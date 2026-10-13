-- The WhatsApp number the whole public site contacts.
--
-- Every "subscribe via WhatsApp" button on the landing page, the course pages, the book pages
-- and the new floating button all read this one key. It was still holding the placeholder
-- 201000000000 that shipped with the rebuilt database, so every one of those buttons opened a
-- chat with a number that answers nobody.
--
-- The value is editable from the admin dashboard (Settings -> Contact & support), so this
-- migration only sets the starting point; a later change made there is the one that counts and
-- must not be overwritten by replaying this file. Hence the WHERE clause: it fills in the
-- placeholder or an empty value, and leaves a real number alone.

INSERT INTO `site_settings` (`setting_key`, `setting_value`)
VALUES ('whatsapp_number', '201060044160')
ON DUPLICATE KEY UPDATE
  `setting_value` = IF(
    `setting_value` IN ('', '201000000000', '01000000000'),
    '201060044160',
    `setting_value`
  );
