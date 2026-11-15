<?php
/**
 * The store, after migration 131: every item the store sells is a row of `products`.
 *
 * Before that migration the store was the standalone rows of `course_books` (no course, no unit),
 * and a second, newer `products` table that could not be bought. Both are one thing now. A moved
 * book kept its id, so every table that already pointed at a store item by number still does:
 *
 *   student_book_subscriptions.book_id      who owns which store item
 *   student_book_purchase_requests.book_id  purchase requests
 *   student_subscription_books.book_id      store items granted inside a subscription
 *   book_teachers.book_id                   teachers assigned to a store item
 *   discount_code_books.book_id             discount codes that name a store item
 *   student_book_progress.book_id           reading progress (lesson files share this table)
 *   item_country_prices  (item_type 'book') country prices
 *   payment_transactions, offline payments, manual sales  (item_type 'book')
 *
 * Those columns are still called `book_id` and the money tables still say `item_type = 'book'`:
 * renaming them would break every request already sent by the mobile app and every row already
 * written. Read `'book'` in those places as "store item". A client may send `item_type =
 * 'product'` for the same thing; store_item_type() maps it.
 *
 * `course_books` now holds only files that belong to a course or a unit. Its ids continue from
 * 1,000,000, so a lesson file and a product never share a number - which is what lets an
 * endpoint that takes "a book id" (opening a file, reading progress) look in products first and
 * fall back to course_books.
 */

require_once __DIR__ . '/functions.php';
require_once __DIR__ . '/language.php';
require_once __DIR__ . '/upload.php';
require_once __DIR__ . '/app_settings.php';

if (!function_exists('store_item_type')) {
    /** 'product' and 'book' name the same thing in a request: a store item. Stored as 'book'. */
    function store_item_type(string $type): string {
        $type = strtolower(trim($type));
        return $type === 'product' ? 'book' : $type;
    }
}

if (!function_exists('store_products_ready')) {
    /** True once migration 131 has run: `products` carries the columns a book had. */
    function store_products_ready($con): bool {
        static $ready = null;
        if ($ready !== null) return $ready;
        $res = @mysqli_query($con, "SHOW COLUMNS FROM `products` LIKE 'legacy_book_id'");
        $ready = $res && mysqli_num_rows($res) > 0;
        return $ready;
    }
}

if (!function_exists('store_item_find')) {
    /** One store item's raw `products` row, or null. */
    function store_item_find($con, int $id, bool $activeOnly = false): ?array {
        if ($id <= 0) return null;
        $sql = "SELECT * FROM products WHERE id = ?" . ($activeOnly ? " AND is_active = 1" : "") . " LIMIT 1";
        $stmt = mysqli_prepare($con, $sql);
        if (!$stmt) return null;
        mysqli_stmt_bind_param($stmt, "i", $id);
        mysqli_stmt_execute($stmt);
        $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));
        return $row ?: null;
    }
}

if (!function_exists('store_items_find')) {
    /** Several raw rows at once, keyed by id. Unknown ids are simply absent. */
    function store_items_find($con, array $ids): array {
        $ids = array_values(array_unique(array_filter(array_map('intval', $ids), fn($i) => $i > 0)));
        if (!$ids) return [];
        $res = @mysqli_query($con, "SELECT * FROM products WHERE id IN (" . implode(',', $ids) . ")");
        $out = [];
        if ($res) {
            while ($row = mysqli_fetch_assoc($res)) {
                $out[(int)$row['id']] = $row;
            }
        }
        return $out;
    }
}

if (!function_exists('store_item_names')) {
    /**
     * name/description of each id in the request's language, falling back to any language and
     * then to the slug, so a list never prints an empty title.
     *
     * @return array<int, array{name: string, description: ?string}>
     */
    function store_item_names($con, array $ids, ?int $langId = null): array {
        $ids = array_values(array_unique(array_filter(array_map('intval', $ids), fn($i) => $i > 0)));
        if (!$ids) return [];
        if ($langId === null) {
            $langId = (int)(get_language_info($con)['id'] ?? 1);
        }
        $list = implode(',', $ids);
        $out = [];
        $res = @mysqli_query($con, "
            SELECT p.id, p.slug,
                   COALESCE(
                       (SELECT t.name FROM products_translations t WHERE t.product_id = p.id AND t.language_id = {$langId} LIMIT 1),
                       (SELECT t.name FROM products_translations t WHERE t.product_id = p.id ORDER BY t.id ASC LIMIT 1),
                       p.slug) AS name,
                   COALESCE(
                       (SELECT t.description FROM products_translations t WHERE t.product_id = p.id AND t.language_id = {$langId} LIMIT 1),
                       (SELECT t.description FROM products_translations t WHERE t.product_id = p.id ORDER BY t.id ASC LIMIT 1)) AS description
            FROM products p WHERE p.id IN ({$list})
        ");
        if ($res) {
            while ($row = mysqli_fetch_assoc($res)) {
                $out[(int)$row['id']] = ['name' => (string)$row['name'], 'description' => $row['description']];
            }
        }
        return $out;
    }
}

if (!function_exists('store_item_name')) {
    function store_item_name($con, int $id, ?int $langId = null): string {
        return store_item_names($con, [$id], $langId)[$id]['name'] ?? '';
    }
}

if (!function_exists('store_name_sql')) {
    /**
     * A SQL expression for a store item's name in the request's language, for a query that joins
     * or selects products under the alias `$alias`. The same fallback as store_item_names().
     */
    function store_name_sql(int $langId, string $alias = 'p'): string {
        return "COALESCE(
            (SELECT pt.name FROM products_translations pt WHERE pt.product_id = {$alias}.id AND pt.language_id = {$langId} LIMIT 1),
            (SELECT pt.name FROM products_translations pt WHERE pt.product_id = {$alias}.id ORDER BY pt.id ASC LIMIT 1),
            {$alias}.slug)";
    }
}

if (!function_exists('store_item_file_type')) {
    /**
     * What a book row used to carry in `file_type`: 'physical' for something handed over, or the
     * file's extension for a digital item. Clients branch on exactly this value.
     */
    function store_item_file_type(array $p): string {
        if (($p['product_type'] ?? 'physical') === 'physical') {
            return 'physical';
        }
        $ext = strtolower(trim((string)($p['file_extension'] ?? '')));
        return $ext !== '' ? $ext : 'pdf';
    }
}

if (!function_exists('store_item_as_book')) {
    /**
     * A product in the shape a book row had, for every endpoint whose readers were built on books
     * (the mobile app above all). Every book field is there with its old meaning; the product's
     * own fields ride along beside them, so a newer client can use them.
     *
     * The file path is included as stored. Endpoints that serve students must still apply the
     * same rules they applied to a book (a view-only item hides `file_path` and `link`).
     */
    function store_item_as_book($con, array $p, ?array $names = null, ?int $langId = null): array {
        $id = (int)$p['id'];
        if ($names === null) {
            $names = store_item_names($con, [$id], $langId)[$id] ?? ['name' => (string)($p['slug'] ?? ''), 'description' => null];
        }
        $isPriced = $p['price'] !== null;
        $salePrice = $isPriced && isset($p['sale_price']) && $p['sale_price'] !== null ? (float)$p['sale_price'] : null;
        $stock = isset($p['stock']) && $p['stock'] !== null ? (int)$p['stock'] : null;
        $fileType = store_item_file_type($p);

        return [
            // --- the book shape, unchanged in meaning ---
            'id' => $id,
            'unit_id' => null,
            'course_id' => null,
            'subject_id' => isset($p['subject_id']) && $p['subject_id'] !== null ? (int)$p['subject_id'] : null,
            'file_type' => $fileType,
            'category' => $p['book_category'] ?? 'summary',
            'extension' => $fileType === 'physical' ? null : $fileType,
            'link' => $p['link'] ?? null,
            'file_path' => $p['file_path'] ?? null,
            'cover_image' => $p['image'] ?? null,
            'allow_download' => (int)($p['allow_download'] ?? 1),
            'title' => $names['name'],
            'description' => $names['description'],
            'price' => (float)($p['price'] ?? 0),
            'is_priced' => $isPriced,
            'is_active' => (int)($p['is_active'] ?? 1),
            'show_on_website' => (int)($p['show_on_website'] ?? 1),
            'order_num' => (int)($p['order_num'] ?? 1),
            'created_by_type' => $p['created_by_type'] ?? 'admin',
            'created_by_id' => isset($p['created_by_id']) && $p['created_by_id'] !== null ? (int)$p['created_by_id'] : null,
            'created_at' => $p['created_at'] ?? null,
            // --- the product's own fields ---
            'item_type' => 'product',
            'product_type' => $p['product_type'] ?? 'physical',
            'product_category_id' => isset($p['product_category_id']) && $p['product_category_id'] !== null ? (int)$p['product_category_id'] : null,
            'slug' => $p['slug'] ?? null,
            'sku' => $p['sku'] ?? null,
            'sale_price' => $salePrice,
            'is_on_sale' => $salePrice !== null && $salePrice < (float)($p['price'] ?? 0),
            'stock' => $stock,
            'in_stock' => $stock === null || $stock > 0,
            'image' => $p['image'] ?? null,
            'gallery' => !empty($p['gallery']) ? (json_decode($p['gallery'], true) ?: []) : [],
            'file_name' => $p['file_name'] ?? null,
            'file_size' => isset($p['file_size']) && $p['file_size'] !== null ? (int)$p['file_size'] : null,
        ];
    }
}

if (!function_exists('store_item_owner_teacher_ids')) {
    /**
     * The teachers a store item belongs to: its creator when that was a teacher, plus any teacher
     * assigned to it in `book_teachers`. The same rule teacher_ownership.php applied to books.
     */
    function store_item_owner_teacher_ids($con, int $id): array {
        $ids = [];
        $p = store_item_find($con, $id);
        if ($p && ($p['created_by_type'] ?? '') === 'teacher' && !empty($p['created_by_id'])) {
            $ids[] = (int)$p['created_by_id'];
        }
        $res = @mysqli_query($con, "SELECT teacher_id FROM book_teachers WHERE book_id = " . (int)$id . " AND is_active = 1");
        if ($res) {
            while ($r = mysqli_fetch_assoc($res)) $ids[] = (int)$r['teacher_id'];
        }
        return array_values(array_unique($ids));
    }
}

if (!function_exists('store_item_effective_price')) {
    /**
     * The base price a buyer of this item pays before any country price or discount: the sale
     * price while the item is on sale, otherwise the price. Null means "no price" - not for sale.
     */
    function store_item_effective_price(array $p): ?float {
        if (!array_key_exists('price', $p) || $p['price'] === null) return null;
        $price = (float)$p['price'];
        $sale = isset($p['sale_price']) && $p['sale_price'] !== null ? (float)$p['sale_price'] : null;
        return ($sale !== null && $sale < $price) ? $sale : $price;
    }
}

if (!function_exists('store_item_sale_block')) {
    /**
     * Why this item cannot be sold right now, or null if it can. Shared by every purchase and
     * grant path so they refuse the same things with the same words.
     *
     * @return array{status:string,message:string,error_code:string}|null
     */
    function store_item_sale_block($con, ?array $p): ?array {
        if (!$p || (int)($p['is_active'] ?? 0) !== 1) {
            return ['status' => 'error', 'error_code' => 'not_found',
                    'message' => app_text($con, 'المنتج غير موجود أو غير متاح.', 'This product does not exist or is not available.')];
        }
        if (($p['product_type'] ?? 'physical') === 'physical' && isset($p['stock']) && $p['stock'] !== null && (int)$p['stock'] <= 0) {
            return ['status' => 'error', 'error_code' => 'out_of_stock',
                    'message' => app_text($con, 'المنتج نفد من المخزون.', 'This product is out of stock.')];
        }
        return null;
    }
}

if (!function_exists('store_item_take_stock')) {
    /**
     * One unit of tracked stock leaves with a granted purchase. Untracked stock (NULL) is left
     * alone, and the count never goes below 0. Call it once per grant, after the grant succeeded.
     */
    function store_item_take_stock($con, int $id): void {
        if ($id <= 0) return;
        @mysqli_query($con, "UPDATE products SET stock = stock - 1 WHERE id = {$id} AND stock IS NOT NULL AND stock > 0");
    }
}
