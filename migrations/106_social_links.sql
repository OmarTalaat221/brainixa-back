-- The real social accounts, and no YouTube row until there is a channel.
--
-- site_settings shipped with "https://facebook.com", "https://instagram.com" and
-- "https://youtube.com" - the platforms' own front doors. The footer printed them under
-- "follow us", so a visitor who pressed Facebook landed on Facebook's homepage rather than on
-- the academy's page. Three links that looked like links and led nowhere useful.
--
-- The Instagram address is stored without the ?mdxt= parameter the owner's link carried: that is
-- a share-session token tied to whoever copied the link, not part of the address.
--
-- Only a bare placeholder is overwritten. An admin who has since saved a real address from the
-- dashboard keeps it if this file is replayed.

UPDATE `site_settings`
   SET `setting_value` = 'https://www.facebook.com/share/1JCezoMk7c/'
 WHERE `setting_key` = 'facebook_link'
   AND `setting_value` IN ('', 'https://facebook.com', 'https://facebook.com/', 'https://www.facebook.com', 'https://www.facebook.com/');

UPDATE `site_settings`
   SET `setting_value` = 'https://www.instagram.com/brainixa.academy'
 WHERE `setting_key` = 'instagram_link'
   AND `setting_value` IN ('', 'https://instagram.com', 'https://instagram.com/', 'https://www.instagram.com', 'https://www.instagram.com/');

-- Emptied rather than deleted: the key still exists for the dashboard to fill in the day a
-- channel is created, and the footer hides any social row whose address is empty.
UPDATE `site_settings`
   SET `setting_value` = ''
 WHERE `setting_key` = 'youtube_link'
   AND `setting_value` IN ('https://youtube.com', 'https://youtube.com/', 'https://www.youtube.com', 'https://www.youtube.com/');
