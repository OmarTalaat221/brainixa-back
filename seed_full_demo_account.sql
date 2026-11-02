-- ============================================================================
--  حساب طالب تجريبي مكتمل بالكامل: اشتراك فعّال في كورس منظَّم بوحدتين، فيديوهات،
--  كتب (ملخّصات PDF)، اختبار بأسئلة اختيار من متعدد + صواب/خطأ + سؤال مقالي
--  (سؤال وجواب)، حصّة اليوم (class_sessions) تظهر في «حصص اليوم»، استشارة
--  محجوزة ومعتمدة مع معلّم الكورس، وباقة (kind='package') مشترك بها الطالب
--  نفسه ومحجوز له فيها موعد فردي اليوم (teacher_availability_slots).
--
--  لماذا ملفّ جديد لا إعادة استعمال setup_demo_student_course.sql:
--  ذلك الملفّ بنى كورس "demo-math-g11" لحساب "demo.student@brainixa.cloud" بكلمة
--  مرور مختلفة (Demo@12345)، ولا نعرف يقينًا أنه نُفِّذ فعلًا على القاعدة الحيّة.
--  هذا الملفّ مستقلّ تمامًا: ينشئ كل شيء من الصفر تحت بريد وكلمة مرور جديدين،
--  ويضيف ما لم يكن موجودًا في أي ملفّ سابق: حصّة اليوم والاستشارة.
--
--  التشغيل (في طرفية cPanel، على الخادم فقط — لا تنفيذ محليًّا ممكن):
--    mysql -u campcod1_brain-ixa -p campcod1_brain-ixa < seed_full_demo_account.sql
--  أو الصق المحتوى في phpMyAdmin.
--
--  آمن للتشغيل مرّتين: كل إدراج محميّ بـ NOT EXISTS أو بفحص مسبق لمعرّف الصفّ.
--
--  بيانات الدخول (تُطبع أيضًا في آخر استعلام SELECT):
--    البريد:        demo.full@brainixa.cloud
--    كلمة المرور:   12345678
-- ============================================================================


-- ─── ٠. الإعدادات ────────────────────────────────────────────────────────────
SET @course_slug    := 'demo-full-pack-g11';
SET @student_email  := 'demo.full@brainixa.cloud';
-- بصمة bcrypt لكلمة المرور 12345678، مولَّدة محليًّا بمكتبة bcryptjs (نفس ما
-- يقبله الباك: البادئة $2b$ مقبولة كما $2y$).
SET @student_password_hash := '$2b$10$3lS8tBYLIKoH1oDOgnajzul6LsfMlkSEROaGVkCMnaDXSC4Z3Jz3a';
SET @video_url := 'https://camp-coding.online/brain-ixa/uploads/videos/vid_6ad4b3273623f8.23283842.mp4';
SET @admin_id   := (SELECT MIN(id) FROM admins);
SET @lang_ar    := (SELECT id FROM languages WHERE code = 'ar' LIMIT 1);
SET @lang_en    := (SELECT id FROM languages WHERE code = 'en' LIMIT 1);

-- المادة: أوّل مادة اسمها يحتوي "رياض"، وإلا أوّل مادة مفعّلة أيًّا كانت.
SET @subject_id := (
    SELECT s.id FROM subjects s
    JOIN subjects_translations st ON st.subject_id = s.id AND st.language_id = @lang_ar
    WHERE s.is_active = 1 AND st.name LIKE '%رياض%' LIMIT 1
);
SET @subject_id := COALESCE(@subject_id, (SELECT id FROM subjects WHERE is_active = 1 ORDER BY id LIMIT 1));

-- المعلّم: أوّل معلّم مفعَّل. حساب مرجعي موجود أصلًا في قاعدة البيانات.
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
       'باقة متكاملة — الصف الثاني الثانوي (تجريبي)',
       'كورس تجريبي كامل: وحدات، فيديوهات، كتب، اختبار، حصّة يوميّة، واستشارة.',
       1
FROM DUAL
WHERE @lang_ar IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM courses_translations WHERE course_id = @course_id AND language_id = @lang_ar) x);

INSERT INTO `courses_translations` (`course_id`, `language_id`, `name`, `description`, `is_active`)
SELECT @course_id, @lang_en,
       'Full Package — Grade 11 (Demo)',
       'A complete demo course: units, videos, books, exam, a daily session, and a consultation.',
       1
FROM DUAL
WHERE @lang_en IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM courses_translations WHERE course_id = @course_id AND language_id = @lang_en) x);


-- ─── ٢. الوحدتان ─────────────────────────────────────────────────────────────
INSERT INTO `units` (`course_id`, `subject_id`, `code`, `order_num`, `lessons_count`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @course_id, @subject_id, 'full-unit-1', 1, 2, 1, 'admin', @admin_id FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM units WHERE course_id = @course_id AND code = 'full-unit-1') x);

INSERT INTO `units` (`course_id`, `subject_id`, `code`, `order_num`, `lessons_count`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @course_id, @subject_id, 'full-unit-2', 2, 2, 1, 'admin', @admin_id FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM units WHERE course_id = @course_id AND code = 'full-unit-2') x);

SET @u1 := (SELECT id FROM units WHERE course_id = @course_id AND code = 'full-unit-1' LIMIT 1);
SET @u2 := (SELECT id FROM units WHERE course_id = @course_id AND code = 'full-unit-2' LIMIT 1);

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


-- ─── ٣. الفيديوهات (جدول `videos` الصحيح، لا `course_videos` المهجور) ────────
INSERT INTO `videos` (`unit_id`, `order_num`, `code`, `video_url`, `duration_seconds`, `publish_status`, `is_active`)
SELECT @u1, 1, 'full-alg-01', @video_url, 860, 'published', 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM videos WHERE unit_id = @u1 AND code = 'full-alg-01') x);
INSERT INTO `videos` (`unit_id`, `order_num`, `code`, `video_url`, `duration_seconds`, `publish_status`, `is_active`)
SELECT @u1, 2, 'full-alg-02', @video_url, 780, 'published', 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM videos WHERE unit_id = @u1 AND code = 'full-alg-02') x);
INSERT INTO `videos` (`unit_id`, `order_num`, `code`, `video_url`, `duration_seconds`, `publish_status`, `is_active`)
SELECT @u2, 1, 'full-trig-01', @video_url, 1080, 'published', 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM videos WHERE unit_id = @u2 AND code = 'full-trig-01') x);
INSERT INTO `videos` (`unit_id`, `order_num`, `code`, `video_url`, `duration_seconds`, `publish_status`, `is_active`)
SELECT @u2, 2, 'full-trig-02', @video_url, 940, 'published', 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM videos WHERE unit_id = @u2 AND code = 'full-trig-02') x);

SET @v1 := (SELECT id FROM videos WHERE unit_id = @u1 AND code = 'full-alg-01'  LIMIT 1);
SET @v2 := (SELECT id FROM videos WHERE unit_id = @u1 AND code = 'full-alg-02'  LIMIT 1);
SET @v3 := (SELECT id FROM videos WHERE unit_id = @u2 AND code = 'full-trig-01' LIMIT 1);
SET @v4 := (SELECT id FROM videos WHERE unit_id = @u2 AND code = 'full-trig-02' LIMIT 1);

INSERT INTO `videos_translations` (`video_id`, `language_id`, `name`, `description`, `is_active`)
SELECT t.video_id, l.id,
       CASE WHEN l.code = 'en' THEN t.name_en ELSE t.name_ar END,
       CASE WHEN l.code = 'en' THEN t.desc_en ELSE t.desc_ar END, 1
FROM (
  SELECT @v1 AS video_id,
         'المعادلات التربيعية — الحل بالتحليل' AS name_ar, 'Quadratic Equations - Solving by Factoring' AS name_en,
         'تحليل الحدّ الثلاثي إلى عاملين.' AS desc_ar, 'Factoring a trinomial into two factors.' AS desc_en
  UNION ALL SELECT @v2, 'المتباينات التربيعية', 'Quadratic Inequalities',
         'حلّ المتباينات ورسم خط الحل.', 'Solving inequalities and the solution line.'
  UNION ALL SELECT @v3, 'الدائرة المثلثية والزوايا', 'The Unit Circle and Angles',
         'تعريف الدائرة المثلثية وقياس الزوايا.', 'Defining the unit circle and measuring angles.'
  UNION ALL SELECT @v4, 'قانونا الجيب وجيب التمام', 'The Sine and Cosine Rules',
         'متى يُستعمل كل قانون، مع أمثلة.', 'When to use each rule, with examples.'
) t
CROSS JOIN `languages` l
WHERE l.is_active = 1 AND t.video_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT video_id, language_id FROM videos_translations) x WHERE x.video_id = t.video_id AND x.language_id = l.id);


-- ─── ٤. الكتب (ملخّصات PDF لكل وحدة، course_books فئة summary) ───────────────
-- الملفّات مرفوعة فعلًا على الخادم من عمل سابق (fix_course_1_content.sql تحقّق
-- من اثنين منها، والثالث من نفس الدفعة) — لا يُرفع شيء جديد هنا.
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

SET @b1 := (SELECT id FROM course_books WHERE unit_id = @u1 AND category = 'summary' LIMIT 1);
SET @b2 := (SELECT id FROM course_books WHERE unit_id = @u2 AND category = 'summary' LIMIT 1);

INSERT INTO `course_books_translations` (`book_id`, `language_id`, `title`, `description`)
SELECT t.book_id, l.id,
       CASE WHEN l.code = 'en' THEN t.title_en ELSE t.title_ar END,
       CASE WHEN l.code = 'en' THEN t.desc_en ELSE t.desc_ar END
FROM (
  SELECT @b1 AS book_id, 'كتاب الوحدة الأولى — الجبر والمتباينات' AS title_ar, 'Unit 1 Book - Algebra and Inequalities' AS title_en,
         'ملخّص ومسائل محلولة.' AS desc_ar, 'Summary and worked problems.' AS desc_en
  UNION ALL SELECT @b2, 'كتاب الوحدة الثانية — حساب المثلثات', 'Unit 2 Book - Trigonometry',
         'ملخّص ومسائل محلولة.', 'Summary and worked problems.'
) t
CROSS JOIN `languages` l
WHERE l.is_active = 1 AND t.book_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT book_id, language_id FROM course_books_translations) x WHERE x.book_id = t.book_id AND x.language_id = l.id);


-- ─── ٥. اختبار الوحدة الأولى: اختيار من متعدد + صواب/خطأ + سؤال مقالي ────────
INSERT INTO `course_exams`
    (`subject_id`, `course_id`, `unit_id`, `order_num`, `duration_minutes`, `total_marks`, `pass_marks`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @subject_id, @course_id, @u1, 1, 20, 4, 3, 1, 'admin', @admin_id
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM course_exams WHERE course_id = @course_id AND unit_id = @u1) x);

SET @exam_id := (SELECT id FROM course_exams WHERE course_id = @course_id AND unit_id = @u1 LIMIT 1);

INSERT INTO `course_exams_translations` (`exam_id`, `language_id`, `title`, `description`)
SELECT @exam_id, l.id,
       CASE WHEN l.code = 'en' THEN 'Unit 1 Exam - Algebra and Inequalities' ELSE 'اختبار الوحدة الأولى — الجبر والمتباينات' END,
       CASE WHEN l.code = 'en' THEN 'MCQ, true/false, and a short written question.' ELSE 'اختيار من متعدد، صواب وخطأ، وسؤال مقالي قصير.' END
FROM `languages` l
WHERE l.is_active = 1 AND @exam_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT exam_id, language_id FROM course_exams_translations) x WHERE x.exam_id = @exam_id AND x.language_id = l.id);

-- السؤال الأوّل: اختيار من متعدد
INSERT INTO `questions` (`exam_id`, `course_id`, `unit_id`, `subject_id`, `question_type`, `order_num`, `score`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @exam_id, @course_id, @u1, @subject_id, 'mcq', 1, 1.00, 1, 'admin', @admin_id FROM DUAL
WHERE @exam_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM questions WHERE exam_id = @exam_id AND order_num = 1) x);
SET @q1 := (SELECT id FROM questions WHERE exam_id = @exam_id AND order_num = 1 LIMIT 1);

INSERT INTO `questions_translations` (`question_id`, `language_id`, `question_text`)
SELECT @q1, l.id, CASE WHEN l.code = 'en' THEN 'Factor x² − 5x + 6.' ELSE 'ما ناتج تحليل x² − 5x + 6 ؟' END
FROM `languages` l WHERE l.is_active = 1 AND @q1 IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT question_id, language_id FROM questions_translations) x WHERE x.question_id = @q1 AND x.language_id = l.id);

INSERT INTO `mcq_options` (`question_id`, `option_key`, `is_correct`, `is_active`)
SELECT @q1, o.okey, o.correct, 1 FROM (SELECT 'A' AS okey, 1 AS correct UNION ALL SELECT 'B', 0 UNION ALL SELECT 'C', 0) o
WHERE @q1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT question_id, option_key FROM mcq_options) x WHERE x.question_id = @q1 AND x.option_key = o.okey);

SET @q1a := (SELECT id FROM mcq_options WHERE question_id = @q1 AND option_key = 'A' LIMIT 1);
SET @q1b := (SELECT id FROM mcq_options WHERE question_id = @q1 AND option_key = 'B' LIMIT 1);
SET @q1c := (SELECT id FROM mcq_options WHERE question_id = @q1 AND option_key = 'C' LIMIT 1);

INSERT INTO `mcq_options_translations` (`mcq_option_id`, `language_id`, `option_text`)
SELECT t.oid, l.id, CASE WHEN l.code = 'en' THEN t.text_en ELSE t.text_ar END
FROM (
  SELECT @q1a AS oid, '(x − 2)(x − 3)' AS text_ar, '(x - 2)(x - 3)' AS text_en
  UNION ALL SELECT @q1b, '(x + 2)(x + 3)', '(x + 2)(x + 3)'
  UNION ALL SELECT @q1c, '(x − 1)(x − 6)', '(x - 1)(x - 6)'
) t
CROSS JOIN `languages` l
WHERE l.is_active = 1 AND t.oid IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT mcq_option_id, language_id FROM mcq_options_translations) x WHERE x.mcq_option_id = t.oid AND x.language_id = l.id);

-- السؤال الثاني: صواب وخطأ
INSERT INTO `questions` (`exam_id`, `course_id`, `unit_id`, `subject_id`, `question_type`, `order_num`, `score`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @exam_id, @course_id, @u1, @subject_id, 'true_false', 2, 1.00, 1, 'admin', @admin_id FROM DUAL
WHERE @exam_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM questions WHERE exam_id = @exam_id AND order_num = 2) x);
SET @q2 := (SELECT id FROM questions WHERE exam_id = @exam_id AND order_num = 2 LIMIT 1);

INSERT INTO `questions_translations` (`question_id`, `language_id`, `question_text`)
SELECT @q2, l.id, CASE WHEN l.code = 'en' THEN 'The sum of the roots of ax² + bx + c = 0 equals (-b / a).' ELSE 'مجموع جذري المعادلة أ س² + ب س + جـ = ٠ يساوي (−ب ÷ أ).' END
FROM `languages` l WHERE l.is_active = 1 AND @q2 IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT question_id, language_id FROM questions_translations) x WHERE x.question_id = @q2 AND x.language_id = l.id);

INSERT INTO `true_false_answers` (`question_id`, `correct_answer`, `is_active`)
SELECT @q2, 1, 1 FROM DUAL
WHERE @q2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT question_id FROM true_false_answers) x WHERE x.question_id = @q2);

-- السؤال الثالث: مقالي (سؤال وجواب)
INSERT INTO `questions` (`exam_id`, `course_id`, `unit_id`, `subject_id`, `question_type`, `order_num`, `score`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @exam_id, @course_id, @u1, @subject_id, 'written', 3, 2.00, 1, 'admin', @admin_id FROM DUAL
WHERE @exam_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM questions WHERE exam_id = @exam_id AND order_num = 3) x);
SET @q3 := (SELECT id FROM questions WHERE exam_id = @exam_id AND order_num = 3 LIMIT 1);

INSERT INTO `questions_translations` (`question_id`, `language_id`, `question_text`)
SELECT @q3, l.id, CASE WHEN l.code = 'en' THEN 'Explain, with an example, when factoring a quadratic fails to find its roots.' ELSE 'اشرح، مع مثال، متى يفشل التحليل في إيجاد جذري معادلة تربيعية.' END
FROM `languages` l WHERE l.is_active = 1 AND @q3 IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT question_id, language_id FROM questions_translations) x WHERE x.question_id = @q3 AND x.language_id = l.id);

INSERT INTO `written_model_answers` (`question_id`, `is_active`)
SELECT @q3, 1 FROM DUAL
WHERE @q3 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT question_id FROM written_model_answers) x WHERE x.question_id = @q3);

SET @wma_id := (SELECT id FROM written_model_answers WHERE question_id = @q3 LIMIT 1);

INSERT INTO `written_model_answers_translations` (`written_model_answer_id`, `language_id`, `model_answer`)
SELECT @wma_id, l.id,
       CASE WHEN l.code = 'en' THEN 'When the discriminant is negative there is no real factorisation; e.g. x² + x + 1 = 0 has no real roots, so it must be solved with the quadratic formula over complex numbers or left as "no real solution".' ELSE 'حين يكون المميّز سالبًا لا يوجد تحليل حقيقي؛ مثال: س² + س + ١ = ٠ ليس لها جذور حقيقية، فتُحلّ بالقانون العام أو يُكتب أنه لا يوجد حل حقيقي.' END
FROM `languages` l WHERE l.is_active = 1 AND @wma_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT written_model_answer_id, language_id FROM written_model_answers_translations) x WHERE x.written_model_answer_id = @wma_id AND x.language_id = l.id);


-- ─── ٦. حساب الطالب التجريبي ─────────────────────────────────────────────────
INSERT INTO `students` (`name`, `email`, `password`, `study_language`, `is_email_verified`, `is_active`)
SELECT 'طالب تجريبي كامل', @student_email, @student_password_hash, 'arabic', 1, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM students WHERE email = @student_email) x);

-- لو كان الحساب موجودًا من تشغيل سابق، تُحدَّث كلمة المرور هنا لتطابق المذكورة أعلى الملفّ.
UPDATE `students` SET `password` = @student_password_hash, `is_active` = 1
WHERE `email` = @student_email;

SET @student_id := (SELECT id FROM students WHERE email = @student_email LIMIT 1);


-- ─── ٧. الاشتراك: يفتح هذا الكورس تحديدًا، سارٍ ستّة أشهر ────────────────────
-- معرّف الاشتراك القائم (إن وُجد) يُحسَب أوّلًا، قبل أي إدراج — تجنّبًا لعطل
-- الاشتراك اليتيم الذي وقع في setup_demo_student_course.sql (أُصلح هناك بملفّ
-- fix_demo_subscription_link.sql منفصل)؛ هنا الترتيب صحيح من أوّل تشغيل.
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

SET @sub_id := IF(@existing_sub_id IS NOT NULL, @existing_sub_id, LAST_INSERT_ID());

INSERT INTO `student_subscription_courses` (`student_subscription_id`, `course_id`)
SELECT @sub_id, @course_id
FROM DUAL
WHERE @sub_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM student_subscription_courses WHERE student_subscription_id = @sub_id AND course_id = @course_id) x);


-- ─── ٨. حصّة اليوم (class_sessions) ──────────────────────────────────────────
-- day_of_week يُحسب من تاريخ اليوم الفعليّ وقت التشغيل (DATE_FORMAT(..., '%W')
-- يُعيد اسم اليوم بالإنجليزية كما يتوقّعه العمود)، ووقتا البداية والنهاية حول
-- اللحظة الحالية، فتظهر الحصّة "متاحة الآن" مباشرةً بعد تشغيل الملفّ.
SET @today_name := DATE_FORMAT(NOW(), '%W');

INSERT INTO `class_sessions` (`teacher_id`, `subject_id`, `course_id`, `code`, `day_of_week`, `start_time`, `end_time`, `room`, `is_online`, `meeting_link`, `is_active`)
SELECT @teacher_id, @subject_id, @course_id, 'full-demo-session', @today_name,
       SUBTIME(CURTIME(), '00:10:00'), ADDTIME(CURTIME(), '01:00:00'),
       NULL, 1, 'https://zoom.us/j/0000000000?pwd=demo', 1
FROM DUAL
WHERE @teacher_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM class_sessions WHERE course_id = @course_id AND code = 'full-demo-session') x);

-- لو كان موجودًا من تشغيل سابق في يوم آخر، يُحدَّث إلى يوم اليوم ووقت قريب من
-- اللحظة الحالية، ليبقى "متاحًا الآن" عند كل تشغيل، لا عند أوّل تشغيل فقط.
UPDATE `class_sessions`
   SET `day_of_week` = @today_name,
       `start_time`  = SUBTIME(CURTIME(), '00:10:00'),
       `end_time`    = ADDTIME(CURTIME(), '01:00:00'),
       `is_active`   = 1
 WHERE `course_id` = @course_id AND `code` = 'full-demo-session';


-- ─── ٩. استشارة محجوزة ومعتمدة مع معلّم الكورس ───────────────────────────────
SET @consult_id := (
    SELECT id FROM consultation_slots
    WHERE teacher_id = @teacher_id AND student_id = @student_id AND is_active = 1
    ORDER BY id DESC LIMIT 1
);

INSERT INTO `consultation_slots` (`teacher_id`, `subject_id`, `type`, `meeting_type`, `slot_date`, `slot_time`, `notes`, `is_booked`, `student_id`, `booked_at`, `status`, `is_active`)
SELECT @teacher_id, @subject_id, 'educational', 'video_call', CURDATE(), ADDTIME(CURTIME(), '02:00:00'),
       'استشارة تجريبية — راجع خطة المذاكرة الأسبوعية.', 1, @student_id, NOW(), 'approved', 1
FROM DUAL
WHERE @teacher_id IS NOT NULL AND @consult_id IS NULL;

-- لو كانت موجودة من تشغيل سابق، تُحدَّث إلى تاريخ اليوم ووقت قريب من اللحظة
-- الحالية، وتبقى معتمدة.
UPDATE `consultation_slots`
   SET `slot_date` = CURDATE(),
       `slot_time` = ADDTIME(CURTIME(), '02:00:00'),
       `is_booked` = 1, `student_id` = @student_id, `status` = 'approved', `is_active` = 1
 WHERE `id` = @consult_id;


-- ─── ١٠. كورس باقة (kind = 'package') + موعد باقة محجوز اليوم ────────────────
-- الباقة كورس مستقلّ عن الكورس العادي أعلاه (الفرق الوحيد عمود kind)، ومواعيده
-- تُحجز عبر teacher_availability_slots/availability_slot_bookings لا
-- class_sessions — فالطالب يشترك في الباقة بالضبط كما يشترك في أي كورس
-- (student_subscription_courses)، لكنه يحجز موعدًا محدّدًا بدل جدول أسبوعي ثابت.
SET @package_slug := 'demo-package-g11';

INSERT INTO `courses`
    (`subject_id`, `teacher_id`, `slug`, `type`, `kind`, `duration_months`, `price`, `is_active`, `show_on_website`, `created_by_type`, `created_by_id`)
SELECT @subject_id, @teacher_id, @package_slug, 'recorded', 'package', 1, 500.00, 1, 1, 'admin', @admin_id
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM courses WHERE slug = @package_slug) x);

SET @package_id := (SELECT id FROM courses WHERE slug = @package_slug LIMIT 1);

INSERT INTO `courses_translations` (`course_id`, `language_id`, `name`, `description`, `is_active`)
SELECT @package_id, l.id,
       CASE WHEN l.code = 'en' THEN 'Monthly Package - One-to-One Sessions (Demo)' ELSE 'باقة شهرية — حصص فردية (تجريبي)' END,
       CASE WHEN l.code = 'en' THEN 'A monthly package: book one-to-one appointments with the teacher.' ELSE 'باقة شهرية: احجزي مواعيد فردية مباشرة مع المعلّم.' END,
       1
FROM `languages` l
WHERE l.is_active = 1 AND @package_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT course_id, language_id FROM courses_translations) x WHERE x.course_id = @package_id AND x.language_id = l.id);

-- اشتراك الطالب في الباقة: صفّ ربط إضافي على نفس الاشتراك الفعّال أعلاه
-- (student_subscriptions واحد قد يفتح أكثر من كورس)، لا اشتراكًا منفصلًا.
INSERT INTO `student_subscription_courses` (`student_subscription_id`, `course_id`)
SELECT @sub_id, @package_id
FROM DUAL
WHERE @sub_id IS NOT NULL AND @package_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM student_subscription_courses WHERE student_subscription_id = @sub_id AND course_id = @package_id) x);

-- الموعد: اليوم، بعد ٣ ساعات من لحظة التشغيل، سعة واحد، محجوز بالكامل من الطالب نفسه.
SET @avail_slot_id := (
    SELECT id FROM teacher_availability_slots
    WHERE teacher_id = @teacher_id AND course_id = @package_id AND notes = 'full-demo-package-slot'
    ORDER BY id DESC LIMIT 1
);

INSERT INTO `teacher_availability_slots` (`teacher_id`, `course_id`, `subject_id`, `slot_date`, `start_time`, `end_time`, `capacity`, `booked_count`, `status`, `is_online`, `meeting_link`, `notes`, `created_by_type`, `created_by_id`)
SELECT @teacher_id, @package_id, @subject_id, CURDATE(), ADDTIME(CURTIME(), '03:00:00'), ADDTIME(CURTIME(), '03:30:00'),
       1, 0, 'available', 1, 'https://zoom.us/j/1111111111?pwd=demo', 'full-demo-package-slot', 'admin', @admin_id
FROM DUAL
WHERE @teacher_id IS NOT NULL AND @package_id IS NOT NULL AND @avail_slot_id IS NULL;

SET @avail_slot_id := COALESCE(@avail_slot_id, LAST_INSERT_ID());

-- لو كان موجودًا من تشغيل سابق في تاريخ فائت، يُحدَّث إلى اليوم ويُعاد فتحه،
-- ليبقى "موعد اليوم" عند كل تشغيل.
UPDATE `teacher_availability_slots`
   SET `slot_date` = CURDATE(),
       `start_time` = ADDTIME(CURTIME(), '03:00:00'),
       `end_time`   = ADDTIME(CURTIME(), '03:30:00'),
       `status`     = 'available',
       `booked_count` = 0
 WHERE `id` = @avail_slot_id;

SET @avail_booking_id := (
    SELECT id FROM availability_slot_bookings
    WHERE slot_id = @avail_slot_id AND student_id = @student_id LIMIT 1
);

INSERT INTO `availability_slot_bookings` (`slot_id`, `student_id`, `student_subscription_id`, `status`, `booked_by_type`, `booked_by_id`)
SELECT @avail_slot_id, @student_id, @sub_id, 'booked', 'student', @student_id
FROM DUAL
WHERE @avail_slot_id IS NOT NULL AND @avail_booking_id IS NULL;

UPDATE `availability_slot_bookings` SET `status` = 'booked' WHERE `id` = @avail_booking_id;

UPDATE `teacher_availability_slots`
   SET `booked_count` = 1, `status` = 'full'
 WHERE `id` = @avail_slot_id;


-- ─── ١١. العدّادات ───────────────────────────────────────────────────────────
UPDATE `units` u
   SET u.lessons_count = (SELECT COUNT(*) FROM videos v WHERE v.unit_id = u.id AND v.is_active = 1)
 WHERE u.course_id = @course_id;

UPDATE `courses` c
   SET c.lessons_count = (
         SELECT COUNT(*) FROM videos v
         JOIN units un ON un.id = v.unit_id
        WHERE un.course_id = @course_id AND v.is_active = 1)
 WHERE c.id = @course_id;


-- ─── ١٢. امتحان على الكورس العادي كاملًا (unit_id فاضي، لا وحدة بعينها) ───────
INSERT INTO `course_exams`
    (`subject_id`, `course_id`, `unit_id`, `order_num`, `duration_minutes`, `total_marks`, `pass_marks`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @subject_id, @course_id, NULL, 2, 30, 2, 1, 1, 'admin', @admin_id
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM course_exams WHERE course_id = @course_id AND unit_id IS NULL) x);

SET @course_exam_id := (SELECT id FROM course_exams WHERE course_id = @course_id AND unit_id IS NULL LIMIT 1);

INSERT INTO `course_exams_translations` (`exam_id`, `language_id`, `title`, `description`)
SELECT @course_exam_id, l.id,
       CASE WHEN l.code = 'en' THEN 'Full Course Exam' ELSE 'امتحان الكورس كاملًا' END,
       CASE WHEN l.code = 'en' THEN 'Covers both units, not a single one.' ELSE 'يغطّي الوحدتين معًا، لا وحدة بعينها.' END
FROM `languages` l
WHERE l.is_active = 1 AND @course_exam_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT exam_id, language_id FROM course_exams_translations) x WHERE x.exam_id = @course_exam_id AND x.language_id = l.id);

INSERT INTO `questions` (`exam_id`, `course_id`, `subject_id`, `question_type`, `order_num`, `score`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @course_exam_id, @course_id, @subject_id, 'mcq', 1, 1.00, 1, 'admin', @admin_id FROM DUAL
WHERE @course_exam_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM questions WHERE exam_id = @course_exam_id AND order_num = 1) x);
SET @cq1 := (SELECT id FROM questions WHERE exam_id = @course_exam_id AND order_num = 1 LIMIT 1);

INSERT INTO `questions_translations` (`question_id`, `language_id`, `question_text`)
SELECT @cq1, l.id, CASE WHEN l.code = 'en' THEN 'Which unit covers the unit circle?' ELSE 'أي وحدة تتناول الدائرة المثلثية؟' END
FROM `languages` l WHERE l.is_active = 1 AND @cq1 IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT question_id, language_id FROM questions_translations) x WHERE x.question_id = @cq1 AND x.language_id = l.id);

INSERT INTO `mcq_options` (`question_id`, `option_key`, `is_correct`, `is_active`)
SELECT @cq1, o.okey, o.correct, 1 FROM (SELECT 'A' AS okey, 0 AS correct UNION ALL SELECT 'B', 1) o
WHERE @cq1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT question_id, option_key FROM mcq_options) x WHERE x.question_id = @cq1 AND x.option_key = o.okey);

SET @cq1a := (SELECT id FROM mcq_options WHERE question_id = @cq1 AND option_key = 'A' LIMIT 1);
SET @cq1b := (SELECT id FROM mcq_options WHERE question_id = @cq1 AND option_key = 'B' LIMIT 1);

INSERT INTO `mcq_options_translations` (`mcq_option_id`, `language_id`, `option_text`)
SELECT t.oid, l.id, CASE WHEN l.code = 'en' THEN t.text_en ELSE t.text_ar END
FROM (
  SELECT @cq1a AS oid, 'الوحدة الأولى — الجبر والمتباينات' AS text_ar, 'Unit 1 - Algebra and Inequalities' AS text_en
  UNION ALL SELECT @cq1b, 'الوحدة الثانية — الدوال المثلثية', 'Unit 2 - Trigonometric Functions'
) t
CROSS JOIN `languages` l
WHERE l.is_active = 1 AND t.oid IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT mcq_option_id, language_id FROM mcq_options_translations) x WHERE x.mcq_option_id = t.oid AND x.language_id = l.id);

INSERT INTO `questions` (`exam_id`, `course_id`, `subject_id`, `question_type`, `order_num`, `score`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @course_exam_id, @course_id, @subject_id, 'true_false', 2, 1.00, 1, 'admin', @admin_id FROM DUAL
WHERE @course_exam_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM questions WHERE exam_id = @course_exam_id AND order_num = 2) x);
SET @cq2 := (SELECT id FROM questions WHERE exam_id = @course_exam_id AND order_num = 2 LIMIT 1);

INSERT INTO `questions_translations` (`question_id`, `language_id`, `question_text`)
SELECT @cq2, l.id, CASE WHEN l.code = 'en' THEN 'This course has exactly two units.' ELSE 'هذا الكورس يتكوّن من وحدتين بالضبط.' END
FROM `languages` l WHERE l.is_active = 1 AND @cq2 IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT question_id, language_id FROM questions_translations) x WHERE x.question_id = @cq2 AND x.language_id = l.id);

INSERT INTO `true_false_answers` (`question_id`, `correct_answer`, `is_active`)
SELECT @cq2, 1, 1 FROM DUAL
WHERE @cq2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT question_id FROM true_false_answers) x WHERE x.question_id = @cq2);


-- ─── ١٣. امتحان على الباقة كاملة (unit_id فاضي أيضًا — الباقة لا وحدات لها) ───
INSERT INTO `course_exams`
    (`subject_id`, `course_id`, `unit_id`, `order_num`, `duration_minutes`, `total_marks`, `pass_marks`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @subject_id, @package_id, NULL, 1, 20, 2, 1, 1, 'admin', @admin_id
FROM DUAL
WHERE @package_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM course_exams WHERE course_id = @package_id AND unit_id IS NULL) x);

SET @package_exam_id := (SELECT id FROM course_exams WHERE course_id = @package_id AND unit_id IS NULL LIMIT 1);

INSERT INTO `course_exams_translations` (`exam_id`, `language_id`, `title`, `description`)
SELECT @package_exam_id, l.id,
       CASE WHEN l.code = 'en' THEN 'Package Exam' ELSE 'امتحان الباقة' END,
       CASE WHEN l.code = 'en' THEN 'For every student subscribed to this package.' ELSE 'لكل طالب مشترك في هذه الباقة.' END
FROM `languages` l
WHERE l.is_active = 1 AND @package_exam_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT exam_id, language_id FROM course_exams_translations) x WHERE x.exam_id = @package_exam_id AND x.language_id = l.id);

INSERT INTO `questions` (`exam_id`, `course_id`, `subject_id`, `question_type`, `order_num`, `score`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @package_exam_id, @package_id, @subject_id, 'mcq', 1, 1.00, 1, 'admin', @admin_id FROM DUAL
WHERE @package_exam_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM questions WHERE exam_id = @package_exam_id AND order_num = 1) x);
SET @pq1 := (SELECT id FROM questions WHERE exam_id = @package_exam_id AND order_num = 1 LIMIT 1);

INSERT INTO `questions_translations` (`question_id`, `language_id`, `question_text`)
SELECT @pq1, l.id, CASE WHEN l.code = 'en' THEN 'A package appointment is booked through:' ELSE 'يُحجز موعد الباقة عبر:' END
FROM `languages` l WHERE l.is_active = 1 AND @pq1 IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT question_id, language_id FROM questions_translations) x WHERE x.question_id = @pq1 AND x.language_id = l.id);

INSERT INTO `mcq_options` (`question_id`, `option_key`, `is_correct`, `is_active`)
SELECT @pq1, o.okey, o.correct, 1 FROM (SELECT 'A' AS okey, 1 AS correct UNION ALL SELECT 'B', 0) o
WHERE @pq1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT question_id, option_key FROM mcq_options) x WHERE x.question_id = @pq1 AND x.option_key = o.okey);

SET @pq1a := (SELECT id FROM mcq_options WHERE question_id = @pq1 AND option_key = 'A' LIMIT 1);
SET @pq1b := (SELECT id FROM mcq_options WHERE question_id = @pq1 AND option_key = 'B' LIMIT 1);

INSERT INTO `mcq_options_translations` (`mcq_option_id`, `language_id`, `option_text`)
SELECT t.oid, l.id, CASE WHEN l.code = 'en' THEN t.text_en ELSE t.text_ar END
FROM (
  SELECT @pq1a AS oid, 'موعد فردي (teacher_availability_slots)' AS text_ar, 'An individual appointment (teacher_availability_slots)' AS text_en
  UNION ALL SELECT @pq1b, 'حصّة أسبوعية ثابتة (class_sessions)', 'A fixed weekly class (class_sessions)'
) t
CROSS JOIN `languages` l
WHERE l.is_active = 1 AND t.oid IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT mcq_option_id, language_id FROM mcq_options_translations) x WHERE x.mcq_option_id = t.oid AND x.language_id = l.id);

INSERT INTO `questions` (`exam_id`, `course_id`, `subject_id`, `question_type`, `order_num`, `score`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @package_exam_id, @package_id, @subject_id, 'true_false', 2, 1.00, 1, 'admin', @admin_id FROM DUAL
WHERE @package_exam_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM questions WHERE exam_id = @package_exam_id AND order_num = 2) x);
SET @pq2 := (SELECT id FROM questions WHERE exam_id = @package_exam_id AND order_num = 2 LIMIT 1);

INSERT INTO `questions_translations` (`question_id`, `language_id`, `question_text`)
SELECT @pq2, l.id, CASE WHEN l.code = 'en' THEN 'This package has a fixed one-month duration in this demo.' ELSE 'مدّة هذه الباقة التجريبية شهر واحد ثابت.' END
FROM `languages` l WHERE l.is_active = 1 AND @pq2 IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT question_id, language_id FROM questions_translations) x WHERE x.question_id = @pq2 AND x.language_id = l.id);

INSERT INTO `true_false_answers` (`question_id`, `correct_answer`, `is_active`)
SELECT @pq2, 1, 1 FROM DUAL
WHERE @pq2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM (SELECT question_id FROM true_false_answers) x WHERE x.question_id = @pq2);


-- ─── ١٤. التحقّق ───────────────────────────────────────────────────────────────
SELECT 'بيانات الدخول' AS what, @student_email AS v1, '12345678' AS v2
UNION ALL SELECT 'course_id (كورس عادي)', @course_id, NULL
UNION ALL SELECT 'package_id (باقة)', @package_id, NULL
UNION ALL SELECT 'عدد الوحدات', (SELECT COUNT(*) FROM units WHERE course_id = @course_id), NULL
UNION ALL SELECT 'عدد الفيديوهات', (SELECT COUNT(*) FROM videos v JOIN units u ON v.unit_id = u.id WHERE u.course_id = @course_id), NULL
UNION ALL SELECT 'عدد الكتب', (SELECT COUNT(*) FROM course_books WHERE course_id = @course_id AND category = 'summary'), NULL
UNION ALL SELECT 'عدد أسئلة اختبار الوحدة', (SELECT COUNT(*) FROM questions WHERE exam_id = @exam_id), NULL
UNION ALL SELECT 'exam_id (امتحان الكورس كاملًا)', @course_exam_id, NULL
UNION ALL SELECT 'عدد أسئلة امتحان الكورس كاملًا', (SELECT COUNT(*) FROM questions WHERE exam_id = @course_exam_id), NULL
UNION ALL SELECT 'exam_id (امتحان الباقة)', @package_exam_id, NULL
UNION ALL SELECT 'عدد أسئلة امتحان الباقة', (SELECT COUNT(*) FROM questions WHERE exam_id = @package_exam_id), NULL
UNION ALL SELECT 'الاشتراك فعّال؟', (SELECT is_active FROM student_subscriptions WHERE id = @sub_id), NULL
UNION ALL SELECT 'الكورس العادي مربوط بالاشتراك؟', (SELECT COUNT(*) FROM student_subscription_courses WHERE student_subscription_id = @sub_id AND course_id = @course_id), NULL
UNION ALL SELECT 'الباقة مربوطة بالاشتراك؟', (SELECT COUNT(*) FROM student_subscription_courses WHERE student_subscription_id = @sub_id AND course_id = @package_id), NULL
UNION ALL SELECT 'حصّة اليوم (يوم/بداية/نهاية)', (SELECT CONCAT(day_of_week, ' ', start_time, '-', end_time) FROM class_sessions WHERE course_id = @course_id AND code = 'full-demo-session'), NULL
UNION ALL SELECT 'الاستشارة (تاريخ/وقت/حالة)', (SELECT CONCAT(slot_date, ' ', slot_time, ' - ', status) FROM consultation_slots WHERE id = @consult_id), NULL
UNION ALL SELECT 'موعد الباقة (تاريخ/وقت/حالة الحجز)', (SELECT CONCAT(s.slot_date, ' ', s.start_time, '-', s.end_time, ' - ', b.status) FROM teacher_availability_slots s JOIN availability_slot_bookings b ON b.slot_id = s.id WHERE s.id = @avail_slot_id AND b.student_id = @student_id), NULL;
