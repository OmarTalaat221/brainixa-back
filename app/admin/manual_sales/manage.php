<?php
require_once __DIR__ . '/../../../helpers/language.php';
require_once __DIR__ . '/../../../helpers/functions.php';

/**
 * The manual sales sheet.
 *
 * Sales made off the platform - a student writes on WhatsApp or Instagram, pays the owner
 * directly, and the owner writes the row down afterwards. Nothing here requires the person to
 * have an account: see migrations/113_manual_sales.sql for why.
 */

if (!function_exists('manual_sale_enums')) {
    function manual_sale_enums(): array {
        return [
            'item_type' => ['course', 'package', 'book'],
            'channel'   => ['facebook', 'instagram', 'whatsapp', 'other'],
            'status'    => ['pending', 'approved', 'rejected'],
        ];
    }
}

if (!function_exists('manual_sale_enum_value')) {
    /** Keeps an out-of-range value out of the column rather than letting MySQL store ''. */
    function manual_sale_enum_value($raw, string $field, string $default): string {
        $allowed = manual_sale_enums()[$field] ?? [];
        $value = strtolower(trim((string)$raw));

        return in_array($value, $allowed, true) ? $value : $default;
    }
}

if (!function_exists('manual_sale_row')) {
    function manual_sale_row(array $row): array {
        $row['id'] = (int)$row['id'];
        $row['item_id'] = $row['item_id'] !== null ? (int)$row['item_id'] : null;
        $row['student_id'] = $row['student_id'] !== null ? (int)$row['student_id'] : null;
        $row['amount'] = (float)$row['amount'];

        // The dial code and the number are stored apart so the sheet can be filtered by
        // country; the joined form is what anyone actually wants to read or dial.
        $dial = trim((string)($row['phone_country_code'] ?? ''));
        $number = trim((string)($row['phone'] ?? ''));
        $row['phone_full'] = $number === '' ? '' : ($dial !== '' ? '+' . $dial . $number : $number);

        return $row;
    }
}

if (!function_exists('adminListManualSales')) {
    function adminListManualSales($con) {
        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(200, (int)($_GET['limit'] ?? 20)));
        $offset = ($page - 1) * $limit;

        $where = [];
        $params = [];
        $types = '';

        $search = trim($_GET['search'] ?? $_GET['q'] ?? '');
        if ($search !== '') {
            $where[] = '(student_name LIKE ? OR phone LIKE ? OR item_name LIKE ? OR note LIKE ?)';
            $pattern = '%' . $search . '%';
            array_push($params, $pattern, $pattern, $pattern, $pattern);
            $types .= 'ssss';
        }

        // Every column the sheet shows can be filtered on; an unknown value is ignored rather
        // than silently returning nothing.
        foreach (['status', 'channel', 'item_type'] as $field) {
            $raw = strtolower(trim($_GET[$field] ?? ''));
            if ($raw !== '' && in_array($raw, manual_sale_enums()[$field], true)) {
                $where[] = "{$field} = ?";
                $params[] = $raw;
                $types .= 's';
            }
        }

        $dial = trim($_GET['phone_country_code'] ?? '');
        if ($dial !== '') {
            $where[] = 'phone_country_code = ?';
            $params[] = ltrim($dial, '+');
            $types .= 's';
        }

        $from = trim($_GET['date_from'] ?? '');
        if ($from !== '') {
            $where[] = 'DATE(COALESCE(paid_at, created_at)) >= ?';
            $params[] = $from;
            $types .= 's';
        }
        $to = trim($_GET['date_to'] ?? '');
        if ($to !== '') {
            $where[] = 'DATE(COALESCE(paid_at, created_at)) <= ?';
            $params[] = $to;
            $types .= 's';
        }

        $whereSql = $where ? ('WHERE ' . implode(' AND ', $where)) : '';

        $total = 0;
        $countStmt = mysqli_prepare($con, "SELECT COUNT(*) AS total FROM manual_sales {$whereSql}");
        if ($countStmt) {
            if ($types !== '') {
                mysqli_stmt_bind_param($countStmt, $types, ...$params);
            }
            mysqli_stmt_execute($countStmt);
            $total = (int)(mysqli_fetch_assoc(mysqli_stmt_get_result($countStmt))['total'] ?? 0);
        }

        $sql = "SELECT * FROM manual_sales {$whereSql} ORDER BY COALESCE(paid_at, created_at) DESC, id DESC LIMIT ? OFFSET ?";
        $stmt = mysqli_prepare($con, $sql);
        if (!$stmt) {
            return ['status' => 'error', 'message' => 'Failed to read manual sales: ' . mysqli_error($con)];
        }
        $listParams = $params;
        $listTypes = $types . 'ii';
        array_push($listParams, $limit, $offset);
        mysqli_stmt_bind_param($stmt, $listTypes, ...$listParams);
        mysqli_stmt_execute($stmt);
        $res = mysqli_stmt_get_result($stmt);

        $items = [];
        while ($row = mysqli_fetch_assoc($res)) {
            $items[] = manual_sale_row($row);
        }

        // Totals over the whole sheet, not the page being looked at - a figure that changes
        // when you turn the page is worse than no figure.
        $stats = [
            'total_count' => 0, 'approved_count' => 0, 'pending_count' => 0, 'rejected_count' => 0,
            'approved_amount' => 0.0, 'pending_amount' => 0.0,
        ];
        $statRes = mysqli_query($con, "
            SELECT status, COUNT(*) AS c, COALESCE(SUM(amount), 0) AS total
            FROM manual_sales GROUP BY status
        ");
        if ($statRes) {
            while ($sRow = mysqli_fetch_assoc($statRes)) {
                $stats['total_count'] += (int)$sRow['c'];
                $stats[$sRow['status'] . '_count'] = (int)$sRow['c'];
                if ($sRow['status'] === 'approved') $stats['approved_amount'] = (float)$sRow['total'];
                if ($sRow['status'] === 'pending') $stats['pending_amount'] = (float)$sRow['total'];
            }
        }

        return [
            'status' => 'success',
            'data' => $items,
            'pagination' => [
                'current_page' => $page,
                'per_page' => $limit,
                'total_records' => $total,
                'total_pages' => $limit > 0 ? (int)ceil($total / $limit) : 0,
                'has_next_page' => ($offset + $limit) < $total,
                'has_prev_page' => $page > 1,
            ],
            'statistics' => $stats,
        ];
    }
}

if (!function_exists('adminGetManualSale')) {
    function adminGetManualSale($con) {
        $id = (int)($_GET['id'] ?? 0);
        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'Manual sale ID is required'];
        }

        $stmt = mysqli_prepare($con, "SELECT * FROM manual_sales WHERE id = ? LIMIT 1");
        mysqli_stmt_bind_param($stmt, "i", $id);
        mysqli_stmt_execute($stmt);
        $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));

        if (!$row) {
            return ['status' => 'error', 'message' => 'Manual sale not found'];
        }

        return ['status' => 'success', 'data' => manual_sale_row($row)];
    }
}

if (!function_exists('adminCreateManualSale')) {
    function adminCreateManualSale($con, $adminData) {
        $body = read_json_body();

        $studentName = trim($body['student_name'] ?? '');
        $itemName = trim($body['item_name'] ?? '');

        if ($studentName === '' || $itemName === '') {
            return ['status' => 'error', 'message' => 'student_name and item_name are required'];
        }

        $phone = trim($body['phone'] ?? '');
        $dial = ltrim(trim($body['phone_country_code'] ?? ''), '+');
        $itemType = manual_sale_enum_value($body['item_type'] ?? null, 'item_type', 'course');
        $channel = manual_sale_enum_value($body['channel'] ?? null, 'channel', 'whatsapp');
        $status = manual_sale_enum_value($body['status'] ?? null, 'status', 'pending');
        $itemId = isset($body['item_id']) && (int)$body['item_id'] > 0 ? (int)$body['item_id'] : null;
        $studentId = isset($body['student_id']) && (int)$body['student_id'] > 0 ? (int)$body['student_id'] : null;
        $amount = (float)($body['amount'] ?? 0);
        $currency = strtoupper(trim($body['currency'] ?? 'EGP')) ?: 'EGP';
        $note = trim($body['note'] ?? '');
        $paidAt = trim($body['paid_at'] ?? '') ?: null;
        $createdBy = (int)($adminData['id'] ?? 0) ?: null;

        $stmt = mysqli_prepare($con, "
            INSERT INTO manual_sales
                (student_name, phone, phone_country_code, item_type, item_name, item_id,
                 channel, status, amount, currency, student_id, note, created_by_id, paid_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        if (!$stmt) {
            return ['status' => 'error', 'message' => 'Failed to prepare manual sale insert: ' . mysqli_error($con)];
        }
        mysqli_stmt_bind_param(
            $stmt, "sssssissdsisis",
            $studentName, $phone, $dial, $itemType, $itemName, $itemId,
            $channel, $status, $amount, $currency, $studentId, $note, $createdBy, $paidAt
        );

        if (!mysqli_stmt_execute($stmt)) {
            return ['status' => 'error', 'message' => 'Failed to create the manual sale: ' . mysqli_error($con)];
        }

        return [
            'status' => 'success',
            'message' => 'Manual sale recorded',
            'data' => ['id' => mysqli_insert_id($con)],
        ];
    }
}

if (!function_exists('adminUpdateManualSale')) {
    function adminUpdateManualSale($con) {
        $body = read_json_body();
        $id = (int)($body['id'] ?? $_GET['id'] ?? 0);

        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'Manual sale ID is required'];
        }

        $fields = [];
        $types = '';
        $values = [];

        // Only what was sent is written, so changing one cell does not blank the rest of the
        // row - and a field sent empty really does empty it.
        foreach (['student_name', 'phone', 'item_name', 'currency', 'note', 'paid_at'] as $text) {
            if (array_key_exists($text, $body)) {
                $fields[] = "{$text} = ?";
                $types .= 's';
                $value = trim((string)$body[$text]);
                $values[] = ($text === 'paid_at' && $value === '') ? null : $value;
            }
        }

        if (array_key_exists('phone_country_code', $body)) {
            $fields[] = 'phone_country_code = ?';
            $types .= 's';
            $values[] = ltrim(trim((string)$body['phone_country_code']), '+');
        }

        foreach (['item_type' => 'course', 'channel' => 'whatsapp', 'status' => 'pending'] as $field => $default) {
            if (array_key_exists($field, $body)) {
                $fields[] = "{$field} = ?";
                $types .= 's';
                $values[] = manual_sale_enum_value($body[$field], $field, $default);
            }
        }

        if (array_key_exists('amount', $body)) {
            $fields[] = 'amount = ?';
            $types .= 'd';
            $values[] = (float)$body['amount'];
        }

        foreach (['item_id', 'student_id'] as $ref) {
            if (array_key_exists($ref, $body)) {
                $fields[] = "{$ref} = ?";
                $types .= 'i';
                $values[] = (int)$body[$ref] > 0 ? (int)$body[$ref] : null;
            }
        }

        if (empty($fields)) {
            return ['status' => 'error', 'message' => 'Nothing to update'];
        }

        $types .= 'i';
        $values[] = $id;

        $stmt = mysqli_prepare($con, "UPDATE manual_sales SET " . implode(', ', $fields) . " WHERE id = ?");
        if (!$stmt) {
            return ['status' => 'error', 'message' => 'Failed to prepare manual sale update: ' . mysqli_error($con)];
        }
        mysqli_stmt_bind_param($stmt, $types, ...$values);

        if (!mysqli_stmt_execute($stmt)) {
            return ['status' => 'error', 'message' => 'Failed to update the manual sale: ' . mysqli_error($con)];
        }

        return ['status' => 'success', 'message' => 'Manual sale updated'];
    }
}

if (!function_exists('adminDeleteManualSale')) {
    function adminDeleteManualSale($con) {
        $body = read_json_body();
        $id = (int)($body['id'] ?? $_GET['id'] ?? 0);

        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'Manual sale ID is required'];
        }

        $stmt = mysqli_prepare($con, "DELETE FROM manual_sales WHERE id = ?");
        mysqli_stmt_bind_param($stmt, "i", $id);

        if (!mysqli_stmt_execute($stmt)) {
            return ['status' => 'error', 'message' => 'Failed to delete the manual sale: ' . mysqli_error($con)];
        }

        if (mysqli_stmt_affected_rows($stmt) === 0) {
            return ['status' => 'error', 'message' => 'Manual sale not found'];
        }

        return ['status' => 'success', 'message' => 'Manual sale deleted'];
    }
}
