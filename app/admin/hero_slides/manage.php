<?php
require_once __DIR__ . '/../../../helpers/language.php';
require_once __DIR__ . '/../../../helpers/functions.php';
require_once __DIR__ . '/../../../helpers/upload.php';

/**
 * The landing page hero's background slides.
 *
 * Kept apart from `banners` on purpose: that table feeds the student mobile app's home screen
 * as well, so a picture meant for the website used to turn up inside the app with no way to
 * separate the two. See migrations/110_hero_slides.sql.
 *
 * A slide is a background and nothing else - an image or a video. The headline and the button
 * live in site_settings and stay put while the picture changes behind them.
 */

if (!function_exists('heroSlideRow')) {
    function heroSlideRow(array $row): array {
        $row['id'] = (int)$row['id'];
        $row['order_num'] = (int)$row['order_num'];
        $row['is_active'] = (int)$row['is_active'];

        // The stored value is a path relative to the API; the dashboard and the website both
        // need something they can load directly.
        $row['media_ar'] = format_response_images($row['media_ar']);
        $row['media_en'] = !empty($row['media_en']) ? format_response_images($row['media_en']) : null;

        return $row;
    }
}

if (!function_exists('adminListHeroSlides')) {
    function adminListHeroSlides($con) {
        $activeFilter = isset($_GET['is_active']) ? (int)$_GET['is_active'] : null;

        $sql = "SELECT id, title_ar, title_en, subtitle_ar, subtitle_en, btn_text_ar, btn_text_en, media_ar, media_en, type, link, order_num, is_active,
                       created_at, updated_at
                FROM hero_slides";
        if ($activeFilter === 0 || $activeFilter === 1) {
            $sql .= " WHERE is_active = " . $activeFilter;
        }
        $sql .= " ORDER BY order_num ASC, id ASC";

        $res = mysqli_query($con, $sql);
        if (!$res) {
            return ['status' => 'error', 'message' => 'Failed to read hero slides: ' . mysqli_error($con)];
        }

        $rows = [];
        $active = 0;
        $videos = 0;
        while ($row = mysqli_fetch_assoc($res)) {
            $row = heroSlideRow($row);
            if ($row['is_active'] === 1) $active++;
            if ($row['type'] === 'video') $videos++;
            $rows[] = $row;
        }

        return [
            'status' => 'success',
            'data' => $rows,
            'statistics' => [
                'total_count' => count($rows),
                'active_count' => $active,
                'inactive_count' => count($rows) - $active,
                'video_count' => $videos,
                'image_count' => count($rows) - $videos,
            ],
        ];
    }
}

if (!function_exists('adminGetHeroSlide')) {
    function adminGetHeroSlide($con) {
        $id = (int)($_GET['id'] ?? 0);
        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'Hero slide ID is required'];
        }

        $stmt = mysqli_prepare($con, "SELECT id, title_ar, title_en, subtitle_ar, subtitle_en, btn_text_ar, btn_text_en, media_ar, media_en, type, link,
                                             order_num, is_active, created_at, updated_at
                                      FROM hero_slides WHERE id = ? LIMIT 1");
        mysqli_stmt_bind_param($stmt, "i", $id);
        mysqli_stmt_execute($stmt);
        $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));

        if (!$row) {
            return ['status' => 'error', 'message' => 'Hero slide not found'];
        }

        return ['status' => 'success', 'data' => heroSlideRow($row)];
    }
}

if (!function_exists('adminCreateHeroSlide')) {
    function adminCreateHeroSlide($con) {
        $body = read_json_body();

        $titleAr = trim($body['title_ar'] ?? '');
        $titleEn = trim($body['title_en'] ?? '');
        $subtitleAr = trim($body['subtitle_ar'] ?? '');
        $subtitleEn = trim($body['subtitle_en'] ?? '');
        $btnTextAr = trim($body['btn_text_ar'] ?? '');
        $btnTextEn = trim($body['btn_text_en'] ?? '');
        $link = trim($body['link'] ?? '');
        $type = strtolower(trim($body['type'] ?? 'image'));
        if (!in_array($type, ['image', 'video'], true)) {
            $type = 'image';
        }
        $orderNum = isset($body['order_num']) && (int)$body['order_num'] > 0 ? (int)$body['order_num'] : 1;
        $isActive = isset($body['is_active']) ? (int)(bool)$body['is_active'] : 1;

        // process_image_input handles a multipart upload, a data URI and a plain URL alike, and
        // accepts video as well as image files despite the name.
        $mediaAr = process_image_input(
            $body['media_ar'] ?? $body['media'] ?? null,
            'hero_slides',
            $_FILES['media_ar'] ?? $_FILES['media'] ?? null
        );
        $mediaEn = process_image_input(
            $body['media_en'] ?? null,
            'hero_slides',
            $_FILES['media_en'] ?? null
        );

        if (empty($mediaAr)) {
            return ['status' => 'error', 'message' => 'The slide media (media_ar) is required'];
        }

        $stmt = mysqli_prepare($con, "
            INSERT INTO hero_slides (title_ar, title_en, subtitle_ar, subtitle_en, btn_text_ar, btn_text_en,
                                     media_ar, media_en, type, link, order_num, is_active)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        if (!$stmt) {
            return ['status' => 'error', 'message' => 'Failed to prepare hero slide insert: ' . mysqli_error($con)];
        }

        $linkOrNull = $link !== '' ? $link : null;
        mysqli_stmt_bind_param(
            $stmt, "ssssssssssii",
            $titleAr, $titleEn, $subtitleAr, $subtitleEn, $btnTextAr, $btnTextEn,
            $mediaAr, $mediaEn, $type, $linkOrNull, $orderNum, $isActive
        );

        if (!mysqli_stmt_execute($stmt)) {
            return ['status' => 'error', 'message' => 'Failed to create the hero slide: ' . mysqli_error($con)];
        }

        return [
            'status' => 'success',
            'message' => 'Hero slide created',
            'data' => ['id' => mysqli_insert_id($con)],
        ];
    }
}

if (!function_exists('adminUpdateHeroSlide')) {
    function adminUpdateHeroSlide($con) {
        $body = read_json_body();
        $id = (int)($body['id'] ?? $_GET['id'] ?? 0);

        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'Hero slide ID is required'];
        }

        $fields = [];
        $types = '';
        $values = [];

        // Only what was sent is touched. A dashboard that edits the order of a slide must not
        // blank its picture just because the form did not resend the file.
        if (array_key_exists('title_ar', $body)) {
            $fields[] = 'title_ar = ?'; $types .= 's'; $values[] = trim($body['title_ar']);
        }
        if (array_key_exists('title_en', $body)) {
            $fields[] = 'title_en = ?'; $types .= 's'; $values[] = trim($body['title_en']);
        }
        foreach (['subtitle_ar', 'subtitle_en', 'btn_text_ar', 'btn_text_en'] as $copyField) {
            if (array_key_exists($copyField, $body)) {
                $fields[] = "$copyField = ?"; $types .= 's'; $values[] = trim($body[$copyField]);
            }
        }
        if (array_key_exists('link', $body)) {
            $link = trim($body['link']);
            $fields[] = 'link = ?'; $types .= 's'; $values[] = $link !== '' ? $link : null;
        }
        if (array_key_exists('type', $body)) {
            $type = strtolower(trim($body['type']));
            if (in_array($type, ['image', 'video'], true)) {
                $fields[] = 'type = ?'; $types .= 's'; $values[] = $type;
            }
        }
        if (array_key_exists('order_num', $body)) {
            $fields[] = 'order_num = ?'; $types .= 'i'; $values[] = max(1, (int)$body['order_num']);
        }
        if (array_key_exists('is_active', $body)) {
            $fields[] = 'is_active = ?'; $types .= 'i'; $values[] = (int)(bool)$body['is_active'];
        }

        $mediaAr = process_image_input(
            $body['media_ar'] ?? null,
            'hero_slides',
            $_FILES['media_ar'] ?? $_FILES['media'] ?? null
        );
        if (!empty($mediaAr)) {
            $fields[] = 'media_ar = ?'; $types .= 's'; $values[] = $mediaAr;
        }

        $mediaEn = process_image_input(
            $body['media_en'] ?? null,
            'hero_slides',
            $_FILES['media_en'] ?? null
        );
        if (!empty($mediaEn)) {
            $fields[] = 'media_en = ?'; $types .= 's'; $values[] = $mediaEn;
        }

        if (empty($fields)) {
            return ['status' => 'error', 'message' => 'Nothing to update'];
        }

        $types .= 'i';
        $values[] = $id;

        $stmt = mysqli_prepare($con, "UPDATE hero_slides SET " . implode(', ', $fields) . " WHERE id = ?");
        if (!$stmt) {
            return ['status' => 'error', 'message' => 'Failed to prepare hero slide update: ' . mysqli_error($con)];
        }
        mysqli_stmt_bind_param($stmt, $types, ...$values);

        if (!mysqli_stmt_execute($stmt)) {
            return ['status' => 'error', 'message' => 'Failed to update the hero slide: ' . mysqli_error($con)];
        }

        return ['status' => 'success', 'message' => 'Hero slide updated'];
    }
}

if (!function_exists('adminDeleteHeroSlide')) {
    function adminDeleteHeroSlide($con) {
        $body = read_json_body();
        $id = (int)($body['id'] ?? $_GET['id'] ?? 0);

        if ($id <= 0) {
            return ['status' => 'error', 'message' => 'Hero slide ID is required'];
        }

        $stmt = mysqli_prepare($con, "DELETE FROM hero_slides WHERE id = ?");
        mysqli_stmt_bind_param($stmt, "i", $id);

        if (!mysqli_stmt_execute($stmt)) {
            return ['status' => 'error', 'message' => 'Failed to delete the hero slide: ' . mysqli_error($con)];
        }

        if (mysqli_stmt_affected_rows($stmt) === 0) {
            return ['status' => 'error', 'message' => 'Hero slide not found'];
        }

        return ['status' => 'success', 'message' => 'Hero slide deleted'];
    }
}

if (!function_exists('getPublicHeroSlides')) {
    /**
     * The active slides, in order, resolved for one language. Used by the public endpoint and
     * folded into /site-settings so the website does not need a second request.
     */
    function getPublicHeroSlides($con, string $langCode = 'ar'): array {
        // Guarded, because this function is called from /site-settings - the endpoint the
        // whole public website and the mobile app read. If the code reaches a server where
        // migration 110 has not been run yet, the table is simply not there; under PHP 8.1's
        // default mysqli mode that raises an exception rather than returning false, and an
        // uncaught one would take the endpoint down with it. An absent table has to read as
        // "no slides", which is a state the hero already knows how to render.
        try {
            // is_active is selected even though the WHERE already pins it: heroSlideRow()
            // casts that column, and leaving it out would make it read a key that is not there.
            $res = @mysqli_query($con, "SELECT id, title_ar, title_en, subtitle_ar, subtitle_en, btn_text_ar, btn_text_en, media_ar, media_en, type, link, order_num, is_active
                                        FROM hero_slides
                                        WHERE is_active = 1
                                        ORDER BY order_num ASC, id ASC");
        } catch (\Throwable $e) {
            return [];
        }
        $slides = [];
        if ($res) {
            while ($row = mysqli_fetch_assoc($res)) {
                $row = heroSlideRow($row);
                // One resolved value per piece of copy, so the website does not repeat the
                // language rules. Each falls back to the other language before giving up,
                // because a slide written in Arabic only should still read in Arabic for an
                // English visitor rather than vanish.
                foreach (['title', 'subtitle', 'btn_text'] as $field) {
                    $ar = $row[$field . '_ar'] ?? '';
                    $en = $row[$field . '_en'] ?? '';
                    $row[$field] = $langCode === 'en' ? ($en ?: $ar) : ($ar ?: $en);
                }
                // English falls back to the Arabic file, which is the usual case: most artwork
                // carries no words at all and one copy serves both.
                $row['media'] = $langCode === 'en'
                    ? ($row['media_en'] ?: $row['media_ar'])
                    : ($row['media_ar'] ?: $row['media_en']);
                $slides[] = $row;
            }
        }

        return $slides;
    }
}

if (!function_exists('publicHeroSlides')) {
    function publicHeroSlides($con) {
        $langCode = strtolower(trim($_GET['lang'] ?? $_SERVER['HTTP_ACCEPT_LANGUAGE'] ?? 'ar'));
        $langCode = str_starts_with($langCode, 'en') ? 'en' : 'ar';

        return ['status' => 'success', 'data' => getPublicHeroSlides($con, $langCode)];
    }
}
