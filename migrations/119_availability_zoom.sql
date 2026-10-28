-- 119_availability_zoom.sql
--
-- Zoom for package session slots (`teacher_availability_slots`), played INSIDE Brainixa, the
-- same way migration 118 did for the weekly `class_sessions` template. This is the feature the
-- live classes actually run on in production - "مواعيد الباقات" / "مواعيدي المتاحة" - not the
-- generic weekly schedule.
--
-- A slot is already one date + one time range (unlike class_sessions, which is a weekly
-- template that repeats), so there is no need for a separate (session_id, date) table here: the
-- meeting just belongs to the slot row directly.
--
-- Idempotent; safe to replay.

ALTER TABLE `teacher_availability_slots`
  ADD COLUMN IF NOT EXISTS `zoom_meeting_id` VARCHAR(32) DEFAULT NULL
  COMMENT 'Set once Start creates the Zoom room; reused if Start is pressed again before End',
  ADD COLUMN IF NOT EXISTS `zoom_password` VARCHAR(64) DEFAULT NULL;
