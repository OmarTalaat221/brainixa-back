-- 126_homework_students.sql
--
-- Homework aimed at particular students.
--
-- Until now a homework row carried a subject and nothing else, so publishing one handed it to
-- every student subscribed to that subject. A teacher who wanted to set extra practice for the
-- three students who are behind had no way to say so.
--
-- The rule this table encodes, and the reason it is a separate table rather than a column:
--
--   * NO rows for a homework  -> it is for everyone subscribed to the subject. This is exactly
--     today's behaviour, so every homework that already exists keeps working untouched and the
--     mobile app sees no change.
--   * SOME rows for a homework -> only those students see it, and only they may submit to it.
--
-- Targeting therefore NARROWS an audience; it never widens one. A student still has to be
-- subscribed to the subject, so a row here cannot hand anyone access they did not already have.
--
-- Both foreign keys cascade: deleting a homework or a student should not leave a row pointing at
-- something that is gone, and a targeting row has no meaning on its own.

CREATE TABLE IF NOT EXISTS `homework_students` (
  `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `homework_id` BIGINT(20) UNSIGNED NOT NULL,
  `student_id` BIGINT(20) UNSIGNED NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_homework_student` (`homework_id`, `student_id`),
  KEY `idx_homework_students_student` (`student_id`),
  CONSTRAINT `fk_homework_students_homework`
    FOREIGN KEY (`homework_id`) REFERENCES `homework` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_homework_students_student`
    FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
