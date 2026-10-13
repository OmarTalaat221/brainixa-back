-- Trims the trailing word from the footer sentence.
--
-- The landing footer prints site_settings.footer_description, falling back to the copy bundled
-- with the page. Editing only the bundled copy changes nothing on a server where the setting is
-- present - which it is - so the stored value is trimmed here as well, and the two stay in step.
--
-- REPLACE() rather than a flat assignment, so an owner who has since rewritten the sentence from
-- the dashboard keeps their wording and loses only the trailing word. Replaying the file is a
-- no-op once there is nothing left to replace.

UPDATE `site_settings`
   SET `setting_value` = REPLACE(`setting_value`, ' براحته.', '.')
 WHERE `setting_key` LIKE 'footer_description%'
   AND `setting_value` LIKE '% براحته.%';

UPDATE `site_settings`
   SET `setting_value` = REPLACE(`setting_value`, ' with ease.', '.')
 WHERE `setting_key` LIKE 'footer_description%'
   AND `setting_value` LIKE '% with ease.%';
