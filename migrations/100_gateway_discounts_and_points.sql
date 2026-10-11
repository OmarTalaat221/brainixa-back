-- Let a card payment carry a discount code and spent points, the way an offline payment already
-- does.
--
-- Until now the two paths priced differently. `offline_payment_requests` has columns for the
-- original amount, the code, the points and what they were worth, and `offline_payment_quote()`
-- works all of it out. The gateway path ignored every bit of that and charged the list price:
-- a student holding a code could only use it by transferring money manually and waiting for a
-- human, and points were worth nothing at all if they paid by card.
--
-- These columns mirror the offline ones so both paths can be read the same way - and so a
-- payment that fails or is refunded can hand the points back, which is impossible if nothing
-- records that they were spent.

ALTER TABLE `payment_transactions`
  ADD COLUMN IF NOT EXISTS `original_amount` DECIMAL(10,2) DEFAULT NULL
  COMMENT 'The list price before any code or points. NULL on rows predating this.'
  AFTER `amount`;

ALTER TABLE `payment_transactions`
  ADD COLUMN IF NOT EXISTS `discount_code_id` BIGINT(20) UNSIGNED DEFAULT NULL
  COMMENT 'The code quoted at checkout. Only SPENT once the payment succeeds, like the offline path.'
  AFTER `original_amount`;

ALTER TABLE `payment_transactions`
  ADD COLUMN IF NOT EXISTS `discount_amount` DECIMAL(10,2) NOT NULL DEFAULT 0.00
  AFTER `discount_code_id`;

-- Points, unlike a code, are taken at checkout: the balance has to be held or two checkouts
-- would spend the same points. That is why a failed or reversed payment must give them back,
-- and why the figure has to be written down here.
ALTER TABLE `payment_transactions`
  ADD COLUMN IF NOT EXISTS `points_spent` DECIMAL(10,2) NOT NULL DEFAULT 0.00
  AFTER `discount_amount`;

ALTER TABLE `payment_transactions`
  ADD COLUMN IF NOT EXISTS `points_discount` DECIMAL(10,2) NOT NULL DEFAULT 0.00
  COMMENT 'What those points were worth in `currency`.'
  AFTER `points_spent`;

-- Set when the points have been handed back, so a refund followed by a retry - or two reversals
-- racing - cannot return the same points twice.
ALTER TABLE `payment_transactions`
  ADD COLUMN IF NOT EXISTS `points_refunded_at` TIMESTAMP NULL DEFAULT NULL
  AFTER `points_discount`;
