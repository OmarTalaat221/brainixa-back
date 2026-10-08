<?php
/**
 * Admin view and control over gateway (EasyKash) payments.
 *
 * There was no admin screen for these at all - `app/admin/payments/` held only the offline flow -
 * so a card payment could not be looked at, let alone corrected. That gap matters most around
 * refunds: the EasyKash account belongs to the client, not to anyone who can ask EasyKash whether
 * they push a REFUNDED callback, so the platform must not depend on being told. These handlers
 * let it find out for itself (`recheck`, which asks EasyKash's Inquiry API about a transaction
 * the platform still believes is paid) and let a human settle it by hand when all else fails
 * (`revoke`).
 */

require_once __DIR__ . '/../../../helpers/functions.php';
require_once __DIR__ . '/../../../helpers/easykash.php';
require_once __DIR__ . '/../../../helpers/payments_grant.php';
require_once __DIR__ . '/../../../helpers/app_settings.php';
// currency_info() and pricing_format_amount() - the figure is printed in the currency it was
// actually taken in, not the platform's base.
require_once __DIR__ . '/../../../helpers/pricing.php';
require_once __DIR__ . '/../../user/student/payments/manage.php';

if (!function_exists('gateway_payment_base_query')) {
    function gateway_payment_base_query(): string {
        return "SELECT t.id, t.student_id, t.item_type, t.item_id, t.amount, t.currency, t.status,
                       t.easykash_ref, t.gateway_reference, t.payment_method, t.granted_ref_id,
                       t.created_at, t.paid_at,
                       s.name AS student_name, s.email AS student_email, s.phone AS student_phone,
                       c.name AS course_name, b.title AS book_title
                FROM payment_transactions t
                LEFT JOIN students s ON s.id = t.student_id
                LEFT JOIN courses c ON c.id = t.item_id AND t.item_type = 'course'
                LEFT JOIN course_books b ON b.id = t.item_id AND t.item_type = 'book'";
    }
}

if (!function_exists('gateway_payment_format')) {
    function gateway_payment_format($con, array $row): array {
        $itemName = $row['item_type'] === 'course'
            ? ($row['course_name'] ?? null)
            : ($row['book_title'] ?? null);

        // Whether the access this payment opened is still standing. A refunded payment whose
        // grant is still active is the exact situation this screen exists to surface, so it is
        // computed here rather than left for the reader to infer from two other columns.
        $accessOpen = $row['granted_ref_id'] !== null && $row['status'] === 'paid';

        $currency = currency_info($con, (string)$row['currency']);

        return [
            'id' => (int)$row['id'],
            'student_id' => (int)$row['student_id'],
            'student_name' => $row['student_name'],
            'student_email' => $row['student_email'],
            'student_phone' => $row['student_phone'],
            'item_type' => $row['item_type'],
            'item_id' => (int)$row['item_id'],
            'item_name' => $itemName,
            'amount' => (float)$row['amount'],
            // The currency object travels with the figure, and the figure is formatted here.
            // Transactions are stored in whatever currency the student was quoted, so a screen
            // that prints the platform's base symbol beside a number taken in another currency
            // is lying about what was charged.
            'currency' => $row['currency'],
            'currency_info' => $currency,
            'amount_formatted' => pricing_format_amount($con, (float)$row['amount'], $currency),
            'status' => $row['status'],
            'easykash_ref' => $row['easykash_ref'],
            'gateway_reference' => $row['gateway_reference'],
            'payment_method' => $row['payment_method'],
            'granted_ref_id' => $row['granted_ref_id'] !== null ? (int)$row['granted_ref_id'] : null,
            'access_granted' => $accessOpen,
            'created_at' => $row['created_at'],
            'paid_at' => $row['paid_at'],
        ];
    }
}

if (!function_exists('gateway_payment_statistics')) {
    function gateway_payment_statistics($con): array {
        $stats = [
            'total_count' => 0,
            'paid_count' => 0,
            'pending_count' => 0,
            'failed_count' => 0,
            'cancelled_count' => 0,
            'paid_amount' => 0.0,
        ];

        $res = mysqli_query($con, "SELECT status, COUNT(*) AS c, SUM(amount) AS total
                                   FROM payment_transactions GROUP BY status");
        if (!$res) return $stats;

        while ($row = mysqli_fetch_assoc($res)) {
            $count = (int)$row['c'];
            $stats['total_count'] += $count;
            $key = $row['status'] . '_count';
            if (array_key_exists($key, $stats)) {
                $stats[$key] = $count;
            }
            if ($row['status'] === 'paid') {
                $stats['paid_amount'] = (float)$row['total'];
            }
        }

        return $stats;
    }
}

if (!function_exists('gateway_find_transaction')) {
    function gateway_find_transaction($con, int $id): ?array {
        $stmt = mysqli_prepare($con, gateway_payment_base_query() . " WHERE t.id = ? LIMIT 1");
        if (!$stmt) return null;
        mysqli_stmt_bind_param($stmt, "i", $id);
        mysqli_stmt_execute($stmt);
        $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));
        return $row ?: null;
    }
}

if (!function_exists('adminListGatewayPayments')) {
    function adminListGatewayPayments($con) {
        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 20)));
        $offset = ($page - 1) * $limit;

        $conditions = [];
        $params = [];
        $types = '';

        $status = trim($_GET['status'] ?? '');
        if (in_array($status, ['pending', 'paid', 'failed', 'cancelled'], true)) {
            $conditions[] = 't.status = ?';
            $params[] = $status;
            $types .= 's';
        }

        $studentId = (int)($_GET['student_id'] ?? 0);
        if ($studentId > 0) {
            $conditions[] = 't.student_id = ?';
            $params[] = $studentId;
            $types .= 'i';
        }

        $itemType = trim($_GET['item_type'] ?? '');
        if (in_array($itemType, ['course', 'book'], true)) {
            $conditions[] = 't.item_type = ?';
            $params[] = $itemType;
            $types .= 's';
        }

        $search = trim($_GET['search'] ?? $_GET['q'] ?? '');
        if ($search !== '') {
            $conditions[] = '(s.name LIKE ? OR s.email LIKE ? OR s.phone LIKE ?
                              OR t.easykash_ref LIKE ? OR t.gateway_reference LIKE ?)';
            $like = '%' . $search . '%';
            array_push($params, $like, $like, $like, $like, $like);
            $types .= 'sssss';
        }

        $where = $conditions ? ' WHERE ' . implode(' AND ', $conditions) : '';

        $total = 0;
        $countStmt = mysqli_prepare(
            $con,
            "SELECT COUNT(*) AS total FROM payment_transactions t
             LEFT JOIN students s ON s.id = t.student_id" . $where
        );
        if ($countStmt) {
            if ($types) mysqli_stmt_bind_param($countStmt, $types, ...$params);
            mysqli_stmt_execute($countStmt);
            $total = (int)(mysqli_fetch_assoc(mysqli_stmt_get_result($countStmt))['total'] ?? 0);
        }

        $stmt = mysqli_prepare($con, gateway_payment_base_query() . $where . " ORDER BY t.id DESC LIMIT {$limit} OFFSET {$offset}");
        if (!$stmt) return ['status' => 'error', 'message' => 'Database error: ' . mysqli_error($con)];
        if ($types) mysqli_stmt_bind_param($stmt, $types, ...$params);
        mysqli_stmt_execute($stmt);
        $res = mysqli_stmt_get_result($stmt);

        $rows = [];
        while ($row = mysqli_fetch_assoc($res)) {
            $rows[] = gateway_payment_format($con, $row);
        }

        return [
            'status' => 'success',
            'data' => $rows,
            'statistics' => gateway_payment_statistics($con),
            'pagination' => [
                'current_page' => $page,
                'per_page' => $limit,
                'total_records' => $total,
                'total_pages' => (int)ceil($total / $limit),
                'has_next_page' => ($offset + $limit) < $total,
                'has_prev_page' => $page > 1,
            ],
        ];
    }
}

if (!function_exists('adminRecheckGatewayPayment')) {
    /**
     * Asks EasyKash what a transaction's status is NOW, and applies the answer.
     *
     * This is the platform's own way of noticing a refund. The student-facing confirm endpoint
     * deliberately stops at a transaction it already believes is paid - re-asking on every page
     * view would hammer the gateway - so nothing re-examines a settled payment. Here an admin
     * can, and because the answer travels through the same processor the callback uses, a
     * REFUNDED answer withdraws access by exactly the same path.
     */
    function adminRecheckGatewayPayment($con) {
        $body = read_json_body();
        $transactionId = (int)($body['transaction_id'] ?? $body['id'] ?? 0);

        if ($transactionId <= 0) {
            return ['status' => 'error', 'message' => 'A transaction_id is required'];
        }

        $tx = gateway_find_transaction($con, $transactionId);
        if (!$tx) {
            return ['status' => 'error', 'message' => 'Unknown transaction'];
        }

        // Ask about the reference actually sent to EasyKash. Transactions predating migration 098
        // carry none and were referenced by their id, so that is the fallback.
        $reference = (string)($tx['gateway_reference'] ?? '');
        if ($reference === '') {
            $reference = (string)$transactionId;
        }

        $inquiry = easykash_inquire_payment($reference);
        easykash_log('Admin recheck of transaction ' . $transactionId . ' (ref ' . $reference . '): ' . json_encode($inquiry, JSON_UNESCAPED_UNICODE));

        if ($inquiry['status'] !== 'success') {
            return [
                'status' => 'error',
                'message' => 'Could not reach EasyKash to check this transaction',
                'gateway_reason' => $inquiry['message'] ?? null,
            ];
        }

        $remote = $inquiry['data'];
        $remoteStatus = strtoupper(trim(easykash_ci_get($remote, 'status')));

        if ($remoteStatus === '' || $remoteStatus === 'NEW') {
            return [
                'status' => 'success',
                'message' => 'EasyKash still reports this payment as not completed',
                'data' => [
                    'transaction_id' => $transactionId,
                    'local_status' => $tx['status'],
                    'gateway_status' => $remoteStatus ?: 'NEW',
                    'changed' => false,
                ],
            ];
        }

        // Signature checking stays off: this data came from a connection we opened and
        // authenticated with our own API key, not from the caller.
        $remote['customerReference'] = $reference;
        $result = payments_process_easykash_result($con, $remote, 0, false);

        $after = gateway_find_transaction($con, $transactionId);

        return [
            'status' => $result['status'],
            'message' => $result['message'] ?? 'Rechecked',
            'data' => [
                'transaction_id' => $transactionId,
                'local_status' => $after['status'] ?? $tx['status'],
                'previous_status' => $tx['status'],
                'gateway_status' => $remoteStatus,
                'changed' => ($after['status'] ?? null) !== $tx['status'],
            ],
        ];
    }
}

if (!function_exists('adminRevokeGatewayPayment')) {
    /**
     * Marks a paid transaction as reversed and withdraws the access it opened.
     *
     * The last resort, for when EasyKash has refunded a payment and neither a callback nor a
     * recheck has reflected it - including the case where the money was returned outside the
     * gateway entirely. It reuses payments_revoke_access(), so it is as narrow as the automatic
     * path: only the row this payment created, and only if it still belongs to that student.
     */
    function adminRevokeGatewayPayment($con, $adminData = null) {
        $body = read_json_body();
        $transactionId = (int)($body['transaction_id'] ?? $body['id'] ?? 0);
        $reason = trim((string)($body['reason'] ?? ''));

        if ($transactionId <= 0) {
            return ['status' => 'error', 'message' => 'A transaction_id is required'];
        }

        $tx = gateway_find_transaction($con, $transactionId);
        if (!$tx) {
            return ['status' => 'error', 'message' => 'Unknown transaction'];
        }

        if ($tx['status'] !== 'paid') {
            return [
                'status' => 'error',
                'message' => app_text(
                    $con,
                    'المعاملة دي مش مدفوعة أصلًا، فمفيش وصول تسحبه.',
                    'This transaction is not in a paid state, so there is no access to withdraw.'
                ),
            ];
        }

        // Flip first and act only if this call is the one that flipped it, so an admin
        // double-clicking cannot revoke twice.
        $updStmt = mysqli_prepare($con, "UPDATE payment_transactions SET status = 'cancelled' WHERE id = ? AND status = 'paid'");
        mysqli_stmt_bind_param($updStmt, "i", $transactionId);
        mysqli_stmt_execute($updStmt);

        if (mysqli_stmt_affected_rows($updStmt) < 1) {
            return [
                'status' => 'error',
                'message' => 'This transaction was already settled by someone else. Reload and try again.',
            ];
        }

        $revoked = payments_revoke_access(
            $con,
            (int)$tx['student_id'],
            $tx['item_type'],
            $tx['granted_ref_id'] !== null ? (int)$tx['granted_ref_id'] : null
        );

        $commissionCancelled = payments_cancel_pending_commission(
            $con,
            (int)$tx['student_id'],
            $tx['item_type'],
            (int)$tx['item_id']
        );

        $adminId = 0;
        if (is_array($adminData)) {
            $adminId = (int)($adminData['id'] ?? $adminData['admin_id'] ?? 0);
        } elseif (is_object($adminData)) {
            $adminId = (int)($adminData->id ?? $adminData->admin_id ?? 0);
        }

        easykash_log(
            'Admin ' . $adminId . ' revoked transaction ' . $transactionId .
            ': revoked=' . ($revoked ? '1' : '0') .
            ' commission_cancelled=' . ($commissionCancelled ? '1' : '0') .
            ($reason !== '' ? ' reason=' . $reason : '')
        );

        return [
            'status' => 'success',
            'message' => app_text(
                $con,
                'تم تسجيل الاسترداد وسحب الوصول.',
                'The refund was recorded and access withdrawn.'
            ),
            'data' => [
                'transaction_id' => $transactionId,
                'payment_status' => 'cancelled',
                'access_revoked' => $revoked,
                'commission_cancelled' => $commissionCancelled,
            ],
        ];
    }
}
