<?php
require_once __DIR__ . '/../../../helpers/functions.php';
require_once __DIR__ . '/../../../helpers/language.php';
require_once __DIR__ . '/../../../helpers/upload.php';
require_once __DIR__ . '/../../../helpers/entities.php';
require_once __DIR__ . '/../../../helpers/app_settings.php';
require_once __DIR__ . '/../../../helpers/teacher_ownership.php';

// teacher_book_ownership_clause() now lives in helpers/teacher_ownership.php.

if (!function_exists('teacherGrantBookAccessToStudent')) {
    function teacherGrantBookAccessToStudent($con, $teacherData = null) {
        $teacherId = (int)($teacherData['id'] ?? 0);
        $body = read_json_body();

        $bookId = (int)($body['book_id'] ?? $body['id'] ?? $_GET['book_id'] ?? 0);
        $studentIds = [];
        if (!empty($body['student_ids']) && is_array($body['student_ids'])) {
            $studentIds = array_map('intval', $body['student_ids']);
        } elseif (!empty($body['student_id'])) {
            $studentIds = [(int)$body['student_id']];
        } elseif (!empty($_GET['student_id'])) {
            $studentIds = [(int)$_GET['student_id']];
        }

        if ($bookId <= 0 || empty($studentIds)) {
            return ['status' => 'error', 'message' => 'book_id and student_id (or student_ids) are required'];
        }

        $bRes = mysqli_query($con, "SELECT id, price FROM course_books WHERE id = {$bookId} LIMIT 1");
        $bRow = $bRes ? mysqli_fetch_assoc($bRes) : null;
        if (!$bRow) {
            return ['status' => 'error', 'message' => 'Book not found'];
        }

        $price = (float)($bRow['price'] ?? 0.00);
        $grantedCount = 0;

        foreach ($studentIds as $stId) {
            if ($stId <= 0) continue;

            $chk = mysqli_query($con, "SELECT id FROM student_book_subscriptions WHERE student_id = {$stId} AND book_id = {$bookId} LIMIT 1");
            if ($chk && mysqli_num_rows($chk) > 0) {
                mysqli_query($con, "UPDATE student_book_subscriptions SET is_active = 1 WHERE student_id = {$stId} AND book_id = {$bookId}");
            } else {
                mysqli_query($con, "INSERT INTO student_book_subscriptions (student_id, book_id, granted_by_type, granted_by_id, price, is_active) VALUES ({$stId}, {$bookId}, 'teacher', {$teacherId}, {$price}, 1)");
            }

            $subStmt = mysqli_prepare($con, "INSERT INTO student_subscriptions (student_id, subscription_type, is_active) VALUES (?, 'custom', 1)");
            if ($subStmt) {
                mysqli_stmt_bind_param($subStmt, "i", $stId);
                mysqli_stmt_execute($subStmt);
                $subId = mysqli_insert_id($con);
                if ($subId > 0) {
                    mysqli_query($con, "INSERT INTO student_subscription_books (student_subscription_id, book_id) VALUES ({$subId}, {$bookId})");
                }
            }

            $grantedCount++;
        }

        return [
            'status' => 'success',
            'message' => "Book access granted successfully to {$grantedCount} student(s)",
            'data' => [
                'book_id' => $bookId,
                'granted_students_count' => $grantedCount
            ]
        ];
    }
}

if (!function_exists('teacherListBookPurchaseRequests')) {
    function teacherListBookPurchaseRequests($con, $teacherData = null) {
        $teacherId = (int)($teacherData['id'] ?? $teacherData['teacher_id'] ?? 0);
        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 20)));
        $offset = ($page - 1) * $limit;

        $studentId = (int)($_GET['student_id'] ?? 0);
        $bookId = (int)($_GET['book_id'] ?? 0);
        $status = trim($_GET['status'] ?? '');
        $search = trim($_GET['search'] ?? $_GET['q'] ?? '');

        $langInfo = get_language_info($con);
        $langId = (int)($langInfo['id'] ?? 1);

        $whereClause = "WHERE " . teacher_book_ownership_clause($teacherId);

        if ($studentId > 0) {
            $whereClause .= " AND sbpr.student_id = {$studentId}";
        }
        if ($bookId > 0) {
            $whereClause .= " AND sbpr.book_id = {$bookId}";
        }
        if ($status !== '') {
            $statusEsc = mysqli_real_escape_string($con, $status);
            $whereClause .= " AND sbpr.status = '{$statusEsc}'";
        }
        if (!empty($search)) {
            $sp = '%' . mysqli_real_escape_string($con, $search) . '%';
            $whereClause .= " AND (st.name LIKE '{$sp}' OR st.email LIKE '{$sp}' OR st.phone LIKE '{$sp}' OR cbt.title LIKE '{$sp}' OR sbpr.status LIKE '{$sp}' OR sbpr.notes LIKE '{$sp}')";
        }

        $countRes = mysqli_query($con, "
            SELECT COUNT(DISTINCT sbpr.id) AS total
            FROM student_book_purchase_requests sbpr
            JOIN students st ON sbpr.student_id = st.id
            LEFT JOIN course_books cb ON sbpr.book_id = cb.id
            LEFT JOIN course_books_translations cbt ON cb.id = cbt.book_id AND cbt.language_id = {$langId}
            {$whereClause}
        ");

        $totalRecords = $countRes ? (int)(mysqli_fetch_assoc($countRes)['total'] ?? 0) : 0;

        $sql = "
            SELECT sbpr.id, sbpr.student_id, sbpr.book_id, sbpr.status, sbpr.reviewed_by_type, sbpr.reviewed_by_id, sbpr.notes, sbpr.review_notes, sbpr.created_at, sbpr.updated_at,
                   st.name AS student_name, st.email AS student_email, st.phone AS student_phone, st.image AS student_image,
                   COALESCE(cbt.title, cb.file_path) AS book_title,
                   cbt.description AS book_description,
                   cb.file_path AS book_file_path,
                   cb.cover_image AS book_cover_image,
                   cb.price AS book_price,
                   cb.allow_download AS book_allow_download
            FROM student_book_purchase_requests sbpr
            JOIN students st ON sbpr.student_id = st.id
            LEFT JOIN course_books cb ON sbpr.book_id = cb.id
            LEFT JOIN course_books_translations cbt ON cb.id = cbt.book_id AND cbt.language_id = {$langId}
            {$whereClause}
            ORDER BY sbpr.id DESC
            LIMIT {$limit} OFFSET {$offset}
        ";

        $res = mysqli_query($con, $sql);
        $items = [];
        if ($res) {
            while ($row = mysqli_fetch_assoc($res)) {
                $row['id'] = (int)$row['id'];
                $row['student_id'] = (int)$row['student_id'];
                $row['book_id'] = (int)$row['book_id'];
                $row['reviewed_by_id'] = $row['reviewed_by_id'] ? (int)$row['reviewed_by_id'] : null;
                $row['book_price'] = (float)($row['book_price'] ?? 0.00);
                $row['book_allow_download'] = (int)($row['book_allow_download'] ?? 1);
                $row['student_image'] = format_image_url($row['student_image']);
                $row['book_cover_image'] = format_image_url($row['book_cover_image']);
                $row['book_file_path'] = format_image_url($row['book_file_path']);
                $items[] = $row;
            }
        }

        return build_admin_paginated_response($items, $page, $limit, $totalRecords, ['total_count' => $totalRecords]);
    }
}

if (!function_exists('teacherDeleteBookPurchaseRequest')) {
    /**
     * Clears a purchase request off this teacher's list once it has been decided.
     *
     * Same rule as the admin's: the list is a QUEUE, not a ledger, so removing a decided row is
     * tidying rather than undoing - approving a request grants the product through
     * `student_book_subscriptions`, a separate row this does not touch.
     *
     * A PENDING request is refused, because deleting one drops a student's request with no answer
     * and they never learn it was seen. And a teacher may only clear requests for their OWN
     * products, which is the same ownership check the review path makes.
     */
    function teacherDeleteBookPurchaseRequest($con, $teacherData = null) {
        $teacherId = 0;
        if (is_array($teacherData)) {
            $teacherId = (int)($teacherData['id'] ?? $teacherData['teacher_id'] ?? 0);
        } elseif (is_object($teacherData)) {
            $teacherId = (int)($teacherData->id ?? $teacherData->teacher_id ?? 0);
        }
        if ($teacherId <= 0) {
            return ['status' => 'error', 'message' => 'Teacher authentication is required'];
        }

        $body = read_json_body();
        // `id` is what the dashboard sends on a DELETE; `request_id` is what the review endpoint
        // takes. Both are accepted so the two do not disagree about what to call the same number.
        $requestId = (int)($body['id'] ?? $body['request_id'] ?? $_GET['id'] ?? $_GET['request_id'] ?? 0);
        if ($requestId <= 0) {
            return [
                'status' => 'error',
                'message' => app_text($con, 'رقم الطلب مطلوب.', 'The request id is required.'),
            ];
        }

        $stmt = mysqli_prepare($con, "SELECT id, book_id, status FROM student_book_purchase_requests WHERE id = ? LIMIT 1");
        if (!$stmt) {
            return ['status' => 'error', 'message' => 'Database error: ' . mysqli_error($con)];
        }
        mysqli_stmt_bind_param($stmt, "i", $requestId);
        mysqli_stmt_execute($stmt);
        $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));

        if (!$row) {
            return [
                'status' => 'error',
                'message' => app_text($con, 'الطلب غير موجود.', 'That request does not exist.'),
            ];
        }

        $bookId = (int)$row['book_id'];
        $ownerCheck = mysqli_query($con, "
            SELECT cb.id FROM course_books cb
            WHERE cb.id = {$bookId} AND " . teacher_book_ownership_clause($teacherId) . "
            LIMIT 1
        ");
        if (!$ownerCheck || mysqli_num_rows($ownerCheck) === 0) {
            return [
                'status' => 'error',
                'message' => app_text($con, 'الطلب ده مش على منتج من منتجاتك.', 'That request is not for one of your products.'),
            ];
        }

        if (($row['status'] ?? '') === 'pending') {
            return [
                'status' => 'error',
                'message' => app_text(
                    $con,
                    'الطلب ده لسه مستني رد. اقبله أو ارفضه الأول، وبعدين امسحه — عشان الطالب يعرف نتيجته.',
                    'This request is still awaiting an answer. Approve or reject it first, then remove it, so the student is told the outcome.'
                ),
            ];
        }

        $del = mysqli_prepare($con, "DELETE FROM student_book_purchase_requests WHERE id = ?");
        if (!$del) {
            return ['status' => 'error', 'message' => 'Database error: ' . mysqli_error($con)];
        }
        mysqli_stmt_bind_param($del, "i", $requestId);
        if (!mysqli_stmt_execute($del)) {
            return ['status' => 'error', 'message' => 'Failed to delete the request: ' . mysqli_error($con)];
        }

        return [
            'status' => 'success',
            'message' => app_text($con, 'تم حذف الطلب.', 'The request was deleted.'),
            'data' => ['id' => $requestId],
        ];
    }
}

if (!function_exists('teacherReviewBookRequest')) {
    function teacherReviewBookRequest($con, $teacherData = null) {
        $teacherId = 0;
        if (is_array($teacherData)) {
            $teacherId = (int)($teacherData['id'] ?? $teacherData['teacher_id'] ?? 0);
        } elseif (is_object($teacherData)) {
            $teacherId = (int)($teacherData->id ?? $teacherData->teacher_id ?? 0);
        }
        if ($teacherId <= 0) {
            return ['status' => 'error', 'message' => 'Teacher authentication is required'];
        }

        $body = read_json_body();
        $requestId = (int)($body['request_id'] ?? $_GET['request_id'] ?? 0);
        $newStatus = trim($body['status'] ?? '');
        $notes = trim($body['notes'] ?? '');

        if ($requestId <= 0) {
            return ['status' => 'error', 'message' => 'request_id is required'];
        }
        if (!in_array($newStatus, ['approved', 'rejected'])) {
            return ['status' => 'error', 'message' => 'status must be approved or rejected'];
        }

        $rRes = mysqli_query($con, "SELECT id, student_id, book_id, status FROM student_book_purchase_requests WHERE id = {$requestId} LIMIT 1");
        $rRow = $rRes ? mysqli_fetch_assoc($rRes) : null;
        if (!$rRow) {
            return ['status' => 'error', 'message' => 'Purchase request not found'];
        }
        if ($rRow['status'] !== 'pending') {
            return ['status' => 'error', 'message' => 'This request has already been reviewed'];
        }

        $bookId = (int)$rRow['book_id'];
        $ownerCheck = mysqli_query($con, "
            SELECT cb.id FROM course_books cb
            WHERE cb.id = {$bookId} AND " . teacher_book_ownership_clause($teacherId) . "
            LIMIT 1
        ");
        if (!$ownerCheck || mysqli_num_rows($ownerCheck) === 0) {
            return ['status' => 'error', 'message' => 'You are not authorized to review this book request'];
        }

        $stId = (int)$rRow['student_id'];
        $notesEsc = mysqli_real_escape_string($con, $notes);

        // review_notes, not notes: `notes` holds what the STUDENT wrote when filing the request.
        // Writing the reviewer's note over it destroyed the student's own words on every review.
        mysqli_query($con, "UPDATE student_book_purchase_requests SET status = '{$newStatus}', reviewed_by_type = 'teacher', reviewed_by_id = {$teacherId}, review_notes = '{$notesEsc}' WHERE id = {$requestId}");

        if ($newStatus === 'approved') {
            $bRes = mysqli_query($con, "SELECT price FROM course_books WHERE id = {$bookId} LIMIT 1");
            $bRow = $bRes ? mysqli_fetch_assoc($bRes) : null;
            $price = $bRow ? (float)$bRow['price'] : 0.00;

            $chk = mysqli_query($con, "SELECT id FROM student_book_subscriptions WHERE student_id = {$stId} AND book_id = {$bookId} LIMIT 1");
            if ($chk && mysqli_num_rows($chk) > 0) {
                mysqli_query($con, "UPDATE student_book_subscriptions SET is_active = 1, granted_by_type = 'teacher', granted_by_id = {$teacherId} WHERE student_id = {$stId} AND book_id = {$bookId}");
            } else {
                mysqli_query($con, "INSERT INTO student_book_subscriptions (student_id, book_id, granted_by_type, granted_by_id, price, is_active) VALUES ({$stId}, {$bookId}, 'teacher', {$teacherId}, {$price}, 1)");
            }
        }

        return [
            'status' => 'success',
            'message' => $newStatus === 'approved' ? 'Request approved and book access granted' : 'Request rejected',
            'data' => ['request_id' => $requestId, 'status' => $newStatus]
        ];
    }
}
