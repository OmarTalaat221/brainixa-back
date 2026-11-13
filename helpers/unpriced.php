<?php
require_once __DIR__ . '/app_settings.php';

/**
 * "No price" - the third state of a price, beside free (0) and a figure.
 *
 * An empty price box means the item is not for sale yet. It must never be read as free:
 * `(float)null` is 0, and 0 is what every money path takes to mean "free", so a NULL that is cast
 * on the way through turns "not for sale" into "give it away". Everything here exists to keep
 * the two apart.
 *
 * Contract: the API never starts sending `price: null` where it used to send a number on a
 * student-facing endpoint. Those keep `price` numeric (0 for an unpriced item) and gain
 * `is_priced` beside it. Only the admin and teacher endpoints, which are read by the dashboards
 * alone, return the raw null.
 */

if (!function_exists('price_column_nullable')) {
    /**
     * Whether migration 130 has run for this table. Before it does, an empty box is stored as 0
     * exactly as it always was - no worse than today, and no failed insert.
     */
    function price_column_nullable($con, string $table): bool {
        static $cache = [];
        if (array_key_exists($table, $cache)) return $cache[$table];

        $safe = preg_replace('/[^a-z_]/i', '', $table);
        $res = @mysqli_query($con, "SHOW COLUMNS FROM `{$safe}` LIKE 'price'");
        $row = $res ? mysqli_fetch_assoc($res) : null;

        return $cache[$table] = ($row && strtoupper((string)($row['Null'] ?? '')) === 'YES');
    }
}

if (!function_exists('price_is_empty_input')) {
    /**
     * An empty box, however it arrived: JSON null, an empty multipart field (the dashboards send
     * null as "" in FormData), or the literal string "null".
     */
    function price_is_empty_input($raw): bool {
        if ($raw === null) return true;
        if (is_string($raw)) {
            $trimmed = strtolower(trim($raw));
            return $trimmed === '' || $trimmed === 'null';
        }
        return false;
    }
}

if (!function_exists('price_from_body')) {
    /**
     * Reads a price off a request body.
     *
     *   ['present' => false]                    the key was not sent - leave the price alone
     *   ['present' => true, 'price' => null]    sent empty - "no price"
     *   ['present' => true, 'price' => 150.0]   a price (0.0 is free)
     *
     * The difference between the first two is the whole point: `isset()` treats a sent null as
     * not sent, which is why an admin could never clear a price once one was set.
     */
    function price_from_body($con, array $body, string $table, string $key = 'price'): array {
        if (!array_key_exists($key, $body)) {
            return ['present' => false, 'price' => null];
        }

        if (price_is_empty_input($body[$key])) {
            return ['present' => true, 'price' => price_column_nullable($con, $table) ? null : 0.0];
        }

        return ['present' => true, 'price' => (float)$body[$key]];
    }
}

if (!function_exists('price_out')) {
    /** A stored price as the dashboards read it: null stays null, anything else is a float. */
    function price_out($value): ?float {
        return $value === null ? null : (float)$value;
    }
}

if (!function_exists('price_unpriced_label')) {
    /** What an unpriced item shows where a price would be. */
    function price_unpriced_label($con): string {
        if (function_exists('app_text')) {
            return app_text($con, 'بدون سعر', 'No price');
        }
        return 'بدون سعر';
    }
}

if (!function_exists('price_not_for_sale_message')) {
    /** The refusal every purchase path gives an unpriced item. */
    function price_not_for_sale_message($con): string {
        if (function_exists('app_text')) {
            return app_text(
                $con,
                'العنصر ده لسه ملوش سعر، فمش متاح للشراء دلوقتي.',
                'This item has no price yet, so it cannot be bought right now.'
            );
        }
        return 'العنصر ده لسه ملوش سعر، فمش متاح للشراء دلوقتي.';
    }
}
