-- 118_zoom_live_classes.sql
--
-- Live classes through Zoom, played INSIDE Brainixa rather than by handing the student a
-- zoom.us link. Two tables, both additive; nothing existing is altered.
--
--   zoom_oauth_tokens   One row. The Server-to-Server OAuth access token, cached until shortly
--                       before it expires. Zoom rate-limits token requests, and without this
--                       every class action would spend one.
--
--   session_zoom_meetings  One row per OCCURRENCE of a class, not per class. class_sessions is a
--                       weekly template (day_of_week + start_time), so the same row runs again
--                       every week and each run needs its own meeting. The unique key on
--                       (session_id, session_date) is what makes "start the class" safe to press
--                       twice: the second press finds the meeting already there instead of
--                       opening a second room and splitting the students between them.
--
-- `meeting_id` is a string on purpose. Zoom meeting ids are 11 digits today and already overflow
-- a 32-bit int; storing them as text also keeps leading zeros and any future format change safe.
--
-- Idempotent; safe to replay.

CREATE TABLE IF NOT EXISTS `zoom_oauth_tokens` (
  `id` TINYINT(3) UNSIGNED NOT NULL DEFAULT 1,
  `access_token` TEXT NOT NULL,
  `expires_at` DATETIME NOT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `session_zoom_meetings` (
  `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `session_id` BIGINT(20) UNSIGNED NOT NULL,
  `session_date` DATE NOT NULL,
  `teacher_id` BIGINT(20) UNSIGNED NOT NULL,
  `meeting_id` VARCHAR(32) NOT NULL,
  `host_user_id` VARCHAR(64) NOT NULL DEFAULT 'me',
  `password` VARCHAR(64) DEFAULT NULL,
  `join_url` TEXT DEFAULT NULL,
  `status` ENUM('live','ended') NOT NULL DEFAULT 'live',
  `started_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `ended_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_session_occurrence` (`session_id`, `session_date`),
  KEY `idx_meeting_id` (`meeting_id`),
  KEY `idx_teacher` (`teacher_id`, `session_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
