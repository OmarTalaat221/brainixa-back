<?php
/**
 * An older copy of the teacher's purchase-request handlers. No route loads this file; the live
 * ones are in manage.php, which is required first so that, should anything load this file, the
 * live teacherReviewBookRequest() (R7 ownership, stock, review_notes) wins the function_exists race.
 */
require_once __DIR__ . '/../../../helpers/functions.php';
require_once __DIR__ . '/../../../helpers/language.php';
require_once __DIR__ . '/manage.php';

if (!function_exists('teacherGetBookPurchaseRequests')) {
    /** The old response shape (book_title, book_cover, book_price), read from products since migration 131. */
    function teacherGetBookPurchaseRequests($con, $teacherData = null) {
        $teacherId = teacher_books_teacher_id($teacherData);
        if ($teacherId <= 0) {
            return ['status' => 'error', 'message' => 'Teacher authentication is required'];
        }

        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 10)));
        $offset = ($page - 1) * $limit;

        $statusFilter = trim($_GET['status'] ?? '');
        $whereExtra = '';
        if (in_array($statusFilter, ['pending', 'approved', 'rejected'], true)) {
            $whereExtra = " AND r.status = '{$statusFilter}'";
        }

        $langInfo = get_language_info($con);
        $langId = (int)($langInfo['id'] ?? 1);

        $owned = "r.book_id IN (SELECT p2.id FROM products p2 WHERE " . teacher_store_item_ownership_clause($teacherId, 'p2') . ")";

        $countRes = mysqli_query($con, "SELECT COUNT(*) AS total FROM student_book_purchase_requests r WHERE {$owned}{$whereExtra}");
        $total = $countRes ? (int)(mysqli_fetch_assoc($countRes)['total'] ?? 0) : 0;

        $res = mysqli_query($con, "
            SELECT r.id, r.student_id, r.book_id, r.status, r.notes, r.reviewed_by_type, r.reviewed_by_id, r.created_at, r.updated_at,
                   st.name AS student_name, st.phone AS student_phone,
                   " . store_name_sql($langId, 'p') . " AS book_title,
                   p.image AS book_cover, p.price AS book_price
            FROM student_book_purchase_requests r
            LEFT JOIN students st ON r.student_id = st.id
            LEFT JOIN products p ON r.book_id = p.id
            WHERE {$owned}{$whereExtra}
            ORDER BY r.id DESC
            LIMIT {$limit} OFFSET {$offset}
        ");

        $items = [];
        while ($res && ($row = mysqli_fetch_assoc($res))) {
            $row['id'] = (int)$row['id'];
            $row['student_id'] = (int)$row['student_id'];
            $row['book_id'] = (int)$row['book_id'];
            $row['reviewed_by_id'] = $row['reviewed_by_id'] ? (int)$row['reviewed_by_id'] : null;
            $row['book_price'] = $row['book_price'] !== null ? (float)$row['book_price'] : null;
            $row['book_cover'] = format_image_url($row['book_cover']);
            $items[] = $row;
        }

        return build_admin_paginated_response($items, $page, $limit, $total, ['total_count' => $total]);
    }
}
