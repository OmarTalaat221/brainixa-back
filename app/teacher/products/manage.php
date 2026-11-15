<?php
/**
 * The teacher's store: the same products API the admin has, through a teacher creator context.
 *
 * Nothing is copied from app/admin/products/manage.php - every handler here calls the shared
 * product_* function with the teacher as the actor, so a rule about prices, files or stock is
 * written once. What differs is who may do what:
 *   - a product the teacher creates is `created_by_type = 'teacher'` and theirs;
 *   - they may edit, delete or hide only a product they own (R7: creator or assigned in
 *     `book_teachers`);
 *   - their list shows their own products plus the admin's unassigned ones, read-only, each row
 *     flagged `is_owned` / `can_edit` (the discount picker keeps `is_owned !== false`).
 */

require_once __DIR__ . '/../../admin/products/manage.php';

if (!function_exists('teacher_products_teacher_id')) {
    function teacher_products_teacher_id($teacherData): int {
        return (int)product_actor($teacherData, 'teacher')['id'];
    }
}

if (!function_exists('teacher_products_auth_error')) {
    function teacher_products_auth_error(): array {
        return ['status' => 'error', 'message' => 'Teacher authentication is required'];
    }
}

if (!function_exists('teacherListProducts')) {
    function teacherListProducts($con, $teacherData = null) {
        $teacherId = teacher_products_teacher_id($teacherData);
        if ($teacherId <= 0) return teacher_products_auth_error();

        return product_list_response($con, [product_teacher_visibility_clause($teacherId, 'p')], $teacherId);
    }
}

if (!function_exists('teacherGetProduct')) {
    function teacherGetProduct($con, $teacherData = null) {
        $teacherId = teacher_products_teacher_id($teacherData);
        if ($teacherId <= 0) return teacher_products_auth_error();
        if (!products_tables_ready($con)) return products_not_ready();

        $id = (int)($_GET['id'] ?? read_json_body()['id'] ?? 0);
        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'id is required'];
        }

        // Only what the teacher's list would show: anything else reads as absent, not forbidden.
        $res = @mysqli_query($con, "SELECT p.* FROM products p WHERE p.id = {$id} AND " . product_teacher_visibility_clause($teacherId, 'p') . " LIMIT 1");
        $row = $res ? mysqli_fetch_assoc($res) : null;
        if (!$row) {
            return ['status' => 'error', 'message' => 'المنتج غير موجود'];
        }

        $item = product_row($con, $row);
        $item['is_owned'] = teacher_owns_store_item($con, $teacherId, $id);
        $item['can_edit'] = $item['is_owned'];

        return ['status' => 'success', 'data' => $item];
    }
}

if (!function_exists('teacherCreateProduct')) {
    function teacherCreateProduct($con, $teacherData = null) {
        $actor = product_actor($teacherData, 'teacher');
        if ($actor['id'] <= 0) return teacher_products_auth_error();
        return product_create($con, $actor);
    }
}

if (!function_exists('teacherUpdateProduct')) {
    function teacherUpdateProduct($con, $teacherData = null) {
        $actor = product_actor($teacherData, 'teacher');
        if ($actor['id'] <= 0) return teacher_products_auth_error();
        return product_update($con, $actor);
    }
}

if (!function_exists('teacherDeleteProduct')) {
    function teacherDeleteProduct($con, $teacherData = null) {
        $actor = product_actor($teacherData, 'teacher');
        if ($actor['id'] <= 0) return teacher_products_auth_error();
        return product_delete($con, $actor);
    }
}

if (!function_exists('teacherToggleProductWebsiteVisibility')) {
    function teacherToggleProductWebsiteVisibility($con, $teacherData = null) {
        $actor = product_actor($teacherData, 'teacher');
        if ($actor['id'] <= 0) return teacher_products_auth_error();
        return product_toggle_website_visibility($con, $actor);
    }
}

if (!function_exists('teacherListProductCategories')) {
    /** Read-only, active categories only: a teacher files products under them, never edits them. */
    function teacherListProductCategories($con, $teacherData = null) {
        $_GET['is_active'] = 1;
        return adminListProductCategories($con);
    }
}
