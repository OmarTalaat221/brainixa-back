-- Email, phone and age become genuinely optional, not just unvalidated in the form.
--
-- `students.email` was already nullable, but the create handler demanded one anyway - the
-- schema and the code disagreed. `teachers.email`, `parents.email` and `admins.email` were
-- NOT NULL in the schema itself, so even fixing the handler would not have been enough; an
-- empty string would have satisfied the column without meaning what "optional" means.
--
-- The UNIQUE key on each email column is untouched and keeps working exactly as it did:
-- MySQL does not treat NULL as equal to NULL in a unique index, so any number of rows may now
-- leave the field empty without colliding with each other.
--
-- Additive in effect even though it is a column change: nothing that already has an email is
-- touched, and no existing response gains or loses a field.

ALTER TABLE `teachers` MODIFY COLUMN `email` VARCHAR(190) DEFAULT NULL;
ALTER TABLE `parents`  MODIFY COLUMN `email` VARCHAR(190) DEFAULT NULL;
ALTER TABLE `admins`   MODIFY COLUMN `email` VARCHAR(190) DEFAULT NULL;

-- `students.email` needs no change here - it was already DEFAULT NULL. The handler that
-- insisted on one anyway is a code fix, not a schema one; see app/admin/users/students.php.
