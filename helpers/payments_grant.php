<?php
require_once __DIR__ . '/functions.php';
require_once __DIR__ . '/admin_notifications.php';

/**
 * Granting paid access, independent of how the money arrived.
 *
 * These three lived inside the gateway handler, which made anything that wanted to grant access
 * after a payment drag a payment gateway in with it. Nothing here knows or cares whether the
 * money came through a gateway, a bank transfer or an admin deciding it did - it resolves what is
 * being bought, checks the student does not already own it, and opens the access.
 */
if (!function_exists('payments_resolve_purchasable_item')) {
    function payments_resolve_purchasable_item($con, string $itemType, int $itemId) {
        if ($itemType === 'course') {
            $stmt = mysqli_prepare($con, "SELECT id, price, is_active FROM courses WHERE id = ? LIMIT 1");
        } elseif ($itemType === 'book') {
            $stmt = mysqli_prepare($con, "SELECT id, price, is_active FROM course_books WHERE id = ? LIMIT 1");
        } else {
            return null;
        }
        if (!$stmt) return null;
        mysqli_stmt_bind_param($stmt, "i", $itemId);
        mysqli_stmt_execute($stmt);
        $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));
        if (!$row) return null;
        $row['id'] = (int)$row['id'];
        $row['price'] = (float)$row['price'];
        $row['is_active'] = (int)$row['is_active'];
        return $row;
    }
}

if (!function_exists('payments_student_already_has_access')) {
    function payments_student_already_has_access($con, int $studentId, string $itemType, int $itemId): bool {
        if ($itemType === 'course') {
            $stmt = mysqli_prepare($con, "SELECT ss.id FROM student_subscription_courses ssc
                JOIN student_subscriptions ss ON ss.id = ssc.student_subscription_id
                WHERE ss.student_id = ? AND ssc.course_id = ? AND ss.is_active = 1
                AND (ss.end_date IS NULL OR ss.end_date >= NOW()) LIMIT 1");
        } else {
            $stmt = mysqli_prepare($con, "SELECT id FROM student_book_subscriptions
                WHERE student_id = ? AND book_id = ? AND is_active = 1 LIMIT 1");
        }
        if (!$stmt) return false;
        mysqli_stmt_bind_param($stmt, "ii", $studentId, $itemId);
        mysqli_stmt_execute($stmt);
        return (bool)mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));
    }
}

if (!function_exists('payments_grant_access')) {
    function payments_grant_access($con, int $studentId, string $itemType, int $itemId, float $price): ?int {
        if ($itemType === 'course') {
            // A package sells a fixed period (courses.duration_months), so the access it grants
            // has to expire with it; an ordinary course stays open ended as before.
            $kindStmt = mysqli_prepare($con, "SELECT kind, duration_months FROM courses WHERE id = ? LIMIT 1");
            mysqli_stmt_bind_param($kindStmt, "i", $itemId);
            mysqli_stmt_execute($kindStmt);
            $courseRow = mysqli_fetch_assoc(mysqli_stmt_get_result($kindStmt));

            $subscriptionType = ($courseRow['kind'] ?? 'normal') === 'package' ? 'package' : 'course';
            $months = (int)($courseRow['duration_months'] ?? 0);
            $endDate = $months > 0 ? date('Y-m-d H:i:s', strtotime("+{$months} months")) : null;

            $stmt = mysqli_prepare($con, "INSERT INTO student_subscriptions (student_id, subscription_type, start_date, end_date, is_active) VALUES (?, ?, NOW(), ?, 1)");
            mysqli_stmt_bind_param($stmt, "iss", $studentId, $subscriptionType, $endDate);
            if (!mysqli_stmt_execute($stmt)) return null;
            $subId = mysqli_insert_id($con);

            $linkStmt = mysqli_prepare($con, "INSERT INTO student_subscription_courses (student_subscription_id, course_id) VALUES (?, ?) ON DUPLICATE KEY UPDATE course_id = course_id");
            mysqli_stmt_bind_param($linkStmt, "ii", $subId, $itemId);
            mysqli_stmt_execute($linkStmt);

            notify_of_course_subscription($con, $studentId, [$itemId], 'شراء مباشر');

            return $subId;
        }

        $stmt = mysqli_prepare($con, "INSERT INTO student_book_subscriptions (student_id, book_id, granted_by_type, granted_by_id, price, is_active) VALUES (?, ?, 'student', ?, ?, 1)");
        mysqli_stmt_bind_param($stmt, "iiid", $studentId, $itemId, $studentId, $price);
        if (!mysqli_stmt_execute($stmt)) return null;
        $grantedId = mysqli_insert_id($con);

        // Paying for a book and asking a teacher to approve it are two doors into the same room.
        // A student who filed a request and then just paid used to leave that request sitting
        // `pending` in the teacher's queue forever, with an Approve button for access the student
        // already has. Close it here, and say why.
        $closeStmt = mysqli_prepare($con, "UPDATE student_book_purchase_requests SET status = 'approved', review_notes = 'تمت الموافقة تلقائيًا بعد إتمام الدفع' WHERE student_id = ? AND book_id = ? AND status = 'pending'");
        if ($closeStmt) {
            mysqli_stmt_bind_param($closeStmt, "ii", $studentId, $itemId);
            mysqli_stmt_execute($closeStmt);
        }

        return $grantedId;
    }
}

if (!function_exists('payments_revoke_access')) {
    /**
     * Closes access that a specific payment opened, when that payment is reversed.
     *
     * Deliberately narrow: it acts on the ONE row `payments_grant_access()` created, identified by
     * the `granted_ref_id` stored on the transaction, and only if that row still belongs to the
     * same student. A student who also bought the course offline, or was given it by an admin,
     * holds a different row, and a refund of this payment must not take that away.
     *
     * Rows are deactivated rather than deleted, so the history of what was granted and withdrawn
     * survives.
     *
     * Returns true only if a row was actually closed, so the caller can tell a real revocation
     * from a repeat of one already done.
     */
    function payments_revoke_access($con, int $studentId, string $itemType, ?int $grantedRefId): bool {
        if ($studentId <= 0 || !$grantedRefId || $grantedRefId <= 0) {
            return false;
        }

        if ($itemType === 'course') {
            // granted_ref_id is the student_subscriptions row. Its linked courses go with it:
            // the access check joins through student_subscriptions.is_active, so closing the
            // subscription closes every course it opened.
            $stmt = mysqli_prepare($con, "UPDATE student_subscriptions SET is_active = 0 WHERE id = ? AND student_id = ? AND is_active = 1");
        } elseif ($itemType === 'book') {
            $stmt = mysqli_prepare($con, "UPDATE student_book_subscriptions SET is_active = 0 WHERE id = ? AND student_id = ? AND is_active = 1");
        } else {
            return false;
        }

        if (!$stmt) return false;

        mysqli_stmt_bind_param($stmt, "ii", $grantedRefId, $studentId);
        if (!mysqli_stmt_execute($stmt)) return false;

        return mysqli_stmt_affected_rows($stmt) > 0;
    }
}

if (!function_exists('payments_cancel_pending_commission')) {
    /**
     * Withdraws the affiliate commission a reversed purchase had earned.
     *
     * Only a commission still `pending` is touched. One already approved or paid means money has
     * moved, or an admin has decided it should; reversing that silently here would make the
     * affiliate's balance disagree with what they were told, so it is left for a human and
     * reported back to the caller.
     */
    function payments_cancel_pending_commission($con, int $studentId, string $itemType, int $itemId): bool {
        if ($studentId <= 0 || $itemId <= 0) return false;

        $stmt = mysqli_prepare($con, "UPDATE affiliate_commissions SET status = 'rejected'
            WHERE referred_student_id = ? AND item_type = ? AND item_id = ? AND status = 'pending'");
        if (!$stmt) return false;

        mysqli_stmt_bind_param($stmt, "isi", $studentId, $itemType, $itemId);
        if (!mysqli_stmt_execute($stmt)) return false;

        return mysqli_stmt_affected_rows($stmt) > 0;
    }
}
