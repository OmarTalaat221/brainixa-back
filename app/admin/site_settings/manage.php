<?php
require_once __DIR__ . '/../../../helpers/functions.php';
require_once __DIR__ . '/../../../helpers/language.php';
require_once __DIR__ . '/../../../helpers/entities.php';
require_once __DIR__ . '/../../../helpers/app_settings.php';
require_once __DIR__ . '/../../../helpers/pricing.php';

if (!function_exists('ensure_site_settings_schema')) {
    function ensure_site_settings_schema($con): void {
    }
}

if (!function_exists('adminGetSiteSettings')) {
    function adminGetSiteSettings($con) {
        $res = mysqli_query($con, "SELECT setting_key, setting_value FROM site_settings");
        $settings = [];
        if ($res) {
            while ($row = mysqli_fetch_assoc($res)) {
                $settings[$row['setting_key']] = $row['setting_value'];
            }
        }
        return ['status' => 'success', 'data' => $settings];
    }
}

/**
 * Rejects values that would break something downstream rather than storing them and letting the
 * damage show up somewhere else.
 *
 * Only the keys with a real contract are checked. Everything else - the landing page copy, the
 * stats labels - is free text by design, and a whitelist here would quietly stop the website
 * editor from saving.
 *
 * Returns the error in the language of the request, or null when the value is acceptable.
 */
if (!function_exists('validate_site_setting')) {
    function validate_site_setting(string $key, string $value, $con = null): ?string {
        $value = trim($value);
        $t = function (string $ar, string $en) use ($con) {
            return app_text($con, $ar, $en);
        };

        switch ($key) {
            case 'whatsapp_number':
                if ($value === '') return null;
                $digits = preg_replace('/\D/', '', $value);
                // wa.me needs the country code, so a local number opens a chat with nobody and
                // support is left wondering why no messages arrive. Length alone does not catch
                // it - Egypt's local format (01012345678) is 11 digits, comfortably inside any
                // sane range. The leading zero is what gives it away: an international number
                // never starts with one.
                if (strlen($digits) < 10 || strlen($digits) > 15) {
                    return $t(
                        'رقم الواتساب لازم يكون بالصيغة الدولية مع كود الدولة (مثال: 201012345678).',
                        'The WhatsApp number must be in international format with a country code (e.g. 201012345678).'
                    );
                }
                if ($digits[0] === '0') {
                    return $t(
                        'رقم الواتساب مكتوب بالصيغة المحلية. اكتبه بكود الدولة من غير صفر في الأول (مثال: 201012345678 بدل 01012345678).',
                        'That is a local WhatsApp number. Use the country code and drop the leading zero (201012345678, not 01012345678).'
                    );
                }
                return null;

            case 'support_email':
                if ($value === '') return null;
                if (!filter_var($value, FILTER_VALIDATE_EMAIL)) {
                    return $t('بريد الدعم الفني غير صالح.', 'The support email address is not valid.');
                }
                return null;

            case 'facebook_link':
            case 'instagram_link':
            case 'youtube_link':
            case 'tiktok_link':
            case 'telegram_link':
                if ($value === '') return null;
                if (!filter_var($value, FILTER_VALIDATE_URL) || !preg_match('#^https?://#i', $value)) {
                    return $t(
                        'الروابط لازم تبدأ بـ http:// أو https://',
                        'Links must start with http:// or https://'
                    );
                }
                return null;

            case 'max_login_attempts':
                if (!ctype_digit($value) || (int)$value < 1 || (int)$value > 50) {
                    return $t(
                        'عدد محاولات الدخول لازم يكون رقم بين 1 و 50.',
                        'The number of allowed sign-in attempts must be between 1 and 50.'
                    );
                }
                return null;

            case 'login_lockout_minutes':
                if (!ctype_digit($value) || (int)$value < 1 || (int)$value > 1440) {
                    return $t(
                        'مدة الإيقاف لازم تكون بين دقيقة و 1440 دقيقة (24 ساعة).',
                        'The lockout duration must be between 1 and 1440 minutes (24 hours).'
                    );
                }
                return null;

            case 'max_devices_per_student':
                if (!ctype_digit($value) || (int)$value < 1 || (int)$value > 50) {
                    return $t(
                        'عدد الأجهزة لازم يكون رقم بين 1 و 50.',
                        'The number of devices must be between 1 and 50.'
                    );
                }
                return null;

            // The currency everything falls back to. Checked against the currencies table, not
            // just its shape: a base currency nothing can name would put a three-letter code in
            // front of every price on the platform, including the ones nobody set a country
            // price for - which is most of them.
            case 'base_currency':
                if (!preg_match('/^[A-Z]{3}$/', strtoupper($value))) {
                    return $t('العملة الأساسية لازم تكون كود من 3 حروف زي USD.', 'The base currency must be a three-letter code such as USD.');
                }
                if ($con && !currency_info($con, strtoupper($value))['is_active']) {
                    return $t('العملة دي مش موجودة أو مش مفعّلة.', 'That currency does not exist or is not active.');
                }
                return null;

            // A URL with {ip} in it. Without the placeholder every lookup would ask about the
            // same address, so the check is for the placeholder as much as for the URL.
            case 'geoip_provider_url':
                if ($value === '') return null;
                if (!filter_var($value, FILTER_VALIDATE_URL) || !preg_match('#^https?://#i', $value)) {
                    return $t('رابط خدمة تحديد الدولة لازم يبدأ بـ http:// أو https://', 'The geo lookup URL must start with http:// or https://');
                }
                if (strpos($value, '{ip}') === false) {
                    return $t('الرابط لازم يحتوي على {ip} مكان عنوان الزائر.', 'The URL must contain {ip} where the visitor address goes.');
                }
                return null;

            case 'registration_enabled':
            case 'login_lockout_enabled':
            case 'student_device_limit_enabled':
            case 'country_pricing_enabled':
            case 'geoip_lookup_enabled':
            case 'announcement_bar_enabled':
                if (!in_array($value, ['0', '1'], true)) {
                    return $t(
                        'قيمة المفتاح ' . $key . ' لازم تكون 0 أو 1.',
                        'The value of ' . $key . ' must be 0 or 1.'
                    );
                }
                return null;

            // A JSON array of {text_ar, text_en} pairs. Rejected outright rather than silently
            // dropped, so a malformed payload never results in the admin saving "successfully"
            // while the bar quietly stops showing anything.
            case 'announcement_bar_items':
                if ($value === '') return null;
                $decoded = json_decode($value, true);
                if (!is_array($decoded)) {
                    return $t(
                        'قائمة الإعلانات غير صالحة.',
                        'The announcement list is not valid.'
                    );
                }
                if (count($decoded) > 20) {
                    return $t(
                        'الحد الأقصى 20 إعلان في نفس الوقت.',
                        'A maximum of 20 announcements at a time is allowed.'
                    );
                }
                foreach ($decoded as $item) {
                    if (!is_array($item)) {
                        return $t(
                            'قائمة الإعلانات غير صالحة.',
                            'The announcement list is not valid.'
                        );
                    }
                }
                return null;

            // Both languages are required, not just Arabic. A refused user is served the message
            // in the language they asked for, so leaving one side blank means half the audience
            // reads the wrong language - or, if both were blank, nothing at all.
            case 'registration_disabled_message_ar':
                if ($value === '') {
                    return $t(
                        'رسالة إيقاف التسجيل بالعربي مينفعش تبقى فاضية.',
                        'The Arabic registration-closed message cannot be empty.'
                    );
                }
                return null;

            case 'registration_disabled_message_en':
                if ($value === '') {
                    return $t(
                        'رسالة إيقاف التسجيل بالإنجليزي مينفعش تبقى فاضية.',
                        'The English registration-closed message cannot be empty.'
                    );
                }
                return null;
        }

        return null;
    }
}

if (!function_exists('adminUpdateSiteSettings')) {
    function adminUpdateSiteSettings($con) {
        $body = read_json_body();
        $inputData = !empty($body) ? $body : $_POST;

        if (empty($inputData) || !is_array($inputData)) {
            return ['status' => 'error', 'message' => 'No settings data provided'];
        }

        // Validated up front, before a single row is written: a half-saved settings form leaves
        // the platform in a state nobody chose.
        $errors = [];
        foreach ($inputData as $key => $val) {
            if (!is_string($key)) continue;
            if (is_array($val) || is_object($val)) continue;
            $error = validate_site_setting($key, (string)$val, $con);
            if ($error !== null) $errors[$key] = $error;
        }

        if ($errors) {
            return [
                'status' => 'error',
                'message' => implode(' ', array_values($errors)),
                'errors' => $errors,
            ];
        }

        // Moving the base currency reprices the whole platform, because `courses.price` and
        // `course_books.price` are bare numbers whose currency is whatever this setting says. The
        // adoption runs here rather than behind its own endpoint so it cannot be stepped around by
        // posting the key straight to this one - which is exactly how it would be stepped around.
        // See helpers/base_currency.php.
        require_once __DIR__ . '/../../../helpers/base_currency.php';

        $currencyMove = null;
        if (array_key_exists('base_currency', $inputData)) {
            $target = strtoupper(trim((string)$inputData['base_currency']));
            $current = pricing_base_currency($con);

            if ($target !== '' && $target !== $current) {
                // Before the setting is written: a failure here leaves the platform still
                // describing its prices with the currency they were entered in.
                $entered = $inputData['base_currency_prices'] ?? [];
                if (is_string($entered)) {
                    $decoded = json_decode($entered, true);
                    $entered = is_array($decoded) ? $decoded : [];
                }

                $currencyMove = base_currency_adopt($con, $target, is_array($entered) ? $entered : []);
                $currencyMove['from'] = $current;
                $currencyMove['to'] = $target;

                // Refused, and nothing written. Saving the setting now would do the exact thing
                // this guard exists to prevent: leave old figures to be re-read as a currency
                // nobody priced them in.
                if (empty($currencyMove['ok'])) {
                    $missing = $currencyMove['missing'];
                    return [
                        'status' => 'error',
                        'message' => app_text(
                            $con,
                            'ما تمّ تغيير شيء. ' . count($missing) . ' عنصر ليس له سعر بـ ' . $target . '، ولا يمكن تحويل سعره تلقائيًا — لازم تُدخل سعر كل واحد منها بالعملة الجديدة أوّلًا.',
                            'Nothing was changed. ' . count($missing) . ' item(s) have no price in ' . $target . ' and cannot be converted automatically - a price in the new currency must be entered for each of them first.'
                        ),
                        'base_currency_blocked' => [
                            'from' => $current,
                            'to' => $target,
                            'missing_count' => count($missing),
                            'missing' => $missing,
                        ],
                    ];
                }
            }
        }

        // Not a setting. It rides along with a base-currency change and is consumed above.
        unset($inputData['base_currency_prices']);

        $stmt = mysqli_prepare($con, "INSERT INTO site_settings (setting_key, setting_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)");
        if (!$stmt) {
            return ['status' => 'error', 'message' => 'Database error preparing settings update'];
        }

        foreach ($inputData as $key => $val) {
            if (!is_string($key)) continue;
            $strVal = is_array($val) || is_object($val) ? json_encode($val, JSON_UNESCAPED_UNICODE) : (string)$val;
            mysqli_stmt_bind_param($stmt, "ss", $key, $strVal);
            mysqli_stmt_execute($stmt);
        }

        $response = adminGetSiteSettings($con);

        if ($currencyMove !== null) {
            $updated = $currencyMove['updated'];

            // Every item got a price in the new currency, or this code would not be running: the
            // refusal above returns before the setting is written. So this is a plain success, and
            // the breakdown is only there for the screen to report what it did.
            $adoptedStored = 0;
            $adoptedEntered = 0;
            foreach ($updated as $row) {
                if (($row['source'] ?? '') === 'entered') $adoptedEntered++;
                else $adoptedStored++;
            }

            $response['base_currency_change'] = [
                'from' => $currencyMove['from'],
                'to' => $currencyMove['to'],
                'adopted_count' => count($updated),
                'adopted_from_stored' => $adoptedStored,
                'adopted_from_entered' => $adoptedEntered,
                'adopted' => $updated,
            ];

            $response['message'] = app_text(
                $con,
                'تم تغيير العملة الأساسية إلى ' . $currencyMove['to'] . '، و' . count($updated) . ' عنصر اتسعّر بها: ' . $adoptedStored . ' أخذ سعره المحفوظ و' . $adoptedEntered . ' بالسعر اللي كتبته.',
                'Base currency changed to ' . $currencyMove['to'] . ', and ' . count($updated) . ' item(s) are now priced in it: ' . $adoptedStored . ' took a stored price and ' . $adoptedEntered . ' took the price you entered.'
            );
        }

        return $response;
    }
}

if (!function_exists('getPublicAboutUsConfig')) {
    function getPublicAboutUsConfig($con) {
        $langInfo = get_language_info($con);
        $langCode = strtolower($langInfo['code'] ?? 'ar');

        $res = mysqli_query($con, "SELECT setting_key, setting_value FROM site_settings");
        $raw = [];
        if ($res) {
            while ($row = mysqli_fetch_assoc($res)) {
                $raw[$row['setting_key']] = $row['setting_value'];
            }
        }

        $pick = function($arKey, $enKey, $default = '') use ($raw, $langCode) {
            if ($langCode === 'en') {
                return $raw[$enKey] ?? $raw[$arKey] ?? $default;
            }
            return $raw[$arKey] ?? $raw[$enKey] ?? $default;
        };

        return [
            'status' => 'success',
            'data' => [
                'language' => $langCode,
                'header' => [
                    'title' => $pick('about_title_ar', 'about_title_en', 'من نحن'),
                    'description' => $pick('about_description_ar', 'about_description_en'),
                ],
                'stats' => [
                    'courses' => $raw['about_stats_courses'] ?? '150+',
                    'books' => $raw['about_stats_books'] ?? '40+',
                    'students' => $raw['about_stats_students'] ?? '20,000+',
                ],
                'mission' => [
                    'title' => $pick('about_mission_title_ar', 'about_mission_title_en', 'رسالتنا'),
                    'text' => $pick('about_mission_text_ar', 'about_mission_text_en'),
                ],
                'offerings' => [
                    [
                        'title' => $pick('about_offering1_title_ar', 'about_offering1_title_en', 'كورسات مباشرة'),
                        'description' => $pick('about_offering1_desc_ar', 'about_offering1_desc_en'),
                    ],
                    [
                        'title' => $pick('about_offering2_title_ar', 'about_offering2_title_en', 'كورسات مسجلة'),
                        'description' => $pick('about_offering2_desc_ar', 'about_offering2_desc_en'),
                    ],
                    [
                        'title' => $pick('about_offering3_title_ar', 'about_offering3_title_en', 'كتب تعليمية'),
                        'description' => $pick('about_offering3_desc_ar', 'about_offering3_desc_en'),
                    ]
                ],
                'values' => [
                    [
                        'title' => $pick('about_val1_title_ar', 'about_val1_title_en', 'الجودة أولاً'),
                        'description' => $pick('about_val1_desc_ar', 'about_val1_desc_en'),
                    ],
                    [
                        'title' => $pick('about_val2_title_ar', 'about_val2_title_en', 'مرونة كاملة'),
                        'description' => $pick('about_val2_desc_ar', 'about_val2_desc_en'),
                    ],
                    [
                        'title' => $pick('about_val3_title_ar', 'about_val3_title_en', 'مجتمع داعم'),
                        'description' => $pick('about_val3_desc_ar', 'about_val3_desc_en'),
                    ],
                    [
                        'title' => $pick('about_val4_title_ar', 'about_val4_title_en', 'شهادات معتمدة'),
                        'description' => $pick('about_val4_desc_ar', 'about_val4_desc_en'),
                    ],
                ],
                'cta' => [
                    'title' => $pick('about_cta_title_ar', 'about_cta_title_en'),
                    'subtitle' => $pick('about_cta_subtitle_ar', 'about_cta_subtitle_en'),
                ],
                'footer' => [
                    'description' => $pick('footer_description_ar', 'footer_description_en'),
                    'facebook' => $raw['facebook_link'] ?? '',
                    'instagram' => $raw['instagram_link'] ?? '',
                    'youtube' => $raw['youtube_link'] ?? '',
                ]
            ]
        ];
    }
}

if (!function_exists('getPublicLandingConfig')) {
    function getPublicLandingConfig($con) {
        $langInfo = get_language_info($con);
        $langCode = strtolower($langInfo['code'] ?? 'ar');
        $langId = (int)($langInfo['id'] ?? 1);

        $res = mysqli_query($con, "SELECT setting_key, setting_value FROM site_settings");
        $rawSettings = [];
        if ($res) {
            while ($row = mysqli_fetch_assoc($res)) {
                $rawSettings[$row['setting_key']] = $row['setting_value'];
            }
        }

        $settings = $rawSettings;
        $settings['lang'] = $langCode;
        $settings['hero_badge_text'] = $langCode === 'en' ? ($rawSettings['hero_badge_text_en'] ?? $rawSettings['hero_badge_text_ar'] ?? '') : ($rawSettings['hero_badge_text_ar'] ?? $rawSettings['hero_badge_text_en'] ?? '');
        $settings['hero_title'] = $langCode === 'en' ? ($rawSettings['hero_title_en'] ?? $rawSettings['hero_title_ar'] ?? '') : ($rawSettings['hero_title_ar'] ?? $rawSettings['hero_title_en'] ?? '');
        $settings['hero_subtitle'] = $langCode === 'en' ? ($rawSettings['hero_subtitle_en'] ?? $rawSettings['hero_subtitle_ar'] ?? '') : ($rawSettings['hero_subtitle_ar'] ?? $rawSettings['hero_subtitle_en'] ?? '');
        $settings['hero_primary_btn_text'] = $langCode === 'en' ? ($rawSettings['hero_primary_btn_text_en'] ?? $rawSettings['hero_primary_btn_text_ar'] ?? '') : ($rawSettings['hero_primary_btn_text_ar'] ?? $rawSettings['hero_primary_btn_text_en'] ?? '');
        $settings['hero_secondary_btn_text'] = $langCode === 'en' ? ($rawSettings['hero_secondary_btn_text_en'] ?? $rawSettings['hero_secondary_btn_text_ar'] ?? '') : ($rawSettings['hero_secondary_btn_text_ar'] ?? $rawSettings['hero_secondary_btn_text_en'] ?? '');
        $settings['stats_courses_label'] = $langCode === 'en' ? ($rawSettings['stats_courses_label_en'] ?? 'Educational Courses') : ($rawSettings['stats_courses_label_ar'] ?? 'كورس تعليمي');
        $settings['stats_books_label'] = $langCode === 'en' ? ($rawSettings['stats_books_label_en'] ?? 'Books & Notes') : ($rawSettings['stats_books_label_ar'] ?? 'كتاب ومذكرة');
        $settings['stats_teachers_label'] = $langCode === 'en' ? ($rawSettings['stats_teachers_label_en'] ?? 'Expert Teachers') : ($rawSettings['stats_teachers_label_ar'] ?? 'مدرّس متخصص');
        $settings['stats_students_label'] = $langCode === 'en' ? ($rawSettings['stats_students_label_en'] ?? 'Enrolled Students') : ($rawSettings['stats_students_label_ar'] ?? 'طالب مسجل');
        $settings['footer_description'] = $langCode === 'en' ? ($rawSettings['footer_description_en'] ?? $rawSettings['footer_description_ar'] ?? '') : ($rawSettings['footer_description_ar'] ?? $rawSettings['footer_description_en'] ?? '');

        // The scrolling announcement bar at the top of the site - off unless an admin both enables
        // it and has at least one non-empty announcement, so an empty/disabled bar never reserves
        // blank space on the page. Stored as one JSON array (text_ar/text_en pairs) under a single
        // key rather than a fixed set of columns, so the admin can list as many as they want.
        $settings['announcement_bar_enabled'] = $rawSettings['announcement_bar_enabled'] ?? '0';
        $announcementItems = json_decode($rawSettings['announcement_bar_items'] ?? '[]', true);
        $settings['announcement_bar_items'] = is_array($announcementItems)
            ? array_values(array_filter(array_map(
                function ($item) use ($langCode) {
                    $ar = trim($item['text_ar'] ?? '');
                    $en = trim($item['text_en'] ?? '');
                    return $langCode === 'en' ? ($en ?: $ar) : ($ar ?: $en);
                },
                $announcementItems
            )))
            : [];

        // The three marketing sections on the home page - the offer, the intro video and the
        // picture carousel. Their creatives were files committed into the website's repo, so
        // changing a campaign picture meant a developer and a deploy. The media is a setting
        // now; the site still falls back to the committed files when a key is empty, so an
        // untouched installation looks exactly as it did.
        //
        // Each section defaults to ENABLED when its key was never written, for the same reason:
        // these sections are on today, and adding a switch should not turn them off.
        foreach (['promo_offer_enabled', 'promo_video_enabled', 'promo_gallery_enabled'] as $flagKey) {
            $settings[$flagKey] = $rawSettings[$flagKey] ?? '1';
        }

        // Every line of copy in the three sections, not only the headings. All of it used to live
        // in the website's translation files, so changing the discount, a badge or a button meant
        // a developer and a deploy. An empty key means the website keeps the wording it shipped
        // with, so an installation that has never touched these reads exactly as it did.
        $promoTextKeys = [
            'promo_offer_badge', 'promo_offer_amount', 'promo_offer_title', 'promo_offer_subtitle',
            'promo_offer_cta', 'promo_offer_image_alt',
            'promo_video_title', 'promo_video_subtitle', 'promo_video_cta',
            'promo_gallery_title', 'promo_gallery_subtitle',
        ];

        foreach ($promoTextKeys as $textKey) {
            $settings[$textKey] = $langCode === 'en'
                ? ($rawSettings[$textKey . '_en'] ?? $rawSettings[$textKey . '_ar'] ?? '')
                : ($rawSettings[$textKey . '_ar'] ?? $rawSettings[$textKey . '_en'] ?? '');
        }

        // The two short lists: the pills under the offer, and the ticks beside the video. One
        // JSON array each, text_ar/text_en per entry - the same shape as the announcement bar, so
        // the admin can add or drop a line without a column being added for it.
        $promoList = function ($raw) use ($langCode) {
            $items = json_decode($raw ?? '[]', true);
            if (!is_array($items)) return [];

            return array_values(array_filter(array_map(
                function ($item) use ($langCode) {
                    if (!is_array($item)) {
                        $plain = trim((string)$item);
                        return $plain !== '' ? $plain : null;
                    }
                    $ar = trim($item['text_ar'] ?? '');
                    $en = trim($item['text_en'] ?? '');
                    $picked = $langCode === 'en' ? ($en ?: $ar) : ($ar ?: $en);
                    return $picked !== '' ? $picked : null;
                },
                $items
            )));
        };

        $settings['promo_offer_pills'] = $promoList($rawSettings['promo_offer_pills'] ?? '[]');
        $settings['promo_video_points'] = $promoList($rawSettings['promo_video_points'] ?? '[]');

        // The carousel. Stored as one JSON array, each entry {image, caption_ar, caption_en}.
        //
        // The served field is deliberately named `src`, NOT `image`. Every response on the way out
        // runs through format_response_images, which rewrites any value under an `image` key - and
        // any bare string in a plain list that ends in a picture extension - into an absolute URL
        // on THIS server. These pictures live on the website, not on the API, so that rewrite
        // turns '/promo/journey.jpg' into a 404. `src` is not one of the keys it touches, and an
        // array of objects is not a list of bare strings, so the path is served exactly as stored
        // - relative paths stay relative to the website, absolute URLs stay untouched.
        //
        // `promo_gallery_items` is deliberately NOT resolved here. It passes through as the raw
        // JSON string it is stored as, which a copy of the website expecting an array of URLs
        // reads as "not configured" and answers by showing the pictures it shipped with. That is
        // the right thing for it to show until it is redeployed - and far better than five broken
        // images, which is what a list of rewritten paths would have given it.
        $galleryRaw = json_decode($rawSettings['promo_gallery_items'] ?? '[]', true);
        $settings['promo_gallery_slides'] = is_array($galleryRaw)
            ? array_values(array_filter(array_map(
                function ($item) use ($langCode) {
                    // Accepts a bare URL string as well as the object, so neither side has to be
                    // redeployed in step with the other.
                    if (!is_array($item)) {
                        $plain = trim((string)$item);
                        return $plain !== '' ? ['src' => $plain, 'caption' => ''] : null;
                    }

                    $url = trim($item['image'] ?? $item['url'] ?? $item['src'] ?? '');
                    if ($url === '') return null;

                    $ar = trim($item['caption_ar'] ?? '');
                    $en = trim($item['caption_en'] ?? '');

                    return [
                        'src' => $url,
                        'caption' => $langCode === 'en' ? ($en ?: $ar) : ($ar ?: $en),
                    ];
                },
                $galleryRaw
            )))
            : [];

        $bannersRes = mysqli_query($con, "SELECT id, title_ar, title_en, image_ar, image_en, link, type FROM banners WHERE is_active = 1 ORDER BY id DESC");
        $banners = [];
        if ($bannersRes) {
            while ($bRow = mysqli_fetch_assoc($bannersRes)) {
                $bRow['title'] = $langCode === 'en' ? ($bRow['title_en'] ?: $bRow['title_ar']) : ($bRow['title_ar'] ?: $bRow['title_en']);
                $bRow['image'] = $langCode === 'en' ? ($bRow['image_en'] ?: $bRow['image_ar']) : ($bRow['image_ar'] ?: $bRow['image_en']);
                $banners[] = format_response_images($bRow);
            }
        }

        $coursesRes = mysqli_query($con, "
            SELECT c.id, c.price, c.image, c.teacher_id, c.show_on_website,
                   COALESCE((SELECT name FROM courses_translations ct WHERE ct.course_id = c.id AND ct.language_id = {$langId} LIMIT 1),
                            (SELECT name FROM courses_translations ct WHERE ct.course_id = c.id LIMIT 1), c.slug) AS name,
                   COALESCE((SELECT description FROM courses_translations ct WHERE ct.course_id = c.id AND ct.language_id = {$langId} LIMIT 1),
                            (SELECT description FROM courses_translations ct WHERE ct.course_id = c.id LIMIT 1)) AS description,
                   (SELECT name FROM teachers t WHERE t.id = c.teacher_id LIMIT 1) AS teacher_name,
                   (SELECT rating FROM teachers t WHERE t.id = c.teacher_id LIMIT 1) AS teacher_rating
            FROM courses c
            WHERE c.is_active = 1 AND c.show_on_website = 1
            ORDER BY c.id DESC
            LIMIT 10
        ");
        $websiteCourses = [];
        if ($coursesRes) {
            while ($cRow = mysqli_fetch_assoc($coursesRes)) {
                $cRow['id'] = (int)$cRow['id'];
                // NULL is "no price" (migration 130): not for sale yet, which is not the same as
                // free. `price` stays a number for every existing reader; `is_priced` is added
                // beside it so the landing page can tell the two apart, as the books already can.
                $cRow['is_priced'] = $cRow['price'] !== null;
                $cRow['price'] = (float)$cRow['price'];
                $cRow['teacher_rating'] = $cRow['teacher_rating'] !== null ? (float)$cRow['teacher_rating'] : 5.0;
                $websiteCourses[] = format_response_images($cRow);
            }
        }

        // b.cover_image, not b.image: course_books has no `image` column at all, so this whole
        // query returned false and the landing page's books section has been silently empty the
        // entire time - the "an empty library lists nothing" branch made it look intentional.
        $booksRes = mysqli_query($con, "
            SELECT b.id, b.unit_id, b.subject_id, b.course_id, b.cover_image, b.price, b.show_on_website, b.file_type,
                   COALESCE((SELECT title FROM course_books_translations bt WHERE bt.book_id = b.id AND bt.language_id = {$langId} LIMIT 1),
                            (SELECT title FROM course_books_translations bt WHERE bt.book_id = b.id LIMIT 1),
                            CONCAT('كتاب رقم ', b.id)) AS title,
                   COALESCE((SELECT description FROM course_books_translations bt WHERE bt.book_id = b.id AND bt.language_id = {$langId} LIMIT 1),
                            (SELECT description FROM course_books_translations bt WHERE bt.book_id = b.id LIMIT 1)) AS description,
                   COALESCE((SELECT t.name FROM teachers t WHERE t.id = b.created_by_id AND b.created_by_type = 'teacher' LIMIT 1), '') AS teacher_name
            FROM course_books b
            WHERE b.is_active = 1 AND b.show_on_website = 1
            ORDER BY b.id DESC
            LIMIT 10
        ");
        $websiteBooks = [];
        if ($booksRes) {
            while ($bRow = mysqli_fetch_assoc($booksRes)) {
                $bRow['id'] = (int)$bRow['id'];
                $bRow['price'] = (float)($bRow['price'] ?? 0.00);
                // The public site never gets the PDF itself. The key stays in the payload so no
                // existing client breaks on its absence, but it is always empty here: a paid book
                // whose file_path is published is a paid book anyone can download without paying.
                $bRow['file_path'] = '';
                $websiteBooks[] = format_response_images($bRow);
            }
        }

        // A bare number is not a price. Each row is priced for the country this request comes
        // from (CDN header, then geo-IP - the same rule as the student dashboard), and carries
        // `currency` and `price_formatted` beside it, so the landing page prints "50 ر.س" to a
        // visitor in Saudi Arabia instead of the base "150" with a symbol it had to guess.
        // Courses and packages used to skip this and always showed the base price.
        if (function_exists('pricing_decorate_rows')) {
            if ($websiteCourses) {
                pricing_decorate_rows($con, $websiteCourses, 'course', 0);
            }
            if ($websiteBooks) {
                pricing_decorate_rows($con, $websiteBooks, 'book', 0);
            }
        }

        $aboutUsData = getPublicAboutUsConfig($con)['data'] ?? null;

        // The landing page's hero backgrounds. Added alongside `banners` rather than replacing
        // it: `banners` is what the student app reads, and nothing already shipped may change
        // shape. A client that does not know this key simply ignores it.
        require_once __DIR__ . '/../hero_slides/manage.php';
        $heroSlides = getPublicHeroSlides($con, $langCode);

        return [
            'status' => 'success',
            'data' => [
                'language' => $langCode,
                'settings' => $settings,
                'banners' => $banners,
                'hero_slides' => $heroSlides,
                'courses' => $websiteCourses,
                'books' => $websiteBooks,
                'about_us' => $aboutUsData,
            ]
        ];
    }
}
