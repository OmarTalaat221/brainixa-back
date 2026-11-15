<?php
/**
 * المتجر — the shop front.
 *
 * Until migration 131 the shelf was merged here from two tables: standalone `course_books` rows
 * (item_type 'book') and `products` (item_type 'product'). Every standalone book has since become
 * a product with the same id, so the shelf is one table now and every entry is `item_type =
 * 'product'`, with an id that is unique on its own. Nothing that was on the shelf left it: a
 * former book is listed here exactly as long as it was listed before (see store_visible_sql).
 *
 * Each entry keeps the product shape and also carries what a book card needed - whether the
 * student owns it, the standing purchase request, `file_type`, `subject_id` - because every item
 * on the shelf can now be bought and owned the way a book was.
 *
 * Prices are country prices (item_type 'book' in item_country_prices, meaning "store item"), on
 * top of the sale price while an item is on sale.
 */

require_once __DIR__ . '/../../helpers/functions.php';
require_once __DIR__ . '/../../helpers/language.php';
require_once __DIR__ . '/../../helpers/upload.php';
require_once __DIR__ . '/../../helpers/pricing.php';
require_once __DIR__ . '/../../helpers/store_items.php';
require_once __DIR__ . '/../admin/products/manage.php';

if (!function_exists('store_item_from_product')) {
    /** A product, in the shape the shelf uses. */
    function store_item_from_product(array $p): array {
        return [
            'item_type' => 'product',
            'id' => $p['id'],
            'name' => $p['name'],
            'description' => $p['description'] ?? null,
            'image' => $p['image'],
            'price' => $p['price'],
            'sale_price' => $p['sale_price'],
            'effective_price' => $p['effective_price'],
            'is_on_sale' => $p['is_on_sale'],
            'discount_percent' => $p['discount_percent'],
            'currency' => $p['currency'],
            'in_stock' => $p['in_stock'],
            'stock' => $p['stock'],
            // Carried through, not dropped: without it a card cannot tell "unlimited" from
            // "sold out", since both arrive with in_stock already decided and stock null-or-zero.
            'is_stock_tracked' => $p['is_stock_tracked'],
            'category' => $p['category'],
            'product_category_id' => $p['product_category_id'],
            'slug' => $p['slug'],
            'sku' => $p['sku'],
            'gallery' => $p['gallery'],
            // The attachment is described to a shopper, but its PATH is withheld unless the
            // product says the file is public (or, below, the student owns it). A digital
            // product's file is the thing being sold, and a shop front that hands out the
            // download link has given the product away.
            'has_file' => $p['has_file'] ?? false,
            'file_name' => ($p['has_file'] ?? false) ? $p['file_name'] : null,
            'file_extension' => ($p['has_file'] ?? false) ? $p['file_extension'] : null,
            'file_size' => ($p['has_file'] ?? false) ? $p['file_size'] : null,
            'file_size_label' => ($p['has_file'] ?? false) ? $p['file_size_label'] : null,
            'file_path' => !empty($p['file_is_public']) ? $p['file_path'] : null,
            'file_is_public' => (bool)($p['file_is_public'] ?? false),
            'order_num' => $p['order_num'],
            'created_at' => $p['created_at'],
            'own' => false,
            'is_locked' => false,
        ];
    }
}

if (!function_exists('store_visible_sql')) {
    /**
     * What a shopper may see: every live item. `show_on_website` decides only whether the item
     * is shown on the public landing page (getPublicLandingConfig), which is what it always meant
     * for a book. One store, one rule - where an item came from does not matter.
     */
    function store_visible_sql($con): string {
        return "p.is_active = 1";
    }
}

if (!function_exists('store_is_book_sql')) {
    /** A "book" on the shelf: a digital item (a file the buyer opens). */
    function store_is_book_sql($con): string {
        if (function_exists('store_products_ready') && store_products_ready($con)) {
            return "p.product_type = 'digital'";
        }
        return "1 = 0";
    }
}

if (!function_exists('store_item_is_book')) {
    function store_item_is_book(array $raw): bool {
        return ($raw['product_type'] ?? '') === 'digital';
    }
}

if (!function_exists('store_price_blocks')) {
    /**
     * The price each item is quoted at for this visitor: the effective base price (the sale price
     * while on sale) overridden by a country price, in one query for the lot.
     *
     * @return array<int, array> the decorated row per id: price, is_priced, base_price, currency, ...
     */
    function store_price_blocks($con, array $rawRows, int $stId): array {
        $rows = [];
        foreach ($rawRows as $raw) {
            $effective = store_item_effective_price($raw);
            $rows[] = ['id' => (int)$raw['id'], 'price' => $effective !== null ? $effective : 0.0];
        }
        if ($rows) {
            pricing_decorate_rows($con, $rows, 'book', $stId);
        }
        $out = [];
        foreach ($rows as $r) {
            $out[(int)$r['id']] = $r;
        }
        return $out;
    }
}

if (!function_exists('store_shelf_item')) {
    /**
     * One shelf entry: the product shape, priced for this visitor, with what a book card reads.
     */
    function store_shelf_item($con, array $raw, ?array $names, array $price, array $access): array {
        $id = (int)$raw['id'];
        $item = store_item_from_product(product_row($con, $raw));

        if ($names !== null) {
            $item['name'] = $names['name'];
            $item['description'] = $names['description'];
        }

        // Price. Without a country price the numbers are base-currency numbers, the sale price
        // included. A country price replaces the lot: it is the one number this visitor pays, and
        // a base-currency "was" price beside it would be in a different currency.
        $isCountry = !empty($price['is_country_price']);
        $item['is_priced'] = (bool)($price['is_priced'] ?? ($raw['price'] !== null));
        $item['effective_price'] = (float)($price['price'] ?? $item['effective_price']);
        $item['base_price'] = $price['base_price'] ?? null;
        $item['price_formatted'] = $price['price_formatted'] ?? null;
        $item['is_country_price'] = $isCountry;
        if (is_array($price['currency'] ?? null)) {
            $item['currency'] = $price['currency']['code'] ?? $item['currency'];
            $item['currency_info'] = $price['currency'];
        }
        if ($isCountry) {
            $item['price'] = $item['effective_price'];
            $item['sale_price'] = null;
            $item['is_on_sale'] = false;
            $item['discount_percent'] = 0;
        }

        // What a book card needs, now true of every item on the shelf.
        $own = (bool)($access['own'] ?? false);
        $item['own'] = $own;
        $item['is_subscribed'] = $own;
        $item['is_locked'] = !$own;
        $item['request_status'] = $access['request_status'] ?? null;
        $item['file_type'] = store_item_file_type($raw);
        $item['product_type'] = $raw['product_type'] ?? 'physical';
        $item['subject_id'] = isset($raw['subject_id']) && $raw['subject_id'] !== null ? (int)$raw['subject_id'] : null;
        $item['book_category'] = $raw['book_category'] ?? null;
        $item['is_book'] = store_item_is_book($raw);
        $item['allow_download'] = (int)($raw['allow_download'] ?? 1);

        // The file. A physical item has none. A digital one is opened by its owner - straight
        // from its path when downloads are allowed, otherwise only through the stream endpoint -
        // and by nobody else unless the product marks its file public.
        $digital = ($raw['product_type'] ?? 'physical') === 'digital';
        $source = $digital ? trim((string)(($raw['file_path'] ?? '') ?: ($raw['link'] ?? '') ?: '')) : '';
        $item['has_file'] = $source !== '';
        $item['view_url'] = null;
        if (!$digital) {
            $item['file_path'] = null;
        } elseif ($own && $source !== '') {
            if ($item['allow_download'] === 1) {
                $item['file_path'] = format_image_url($source);
                $item['view_url'] = $item['file_path'];
            } else {
                $item['file_path'] = null;
                $item['view_url'] = 'https://camp-coding.online/brain-ixa/student/books/stream?book_id=' . $id;
            }
        }

        return $item;
    }
}

if (!function_exists('store_student_id')) {
    function store_student_id($studentData): int {
        if (is_array($studentData)) {
            return (int)($studentData['id'] ?? $studentData['student_id'] ?? 0);
        }
        if (is_object($studentData)) {
            return (int)($studentData->id ?? $studentData->student_id ?? 0);
        }
        return 0;
    }
}

if (!function_exists('store_access_for')) {
    /** Ownership and requests for these raw rows; nobody owns anything when no one is signed in. */
    function store_access_for($con, int $stId, array $rawById): array {
        if ($stId > 0 && $rawById) {
            require_once __DIR__ . '/../user/student/content/books.php';
            return student_store_items_access($con, $stId, $rawById);
        }
        $out = [];
        foreach ($rawById as $id => $_) {
            $out[(int)$id] = ['own' => false, 'request_status' => null, 'request_review_notes' => null];
        }
        return $out;
    }
}

if (!function_exists('storeList')) {
    /**
     * The shelf: every live store item, one shape, one sort.
     *
     * `type=book` narrows it to the items that are books (former books, and digital items filed as
     * a summary or a past paper); `type=product` is the whole shelf, since every item is a product.
     * `category_id` narrows to one product category, which a former book does not have - said in
     * `applied_filters` rather than left for somebody to work out from a suddenly shorter list.
     */
    function storeList($con, $studentData = null) {
        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 20)));

        $type = strtolower(trim($_GET['type'] ?? $_GET['item_type'] ?? ''));
        $categoryId = (int)($_GET['category_id'] ?? $_GET['product_category_id'] ?? 0);
        $sort = strtolower(trim($_GET['sort'] ?? 'newest'));
        $stId = store_student_id($studentData);

        $raws = [];
        if (products_tables_ready($con)) {
            // The shared filters (category, search, price range, in stock), with the shopper's
            // visibility rule in place of the plain "on the website" one.
            $where = array_values(array_filter(
                product_filters_sql($con, true),
                fn($w) => !in_array(trim($w), ['p.is_active = 1', 'p.show_on_website = 1'], true)
            ));
            $where[] = store_visible_sql($con);
            if ($type === 'book') {
                $where[] = store_is_book_sql($con);
            }

            // Not paginated in SQL: the sort can be by the price this visitor is quoted, which is
            // a country price decided after the query. Bounded so a catalogue that grows past
            // this is still an answer rather than a timeout.
            $res = @mysqli_query($con, "SELECT p.* FROM products p WHERE " . implode(' AND ', $where) . " ORDER BY p.order_num ASC, p.id DESC LIMIT 1000");
            while ($res && ($row = mysqli_fetch_assoc($res))) {
                $raws[(int)$row['id']] = $row;
            }
        }

        $langId = (int)(get_language_info($con)['id'] ?? 1);
        $names = store_item_names($con, array_keys($raws), $langId);
        $prices = store_price_blocks($con, array_values($raws), $stId);

        $keys = [];
        foreach ($raws as $id => $raw) {
            $keys[] = [
                'id' => $id,
                'price' => (float)($prices[$id]['price'] ?? 0),
                'name' => (string)($names[$id]['name'] ?? $raw['slug'] ?? ''),
                'created_at' => (string)($raw['created_at'] ?? ''),
            ];
        }
        usort($keys, function ($a, $b) use ($sort) {
            switch ($sort) {
                case 'price_asc':  return $a['price'] <=> $b['price'];
                case 'price_desc': return $b['price'] <=> $a['price'];
                case 'name':       return strcmp($a['name'], $b['name']);
                case 'oldest':     return strcmp($a['created_at'], $b['created_at']);
                default:           return strcmp($b['created_at'], $a['created_at']);
            }
        });

        $total = count($keys);
        $booksCount = 0;
        foreach ($raws as $raw) {
            if (store_item_is_book($raw)) $booksCount++;
        }

        // Only the page is built in full: product_row() reads translations and the category per
        // row, and the ownership checks are per student.
        $pageKeys = array_slice($keys, ($page - 1) * $limit, $limit);
        $pageRaws = [];
        foreach ($pageKeys as $k) {
            $pageRaws[$k['id']] = $raws[$k['id']];
        }
        $access = store_access_for($con, $stId, $pageRaws);

        $pageItems = [];
        foreach ($pageRaws as $id => $raw) {
            $pageItems[] = store_shelf_item($con, $raw, $names[$id] ?? null, $prices[$id] ?? [], $access[$id] ?? []);
        }

        $response = build_paginated_response($pageItems, $page, $limit, $total, [
            'total_count' => $total,
            'products_count' => $total,
            // The items that are books, among the ones listed. They are products too, so they are
            // also counted in products_count.
            'books_count' => $booksCount,
        ]);

        $response['applied_filters'] = [
            'type' => $type !== '' ? $type : 'all',
            'category_id' => $categoryId > 0 ? $categoryId : null,
            'sort' => $sort,
            // So a client never has to guess why the books vanished.
            'books_excluded_reason' => $categoryId > 0
                ? 'الكتب لا تحمل تصنيف منتجات، فهي مستبعَدة أثناء الفلترة بتصنيف'
                : null,
        ];

        return $response;
    }
}

if (!function_exists('storeCategories')) {
    /**
     * The product categories a shopper may browse, each with how many live products it holds -
     * so the shop front can hide an empty shelf instead of opening one.
     */
    function storeCategories($con) {
        if (!products_tables_ready($con)) {
            return ['status' => 'success', 'data' => []];
        }

        $langId = (int)(get_language_info($con)['id'] ?? 1);
        $hideEmpty = !empty($_GET['hide_empty']);

        // The fallback name is a SUBQUERY, not a second LEFT JOIN. Joining the translations table
        // again without a language condition multiplies the row once per translation a category
        // has, so a category with both Arabic and English came back twice - which it did, until
        // this was measured. A GROUP BY cannot fix that while the duplicated column is selected.
        $res = @mysqli_query($con, "
            SELECT c.id, c.code, c.image, c.order_num,
                   COALESCE(
                       (SELECT t.name FROM product_categories_translations t
                         WHERE t.product_category_id = c.id AND t.language_id = {$langId} LIMIT 1),
                       (SELECT t2.name FROM product_categories_translations t2
                         WHERE t2.product_category_id = c.id ORDER BY t2.id ASC LIMIT 1),
                       c.code
                   ) AS name,
                   COALESCE(
                       (SELECT t.description FROM product_categories_translations t
                         WHERE t.product_category_id = c.id AND t.language_id = {$langId} LIMIT 1),
                       (SELECT t2.description FROM product_categories_translations t2
                         WHERE t2.product_category_id = c.id ORDER BY t2.id ASC LIMIT 1)
                   ) AS description,
                   (SELECT COUNT(*) FROM products p
                     WHERE p.product_category_id = c.id AND p.is_active = 1 AND p.show_on_website = 1
                   ) AS products_count
            FROM product_categories c
            WHERE c.is_active = 1
            ORDER BY c.order_num ASC, c.id ASC
        ");

        $items = [];
        if ($res) {
            while ($row = mysqli_fetch_assoc($res)) {
                $row['id'] = (int)$row['id'];
                $row['order_num'] = (int)$row['order_num'];
                $row['products_count'] = (int)$row['products_count'];
                if ($hideEmpty && $row['products_count'] === 0) {
                    continue;
                }
                $items[] = format_response_images($row);
            }
        }

        return ['status' => 'success', 'data' => $items];
    }
}

if (!function_exists('storeShowProduct')) {
    /** One store item, for its details page. Only a visible one: this is the shopper's view. */
    function storeShowProduct($con, $studentData = null) {
        if (!products_tables_ready($con)) {
            return ['status' => 'error', 'message' => 'المنتج غير موجود'];
        }

        $id = (int)($_GET['id'] ?? 0);
        $slug = trim((string)($_GET['slug'] ?? ''));

        if ($id <= 0 && $slug === '') {
            return ['status' => 'error', 'message' => 'id أو slug مطلوب'];
        }

        $visible = store_visible_sql($con);
        if ($id > 0) {
            $stmt = mysqli_prepare($con, "SELECT p.* FROM products p WHERE p.id = ? AND {$visible} LIMIT 1");
            mysqli_stmt_bind_param($stmt, "i", $id);
        } else {
            $stmt = mysqli_prepare($con, "SELECT p.* FROM products p WHERE p.slug = ? AND {$visible} LIMIT 1");
            mysqli_stmt_bind_param($stmt, "s", $slug);
        }

        mysqli_stmt_execute($stmt);
        $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));

        if (!$row) {
            return ['status' => 'error', 'message' => 'المنتج غير موجود'];
        }

        $rowId = (int)$row['id'];
        $stId = store_student_id($studentData);
        $prices = store_price_blocks($con, [$row], $stId);
        $access = store_access_for($con, $stId, [$rowId => $row]);
        $langId = (int)(get_language_info($con)['id'] ?? 1);
        $names = store_item_names($con, [$rowId], $langId);

        return ['status' => 'success', 'data' => store_shelf_item($con, $row, $names[$rowId] ?? null, $prices[$rowId] ?? [], $access[$rowId] ?? [])];
    }
}
