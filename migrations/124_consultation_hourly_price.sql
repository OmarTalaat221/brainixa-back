-- 124_consultation_hourly_price.sql
--
-- An hourly price on a consultation slot.
--
-- Nullable on purpose, and it stays null unless somebody types a figure: a consultation that was
-- free before this ran is still free after it, and most are. A price of 0.00 is a deliberate
-- "free", which is not the same thing as "no price set", so the two are kept apart rather than
-- collapsed into a DEFAULT 0.
--
-- Per slot rather than per teacher, because an hour is not worth the same at every hour: a
-- revision session the week before an exam and an ordinary follow-up are both consultations, and
-- the one price per teacher could not tell them apart.
--
-- Safe to run more than once.

ALTER TABLE `consultation_slots`
  ADD COLUMN IF NOT EXISTS `price_per_hour` DECIMAL(10,2) NULL DEFAULT NULL AFTER `notes`;
