<?php
/**
 * منتجات المتجر وتصنيفاتها — admin CRUD.
 *
 * The store had no products of its own. What it sold were `course_books` rows with no file
 * attached, which works for a printed book and for nothing else: a school bag has no subject, no
 * course and no unit, and the nearest thing to a category on that table is
 * `enum('summary','exam')`, which says whether a PDF is a summary or a past paper.
 *
 * So products are their own table, with their own categories - "حقائب مدرسية" is not a course
 * category and does not belong in the same list as "الكيمياء". Nothing about books changed; the
 * store endpoint lists the two side by side (see app/store/manage.php).
 *
 * Needs migration 127. Every function here degrades to an empty list rather than a fatal error
 * while it has not run, as the rest of this codebase does for a table added after the fact.
 */

require_once __DIR__ . '/../../../helpers/functions.php';
require_once __DIR__ . '/../../../helpers/language.php';
require_once __DIR__ . '/../../../helpers/upload.php';
require_once __DIR__ . '/../../content/helpers.php';

if (!function_exists('products_tables_ready')) {
    /** Migration 127 has run. Cached: this is asked on every call into this file. */
    function products_tables_ready($con): bool {
        static $cached = null;
        if ($cached !== null) {
            return $cached;
        }
        $res = @mysqli_query($con, "SHOW TABLES LIKE 'products'");
        $cached = $res && mysqli_num_rows($res) > 0;
        return $cached;
    }
}

if (!function_exists('products_not_ready')) {
    function products_not_ready(): array {
        return [
            'status' => 'error',
            'message' => 'جدول المنتجات غير موجود بعد. شغّل migrations/127_products_and_categories.sql أولًا.',
        ];
    }
}

if (!function_exists('product_translation_pairs')) {
    /**
     * `name_ar` / `name_en` off the request, resolved to language ids. Both optional
     * individually; the caller decides whether at least one is required.
     */
    function product_translation_pairs($con, array $body, string $prefix = 'name'): array {
        $pairs = [];
        foreach (['ar', 'en'] as $code) {
            $name = trim((string)($body[$prefix . '_' . $code] ?? ''));
            $desc = trim((string)($body['description_' . $code] ?? ''));
            if ($name === '' && $desc === '') {
                continue;
            }
            $langId = get_language_id_by_code($con, $code);
            if ($langId > 0) {
                $pairs[$langId] = ['name' => $name, 'description' => $desc !== '' ? $desc : null];
            }
        }
        return $pairs;
    }
}

if (!function_exists('get_language_id_by_code')) {
    function get_language_id_by_code($con, string $code): int {
        $stmt = mysqli_prepare($con, "SELECT id FROM languages WHERE code = ? LIMIT 1");
        if (!$stmt) return 0;
        mysqli_stmt_bind_param($stmt, "s", $code);
        mysqli_stmt_execute($stmt);
        $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));
        return (int)($row['id'] ?? 0);
    }
}

/* ===================== تصنيفات المنتجات — Product categories ===================== */

if (!function_exists('product_category_row')) {
    /** One category with its translations folded into name_ar / name_en. */
    function product_category_row($con, array $row): array {
        $id = (int)$row['id'];
        $out = [
            'id' => $id,
            'code' => $row['code'],
            'image' => $row['image'] ?? null,
            'order_num' => (int)($row['order_num'] ?? 1),
            'is_active' => (int)($row['is_active'] ?? 1),
            'created_at' => $row['created_at'] ?? null,
            'products_count' => 0,
            'translations' => [],
        ];

        $tStmt = mysqli_prepare($con, "
            SELECT t.language_id, l.code AS language_code, t.name, t.description
            FROM product_categories_translations t
            JOIN languages l ON l.id = t.language_id
            WHERE t.product_category_id = ?
        ");
        if ($tStmt) {
            mysqli_stmt_bind_param($tStmt, "i", $id);
            mysqli_stmt_execute($tStmt);
            $tRes = mysqli_stmt_get_result($tStmt);
            while ($t = mysqli_fetch_assoc($tRes)) {
                $t['language_id'] = (int)$t['language_id'];
                if ($t['language_code'] === 'ar') { $out['name_ar'] = $t['name']; $out['description_ar'] = $t['description']; }
                if ($t['language_code'] === 'en') { $out['name_en'] = $t['name']; $out['description_en'] = $t['description']; }
                $out['translations'][] = $t;
            }
        }

        $out['name'] = $out['name_ar'] ?? ($out['name_en'] ?? $out['code']);

        $cRes = @mysqli_query($con, "SELECT COUNT(*) AS c FROM products WHERE product_category_id = {$id}");
        if ($cRes && $cRow = mysqli_fetch_assoc($cRes)) {
            $out['products_count'] = (int)$cRow['c'];
        }

        return format_response_images($out);
    }
}

if (!function_exists('adminListProductCategories')) {
    function adminListProductCategories($con) {
        if (!products_tables_ready($con)) {
            return build_paginated_response([], 1, 10, 0);
        }

        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 20)));
        $offset = ($page - 1) * $limit;
        $search = trim($_GET['search'] ?? $_GET['q'] ?? '');

        $where = [];
        $params = [];
        $types = '';

        if ($search !== '') {
            $where[] = "(c.code LIKE ? OR EXISTS (SELECT 1 FROM product_categories_translations t WHERE t.product_category_id = c.id AND t.name LIKE ?))";
            $pattern = '%' . $search . '%';
            $params[] = $pattern; $params[] = $pattern; $types .= 'ss';
        }
        if (isset($_GET['is_active']) && $_GET['is_active'] !== '') {
            $where[] = "c.is_active = ?";
            $params[] = (int)$_GET['is_active']; $types .= 'i';
        }

        $whereSql = $where ? 'WHERE ' . implode(' AND ', $where) : '';

        $countStmt = mysqli_prepare($con, "SELECT COUNT(*) AS total FROM product_categories c {$whereSql}");
        $total = 0;
        if ($countStmt) {
            if ($params) mysqli_stmt_bind_param($countStmt, $types, ...$params);
            mysqli_stmt_execute($countStmt);
            $total = (int)(mysqli_fetch_assoc(mysqli_stmt_get_result($countStmt))['total'] ?? 0);
        }

        $stmt = mysqli_prepare($con, "
            SELECT c.id, c.code, c.image, c.order_num, c.is_active, c.created_at
            FROM product_categories c
            {$whereSql}
            ORDER BY c.order_num ASC, c.id DESC
            LIMIT ? OFFSET ?
        ");
        $rows = [];
        if ($stmt) {
            $bindTypes = $types . 'ii';
            $bindParams = array_merge($params, [$limit, $offset]);
            mysqli_stmt_bind_param($stmt, $bindTypes, ...$bindParams);
            mysqli_stmt_execute($stmt);
            $res = mysqli_stmt_get_result($stmt);
            while ($row = mysqli_fetch_assoc($res)) {
                $rows[] = product_category_row($con, $row);
            }
        }

        return build_paginated_response($rows, $page, $limit, $total);
    }
}

if (!function_exists('adminGetProductCategory')) {
    function adminGetProductCategory($con) {
        if (!products_tables_ready($con)) return products_not_ready();

        $id = (int)($_GET['id'] ?? read_json_body()['id'] ?? 0);
        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'id is required'];
        }

        $stmt = mysqli_prepare($con, "SELECT id, code, image, order_num, is_active, created_at FROM product_categories WHERE id = ? LIMIT 1");
        mysqli_stmt_bind_param($stmt, "i", $id);
        mysqli_stmt_execute($stmt);
        $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));

        if (!$row) {
            return ['status' => 'error', 'message' => 'التصنيف غير موجود'];
        }

        return ['status' => 'success', 'data' => product_category_row($con, $row)];
    }
}

if (!function_exists('adminCreateProductCategory')) {
    function adminCreateProductCategory($con) {
        if (!products_tables_ready($con)) return products_not_ready();

        $body = read_json_body();
        $nameAr = trim((string)($body['name_ar'] ?? $body['name'] ?? ''));
        $nameEn = trim((string)($body['name_en'] ?? ''));

        if ($nameAr === '' && $nameEn === '') {
            return ['status' => 'error', 'message' => 'اسم التصنيف مطلوب (name_ar أو name_en)'];
        }

        // Same generator the course slug uses, so an Arabic-only category name produces a real
        // code instead of collapsing to a single dash.
        $code = trim((string)($body['code'] ?? ''));
        $code = generate_entity_code($con, 'product_categories', $code !== '' ? $code : ($nameEn !== '' ? $nameEn : $nameAr), 'category');

        $image = process_image_input($body['image'] ?? null, 'products', $_FILES['image'] ?? null);
        $orderNum = isset($body['order_num']) ? (int)$body['order_num'] : 1;
        $isActive = isset($body['is_active']) ? (int)(bool)$body['is_active'] : 1;

        $stmt = mysqli_prepare($con, "INSERT INTO product_categories (code, image, order_num, is_active) VALUES (?, ?, ?, ?)");
        if (!$stmt) {
            return ['status' => 'error', 'message' => describe_db_write_error($con, 'تعذّر إنشاء التصنيف')];
        }
        mysqli_stmt_bind_param($stmt, "ssii", $code, $image, $orderNum, $isActive);
        if (!mysqli_stmt_execute($stmt)) {
            return ['status' => 'error', 'message' => describe_db_write_error($con, 'تعذّر إنشاء التصنيف')];
        }

        $categoryId = mysqli_insert_id($con);
        product_category_save_translations($con, $categoryId, $body);

        return ['status' => 'success', 'message' => 'تم إنشاء التصنيف بنجاح', 'data' => ['id' => $categoryId]];
    }
}

if (!function_exists('product_category_save_translations')) {
    function product_category_save_translations($con, int $categoryId, array $body): void {
        foreach (product_translation_pairs($con, $body) as $langId => $t) {
            $stmt = mysqli_prepare($con, "
                INSERT INTO product_categories_translations (product_category_id, language_id, name, description)
                VALUES (?, ?, ?, ?)
                ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description)
            ");
            if (!$stmt) continue;
            mysqli_stmt_bind_param($stmt, "iiss", $categoryId, $langId, $t['name'], $t['description']);
            mysqli_stmt_execute($stmt);
        }
    }
}

if (!function_exists('adminUpdateProductCategory')) {
    function adminUpdateProductCategory($con) {
        if (!products_tables_ready($con)) return products_not_ready();

        $body = read_json_body();
        $id = (int)($body['id'] ?? $_GET['id'] ?? 0);
        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'id is required'];
        }

        $fields = [];
        $params = [];
        $types = '';

        if (isset($body['code']) && trim((string)$body['code']) !== '') {
            $fields[] = 'code = ?';
            $params[] = generate_entity_code($con, 'product_categories', trim((string)$body['code']), 'category');
            $types .= 's';
        }
        if (product_image_mentioned($body)) {
            $image = process_image_input($body['image'] ?? null, 'products', $_FILES['image'] ?? null);
            $fields[] = 'image = ?'; $params[] = $image; $types .= 's';
        }
        if (isset($body['order_num'])) {
            $fields[] = 'order_num = ?'; $params[] = (int)$body['order_num']; $types .= 'i';
        }
        if (isset($body['is_active'])) {
            $fields[] = 'is_active = ?'; $params[] = (int)(bool)$body['is_active']; $types .= 'i';
        }

        if ($fields) {
            $stmt = mysqli_prepare($con, "UPDATE product_categories SET " . implode(', ', $fields) . " WHERE id = ?");
            if ($stmt) {
                $params[] = $id; $types .= 'i';
                mysqli_stmt_bind_param($stmt, $types, ...$params);
                if (!mysqli_stmt_execute($stmt)) {
                    return ['status' => 'error', 'message' => describe_db_write_error($con, 'تعذّر تعديل التصنيف')];
                }
            }
        }

        product_category_save_translations($con, $id, $body);

        return ['status' => 'success', 'message' => 'تم تعديل التصنيف بنجاح'];
    }
}

if (!function_exists('adminDeleteProductCategory')) {
    function adminDeleteProductCategory($con) {
        if (!products_tables_ready($con)) return products_not_ready();

        $body = read_json_body();
        $id = (int)($body['id'] ?? $_GET['id'] ?? 0);
        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'id is required'];
        }

        // The products survive: `product_category_id` is ON DELETE SET NULL, so deleting a
        // category empties its shelf rather than destroying the stock on it. Said plainly in the
        // response, because "deleted" on a screen listing 40 products should not leave the admin
        // guessing whether the 40 went with it.
        $countRes = @mysqli_query($con, "SELECT COUNT(*) AS c FROM products WHERE product_category_id = {$id}");
        $orphaned = $countRes ? (int)(mysqli_fetch_assoc($countRes)['c'] ?? 0) : 0;

        $stmt = mysqli_prepare($con, "DELETE FROM product_categories WHERE id = ?");
        mysqli_stmt_bind_param($stmt, "i", $id);
        if (!mysqli_stmt_execute($stmt)) {
            return ['status' => 'error', 'message' => describe_db_write_error($con, 'تعذّر حذف التصنيف')];
        }

        return [
            'status' => 'success',
            'message' => $orphaned > 0
                ? "تم حذف التصنيف. {$orphaned} منتجًا أصبح بلا تصنيف ولم يُحذف."
                : 'تم حذف التصنيف بنجاح',
            'data' => ['uncategorised_products' => $orphaned],
        ];
    }
}

/* ============================ المنتجات — Products ============================ */

if (!function_exists('product_image_mentioned')) {
    /**
     * Whether this request is actually saying something about the image.
     *
     * A form-data request carries an `image` row whether or not a file was picked: the upload
     * arrives as UPLOAD_ERR_NO_FILE and the text field as an empty string. Neither means "remove
     * the image", so neither may reach the UPDATE - otherwise editing a price from the dashboard
     * silently clears the picture.
     */
    function product_image_mentioned(array $body): bool {
        $upload = $_FILES['image'] ?? null;
        if (is_array($upload) && (int)($upload['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_NO_FILE) {
            return true;
        }

        if (!array_key_exists('image', $body)) {
            return false;
        }

        $raw = $body['image'];

        // An explicit null is a removal and does count. An empty string is a blank form row.
        return !(is_string($raw) && trim($raw) === '');
    }
}

if (!function_exists('product_file_size_label')) {
    /**
     * "2.4 MB", computed once here rather than in each client. Returns null for an absent size
     * rather than "0 B": a file whose size was never recorded is not a file of nothing.
     */
    function product_file_size_label($bytes): ?string {
        if ($bytes === null || $bytes === '' || (int)$bytes <= 0) {
            return null;
        }
        $bytes = (float)$bytes;
        $units = ['B', 'KB', 'MB', 'GB'];
        $i = 0;
        while ($bytes >= 1024 && $i < count($units) - 1) {
            $bytes /= 1024;
            $i++;
        }
        return ($i === 0 ? (int)$bytes : round($bytes, 1)) . ' ' . $units[$i];
    }
}

if (!function_exists('product_file_columns_ready')) {
    /** Migration 128. Until it has run a product simply has no attachment. */
    function product_file_columns_ready($con): bool {
        static $cached = null;
        if ($cached !== null) {
            return $cached;
        }
        $res = @mysqli_query($con, "SHOW COLUMNS FROM `products` LIKE 'file_path'");
        $cached = $res && mysqli_num_rows($res) > 0;
        return $cached;
    }
}

if (!function_exists('product_file_fields_from_body')) {
    /**
     * The attachment off the request, as [column => value] ready to splice into an INSERT or an
     * UPDATE. Returns an empty array when the body says nothing about a file, which is how a
     * product is saved without touching the one it already has.
     *
     * `file: null` is an explicit "remove it", and is told apart from "not mentioned" - the same
     * distinction the sale price and the stock make elsewhere in this file.
     */
    function product_file_fields_from_body($con, array $body, ?string $currentFilePath = null): array {
        if (!product_file_columns_ready($con)) {
            return [];
        }

        // A form-data request carries a `file` row whether or not the person picked anything, and
        // an empty one arrives as UPLOAD_ERR_NO_FILE. That is "nothing chosen", not "a file that
        // failed" - treating it as the latter answers every ordinary save with a bogus "this file
        // type is not allowed", and treating it as a removal would delete the attachment each
        // time the price was edited from the dashboard.
        $upload = $_FILES['file'] ?? $_FILES['product_file'] ?? null;
        if (is_array($upload) && (int)($upload['error'] ?? UPLOAD_ERR_NO_FILE) === UPLOAD_ERR_NO_FILE) {
            $upload = null;
        }

        $rawGiven = array_key_exists('file', $body) || array_key_exists('file_path', $body);
        $raw = $body['file'] ?? $body['file_path'] ?? null;

        // The same for the text half: form-data sends an empty string for a row left blank, and
        // an empty string is not a request to clear the file. Only an explicit JSON null is.
        if ($rawGiven && is_string($raw) && trim($raw) === '') {
            $rawGiven = false;
            $raw = null;
        }

        if (!$rawGiven && $upload === null) {
            return [];
        }

        // The edit form prefills the field with the file's stored path, so an admin who changes
        // only the price posts that same path straight back. Treated as "unchanged" rather than
        // as a new file: re-processing it would derive the name from the path and overwrite
        // "المخطط النهائي.dwg" with "file_6af58740033735.38251147.dwg", which is the name on disk
        // and not a name anybody chose.
        if (empty($upload) && is_string($raw) && $currentFilePath !== null && trim($raw) === $currentFilePath) {
            return [];
        }

        // Explicitly cleared.
        if ($raw === null && empty($upload)) {
            return [
                'file_path' => null,
                'file_name' => null,
                'file_extension' => null,
                'file_size' => null,
            ];
        }

        $result = process_any_file_input($raw, 'products', $upload, $body['file_name'] ?? null);
        if ($result === null) {
            return ['__error' => 'نوع الملف غير مسموح، أو تعذّر رفعه. الملفات التنفيذية مرفوضة.'];
        }

        return [
            'file_path' => $result['path'],
            'file_name' => $result['name'],
            'file_extension' => $result['extension'] !== '' ? $result['extension'] : null,
            'file_size' => $result['size'] > 0 ? $result['size'] : null,
        ];
    }
}

if (!function_exists('product_row')) {
    /**
     * One product in the shape both the admin list and the store use. `effective_price` is
     * computed here rather than left to each client: a sale price that three screens each decide
     * how to apply is a sale price three screens eventually disagree about.
     */
    function product_row($con, array $row, ?int $langId = null): array {
        $id = (int)$row['id'];

        $price = (float)$row['price'];
        $salePrice = $row['sale_price'] !== null ? (float)$row['sale_price'] : null;
        $onSale = $salePrice !== null && $salePrice < $price;

        $stock = $row['stock'] !== null ? (int)$row['stock'] : null;

        $out = [
            'id' => $id,
            'product_category_id' => $row['product_category_id'] !== null ? (int)$row['product_category_id'] : null,
            'slug' => $row['slug'],
            'sku' => $row['sku'] ?? null,
            'price' => round($price, 2),
            'sale_price' => $salePrice !== null ? round($salePrice, 2) : null,
            'effective_price' => round($onSale ? $salePrice : $price, 2),
            'is_on_sale' => $onSale,
            'discount_percent' => $onSale && $price > 0 ? (int)round((($price - $salePrice) / $price) * 100) : 0,
            'currency' => $row['currency'] ?? 'EGP',
            // NULL stock is "not tracked", which must not read as "sold out".
            'stock' => $stock,
            'in_stock' => $stock === null || $stock > 0,
            'is_stock_tracked' => $stock !== null,
            'image' => $row['image'] ?? null,
            'gallery' => $row['gallery'] ? (json_decode($row['gallery'], true) ?: []) : [],
            // The attachment. `file_path` is included here because this is the admin's shape;
            // the store strips it unless the product says the file is public (see
            // store_item_from_product), since a digital product's file IS the thing being sold.
            'has_file' => !empty($row['file_path'] ?? null),
            'file_path' => $row['file_path'] ?? null,
            'file_name' => $row['file_name'] ?? null,
            'file_extension' => $row['file_extension'] ?? null,
            'file_size' => isset($row['file_size']) && $row['file_size'] !== null ? (int)$row['file_size'] : null,
            'file_size_label' => product_file_size_label($row['file_size'] ?? null),
            'file_is_public' => (int)($row['file_is_public'] ?? 0) === 1,
            'is_active' => (int)($row['is_active'] ?? 1),
            'show_on_website' => (int)($row['show_on_website'] ?? 1),
            'order_num' => (int)($row['order_num'] ?? 1),
            'created_by_type' => $row['created_by_type'] ?? 'admin',
            'created_by_id' => $row['created_by_id'] !== null ? (int)$row['created_by_id'] : null,
            'created_at' => $row['created_at'] ?? null,
            'translations' => [],
        ];

        $tStmt = mysqli_prepare($con, "
            SELECT t.language_id, l.code AS language_code, t.name, t.description
            FROM products_translations t
            JOIN languages l ON l.id = t.language_id
            WHERE t.product_id = ?
        ");
        if ($tStmt) {
            mysqli_stmt_bind_param($tStmt, "i", $id);
            mysqli_stmt_execute($tStmt);
            $tRes = mysqli_stmt_get_result($tStmt);
            while ($t = mysqli_fetch_assoc($tRes)) {
                $t['language_id'] = (int)$t['language_id'];
                if ($t['language_code'] === 'ar') { $out['name_ar'] = $t['name']; $out['description_ar'] = $t['description']; }
                if ($t['language_code'] === 'en') { $out['name_en'] = $t['name']; $out['description_en'] = $t['description']; }
                $out['translations'][] = $t;
            }
        }

        $out['name'] = $out['name_ar'] ?? ($out['name_en'] ?? $out['slug']);
        $out['description'] = $out['description_ar'] ?? ($out['description_en'] ?? null);

        if ($out['product_category_id']) {
            $cRes = @mysqli_query($con, "
                SELECT c.id, c.code,
                       (SELECT t.name FROM product_categories_translations t
                         WHERE t.product_category_id = c.id ORDER BY t.id ASC LIMIT 1) AS name
                FROM product_categories c WHERE c.id = " . $out['product_category_id'] . " LIMIT 1
            ");
            $out['category'] = $cRes ? (mysqli_fetch_assoc($cRes) ?: null) : null;
        } else {
            $out['category'] = null;
        }

        return format_response_images($out);
    }
}

if (!function_exists('product_filters_sql')) {
    /**
     * The filters shared by the admin list and the store, so the two cannot disagree about what
     * `category_id` or `search` mean. `$publicOnly` adds the two conditions a shopper's view
     * needs and an admin's must not have.
     */
    function product_filters_sql($con, bool $publicOnly): array {
        $where = $publicOnly ? ["p.is_active = 1", "p.show_on_website = 1"] : [];

        $categoryId = (int)($_GET['category_id'] ?? $_GET['product_category_id'] ?? 0);
        if ($categoryId > 0) {
            $where[] = "p.product_category_id = {$categoryId}";
        }

        $search = trim($_GET['search'] ?? $_GET['q'] ?? '');
        if ($search !== '') {
            $pattern = '%' . mysqli_real_escape_string($con, $search) . '%';
            $where[] = "(p.slug LIKE '{$pattern}' OR p.sku LIKE '{$pattern}'
                         OR EXISTS (SELECT 1 FROM products_translations t
                                    WHERE t.product_id = p.id AND (t.name LIKE '{$pattern}' OR t.description LIKE '{$pattern}')))";
        }

        if (isset($_GET['min_price']) && $_GET['min_price'] !== '') {
            $where[] = "COALESCE(p.sale_price, p.price) >= " . (float)$_GET['min_price'];
        }
        if (isset($_GET['max_price']) && $_GET['max_price'] !== '') {
            $where[] = "COALESCE(p.sale_price, p.price) <= " . (float)$_GET['max_price'];
        }
        if (!empty($_GET['in_stock'])) {
            $where[] = "(p.stock IS NULL OR p.stock > 0)";
        }
        if (!$publicOnly && isset($_GET['is_active']) && $_GET['is_active'] !== '') {
            $where[] = "p.is_active = " . (int)$_GET['is_active'];
        }

        return $where;
    }
}

if (!function_exists('adminListProducts')) {
    function adminListProducts($con) {
        if (!products_tables_ready($con)) {
            return build_paginated_response([], 1, 10, 0);
        }

        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 20)));
        $offset = ($page - 1) * $limit;

        $where = product_filters_sql($con, false);
        $whereSql = $where ? 'WHERE ' . implode(' AND ', $where) : '';

        $totalRes = @mysqli_query($con, "SELECT COUNT(*) AS total FROM products p {$whereSql}");
        $total = $totalRes ? (int)(mysqli_fetch_assoc($totalRes)['total'] ?? 0) : 0;

        $statRes = @mysqli_query($con, "
            SELECT COUNT(*) AS total,
                   COALESCE(SUM(is_active = 1), 0) AS active_count,
                   COALESCE(SUM(is_active = 0), 0) AS inactive_count,
                   COALESCE(SUM(stock IS NOT NULL AND stock <= 0), 0) AS out_of_stock_count
            FROM products
        ");
        $stat = $statRes ? (mysqli_fetch_assoc($statRes) ?: []) : [];

        $res = @mysqli_query($con, "
            SELECT p.* FROM products p
            {$whereSql}
            ORDER BY p.order_num ASC, p.id DESC
            LIMIT {$limit} OFFSET {$offset}
        ");

        $rows = [];
        if ($res) {
            while ($row = mysqli_fetch_assoc($res)) {
                $rows[] = product_row($con, $row);
            }
        }

        return build_paginated_response($rows, $page, $limit, $total, [
            'total_count' => (int)($stat['total'] ?? 0),
            'active_count' => (int)($stat['active_count'] ?? 0),
            'inactive_count' => (int)($stat['inactive_count'] ?? 0),
            'out_of_stock_count' => (int)($stat['out_of_stock_count'] ?? 0),
        ]);
    }
}

if (!function_exists('adminGetProduct')) {
    function adminGetProduct($con) {
        if (!products_tables_ready($con)) return products_not_ready();

        $id = (int)($_GET['id'] ?? read_json_body()['id'] ?? 0);
        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'id is required'];
        }

        $stmt = mysqli_prepare($con, "SELECT * FROM products WHERE id = ? LIMIT 1");
        mysqli_stmt_bind_param($stmt, "i", $id);
        mysqli_stmt_execute($stmt);
        $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));

        if (!$row) {
            return ['status' => 'error', 'message' => 'المنتج غير موجود'];
        }

        return ['status' => 'success', 'data' => product_row($con, $row)];
    }
}

if (!function_exists('product_save_translations')) {
    function product_save_translations($con, int $productId, array $body): void {
        foreach (product_translation_pairs($con, $body) as $langId => $t) {
            $stmt = mysqli_prepare($con, "
                INSERT INTO products_translations (product_id, language_id, name, description)
                VALUES (?, ?, ?, ?)
                ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description)
            ");
            if (!$stmt) continue;
            mysqli_stmt_bind_param($stmt, "iiss", $productId, $langId, $t['name'], $t['description']);
            mysqli_stmt_execute($stmt);
        }
    }
}

if (!function_exists('product_price_input')) {
    /**
     * A price off the request. Returns false on a value that is not a number, so a typo is a
     * refusal rather than a silent zero - and null on an absent or blank one, which is how
     * "no sale price" is said.
     */
    function product_price_input(array $body, string $key) {
        if (!array_key_exists($key, $body)) {
            return null;
        }
        $raw = $body[$key];
        if ($raw === null || trim((string)$raw) === '') {
            return null;
        }
        if (!is_numeric($raw)) {
            return false;
        }
        return round((float)$raw, 2);
    }
}

if (!function_exists('product_apply_file_fields')) {
    /**
     * Writes the attachment columns, plus `file_is_public` when the body mentions it. Shared by
     * create and update so the two cannot drift about what clearing a file means.
     */
    function product_apply_file_fields($con, int $productId, array $fileFields, array $body): void {
        if (!product_file_columns_ready($con)) {
            return;
        }

        $sets = [];
        $params = [];
        $types = '';

        foreach ($fileFields as $column => $value) {
            if ($column === '__error') continue;
            $sets[] = "`{$column}` = ?";
            $params[] = $value;
            $types .= ($column === 'file_size') ? 'i' : 's';
        }

        if (array_key_exists('file_is_public', $body)) {
            $sets[] = "`file_is_public` = ?";
            $params[] = (int)(bool)$body['file_is_public'];
            $types .= 'i';
        }

        if (!$sets) {
            return;
        }

        $stmt = mysqli_prepare($con, "UPDATE products SET " . implode(', ', $sets) . " WHERE id = ?");
        if (!$stmt) {
            return;
        }
        $params[] = $productId;
        $types .= 'i';
        mysqli_stmt_bind_param($stmt, $types, ...$params);
        mysqli_stmt_execute($stmt);
    }
}

if (!function_exists('adminCreateProduct')) {
    function adminCreateProduct($con, $adminData = null) {
        if (!products_tables_ready($con)) return products_not_ready();

        $body = read_json_body();
        $nameAr = trim((string)($body['name_ar'] ?? $body['name'] ?? ''));
        $nameEn = trim((string)($body['name_en'] ?? ''));

        if ($nameAr === '' && $nameEn === '') {
            return ['status' => 'error', 'message' => 'اسم المنتج مطلوب (name_ar أو name_en)'];
        }

        $price = product_price_input($body, 'price');
        if ($price === false) {
            return ['status' => 'error', 'message' => 'السعر غير صالح'];
        }
        $price = $price ?? 0.00;

        $salePrice = product_price_input($body, 'sale_price');
        if ($salePrice === false) {
            return ['status' => 'error', 'message' => 'سعر العرض غير صالح'];
        }
        if ($salePrice !== null && $salePrice > $price) {
            return ['status' => 'error', 'message' => 'سعر العرض لا يمكن أن يتجاوز السعر الأصلي'];
        }

        $categoryId = isset($body['product_category_id']) ? (int)$body['product_category_id']
            : (isset($body['category_id']) ? (int)$body['category_id'] : 0);
        if ($categoryId > 0) {
            $chk = @mysqli_query($con, "SELECT id FROM product_categories WHERE id = {$categoryId} LIMIT 1");
            if (!$chk || !mysqli_num_rows($chk)) {
                return ['status' => 'error', 'message' => 'التصنيف المختار غير موجود'];
            }
        }

        $slug = generate_unique_slug($con, 'products', trim((string)($body['slug'] ?? '')) !== ''
            ? trim((string)$body['slug'])
            : ($nameEn !== '' ? $nameEn : $nameAr), 'product');

        $sku = trim((string)($body['sku'] ?? '')) ?: null;
        $currency = strtoupper(trim((string)($body['currency'] ?? 'EGP'))) ?: 'EGP';
        // Absent means "not tracked"; an explicit 0 means "out of stock". They are kept apart.
        $stock = array_key_exists('stock', $body) && $body['stock'] !== null && trim((string)$body['stock']) !== ''
            ? (int)$body['stock']
            : null;
        $image = process_image_input($body['image'] ?? null, 'products', $_FILES['image'] ?? null);
        $gallery = isset($body['gallery']) && is_array($body['gallery'])
            ? json_encode(array_values($body['gallery']), JSON_UNESCAPED_UNICODE)
            : null;
        $isActive = isset($body['is_active']) ? (int)(bool)$body['is_active'] : 1;
        $showOnWebsite = isset($body['show_on_website']) ? (int)(bool)$body['show_on_website'] : 1;
        $orderNum = isset($body['order_num']) ? (int)$body['order_num'] : 1;
        $adminId = is_array($adminData) ? (int)($adminData['id'] ?? 0) : 0;
        $createdById = $adminId > 0 ? $adminId : null;

        $stmt = mysqli_prepare($con, "
            INSERT INTO products
                (product_category_id, slug, sku, price, sale_price, currency, stock, image, gallery,
                 is_active, show_on_website, order_num, created_by_type, created_by_id)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'admin', ?)
        ");
        if (!$stmt) {
            return ['status' => 'error', 'message' => describe_db_write_error($con, 'تعذّر إنشاء المنتج')];
        }

        $categoryParam = $categoryId > 0 ? $categoryId : null;
        mysqli_stmt_bind_param(
            $stmt, "issddsissiiii",
            $categoryParam, $slug, $sku, $price, $salePrice, $currency, $stock, $image, $gallery,
            $isActive, $showOnWebsite, $orderNum, $createdById
        );
        if (!mysqli_stmt_execute($stmt)) {
            return ['status' => 'error', 'message' => describe_db_write_error($con, 'تعذّر إنشاء المنتج')];
        }

        $productId = mysqli_insert_id($con);
        product_save_translations($con, $productId, $body);

        // Written as a second statement rather than spliced into the INSERT: the columns only
        // exist once migration 128 has run, and the product must still be creatable before then.
        $fileWarning = null;
        $fileFields = product_file_fields_from_body($con, $body);
        if (isset($fileFields['__error'])) {
            $fileWarning = $fileFields['__error'];
        } elseif ($fileFields) {
            product_apply_file_fields($con, $productId, $fileFields, $body);
        }

        return [
            'status' => 'success',
            // The product was created either way; saying so plainly beats a bare success that
            // leaves an owner wondering where their attachment went.
            'message' => $fileWarning ? 'تم إنشاء المنتج، لكن ' . $fileWarning : 'تم إنشاء المنتج بنجاح',
            'data' => ['id' => $productId, 'slug' => $slug, 'file_warning' => $fileWarning],
        ];
    }
}

if (!function_exists('adminUpdateProduct')) {
    function adminUpdateProduct($con) {
        if (!products_tables_ready($con)) return products_not_ready();

        $body = read_json_body();
        $id = (int)($body['id'] ?? $_GET['id'] ?? 0);
        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'id is required'];
        }

        $currentCols = product_file_columns_ready($con) ? "price, sale_price, file_path" : "price, sale_price";
        $currentRes = @mysqli_query($con, "SELECT {$currentCols} FROM products WHERE id = {$id} LIMIT 1");
        $current = $currentRes ? mysqli_fetch_assoc($currentRes) : null;
        if (!$current) {
            return ['status' => 'error', 'message' => 'المنتج غير موجود'];
        }

        $fields = [];
        $params = [];
        $types = '';

        $price = product_price_input($body, 'price');
        if ($price === false) {
            return ['status' => 'error', 'message' => 'السعر غير صالح'];
        }
        if ($price !== null) {
            $fields[] = 'price = ?'; $params[] = $price; $types .= 'd';
        }

        // Both prices are resolved to what they WILL be after this update, then checked against
        // each other once - rather than checking only the field that happens to be in the body.
        //
        // Checking only the body let `{"price": 300}` through on a product priced 450 with a 360
        // sale, leaving 300 with a sale price of 360 above it: a product whose "discount" costs
        // more than the product. Lowering a price is the ordinary way that happens, and it sends
        // no sale_price at all.
        $salePriceGiven = array_key_exists('sale_price', $body);
        $salePrice = null;
        if ($salePriceGiven) {
            $salePrice = product_price_input($body, 'sale_price');
            if ($salePrice === false) {
                return ['status' => 'error', 'message' => 'سعر العرض غير صالح'];
            }
        } elseif ($current['sale_price'] !== null) {
            $salePrice = (float)$current['sale_price'];
        }

        $finalPrice = $price !== null ? $price : (float)$current['price'];
        if ($salePrice !== null && $salePrice > $finalPrice) {
            return [
                'status' => 'error',
                'message' => $salePriceGiven
                    ? 'سعر العرض لا يمكن أن يتجاوز السعر الأصلي'
                    : 'السعر الجديد أقل من سعر العرض الحالي (' . $salePrice . '). عدّل سعر العرض أو احذفه في نفس الطلب.',
            ];
        }

        if ($salePriceGiven) {
            $fields[] = 'sale_price = ?'; $params[] = $salePrice; $types .= 'd';
        }

        if (array_key_exists('product_category_id', $body) || array_key_exists('category_id', $body)) {
            $categoryId = (int)($body['product_category_id'] ?? $body['category_id'] ?? 0);
            if ($categoryId > 0) {
                $chk = @mysqli_query($con, "SELECT id FROM product_categories WHERE id = {$categoryId} LIMIT 1");
                if (!$chk || !mysqli_num_rows($chk)) {
                    return ['status' => 'error', 'message' => 'التصنيف المختار غير موجود'];
                }
            }
            $fields[] = 'product_category_id = ?';
            $params[] = $categoryId > 0 ? $categoryId : null;
            $types .= 'i';
        }

        if (isset($body['slug']) && trim((string)$body['slug']) !== '') {
            $fields[] = 'slug = ?';
            $params[] = generate_unique_slug($con, 'products', trim((string)$body['slug']), 'product', $id);
            $types .= 's';
        }
        if (array_key_exists('sku', $body)) {
            $fields[] = 'sku = ?'; $params[] = trim((string)$body['sku']) ?: null; $types .= 's';
        }
        if (isset($body['currency'])) {
            $fields[] = 'currency = ?'; $params[] = strtoupper(trim((string)$body['currency'])); $types .= 's';
        }
        if (array_key_exists('stock', $body)) {
            $stock = ($body['stock'] === null || trim((string)$body['stock']) === '') ? null : (int)$body['stock'];
            $fields[] = 'stock = ?'; $params[] = $stock; $types .= 'i';
        }
        if (product_image_mentioned($body)) {
            $image = process_image_input($body['image'] ?? null, 'products', $_FILES['image'] ?? null);
            $fields[] = 'image = ?'; $params[] = $image; $types .= 's';
        }
        if (isset($body['gallery']) && is_array($body['gallery'])) {
            $fields[] = 'gallery = ?';
            $params[] = json_encode(array_values($body['gallery']), JSON_UNESCAPED_UNICODE);
            $types .= 's';
        }
        if (isset($body['is_active'])) {
            $fields[] = 'is_active = ?'; $params[] = (int)(bool)$body['is_active']; $types .= 'i';
        }
        if (isset($body['show_on_website'])) {
            $fields[] = 'show_on_website = ?'; $params[] = (int)(bool)$body['show_on_website']; $types .= 'i';
        }
        if (isset($body['order_num'])) {
            $fields[] = 'order_num = ?'; $params[] = (int)$body['order_num']; $types .= 'i';
        }

        if ($fields) {
            $stmt = mysqli_prepare($con, "UPDATE products SET " . implode(', ', $fields) . " WHERE id = ?");
            if (!$stmt) {
                return ['status' => 'error', 'message' => describe_db_write_error($con, 'تعذّر تعديل المنتج')];
            }
            $params[] = $id; $types .= 'i';
            mysqli_stmt_bind_param($stmt, $types, ...$params);
            if (!mysqli_stmt_execute($stmt)) {
                return ['status' => 'error', 'message' => describe_db_write_error($con, 'تعذّر تعديل المنتج')];
            }
        }

        product_save_translations($con, $id, $body);

        $fileWarning = null;
        $fileFields = product_file_fields_from_body($con, $body, $current['file_path'] ?? null);
        if (isset($fileFields['__error'])) {
            $fileWarning = $fileFields['__error'];
        } elseif ($fileFields || array_key_exists('file_is_public', $body)) {
            product_apply_file_fields($con, $id, $fileFields, $body);
        }

        return [
            'status' => 'success',
            'message' => $fileWarning ? 'تم تعديل المنتج، لكن ' . $fileWarning : 'تم تعديل المنتج بنجاح',
            'data' => ['file_warning' => $fileWarning],
        ];
    }
}

if (!function_exists('adminDeleteProduct')) {
    function adminDeleteProduct($con) {
        if (!products_tables_ready($con)) return products_not_ready();

        $body = read_json_body();
        $id = (int)($body['id'] ?? $_GET['id'] ?? 0);
        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'id is required'];
        }

        $stmt = mysqli_prepare($con, "DELETE FROM products WHERE id = ?");
        mysqli_stmt_bind_param($stmt, "i", $id);
        if (!mysqli_stmt_execute($stmt)) {
            return ['status' => 'error', 'message' => describe_db_write_error($con, 'تعذّر حذف المنتج')];
        }

        return ['status' => 'success', 'message' => 'تم حذف المنتج بنجاح'];
    }
}

if (!function_exists('adminToggleProductWebsiteVisibility')) {
    /** The same one-click toggle courses and books have on the website-visibility screen. */
    function adminToggleProductWebsiteVisibility($con) {
        if (!products_tables_ready($con)) return products_not_ready();

        $body = read_json_body();
        $id = (int)($body['id'] ?? $_GET['id'] ?? 0);
        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'id is required'];
        }

        if (!@mysqli_query($con, "UPDATE products SET show_on_website = IF(show_on_website = 1, 0, 1) WHERE id = {$id}")) {
            return ['status' => 'error', 'message' => describe_db_write_error($con, 'تعذّر تغيير حالة الظهور')];
        }

        $res = @mysqli_query($con, "SELECT show_on_website FROM products WHERE id = {$id} LIMIT 1");
        $row = $res ? mysqli_fetch_assoc($res) : null;

        return [
            'status' => 'success',
            'message' => 'تم تحديث حالة الظهور بالمتجر',
            'data' => ['show_on_website' => (int)($row['show_on_website'] ?? 0)],
        ];
    }
}
