-- 117_database_default_charset_utf8mb4.sql
--
-- The database's own default was latin1 / latin1_swedish_ci. Almost every table escaped that
-- because the rebuild dump names utf8mb4 explicitly, but a CREATE TABLE written without a
-- DEFAULT CHARSET clause inherits the database default instead -- which is exactly how
-- `hr_policy_settings` ended up latin1, and how any future ensure_*_schema table would too.
--
-- Two separate things, both needed:
--   1. The database default, so new tables stop inheriting latin1. This changes no data at all;
--      it only decides what a later CREATE TABLE gets when it does not say.
--   2. The one table that already inherited it.
--
-- `hr_policy_settings` is safe to convert: its only non-utf8mb4 column is
-- `default_pay_model`, an ENUM whose values are 'hourly' / 'per_session' / 'per_minute' --
-- pure ASCII, identical in latin1 and utf8mb4, so nothing can be lost in translation.
--
-- NOTE for anyone extending this file later: a plain CONVERT TO CHARACTER SET is only safe
-- because every other column in this database is ALREADY utf8mb4. On a column that holds raw
-- UTF-8 bytes inside a latin1 column, this same statement would corrupt the text, and the
-- conversion has to go through BINARY first. Check before adding a table here:
--
--   SELECT TABLE_NAME, COLUMN_NAME, CHARACTER_SET_NAME
--   FROM information_schema.COLUMNS
--   WHERE TABLE_SCHEMA = DATABASE()
--     AND CHARACTER_SET_NAME IS NOT NULL
--     AND CHARACTER_SET_NAME <> 'utf8mb4';
--
-- Idempotent; safe to replay.

ALTER DATABASE `campcod1_brain-ixa`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `hr_policy_settings`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
