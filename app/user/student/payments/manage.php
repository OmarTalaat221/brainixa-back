<?php
require_once __DIR__ . '/../../../../helpers/functions.php';
require_once __DIR__ . '/../../../../helpers/easykash.php';
require_once __DIR__ . '/../../../../helpers/admin_notifications.php';

require_once __DIR__ . '/../../../../helpers/payments_grant.php';
// app_text() lives here and is used below for the bilingual refusal messages.
require_once __DIR__ . '/../../../../helpers/app_settings.php';
// pricing_for_item() - the per-country price the student was actually shown.
require_once __DIR__ . '/../../../../helpers/pricing.php';


if (!function_exists('payments_new_gateway_reference')) {
    /**
     * A customerReference that EasyKash has certainly never seen.
     *
     * Shaped `BX<transaction id>-<8 random hex>` so a reference found in the gateway's dashboard
     * still points at the local row, while the random tail survives a database rebuild and a
     * second site sharing the merchant account. The UNIQUE index added in migration 098 is the
     * real guarantee; the retry here only keeps an astronomically unlikely clash from surfacing
     * as an error the student would see.
     */
    function payments_new_gateway_reference($con, int $transactionId): string {
        for ($attempt = 0; $attempt < 5; $attempt++) {
            $candidate = 'BX' . $transactionId . '-' . bin2hex(random_bytes(4));

            $stmt = mysqli_prepare($con, "SELECT id FROM payment_transactions WHERE gateway_reference = ? LIMIT 1");
            mysqli_stmt_bind_param($stmt, "s", $candidate);
            mysqli_stmt_execute($stmt);
            $taken = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));

            if (!$taken) {
                return $candidate;
            }
        }

        // Five collisions on 4 random bytes is not a thing that happens; falling back to the
        // clock rather than returning something known-duplicate.
        return 'BX' . $transactionId . '-' . bin2hex(random_bytes(4)) . dechex(time());
    }
}

if (!function_exists('payments_resolve_transaction_by_reference')) {
    /**
     * Finds the transaction a gateway reference belongs to.
     *
     * Two forms are accepted on purpose: the `BX<id>-<hex>` reference sent since migration 098,
     * and a bare integer id, which is what transactions created before it carry. Dropping the
     * second would strand any payment that was already in flight at deploy time.
     */
    function payments_resolve_transaction_by_reference($con, string $reference): int {
        $reference = trim($reference);
        if ($reference === '') {
            return 0;
        }

        $stmt = mysqli_prepare($con, "SELECT id FROM payment_transactions WHERE gateway_reference = ? LIMIT 1");
        mysqli_stmt_bind_param($stmt, "s", $reference);
        mysqli_stmt_execute($stmt);
        $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));

        if ($row) {
            return (int)$row['id'];
        }

        // Legacy: the reference WAS the id. Only honoured when the whole string is a number, so
        // "BX8-a1b2c3d4" can never be read as transaction 8 by a sloppy integer cast.
        return ctype_digit($reference) ? (int)$reference : 0;
    }
}

if (!function_exists('studentInitiatePayment')) {
    function studentInitiatePayment($con, $studentData = null) {
        $stId = 0;
        if (is_array($studentData)) {
            $stId = (int)($studentData['id'] ?? $studentData['student_id'] ?? 0);
        } elseif (is_object($studentData)) {
            $stId = (int)($studentData->id ?? $studentData->student_id ?? 0);
        }
        if ($stId <= 0) {
            return ['status' => 'error', 'message' => trans('student_auth_required')];
        }

        $body = read_json_body();
        $itemType = strtolower(trim($body['item_type'] ?? ''));
        $itemId = (int)($body['item_id'] ?? 0);

        if (!in_array($itemType, ['course', 'book'], true) || $itemId <= 0) {
            return ['status' => 'error', 'message' => trans('invalid_request') ?? 'A valid item_type (course|book) and item_id are required'];
        }

        $item = payments_resolve_purchasable_item($con, $itemType, $itemId);
        if (!$item || (int)$item['is_active'] !== 1) {
            return ['status' => 'error', 'message' => trans('item_not_found_or_unavailable')];
        }
        if ($item['price'] <= 0) {
            return ['status' => 'error', 'message' => trans('item_is_free')];
        }
        if (payments_student_already_has_access($con, $stId, $itemType, $itemId)) {
            return ['status' => 'error', 'message' => trans('already_have_access')];
        }

        $stStmt = mysqli_prepare($con, "SELECT name, email, phone FROM students WHERE id = ? LIMIT 1");
        mysqli_stmt_bind_param($stStmt, "i", $stId);
        mysqli_stmt_execute($stStmt);
        $student = mysqli_fetch_assoc(mysqli_stmt_get_result($stStmt));
        if (!$student) {
            return ['status' => 'error', 'message' => trans('student_not_found')];
        }

        // EasyKash requires name, email AND mobile on every payment request. `students.email`
        // became nullable in migration 095 so a student can sign up with a phone only, and
        // `phone` can be blank too - so without this check the gateway rejects the request and
        // the student sees a meaningless failure instead of being told what is missing.
        $missing = [];
        if (trim((string)($student['email'] ?? '')) === '') $missing[] = 'email';
        if (trim((string)($student['phone'] ?? '')) === '') $missing[] = 'phone';
        if ($missing) {
            return [
                'status' => 'error',
                'error_code' => 'profile_incomplete',
                'missing_fields' => $missing,
                'message' => app_text(
                    $con,
                    'عشان تدفع أونلاين لازم يكون في إيميل ورقم تليفون في حسابك. كمّل بياناتك وجرب تاني.',
                    'Online payment needs an email address and a phone number on your account. Please complete your profile and try again.'
                ),
            ];
        }

        $config = easykash_config();
        $redirectUrl = trim($body['redirect_url'] ?? '') ?: $config['default_redirect_url'];

        // The amount and the currency both come from the pricing engine, exactly as the offline
        // path takes them. Charging `$item['price']` in the configured currency - which is what
        // this used to do - ignores the per-country price table: a student shown "150 SAR" on the
        // course page would have been charged the base figure, in pounds.
        $priced = pricing_for_item($con, $itemType, $itemId, (float)$item['price'], $stId);
        $amount = (float)$priced['price'];
        $currency = (string)$priced['currency']['code'];

        if ($amount <= 0) {
            return ['status' => 'error', 'message' => trans('item_is_free')];
        }

        $insStmt = mysqli_prepare($con, "INSERT INTO payment_transactions (student_id, item_type, item_id, amount, currency, status) VALUES (?, ?, ?, ?, ?, 'pending')");
        mysqli_stmt_bind_param($insStmt, "isids", $stId, $itemType, $itemId, $amount, $currency);
        if (!mysqli_stmt_execute($insStmt)) {
            return ['status' => 'error', 'message' => 'Failed to create payment transaction: ' . mysqli_error($con)];
        }
        $transactionId = mysqli_insert_id($con);

        // EasyKash burns a customerReference permanently, and does so per MERCHANT ACCOUNT. The
        // row id was being sent, which collides three ways: Brainixa and Najeh share the account,
        // a rebuilt database restarts the counter onto references already spent, and a failed
        // attempt still consumes its own. The random tail makes the reference unique for all
        // time; the row id stays the local key and is still readable inside it.
        $gatewayRef = payments_new_gateway_reference($con, $transactionId);

        $refStmt = mysqli_prepare($con, "UPDATE payment_transactions SET gateway_reference = ? WHERE id = ?");
        mysqli_stmt_bind_param($refStmt, "si", $gatewayRef, $transactionId);
        mysqli_stmt_execute($refStmt);

        $result = easykash_create_payment([
            'amount' => $amount,
            'currency' => $currency,
            'name' => $student['name'],
            'email' => $student['email'],
            'mobile' => $student['phone'] ?? '',
            'redirectUrl' => $redirectUrl,
            'customerReference' => $gatewayRef,
        ]);

        if ($result['status'] !== 'success') {
            mysqli_query($con, "UPDATE payment_transactions SET status = 'failed' WHERE id = {$transactionId}");

            // `details` used to carry only our own generic sentence, so the gateway's actual
            // complaint - which it does state, field by field - never reached anyone. The
            // specific reason goes out alongside it; the full response stays in the log.
            return [
                'status' => 'error',
                'message' => 'Failed to initiate payment with EasyKash',
                'details' => $result['message'] ?? null,
                'gateway_reason' => $result['reason'] ?? ($result['error'] ?? null),
                'gateway_http_code' => $result['http_code'] ?? null,
                'transaction_id' => $transactionId,
            ];
        }

        return [
            'status' => 'success',
            'message' => trans('payment_initiated'),
            'data' => [
                'transaction_id' => $transactionId,
                'amount' => $amount,
                'currency' => $currency,
                'amount_formatted' => $priced['price_formatted'] ?? null,
                'payment_url' => $result['redirectUrl'],
            ],
        ];
    }
}

if (!function_exists('payments_process_easykash_result')) {
    function payments_process_easykash_result($con, array $data, int $requireStudentId = 0, bool $requireSignature = true): array {
        $rawCallback = json_encode($data, JSON_UNESCAPED_UNICODE);

        // `(int)` on the reference used to be enough, when the reference was the row id. It now
        // arrives as "BX8-a1b2c3d4", which an integer cast would silently read as 8 - a real
        // transaction belonging to someone else. Resolved through the lookup instead.
        $transactionId = payments_resolve_transaction_by_reference(
            $con,
            easykash_ci_get($data, 'customerReference')
        );

        if ($requireSignature && !easykash_verify_callback_signature($data)) {
            if ($transactionId > 0) {
                $updStmt = mysqli_prepare($con, "UPDATE payment_transactions SET raw_callback = ? WHERE id = ?");
                mysqli_stmt_bind_param($updStmt, "si", $rawCallback, $transactionId);
                mysqli_stmt_execute($updStmt);
            }
            return ['status' => 'error', 'message' => 'Invalid signature'];
        }

        if ($transactionId <= 0) {
            return ['status' => 'error', 'message' => 'Missing customerReference'];
        }

        $stmt = mysqli_prepare($con, "SELECT id, student_id, item_type, item_id, amount, status, granted_ref_id FROM payment_transactions WHERE id = ? LIMIT 1");
        mysqli_stmt_bind_param($stmt, "i", $transactionId);
        mysqli_stmt_execute($stmt);
        $tx = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));

        if (!$tx) {
            return ['status' => 'error', 'message' => 'Unknown transaction'];
        }

        if ($requireStudentId > 0 && (int)$tx['student_id'] !== $requireStudentId) {
            return ['status' => 'error', 'message' => 'This transaction does not belong to you'];
        }

        $paidStatus = strtoupper(trim(easykash_ci_get($data, 'status')));
        $easykashRef = easykash_ci_get($data, 'easykashRef') ?: (easykash_ci_get($data, 'providerRefNum') ?: null);
        $paymentMethod = easykash_ci_get($data, 'PaymentMethod') ?: null;

        // EasyKash's documented statuses are DELIVERED, EXPIRED, FAILED, NEW, PAID, REFUNDED,
        // CANCELED. Three of those need saying out loud:
        //
        //   DELIVERED is a state a transaction reaches AFTER being paid, so treating it as
        //   anything but paid would deny access to someone who has already paid.
        //   CANCELED is spelled with one L by EasyKash; the old check looked for 'CANCELLED' and
        //   therefore never matched, filing every cancellation as a failure.
        //   REFUNDED means the money went back, so access should not stand - 'cancelled' is the
        //   closest the column's enum gets.
        $isPaid = in_array($paidStatus, ['PAID', 'DELIVERED'], true);
        $isReversed = in_array($paidStatus, ['CANCELED', 'CANCELLED', 'REFUNDED'], true);

        // A transaction already settled as paid used to return "already processed" here and stop,
        // whatever the gateway had just said. That made a refund a no-op: EasyKash took the money
        // back and the student kept the course for good. The short-circuit still stands for a
        // repeated PAID - it is what keeps a double callback from granting twice - but a reversal
        // arriving against a paid transaction is now acted on.
        if ($tx['status'] === 'paid') {
            if (!$isReversed) {
                return [
                    'status' => 'success',
                    'message' => 'Transaction already processed',
                    'data' => ['transaction_id' => $transactionId, 'payment_status' => 'paid'],
                ];
            }

            // Flip the transaction first, and only act if THIS call is the one that flipped it.
            // Two reversals racing - a callback and the student reopening the result page - would
            // otherwise both pass the read above and revoke twice.
            $revStmt = mysqli_prepare($con, "UPDATE payment_transactions SET status = 'cancelled', raw_callback = ? WHERE id = ? AND status = 'paid'");
            mysqli_stmt_bind_param($revStmt, "si", $rawCallback, $transactionId);
            mysqli_stmt_execute($revStmt);

            if (mysqli_stmt_affected_rows($revStmt) < 1) {
                return [
                    'status' => 'success',
                    'message' => 'Transaction already processed',
                    'data' => ['transaction_id' => $transactionId, 'payment_status' => 'cancelled'],
                ];
            }

            $revoked = payments_revoke_access(
                $con,
                (int)$tx['student_id'],
                $tx['item_type'],
                isset($tx['granted_ref_id']) ? (int)$tx['granted_ref_id'] : null
            );

            // The purchase had earned the referrer a pending commission; a reversed purchase
            // should not keep earning it. Lives in payments_grant.php, required at the top.
            $commissionCancelled = payments_cancel_pending_commission(
                $con,
                (int)$tx['student_id'],
                $tx['item_type'],
                (int)$tx['item_id']
            );

            // Worth a line in the log either way: `revoked=0` means the grant row was already
            // closed or was never recorded, which is the case a human may need to finish by hand.
            easykash_log(
                'Reversal (' . $paidStatus . ') for transaction ' . $transactionId .
                ': revoked=' . ($revoked ? '1' : '0') .
                ' commission_cancelled=' . ($commissionCancelled ? '1' : '0')
            );

            return [
                'status' => 'success',
                'message' => 'Payment reversed and access withdrawn',
                'data' => [
                    'transaction_id' => $transactionId,
                    'payment_status' => 'cancelled',
                    'access_revoked' => $revoked,
                ],
            ];
        }

        if (!$isPaid) {
            $newStatus = $isReversed ? 'cancelled' : 'failed';
            $updStmt = mysqli_prepare($con, "UPDATE payment_transactions SET status = ?, easykash_ref = ?, payment_method = ?, raw_callback = ? WHERE id = ?");
            mysqli_stmt_bind_param($updStmt, "ssssi", $newStatus, $easykashRef, $paymentMethod, $rawCallback, $transactionId);
            mysqli_stmt_execute($updStmt);
            return [
                'status' => 'success',
                'message' => 'Callback recorded',
                'data' => ['transaction_id' => $transactionId, 'payment_status' => $newStatus],
            ];
        }

        // Claim the transaction BEFORE granting anything.
        //
        // The order used to be the other way round - grant, create the commission, then record
        // the payment - with nothing but a plain SELECT a few lines above deciding whether this
        // call should proceed. Two callers arriving together both read 'pending', both granted,
        // and the student ended up with two subscriptions and the referrer with two commissions
        // for one payment. And they do arrive together: EasyKash's own server-to-server callback
        // and the student's browser landing on /payment/result fire at the same moment.
        //
        // `status <> 'paid'` rather than `= 'pending'` on purpose: a voucher we had already
        // written off as failed can still be paid later, and that late PAID must be honoured.
        // This is the pattern the offline path has always used.
        $claimStmt = mysqli_prepare($con, "UPDATE payment_transactions
            SET status = 'paid', easykash_ref = ?, payment_method = ?, raw_callback = ?, paid_at = NOW()
            WHERE id = ? AND status <> 'paid'");
        mysqli_stmt_bind_param($claimStmt, "sssi", $easykashRef, $paymentMethod, $rawCallback, $transactionId);
        mysqli_stmt_execute($claimStmt);

        if (mysqli_stmt_affected_rows($claimStmt) < 1) {
            // Someone else got here first. Theirs is the call that grants.
            return [
                'status' => 'success',
                'message' => 'Transaction already processed',
                'data' => ['transaction_id' => $transactionId, 'payment_status' => 'paid'],
            ];
        }

        $grantedRefId = payments_grant_access($con, (int)$tx['student_id'], $tx['item_type'], (int)$tx['item_id'], (float)$tx['amount']);

        if ($grantedRefId === null) {
            // The money is real and stays recorded as paid - but the student has nothing. Said
            // out loud rather than returning success, because this is the one case where a silent
            // "paid" would leave somebody who has paid locked out with nobody aware of it. The
            // admin gateway screen shows it as paid with no grant.
            easykash_log(
                'GRANT FAILED after payment. transaction=' . $transactionId .
                ' student=' . (int)$tx['student_id'] .
                ' item=' . $tx['item_type'] . '#' . (int)$tx['item_id'] .
                ' - money taken, access NOT given'
            );

            return [
                'status' => 'error',
                'error_code' => 'grant_failed',
                'message' => app_text(
                    $con,
                    'تم الدفع بنجاح بس حصلت مشكلة في فتح المحتوى. تواصل معانا وهنفتحه لك فورًا.',
                    'Your payment went through, but we could not open the content. Contact us and we will open it right away.'
                ),
                'data' => ['transaction_id' => $transactionId, 'payment_status' => 'paid'],
            ];
        }

        $refStmt = mysqli_prepare($con, "UPDATE payment_transactions SET granted_ref_id = ? WHERE id = ?");
        mysqli_stmt_bind_param($refStmt, "ii", $grantedRefId, $transactionId);
        mysqli_stmt_execute($refStmt);

        require_once __DIR__ . '/../affiliate/manage.php';
        if (function_exists('createPendingAffiliateCommission')) {
            createPendingAffiliateCommission($con, (int)$tx['student_id'], $tx['item_type'], (int)$tx['item_id'], (float)$tx['amount']);
        }

        return [
            'status' => 'success',
            'message' => trans('payment_confirmed_access_granted'),
            'data' => ['transaction_id' => $transactionId, 'payment_status' => 'paid'],
        ];
    }
}

if (!function_exists('paymentsEasykashCallback')) {
    function paymentsEasykashCallback($con) {
        // Merge GET and POST: EasyKash's own docs are inconsistent about whether the
        // callback arrives as query params or a POST body, so accept either.
        $data = array_merge($_GET, $_POST);

        // Always log the raw callback attempt, even if signature verification fails below,
        // so a bad/rejected callback can be diagnosed instead of silently vanishing.
        easykash_log('Callback received: ' . json_encode($data, JSON_UNESCAPED_UNICODE));

        return payments_process_easykash_result($con, $data);
    }
}

if (!function_exists('studentConfirmPayment')) {
    function studentConfirmPayment($con, $studentData = null) {
        $stId = 0;
        if (is_array($studentData)) {
            $stId = (int)($studentData['id'] ?? $studentData['student_id'] ?? 0);
        } elseif (is_object($studentData)) {
            $stId = (int)($studentData->id ?? $studentData->student_id ?? 0);
        }
        if ($stId <= 0) {
            return ['status' => 'error', 'message' => 'Student authentication is required'];
        }

        $data = array_merge($_GET, read_json_body());
        easykash_log('Frontend confirm received (student ' . $stId . '): ' . json_encode($data, JSON_UNESCAPED_UNICODE));

        // SECURITY: nothing the browser sent is believed.
        //
        // This endpoint used to pass the request body straight into the processor with signature
        // checking turned off, so a signed-in student could POST {customerReference: <their own
        // pending transaction>, status: "PAID"} and be granted the course without paying. The only
        // thing taken from the request now is WHICH transaction to ask about; the answer comes from
        // EasyKash itself, over a connection we open and authenticate with our own API key.
        $transactionId = payments_resolve_transaction_by_reference(
            $con,
            easykash_ci_get($data, 'customerReference')
        );
        if ($transactionId <= 0) {
            $transactionId = (int)($data['transaction_id'] ?? 0);
        }
        if ($transactionId <= 0) {
            return ['status' => 'error', 'message' => 'A transaction id is required'];
        }

        // Ownership is checked before we ask EasyKash anything, so this cannot be used to probe
        // other students' transactions.
        $ownStmt = mysqli_prepare($con, "SELECT id, status, gateway_reference FROM payment_transactions WHERE id = ? AND student_id = ? LIMIT 1");
        mysqli_stmt_bind_param($ownStmt, "ii", $transactionId, $stId);
        mysqli_stmt_execute($ownStmt);
        $own = mysqli_fetch_assoc(mysqli_stmt_get_result($ownStmt));
        if (!$own) {
            return ['status' => 'error', 'message' => 'This transaction does not belong to you'];
        }

        if ($own['status'] === 'paid') {
            return [
                'status' => 'success',
                'message' => 'Transaction already processed',
                'data' => ['transaction_id' => $transactionId, 'payment_status' => 'paid'],
            ];
        }

        // Ask about the reference that was actually sent. EasyKash knows nothing about our row
        // ids, so querying by id would miss every transaction created since migration 098 - and
        // worse, could match a DIFFERENT merchant's old reference that happens to be that number.
        $inquiryRef = (string)($own['gateway_reference'] ?? '');
        if ($inquiryRef === '') {
            $inquiryRef = (string)$transactionId;
        }

        $inquiry = easykash_inquire_payment($inquiryRef);
        easykash_log('Inquiry for transaction ' . $transactionId . ' (ref ' . $inquiryRef . '): ' . json_encode($inquiry, JSON_UNESCAPED_UNICODE));

        if ($inquiry['status'] !== 'success') {
            // A student who opened the gateway and came back without paying gets this answer.
            // It is not an error on their part or ours, and telling them their payment "could not
            // be confirmed" would suggest money might have moved when none did.
            if (($inquiry['error_code'] ?? '') === 'not_attempted') {
                return [
                    'status' => 'success',
                    'message' => trans('payment_still_pending') ?: 'Payment is still pending.',
                    'data' => ['transaction_id' => $transactionId, 'payment_status' => 'pending'],
                ];
            }

            // The gateway being unreachable is not a failed payment. The transaction is left
            // pending so the callback - or a later retry - can still settle it.
            return [
                'status' => 'error',
                'message' => trans('payment_status_unavailable') ?: 'Could not reach EasyKash to confirm this payment. Please try again shortly.',
            ];
        }

        $remote = $inquiry['data'];
        $remoteStatus = strtoupper(trim(easykash_ci_get($remote, 'status')));

        // NEW means the buyer has not finished paying - a cash voucher still waiting to be paid,
        // for instance. Marking that 'failed' would bury a payment that is still perfectly alive.
        if ($remoteStatus === 'NEW' || $remoteStatus === '') {
            return [
                'status' => 'success',
                'message' => trans('payment_still_pending') ?: 'Payment is still pending.',
                'data' => ['transaction_id' => $transactionId, 'payment_status' => 'pending'],
            ];
        }

        // The processor expects callback-shaped input, so the inquiry answer is handed over under
        // the same field names. Signature checking stays off here on purpose and is safe now: this
        // data came from EasyKash, not from the caller.
        $remote['customerReference'] = $inquiryRef;

        return payments_process_easykash_result($con, $remote, $stId, false);
    }
}

if (!function_exists('studentGetPaymentStatus')) {
    function studentGetPaymentStatus($con, $studentData = null, int $transactionId = 0) {
        $stId = 0;
        if (is_array($studentData)) {
            $stId = (int)($studentData['id'] ?? $studentData['student_id'] ?? 0);
        } elseif (is_object($studentData)) {
            $stId = (int)($studentData->id ?? $studentData->student_id ?? 0);
        }
        if ($stId <= 0 || $transactionId <= 0) {
            return ['status' => 'error', 'message' => 'Invalid request'];
        }

        $stmt = mysqli_prepare($con, "SELECT id, item_type, item_id, amount, currency, status, created_at, paid_at FROM payment_transactions WHERE id = ? AND student_id = ? LIMIT 1");
        mysqli_stmt_bind_param($stmt, "ii", $transactionId, $stId);
        mysqli_stmt_execute($stmt);
        $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));

        if (!$row) {
            return ['status' => 'error', 'message' => 'Transaction not found'];
        }

        $row['id'] = (int)$row['id'];
        $row['item_id'] = (int)$row['item_id'];
        $row['amount'] = (float)$row['amount'];

        return ['status' => 'success', 'data' => $row];
    }
}
