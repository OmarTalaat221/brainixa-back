-- ============================================================================
--  حساب طالب تجريبي جاهز بالكامل: اشتراك فعّال + كورس + وحدات + فيديوهات +
--  ملخّصات + اختبار بأسئلة حقيقية — لاختبار شاشات «المواد الدراسية» في تطبيق
--  الطالب فعليًّا، لا بمعاينة فارغة.
--
--  لماذا ملفّ جديد لا إعادة استعمال seed_course_1_content.sql:
--  الكورس رقم ١ الذي بُني عليه ذلك الملفّ لم يعد موجودًا في قاعدة البيانات —
--  رقمه مطابق لكورس اختبار الدفع «payment-test-2egp» وليس كورس الرياضيات
--  التجريبي، وقد حُذف. فهذا الملفّ يبني كل شيء من الصفر: الكورس، الحساب،
--  والاشتراك معًا، بدل أن يفترض وجود شيء مضى.
--
--  التشغيل:
--    mysql -u campcod1_brain-ixa -p campcod1_brain-ixa < setup_demo_student_course.sql
--  أو الصق المحتوى في phpMyAdmin.
--
--  آمن للتشغيل مرّتين: كل إدراج محميّ بـ NOT EXISTS أو ON DUPLICATE KEY، فإعادة
--  التشغيل لا تُكرّر صفًّا ولا تُنشئ كورسًا ثانيًا.
--
--  بيانات الدخول (تُطبع أيضًا في آخر استعلام SELECT):
--    البريد:        demo.student@brainixa.cloud
--    كلمة المرور:   Demo@12345
-- ============================================================================


-- ─── ٠. الإعدادات ────────────────────────────────────────────────────────────
SET @course_slug   := 'demo-math-g11';
SET @student_email := 'demo.student@brainixa.cloud';
-- بصمة bcrypt لكلمة المرور Demo@12345، مولَّدة محليًّا بـ bcryptjs. PHP يقبل
-- البادئة $2b$ كما يقبل $2y$ — كلاهما بصمة bcrypt قياسية، والتحقّق لا يميّز.
SET @student_password_hash := '$2b$10$j0Vj9z2X4gr.kJfBlyYpF.jX8QzURliKRLPyv6Aj9Oyi5KdWoDTi6';
SET @video_url := 'https://camp-coding.online/brain-ixa/uploads/videos/vid_6ad4b3273623f8.23283842.mp4';
SET @admin_id   := (SELECT MIN(id) FROM admins);
SET @lang_ar    := (SELECT id FROM languages WHERE code = 'ar' LIMIT 1);
SET @lang_en    := (SELECT id FROM languages WHERE code = 'en' LIMIT 1);

-- المادة: أوّل مادة اسمها يحتوي "رياض"، وإلا أوّل مادة مفعّلة أيًّا كانت —
-- فالمهمّ أن تكون صفًّا حقيقيًّا موجودًا، لا أن تكون هذه المادة بعينها.
SET @subject_id := (
    SELECT s.id FROM subjects s
    JOIN subjects_translations st ON st.subject_id = s.id AND st.language_id = @lang_ar
    WHERE s.is_active = 1 AND st.name LIKE '%رياض%' LIMIT 1
);
SET @subject_id := COALESCE(@subject_id, (SELECT id FROM subjects WHERE is_active = 1 ORDER BY id LIMIT 1));

-- المعلّم: أوّل معلّم مفعَّل. حساب مرجعي موجود أصلًا في قاعدة البيانات، لا
-- بيانات ناجح حقيقية — راجع CLAUDE.md.
SET @teacher_id := (SELECT id FROM teachers WHERE is_active = 1 ORDER BY id LIMIT 1);


-- ─── ١. الكورس ───────────────────────────────────────────────────────────────
INSERT INTO `courses`
    (`subject_id`, `teacher_id`, `slug`, `type`, `kind`, `price`, `is_active`, `show_on_website`, `created_by_type`, `created_by_id`)
SELECT @subject_id, @teacher_id, @course_slug, 'recorded', 'normal', 0.00, 1, 1, 'admin', @admin_id
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM courses WHERE slug = @course_slug) x);

SET @course_id := (SELECT id FROM courses WHERE slug = @course_slug LIMIT 1);

INSERT INTO `courses_translations` (`course_id`, `language_id`, `name`, `description`, `is_active`)
SELECT @course_id, @lang_ar,
       'رياضيات — الصف الثاني الثانوي (تجريبي)',
       'كورس تجريبي لاختبار شاشات الفيديوهات والملخّصات والأسئلة في تطبيق الطالب.',
       1
FROM DUAL
WHERE @lang_ar IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM courses_translations WHERE course_id = @course_id AND language_id = @lang_ar) x);

INSERT INTO `courses_translations` (`course_id`, `language_id`, `name`, `description`, `is_active`)
SELECT @course_id, @lang_en,
       'Mathematics — Grade 11 (Demo)',
       'A demo course for testing the videos, summaries and questions screens in the student app.',
       1
FROM DUAL
WHERE @lang_en IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM courses_translations WHERE course_id = @course_id AND language_id = @lang_en) x);


-- ─── ٢. الوحدتان ─────────────────────────────────────────────────────────────
INSERT INTO `units` (`course_id`, `subject_id`, `code`, `order_num`, `lessons_count`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @course_id, @subject_id, 'demo-unit-1', 1, 2, 1, 'admin', @admin_id FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM units WHERE course_id = @course_id AND code = 'demo-unit-1') x);

INSERT INTO `units` (`course_id`, `subject_id`, `code`, `order_num`, `lessons_count`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @course_id, @subject_id, 'demo-unit-2', 2, 1, 1, 'admin', @admin_id FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM units WHERE course_id = @course_id AND code = 'demo-unit-2') x);

SET @u1 := (SELECT id FROM units WHERE course_id = @course_id AND code = 'demo-unit-1' LIMIT 1);
SET @u2 := (SELECT id FROM units WHERE course_id = @course_id AND code = 'demo-unit-2' LIMIT 1);

INSERT INTO `units_translations` (`unit_id`, `language_id`, `name`, `description`, `is_active`)
SELECT @u1, @lang_ar, 'الوحدة الأولى: الجبر والمتباينات', 'مقدّمة في الجبر والمتباينات.', 1 FROM DUAL
WHERE @lang_ar IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM units_translations WHERE unit_id = @u1 AND language_id = @lang_ar) x);

INSERT INTO `units_translations` (`unit_id`, `language_id`, `name`, `description`, `is_active`)
SELECT @u1, @lang_en, 'Unit 1: Algebra and Inequalities', 'An introduction to algebra and inequalities.', 1 FROM DUAL
WHERE @lang_en IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM units_translations WHERE unit_id = @u1 AND language_id = @lang_en) x);

INSERT INTO `units_translations` (`unit_id`, `language_id`, `name`, `description`, `is_active`)
SELECT @u2, @lang_ar, 'الوحدة الثانية: الدوال المثلثية', 'الدوال المثلثية الأساسية وتطبيقاتها.', 1 FROM DUAL
WHERE @lang_ar IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM units_translations WHERE unit_id = @u2 AND language_id = @lang_ar) x);

INSERT INTO `units_translations` (`unit_id`, `language_id`, `name`, `description`, `is_active`)
SELECT @u2, @lang_en, 'Unit 2: Trigonometric Functions', 'Core trigonometric functions and their uses.', 1 FROM DUAL
WHERE @lang_en IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM units_translations WHERE unit_id = @u2 AND language_id = @lang_en) x);


-- ─── ٣. الفيديوهات ───────────────────────────────────────────────────────────
-- المدّة ثوانٍ صحيحة مكتوبة مباشرةً هنا، لا نصًّا "mm:ss" يحتاج تحويلًا —
-- فعطل التحويل الذي اكتُشف في لوحة الأدمن لا علاقة له بهذا الملفّ.

INSERT INTO `videos` (`unit_id`, `order_num`, `code`, `video_url`, `duration_seconds`, `publish_status`, `is_active`)
SELECT @u1, 1, 'demo-alg-01', @video_url, 860, 'published', 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM videos WHERE unit_id = @u1 AND code = 'demo-alg-01') x);

INSERT INTO `videos` (`unit_id`, `order_num`, `code`, `video_url`, `duration_seconds`, `publish_status`, `is_active`)
SELECT @u1, 2, 'demo-alg-02', @video_url, 780, 'published', 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM videos WHERE unit_id = @u1 AND code = 'demo-alg-02') x);

INSERT INTO `videos` (`unit_id`, `order_num`, `code`, `video_url`, `duration_seconds`, `publish_status`, `is_active`)
SELECT @u2, 1, 'demo-trig-01', @video_url, 1080, 'published', 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM videos WHERE unit_id = @u2 AND code = 'demo-trig-01') x);

SET @v1 := (SELECT id FROM videos WHERE unit_id = @u1 AND code = 'demo-alg-01' LIMIT 1);
SET @v2 := (SELECT id FROM videos WHERE unit_id = @u1 AND code = 'demo-alg-02' LIMIT 1);
SET @v3 := (SELECT id FROM videos WHERE unit_id = @u2 AND code = 'demo-trig-01' LIMIT 1);

INSERT INTO `videos_translations` (`video_id`, `language_id`, `name`, `description`, `is_active`)
SELECT @v1, @lang_ar, 'المعادلات التربيعية — الحل بالتحليل', 'تحليل الحدّ الثلاثي إلى عاملين.', 1 FROM DUAL
WHERE @lang_ar IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM videos_translations WHERE video_id = @v1 AND language_id = @lang_ar) x);
INSERT INTO `videos_translations` (`video_id`, `language_id`, `name`, `description`, `is_active`)
SELECT @v1, @lang_en, 'Quadratic Equations — Solving by Factoring', 'Factoring a trinomial into two factors.', 1 FROM DUAL
WHERE @lang_en IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM videos_translations WHERE video_id = @v1 AND language_id = @lang_en) x);

INSERT INTO `videos_translations` (`video_id`, `language_id`, `name`, `description`, `is_active`)
SELECT @v2, @lang_ar, 'المتباينات التربيعية', 'حلّ المتباينات ورسم خط الحل.', 1 FROM DUAL
WHERE @lang_ar IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM videos_translations WHERE video_id = @v2 AND language_id = @lang_ar) x);
INSERT INTO `videos_translations` (`video_id`, `language_id`, `name`, `description`, `is_active`)
SELECT @v2, @lang_en, 'Quadratic Inequalities', 'Solving inequalities and the solution line.', 1 FROM DUAL
WHERE @lang_en IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM videos_translations WHERE video_id = @v2 AND language_id = @lang_en) x);

INSERT INTO `videos_translations` (`video_id`, `language_id`, `name`, `description`, `is_active`)
SELECT @v3, @lang_ar, 'الدائرة المثلثية والزوايا', 'تعريف الدائرة المثلثية وقياس الزوايا.', 1 FROM DUAL
WHERE @lang_ar IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM videos_translations WHERE video_id = @v3 AND language_id = @lang_ar) x);
INSERT INTO `videos_translations` (`video_id`, `language_id`, `name`, `description`, `is_active`)
SELECT @v3, @lang_en, 'The Unit Circle and Angles', 'Defining the unit circle and measuring angles.', 1 FROM DUAL
WHERE @lang_en IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM videos_translations WHERE video_id = @v3 AND language_id = @lang_en) x);


-- ─── ٤. الملخّصات (course_books, category='summary') ─────────────────────────
-- الملفّان مرفوعان فعلًا على الخادم من عمل سابق (تحقّقتُ أن الرابطين ما زالا
-- يُقدَّمان Content-Type: application/pdf) — لا يُرفع شيء جديد هنا.

INSERT INTO `course_books`
    (`subject_id`, `course_id`, `unit_id`, `category`, `file_type`, `extension`,
     `file_path`, `order_num`, `is_active`, `show_on_website`, `created_by_type`, `created_by_id`, `cover_image`)
SELECT @subject_id, @course_id, @u1, 'summary', 'pdf', 'pdf',
       'https://camp-coding.online/brain-ixa/uploads/documents/doc_6ad4b694517e71.96169744.pdf',
       1, 1, 1, 'admin', @admin_id, ''
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM course_books WHERE unit_id = @u1 AND category = 'summary') x);

INSERT INTO `course_books`
    (`subject_id`, `course_id`, `unit_id`, `category`, `file_type`, `extension`,
     `file_path`, `order_num`, `is_active`, `show_on_website`, `created_by_type`, `created_by_id`, `cover_image`)
SELECT @subject_id, @course_id, @u2, 'summary', 'pdf', 'pdf',
       'https://camp-coding.online/brain-ixa/uploads/documents/doc_6ad4b695090043.74079801.pdf',
       1, 1, 1, 'admin', @admin_id, ''
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM course_books WHERE unit_id = @u2 AND category = 'summary') x);


-- ─── ٥. اختبار الوحدة الأولى بثلاثة أسئلة اختيار من متعدّد ────────────────────
INSERT INTO `course_exams`
    (`subject_id`, `course_id`, `unit_id`, `order_num`, `duration_minutes`, `total_marks`, `pass_marks`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @subject_id, @course_id, @u1, 1, 15, 3, 2, 1, 'admin', @admin_id
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM course_exams WHERE course_id = @course_id AND unit_id = @u1) x);

SET @exam_id := (SELECT id FROM course_exams WHERE course_id = @course_id AND unit_id = @u1 LIMIT 1);

INSERT INTO `course_exams_translations` (`exam_id`, `language_id`, `title`, `description`)
SELECT @exam_id, @lang_ar, 'اختبار الوحدة الأولى — الجبر والمتباينات', 'ثلاثة أسئلة اختيار من متعدّد.' FROM DUAL
WHERE @lang_ar IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM course_exams_translations WHERE exam_id = @exam_id AND language_id = @lang_ar) x);
INSERT INTO `course_exams_translations` (`exam_id`, `language_id`, `title`, `description`)
SELECT @exam_id, @lang_en, 'Unit 1 Exam — Algebra and Inequalities', 'Three multiple-choice questions.' FROM DUAL
WHERE @lang_en IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM course_exams_translations WHERE exam_id = @exam_id AND language_id = @lang_en) x);

-- السؤال الأوّل
INSERT INTO `questions` (`exam_id`, `course_id`, `unit_id`, `subject_id`, `question_type`, `order_num`, `score`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @exam_id, @course_id, @u1, @subject_id, 'mcq', 1, 1.00, 1, 'admin', @admin_id FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM questions WHERE exam_id = @exam_id AND order_num = 1) x);
SET @q1 := (SELECT id FROM questions WHERE exam_id = @exam_id AND order_num = 1 LIMIT 1);

INSERT INTO `questions_translations` (`question_id`, `language_id`, `question_text`)
SELECT @q1, @lang_ar, 'ما ناتج تحليل x² − 5x + 6 ؟' FROM DUAL
WHERE @lang_ar IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM questions_translations WHERE question_id = @q1 AND language_id = @lang_ar) x);
INSERT INTO `questions_translations` (`question_id`, `language_id`, `question_text`)
SELECT @q1, @lang_en, 'Factor x² − 5x + 6.' FROM DUAL
WHERE @lang_en IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM questions_translations WHERE question_id = @q1 AND language_id = @lang_en) x);

INSERT INTO `mcq_options` (`question_id`, `option_key`, `is_correct`, `is_active`)
SELECT @q1, 'A', 1, 1 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options WHERE question_id = @q1 AND option_key = 'A') x);
INSERT INTO `mcq_options` (`question_id`, `option_key`, `is_correct`, `is_active`)
SELECT @q1, 'B', 0, 1 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options WHERE question_id = @q1 AND option_key = 'B') x);
INSERT INTO `mcq_options` (`question_id`, `option_key`, `is_correct`, `is_active`)
SELECT @q1, 'C', 0, 1 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options WHERE question_id = @q1 AND option_key = 'C') x);

SET @q1a := (SELECT id FROM mcq_options WHERE question_id = @q1 AND option_key = 'A' LIMIT 1);
SET @q1b := (SELECT id FROM mcq_options WHERE question_id = @q1 AND option_key = 'B' LIMIT 1);
SET @q1c := (SELECT id FROM mcq_options WHERE question_id = @q1 AND option_key = 'C' LIMIT 1);

INSERT INTO `mcq_options_translations` (`mcq_option_id`, `language_id`, `option_text`)
SELECT @q1a, @lang_ar, '(x − 2)(x − 3)' FROM DUAL WHERE @lang_ar IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options_translations WHERE mcq_option_id = @q1a AND language_id = @lang_ar) x);
INSERT INTO `mcq_options_translations` (`mcq_option_id`, `language_id`, `option_text`)
SELECT @q1a, @lang_en, '(x − 2)(x − 3)' FROM DUAL WHERE @lang_en IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options_translations WHERE mcq_option_id = @q1a AND language_id = @lang_en) x);
INSERT INTO `mcq_options_translations` (`mcq_option_id`, `language_id`, `option_text`)
SELECT @q1b, @lang_ar, '(x + 2)(x + 3)' FROM DUAL WHERE @lang_ar IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options_translations WHERE mcq_option_id = @q1b AND language_id = @lang_ar) x);
INSERT INTO `mcq_options_translations` (`mcq_option_id`, `language_id`, `option_text`)
SELECT @q1b, @lang_en, '(x + 2)(x + 3)' FROM DUAL WHERE @lang_en IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options_translations WHERE mcq_option_id = @q1b AND language_id = @lang_en) x);
INSERT INTO `mcq_options_translations` (`mcq_option_id`, `language_id`, `option_text`)
SELECT @q1c, @lang_ar, '(x − 1)(x − 6)' FROM DUAL WHERE @lang_ar IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options_translations WHERE mcq_option_id = @q1c AND language_id = @lang_ar) x);
INSERT INTO `mcq_options_translations` (`mcq_option_id`, `language_id`, `option_text`)
SELECT @q1c, @lang_en, '(x − 1)(x − 6)' FROM DUAL WHERE @lang_en IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options_translations WHERE mcq_option_id = @q1c AND language_id = @lang_en) x);

-- السؤال الثاني
INSERT INTO `questions` (`exam_id`, `course_id`, `unit_id`, `subject_id`, `question_type`, `order_num`, `score`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @exam_id, @course_id, @u1, @subject_id, 'mcq', 2, 1.00, 1, 'admin', @admin_id FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM questions WHERE exam_id = @exam_id AND order_num = 2) x);
SET @q2 := (SELECT id FROM questions WHERE exam_id = @exam_id AND order_num = 2 LIMIT 1);

INSERT INTO `questions_translations` (`question_id`, `language_id`, `question_text`)
SELECT @q2, @lang_ar, 'حلّ المتباينة x − 3 > 0 هو:' FROM DUAL
WHERE @lang_ar IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM questions_translations WHERE question_id = @q2 AND language_id = @lang_ar) x);
INSERT INTO `questions_translations` (`question_id`, `language_id`, `question_text`)
SELECT @q2, @lang_en, 'The solution of the inequality x − 3 > 0 is:' FROM DUAL
WHERE @lang_en IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM questions_translations WHERE question_id = @q2 AND language_id = @lang_en) x);

INSERT INTO `mcq_options` (`question_id`, `option_key`, `is_correct`, `is_active`)
SELECT @q2, 'A', 0, 1 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options WHERE question_id = @q2 AND option_key = 'A') x);
INSERT INTO `mcq_options` (`question_id`, `option_key`, `is_correct`, `is_active`)
SELECT @q2, 'B', 1, 1 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options WHERE question_id = @q2 AND option_key = 'B') x);
INSERT INTO `mcq_options` (`question_id`, `option_key`, `is_correct`, `is_active`)
SELECT @q2, 'C', 0, 1 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options WHERE question_id = @q2 AND option_key = 'C') x);

SET @q2a := (SELECT id FROM mcq_options WHERE question_id = @q2 AND option_key = 'A' LIMIT 1);
SET @q2b := (SELECT id FROM mcq_options WHERE question_id = @q2 AND option_key = 'B' LIMIT 1);
SET @q2c := (SELECT id FROM mcq_options WHERE question_id = @q2 AND option_key = 'C' LIMIT 1);

INSERT INTO `mcq_options_translations` (`mcq_option_id`, `language_id`, `option_text`)
SELECT @q2a, @lang_ar, 'x < 3' FROM DUAL WHERE @lang_ar IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options_translations WHERE mcq_option_id = @q2a AND language_id = @lang_ar) x);
INSERT INTO `mcq_options_translations` (`mcq_option_id`, `language_id`, `option_text`)
SELECT @q2a, @lang_en, 'x < 3' FROM DUAL WHERE @lang_en IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options_translations WHERE mcq_option_id = @q2a AND language_id = @lang_en) x);
INSERT INTO `mcq_options_translations` (`mcq_option_id`, `language_id`, `option_text`)
SELECT @q2b, @lang_ar, 'x > 3' FROM DUAL WHERE @lang_ar IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options_translations WHERE mcq_option_id = @q2b AND language_id = @lang_ar) x);
INSERT INTO `mcq_options_translations` (`mcq_option_id`, `language_id`, `option_text`)
SELECT @q2b, @lang_en, 'x > 3' FROM DUAL WHERE @lang_en IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options_translations WHERE mcq_option_id = @q2b AND language_id = @lang_en) x);
INSERT INTO `mcq_options_translations` (`mcq_option_id`, `language_id`, `option_text`)
SELECT @q2c, @lang_ar, 'x = 3' FROM DUAL WHERE @lang_ar IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options_translations WHERE mcq_option_id = @q2c AND language_id = @lang_ar) x);
INSERT INTO `mcq_options_translations` (`mcq_option_id`, `language_id`, `option_text`)
SELECT @q2c, @lang_en, 'x = 3' FROM DUAL WHERE @lang_en IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options_translations WHERE mcq_option_id = @q2c AND language_id = @lang_en) x);

-- السؤال الثالث
INSERT INTO `questions` (`exam_id`, `course_id`, `unit_id`, `subject_id`, `question_type`, `order_num`, `score`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @exam_id, @course_id, @u1, @subject_id, 'mcq', 3, 1.00, 1, 'admin', @admin_id FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM questions WHERE exam_id = @exam_id AND order_num = 3) x);
SET @q3 := (SELECT id FROM questions WHERE exam_id = @exam_id AND order_num = 3 LIMIT 1);

INSERT INTO `questions_translations` (`question_id`, `language_id`, `question_text`)
SELECT @q3, @lang_ar, 'عدد جذور المعادلة x² − 4 = 0 هو:' FROM DUAL
WHERE @lang_ar IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM questions_translations WHERE question_id = @q3 AND language_id = @lang_ar) x);
INSERT INTO `questions_translations` (`question_id`, `language_id`, `question_text`)
SELECT @q3, @lang_en, 'How many roots does x² − 4 = 0 have?' FROM DUAL
WHERE @lang_en IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM questions_translations WHERE question_id = @q3 AND language_id = @lang_en) x);

INSERT INTO `mcq_options` (`question_id`, `option_key`, `is_correct`, `is_active`)
SELECT @q3, 'A', 0, 1 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options WHERE question_id = @q3 AND option_key = 'A') x);
INSERT INTO `mcq_options` (`question_id`, `option_key`, `is_correct`, `is_active`)
SELECT @q3, 'B', 1, 1 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options WHERE question_id = @q3 AND option_key = 'B') x);
INSERT INTO `mcq_options` (`question_id`, `option_key`, `is_correct`, `is_active`)
SELECT @q3, 'C', 0, 1 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options WHERE question_id = @q3 AND option_key = 'C') x);

SET @q3a := (SELECT id FROM mcq_options WHERE question_id = @q3 AND option_key = 'A' LIMIT 1);
SET @q3b := (SELECT id FROM mcq_options WHERE question_id = @q3 AND option_key = 'B' LIMIT 1);
SET @q3c := (SELECT id FROM mcq_options WHERE question_id = @q3 AND option_key = 'C' LIMIT 1);

INSERT INTO `mcq_options_translations` (`mcq_option_id`, `language_id`, `option_text`)
SELECT @q3a, @lang_ar, 'جذر واحد' FROM DUAL WHERE @lang_ar IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options_translations WHERE mcq_option_id = @q3a AND language_id = @lang_ar) x);
INSERT INTO `mcq_options_translations` (`mcq_option_id`, `language_id`, `option_text`)
SELECT @q3a, @lang_en, 'One root' FROM DUAL WHERE @lang_en IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options_translations WHERE mcq_option_id = @q3a AND language_id = @lang_en) x);
INSERT INTO `mcq_options_translations` (`mcq_option_id`, `language_id`, `option_text`)
SELECT @q3b, @lang_ar, 'جذران' FROM DUAL WHERE @lang_ar IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options_translations WHERE mcq_option_id = @q3b AND language_id = @lang_ar) x);
INSERT INTO `mcq_options_translations` (`mcq_option_id`, `language_id`, `option_text`)
SELECT @q3b, @lang_en, 'Two roots' FROM DUAL WHERE @lang_en IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options_translations WHERE mcq_option_id = @q3b AND language_id = @lang_en) x);
INSERT INTO `mcq_options_translations` (`mcq_option_id`, `language_id`, `option_text`)
SELECT @q3c, @lang_ar, 'لا يوجد جذر حقيقي' FROM DUAL WHERE @lang_ar IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options_translations WHERE mcq_option_id = @q3c AND language_id = @lang_ar) x);
INSERT INTO `mcq_options_translations` (`mcq_option_id`, `language_id`, `option_text`)
SELECT @q3c, @lang_en, 'No real root' FROM DUAL WHERE @lang_en IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM mcq_options_translations WHERE mcq_option_id = @q3c AND language_id = @lang_en) x);


-- ─── ٦. حساب الطالب التجريبي ─────────────────────────────────────────────────
INSERT INTO `students` (`name`, `email`, `password`, `study_language`, `is_email_verified`, `is_active`)
SELECT 'طالب تجريبي', @student_email, @student_password_hash, 'arabic', 1, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM students WHERE email = @student_email) x);

-- لو كان الحساب موجودًا من تشغيل سابق بكلمة مرور مختلفة، تُحدَّث هنا لتطابق
-- كلمة المرور المذكورة أعلى الملفّ — حتى لا يفاجئك دخول مرفوض بعد قراءة ما
-- كُتب هنا كحقيقة حالية.
UPDATE `students` SET `password` = @student_password_hash, `is_active` = 1
WHERE `email` = @student_email;

SET @student_id := (SELECT id FROM students WHERE email = @student_email LIMIT 1);


-- ─── ٧. الاشتراك: يفتح هذا الكورس تحديدًا، سارٍ ستّة أشهر ────────────────────
-- مُعرَّف الاشتراك القائم (إن وُجد) يُحسَب أوّلًا، قبل أي إدراج — لأن حساب
-- معرّف اشتراكٍ جديد عبر الربط بالكورس مستحيل بداهةً: الربط نفسه لم يُكتب بعد.
-- هذا بالضبط ما كُسر في أوّل نسخة من هذا الملفّ: حاولت قراءة معرّف الاشتراك
-- عبر جدول الربط قبل إدراج الربط، فجاء NULL دائمًا، وبقي الاشتراك يتيمًا —
-- موجودًا، نشطًا، لكن غير مربوط بأي كورس. من شغّل تلك النسخة يُصلحه بملفّ
-- fix_demo_subscription_link.sql المرفق، لا بإعادة تشغيل هذا الملفّ، لأن
-- إعادة التشغيل هنا كانت ستُنشئ اشتراكًا يتيمًا ثانيًا بجوار الأوّل.
SET @existing_sub_id := (
    SELECT ss.id FROM student_subscriptions ss
    JOIN student_subscription_courses ssc ON ssc.student_subscription_id = ss.id
    WHERE ss.student_id = @student_id AND ssc.course_id = @course_id AND ss.is_active = 1
    ORDER BY ss.id DESC LIMIT 1
);

INSERT INTO `student_subscriptions` (`student_id`, `subscription_type`, `start_date`, `end_date`, `is_active`)
SELECT @student_id, 'course', NOW(), DATE_ADD(NOW(), INTERVAL 6 MONTH), 1
FROM DUAL
WHERE @existing_sub_id IS NULL;

-- الموجود إن وُجد، وإلا معرّف ما أُدرِج للتوّ — لا طريق ثالث. LAST_INSERT_ID()
-- يبقى على قيمته السابقة ما لم يُنفَّذ إدراجٌ فعليّ، فلا خطر من قراءته هنا
-- حين لا حاجة إليه أصلًا (حالة @existing_sub_id الموجودة).
SET @sub_id := IF(@existing_sub_id IS NOT NULL, @existing_sub_id, LAST_INSERT_ID());

INSERT INTO `student_subscription_courses` (`student_subscription_id`, `course_id`)
SELECT @sub_id, @course_id
FROM DUAL
WHERE @sub_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM student_subscription_courses WHERE student_subscription_id = @sub_id AND course_id = @course_id) x);


-- ─── ٨. التحقّق ───────────────────────────────────────────────────────────────
SELECT
    'بيانات الدخول' AS what, @student_email AS email, 'Demo@12345' AS password
UNION ALL
SELECT 'course_id', @course_id, NULL
UNION ALL
SELECT 'عدد الوحدات', (SELECT COUNT(*) FROM units WHERE course_id = @course_id), NULL
UNION ALL
SELECT 'عدد الفيديوهات', (SELECT COUNT(*) FROM videos v JOIN units u ON v.unit_id = u.id WHERE u.course_id = @course_id), NULL
UNION ALL
SELECT 'عدد الملخّصات', (SELECT COUNT(*) FROM course_books WHERE course_id = @course_id AND category = 'summary'), NULL
UNION ALL
SELECT 'عدد أسئلة الاختبار', (SELECT COUNT(*) FROM questions WHERE exam_id = @exam_id), NULL
UNION ALL
SELECT 'الاشتراك فعّال؟', (SELECT is_active FROM student_subscriptions WHERE id = @sub_id), NULL;
