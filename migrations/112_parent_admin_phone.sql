-- A phone number for parents and for admins.
--
-- Students have had `phone` and `phone_country_code` since the beginning, and a teacher's
-- number is their `whatsapp` column. Parents and admins had an email address and nothing
-- else: there was no way to reach a parent about their child, and no second way to identify
-- an admin at all.
--
-- The two columns mirror the students table exactly, down to the comment on the dial code, so
-- the four roles can be read and written the same way rather than each having its own shape.
--
-- Additive: new nullable columns. Nothing reads them yet except the code shipped with this
-- migration, and every existing response keeps its shape - a client that does not know the
-- field simply ignores it.

ALTER TABLE `parents`
    ADD COLUMN IF NOT EXISTS `phone` VARCHAR(30) DEFAULT NULL AFTER `email`,
    ADD COLUMN IF NOT EXISTS `phone_country_code` VARCHAR(8) DEFAULT NULL
        COMMENT 'Dial code of the phone number, without the +' AFTER `phone`;

ALTER TABLE `admins`
    ADD COLUMN IF NOT EXISTS `phone` VARCHAR(30) DEFAULT NULL AFTER `email`,
    ADD COLUMN IF NOT EXISTS `phone_country_code` VARCHAR(8) DEFAULT NULL
        COMMENT 'Dial code of the phone number, without the +' AFTER `phone`;

-- No UNIQUE index on either. A household can share one number between a parent and a student,
-- and two admins at the same school may share a landline; making it unique would reject real
-- data for the sake of a constraint nothing asked for.
