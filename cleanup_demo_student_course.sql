-- ============================================================================
--  يحذف كل ما أنشأه setup_demo_student_course.sql (ثمّ fix_demo_subscription_link.sql):
--  الكورس التجريبي بكل ما يتفرّع عنه، وحساب الطالب التجريبي، والاشتراك الذي
--  يربطهما.
--
--  التشغيل:
--    mysql -u campcod1_brain-ixa -p campcod1_brain-ixa < cleanup_demo_student_course.sql
--  أو الصق المحتوى في phpMyAdmin.
--
--  آمن للتشغيل مرّتين: لو كان كل شيء محذوفًا من قبل، المعرّفات تصير NULL ولا
--  تطابق صفًّا، فلا تُحذف أي بيانات حقيقية بالخطأ.
--
--  لا يمسّ المادة (@subject_id) ولا المعلّم (@teacher_id) اللذين استُعير
--  معرّفاهما من بيانات حقيقية موجودة أصلًا — هذان لم يُنشآ لهذا الاختبار
--  فلا يُحذفان بسببه.
-- ============================================================================

SET @student_email := 'demo.student@brainixa.cloud';
SET @course_slug    := 'demo-math-g11';

SET @course_id  := (SELECT id FROM courses  WHERE slug  = @course_slug  LIMIT 1);
SET @student_id := (SELECT id FROM students WHERE email = @student_email LIMIT 1);

SELECT @course_id AS will_delete_course_id, @student_id AS will_delete_student_id;


-- ─── ١. الاشتراك ─────────────────────────────────────────────────────────────
-- يُحذف بمعرّف الطالب مباشرةً، لا بالربط بالكورس: هذا الطالب التجريبي لا
-- اشتراك له في أي كورس آخر، فحذف كل اشتراكاته آمن ولا يمسّ طالبًا حقيقيًّا.
DELETE FROM student_subscription_courses
WHERE student_subscription_id IN (SELECT id FROM (SELECT id FROM student_subscriptions WHERE student_id = @student_id) x);

DELETE FROM student_subscriptions WHERE student_id = @student_id;


-- ─── ٢. الكتب والاختبار (لا مفتاح أجنبي نحو الكورس، فالحذف يدويّ بالكامل) ────
SET @exam_id := (SELECT id FROM course_exams WHERE course_id = @course_id LIMIT 1);

DELETE FROM mcq_options_translations
WHERE mcq_option_id IN (SELECT id FROM (SELECT id FROM mcq_options WHERE question_id IN (SELECT id FROM (SELECT id FROM questions WHERE exam_id = @exam_id) q)) o);
DELETE FROM mcq_options
WHERE question_id IN (SELECT id FROM (SELECT id FROM questions WHERE exam_id = @exam_id) q);
DELETE FROM questions_translations
WHERE question_id IN (SELECT id FROM (SELECT id FROM questions WHERE exam_id = @exam_id) q);
DELETE FROM questions WHERE exam_id = @exam_id;

DELETE FROM course_exams_translations WHERE exam_id = @exam_id;
DELETE FROM course_exams WHERE course_id = @course_id;

DELETE FROM course_books WHERE course_id = @course_id;
-- الملفّان المرفوعان على الخادم (doc_6ad4b694517e71... وdoc_6ad4b695090043...)
-- يبقيان كما هما: كانا موجودين قبل هذا الاختبار وليسا جزءًا منه.


-- ─── ٣. الكورس نفسه ──────────────────────────────────────────────────────────
-- حذف صفّ الكورس يُسقط تلقائيًّا بالمفتاح الأجنبي (ON DELETE CASCADE):
-- courses_translations، وunits ومن ورائها units_translations وvideos
-- ومن ورائها videos_translations. لا حاجة لحذف هذه الجداول يدويًّا.
DELETE FROM courses WHERE id = @course_id;


-- ─── ٤. حساب الطالب ──────────────────────────────────────────────────────────
-- حذف صفّ الطالب يُسقط تلقائيًّا ما تبقّى له من صفوف فرعية بالمفتاح الأجنبي
-- (محاولات امتحان، إحالات، معاملات نقاط) — وكلّها فارغة أصلًا لحساب لم
-- يُستخدم إلا للاختبار.
DELETE FROM students WHERE id = @student_id;


-- ─── ٥. التحقّق ───────────────────────────────────────────────────────────────
-- يجب أن تعود الأصفار كلّها.
SELECT
  (SELECT COUNT(*) FROM courses                      WHERE id = @course_id) AS course_row,
  (SELECT COUNT(*) FROM courses_translations         WHERE course_id = @course_id) AS course_translations,
  (SELECT COUNT(*) FROM units                        WHERE course_id = @course_id) AS units,
  (SELECT COUNT(*) FROM course_exams                 WHERE course_id = @course_id) AS exams,
  (SELECT COUNT(*) FROM course_books                 WHERE course_id = @course_id) AS books,
  (SELECT COUNT(*) FROM students                     WHERE id = @student_id) AS student_row,
  (SELECT COUNT(*) FROM student_subscriptions        WHERE student_id = @student_id) AS subscriptions;
