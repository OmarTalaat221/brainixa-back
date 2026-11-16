-- 132: rescheduling a package appointment.
--
-- `session_reschedule_requests` only knew the weekly class sessions: a request named a
-- `session_id` and a new weekday. A package appointment is a dated slot (`teacher_availability_slots`
-- + the student's row in `availability_slot_bookings`), and moving one means a new DATE and time -
-- "17 November 16:30 -> 18 November 17:30". The same table and the same review screens now carry
-- both kinds, told apart by `slot_id`:
--
--   weekly session request : session_id set,  slot_id NULL   (unchanged)
--   package appointment    : session_id NULL, slot_id set, new_date set
--
-- On approval the student's booking moves to a slot of the same teacher at the new date and time
-- (an existing one if it has room, otherwise a new one); `new_slot_id` records where it went, and
-- `original_*` keep where it was, since the old slot may be removed once it is empty.
--
-- Idempotent: every change checks first.

ALTER TABLE `session_reschedule_requests`
  MODIFY COLUMN `session_id` BIGINT(20) UNSIGNED NULL,
  MODIFY COLUMN `new_day` ENUM('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday') NULL,
  ADD COLUMN IF NOT EXISTS `slot_id` BIGINT(20) UNSIGNED NULL DEFAULT NULL
      COMMENT 'A package appointment (teacher_availability_slots.id); NULL for a weekly session' AFTER `session_id`,
  ADD COLUMN IF NOT EXISTS `new_date` DATE NULL DEFAULT NULL
      COMMENT 'The date asked for, for a package appointment' AFTER `new_day`,
  ADD COLUMN IF NOT EXISTS `original_date` DATE NULL DEFAULT NULL AFTER `new_end_time`,
  ADD COLUMN IF NOT EXISTS `original_start_time` TIME NULL DEFAULT NULL AFTER `original_date`,
  ADD COLUMN IF NOT EXISTS `original_end_time` TIME NULL DEFAULT NULL AFTER `original_start_time`,
  ADD COLUMN IF NOT EXISTS `new_slot_id` BIGINT(20) UNSIGNED NULL DEFAULT NULL
      COMMENT 'Where the booking moved to once approved' AFTER `original_end_time`;

SET @has_idx := (SELECT COUNT(*) FROM information_schema.STATISTICS
                 WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'session_reschedule_requests'
                   AND INDEX_NAME = 'idx_srr_slot');
SET @sql := IF(@has_idx > 0, 'SELECT 1', 'ALTER TABLE `session_reschedule_requests` ADD KEY `idx_srr_slot` (`slot_id`)');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
