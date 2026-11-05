-- 125_session_ratings.sql
--
-- A rating for one live class, left by one student, after it has happened.
--
-- The platform already had `teacher_ratings` and `course_ratings`, and neither can answer the
-- question this is for. Both are a single verdict on a whole person or a whole course, with no
-- `session_id` anywhere in them: a student rates their teacher once, and that one number stands
-- for a term's worth of classes. It cannot say that last Tuesday went badly.
--
-- The key is (session_id, occurrence_date, student_id), not (session_id, student_id), because
-- `class_sessions` is a weekly template - one row describing "Mondays at 16:00" - and what gets
-- rated is one occurrence of it. The same three columns are what `teacher_session_attendance`
-- is keyed on, so a rating and the attendance it belongs to line up exactly.
--
-- `teacher_id` is stored rather than joined through the session, so that a teacher's average
-- stays attached to the person who actually taught the class even if the session is later
-- handed to somebody else.
--
-- Safe to run more than once.

CREATE TABLE IF NOT EXISTS `session_ratings` (
    `id` BIGINT(20) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `session_id` BIGINT(20) UNSIGNED NOT NULL,
    `occurrence_date` DATE NOT NULL,
    `student_id` BIGINT(20) UNSIGNED NOT NULL,
    `teacher_id` BIGINT(20) UNSIGNED NOT NULL,
    `rating` TINYINT(4) NOT NULL CHECK (`rating` BETWEEN 1 AND 5),
    `comment` TEXT NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- One rating per student per occurrence. A second submission updates the first rather than
    -- adding a vote, so nobody can rate the same class twice.
    UNIQUE KEY `uniq_session_rating` (`session_id`, `occurrence_date`, `student_id`),

    KEY `idx_session_ratings_teacher` (`teacher_id`, `occurrence_date`),
    KEY `idx_session_ratings_date` (`occurrence_date`),

    CONSTRAINT `fk_session_ratings_session` FOREIGN KEY (`session_id`)
        REFERENCES `class_sessions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_session_ratings_student` FOREIGN KEY (`student_id`)
        REFERENCES `students` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_session_ratings_teacher` FOREIGN KEY (`teacher_id`)
        REFERENCES `teachers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
