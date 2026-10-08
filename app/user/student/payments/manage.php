<?php
require_once __DIR__ . '/../../../../helpers/functions.php';
require_once __DIR__ . '/../../../../helpers/easykash.php';
require_once __DIR__ . '/../../../../helpers/admin_notifications.php';

require_once __DIR__ . '/../../../../helpers/payments_grant.php';
// app_text() lives here and is used below for the bilingual refusal messages.
require_once __DIR__ . '/../../../../helpers/app_settings.php';


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

        $insStmt = mysqli_prepare($con, "INSERT INTO payment_transactions (student_id, item_type, item_id, amount, currency, status) VALUES (?, ?, ?, ?, ?, 'pending')");
        $currency = $config['currency'];
        mysqli_stmt_bind_param($insStmt, "isids", $stId, $itemType, $itemId, $item['price'], $currency);
        if (!mysqli_stmt_execute($insStmt)) {
            return ['status' => 'error', 'message' => 'Failed to create payment transaction: ' . mysqli_error($con)];
        }
        $transactionId = mysqli_insert_id($con);

        $result = easykash_create_payment([
            'amount' => $item['price'],
            'currency' => $currency,
            'name' => $student['name'],
            'email' => $student['email'],
            'mobile' => $student['phone'] ?? '',
            'redirectUrl' => $redirectUrl,
            'customerReference' => $transactionId,
        ]);

        if ($result['status'] !== 'success') {
            mysqli_query($con, "UPDATE payment_transactions SET status = 'failed' WHERE id = {$transactionId}");
            return ['status' => 'error', 'message' => 'Failed to initiate payment with EasyKash', 'details' => $result['message'] ?? null];
        }

        return [
            'status' => 'success',
            'message' => trans('payment_initiated'),
            'data' => [
                'transaction_id' => $transactionId,
                'amount' => $item['price'],
                'currency' => $currency,
                'payment_url' => $result['redirectUrl'],
            ],
        ];
    }
}

if (!function_exists('payments_process_easykash_result')) {
    function payments_process_easykash_result($con, array $data, int $requireStudentId = 0, bool $requireSignature = true): array {
        $rawCallback = json_encode($data, JSON_UNESCAPED_UNICODE);
        $transactionId = (int)easykash_ci_get($data, 'customerReference');

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

        $stmt = mysqli_prepare($con, "SELECT id, student_id, item_type, item_id, amount, status FROM payment_transactions WHERE id = ? LIMIT 1");
        mysqli_stmt_bind_param($stmt, "i", $transactionId);
        mysqli_stmt_execute($stmt);
        $tx = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));

        if (!$tx) {
            return ['status' => 'error', 'message' => 'Unknown transaction'];
        }

        if ($requireStudentId > 0 && (int)$tx['student_id'] !== $requireStudentId) {
            return ['status' => 'error', 'message' => 'This transaction does not belong to you'];
        }

        if ($tx['status'] === 'paid') {
            return [
                'status' => 'success',
                'message' => 'Transaction already processed',
                'data' => ['transaction_id' => $transactionId, 'payment_status' => 'paid'],
            ];
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

        if (!$isPaid) {
            $newStatus = in_array($paidStatus, ['CANCELED', 'CANCELLED', 'REFUNDED'], true)
                ? 'cancelled'
                : 'failed';
            $updStmt = mysqli_prepare($con, "UPDATE payment_transactions SET status = ?, easykash_ref = ?, payment_method = ?, raw_callback = ? WHERE id = ?");
            mysqli_stmt_bind_param($updStmt, "ssssi", $newStatus, $easykashRef, $paymentMethod, $rawCallback, $transactionId);
            mysqli_stmt_execute($updStmt);
            return [
                'status' => 'success',
                'message' => 'Callback recorded',
                'data' => ['transaction_id' => $transactionId, 'payment_status' => $newStatus],
            ];
        }

        $grantedRefId = payments_grant_access($con, (int)$tx['student_id'], $tx['item_type'], (int)$tx['item_id'], (float)$tx['amount']);

        require_once __DIR__ . '/../affiliate/manage.php';
        if (function_exists('createPendingAffiliateCommission')) {
            createPendingAffiliateCommission($con, (int)$tx['student_id'], $tx['item_type'], (int)$tx['item_id'], (float)$tx['amount']);
        }

        $updStmt = mysqli_prepare($con, "UPDATE payment_transactions SET status = 'paid', easykash_ref = ?, payment_method = ?, granted_ref_id = ?, raw_callback = ?, paid_at = NOW() WHERE id = ?");
        mysqli_stmt_bind_param($updStmt, "ssisi", $easykashRef, $paymentMethod, $grantedRefId, $rawCallback, $transactionId);
        mysqli_stmt_execute($updStmt);

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
        $transactionId = (int)easykash_ci_get($data, 'customerReference');
        if ($transactionId <= 0) {
            $transactionId = (int)($data['transaction_id'] ?? 0);
        }
        if ($transactionId <= 0) {
            return ['status' => 'error', 'message' => 'A transaction id is required'];
        }

        // Ownership is checked before we ask EasyKash anything, so this cannot be used to probe
        // other students' transactions.
        $ownStmt = mysqli_prepare($con, "SELECT id, status FROM payment_transactions WHERE id = ? AND student_id = ? LIMIT 1");
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

        $inquiry = easykash_inquire_payment($transactionId);
        easykash_log('Inquiry for transaction ' . $transactionId . ': ' . json_encode($inquiry, JSON_UNESCAPED_UNICODE));

        if ($inquiry['status'] !== 'success') {
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
        $remote['customerReference'] = $transactionId;

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
