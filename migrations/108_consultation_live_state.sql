-- ============================================================
-- Migration: 108_consultation_live_state.sql
-- "Start" has to mean something to the student, not just open a link for
-- whoever pressed it. The slot now records when it was started and when it
-- was ended, so the student's screen can say "it has started, go in" and
-- later "it is over" instead of leaving them guessing at the hour.
--
-- `status` becomes a VARCHAR in the same migration, BEFORE anything writes
-- in_progress to it. It was an enum of four values, and MySQL stores a
-- value an enum has not been told about as the empty string without
-- complaining - which silently loses the status of every consultation that
-- is started or ended.
-- ============================================================

ALTER TABLE `consultation_slots`
  ADD COLUMN IF NOT EXISTS `started_at` DATETIME NULL
  COMMENT 'When the admin or the teacher pressed Start',
  ADD COLUMN IF NOT EXISTS `ended_at` DATETIME NULL
  COMMENT 'When it was ended; the consultation reads as completed from here on';

ALTER TABLE `consultation_slots`
  MODIFY COLUMN `status` VARCHAR(20) NOT NULL DEFAULT 'available';
