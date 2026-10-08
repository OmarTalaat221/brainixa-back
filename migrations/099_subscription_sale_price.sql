-- Let a manually granted course subscription record what was actually collected for it.
--
-- A sale agreed over WhatsApp ends as an admin creating a subscription by hand. That path wrote
-- no price anywhere - `student_subscriptions` had no price column at all - so the money was
-- invisible to every revenue figure on the platform. The dashboard's own source list says as
-- much about the course path: "there was NOWHERE this money was ever visible before".
--
-- Books already worked: `student_book_subscriptions.price` carries the figure, and the dashboard
-- counts it under `offline_book_grants`. This gives courses the same thing.
--
-- Only MANUALLY entered sales fill this in. Subscriptions created by payments_grant_access() -
-- gateway payments and approved offline requests - leave it NULL, because those are already
-- counted from payment_transactions and offline_payment_requests respectively. Counting rows
-- with a price > 0 therefore cannot double-count a sale that another source already reports.

ALTER TABLE `student_subscriptions`
  ADD COLUMN IF NOT EXISTS `price` DECIMAL(10,2) DEFAULT NULL
  COMMENT 'What was collected for a manually entered sale. NULL for grants made by a payment flow, which are counted at their own source.'
  AFTER `end_date`;

ALTER TABLE `student_subscriptions`
  ADD COLUMN IF NOT EXISTS `currency` VARCHAR(10) DEFAULT NULL
  COMMENT 'Currency of `price`. Never assume the platform base: a sale can be agreed in the buyer''s own currency.'
  AFTER `price`;

-- How the sale was agreed, so revenue can be broken down by channel rather than lumped into one
-- "manual" bucket. The payment flows do not set this; it describes a sale entered by hand.
ALTER TABLE `student_subscriptions`
  ADD COLUMN IF NOT EXISTS `sale_channel` VARCHAR(30) DEFAULT NULL
  COMMENT 'whatsapp | cash | bank_transfer | other. NULL for grants made by a payment flow.'
  AFTER `currency`;

-- Revenue queries filter on `price > 0` and group by date, so both are worth an index.
ALTER TABLE `student_subscriptions`
  ADD INDEX IF NOT EXISTS `idx_student_subscriptions_price` (`price`);
