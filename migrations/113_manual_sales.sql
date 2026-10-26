-- The manual sales sheet: what the owner sold outside the platform.
--
-- `offline_payment_requests` already exists, but it is a different thing: the student files
-- it from their own account, against a real course row, and the admin only approves or
-- refuses. This is the opposite direction - a student writes on WhatsApp or Instagram, pays
-- the owner directly, and the owner writes the sale down afterwards. There is often no
-- account on the platform at all yet, so nothing here may depend on one.
--
-- Hence the free text: a name and a subscription name are typed, not chosen. `student_id` and
-- `item_id` are there for the cases where the person does have an account or the thing sold
-- is a real course, so a row can be tied to them later without being blocked on it now.
--
-- Additive: a new table on its own. Nothing existing is touched and no response changes shape.

CREATE TABLE IF NOT EXISTS `manual_sales` (
    `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,

    `student_name` VARCHAR(191) NOT NULL,
    -- Stored apart from the number so the sheet can be filtered by country, and so a number
    -- keeps its dial code when it is exported or dialled.
    `phone` VARCHAR(30) DEFAULT NULL,
    `phone_country_code` VARCHAR(8) DEFAULT NULL COMMENT 'Dial code without the +',

    `item_type` ENUM('course','package','book') NOT NULL DEFAULT 'course',
    `item_name` VARCHAR(255) NOT NULL,
    -- Optional: set when the thing sold matches a real row, left null when it does not.
    `item_id` BIGINT(20) UNSIGNED DEFAULT NULL,

    `channel` ENUM('facebook','instagram','whatsapp','other') NOT NULL DEFAULT 'whatsapp',
    `status` ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',

    -- Not asked for, but a payment record that cannot be totalled is a list, not a ledger.
    -- Both are optional, so a row can be written before the money is settled.
    `amount` DECIMAL(14,3) NOT NULL DEFAULT 0.000,
    `currency` VARCHAR(10) NOT NULL DEFAULT 'EGP',

    `student_id` BIGINT(20) UNSIGNED DEFAULT NULL COMMENT 'Linked platform account, when there is one',
    `note` TEXT DEFAULT NULL,

    `created_by_id` BIGINT(20) UNSIGNED DEFAULT NULL COMMENT 'The admin who wrote the row',
    `paid_at` DATETIME DEFAULT NULL COMMENT 'When the money arrived, as the owner remembers it',
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (`id`),
    KEY `idx_manual_sales_status` (`status`),
    KEY `idx_manual_sales_channel` (`channel`),
    KEY `idx_manual_sales_item_type` (`item_type`),
    KEY `idx_manual_sales_student` (`student_id`),
    KEY `idx_manual_sales_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- No foreign key on `student_id`. The whole point is that most of these people are not in
-- `students` yet, and a constraint would turn an optional link into a requirement.

INSERT INTO `permissions` (`code`, `name`, `module`, `description`) VALUES
('manage_manual_sales', 'Manage Manual Sales', 'manual_sales', 'Record and review sales made outside the platform')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `module` = VALUES(`module`);

INSERT INTO `permissions_translations` (`permission_id`, `language_id`, `name`, `description`)
SELECT p.id, 1, 'إدارة المبيعات اليدوية', 'تسجيل ومراجعة المبيعات التي تتم خارج المنصّة'
FROM `permissions` p WHERE p.code = 'manage_manual_sales'
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `permissions_translations` (`permission_id`, `language_id`, `name`, `description`)
SELECT p.id, 2, 'Manage Manual Sales', 'Record and review sales made outside the platform'
FROM `permissions` p WHERE p.code = 'manage_manual_sales'
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 1, p.id FROM `permissions` p WHERE p.code = 'manage_manual_sales'
ON DUPLICATE KEY UPDATE `role_id` = VALUES(`role_id`);
