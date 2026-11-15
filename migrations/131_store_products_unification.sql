-- 131: one store. The store's books move into `products`.
--
-- Until now the store was two things: the original one, standalone rows of `course_books` (a
-- book, a PDF, or a physical item with `file_type = 'physical'`), and `products` (migration 127),
-- which had the better shape - categories, stock, sale price, gallery, any file type - but no way
-- to be bought. From here `products` is the store, and `course_books` holds only the files that
-- belong to a course or a unit.
--
-- WHAT MOVES: every `course_books` row with no course and no unit (`course_id IS NULL AND
-- unit_id IS NULL`), with its translations. A row tied to a course or a unit is that course's
-- content and stays.
--
-- IDS ARE KEPT. A moved book becomes the product with the SAME id. Everything that already points
-- at it by number keeps working untouched: purchases (`student_book_subscriptions`), purchase
-- requests, card and transfer payments and manual sales (`item_type = 'book'`), discount codes
-- (`discount_code_books`), country prices (`item_country_prices`, item_type 'book'), teacher
-- assignments (`book_teachers`) and reading progress - and so does the mobile app, which asks for
-- these items by their book id. To make room, the products that existed before this migration
-- are renumbered first, above the highest book id; nothing outside `products_translations`
-- referred to them yet.
--
-- THE TWO NUMBER RANGES STAY APART. `course_books` continues from 1,000,000, so a lesson file
-- created later can never share a number with a product. That matters because a few endpoints
-- (opening a file, reading progress) take an id that may be either.
--
-- NOTHING IS LOST. The moved rows are copied to `course_books_store_archive` and
-- `course_books_store_archive_translations` before they are removed from `course_books`.
--
-- PRICES: a store price is in the platform's base currency, like a course's, so the pricing by
-- country and the base-currency move treat every product the same way. `products.currency` is
-- set to the base currency on every row. The few products created before this migration were
-- entered with a currency of their own (EGP by default); their numbers are kept as they were and
-- should be checked once in the dashboard.
--
-- Safe to run more than once: each step checks whether it has already been done, and the whole
-- run is recorded in `store_unification_state`. Run it with the mysql client (it uses DELIMITER):
--
--   mysql -u campcod1_brain-ixa -p campcod1_brain-ixa < migrations/131_store_products_unification.sql

-- ---------------------------------------------------------------------------------------------
-- 1. The columns a book had and a product did not.
-- ---------------------------------------------------------------------------------------------
ALTER TABLE `products`
  ADD COLUMN IF NOT EXISTS `product_type` ENUM('physical','digital') NOT NULL DEFAULT 'physical'
      COMMENT 'physical = handed over off the platform; digital = a file the buyer opens' AFTER `product_category_id`,
  ADD COLUMN IF NOT EXISTS `subject_id` BIGINT(20) UNSIGNED DEFAULT NULL
      COMMENT 'A subscription to this subject unlocks the product, as it did for a book' AFTER `product_type`,
  ADD COLUMN IF NOT EXISTS `book_category` ENUM('summary','exam') DEFAULT NULL
      COMMENT 'For a digital book: a summary or a past paper. NULL for anything else' AFTER `subject_id`,
  ADD COLUMN IF NOT EXISTS `allow_download` TINYINT(1) NOT NULL DEFAULT 1
      COMMENT '0 = the buyer reads the file through the API and never gets its path' AFTER `file_is_public`,
  ADD COLUMN IF NOT EXISTS `link` TEXT DEFAULT NULL
      COMMENT 'An external link instead of an uploaded file' AFTER `allow_download`,
  ADD COLUMN IF NOT EXISTS `legacy_book_id` BIGINT(20) UNSIGNED DEFAULT NULL
      COMMENT 'The course_books id this product was moved from (migration 131); equals id' AFTER `link`;

-- `discount_code_books.book_id` pointed at `course_books`, with ON DELETE CASCADE: removing the
-- moved rows would have silently emptied every code that named a store item. It now names a
-- product, by the same number.
SET @fk := (SELECT CONSTRAINT_NAME FROM information_schema.TABLE_CONSTRAINTS
            WHERE CONSTRAINT_SCHEMA = DATABASE() AND TABLE_NAME = 'discount_code_books'
              AND CONSTRAINT_NAME = 'fk_discount_code_books_book' AND CONSTRAINT_TYPE = 'FOREIGN KEY' LIMIT 1);
SET @sql := IF(@fk IS NULL, 'SELECT 1', 'ALTER TABLE `discount_code_books` DROP FOREIGN KEY `fk_discount_code_books_book`');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

CREATE TABLE IF NOT EXISTS `store_unification_state` (
  `step` VARCHAR(64) NOT NULL,
  `detail` TEXT DEFAULT NULL,
  `done_at` TIMESTAMP NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`step`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `course_books_store_archive` LIKE `course_books`;
CREATE TABLE IF NOT EXISTS `course_books_store_archive_translations` LIKE `course_books_translations`;

DROP PROCEDURE IF EXISTS `brainixa_131_unify_store`;

DELIMITER $$
CREATE PROCEDURE `brainixa_131_unify_store`()
BEGIN
  DECLARE v_offset BIGINT DEFAULT 0;
  DECLARE v_base CHAR(3) DEFAULT 'EGP';
  DECLARE v_moved INT DEFAULT 0;

  SELECT COALESCE(NULLIF(UPPER(TRIM(setting_value)), ''), 'EGP') INTO v_base
    FROM site_settings WHERE setting_key = 'base_currency' LIMIT 1;

  -- 2. Renumber the products that existed before, above every book id, once. They had no type
  -- yet either: one with a file is digital.
  IF NOT EXISTS (SELECT 1 FROM store_unification_state WHERE step = 'renumber_products') THEN
    UPDATE products SET product_type = 'digital'
     WHERE file_path IS NOT NULL AND file_path <> '' AND legacy_book_id IS NULL;
    SELECT GREATEST(COALESCE(MAX(id), 0), (SELECT COALESCE(MAX(id), 0) FROM course_books)) INTO v_offset
      FROM products;
    SET FOREIGN_KEY_CHECKS = 0;
    UPDATE products_translations SET product_id = product_id + v_offset;
    UPDATE products SET id = id + v_offset;
    SET FOREIGN_KEY_CHECKS = 1;
    INSERT INTO store_unification_state (step, detail)
      VALUES ('renumber_products', CONCAT('offset ', v_offset));
  END IF;

  -- 3. Copy the store's books into products, same id, once.
  IF NOT EXISTS (SELECT 1 FROM store_unification_state WHERE step = 'copy_books') THEN
    INSERT IGNORE INTO course_books_store_archive
      SELECT * FROM course_books WHERE course_id IS NULL AND unit_id IS NULL;
    INSERT IGNORE INTO course_books_store_archive_translations
      SELECT t.* FROM course_books_translations t
      JOIN course_books b ON b.id = t.book_id
      WHERE b.course_id IS NULL AND b.unit_id IS NULL;

    INSERT INTO products
      (id, product_category_id, product_type, subject_id, book_category, slug, sku,
       price, sale_price, currency, stock, image, gallery,
       file_path, file_name, file_extension, file_size, file_is_public, allow_download, link, legacy_book_id,
       is_active, show_on_website, order_num, created_by_type, created_by_id, created_at, updated_at)
    SELECT b.id, NULL,
           IF(LOWER(COALESCE(b.file_type, '')) = 'physical', 'physical', 'digital'),
           b.subject_id,
           IF(LOWER(COALESCE(b.file_type, '')) = 'physical', NULL, b.category),
           CONCAT('store-item-', b.id), NULL,
           b.price, NULL, v_base, NULL, NULLIF(b.cover_image, ''), NULL,
           IF(LOWER(COALESCE(b.file_type, '')) = 'physical', NULL, NULLIF(b.file_path, '')),
           NULL,
           IF(LOWER(COALESCE(b.file_type, '')) = 'physical', NULL, COALESCE(NULLIF(b.extension, ''), NULLIF(b.file_type, ''))),
           NULL, 0, COALESCE(b.allow_download, 1), NULLIF(b.link, ''), b.id,
           b.is_active, b.show_on_website, b.order_num, b.created_by_type, b.created_by_id,
           b.created_at, b.updated_at
      FROM course_books b
     WHERE b.course_id IS NULL AND b.unit_id IS NULL
       AND NOT EXISTS (SELECT 1 FROM products p WHERE p.id = b.id);

    SET v_moved = ROW_COUNT();

    INSERT INTO products_translations (product_id, language_id, name, description)
    SELECT t.book_id, t.language_id, t.title, t.description
      FROM course_books_translations t
      JOIN course_books b ON b.id = t.book_id
     WHERE b.course_id IS NULL AND b.unit_id IS NULL
    ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description);

    INSERT INTO store_unification_state (step, detail)
      VALUES ('copy_books', CONCAT(v_moved, ' book(s) copied into products'));
  END IF;

  -- 4. Remove the moved books from course_books, once the copy is recorded.
  IF NOT EXISTS (SELECT 1 FROM store_unification_state WHERE step = 'remove_books') THEN
    DELETE t FROM course_books_translations t
      JOIN course_books b ON b.id = t.book_id
     WHERE b.course_id IS NULL AND b.unit_id IS NULL
       AND EXISTS (SELECT 1 FROM products p WHERE p.id = b.id AND p.legacy_book_id = b.id);
    DELETE b FROM course_books b
     WHERE b.course_id IS NULL AND b.unit_id IS NULL
       AND EXISTS (SELECT 1 FROM products p WHERE p.id = b.id AND p.legacy_book_id = b.id);
    INSERT INTO store_unification_state (step, detail)
      VALUES ('remove_books', CONCAT(ROW_COUNT(), ' book row(s) removed from course_books'));
  END IF;

  -- 5. Every store price is in the base currency.
  UPDATE products SET currency = v_base WHERE currency <> v_base;
END$$
DELIMITER ;

CALL `brainixa_131_unify_store`();
DROP PROCEDURE IF EXISTS `brainixa_131_unify_store`;

-- 6. Lesson files continue from 1,000,000; products stay below it. MariaDB never lowers an
-- AUTO_INCREMENT below the highest id, so this is harmless on a second run.
ALTER TABLE `course_books` AUTO_INCREMENT = 1000000;

-- What happened, for the person running this.
SELECT step, detail, done_at FROM store_unification_state ORDER BY done_at;
SELECT COUNT(*) AS products_total,
       SUM(legacy_book_id IS NOT NULL) AS moved_from_books,
       SUM(product_type = 'digital') AS digital,
       SUM(product_type = 'physical') AS physical
  FROM products;
SELECT COUNT(*) AS store_books_left_in_course_books
  FROM course_books WHERE course_id IS NULL AND unit_id IS NULL;
