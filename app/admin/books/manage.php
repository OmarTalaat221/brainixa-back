<?php
require_once __DIR__ . '/../../../helpers/unpriced.php';
require_once __DIR__ . '/../../../helpers/teacher_ownership.php';
require_once __DIR__ . '/../../../helpers/functions.php';
require_once __DIR__ . '/../../../helpers/language.php';
require_once __DIR__ . '/../../../helpers/upload.php';
require_once __DIR__ . '/../../../helpers/entities.php';
// app_text() lives here. Reaching it through whatever else the chain happens to pull in is how
// session_ratings died with a PHP fatal that came back as HTML where the client expected JSON.
require_once __DIR__ . '/../../../helpers/app_settings.php';
require_once __DIR__ . '/../../../helpers/store_items.php';
require_once __DIR__ . '/../content/units.php';
require_once __DIR__ . '/../products/manage.php';

/*
 * Since migration 131 this file manages LESSON FILES only - `course_books` rows that belong to a
 * course or a unit. The store's books became `products` (same ids) and are managed through
 * /admin/products and /teacher/products. What still touches store items here:
 *   - the books list with `scope=general` (and with no scope) carries them as book-shaped rows,
 *     read-only, so an older dashboard build still sees its store tab;
 *   - show / stream fall back to the product for a store item's id;
 *   - purchase requests and grant-access, which were always about store items, read products.
 * A request that would create a book with no course and no unit, or turn a lesson file into one,
 * is refused rather than quietly creating a product.
 */

if (!function_exists('ensure_books_schema')) {
    function ensure_books_schema($con) {
    }
}

if (!function_exists('books_store_item_refusal')) {
    /** Why /books will not create, edit or remove a store item any more, and where to go instead. */
    function books_store_item_refusal($con): array {
        $where = is_teacher_request() ? '/teacher/products' : '/admin/products';
        return [
            'status' => 'error',
            'error_code' => 'store_item_is_product',
            'message' => app_text(
                $con,
                "عناصر المتجر أصبحت تُدار كمنتجات من شاشة المنتجات ({$where}). الكتب هنا هي ملفات الدروس فقط، ويجب أن ترتبط بكورس أو وحدة.",
                "Store items are managed as products now ({$where}). Books here are lesson files only and must belong to a course or a unit."
            ),
        ];
    }
}

if (!function_exists('books_is_lesson_file')) {
    function books_is_lesson_file($con, int $id): bool {
        if ($id <= 0) return false;
        $res = @mysqli_query($con, "SELECT id FROM course_books WHERE id = {$id} LIMIT 1");
        return $res && mysqli_num_rows($res) > 0;
    }
}

if (!function_exists('admin_store_item_book_row')) {
    /**
     * A store item (a product) in the exact shape adminGetBookDetails() gives a book, so the
     * books screens of an older dashboard keep rendering it. Read-only: `manage_via` says where
     * it is edited now.
     */
    function admin_store_item_book_row($con, array $p): array {
        $id = (int)$p['id'];
        $langInfo = get_language_info($con);

        $translations = [];
        $titleAr = $titleEn = $descAr = $descEn = null;
        $tRes = @mysqli_query($con, "SELECT t.language_id, l.code AS language_code, t.name AS title, t.description FROM products_translations t JOIN languages l ON t.language_id = l.id WHERE t.product_id = {$id}");
        while ($tRes && ($tRow = mysqli_fetch_assoc($tRes))) {
            $tRow['language_id'] = (int)$tRow['language_id'];
            $translations[] = $tRow;
            if ($tRow['language_code'] === 'ar') { $titleAr = $tRow['title']; $descAr = $tRow['description']; }
            if ($tRow['language_code'] === 'en') { $titleEn = $tRow['title']; $descEn = $tRow['description']; }
        }
        $transMap = array_column($translations, 'title', 'language_code');
        $descMap = array_column($translations, 'description', 'language_code');
        $title = $transMap[$langInfo['code']] ?? ($titleAr ?? $titleEn ?? ('Book #' . $id));
        $description = $descMap[$langInfo['code']] ?? ($descAr ?? $descEn ?? '');

        $row = store_item_as_book($con, $p, ['name' => $title, 'description' => $description]);

        // The admin's book shape: null is "no price", not 0.
        $row['is_priced'] = $p['price'] !== null;
        $row['price'] = price_out($p['price']);
        $row['updated_at'] = $p['updated_at'] ?? null;

        // The same file rule adminGetBookDetails() applies to a book.
        if ((int)$row['allow_download'] === 1) {
            $row['link'] = format_image_url($row['link']);
            $row['file_path'] = format_image_url($row['file_path'] ?: $row['link']);
            $row['view_url'] = $row['file_path'];
        } else {
            $row['link'] = null;
            $row['file_path'] = null;
            $streamBase = is_teacher_request() ? 'teacher' : 'admin';
            $row['view_url'] = 'https://camp-coding.online/brain-ixa/' . $streamBase . '/books/stream?book_id=' . $id;
        }

        $row['translations'] = $translations;
        $row['title_ar'] = $titleAr;
        $row['title_en'] = $titleEn;
        $row['description_ar'] = $descAr;
        $row['description_en'] = $descEn;
        $row['unit'] = null;
        $row['course'] = null;
        $row['subject'] = $row['subject_id'] ? get_subject_details($con, $row['subject_id']) : null;
        $row['teachers'] = product_teachers($con, $p);
        $row['is_store_item'] = true;
        $row['read_only'] = true;
        $row['manage_via'] = 'products';

        return format_response_images($row);
    }
}

if (!function_exists('adminGetBookDetails')) {
    function adminGetBookDetails($con, $bookId) {
        if (!$bookId) return null;
        $bookId = (int)$bookId;
        $langInfo = get_language_info($con);

        $res = mysqli_query($con, "SELECT id, subject_id, course_id, unit_id, file_type, category, extension, link, file_path, cover_image, price, allow_download, order_num, is_active, created_by_type, created_by_id, created_at, updated_at FROM course_books WHERE id = {$bookId} LIMIT 1");
        if (!$res || !($row = mysqli_fetch_assoc($res))) {
            // Not a lesson file: a store item asked for by the id it had as a book.
            $product = store_item_find($con, $bookId);
            return $product ? admin_store_item_book_row($con, $product) : null;
        }

        $row['id'] = (int)$row['id'];
        $row['unit_id'] = !empty($row['unit_id']) ? (int)$row['unit_id'] : null;
        $row['subject_id'] = !empty($row['subject_id']) ? (int)$row['subject_id'] : null;
        $row['course_id'] = !empty($row['course_id']) ? (int)$row['course_id'] : null;
        $row['category'] = $row['category'] ?: 'summary';
        // null is "no price" and stays null for the dashboard; 0 is free.
        $row['is_priced'] = $row['price'] !== null;
        $row['price'] = price_out($row['price']);
        $row['allow_download'] = (int)($row['allow_download'] ?? 1);
        $row['is_active'] = (int)$row['is_active'];
        $rawLink = $row['link'];
        $row['cover_image'] = format_image_url(!empty($row['cover_image']) ? $row['cover_image'] : $rawLink);

        // Admin/teacher open this file the same way a student does: a direct link when it is
        // downloadable, or - when allow_download was turned off specifically to keep it from
        // being extracted and shared - only through the authenticated view-only stream, never a
        // bare public URL. The flag is for the audience it was set for, not just for students.
        if ($row['allow_download'] === 1) {
            $row['link'] = format_image_url($row['link']);
            $row['file_path'] = format_image_url($row['file_path'] ?: $rawLink);
            $row['view_url'] = $row['file_path'];
        } else {
            $row['link'] = null;
            $row['file_path'] = null;
            $streamBase = is_teacher_request() ? 'teacher' : 'admin';
            $row['view_url'] = 'https://camp-coding.online/brain-ixa/' . $streamBase . '/books/stream?book_id=' . $row['id'];
        }

        $translations = [];
        $titleAr = null;
        $titleEn = null;
        $descAr = null;
        $descEn = null;

        $tRes = mysqli_query($con, "SELECT cbt.language_id, l.code AS language_code, cbt.title, cbt.description FROM course_books_translations cbt JOIN languages l ON cbt.language_id = l.id WHERE cbt.book_id = {$bookId}");
        if ($tRes) {
            while ($tRow = mysqli_fetch_assoc($tRes)) {
                $tRow['language_id'] = (int)$tRow['language_id'];
                $translations[] = $tRow;
                if ($tRow['language_code'] === 'ar') {
                    $titleAr = $tRow['title'];
                    $descAr = $tRow['description'];
                }
                if ($tRow['language_code'] === 'en') {
                    $titleEn = $tRow['title'];
                    $descEn = $tRow['description'];
                }
            }
        }

        $transMap = array_column($translations, 'title', 'language_code');
        $descMap = array_column($translations, 'description', 'language_code');
        $row['title'] = $transMap[$langInfo['code']] ?? ($titleAr ?? $titleEn ?? ('Book #' . $row['id']));
        $row['description'] = $descMap[$langInfo['code']] ?? ($descAr ?? $descEn ?? '');

        $row['translations'] = $translations;
        $row['title_ar'] = $titleAr;
        $row['title_en'] = $titleEn;
        $row['description_ar'] = $descAr;
        $row['description_en'] = $descEn;

        $row['unit'] = $row['unit_id'] ? get_unit_details($con, $row['unit_id']) : null;
        $courseIdForLookup = $row['course_id'] ?: (int)($row['unit']['course_id'] ?? 0);
        $row['course'] = $courseIdForLookup ? get_course_details($con, $courseIdForLookup) : null;
        $row['subject'] = $row['subject_id'] ? get_subject_details($con, $row['subject_id']) : null;

        return format_response_images($row);
    }
}

if (!function_exists('adminListBooks')) {
    /**
     * Lesson files from `course_books`, and - where the old list showed store books - the store
     * items from `products` as book-shaped rows (read-only). The two are paged as ONE list: a
     * UNION ALL of (id, order_num, source) is ordered and cut in SQL, and the total is the sum of
     * both counts, so pagination stays right however the two are mixed.
     *
     *   scope=unit                lesson files only
     *   scope=general             store items only (the old store tab); with a course_id it is
     *                             that course's files not tied to a unit, which is what the
     *                             teacher dashboard's course-books page asks for
     *   no scope                  both
     *   course_id / unit_id       lesson files only (a store item belongs to neither)
     */
    function adminListBooks($con) {
        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 10)));
        $offset = ($page - 1) * $limit;

        $search = trim($_GET['search'] ?? $_GET['q'] ?? '');
        $unitId = isset($_GET['unit_id']) ? (int)$_GET['unit_id'] : 0;
        $courseId = isset($_GET['course_id']) ? (int)$_GET['course_id'] : 0;
        $subjectId = isset($_GET['subject_id']) ? (int)$_GET['subject_id'] : 0;
        $teacherId = isset($_GET['teacher_id']) ? (int)$_GET['teacher_id'] : 0;
        $category = in_array(trim($_GET['category'] ?? ''), ['summary', 'exam'], true) ? trim($_GET['category']) : '';
        $scope = in_array(trim($_GET['scope'] ?? ''), ['general', 'unit'], true) ? trim($_GET['scope']) : '';

        $langInfo = get_language_info($con);
        $langId = (int)($langInfo['id'] ?? 1);

        $linkedFilter = $courseId > 0 || $unitId > 0;
        $includeLessons = $scope !== 'general' || $linkedFilter;
        $includeStore = $scope !== 'unit' && !$linkedFilter && products_tables_ready($con);

        // ---- lesson files (course_books) ----
        // A store item is never read from course_books (R1): only rows tied to a course or unit.
        $cbWhere = ["(cb.course_id IS NOT NULL OR cb.unit_id IS NOT NULL)"];
        if ($unitId > 0) $cbWhere[] = "cb.unit_id = {$unitId}";
        if ($category !== '') $cbWhere[] = "cb.category = '{$category}'";
        if ($scope === 'general') $cbWhere[] = "cb.unit_id IS NULL";
        if ($courseId > 0) $cbWhere[] = "(cb.course_id = {$courseId} OR cb.unit_id IN (SELECT id FROM units WHERE course_id = {$courseId}))";
        if ($subjectId > 0) $cbWhere[] = "cb.subject_id = {$subjectId}";
        if ($teacherId > 0) {
            $cbWhere[] = "(
                (cb.created_by_type = 'teacher' AND cb.created_by_id = {$teacherId})
                OR (cb.created_by_id = {$teacherId})
                OR cb.id IN (SELECT book_id FROM book_teachers WHERE teacher_id = {$teacherId} AND is_active = 1)
                OR cb.course_id IN (SELECT id FROM courses WHERE teacher_id = {$teacherId} OR (created_by_type = 'teacher' AND created_by_id = {$teacherId}))
                OR cb.course_id IN (SELECT course_id FROM course_teachers WHERE teacher_id = {$teacherId} AND is_active = 1)
                OR cb.unit_id IN (SELECT id FROM units WHERE (created_by_type = 'teacher' AND created_by_id = {$teacherId}))
                OR cb.unit_id IN (SELECT unit_id FROM unit_teachers WHERE teacher_id = {$teacherId} AND is_active = 1)
                OR cb.subject_id IN (SELECT subject_id FROM teacher_subjects WHERE teacher_id = {$teacherId})
                OR (cb.created_by_type = 'admin' AND NOT EXISTS (SELECT 1 FROM book_teachers bt_chk WHERE bt_chk.book_id = cb.id AND bt_chk.is_active = 1))
            )";
        }
        if (!empty($search)) {
            $sp = '%' . mysqli_real_escape_string($con, $search) . '%';
            $cbWhere[] = "(cbt.title LIKE '{$sp}' OR cbt.description LIKE '{$sp}')";
        }
        $cbWhereSql = "WHERE " . implode(" AND ", $cbWhere);
        $cbFrom = "FROM course_books cb
            LEFT JOIN course_books_translations cbt ON cb.id = cbt.book_id AND cbt.language_id = {$langId}
            {$cbWhereSql}";

        // ---- store items (products) ----
        $pWhere = [];
        $storeReady = store_products_ready($con);
        if ($category !== '' && $storeReady) $pWhere[] = "p.book_category = '{$category}'";
        if ($subjectId > 0 && $storeReady) $pWhere[] = "p.subject_id = {$subjectId}";
        // The old store list for a teacher: their own items, the ones assigned to them, and the
        // admin's unassigned items (read-only).
        if ($teacherId > 0) $pWhere[] = product_teacher_visibility_clause($teacherId, 'p');
        if (!empty($search)) {
            $sp = '%' . mysqli_real_escape_string($con, $search) . '%';
            $pWhere[] = "EXISTS (SELECT 1 FROM products_translations pt_s WHERE pt_s.product_id = p.id AND (pt_s.name LIKE '{$sp}' OR pt_s.description LIKE '{$sp}'))";
        }
        $pWhereSql = $pWhere ? "WHERE " . implode(" AND ", $pWhere) : "";

        $totalRecords = 0;
        if ($includeLessons) {
            $countRes = mysqli_query($con, "SELECT COUNT(DISTINCT cb.id) AS total {$cbFrom}");
            $totalRecords += $countRes ? (int)(mysqli_fetch_assoc($countRes)['total'] ?? 0) : 0;
        }
        if ($includeStore) {
            $countRes = @mysqli_query($con, "SELECT COUNT(*) AS total FROM products p {$pWhereSql}");
            $totalRecords += $countRes ? (int)(mysqli_fetch_assoc($countRes)['total'] ?? 0) : 0;
        }

        $parts = [];
        if ($includeLessons) {
            $parts[] = "SELECT DISTINCT cb.id AS id, cb.order_num AS order_num, 0 AS src {$cbFrom}";
        }
        if ($includeStore) {
            $parts[] = "SELECT p.id AS id, p.order_num AS order_num, 1 AS src FROM products p {$pWhereSql}";
        }

        $books = [];
        if ($parts) {
            $res = @mysqli_query($con, "
                SELECT x.id, x.src FROM (" . implode(" UNION ALL ", $parts) . ") x
                ORDER BY x.order_num ASC, x.src ASC, x.id ASC
                LIMIT {$limit} OFFSET {$offset}
            ");

            // For a teacher: which of these rows are theirs. Lesson files by the course/unit
            // route, store items by R7. The list also carries the admin's unassigned products,
            // read-only, and a teacher can neither discount those nor act on their purchase
            // requests - the server refuses both by the same rule this reads.
            $ownedLessons = $teacherId > 0 && $includeLessons ? array_flip(teacher_owned_lesson_file_ids($con, $teacherId)) : [];
            $ownedStore = $teacherId > 0 && $includeStore ? array_flip(teacher_owned_store_item_ids($con, $teacherId)) : [];

            $storeIds = [];
            $order = [];
            while ($res && ($row = mysqli_fetch_assoc($res))) {
                $order[] = [(int)$row['id'], (int)$row['src']];
                if ((int)$row['src'] === 1) $storeIds[] = (int)$row['id'];
            }
            $storeRows = $storeIds ? store_items_find($con, $storeIds) : [];

            foreach ($order as [$bId, $src]) {
                if ($src === 1) {
                    if (!isset($storeRows[$bId])) continue;
                    $detail = admin_store_item_book_row($con, $storeRows[$bId]);
                    if ($teacherId > 0) {
                        $detail['is_owned'] = isset($ownedStore[$bId]);
                        // Edited through /teacher/products, never through /books.
                        $detail['can_edit'] = false;
                    }
                } else {
                    $detail = adminGetBookDetails($con, $bId);
                    if (!$detail) continue;
                    if ($teacherId > 0) {
                        $detail['can_edit'] = ($detail['created_by_type'] ?? 'admin') !== 'admin';
                        $detail['is_owned'] = isset($ownedLessons[$bId]);
                    }
                }
                $books[] = $detail;
            }
        }

        // Cheap aggregate counts for the library's stat cards - across both tables, not just the
        // current page/search/scope. `general_count` is the store (products), `unit_count` the
        // lesson files, as the two tabs show them.
        $lessonStats = mysqli_fetch_assoc(mysqli_query($con, "
            SELECT
                COUNT(*) AS total_count,
                COALESCE(SUM(is_active = 1), 0) AS active_count,
                COALESCE(SUM(is_active = 0), 0) AS inactive_count
            FROM course_books
            WHERE course_id IS NOT NULL OR unit_id IS NOT NULL
        ")) ?: [];
        $storeStats = [];
        if (products_tables_ready($con)) {
            $sRes = @mysqli_query($con, "
                SELECT COUNT(*) AS total_count,
                       COALESCE(SUM(is_active = 1), 0) AS active_count,
                       COALESCE(SUM(is_active = 0), 0) AS inactive_count
                FROM products
            ");
            $storeStats = $sRes ? (mysqli_fetch_assoc($sRes) ?: []) : [];
        }
        $statistics = [
            'total_count' => (int)($lessonStats['total_count'] ?? 0) + (int)($storeStats['total_count'] ?? 0),
            'active_count' => (int)($lessonStats['active_count'] ?? 0) + (int)($storeStats['active_count'] ?? 0),
            'inactive_count' => (int)($lessonStats['inactive_count'] ?? 0) + (int)($storeStats['inactive_count'] ?? 0),
            'general_count' => (int)($storeStats['total_count'] ?? 0),
            'unit_count' => (int)($lessonStats['total_count'] ?? 0),
        ];

        return build_admin_paginated_response($books, $page, $limit, $totalRecords, $statistics);
    }
}

if (!function_exists('adminGetBook')) {
    function adminGetBook($con) {
        $id = (int)($_GET['id'] ?? read_json_body()['id'] ?? 0);
        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'Book ID is required'];
        }
        $book = adminGetBookDetails($con, $id);
        if (!$book) {
            return ['status' => 'error', 'message' => 'Book not found'];
        }
        return ['status' => 'success', 'data' => $book];
    }
}

if (!function_exists('adminCreateBook')) {
    function adminCreateBook($con, $creatorData = null) {
        $body = read_json_body();

        $creatorType = 'admin';
        $creatorId = 1;
        if (is_array($creatorData)) {
            $creatorType = (!empty($creatorData['teacher_id']) || isset($creatorData['specialization']) || ($creatorData['role'] ?? '') === 'teacher' || ($creatorData['user_type'] ?? '') === 'teacher') ? 'teacher' : 'admin';
            $creatorId = (int)($creatorData['id'] ?? $creatorData['teacher_id'] ?? 1);
        } elseif (is_object($creatorData)) {
            $creatorType = (!empty($creatorData->teacher_id) || isset($creatorData->specialization) || ($creatorData->role ?? '') === 'teacher' || ($creatorData->user_type ?? '') === 'teacher') ? 'teacher' : 'admin';
            $creatorId = (int)($creatorData->id ?? $creatorData->teacher_id ?? 1);
        }

        $titleAr = trim($body['title_ar'] ?? $body['title'] ?? '');
        $titleEn = trim($body['title_en'] ?? $titleAr);
        $descAr = trim($body['description_ar'] ?? $body['description'] ?? '');
        $descEn = trim($body['description_en'] ?? $descAr);

        // read_json_body() already uploads any raw $_FILES entry itself and rewrites $body[key] into
        // a hosted URL (the generic handler further up in helpers/functions.php) - 'cover_image'/
        // 'image' already relied on that. The PDF upload never worked because nothing here ever read
        // the uploaded 'file' key the same way, only 'file_path' (which the form never sends).
        $filePath = trim($body['file_path'] ?? $body['file'] ?? '');
        $link = trim($body['link'] ?? '');
        $coverImage = trim($body['cover_image'] ?? $body['image'] ?? '');

        $fileType = trim($body['file_type'] ?? 'pdf');
        $category = in_array(trim($body['category'] ?? ''), ['summary', 'exam'], true) ? trim($body['category']) : 'summary';
        $extension = trim($body['extension'] ?? 'pdf');
        $courseId = isset($body['course_id']) && (int)$body['course_id'] > 0 ? (int)$body['course_id'] : null;
        $unitId = isset($body['unit_id']) && (int)$body['unit_id'] > 0 ? (int)$body['unit_id'] : null;
        $subjectId = isset($body['subject_id']) && (int)$body['subject_id'] > 0 ? (int)$body['subject_id'] : null;
        $isActive = isset($body['is_active']) ? (int)$body['is_active'] : 1;

        // A unit-scoped book only ever got unit_id from the form - course_id/subject_id were left
        // NULL on the row forever, resolvable only at read time by whichever endpoint bothered to
        // join units. Storing the real values here keeps every consumer consistent.
        if ($unitId !== null && ($courseId === null || $subjectId === null)) {
            $uRes = mysqli_query($con, "SELECT course_id, subject_id FROM units WHERE id = {$unitId} LIMIT 1");
            if ($uRes && $uRow = mysqli_fetch_assoc($uRes)) {
                if ($courseId === null && !empty($uRow['course_id'])) {
                    $courseId = (int)$uRow['course_id'];
                }
                if ($subjectId === null && !empty($uRow['subject_id'])) {
                    $subjectId = (int)$uRow['subject_id'];
                }
            }
        }

        // A book with no course and no unit used to be a store item. The store is `products` now
        // (migration 131); creating one here would put a store item where nothing sells it.
        if ($courseId === null && $unitId === null) {
            return books_store_item_refusal($con);
        }

        // Books tied to a course/unit are bundled with the course purchase and
        // must never carry their own separate price — only standalone
        // (external) books, with no course_id/unit_id, are individually priced.
        $isCourseLinked = ($courseId !== null || $unitId !== null);
        // Empty is "no price", 0 is free. A lesson file is never sold on its own, so it is
        // always 0 whatever was sent.
        $priceInput = price_from_body($con, $body, 'course_books');
        $price = $isCourseLinked ? 0.00 : ($priceInput['present'] ? $priceInput['price'] : 0.00);
        // Interpolated below, so a "no price" has to become the SQL keyword, not an empty string.
        $priceSql = $price === null ? 'NULL' : (string)(float)$price;
        // Every book is view-only on the platform, whatever the request body says. Handing a
        // student a downloadable file hands it to whoever they pass it on to, and the column is
        // what the student endpoints read to decide whether to expose the file's real address at
        // all - so this is the single place that keeps that address from ever being published.
        $allowDownload = 0;

        $cbSub = $subjectId ? $subjectId : 'NULL';
        $cbCourse = $courseId ? $courseId : 'NULL';
        $cbUnit = $unitId ? $unitId : 'NULL';

        $cbSql = "INSERT INTO course_books (subject_id, course_id, unit_id, file_type, category, extension, link, file_path, cover_image, price, allow_download, is_active, created_by_type, created_by_id) VALUES ({$cbSub}, {$cbCourse}, {$cbUnit}, '" . mysqli_real_escape_string($con, $fileType) . "', '" . mysqli_real_escape_string($con, $category) . "', '" . mysqli_real_escape_string($con, $extension) . "', '" . mysqli_real_escape_string($con, $link) . "', '" . mysqli_real_escape_string($con, $filePath) . "', '" . mysqli_real_escape_string($con, $coverImage) . "', {$priceSql}, {$allowDownload}, {$isActive}, '{$creatorType}', {$creatorId})";
        if (!mysqli_query($con, $cbSql)) {
            return ['status' => 'error', 'message' => 'Failed to create book: ' . mysqli_error($con)];
        }
        $bookId = mysqli_insert_id($con);
        if ($creatorType === 'teacher' && $creatorId > 0) {
            @mysqli_query($con, "INSERT INTO book_teachers (book_id, teacher_id, is_active) VALUES ({$bookId}, {$creatorId}, 1) ON DUPLICATE KEY UPDATE is_active = 1");
        }

        if (!empty($titleAr) || !empty($descAr)) {
            @mysqli_query($con, "INSERT INTO course_books_translations (book_id, language_id, title, description) VALUES ({$bookId}, 1, '" . mysqli_real_escape_string($con, $titleAr) . "', '" . mysqli_real_escape_string($con, $descAr) . "') ON DUPLICATE KEY UPDATE title = VALUES(title), description = VALUES(description)");
        }
        if (!empty($titleEn) || !empty($descEn)) {
            @mysqli_query($con, "INSERT INTO course_books_translations (book_id, language_id, title, description) VALUES ({$bookId}, 2, '" . mysqli_real_escape_string($con, $titleEn) . "', '" . mysqli_real_escape_string($con, $descEn) . "') ON DUPLICATE KEY UPDATE title = VALUES(title), description = VALUES(description)");
        }

        return [
            'status' => 'success',
            'message' => 'Book created successfully',
            'data' => adminGetBookDetails($con, $bookId)
        ];
    }
}

if (!function_exists('adminUpdateBook')) {
    function adminUpdateBook($con, $creatorData = null) {
        $body = read_json_body();
        $id = (int)($body['id'] ?? $_GET['id'] ?? 0);
        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'Book ID is required'];
        }

        $existingRes = mysqli_query($con, "SELECT course_id, unit_id FROM course_books WHERE id = {$id} LIMIT 1");
        $existingRow = $existingRes ? mysqli_fetch_assoc($existingRes) : null;
        if (!$existingRow) {
            // A store item's id: it is edited as a product now.
            if (store_item_find($con, $id)) {
                return books_store_item_refusal($con);
            }
            return ['status' => 'error', 'message' => 'Book not found'];
        }

        $resolvedCourseId = isset($body['course_id']) ? (int)$body['course_id'] : (int)($existingRow['course_id'] ?? 0);
        $resolvedUnitId = isset($body['unit_id']) ? (int)$body['unit_id'] : (int)($existingRow['unit_id'] ?? 0);
        // Detaching a lesson file from both its course and its unit would turn it into a store
        // item, which is a product now.
        if ($resolvedCourseId <= 0 && $resolvedUnitId <= 0) {
            return books_store_item_refusal($con);
        }
        // Books tied to a course/unit are bundled with the course purchase —
        // force their price to 0 regardless of what was submitted.
        $isCourseLinked = ($resolvedCourseId > 0 || $resolvedUnitId > 0);

        $updateFields = [];

        // Same backfill as creation: a unit-scoped book must carry its unit's real course_id/
        // subject_id, not leave them NULL forever just because the form only ever sent unit_id.
        if ($resolvedUnitId > 0 && (!isset($body['course_id']) || !isset($body['subject_id']))) {
            $uRes2 = mysqli_query($con, "SELECT course_id, subject_id FROM units WHERE id = {$resolvedUnitId} LIMIT 1");
            if ($uRes2 && $uRow2 = mysqli_fetch_assoc($uRes2)) {
                if (!isset($body['course_id']) && !empty($uRow2['course_id'])) {
                    $updateFields[] = "course_id = " . (int)$uRow2['course_id'];
                }
                if (!isset($body['subject_id']) && !empty($uRow2['subject_id'])) {
                    $updateFields[] = "subject_id = " . (int)$uRow2['subject_id'];
                }
            }
        }

        // Same enforcement as creation: every book is view-only, whatever the form sends. An
        // older book that was saved as downloadable is pulled back in line the next time it is
        // edited, without anyone having to notice it.
        $updateFields[] = "allow_download = 0";

        if ($isCourseLinked) {
            $updateFields[] = "price = 0";
        } else {
            // `isset()` read a sent null as "not sent", so a price could never be cleared. Absent
            // still means "leave it"; sent empty means "no price".
            $priceInput = price_from_body($con, $body, 'course_books');
            if ($priceInput['present']) {
                $updateFields[] = $priceInput['price'] === null
                    ? "price = NULL"
                    : "price = " . (float)$priceInput['price'];
            }
        }
        // read_json_body() already uploads a raw $_FILES entry itself and rewrites $body[key] into a
        // hosted URL - 'cover_image'/'image' already relied on that below. The PDF upload never
        // worked because nothing here ever read the uploaded 'file' key, only 'file_path' (which the
        // edit form never sends).
        if (isset($body['file_path']) || isset($body['file'])) {
            $fpEsc = mysqli_real_escape_string($con, trim($body['file_path'] ?? $body['file']));
            $updateFields[] = "file_path = '{$fpEsc}'";
        }
        if (isset($body['link'])) {
            $linkEsc = mysqli_real_escape_string($con, trim($body['link']));
            $updateFields[] = "link = '{$linkEsc}'";
        }
        if (isset($body['cover_image']) || isset($body['image'])) {
            $imgEsc = mysqli_real_escape_string($con, trim($body['cover_image'] ?? $body['image']));
            $updateFields[] = "cover_image = '{$imgEsc}'";
        }
        if (isset($body['file_type'])) {
            $ftEsc = mysqli_real_escape_string($con, trim($body['file_type']));
            $updateFields[] = "file_type = '{$ftEsc}'";
            $updateFields[] = "extension = '{$ftEsc}'";
        }
        if (in_array(trim($body['category'] ?? ''), ['summary', 'exam'], true)) {
            $updateFields[] = "category = '" . trim($body['category']) . "'";
        }
        if (isset($body['is_active'])) {
            $act = (int)$body['is_active'];
            $updateFields[] = "is_active = {$act}";
        }
        if (isset($body['subject_id'])) {
            $subVal = (int)$body['subject_id'] > 0 ? (int)$body['subject_id'] : 'NULL';
            $updateFields[] = "subject_id = {$subVal}";
        }
        if (isset($body['course_id'])) {
            $crsVal = (int)$body['course_id'] > 0 ? (int)$body['course_id'] : 'NULL';
            $updateFields[] = "course_id = {$crsVal}";
        }
        if (isset($body['unit_id'])) {
            $unitVal = (int)$body['unit_id'] > 0 ? (int)$body['unit_id'] : 'NULL';
            $updateFields[] = "unit_id = {$unitVal}";
        }

        if (!empty($updateFields)) {
            mysqli_query($con, "UPDATE course_books SET " . implode(", ", $updateFields) . " WHERE id = {$id}");
        }

        if (isset($body['title_ar']) || isset($body['title_en']) || isset($body['title']) || isset($body['description_ar']) || isset($body['description_en'])) {
            $titleAr = trim($body['title_ar'] ?? $body['title'] ?? '');
            $titleEn = trim($body['title_en'] ?? $titleAr);
            $descAr = trim($body['description_ar'] ?? $body['description'] ?? '');
            $descEn = trim($body['description_en'] ?? $descAr);

            if (!empty($titleAr)) {
                @mysqli_query($con, "INSERT INTO course_books_translations (book_id, language_id, title, description) VALUES ({$id}, 1, '" . mysqli_real_escape_string($con, $titleAr) . "', '" . mysqli_real_escape_string($con, $descAr) . "') ON DUPLICATE KEY UPDATE title = VALUES(title), description = VALUES(description)");
            }
            if (!empty($titleEn)) {
                @mysqli_query($con, "INSERT INTO course_books_translations (book_id, language_id, title, description) VALUES ({$id}, 2, '" . mysqli_real_escape_string($con, $titleEn) . "', '" . mysqli_real_escape_string($con, $descEn) . "') ON DUPLICATE KEY UPDATE title = VALUES(title), description = VALUES(description)");
            }
        }

        return [
            'status' => 'success',
            'message' => 'Book updated successfully',
            'data' => adminGetBookDetails($con, $id)
        ];
    }
}

if (!function_exists('adminDeleteBook')) {
    function adminDeleteBook($con, $creatorData = null) {
        $id = (int)($_GET['id'] ?? read_json_body()['id'] ?? 0);
        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'Book ID is required'];
        }
        // A store item is deleted as a product, never through /books.
        if (!books_is_lesson_file($con, $id) && store_item_find($con, $id)) {
            return books_store_item_refusal($con);
        }
        if (mysqli_query($con, "DELETE FROM course_books WHERE id = {$id}")) {
            @mysqli_query($con, "DELETE FROM course_books_translations WHERE book_id = {$id}");
            return ['status' => 'success', 'message' => 'Book deleted successfully'];
        }
        return ['status' => 'error', 'message' => 'Failed to delete book'];
    }
}

if (!function_exists('adminReorderBooks')) {
    // Persists a manually drag-reordered list of a unit's books/exam PDFs. Scoped to one
    // unit + category at a time, same as the Units reorder - the two categories are always
    // browsed as separate lists, so their order_num sequences are independent of each other.
    // Body: { unit_id, category, ordered_ids: [book_id, book_id, ...] } - the new order, top to bottom.
    function adminReorderBooks($con) {
        $body = read_json_body();
        $unitId = (int)($body['unit_id'] ?? 0);
        $category = in_array(trim($body['category'] ?? ''), ['summary', 'exam'], true) ? trim($body['category']) : null;
        $orderedIds = $body['ordered_ids'] ?? $body['order'] ?? [];

        if ($unitId <= 0) {
            return ['status' => 'error', 'message' => 'unit_id is required'];
        }
        if (!is_array($orderedIds) || empty($orderedIds)) {
            return ['status' => 'error', 'message' => 'ordered_ids is required'];
        }

        $categorySql = $category !== null ? "AND category = '{$category}'" : '';
        $position = 1;
        foreach ($orderedIds as $bookId) {
            $bookId = (int)$bookId;
            if ($bookId <= 0) continue;
            mysqli_query($con, "UPDATE course_books SET order_num = {$position} WHERE id = {$bookId} AND unit_id = {$unitId} {$categorySql}");
            $position++;
        }

        return ['status' => 'success', 'message' => 'Books reordered successfully'];
    }
}

if (!function_exists('adminStreamBookFile')) {
    // Admin/teacher's own "Open" action, kept consistent with the student's authenticated
    // view-only stream: when allow_download = 0, adminGetBookDetails() hands out this URL
    // instead of the raw file_path/link, specifically so the file never ends up as a bare,
    // copyable, permanent public link - not even in the hands of the people managing it.
    // No per-book ownership check: being an authenticated admin or teacher (enforced by
    // whichever middleware wraps the route) is itself the permission.
    function adminStreamBookFile($con) {
        $bookId = (int)($_GET['book_id'] ?? $_GET['id'] ?? 0);
        if ($bookId <= 0) {
            return ['status' => 'error', 'message' => 'book_id is required'];
        }

        $bRes = mysqli_query($con, "SELECT file_path, link, file_type FROM course_books WHERE id = {$bookId} LIMIT 1");
        $bRow = $bRes ? mysqli_fetch_assoc($bRes) : null;
        if (!$bRow) {
            // A store item: the view-only URL adminGetBookDetails() hands out for it points here.
            $product = store_item_find($con, $bookId);
            if ($product) {
                $bRow = [
                    'file_path' => $product['file_path'] ?? '',
                    'link' => $product['link'] ?? '',
                    'file_type' => store_item_file_type($product),
                ];
            }
        }
        if (!$bRow) {
            return ['status' => 'error', 'message' => 'Book not found'];
        }

        $source = trim($bRow['file_path'] ?: $bRow['link'] ?: '');
        if ($source === '') {
            return ['status' => 'error', 'message' => 'Book file is not available'];
        }

        $mime = ((trim($bRow['file_type'] ?? 'pdf')) === 'pdf') ? 'application/pdf' : 'application/octet-stream';

        if (preg_match('/^https?:\/\//i', $source)) {
            $ch = curl_init($source);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
            curl_setopt($ch, CURLOPT_TIMEOUT, 30);
            $content = curl_exec($ch);
            $ok = ($content !== false && curl_getinfo($ch, CURLINFO_HTTP_CODE) < 400);
            curl_close($ch);

            if (!$ok) {
                return ['status' => 'error', 'message' => 'Failed to load book file'];
            }

            header('Content-Type: ' . $mime);
            header('Content-Disposition: inline; filename="book-' . $bookId . '"');
            header('X-Content-Type-Options: nosniff');
            echo $content;
            exit();
        }

        $localPath = realpath(__DIR__ . '/../../../' . ltrim($source, '/'));
        $uploadsRoot = realpath(__DIR__ . '/../../../');
        if (!$localPath || !$uploadsRoot || !str_starts_with($localPath, $uploadsRoot) || !is_file($localPath)) {
            return ['status' => 'error', 'message' => 'Book file is not available'];
        }

        header('Content-Type: ' . $mime);
        header('Content-Disposition: inline; filename="' . basename($localPath) . '"');
        header('Content-Length: ' . filesize($localPath));
        header('X-Content-Type-Options: nosniff');
        readfile($localPath);
        exit();
    }
}

if (!function_exists('adminToggleBookWebsiteVisibility')) {
    function adminToggleBookWebsiteVisibility($con) {
        $body = read_json_body();
        $id = (int)($body['id'] ?? $_GET['id'] ?? 0);
        $showOnWebsite = isset($body['show_on_website']) ? (int)$body['show_on_website'] : (isset($_GET['show_on_website']) ? (int)$_GET['show_on_website'] : null);

        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'Book ID is required'];
        }
        // A store item's visibility is toggled as a product (/admin/products/toggle-website-visibility).
        if (!books_is_lesson_file($con, $id) && store_item_find($con, $id)) {
            return books_store_item_refusal($con);
        }

        if ($showOnWebsite !== null) {
            $val = $showOnWebsite ? 1 : 0;
            @mysqli_query($con, "UPDATE course_books SET show_on_website = {$val} WHERE id = {$id}");
        } else {
            @mysqli_query($con, "UPDATE course_books SET show_on_website = IF(show_on_website = 1, 0, 1) WHERE id = {$id}");
        }

        return ['status' => 'success', 'message' => 'Book website visibility updated successfully'];
    }
}

if (!function_exists('store_item_grant_one')) {
    /**
     * Gives one student one store item - the shared core of grant-access and of approving a
     * purchase request, for the admin and the teacher alike.
     *
     * Returns 'granted' (a new or re-activated ownership: one unit of tracked stock leaves), or
     * 'already' (the student already held it: nothing leaves the shelf twice), or the
     * store_item_sale_block() error code when the item cannot be handed over right now. Stock is
     * re-read for each student because a grant to a list of students can empty the shelf midway.
     */
    function store_item_grant_one($con, int $itemId, int $studentId, string $byType, int $byId, bool $restampGrantor): string {
        $chk = mysqli_query($con, "SELECT id, is_active FROM student_book_subscriptions WHERE student_id = {$studentId} AND book_id = {$itemId} LIMIT 1");
        $existing = $chk ? mysqli_fetch_assoc($chk) : null;
        $byType = $byType === 'teacher' ? 'teacher' : 'admin';

        if ($existing && (int)$existing['is_active'] === 1) {
            if ($restampGrantor) {
                mysqli_query($con, "UPDATE student_book_subscriptions SET granted_by_type = '{$byType}', granted_by_id = {$byId} WHERE student_id = {$studentId} AND book_id = {$itemId}");
            }
            return 'already';
        }

        $item = store_item_find($con, $itemId);
        $block = store_item_sale_block($con, $item);
        if ($block) {
            return $block['error_code'];
        }

        if ($existing) {
            $grantor = $restampGrantor ? ", granted_by_type = '{$byType}', granted_by_id = {$byId}" : "";
            mysqli_query($con, "UPDATE student_book_subscriptions SET is_active = 1{$grantor} WHERE student_id = {$studentId} AND book_id = {$itemId}");
        } else {
            // What the student would have paid: the sale price while on sale. "No price" is
            // recorded as 0 - a grant is a gift, whatever the shop would charge.
            $price = (float)(store_item_effective_price($item) ?? 0.00);
            mysqli_query($con, "INSERT INTO student_book_subscriptions (student_id, book_id, granted_by_type, granted_by_id, price, is_active) VALUES ({$studentId}, {$itemId}, '{$byType}', {$byId}, {$price}, 1)");
        }

        store_item_take_stock($con, $itemId);
        return 'granted';
    }
}

if (!function_exists('store_item_grant_access')) {
    /**
     * grant-access for the admin and the teacher: the same body, the same response. A teacher may
     * grant only an item they own (R7); `$teacherId` is 0 for the admin.
     */
    function store_item_grant_access($con, string $byType, int $byId, int $teacherId = 0) {
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

        $item = store_item_find($con, $bookId);
        if (!$item) {
            return ['status' => 'error', 'message' => 'Book not found'];
        }
        if ($teacherId > 0 && !teacher_owns_store_item($con, $teacherId, $bookId)) {
            return [
                'status' => 'error',
                'error_code' => 'not_owner',
                'message' => app_text($con, 'هذا المنتج ليس من منتجاتك، فلا يمكنك منحه لطالب.', 'This product is not one of yours, so you cannot grant it to a student.'),
            ];
        }
        $block = store_item_sale_block($con, $item);
        if ($block) {
            return $block;
        }

        $grantedCount = 0;
        $outOfStock = [];

        foreach (array_unique($studentIds) as $stId) {
            if ($stId <= 0) continue;

            $result = store_item_grant_one($con, $bookId, $stId, $byType, $byId, false);
            if ($result !== 'granted' && $result !== 'already') {
                $outOfStock[] = $stId;
                continue;
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

        $message = "Book access granted successfully to {$grantedCount} student(s)";
        if ($outOfStock) {
            $message .= app_text($con, '. نفد المخزون قبل منح ' . count($outOfStock) . ' طالب.', '. Stock ran out before ' . count($outOfStock) . ' student(s) could be granted.');
        }

        return [
            'status' => 'success',
            'message' => $message,
            'data' => [
                'book_id' => $bookId,
                'granted_students_count' => $grantedCount,
                'out_of_stock_student_ids' => $outOfStock,
            ]
        ];
    }
}

if (!function_exists('adminGrantBookAccessToStudent')) {
    function adminGrantBookAccessToStudent($con, $adminData = null) {
        $adminId = 1;
        if (is_array($adminData) && !empty($adminData['id'])) {
            $adminId = (int)$adminData['id'];
        } elseif (is_object($adminData) && !empty($adminData->id)) {
            $adminId = (int)$adminData->id;
        }
        return store_item_grant_access($con, 'admin', $adminId);
    }
}

// teacherGrantBookAccessToStudent lives in app/teacher/books/manage.php

if (!function_exists('book_request_select_sql')) {
    /**
     * The columns of a purchase-request row, read from the product the request is for. Every
     * name the list returned when it read course_books is still here with its old meaning;
     * `book_cover_image` is the product's image.
     */
    function book_request_select_sql(int $langId): string {
        $nameSql = store_name_sql($langId, 'p');
        return "
                sbpr.id,
                sbpr.student_id,
                sbpr.book_id,
                sbpr.status,
                sbpr.reviewed_by_type,
                sbpr.reviewed_by_id,
                sbpr.notes,
                sbpr.review_notes,
                sbpr.created_at,
                sbpr.updated_at,

                st.name AS student_name,
                st.email AS student_email,
                st.phone AS student_phone,
                st.image AS student_image,

                IF(p.id IS NULL, NULL, {$nameSql}) AS book_title,
                (SELECT COALESCE(
                    (SELECT pt.description FROM products_translations pt WHERE pt.product_id = p.id AND pt.language_id = {$langId} LIMIT 1),
                    (SELECT pt.description FROM products_translations pt WHERE pt.product_id = p.id ORDER BY pt.id ASC LIMIT 1))
                ) AS book_description,
                p.file_path AS book_file_path,
                p.image AS book_cover_image,
                p.price AS book_price,
                p.sale_price AS book_sale_price,
                p.stock AS book_stock,
                p.allow_download AS book_allow_download,
                p.product_type AS book_product_type,
                p.file_extension AS book_file_extension,
                p.subject_id AS subject_id,
                subt.name AS subject_name
        ";
    }
}

if (!function_exists('book_request_from_sql')) {
    function book_request_from_sql(int $langId): string {
        return "
            FROM student_book_purchase_requests sbpr
            JOIN students st ON sbpr.student_id = st.id
            LEFT JOIN products p ON sbpr.book_id = p.id
            LEFT JOIN subjects sub ON p.subject_id = sub.id
            LEFT JOIN subjects_translations subt ON sub.id = subt.subject_id AND subt.language_id = {$langId}
        ";
    }
}

if (!function_exists('book_request_format_row')) {
    function book_request_format_row(array $row): array {
        $row['id'] = (int)$row['id'];
        $row['student_id'] = (int)$row['student_id'];
        $row['book_id'] = (int)$row['book_id'];
        $row['reviewed_by_id'] = !empty($row['reviewed_by_id']) ? (int)$row['reviewed_by_id'] : null;
        $row['student_image'] = !empty($row['student_image']) ? format_image_url($row['student_image']) : null;
        $row['book_cover_image'] = !empty($row['book_cover_image']) ? format_image_url($row['book_cover_image']) : null;
        $row['book_file_path'] = !empty($row['book_file_path']) ? format_image_url($row['book_file_path']) : null;

        // `book_file_type` keeps the value a book row carried: 'physical' or the extension.
        $productType = $row['book_product_type'] ?? null;
        $row['book_file_type'] = $productType === null ? null : store_item_file_type([
            'product_type' => $productType,
            'file_extension' => $row['book_file_extension'] ?? null,
        ]);
        unset($row['book_file_extension']);

        $priced = $row['book_price'] !== null;
        $effective = store_item_effective_price(['price' => $row['book_price'], 'sale_price' => $row['book_sale_price']]);
        $row['book_price'] = (float)($row['book_price'] ?? 0.00);
        $row['book_is_priced'] = $priced;
        $row['book_sale_price'] = $row['book_sale_price'] !== null ? (float)$row['book_sale_price'] : null;
        $row['book_effective_price'] = $effective;
        $row['book_stock'] = $row['book_stock'] !== null ? (int)$row['book_stock'] : null;
        $row['book_in_stock'] = $row['book_stock'] === null || $row['book_stock'] > 0;
        $row['book_allow_download'] = (int)($row['book_allow_download'] ?? 1);
        $row['subject_id'] = !empty($row['subject_id']) ? (int)$row['subject_id'] : null;
        $row['subject_name'] = $row['subject_name'] ?? null;
        $row['item_type'] = 'product';

        return $row;
    }
}

if (!function_exists('book_request_search_sql')) {
    function book_request_search_sql($con, string $search, bool $withSubject): string {
        $like = '%' . mysqli_real_escape_string($con, $search) . '%';
        return " AND (
                st.name LIKE '{$like}'
                OR st.email LIKE '{$like}'
                OR st.phone LIKE '{$like}'
                OR EXISTS (SELECT 1 FROM products_translations pt_s WHERE pt_s.product_id = p.id AND pt_s.name LIKE '{$like}')
                OR sbpr.status LIKE '{$like}'
                OR sbpr.notes LIKE '{$like}'"
            . ($withSubject ? " OR subt.name LIKE '{$like}'" : "") . "
            )";
    }
}

if (!function_exists('adminListBookPurchaseRequests')) {
    function adminListBookPurchaseRequests($con) {
        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, (int)($_GET['limit'] ?? 20));
        $offset = ($page - 1) * $limit;

        $studentId = (int)($_GET['student_id'] ?? 0);
        $bookId = (int)($_GET['book_id'] ?? 0);
        $subjectId = (int)($_GET['subject_id'] ?? $_GET['category_id'] ?? 0);
        $status = trim($_GET['status'] ?? '');
        $reviewedByType = trim($_GET['reviewed_by_type'] ?? '');
        $search = trim($_GET['search'] ?? $_GET['q'] ?? '');

        $langInfo = get_language_info($con);
        $langId = (int)($langInfo['id'] ?? 1);

        $whereClause = "WHERE 1=1";
        if ($studentId > 0) {
            $whereClause .= " AND sbpr.student_id = {$studentId}";
        }
        if ($bookId > 0) {
            $whereClause .= " AND sbpr.book_id = {$bookId}";
        }
        if ($subjectId > 0) {
            $whereClause .= " AND p.subject_id = {$subjectId}";
        }
        if ($status !== '') {
            $statusEsc = mysqli_real_escape_string($con, $status);
            $whereClause .= " AND sbpr.status = '{$statusEsc}'";
        }
        if ($reviewedByType !== '') {
            $reviewedByTypeEsc = mysqli_real_escape_string($con, $reviewedByType);
            $whereClause .= " AND sbpr.reviewed_by_type = '{$reviewedByTypeEsc}'";
        }
        if ($search !== '') {
            $whereClause .= book_request_search_sql($con, $search, true);
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

// teacherListBookPurchaseRequests lives in app/teacher/books/manage.php

if (!function_exists('book_request_review')) {
    /**
     * Approve or reject a pending purchase request - the admin's and the teacher's review are
     * this one function. An approval is refused, and the request left pending, when the item
     * cannot be handed over (gone, inactive, out of stock); otherwise it grants the item and
     * takes one unit of tracked stock (R6). `$teacherId` > 0 limits it to that teacher's items.
     */
    function book_request_review($con, string $byType, int $byId, int $teacherId = 0) {
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

        $stId = (int)$rRow['student_id'];
        $bookId = (int)$rRow['book_id'];

        if ($teacherId > 0 && !teacher_owns_store_item($con, $teacherId, $bookId)) {
            return ['status' => 'error', 'message' => 'You are not authorized to review this book request'];
        }

        if ($newStatus === 'approved') {
            $block = store_item_sale_block($con, store_item_find($con, $bookId));
            if ($block) {
                return $block;
            }
        }

        $byType = $byType === 'teacher' ? 'teacher' : 'admin';
        $notesEsc = mysqli_real_escape_string($con, $notes);

        // review_notes, not notes: `notes` is the student's own note from when the request was
        // filed. Writing the reviewer's note over it lost the student's words every time.
        mysqli_query($con, "UPDATE student_book_purchase_requests SET status = '{$newStatus}', reviewed_by_type = '{$byType}', reviewed_by_id = {$byId}, review_notes = '{$notesEsc}' WHERE id = {$requestId}");

        if ($newStatus === 'approved') {
            store_item_grant_one($con, $bookId, $stId, $byType, $byId, true);
        }

        return [
            'status' => 'success',
            'message' => $newStatus === 'approved' ? 'Request approved and book access granted' : 'Request rejected',
            'data' => ['request_id' => $requestId, 'status' => $newStatus]
        ];
    }
}

if (!function_exists('adminReviewBookRequest')) {
    function adminReviewBookRequest($con, $adminData = null) {
        $adminId = 0;
        if (is_array($adminData)) {
            $adminId = (int)($adminData['id'] ?? $adminData['admin_id'] ?? 0);
        } elseif (is_object($adminData)) {
            $adminId = (int)($adminData->id ?? $adminData->admin_id ?? 0);
        }
        return book_request_review($con, 'admin', $adminId);
    }
}

if (!function_exists('adminDeleteBookPurchaseRequest')) {
    /**
     * Clears a purchase request off the list once it has been decided.
     *
     * The list is a QUEUE, not a ledger: an admin works through it, and approved and rejected rows
     * pile up in front of the ones still waiting. Removing a decided row is tidying, not undoing -
     * approving a request grants the book through `student_book_subscriptions`, and that row is a
     * separate thing which this does not touch. A student who was granted a book keeps it.
     *
     * A PENDING request is refused. Deleting one would silently drop a student's request with no
     * answer, and the student would never learn it had been seen at all - "reject it, then remove
     * it" is one extra click and leaves them told.
     */
    function adminDeleteBookPurchaseRequest($con) {
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

        $stmt = mysqli_prepare($con, "SELECT id, status FROM student_book_purchase_requests WHERE id = ? LIMIT 1");
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
            'message' => app_text($con, 'تم حذف الطلب.', 'The request has been removed.'),
            'data' => ['id' => $requestId],
        ];
    }
}
