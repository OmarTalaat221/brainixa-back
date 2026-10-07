-- 097: Question bank (بنك الأسئلة), organised into folders.
--
-- A reusable pool of questions an exam can be built from, instead of every question being born
-- inside one exam and dying with it.
--
-- WHAT A BANK QUESTION IS
--
-- A row in `questions` with `is_bank = 1`, a `bank_folder_id`, and NULL for `exam_id`, `unit_id`,
-- `course_id` and `subject_id`. The bank is global: a bank question belongs to no course, no
-- subject and no unit. It is filed in a folder and nothing else.
--
-- It is NOT a separate table, because a question's content lives in five other tables -
-- `questions_translations`, `mcq_options` (+ its translations), `true_false_answers`,
-- `written_model_answers` (+ its translations) - and a parallel bank would have to duplicate all
-- of them, then keep the two copies in step forever.
--
-- Pulling a bank question into an exam COPIES it: the exam gets its own question row, with its own
-- answers, carrying the exam's course/unit/subject. So editing a bank question later never
-- rewrites an exam a student has already sat, and `exam_attempt_answers` keeps pointing at exactly
-- what was asked.
--
-- WHY THE NULLS MATTER
--
-- They are not decoration - they are what makes this safe. Every student-facing query over
-- `questions` filters by `exam_id`, `unit_id` or `course_id`, and NULL matches none of them. So a
-- bank question cannot reach a student even through a query that has never heard of `is_bank`.
-- The handful of places that filter by none of the three are guarded explicitly in the PHP.

-- `exam_id` and `course_id` have to let go of NOT NULL for a question to exist outside both.
-- Migration 015 also did this to exam_id, but the live database was rebuilt from an export where
-- it is still NOT NULL, so the migration history cannot be trusted here - this runs again
-- deliberately and is harmless if the columns are already nullable.
--
-- The existing foreign keys stay exactly as they are. Both are ON DELETE CASCADE, and a NULL
-- foreign key is simply not enforced - which is what makes a bank question outlive the deletion of
-- any course or exam.
ALTER TABLE `questions` MODIFY COLUMN `exam_id` BIGINT(20) UNSIGNED NULL;
ALTER TABLE `questions` MODIFY COLUMN `course_id` BIGINT(20) UNSIGNED NULL;

-- Folders are one level deep by design - a flat list, not a tree. No parent_id, so there is no
-- cycle to guard against and no recursive read.
--
-- The name is a single column rather than a translations table: a teacher names their own folders
-- for their own use, and asking for an Arabic and an English name for "جبر - صعب" would be
-- paperwork, not a feature.
CREATE TABLE IF NOT EXISTS `question_bank_folders` (
    `id` BIGINT(20) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(190) NOT NULL,
    `description` TEXT NULL,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    -- Who owns the folder. A teacher only ever sees their own; an admin sees every folder.
    `created_by_type` VARCHAR(80) NOT NULL DEFAULT 'admin',
    `created_by_id` BIGINT(20) UNSIGNED NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY `idx_qbf_owner` (`created_by_type`, `created_by_id`, `is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE `questions`
  ADD COLUMN IF NOT EXISTS `is_bank` TINYINT(1) NOT NULL DEFAULT 0 AFTER `exam_id`;

ALTER TABLE `questions`
  ADD COLUMN IF NOT EXISTS `bank_folder_id` BIGINT(20) UNSIGNED NULL AFTER `is_bank`;

-- The bank is always read as "the questions in this folder", so the index leads with the folder.
ALTER TABLE `questions`
  ADD INDEX IF NOT EXISTS `idx_questions_bank_folder` (`is_bank`, `bank_folder_id`, `is_active`);

-- Emptying a folder would orphan its questions into a bank nothing can navigate to, so deleting a
-- folder takes its questions with it. They are copies-in-waiting; the exams built from them own
-- their own rows and are untouched.
ALTER TABLE `questions`
  ADD CONSTRAINT `fk_questions_bank_folder` FOREIGN KEY (`bank_folder_id`)
  REFERENCES `question_bank_folders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
