-- Lets a teacher keep their own manual sales sheet, the same feature the admin already has
-- (migrations/113_manual_sales.sql), for the exact same reason: a student reaches a teacher
-- directly over WhatsApp/Instagram and pays them, not the platform owner, so the teacher needs
-- somewhere to log it too.
--
-- `created_by_id` alone could not tell an admin's row from a teacher's - both are just numeric
-- ids from two different tables, and id 1 exists in both. Without `created_by_type`, scoping a
-- teacher's list to "rows they wrote" was not expressible at all, let alone safely: a teacher
-- could have ended up reading or editing a row an admin wrote (or vice versa) purely because the
-- two tables' ids happened to collide.
--
-- Additive: existing rows default to 'admin', the only type that existed before this, so nothing
-- already recorded changes meaning. adminCreateManualSale() never has to mention this column -
-- its INSERT already omits it, so it keeps getting the 'admin' default exactly as before.

ALTER TABLE `manual_sales`
    ADD COLUMN IF NOT EXISTS `created_by_type` ENUM('admin','teacher') NOT NULL DEFAULT 'admin'
        COMMENT 'Which table created_by_id points into' AFTER `note`;

ALTER TABLE `manual_sales`
    ADD INDEX IF NOT EXISTS `idx_manual_sales_created_by` (`created_by_type`, `created_by_id`);
