-- 127_products_and_categories.sql
--
-- منتجات المتجر وتصنيفاتها.
--
-- Until now the store had no products of its own. What it sold was rows of `course_books` whose
-- `file_type` is 'physical' - a book with no file attached - which works for a printed book and
-- for nothing else. A school bag is not a book, has no subject, no course and no unit, and the
-- only thing resembling a category on `course_books` is `category enum('summary','exam')`, which
-- says whether a PDF is a summary or a past paper. There was nowhere to put a product.
--
-- So products are their own table rather than more columns bolted onto books. The two are listed
-- side by side by the store endpoint; they are not merged in the database, because a book has a
-- file, a subject and a reader, and a product has stock and a price and none of the rest.
--
-- Categories are products' own as well, NOT `course_categories`. "الكيمياء" is a course category
-- and "حقائب مدرسية" is a product category; one list holding both would be a list nobody can use
-- on either screen.
--
-- Nothing existing is altered: no column is added to `course_books`, no row is moved, and the
-- books already in the store keep selling exactly as they do today.
--
-- Safe to run more than once.


-- ─── ١) تصنيفات المنتجات ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `product_categories` (
  `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(100) NOT NULL COMMENT 'Internal handle, unique, generated from the name when not given',
  `image` VARCHAR(500) DEFAULT NULL,
  `order_num` INT(11) NOT NULL DEFAULT 1,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NULL DEFAULT current_timestamp(),
  `updated_at` TIMESTAMP NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_product_categories_code` (`code`),
  KEY `idx_product_categories_active` (`is_active`, `order_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- The name lives in the translations table, exactly as it does for course categories, so a
-- category reads correctly on an Arabic phone and an English one without a second column.
CREATE TABLE IF NOT EXISTS `product_categories_translations` (
  `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_category_id` BIGINT(20) UNSIGNED NOT NULL,
  `language_id` BIGINT(20) UNSIGNED NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `description` TEXT DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_product_category_lang` (`product_category_id`, `language_id`),
  KEY `idx_pct_lang` (`language_id`),
  CONSTRAINT `fk_pct_category` FOREIGN KEY (`product_category_id`)
      REFERENCES `product_categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ─── ٢) المنتجات ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `products` (
  `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_category_id` BIGINT(20) UNSIGNED DEFAULT NULL COMMENT 'NULL = uncategorised; a category may be deleted without taking its products with it',
  `slug` VARCHAR(191) NOT NULL,
  `sku` VARCHAR(100) DEFAULT NULL COMMENT 'The owner is own reference, not generated here',
  `price` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  -- NULL, not 0: "no discount" and "free" are different answers, and reading a missing sale
  -- price as zero would present every product as a giveaway.
  `sale_price` DECIMAL(10,2) DEFAULT NULL COMMENT 'NULL = not on sale. 0.00 = deliberately free',
  `currency` CHAR(3) NOT NULL DEFAULT 'EGP',
  -- NULL means "not tracked", which is not the same as 0 = "sold out". A made-to-order item and
  -- an item that ran out must not read alike on the card.
  `stock` INT(11) DEFAULT NULL COMMENT 'NULL = stock not tracked. 0 = out of stock',
  `image` LONGTEXT DEFAULT NULL COMMENT 'Cover image',
  `gallery` LONGTEXT DEFAULT NULL COMMENT 'JSON array of extra image paths',
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `show_on_website` TINYINT(1) NOT NULL DEFAULT 1,
  `order_num` INT(11) NOT NULL DEFAULT 1,
  `created_by_type` ENUM('admin','teacher') NOT NULL DEFAULT 'admin',
  `created_by_id` BIGINT(20) UNSIGNED DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT current_timestamp(),
  `updated_at` TIMESTAMP NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_products_slug` (`slug`),
  KEY `idx_products_category` (`product_category_id`),
  KEY `idx_products_listing` (`is_active`, `show_on_website`, `order_num`),
  CONSTRAINT `fk_products_category` FOREIGN KEY (`product_category_id`)
      REFERENCES `product_categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `products_translations` (
  `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_id` BIGINT(20) UNSIGNED NOT NULL,
  `language_id` BIGINT(20) UNSIGNED NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `description` TEXT DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_product_lang` (`product_id`, `language_id`),
  KEY `idx_pt_lang` (`language_id`),
  CONSTRAINT `fk_pt_product` FOREIGN KEY (`product_id`)
      REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ─── ٣) صلاحية إدارة المتجر ───────────────────────────────────────────────────
-- Products are gated on their own permission rather than on `manage_books`: whoever prices the
-- school bags is not necessarily whoever uploads the PDFs.
INSERT INTO `permissions` (`code`, `name`, `module`, `description`) VALUES
('manage_products', 'Manage Store Products', 'store', 'Create and price store products, and manage their categories')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `module` = VALUES(`module`);

INSERT INTO `permissions_translations` (`permission_id`, `language_id`, `name`, `description`)
SELECT p.id, 1, 'إدارة منتجات المتجر', 'إضافة المنتجات وتسعيرها وإدارة تصنيفاتها'
FROM `permissions` p WHERE p.code = 'manage_products'
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `permissions_translations` (`permission_id`, `language_id`, `name`, `description`)
SELECT p.id, 2, 'Manage Store Products', 'Create and price store products, and manage their categories'
FROM `permissions` p WHERE p.code = 'manage_products'
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- Super Admin (role 1) gets it, the same way every other module permission is granted. A super
-- admin already passes every permission check (helpers/rbac.php), so the routes work before this
-- file is applied - running it is what lets the permission be granted to anyone else.
INSERT INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 1, p.id FROM `permissions` p WHERE p.code = 'manage_products'
ON DUPLICATE KEY UPDATE `role_id` = VALUES(`role_id`);
