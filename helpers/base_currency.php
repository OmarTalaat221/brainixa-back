<?php
require_once __DIR__ . '/app_settings.php';
/**
 * Changing the platform's base currency, without silently repricing everything.
 *
 * `courses.price` and `products.price` are plain numbers. Nothing on the row says which
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
 *
 * Those items are not allowed through. Letting the switch proceed and leaving their figures to be
 * re-read as the new currency is the exact bug this file exists to stop - it is what turns 300 EGP
 * into 300 SAR. So the change is REFUSED until a price in the incoming currency has been given for
 * every one of them, and the refusal names them. Nothing here ever invents a conversion: an
 * exchange rate picked by the server would put a number in front of a customer that nobody
 * approved.
 *
 * Store products go through here exactly like courses. Since migration 131 every store item is a
 * `products` row priced in the base currency (`products.currency` is set to the base on every row
 * and is kept in step below), and country prices for them are stored under item_type 'book', the
 * token the store used before. `course_books` now holds only lesson files, which carry no price
 * of their own and are not touched.
 *
 * A product on sale has a second number, `sale_price`, in the same old currency. It is cleared
 * when the price moves: the new price is either the country price buyers in that currency were
 * already paying in place of the sale price, or a figure the admin typed for the new currency,
 * and a leftover sale figure in the old currency would undercut both. Each such row is reported
 * with `current_sale_price` so the admin can set a new sale.
 */

require_once __DIR__ . '/functions.php';
require_once __DIR__ . '/pricing.php';
require_once __DIR__ . '/store_items.php';

if (!function_exists('base_currency_item_sources')) {
    /**
     * The things that carry a bare price in the base currency. `kind` separates packages from
     * ordinary courses for the report only - both live in `courses` and are priced the same way.
     * 'book' is the store item token (item_country_prices, the money tables); its rows are products.
     */
    function base_currency_item_sources(): array {
        return [
            'course' => ['table' => 'courses', 'price_column' => 'price'],
            'book'   => ['table' => 'products', 'price_column' => 'price'],
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

        // A store item: a product, named in products_translations.
        return store_name_sql($langId, 'i');
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
            $saleSql = $itemType === 'book' ? 'i.sale_price' : 'NULL';

            $sql = "
                SELECT i.id,
                       {$nameSql} AS item_name,
                       {$kindSql} AS item_kind,
                       i.{$priceColumn} AS base_price,
                       {$saleSql} AS sale_price,
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
                if ($itemType === 'book') {
                    $entry['current_sale_price'] = $row['sale_price'] !== null ? (float)$row['sale_price'] : null;
                }

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
                // Kept for the screens that print it. Products used to be outside this move; since
                // migration 131 they are listed above with the courses.
                'products_note' => app_text(
                    $con,
                    'المنتجات مسعّرة بالعملة الأساسية زي الكورسات، وموجودة في القايمة. سعر التخفيض لأي منتج بيتشال عند التحويل.',
                    'Store products are priced in the base currency like courses and are listed here. Any sale price on a product is cleared when it moves.'
                ),
            ],
        ];
    }
}

if (!function_exists('base_currency_entered_prices')) {
    /**
     * The prices the admin typed for the items that had none, keyed "course-12" / "book-7".
     *
     * Accepts either that map or a list of {item_type, item_id, price}, because a form sends one
     * and a script the other, and refusing the shape somebody happens to have is not a safety
     * measure.
     */
    function base_currency_entered_prices($input): array {
        $out = [];
        if (!is_array($input)) return $out;

        foreach ($input as $key => $value) {
            $itemType = null;
            $itemId = 0;
            $price = null;

            if (is_array($value) && isset($value['item_type'], $value['item_id'])) {
                $itemType = (string)$value['item_type'];
                $itemId = (int)$value['item_id'];
                $price = $value['price'] ?? null;
            } elseif (is_string($key) && strpos($key, '-') !== false) {
                [$itemType, $rawId] = explode('-', $key, 2);
                $itemId = (int)$rawId;
                $price = $value;
            }

            if (!in_array($itemType, ['course', 'book'], true) || $itemId <= 0) continue;
            if ($price === null || $price === '' || !is_numeric($price)) continue;

            $price = (float)$price;
            // Zero is allowed - an item deliberately given away - but a negative price is not a
            // price, and it would be stored and charged.
            if ($price < 0) continue;

            $out[$itemType . '-' . $itemId] = $price;
        }

        return $out;
    }
}

if (!function_exists('base_currency_adopt')) {
    /**
     * Moves every item's base price into the incoming currency, or refuses outright.
     *
     * Two ways a price gets there, and no third:
     *
     *   - it was already entered for a country using that currency, so it is adopted;
     *   - the admin typed it on the confirmation screen, so it is used.
     *
     * Anything still without one REFUSES THE WHOLE CHANGE and is named in `missing`. No partial
     * write happens in that case: the caller must not save the setting either, or the platform
     * ends up describing old figures with a new currency, which is the bug this guards against.
     *
     * Runs before the setting is written, so a failure leaves the platform still describing its
     * prices with the currency they were entered in.
     */
    function base_currency_adopt($con, string $targetCurrency, array $enteredPrices = []): array {
        $scan = base_currency_scan($con, $targetCurrency);
        $sources = base_currency_item_sources();
        $entered = base_currency_entered_prices($enteredPrices);

        // Everything that now has a number, from either source.
        $toWrite = [];
        foreach ($scan['adoptable'] as $row) {
            $row['source'] = 'stored';
            $toWrite[] = $row;
        }

        $stillMissing = [];
        foreach ($scan['missing'] as $row) {
            $key = $row['item_type'] . '-' . $row['item_id'];
            if (array_key_exists($key, $entered)) {
                $row['new_price'] = $entered[$key];
                $row['source'] = 'entered';
                $toWrite[] = $row;
            } else {
                $stillMissing[] = $row;
            }
        }

        if ($stillMissing) {
            return ['ok' => false, 'updated' => [], 'missing' => $stillMissing];
        }

        $updated = [];
        foreach ($toWrite as $row) {
            $source = $sources[$row['item_type']] ?? null;
            if (!$source) continue;

            // A product's sale figure was in the old currency; see the note at the top of the file.
            $extraSet = $row['item_type'] === 'book' ? ', sale_price = NULL' : '';
            $stmt = @mysqli_prepare($con, "UPDATE {$source['table']} SET {$source['price_column']} = ?{$extraSet} WHERE id = ?");
            if (!$stmt) continue;

            $newPrice = $row['new_price'];
            $itemId = $row['item_id'];
            mysqli_stmt_bind_param($stmt, "di", $newPrice, $itemId);
            if (@mysqli_stmt_execute($stmt)) $updated[] = $row;
        }

        // Every product row states the base currency (migration 131), including the unpriced and
        // free ones the scan skipped, so all of them follow it.
        $targetCode = strtoupper(trim($targetCurrency));
        if (preg_match('/^[A-Z]{3}$/', $targetCode)) {
            @mysqli_query($con, "UPDATE products SET currency = '{$targetCode}' WHERE currency <> '{$targetCode}'");
        }

        return ['ok' => true, 'updated' => $updated, 'missing' => []];
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
