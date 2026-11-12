<?php
/**
 * المتجر — one shelf, two kinds of thing on it.
 *
 * The store already sold books: rows of `course_books` that are standalone (tied to no course and
 * no unit), which `GET /books?standalone=1` lists. Products are a separate table with a separate
 * shape - stock, a sale price, a product category - and merging the two tables in the database
 * was never the right answer, because a book has a file, a subject and a reader, and a product
 * has none of those.
 *
 * They are merged HERE instead, at the one place that has to show them together: the shop front.
 * Every entry carries `item_type` ('product' or 'book') and an `id` that is only unique within
 * its own type, so a client must key on the pair. That is stated rather than hidden behind a
 * synthetic id, because an id that silently means two different things in two different tables is
 * how a cart ends up buying the wrong row.
 *
 * `GET /books` is untouched and still lists books exactly as it did. This endpoint is additive:
 * nothing that reads the old one has to change.
 *
 * Needs migration 127. Without it the store simply shows the books it always showed, rather than
 * failing - a half-deployed server should still have a shop.
 */

require_once __DIR__ . '/../../helpers/functions.php';
require_once __DIR__ . '/../../helpers/language.php';
require_once __DIR__ . '/../../helpers/upload.php';
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
            'order_num' => $p['order_num'],
            'created_at' => $p['created_at'],
            // A book can already be owned by the student; a product is bought every time, so
            // these are stated rather than omitted - a card that reads both kinds should not
            // have to know which fields a product happens not to have.
            'own' => false,
            'is_locked' => false,
        ];
    }
}

if (!function_exists('store_item_from_book')) {
    /** A standalone book, flattened into the same shape. */
    function store_item_from_book(array $b): array {
        $price = (float)($b['price'] ?? 0);

        return [
            'item_type' => 'book',
            'id' => (int)$b['id'],
            'name' => $b['title'] ?? ('#' . $b['id']),
            'description' => $b['description'] ?? null,
            'image' => $b['cover_image'] ?? null,
            'price' => round($price, 2),
            // Books carry no sale price and no stock. Reported as null / unlimited rather than
            // as zero, so a client sorting or filtering on these does not read every book as
            // free or as sold out.
            'sale_price' => null,
            'effective_price' => round($price, 2),
            'is_on_sale' => false,
            'discount_percent' => 0,
            'currency' => $b['currency'] ?? 'EGP',
            'in_stock' => true,
            'stock' => null,
            'is_stock_tracked' => false,
            'category' => null,
            'product_category_id' => null,
            'slug' => null,
            'sku' => null,
            'gallery' => [],
            'order_num' => (int)($b['order_num'] ?? 1),
            'created_at' => $b['created_at'] ?? null,
            'own' => (bool)($b['own'] ?? false),
            'is_locked' => (bool)($b['is_locked'] ?? !($b['own'] ?? false)),
            // Kept so a book card can still do the things only books do.
            'file_type' => $b['file_type'] ?? null,
            'subject_id' => $b['subject_id'] ?? null,
            'request_status' => $b['request_status'] ?? null,
        ];
    }
}

if (!function_exists('store_fetch_products')) {
    /**
     * Public products, already filtered and shaped. Returns [] when migration 127 has not run,
     * which is what keeps the store working on a half-deployed server.
     */
    function store_fetch_products($con): array {
        if (!products_tables_ready($con)) {
            return [];
        }

        $where = product_filters_sql($con, true);
        $whereSql = $where ? 'WHERE ' . implode(' AND ', $where) : '';

        // Not paginated here: the two sources are merged and sorted as one list below, and a
        // page taken from either source before the merge is a page of the wrong things. Bounded
        // so a catalogue that grows past this is still an answer rather than a timeout.
        $res = @mysqli_query($con, "SELECT p.* FROM products p {$whereSql} ORDER BY p.order_num ASC, p.id DESC LIMIT 500");
        if (!$res) {
            return [];
        }

        $items = [];
        while ($row = mysqli_fetch_assoc($res)) {
            $items[] = store_item_from_product(product_row($con, $row));
        }
        return $items;
    }
}

if (!function_exists('store_fetch_books')) {
    /**
     * Standalone books, through the endpoint that already owns what a book in the store is -
     * including whether this student already owns it, which is not a thing this file should be
     * working out a second time.
     */
    function store_fetch_books($con, $studentData): array {
        require_once __DIR__ . '/../user/student/content/books.php';

        // The books endpoint reads its filters from $_GET. Forced for the duration of the call
        // and restored afterwards, so the store's own paging never leaks into it.
        $saved = $_GET;
        $_GET['standalone'] = '1';
        $_GET['page'] = 1;
        $_GET['limit'] = 100;
        unset($_GET['category_id'], $_GET['product_category_id'], $_GET['min_price'], $_GET['max_price'], $_GET['in_stock']);

        $response = studentGetAllBooksWithOwn($con, $studentData);

        $_GET = $saved;

        $items = [];
        foreach ($response['data'] ?? [] as $book) {
            $items[] = store_item_from_book($book);
        }
        return $items;
    }
}

if (!function_exists('storeList')) {
    /**
     * The shelf. Products and standalone books in one list, one shape, one sort.
     *
     * `type=product` or `type=book` narrows it to one kind; `category_id` narrows to one product
     * category and so excludes books, which have none - said in the response's `applied_filters`
     * rather than left for somebody to work out from a suddenly shorter list.
     */
    function storeList($con, $studentData = null) {
        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 20)));

        $type = strtolower(trim($_GET['type'] ?? $_GET['item_type'] ?? ''));
        $categoryId = (int)($_GET['category_id'] ?? $_GET['product_category_id'] ?? 0);

        // A product category is a product's attribute. Filtering by one and still returning books
        // would be returning rows the filter does not apply to.
        $booksExcludedByCategory = $categoryId > 0;

        $items = [];
        if ($type !== 'book') {
            $items = array_merge($items, store_fetch_products($con));
        }
        if ($type !== 'product' && !$booksExcludedByCategory) {
            $items = array_merge($items, store_fetch_books($con, $studentData));
        }

        $sort = strtolower(trim($_GET['sort'] ?? 'newest'));
        usort($items, function ($a, $b) use ($sort) {
            switch ($sort) {
                case 'price_asc':  return $a['effective_price'] <=> $b['effective_price'];
                case 'price_desc': return $b['effective_price'] <=> $a['effective_price'];
                case 'name':       return strcmp((string)$a['name'], (string)$b['name']);
                case 'oldest':     return strcmp((string)($a['created_at'] ?? ''), (string)($b['created_at'] ?? ''));
                default:           return strcmp((string)($b['created_at'] ?? ''), (string)($a['created_at'] ?? ''));
            }
        });

        $total = count($items);
        $pageItems = array_slice($items, ($page - 1) * $limit, $limit);

        $response = build_paginated_response($pageItems, $page, $limit, $total, [
            'total_count' => $total,
            'products_count' => count(array_filter($items, fn($i) => $i['item_type'] === 'product')),
            'books_count' => count(array_filter($items, fn($i) => $i['item_type'] === 'book')),
        ]);

        $response['applied_filters'] = [
            'type' => $type !== '' ? $type : 'all',
            'category_id' => $categoryId > 0 ? $categoryId : null,
            'sort' => $sort,
            // So a client never has to guess why the books vanished.
            'books_excluded_reason' => $booksExcludedByCategory
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
    /** One product, for its details page. Only a live one: this is the shopper's view. */
    function storeShowProduct($con) {
        if (!products_tables_ready($con)) {
            return ['status' => 'error', 'message' => 'المنتج غير موجود'];
        }

        $id = (int)($_GET['id'] ?? 0);
        $slug = trim((string)($_GET['slug'] ?? ''));

        if ($id <= 0 && $slug === '') {
            return ['status' => 'error', 'message' => 'id أو slug مطلوب'];
        }

        if ($id > 0) {
            $stmt = mysqli_prepare($con, "SELECT * FROM products WHERE id = ? AND is_active = 1 AND show_on_website = 1 LIMIT 1");
            mysqli_stmt_bind_param($stmt, "i", $id);
        } else {
            $stmt = mysqli_prepare($con, "SELECT * FROM products WHERE slug = ? AND is_active = 1 AND show_on_website = 1 LIMIT 1");
            mysqli_stmt_bind_param($stmt, "s", $slug);
        }

        mysqli_stmt_execute($stmt);
        $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));

        if (!$row) {
            return ['status' => 'error', 'message' => 'المنتج غير موجود'];
        }

        return ['status' => 'success', 'data' => store_item_from_product(product_row($con, $row))];
    }
}
