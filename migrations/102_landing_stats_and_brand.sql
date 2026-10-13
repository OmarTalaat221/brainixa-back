-- The landing page's headline figures, and the brand spelled as one word.
--
-- The four counters are not computed - they are copy, stored in site_settings and shown as-is.
-- They were inherited from the Najeh numbers (3000 courses, 4000 books, 85 teachers, 100k
-- students) and described a platform Brainixa is not. A visitor who clicks through to a
-- catalogue holding three courses has been told something untrue before they even arrive.
--
-- UPDATE, not INSERT: every key below already exists, and the landing page reads whatever is
-- here. The fallbacks in the page's own code are only for a settings fetch that fails.

UPDATE `site_settings` SET `setting_value` = '+200'  WHERE `setting_key` = 'stats_courses_count';
UPDATE `site_settings` SET `setting_value` = '+300'  WHERE `setting_key` = 'stats_books_count';
UPDATE `site_settings` SET `setting_value` = '+10'   WHERE `setting_key` = 'stats_teachers_count';
UPDATE `site_settings` SET `setting_value` = '+500'  WHERE `setting_key` = 'stats_students_count';

-- The labels are stored per language. `stats_*_label` without a suffix is NOT what the landing
-- reads: the public endpoint picks `_ar` or `_en` by request language and falls back to a
-- hardcoded default, so writing only the bare key changes nothing on the page. Both suffixed
-- keys are written, and the bare one with them so the two never disagree.
--
-- "مدرّس" became "معلم" across the platform; the landing page kept the old word.
INSERT INTO `site_settings` (`setting_key`, `setting_value`) VALUES
  ('stats_teachers_label',    'معلم متخصص'),
  ('stats_teachers_label_ar', 'معلم متخصص'),
  ('stats_teachers_label_en', 'Expert Teachers'),
  ('stats_students_label',    'طالب'),
  ('stats_students_label_ar', 'طالب'),
  ('stats_students_label_en', 'Students')
ON DUPLICATE KEY UPDATE `setting_value` = VALUES(`setting_value`);

-- BRAIN-IXA -> BRAINIXA wherever the hyphenated form was stored. REPLACE() rather than a flat
-- assignment, because these values are whole sentences in places ("منصة BRAIN-IXA") and only the
-- name inside them should change. Idempotent: a second run finds nothing left to replace.
UPDATE `site_settings`
   SET `setting_value` = REPLACE(`setting_value`, 'BRAIN-IXA', 'BRAINIXA')
 WHERE `setting_value` LIKE '%BRAIN-IXA%';

-- The hero's live-session badge and the "subscription plans" button were removed from the page,
-- so the settings behind them no longer reach anything. Left in place rather than deleted: they
-- cost nothing, and deleting them would make restoring either element a schema change.
