-- 116_book_request_review_notes.sql
--
-- `student_book_purchase_requests` had a single `notes` column serving two different authors:
-- the student's note written when the request is filed, and the reviewer's note written when it
-- is approved or rejected. Every review therefore overwrote the student's own words, and the
-- admin dashboard read a `review_notes` column that never existed, so its review box was always
-- blank. Split them: `notes` stays the student's, `review_notes` is the reviewer's.
--
-- Idempotent; safe to replay.

ALTER TABLE `student_book_purchase_requests`
  ADD COLUMN IF NOT EXISTS `review_notes` TEXT DEFAULT NULL AFTER `notes`;
