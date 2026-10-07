-- 096: Rebrand the leftover Najeh wording in `site_settings` to Brainixa, and move the platform's
--      locale defaults from Najeh's Lebanon to Brainixa's Egypt.
--
-- The database was rebuilt from a Najeh export, and `site_settings` was the one table whose
-- reference data is also user-facing copy: the site name, the hero badge and title, the About
-- page, and the announcement bar all still said "Najeh" on a Brainixa site.
--
-- Written as REPLACE() over the values rather than as a list of fixed strings on purpose:
--
--   1. It is idempotent. A second run finds no "Najeh" left and changes nothing.
--   2. It keeps whatever the admin has since edited. Rewriting each key to a literal would
--      silently discard their copy and put the seeded wording back.
--   3. It catches every key, including any added after this migration was written.
--
-- The brand is spelled "Brainixa" in Arabic copy too - that is the convention the dashboards
-- already follow ("انضم لأكتر من 20,000 طالب بيتفوقوا مع Brainixa").

-- MySQL's REPLACE() is case-sensitive regardless of the column collation, so the capitalised
-- brand and the lowercase domain form are handled separately.
UPDATE `site_settings`
SET `setting_value` = REPLACE(`setting_value`, 'Najeh', 'Brainixa')
WHERE `setting_value` LIKE '%Najeh%';

-- 'support@najeh-demo.com' and friends.
UPDATE `site_settings`
SET `setting_value` = REPLACE(`setting_value`, 'najeh', 'brainixa')
WHERE `setting_value` LIKE '%najeh%';

-- The Arabic site name is the only value holding the brand in Arabic script. Scoped to that one
-- key and matched exactly, because "ناجح" is also an ordinary Arabic adjective ("successful") and
-- a blind replace would corrupt any sentence that happens to use the word.
UPDATE `site_settings`
SET `setting_value` = 'Brainixa'
WHERE `setting_key` = 'site_name_ar'
  AND `setting_value` = 'ناجح';

-- Brainixa is an Egyptian platform, so a phone number typed without a country code is Egyptian.
-- Migration 095 set this to Lebanon's 961 for Najeh, which is where this database was exported
-- from; 20 is also the fallback helpers/phone.php uses when the setting is missing entirely.
--
-- Nothing else needed moving: `countries` already sorts Egypt first (id 1, dial code 20, EGP),
-- the timezone is already Africa/Cairo, and no code in the backend or the three dashboards
-- mentions Lebanon at all - it was only ever this one row.
INSERT INTO `site_settings` (`setting_key`, `setting_value`)
VALUES ('default_phone_dial_code', '20')
ON DUPLICATE KEY UPDATE `setting_value` = '20';

-- PLACEHOLDER - REPLACE BEFORE LAUNCH.
--
-- The support number was still Najeh's real Lebanese line (+961 79 431793), and every "Subscribe
-- via WhatsApp" button on Brainixa opened a chat with it. An Egyptian all-zeros dummy is put in
-- its place so no student reaches a stranger; it matches the `support_phone` placeholder already
-- in this table, and it is in the international form the admin screen demands (a leading 0 is
-- rejected as a local number). It reaches nobody, so the WhatsApp button will not work until a
-- real number is entered from Settings.
--
-- Scoped to the Lebanese value so replaying this never overwrites a real number entered later.
UPDATE `site_settings`
SET `setting_value` = '201000000000'
WHERE `setting_key` = 'whatsapp_number'
  AND REPLACE(REPLACE(`setting_value`, '+', ''), ' ', '') = '96179431793';
