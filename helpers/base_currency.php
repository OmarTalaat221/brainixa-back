<?php
/**
 * Changing the platform's base currency, without silently repricing everything.
 *
 * `courses.price` and `course_books.price` are plain numbers. Nothing on the row says which
 * currency they are in - the answer is whatever `base_currency` happens to say today. So flipping
 * that setting from EGP to SAR does not convert anything: a course priced at 300 EGP becomes a
 * course priced at 300 SAR, roughly eight times dearer, with no edit, no audit trail and nothing
 * on screen to show it happened.
 *
 * The one piece of real information available is the country prices that were already entered. If
 * a course has a Saudi price of 50 SAR and the base is moving to SAR, then 50 is the number its
 * owner actually meant in that currency, and it should become the new base price. That is what
 * `base_currency_adopt()` does.
 *
 * What is left over is the point of all this: every item with NO price in the incoming currency
 * cannot be fixed automatically, because nobody has ever said what it costs in that currency.
 * Those are listed, counted and handed back so the admin is told exactly which items they now owe
 * a price - instead of finding out from a customer who paid the wrong amount.
 *
 * Products are deliberately absent. `products.currency` is a column on each row, so a product
 * already carries its own currency and the base setting never spoke for it.
 */

require_once __DIR__ . '/functions.php';
require_once __DIR__ . '/pricing.php';

if (!function_exists('base_currency_item_sources')) {
    /**
     * The things that carry a bare price in the base currency. `kind` separates packages from
     * ordinary courses for the report only - both live in `courses` and are priced the same way.
     */
    function base_currency_item_sources(): array {
        return [
            'course' => ['table' => 'courses', 'price_column' => 'price'],
            'book'   => ['table' => 'course_books', 'price_column' => 'price'],
        ];
    }
}

if (!function_exists('base_currency_item_name_sql')) {
    /** The translated name of an item, preferring the request's language. */
    function base_currency_item_name_sql(string $itemType, int $langId): string {
        if ($itemType === 'course') {
            return "COALESCE(
                (SELECT ct.name FROM courses_translations ct WHERE ct.course_id = i.id AND ct.language_id = {$langId} LIMIT 1),
                (SELECT ct.name FROM courses_translations ct WHERE ct.course_id = i.id LIMIT 1))";
        }

        return "COALESCE(
            (SELECT bt.title FROM course_books_translations bt WHERE bt.book_id = i.id AND bt.language_id = {$langId} LIMIT 1),
            (SELECT bt.title FROM course_books_translations bt WHERE bt.book_id = i.id LIMIT 1))";
    }
}

if (!function_exists('base_currency_scan')) {
    /**
     * Every priced item, split by whether a price in the incoming currency already exists.
     *
     * The join is on the CURRENCY, not on one country: several countries can share a currency, and
     * a price entered for any of them is a price in that currency. Where more than one exists the
     * lowest is taken - over-charging someone because two countries disagreed is the worse of the
     * two mistakes.
     *
     * Only `is_active = 1` rows count, because an inactive country price is one the admin has
     * already said should not be used.
     */
    function base_currency_scan($con, string $targetCurrency): array {
        $target = strtoupper(trim($targetCurrency));
        $langId = (int)(get_language_info($con)['id'] ?? 1);

        $adoptable = [];
        $missing = [];

        foreach (base_currency_item_sources() as $itemType => $source) {
            $table = $source['table'];
            $priceColumn = $source['price_column'];
            $nameSql = base_currency_item_name_sql($itemType, $langId);
            $kindSql = $itemType === 'course' ? 'i.kind' : "'book'";

            $sql = "
                SELECT i.id,
                       {$nameSql} AS item_name,
                       {$kindSql} AS item_kind,
                       i.{$priceColumn} AS base_price,
                       (SELECT MIN(p.price) FROM item_country_prices p
                         WHERE p.item_type = ? AND p.item_id = i.id
                           AND p.is_active = 1 AND p.currency_code = ?) AS target_price
                FROM {$table} i
                WHERE i.{$priceColumn} IS NOT NULL AND i.{$priceColumn} > 0
                ORDER BY i.id DESC
            ";

            $stmt = @mysqli_prepare($con, $sql);
            if (!$stmt) continue;

            mysqli_stmt_bind_param($stmt, "ss", $itemType, $target);
            mysqli_stmt_execute($stmt);
            $res = mysqli_stmt_get_result($stmt);

            while ($row = mysqli_fetch_assoc($res)) {
                $entry = [
                    'item_type' => $itemType,
                    'item_kind' => $row['item_kind'] ?: $itemType,
                    'item_id' => (int)$row['id'],
                    'item_name' => $row['item_name'] ?: ('#' . (int)$row['id']),
                    'current_price' => (float)$row['base_price'],
                ];

                if ($row['target_price'] !== null) {
                    $entry['new_price'] = (float)$row['target_price'];
                    $adoptable[] = $entry;
                } else {
                    $missing[] = $entry;
                }
            }
        }

        return ['adoptable' => $adoptable, 'missing' => $missing];
    }
}

if (!function_exists('base_currency_impact')) {
    /**
     * What switching to this currency would do, without doing any of it. The screen asks for this
     * first and shows it as a confirmation, so the admin decides with the numbers in front of them.
     */
    function base_currency_impact($con, string $targetCurrency): array {
        $target = strtoupper(trim($targetCurrency));
        $current = pricing_base_currency($con);

        if (!preg_match('/^[A-Z]{3}$/', $target)) {
            return ['status' => 'error', 'message' => app_text($con, 'كود العملة لازم يكون 3 حروف.', 'The currency code must be three letters.')];
        }

        $targetInfo = currency_info($con, $target);
        if (empty($targetInfo['is_active'])) {
            return ['status' => 'error', 'message' => app_text($con, 'العملة دي مش موجودة أو مش مفعّلة.', 'That currency does not exist or is not active.')];
        }

        if ($target === $current) {
            return [
                'status' => 'success',
                'data' => [
                    'is_change' => false,
                    'current_currency' => currency_info($con, $current),
                    'target_currency' => $targetInfo,
                    'adoptable' => [], 'missing' => [],
                    'adoptable_count' => 0, 'missing_count' => 0,
                    'message' => app_text($con, 'دي العملة الأساسية الحالية بالفعل.', 'That is already the base currency.'),
                ],
            ];
        }

        $scan = base_currency_scan($con, $target);

        // Counted per kind as well as in total: "47 items" says much less to someone deciding than
        // "12 packages, 30 courses and 5 books".
        $byKind = [];
        foreach ($scan['missing'] as $row) {
            $kind = $row['item_kind'];
            $byKind[$kind] = ($byKind[$kind] ?? 0) + 1;
        }

        return [
            'status' => 'success',
            'data' => [
                'is_change' => true,
                'current_currency' => currency_info($con, $current),
                'target_currency' => $targetInfo,
                'adoptable' => $scan['adoptable'],
                'missing' => $scan['missing'],
                'adoptable_count' => count($scan['adoptable']),
                'missing_count' => count($scan['missing']),
                'missing_by_kind' => $byKind,
                'products_note' => app_text(
                    $con,
                    'المنتجات مش متأثرة: كل منتج بيحمل عملته في صفّه.',
                    'Products are unaffected: each product carries its own currency on its row.'
                ),
            ],
        ];
    }
}

if (!function_exists('base_currency_adopt')) {
    /**
     * Rewrites each item's base price to the price already entered in the incoming currency.
     *
     * Runs before the setting is written, so if this fails the platform is still describing its
     * prices with the currency they were entered in.
     *
     * Items with no price in that currency are NOT touched. There is nothing to convert them with -
     * guessing at an exchange rate would put a number in front of a customer that nobody approved -
     * so they keep their figure and are reported as owing a price.
     */
    function base_currency_adopt($con, string $targetCurrency): array {
        $scan = base_currency_scan($con, $targetCurrency);
        $sources = base_currency_item_sources();

        $updated = [];
        foreach ($scan['adoptable'] as $row) {
            $source = $sources[$row['item_type']] ?? null;
            if (!$source) continue;

            $stmt = @mysqli_prepare($con, "UPDATE {$source['table']} SET {$source['price_column']} = ? WHERE id = ?");
            if (!$stmt) continue;

            $newPrice = $row['new_price'];
            $itemId = $row['item_id'];
            mysqli_stmt_bind_param($stmt, "di", $newPrice, $itemId);
            if (@mysqli_stmt_execute($stmt)) $updated[] = $row;
        }

        return ['updated' => $updated, 'missing' => $scan['missing']];
    }
}

if (!function_exists('adminBaseCurrencyImpact')) {
    function adminBaseCurrencyImpact($con) {
        $target = (string)($_GET['currency'] ?? $_GET['base_currency'] ?? '');
        if (trim($target) === '') {
            return ['status' => 'error', 'message' => app_text($con, 'اختار العملة الأول.', 'Name the currency first.')];
        }

        return base_currency_impact($con, $target);
    }
}
