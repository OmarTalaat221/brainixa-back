-- 128_product_file.sql
--
-- ملف مرفق للمنتج، بأي نوع.
--
-- A product may need a file attached to it: a size guide, a CAD drawing, a font, an installer, a
-- template - something nobody listed in advance. Every other upload path on this platform names
-- the extensions it accepts, which is right for an avatar and wrong here, so `upload_any_file()`
-- inverts the rule: anything EXCEPT what a web server might run (see helpers/upload.php).
--
-- That is safe because `uploads/.htaccess` already turns the PHP engine off, strips the handlers
-- and refuses to serve executables outright. The deny-list is the first lock in front of a door
-- that is already closed, not the only one.
--
-- Four columns rather than one path:
--
--   file_path       where it is stored, under a generated name
--   file_name       what the owner called it, for the download and for the screen
--   file_extension  so a card can draw an icon without parsing a path on every row
--   file_size       so it can say "2.4MB" without stat()ing a file per row in a list
--
-- The stored name is never the uploaded name. A generated name cannot collide, cannot traverse a
-- directory, and cannot carry a second extension past the deny-list.
--
-- `file_is_public` decides who may have the path. It defaults to 0 - NOT public - because a
-- product file may well be the thing being sold, and a digital product whose file is handed out
-- on the public shop front has been given away. An owner attaching a spec sheet meant for
-- everybody ticks the box. Until checkout exists there is no third option, and defaulting to the
-- one that leaks is the wrong way round.
--
-- Safe to run more than once. Needs 127.

ALTER TABLE `products`
  ADD COLUMN IF NOT EXISTS `file_path` TEXT DEFAULT NULL COMMENT 'Stored under a generated name; never the uploaded name' AFTER `gallery`,
  ADD COLUMN IF NOT EXISTS `file_name` VARCHAR(255) DEFAULT NULL COMMENT 'The original name, for display and for the download' AFTER `file_path`,
  ADD COLUMN IF NOT EXISTS `file_extension` VARCHAR(20) DEFAULT NULL AFTER `file_name`,
  ADD COLUMN IF NOT EXISTS `file_size` BIGINT(20) UNSIGNED DEFAULT NULL COMMENT 'Bytes' AFTER `file_extension`,
  ADD COLUMN IF NOT EXISTS `file_is_public` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '0 = only the admin gets the path. 1 = the store serves it to anyone' AFTER `file_size`;
