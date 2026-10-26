-- Give each hero slide its own words.
--
-- 110 made a slide a background and nothing else, with the headline, paragraph and button
-- fixed in site_settings. The owner wants them to change with the slide: one slide announces
-- a discount, the next introduces the platform, and each needs its own sentence and its own
-- link.
--
-- The site_settings keys stay exactly where they are and keep their meaning: they are what the
-- hero shows when a slide leaves a field empty, and what it shows when there are no slides at
-- all. So a slide that only wants a new picture writes nothing here and inherits the rest.
--
-- Additive: new nullable columns on a table added days ago, nothing existing touched.

ALTER TABLE `hero_slides`
    ADD COLUMN IF NOT EXISTS `subtitle_ar` VARCHAR(500) DEFAULT NULL AFTER `title_en`,
    ADD COLUMN IF NOT EXISTS `subtitle_en` VARCHAR(500) DEFAULT NULL AFTER `subtitle_ar`,
    ADD COLUMN IF NOT EXISTS `btn_text_ar` VARCHAR(120) DEFAULT NULL AFTER `subtitle_en`,
    ADD COLUMN IF NOT EXISTS `btn_text_en` VARCHAR(120) DEFAULT NULL AFTER `btn_text_ar`;

-- `link` is already on the table and becomes the slide's button link. It used to make the
-- whole picture clickable; a slide that sets a button text now gets a button instead, which is
-- the clearer thing for a reader either way.
