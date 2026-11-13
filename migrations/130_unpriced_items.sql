-- 130: "no price" as a state of its own, beside free (0) and a price.
--
-- The client wants three outcomes from the price box on a course, a package and a store product:
--
--   left empty  -> "no price"   (not for sale yet - NOT free)
--   0           -> free
--   a number    -> that price
--
-- A NOT NULL column cannot hold the first, which is why an empty box has always been saved as 0
-- and shown as "free". NULL is the empty box.
--
-- The DEFAULT stays 0.00, so an older client that sends no price at all keeps the behaviour it
-- had. Only an explicit empty value means "no price".
--
-- course_books.price is already nullable (`double DEFAULT 0`) and needs nothing.
--
-- Idempotent: MODIFY to the same definition is a no-op on a second run.

ALTER TABLE `courses`
  MODIFY COLUMN `price` DECIMAL(10,2) NULL DEFAULT 0.00;

ALTER TABLE `products`
  MODIFY COLUMN `price` DECIMAL(10,2) NULL DEFAULT 0.00;
