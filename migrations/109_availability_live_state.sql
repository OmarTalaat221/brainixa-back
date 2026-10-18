-- ============================================================
-- Migration: 109_availability_live_state.sql
-- A package session needs the same thing a consultation needed: the meeting
-- link cannot sit on the student's screen from the moment they book. It is
-- an invitation to walk into an empty room, hours or days early.
--
-- Start is a stored state. `started_at` and `ended_at` are what the
-- student's screen reads to decide whether to show the link at all - along
-- with the session's own hour, which opens it on its own.
--
-- `status` becomes a VARCHAR for the same reason as in 108: four other
-- places write to this column, and an enum eats a value it does not know.
-- ============================================================

ALTER TABLE `teacher_availability_slots`
  ADD COLUMN IF NOT EXISTS `started_at` DATETIME NULL
  COMMENT 'When the admin or the teacher pressed Start',
  ADD COLUMN IF NOT EXISTS `ended_at` DATETIME NULL
  COMMENT 'When it was ended; the session reads as completed from here on';

ALTER TABLE `teacher_availability_slots`
  MODIFY COLUMN `status` VARCHAR(20) NOT NULL DEFAULT 'available';
