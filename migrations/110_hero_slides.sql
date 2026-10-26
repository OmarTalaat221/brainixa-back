-- The landing page hero's own slides, kept deliberately apart from `banners`.
--
-- The website hero was reading `banners`, and `banners` is also what the student mobile app
-- shows on its home screen (app/user/student/content/home.php). So a picture added for the
-- website appeared inside the app as well, and there was no way to have one without the other.
-- A separate table means the two can be managed separately, which is what they are.
--
-- A slide is a background: an image or a video. The headline, the paragraph and the button
-- stay where they are, in site_settings, and do not change from slide to slide - text printed
-- over artwork that already carries its own wording reads as two sentences at once.
--
-- Additive only: a new table, a new permission, no existing column touched and no existing
-- response changed, so nothing already shipped can break on it.

CREATE TABLE IF NOT EXISTS `hero_slides` (
    `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    -- A label, not a caption: it names the slide in the dashboard list and becomes the image's
    -- alt text. It is never printed over the picture.
    `title_ar` VARCHAR(255) DEFAULT NULL,
    `title_en` VARCHAR(255) DEFAULT NULL,
    -- The Arabic media is the slide; the English one is an optional alternative for visitors
    -- reading the site in English, and falls back to the Arabic when absent.
    `media_ar` VARCHAR(500) NOT NULL,
    `media_en` VARCHAR(500) DEFAULT NULL,
    `type` ENUM('image','video') NOT NULL DEFAULT 'image',
    `link` VARCHAR(500) DEFAULT NULL,
    `order_num` INT UNSIGNED NOT NULL DEFAULT 1,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_hero_slides_active_order` (`is_active`, `order_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- No seed row. An empty table is a working state: the hero falls back to its flat gradient,
-- which is exactly how the page looked before this feature existed.

INSERT INTO `permissions` (`code`, `name`, `module`, `description`) VALUES
('manage_hero_slides', 'Manage Hero Slides', 'hero_slides', 'Manage the landing page hero background slides')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `module` = VALUES(`module`);

INSERT INTO `permissions_translations` (`permission_id`, `language_id`, `name`, `description`)
SELECT p.id, 1, 'إدارة شرائح البانر الرئيسي', 'إدارة صور وفيديوهات خلفية البانر في الصفحة الرئيسية'
FROM `permissions` p WHERE p.code = 'manage_hero_slides'
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `permissions_translations` (`permission_id`, `language_id`, `name`, `description`)
SELECT p.id, 2, 'Manage Hero Slides', 'Manage the landing page hero background images and videos'
FROM `permissions` p WHERE p.code = 'manage_hero_slides'
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- Super Admin (role 1) gets it, the same way every other module permission is granted.
INSERT INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 1, p.id FROM `permissions` p WHERE p.code = 'manage_hero_slides'
ON DUPLICATE KEY UPDATE `role_id` = VALUES(`role_id`);
