<?php
require_once __DIR__ . '/../../../helpers/functions.php';
require_once __DIR__ . '/../../../helpers/language.php';
require_once __DIR__ . '/../../../helpers/upload.php';
require_once __DIR__ . '/../../../helpers/entities.php';
require_once __DIR__ . '/../../../helpers/app_settings.php';
require_once __DIR__ . '/../../../helpers/teacher_ownership.php';
require_once __DIR__ . '/../../../helpers/store_items.php';
// The grant, the review and the purchase-request row are shared with the admin's, so the two
// cannot drift (they did once: the teacher's review overwrote the student's note).
require_once __DIR__ . '/../../admin/books/manage.php';

/*
 * The teacher's purchase requests and grant-access. Both were always about STORE items, and a
 * store item is a product since migration 131 - so ownership here is R7 (the product's creator or
 * a teacher assigned in book_teachers), via teacher_store_item_ownership_clause() /
 * teacher_owns_store_item(), and no longer the course/unit routes that apply to lesson files.
 */

if (!function_exists('teacher_books_teacher_id')) {
    function teacher_books_teacher_id($teacherData): int {
        if (is_array($teacherData)) {
            return (int)($teacherData['id'] ?? $teacherData['teacher_id'] ?? 0);
        }
        if (is_object($teacherData)) {
            return (int)($teacherData->id ?? $teacherData->teacher_id ?? 0);
        }
        return 0;
    }
}

if (!function_exists('teacherGrantBookAccessToStudent')) {
    function teacherGrantBookAccessToStudent($con, $teacherData = null) {
        $teacherId = teacher_books_teacher_id($teacherData);
        if ($teacherId <= 0) {
            return ['status' => 'error', 'message' => 'Teacher authentication is required'];
        }
        return store_item_grant_access($con, 'teacher', $teacherId, $teacherId);
    }
}

if (!function_exists('teacherListBookPurchaseRequests')) {
    function teacherListBookPurchaseRequests($con, $teacherData = null) {
        $teacherId = teacher_books_teacher_id($teacherData);
        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 20)));
        $offset = ($page - 1) * $limit;

        $studentId = (int)($_GET['student_id'] ?? 0);
        $bookId = (int)($_GET['book_id'] ?? 0);
        $status = trim($_GET['status'] ?? '');
        $search = trim($_GET['search'] ?? $_GET['q'] ?? '');

        $langInfo = get_language_info($con);
        $langId = (int)($langInfo['id'] ?? 1);

        // Only requests for this teacher's own products - exactly the set the review and delete
        // below accept, so a row on screen is a row that can be acted on.
        $whereClause = "WHERE p.id IS NOT NULL AND " . teacher_store_item_ownership_clause($teacherId, 'p');

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
            $whereClause .= book_request_search_sql($con, $search, false);
        }

        $from = book_request_from_sql($langId);

        $countRes = mysqli_query($con, "SELECT COUNT(DISTINCT sbpr.id) AS total {$from} {$whereClause}");
        $totalRecords = $countRes ? (int)(mysqli_fetch_assoc($countRes)['total'] ?? 0) : 0;

        $res = mysqli_query($con, "
            SELECT " . book_request_select_sql($langId) . "
            {$from}
            {$whereClause}
            ORDER BY sbpr.id DESC
            LIMIT {$limit} OFFSET {$offset}
        ");

        $items = [];
        while ($res && ($row = mysqli_fetch_assoc($res))) {
            $items[] = book_request_format_row($row);
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
        $teacherId = teacher_books_teacher_id($teacherData);
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

        if (!teacher_owns_store_item($con, $teacherId, (int)$row['book_id'])) {
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
        $teacherId = teacher_books_teacher_id($teacherData);
        if ($teacherId <= 0) {
            return ['status' => 'error', 'message' => 'Teacher authentication is required'];
        }
        return book_request_review($con, 'teacher', $teacherId, $teacherId);
    }
}
