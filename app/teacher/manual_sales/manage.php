<?php
require_once __DIR__ . '/../../admin/manual_sales/manage.php';

/**
 * A teacher's own manual sales sheet - same feature and same table as the admin's (see
 * app/admin/manual_sales/manage.php and migrations/113_manual_sales.sql / 115), scoped to rows
 * this teacher wrote. A student who messages a teacher directly on WhatsApp/Instagram pays the
 * teacher, not the platform owner, so the teacher needs their own ledger for it - but only ever
 * their own: `created_by_type = 'teacher' AND created_by_id = <this teacher>` on every query, so
 * one teacher can never read, edit or delete another teacher's (or an admin's) rows.
 */

if (!function_exists('teacherListManualSales')) {
    function teacherListManualSales($con, $teacherData) {
        $teacherId = (int)($teacherData['id'] ?? 0);
        if ($teacherId <= 0) {
            return ['status' => 'error', 'message' => 'Unauthorized teacher token'];
        }

        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(200, (int)($_GET['limit'] ?? 20)));
        $offset = ($page - 1) * $limit;

        $where = ['created_by_type = ?', 'created_by_id = ?'];
        $params = ['teacher', $teacherId];
        $types = 'si';

        $search = trim($_GET['search'] ?? $_GET['q'] ?? '');
        if ($search !== '') {
            $where[] = '(student_name LIKE ? OR phone LIKE ? OR item_name LIKE ? OR note LIKE ?)';
            $pattern = '%' . $search . '%';
            array_push($params, $pattern, $pattern, $pattern, $pattern);
            $types .= 'ssss';
        }

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

        $whereSql = 'WHERE ' . implode(' AND ', $where);

        $total = 0;
        $countStmt = mysqli_prepare($con, "SELECT COUNT(*) AS total FROM manual_sales {$whereSql}");
        if ($countStmt) {
            mysqli_stmt_bind_param($countStmt, $types, ...$params);
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

        $stats = [
            'total_count' => 0, 'approved_count' => 0, 'pending_count' => 0, 'rejected_count' => 0,
            'approved_amount' => 0.0, 'pending_amount' => 0.0,
        ];
        $statStmt = mysqli_prepare($con, "
            SELECT status, COUNT(*) AS c, COALESCE(SUM(amount), 0) AS total
            FROM manual_sales WHERE created_by_type = 'teacher' AND created_by_id = ? GROUP BY status
        ");
        if ($statStmt) {
            mysqli_stmt_bind_param($statStmt, "i", $teacherId);
            mysqli_stmt_execute($statStmt);
            $statRes = mysqli_stmt_get_result($statStmt);
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

if (!function_exists('teacherGetManualSale')) {
    function teacherGetManualSale($con, $teacherData) {
        $teacherId = (int)($teacherData['id'] ?? 0);
        $id = (int)($_GET['id'] ?? 0);
        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'Manual sale ID is required'];
        }

        $stmt = mysqli_prepare($con, "SELECT * FROM manual_sales WHERE id = ? AND created_by_type = 'teacher' AND created_by_id = ? LIMIT 1");
        mysqli_stmt_bind_param($stmt, "ii", $id, $teacherId);
        mysqli_stmt_execute($stmt);
        $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));

        if (!$row) {
            return ['status' => 'error', 'message' => 'Manual sale not found'];
        }

        return ['status' => 'success', 'data' => manual_sale_row($row)];
    }
}

if (!function_exists('teacherCreateManualSale')) {
    function teacherCreateManualSale($con, $teacherData) {
        $teacherId = (int)($teacherData['id'] ?? 0);
        if ($teacherId <= 0) {
            return ['status' => 'error', 'message' => 'Unauthorized teacher token'];
        }

        $body = read_json_body();

        $studentName = trim($body['student_name'] ?? '');
        $itemName = trim($body['item_name'] ?? '');

        if ($studentName === '' || $itemName === '') {
            return ['status' => 'error', 'message' => 'student_name and item_name are required'];
        }

        [$phone, $dial] = manual_sale_split_phone(
            trim($body['phone'] ?? ''),
            trim($body['phone_country_code'] ?? '')
        );
        $itemType = manual_sale_enum_value($body['item_type'] ?? null, 'item_type', 'course');
        $channel = manual_sale_enum_value($body['channel'] ?? null, 'channel', 'whatsapp');
        $status = manual_sale_enum_value($body['status'] ?? null, 'status', 'pending');
        $itemId = isset($body['item_id']) && (int)$body['item_id'] > 0 ? (int)$body['item_id'] : null;
        $studentId = isset($body['student_id']) && (int)$body['student_id'] > 0 ? (int)$body['student_id'] : null;
        $amount = (float)($body['amount'] ?? 0);
        $currency = strtoupper(trim($body['currency'] ?? 'EGP')) ?: 'EGP';
        $note = trim($body['note'] ?? '');
        $paidAt = trim($body['paid_at'] ?? '') ?: null;
        $receipt = manual_sale_receipt_value($body) ?: null;

        $stmt = mysqli_prepare($con, "
            INSERT INTO manual_sales
                (student_name, phone, phone_country_code, item_type, item_name, item_id,
                 channel, status, amount, currency, student_id, note, transfer_receipt, created_by_type, created_by_id, paid_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'teacher', ?, ?)
        ");
        if (!$stmt) {
            return ['status' => 'error', 'message' => 'Failed to prepare manual sale insert: ' . mysqli_error($con)];
        }
        mysqli_stmt_bind_param(
            $stmt, "sssssissdsissis",
            $studentName, $phone, $dial, $itemType, $itemName, $itemId,
            $channel, $status, $amount, $currency, $studentId, $note, $receipt, $teacherId, $paidAt
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

if (!function_exists('teacherUpdateManualSale')) {
    function teacherUpdateManualSale($con, $teacherData) {
        $teacherId = (int)($teacherData['id'] ?? 0);
        $body = read_json_body();
        $id = (int)($body['id'] ?? $_GET['id'] ?? 0);

        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'Manual sale ID is required'];
        }

        $ownsStmt = mysqli_prepare($con, "SELECT id FROM manual_sales WHERE id = ? AND created_by_type = 'teacher' AND created_by_id = ? LIMIT 1");
        mysqli_stmt_bind_param($ownsStmt, "ii", $id, $teacherId);
        mysqli_stmt_execute($ownsStmt);
        if (!mysqli_fetch_assoc(mysqli_stmt_get_result($ownsStmt))) {
            return ['status' => 'error', 'message' => 'Manual sale not found'];
        }

        $fields = [];
        $types = '';
        $values = [];

        foreach (['student_name', 'item_name', 'currency', 'note', 'paid_at'] as $text) {
            if (array_key_exists($text, $body)) {
                $fields[] = "{$text} = ?";
                $types .= 's';
                $value = trim((string)$body[$text]);
                $values[] = ($text === 'paid_at' && $value === '') ? null : $value;
            }
        }

        if (array_key_exists('phone', $body) || array_key_exists('phone_country_code', $body)) {
            [$phone, $dial] = manual_sale_split_phone(
                trim((string)($body['phone'] ?? '')),
                trim((string)($body['phone_country_code'] ?? ''))
            );
            $fields[] = 'phone = ?';
            $types .= 's';
            $values[] = $phone;
            $fields[] = 'phone_country_code = ?';
            $types .= 's';
            $values[] = $dial;
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

        // A receipt sent empty really does come off the row; one not mentioned is left alone.
        $receipt = manual_sale_receipt_value($body);
        if ($receipt !== null) {
            $fields[] = 'transfer_receipt = ?';
            $types .= 's';
            $values[] = $receipt !== '' ? $receipt : null;
        }

        if (empty($fields)) {
            return ['status' => 'error', 'message' => 'Nothing to update'];
        }

        $types .= 'ii';
        $values[] = $id;
        $values[] = $teacherId;

        $stmt = mysqli_prepare($con, "UPDATE manual_sales SET " . implode(', ', $fields) . " WHERE id = ? AND created_by_type = 'teacher' AND created_by_id = ?");
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

if (!function_exists('teacherDeleteManualSale')) {
    function teacherDeleteManualSale($con, $teacherData) {
        $teacherId = (int)($teacherData['id'] ?? 0);
        $body = read_json_body();
        $id = (int)($body['id'] ?? $_GET['id'] ?? 0);

        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'Manual sale ID is required'];
        }

        $stmt = mysqli_prepare($con, "DELETE FROM manual_sales WHERE id = ? AND created_by_type = 'teacher' AND created_by_id = ?");
        mysqli_stmt_bind_param($stmt, "ii", $id, $teacherId);

        if (!mysqli_stmt_execute($stmt)) {
            return ['status' => 'error', 'message' => 'Failed to delete the manual sale: ' . mysqli_error($con)];
        }

        if (mysqli_stmt_affected_rows($stmt) === 0) {
            return ['status' => 'error', 'message' => 'Manual sale not found'];
        }

        return ['status' => 'success', 'message' => 'Manual sale deleted'];
    }
}
