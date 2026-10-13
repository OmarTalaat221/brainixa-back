<?php
require_once __DIR__ . '/../../../helpers/language.php';
// app_text() for the bilingual refusal when a category is still in use.
require_once __DIR__ . '/../../../helpers/app_settings.php';


if (!function_exists('course_category_make_code')) {
    /**
     * A code for a category whose creator did not type one.
     *
     * `course_categories.code` is NOT NULL and UNIQUE, so "optional" cannot mean "empty" - it has
     * to mean "we work one out". Derived from the name where that gives something usable: an
     * English name slugs cleanly, an Arabic one does not survive a slug at all, so that falls
     * back to a short readable stamp instead of an empty string.
     */
    function course_category_make_code($con, string $nameEn, string $nameAr): string {
        $base = strtolower(trim($nameEn !== '' ? $nameEn : $nameAr));
        $base = preg_replace('/[^a-z0-9]+/', '-', $base);
        $base = trim((string)$base, '-');

        if ($base === '' || strlen($base) < 2) {
            $base = 'category';
        }
        $base = substr($base, 0, 60);

        // UNIQUE means a clash is a refusal, not a warning - so walk until the name is free.
        $candidate = $base;
        for ($i = 2; $i < 200; $i++) {
            $stmt = mysqli_prepare($con, "SELECT id FROM course_categories WHERE code = ? LIMIT 1");
            mysqli_stmt_bind_param($stmt, "s", $candidate);
            mysqli_stmt_execute($stmt);
            if (!mysqli_fetch_assoc(mysqli_stmt_get_result($stmt))) {
                return $candidate;
            }
            $candidate = $base . '-' . $i;
        }

        return $base . '-' . bin2hex(random_bytes(3));
    }
}

if (!function_exists('adminListCourseCategories')) {
    function adminListCourseCategories($con) {
        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 10)));
        $offset = ($page - 1) * $limit;
        $search = trim($_GET['search'] ?? $_GET['q'] ?? $_GET['query'] ?? '');

        $whereClause = "";
        $params = [];
        $types = "";

        if (!empty($search)) {
            $searchPattern = '%' . $search . '%';
            $whereClause = "WHERE (cc.code LIKE ? OR cct.name LIKE ?)";
            $params = [$searchPattern, $searchPattern];
            $types = "ss";
        }

        $statRes = mysqli_query($con, "SELECT COUNT(*) AS total, SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) AS active_count, SUM(CASE WHEN is_active = 0 THEN 1 ELSE 0 END) AS inactive_count FROM course_categories");
        $statRow = mysqli_fetch_assoc($statRes);
        $totalRecords = (int)($statRow['total'] ?? 0);
        $statistics = [
            'total_count' => $totalRecords,
            'active_count' => (int)($statRow['active_count'] ?? 0),
            'inactive_count' => (int)($statRow['inactive_count'] ?? 0)
        ];

        if (!empty($whereClause)) {
            $countSql = "SELECT COUNT(DISTINCT cc.id) AS total FROM course_categories cc LEFT JOIN course_categories_translations cct ON cc.id = cct.course_category_id {$whereClause}";
            $countStmt = mysqli_prepare($con, $countSql);
            mysqli_stmt_bind_param($countStmt, $types, ...$params);
            mysqli_stmt_execute($countStmt);
            $countRes = mysqli_stmt_get_result($countStmt);
            $totalRecords = (int)(mysqli_fetch_assoc($countRes)['total'] ?? 0);
        }

        $sql = "SELECT DISTINCT cc.id, cc.code, cc.image, cc.is_active, cc.created_at FROM course_categories cc LEFT JOIN course_categories_translations cct ON cc.id = cct.course_category_id {$whereClause} ORDER BY cc.id DESC LIMIT ? OFFSET ?";
        
        $params[] = $limit;
        $params[] = $offset;
        $types .= "ii";

        $stmt = mysqli_prepare($con, $sql);
        mysqli_stmt_bind_param($stmt, $types, ...$params);
        mysqli_stmt_execute($stmt);
        $res = mysqli_stmt_get_result($stmt);

        $categories = [];
        while ($row = mysqli_fetch_assoc($res)) {
            $catId = (int)$row['id'];
            $row['id'] = $catId;
            $row['is_active'] = (int)$row['is_active'];

            $transStmt = mysqli_prepare($con, "SELECT cct.language_id, l.code AS language_code, cct.name FROM course_categories_translations cct JOIN languages l ON cct.language_id = l.id WHERE cct.course_category_id = ?");
            mysqli_stmt_bind_param($transStmt, "i", $catId);
            mysqli_stmt_execute($transStmt);
            $transRes = mysqli_stmt_get_result($transStmt);

            $translations = [];
            while ($t = mysqli_fetch_assoc($transRes)) {
                $t['language_id'] = (int)$t['language_id'];
                if ($t['language_code'] === 'ar') $row['name_ar'] = $t['name'];
                if ($t['language_code'] === 'en') $row['name_en'] = $t['name'];
                $translations[] = $t;
            }
            $row['translations'] = $translations;

            $categories[] = $row;
        }

        return build_admin_paginated_response($categories, $page, $limit, $totalRecords, $statistics);
    }
}

if (!function_exists('adminGetCourseCategory')) {
    function adminGetCourseCategory($con) {
        $id = (int)($_GET['id'] ?? read_json_body()['id'] ?? 0);
        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'Course category ID is required'];
        }

        $stmt = mysqli_prepare($con, "SELECT id, code, image, is_active, created_at FROM course_categories WHERE id = ? LIMIT 1");
        mysqli_stmt_bind_param($stmt, "i", $id);
        mysqli_stmt_execute($stmt);
        $res = mysqli_stmt_get_result($stmt);
        $row = mysqli_fetch_assoc($res);

        if (!$row) {
            return ['status' => 'error', 'message' => 'Course category not found'];
        }

        $catId = (int)$row['id'];
        $row['id'] = $catId;
        $row['is_active'] = (int)$row['is_active'];

        $transStmt = mysqli_prepare($con, "SELECT cct.language_id, l.code AS language_code, cct.name FROM course_categories_translations cct JOIN languages l ON cct.language_id = l.id WHERE cct.course_category_id = ?");
        mysqli_stmt_bind_param($transStmt, "i", $catId);
        mysqli_stmt_execute($transStmt);
        $transRes = mysqli_stmt_get_result($transStmt);

        $translations = [];
        while ($t = mysqli_fetch_assoc($transRes)) {
            $t['language_id'] = (int)$t['language_id'];
            if ($t['language_code'] === 'ar') $row['name_ar'] = $t['name'];
            if ($t['language_code'] === 'en') $row['name_en'] = $t['name'];
            $translations[] = $t;
        }
        $row['translations'] = $translations;

        return ['status' => 'success', 'data' => $row];
    }
}

if (!function_exists('adminCreateCourseCategory')) {
    function adminCreateCourseCategory($con) {
        $body = read_json_body();
        $code = strtolower(trim($body['code'] ?? ''));
        $nameAr = trim($body['name_ar'] ?? '');
        $nameEn = trim($body['name_en'] ?? $nameAr);
        $image = trim($body['image'] ?? '');
        $isActive = isset($body['is_active']) ? (int)$body['is_active'] : 1;

        // Only the Arabic name is actually required. The code is worked out when left blank, and
        // the English name falls back to the Arabic one - it always did, the form just insisted
        // on it anyway.
        if (empty($nameAr)) {
            return ['status' => 'error', 'message' => app_text(
                $con,
                'اسم التصنيف بالعربي مطلوب.',
                'The Arabic category name is required.'
            )];
        }

        if ($code === '') {
            $code = course_category_make_code($con, $nameEn, $nameAr);
        }

        $stmt = mysqli_prepare($con, "INSERT INTO course_categories (code, image, is_active) VALUES (?, ?, ?)");
        mysqli_stmt_bind_param($stmt, "ssi", $code, $image, $isActive);

        if (!mysqli_stmt_execute($stmt)) {
            return ['status' => 'error', 'message' => 'Failed to create course category: ' . mysqli_error($con)];
        }

        $catId = mysqli_insert_id($con);

        $transStmt = mysqli_prepare($con, "INSERT INTO course_categories_translations (course_category_id, language_id, name) VALUES (?, 1, ?), (?, 2, ?)");
        mysqli_stmt_bind_param($transStmt, "isis", $catId, $nameAr, $catId, $nameEn);
        mysqli_stmt_execute($transStmt);

        return [
            'status' => 'success',
            'message' => 'Course category created successfully',
            'data' => adminGetCourseCategory($con)['data'] ?? null
        ];
    }
}

if (!function_exists('adminUpdateCourseCategory')) {
    function adminUpdateCourseCategory($con) {
        $body = read_json_body();
        $id = (int)($body['id'] ?? 0);
        $code = strtolower(trim($body['code'] ?? ''));
        $nameAr = trim($body['name_ar'] ?? '');
        $nameEn = trim($body['name_en'] ?? '');
        $image = trim($body['image'] ?? '');
        $isActive = isset($body['is_active']) ? (int)$body['is_active'] : null;

        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'Course category ID is required'];
        }

        if (!empty($code)) {
            $stmt = mysqli_prepare($con, "UPDATE course_categories SET code = ? WHERE id = ?");
            mysqli_stmt_bind_param($stmt, "si", $code, $id);
            mysqli_stmt_execute($stmt);
        }

        if (!empty($image)) {
            $stmt = mysqli_prepare($con, "UPDATE course_categories SET image = ? WHERE id = ?");
            mysqli_stmt_bind_param($stmt, "si", $image, $id);
            mysqli_stmt_execute($stmt);
        }

        if ($isActive !== null) {
            $stmt = mysqli_prepare($con, "UPDATE course_categories SET is_active = ? WHERE id = ?");
            mysqli_stmt_bind_param($stmt, "ii", $isActive, $id);
            mysqli_stmt_execute($stmt);
        }

        if (!empty($nameAr)) {
            $transStmt = mysqli_prepare($con, "INSERT INTO course_categories_translations (course_category_id, language_id, name) VALUES (?, 1, ?) ON DUPLICATE KEY UPDATE name = VALUES(name)");
            mysqli_stmt_bind_param($transStmt, "is", $id, $nameAr);
            mysqli_stmt_execute($transStmt);
        }

        if (!empty($nameEn)) {
            $transStmt = mysqli_prepare($con, "INSERT INTO course_categories_translations (course_category_id, language_id, name) VALUES (?, 2, ?) ON DUPLICATE KEY UPDATE name = VALUES(name)");
            mysqli_stmt_bind_param($transStmt, "is", $id, $nameEn);
            mysqli_stmt_execute($transStmt);
        }

        return [
            'status' => 'success',
            'message' => 'Course category updated successfully',
            'data' => adminGetCourseCategory($con)['data'] ?? null
        ];
    }
}

if (!function_exists('adminDeleteCourseCategory')) {
    function adminDeleteCourseCategory($con) {
        $body = read_json_body();
        $id = (int)($_GET['id'] ?? $body['id'] ?? 0);

        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'Course category ID is required'];
        }

        // Courses point at this category with a foreign key that has no ON DELETE action, so the
        // database refuses the delete. That refusal used to be handed to the admin verbatim -
        // "Cannot delete or update a parent row: a foreign key constraint fails ..." - which says
        // nothing about what to do. Ask first, and answer in terms of the thing they can act on.
        $useStmt = mysqli_prepare($con, "SELECT COUNT(*) AS total FROM courses WHERE category_id = ?");
        mysqli_stmt_bind_param($useStmt, "i", $id);
        mysqli_stmt_execute($useStmt);
        $inUse = (int)(mysqli_fetch_assoc(mysqli_stmt_get_result($useStmt))['total'] ?? 0);

        // `with_courses` is the deliberate second choice: delete the category AND the courses
        // filed under it. Opt-in only, because it is not a tidy-up - deleting a course cascades
        // to its units, questions and resources, and none of that comes back.
        $withCourses = !empty($body['with_courses']) || ($_GET['with_courses'] ?? '') === '1';

        if ($inUse > 0 && !$withCourses) {
            return [
                'status' => 'error',
                'error_code' => 'category_in_use',
                'courses_count' => $inUse,
                'message' => app_text(
                    $con,
                    'مينفعش تمسح التصنيف ده لأن فيه ' . $inUse . ' كورس مرتبط بيه. غيّر تصنيف الكورسات دي الأول، أو اعمله غير نشط عشان يختفي من القوائم.',
                    'This category cannot be deleted because ' . $inUse . ' course(s) still use it. Move those courses to another category first, or set it inactive to hide it from the lists.'
                ),
            ];
        }

        if ($inUse > 0 && $withCourses) {
            // One line nobody may cross: a course somebody paid for. Deleting it strips access
            // the student bought and leaves their subscription and payment rows pointing at a
            // course that no longer exists - student_subscription_courses has no foreign key to
            // catch it. There is no undo and no refund path, so this is refused outright rather
            // than confirmed away.
            $soldStmt = mysqli_prepare($con, "SELECT COUNT(DISTINCT ss.student_id) AS students
                FROM student_subscription_courses ssc
                JOIN student_subscriptions ss ON ss.id = ssc.student_subscription_id
                JOIN courses c ON c.id = ssc.course_id
                WHERE c.category_id = ? AND ss.is_active = 1");
            mysqli_stmt_bind_param($soldStmt, "i", $id);
            mysqli_stmt_execute($soldStmt);
            $subscribed = (int)(mysqli_fetch_assoc(mysqli_stmt_get_result($soldStmt))['students'] ?? 0);

            if ($subscribed > 0) {
                return [
                    'status' => 'error',
                    'error_code' => 'courses_have_students',
                    'students_count' => $subscribed,
                    'courses_count' => $inUse,
                    'message' => app_text(
                        $con,
                        'مينفعش يتحذف: فيه ' . $subscribed . ' طالب مشترك في كورسات التصنيف ده. امسح أو انقل الكورسات دي بنفسك الأول.',
                        'Cannot delete: ' . $subscribed . ' student(s) are subscribed to courses in this category. Remove or move those courses yourself first.'
                    ),
                ];
            }

            // Cascades take the units, questions, resources, translations and teacher links.
            $delCourses = mysqli_prepare($con, "DELETE FROM courses WHERE category_id = ?");
            mysqli_stmt_bind_param($delCourses, "i", $id);
            if (!mysqli_stmt_execute($delCourses)) {
                return ['status' => 'error', 'message' => 'Failed to delete the category courses: ' . mysqli_error($con)];
            }
            $deletedCourses = mysqli_stmt_affected_rows($delCourses);
        }

        $stmt = mysqli_prepare($con, "DELETE FROM course_categories WHERE id = ?");
        mysqli_stmt_bind_param($stmt, "i", $id);

        if (!mysqli_stmt_execute($stmt)) {
            return ['status' => 'error', 'message' => 'Failed to delete course category: ' . mysqli_error($con)];
        }

        // Translations are the category's own rows, not another feature's data.
        $trStmt = mysqli_prepare($con, "DELETE FROM course_categories_translations WHERE course_category_id = ?");
        mysqli_stmt_bind_param($trStmt, "i", $id);
        mysqli_stmt_execute($trStmt);

        $deletedCourses = $deletedCourses ?? 0;

        return [
            'status' => 'success',
            'deleted_courses' => $deletedCourses,
            'message' => $deletedCourses > 0
                ? app_text(
                    $con,
                    'تم حذف التصنيف و' . $deletedCourses . ' كورس كانوا تحته.',
                    'The category and ' . $deletedCourses . ' course(s) under it were deleted.'
                )
                : app_text($con, 'تم حذف التصنيف.', 'Course category deleted successfully'),
        ];
    }
}
