-- 129_discount_code_books.sql
--
-- Discount codes that reach the store.
--
-- A discount code could only ever reduce a COURSE price. The scope table is `discount_code_courses`,
-- the validator takes course ids, and `offline_payment_quote()` refused a code outright unless the
-- item being priced was a course - so a book, which is what this platform sells in its store, had
-- nowhere to put one. There was no field for it on the manual-sale form either, and that was not an
-- oversight: the form hid it because the server would have ignored it.
--
-- This mirrors `discount_code_courses` rather than replacing both with one generic table. Rewriting
-- the course scope would mean migrating live rows that a live payment path reads; adding a second
-- table beside it changes nothing that already works.
--
-- How scope reads once this exists, unchanged from how it reads for courses:
--
--   applies_to = 'all'      -> every course AND every book. A code meant for the whole platform
--                              now actually covers the whole platform.
--   applies_to = 'selected' -> whatever is listed, in EITHER table. A code may name courses only,
--                              books only, or both; listing neither matches nothing, which is the
--                              same as before.
--
-- `book_id` points at `course_books`, which is what the store sells. The newer `products` table is
-- not covered: it has no purchase path at all yet, so a discount on one would have nowhere to be
-- applied.

CREATE TABLE IF NOT EXISTS `discount_code_books` (
  `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `discount_code_id` BIGINT(20) UNSIGNED NOT NULL,
  `book_id` BIGINT(20) UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_discount_code_book` (`discount_code_id`, `book_id`),
  KEY `idx_discount_code_books_book` (`book_id`),
  CONSTRAINT `fk_discount_code_books_code`
    FOREIGN KEY (`discount_code_id`) REFERENCES `discount_codes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_discount_code_books_book`
    FOREIGN KEY (`book_id`) REFERENCES `course_books` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
