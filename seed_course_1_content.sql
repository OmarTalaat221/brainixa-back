-- ============================================================================
--  ⚠️  هذا الملفّ فيه خطأ. شغِّل بعده fix_course_1_content.sql
--
--  الأقسام ٣ و٤ تكتب الدروس في جدول `course_videos`، والمنصّة تقرأ من `videos`.
--  فالوحدات والاختبار أُنشئت صحيحة، والدروس ذهبت إلى جدول لا تعرضه أي شاشة.
--  ملفّ التصحيح يسحب تلك الصفوف ويكتب الدروس في مكانها، ويضيف الملخّصات.
--
--  تُرك الملفّ كما هو عمدًا: هو سجلّ ما شُغِّل فعلًا على قاعدة البيانات.
-- ============================================================================

-- ============================================================================
--  محتوى حقيقي لكورس «رياضيات — الصف الثاني الثانوي» (course_id = 1)
--
--  ثلاث وحدات · ثمانية دروس · اختبار بثلاثة أسئلة مصحَّحة آليًّا.
--
--  التشغيل:
--    mysql -u campcod1_brain-ixa -p campcod1_brain-ixa < seed_course_1_content.sql
--  أو الصق المحتوى في phpMyAdmin.
--
--  آمن للتشغيل مرّتين: كل إدراج محميّ بـ NOT EXISTS، فإعادة التشغيل لا تُكرّر شيئًا.
-- ============================================================================
--
--  ─── عن الفيديو ───────────────────────────────────────────────────────────
--
--  الدروس الثمانية كلّها تشير إلى مقطع تجريبي واحد مرفوع على خادمكم، مكتوب
--  عليه «فيديو تجريبي — محتوى للعرض فقط». اختير هذا بدل مقطع من موقع اختبار
--  خارجي لأن الروابط الخارجية تسقط، ولأن المقطع يقول عن نفسه ما هو فلا يظنّه
--  أحد درسًا حقيقيًّا.
--
--  ⚠️  لا يوجد «فيديو باني تجريبي» يمكن إعطاؤه. فيديوهات Bunny Stream تعيش في
--      مكتبة مرتبطة بحسابكم، ولا توجد مكتبة عامّة. والمعرّفات الثلاثة المذكورة
--      في توثيق Bunny أمثلة لا فيديوهات: جرّبتها فكلّها تردّ صفحة خطأ.
--
--      حين تُنشئون مكتبة على Bunny، استبدلوا سطر @video_url وحده بالصيغة:
--        https://iframe.mediadelivery.net/embed/{library_id}/{video_guid}
--      والباك يتعرّف عليها ويخزّنها بصيغة التضمين تلقائيًّا
--      (helpers/video_source.php). ولا شيء آخر في هذا الملفّ يحتاج تغييرًا.
-- ============================================================================


-- ─── ٠. الهدف وما يُورَث منه ────────────────────────────────────────────────
SET @course_id := 1;
SET @video_url := 'https://camp-coding.online/brain-ixa/uploads/videos/vid_6ad4b3273623f8.23283842.mp4';

-- المادة والمعلّم يُؤخذان من الكورس نفسه، فلا رقم مثبَّت في هذا الملفّ.
SET @subject_id := (SELECT subject_id FROM courses WHERE id = @course_id);
SET @admin_id   := (SELECT MIN(id) FROM admins);
SET @lang_ar    := (SELECT id FROM languages WHERE code = 'ar' LIMIT 1);
SET @lang_en    := (SELECT id FROM languages WHERE code = 'en' LIMIT 1);

SELECT @course_id AS course_id,
       (SELECT name FROM courses_translations WHERE course_id = @course_id AND language_id = @lang_ar LIMIT 1) AS course_name,
       @subject_id AS subject_id;


-- ─── ١. الوحدات ─────────────────────────────────────────────────────────────
-- `code` هو ما يُميّز الوحدة عند إعادة التشغيل، ولذلك اختير فريدًا ومقروءًا.

INSERT INTO `units` (`course_id`, `subject_id`, `code`, `order_num`, `lessons_count`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @course_id, @subject_id, 'g11-math-algebra', 1, 3, 1, 'admin', @admin_id FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM units WHERE course_id = @course_id AND code = 'g11-math-algebra') x);

INSERT INTO `units` (`course_id`, `subject_id`, `code`, `order_num`, `lessons_count`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @course_id, @subject_id, 'g11-math-trig', 2, 3, 1, 'admin', @admin_id FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM units WHERE course_id = @course_id AND code = 'g11-math-trig') x);

INSERT INTO `units` (`course_id`, `subject_id`, `code`, `order_num`, `lessons_count`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @course_id, @subject_id, 'g11-math-calculus', 3, 2, 1, 'admin', @admin_id FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM units WHERE course_id = @course_id AND code = 'g11-math-calculus') x);

SET @u1 := (SELECT id FROM units WHERE course_id = @course_id AND code = 'g11-math-algebra'  LIMIT 1);
SET @u2 := (SELECT id FROM units WHERE course_id = @course_id AND code = 'g11-math-trig'     LIMIT 1);
SET @u3 := (SELECT id FROM units WHERE course_id = @course_id AND code = 'g11-math-calculus' LIMIT 1);


-- ─── ٢. أسماء الوحدات بكل لغة مفعّلة ────────────────────────────────────────
-- الاسم يعيش في جدول ترجمة لا في صفّ الوحدة. ولغة ناقصة تعني وحدة بلا اسم
-- لمن يتصفّح بتلك اللغة، فتُكتب كل اللغات المفعّلة دفعةً واحدة.

INSERT INTO `units_translations` (`unit_id`, `language_id`, `name`, `description`, `is_active`)
SELECT u.unit_id, l.id,
       CASE WHEN l.code = 'en' THEN u.name_en ELSE u.name_ar END,
       CASE WHEN l.code = 'en' THEN u.desc_en ELSE u.desc_ar END,
       1
FROM (
  SELECT @u1 AS unit_id,
         'الوحدة الأولى: الجبر والمتباينات' AS name_ar, 'Unit 1: Algebra and Inequalities' AS name_en,
         'المعادلات التربيعية وطرق حلّها، المميز وطبيعة الجذور، والمتباينات التربيعية.' AS desc_ar,
         'Quadratic equations and how to solve them, the discriminant, and quadratic inequalities.' AS desc_en
  UNION ALL SELECT @u2,
         'الوحدة الثانية: حساب المثلثات', 'Unit 2: Trigonometry',
         'الدوال المثلثية، قانونا الجيب وجيب التمام، والمتطابقات الأساسية.',
         'Trigonometric functions, the sine and cosine rules, and the basic identities.'
  UNION ALL SELECT @u3,
         'الوحدة الثالثة: مقدمة في التفاضل', 'Unit 3: Introduction to Calculus',
         'النهايات والاتصال، ثم المشتقة الأولى وقواعد الاشتقاق.',
         'Limits and continuity, then the first derivative and the rules of differentiation.'
) u
CROSS JOIN `languages` l
WHERE l.is_active = 1 AND u.unit_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM (SELECT unit_id, language_id FROM units_translations) t
    WHERE t.unit_id = u.unit_id AND t.language_id = l.id
  );


-- ─── ٣. الدروس ──────────────────────────────────────────────────────────────
-- لا عمود يُميّز الفيديو غير ترتيبه داخل وحدته، فالحماية من التكرار تقوم على
-- الزوج (unit_id, order_num).

INSERT INTO `course_videos` (`subject_id`, `course_id`, `unit_id`, `duration`, `video_url`, `order_num`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @subject_id, @course_id, v.unit_id, v.duration, @video_url, v.order_num, 1, 'admin', @admin_id
FROM (
  SELECT @u1 AS unit_id, 1 AS order_num, '14:20' AS duration UNION ALL
  SELECT @u1, 2, '18:05' UNION ALL
  SELECT @u1, 3, '12:40' UNION ALL
  SELECT @u2, 1, '16:10' UNION ALL
  SELECT @u2, 2, '21:35' UNION ALL
  SELECT @u2, 3, '15:50' UNION ALL
  SELECT @u3, 1, '19:25' UNION ALL
  SELECT @u3, 2, '23:15'
) v
WHERE v.unit_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM (SELECT unit_id, order_num FROM course_videos) c
    WHERE c.unit_id = v.unit_id AND c.order_num = v.order_num
  );


-- ─── ٤. عناوين الدروس ───────────────────────────────────────────────────────
INSERT INTO `course_videos_translations` (`video_id`, `language_id`, `title`, `description`)
SELECT cv.id, l.id,
       CASE WHEN l.code = 'en' THEN t.title_en ELSE t.title_ar END,
       CASE WHEN l.code = 'en' THEN t.desc_en  ELSE t.desc_ar  END
FROM (
  SELECT @u1 AS unit_id, 1 AS order_num,
         'المعادلات التربيعية — الحل بالتحليل' AS title_ar, 'Quadratic equations - solving by factorisation' AS title_en,
         'تحليل الحد الثلاثي إلى عاملين، ومتى يصلح التحليل ومتى لا يصلح.' AS desc_ar,
         'Factorising a trinomial, and when factorisation works and when it does not.' AS desc_en
  UNION ALL SELECT @u1, 2, 'المميز وطبيعة الجذور', 'The discriminant and the nature of the roots',
         'قيمة المميز وماذا تقول عن عدد الجذور الحقيقية قبل حلّ المعادلة.',
         'What the discriminant says about the number of real roots before solving.'
  UNION ALL SELECT @u1, 3, 'المتباينات التربيعية', 'Quadratic inequalities',
         'حل المتباينة بيانيًّا وبجدول الإشارة.',
         'Solving an inequality graphically and with a sign table.'
  UNION ALL SELECT @u2, 1, 'الدوال المثلثية في المثلث القائم', 'Trigonometric functions in a right triangle',
         'الجيب وجيب التمام والظل، وعلاقة كلٍّ منها بأضلاع المثلث.',
         'Sine, cosine and tangent, and how each relates to the triangle sides.'
  UNION ALL SELECT @u2, 2, 'قانون الجيب وقانون جيب التمام', 'The sine rule and the cosine rule',
         'متى يُستعمل كل قانون، مع أمثلة على المثلث غير القائم.',
         'When to use each rule, with worked examples on a non-right triangle.'
  UNION ALL SELECT @u2, 3, 'المتطابقات المثلثية الأساسية', 'The basic trigonometric identities',
         'المتطابقة الفيثاغورية ومتطابقات الزاوية المزدوجة.',
         'The Pythagorean identity and the double-angle identities.'
  UNION ALL SELECT @u3, 1, 'النهايات ومفهوم الاتصال', 'Limits and continuity',
         'معنى النهاية، وشروط اتصال الدالة عند نقطة.',
         'What a limit means, and the conditions for a function to be continuous at a point.'
  UNION ALL SELECT @u3, 2, 'المشتقة الأولى وقواعد الاشتقاق', 'The first derivative and the rules of differentiation',
         'تعريف المشتقة، وقاعدة القوة وقاعدتا الضرب والقسمة.',
         'The definition of the derivative, the power rule, and the product and quotient rules.'
) t
JOIN `course_videos` cv ON cv.unit_id = t.unit_id AND cv.order_num = t.order_num
CROSS JOIN `languages` l
WHERE l.is_active = 1
  AND NOT EXISTS (
    SELECT 1 FROM (SELECT video_id, language_id FROM course_videos_translations) x
    WHERE x.video_id = cv.id AND x.language_id = l.id
  );


-- ─── ٥. اختبار الوحدة الأولى ────────────────────────────────────────────────
INSERT INTO `course_exams` (`subject_id`, `course_id`, `unit_id`, `order_num`, `duration_minutes`, `total_marks`, `pass_marks`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @subject_id, @course_id, @u1, 1, 20, 3, 2, 1, 'admin', @admin_id FROM DUAL
WHERE @u1 IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM course_exams WHERE course_id = @course_id AND unit_id = @u1) x);

SET @exam_id := (SELECT id FROM course_exams WHERE course_id = @course_id AND unit_id = @u1 ORDER BY id LIMIT 1);

INSERT INTO `course_exams_translations` (`exam_id`, `language_id`, `title`, `description`)
SELECT @exam_id, l.id,
       CASE WHEN l.code = 'en' THEN 'Unit 1 quiz - Algebra and Inequalities' ELSE 'اختبار الوحدة الأولى — الجبر والمتباينات' END,
       CASE WHEN l.code = 'en' THEN 'Three questions, twenty minutes. Two correct answers to pass.' ELSE 'ثلاثة أسئلة في عشرين دقيقة. النجاح بإجابتين صحيحتين.' END
FROM `languages` l
WHERE l.is_active = 1 AND @exam_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM (SELECT exam_id, language_id FROM course_exams_translations) t
    WHERE t.exam_id = @exam_id AND t.language_id = l.id
  );


-- ─── ٦. الأسئلة ─────────────────────────────────────────────────────────────
INSERT INTO `questions` (`exam_id`, `course_id`, `unit_id`, `subject_id`, `question_type`, `order_num`, `score`, `is_active`, `created_by_type`, `created_by_id`)
SELECT @exam_id, @course_id, @u1, @subject_id, q.qtype, q.order_num, 1.00, 1, 'admin', @admin_id
FROM (
  SELECT 'mcq' AS qtype, 1 AS order_num UNION ALL
  SELECT 'mcq', 2 UNION ALL
  SELECT 'true_false', 3
) q
WHERE @exam_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM (SELECT exam_id, order_num FROM questions) x
    WHERE x.exam_id = @exam_id AND x.order_num = q.order_num
  );

SET @q1 := (SELECT id FROM questions WHERE exam_id = @exam_id AND order_num = 1 LIMIT 1);
SET @q2 := (SELECT id FROM questions WHERE exam_id = @exam_id AND order_num = 2 LIMIT 1);
SET @q3 := (SELECT id FROM questions WHERE exam_id = @exam_id AND order_num = 3 LIMIT 1);

INSERT INTO `questions_translations` (`question_id`, `language_id`, `question_text`, `is_active`)
SELECT t.qid, l.id, CASE WHEN l.code = 'en' THEN t.text_en ELSE t.text_ar END, 1
FROM (
  SELECT @q1 AS qid,
         'ما مجموعة حلّ المعادلة: س² − ٥س + ٦ = ٠ ؟' AS text_ar,
         'What is the solution set of x² - 5x + 6 = 0 ?' AS text_en
  UNION ALL SELECT @q2,
         'إذا كان مميز المعادلة التربيعية أصغر من الصفر، فإن للمعادلة:',
         'If the discriminant of a quadratic is negative, the equation has:'
  UNION ALL SELECT @q3,
         'مجموع جذري المعادلة أ س² + ب س + جـ = ٠ يساوي (−ب ÷ أ).',
         'The sum of the roots of ax² + bx + c = 0 equals (-b / a).'
) t
CROSS JOIN `languages` l
WHERE l.is_active = 1 AND t.qid IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM (SELECT question_id, language_id FROM questions_translations) x
    WHERE x.question_id = t.qid AND x.language_id = l.id
  );


-- ─── ٧. خيارات الأسئلة من نوع الاختيار من متعدد ─────────────────────────────
INSERT INTO `mcq_options` (`question_id`, `option_key`, `is_correct`, `is_active`)
SELECT o.qid, o.okey, o.correct, 1
FROM (
  SELECT @q1 AS qid, 'A' AS okey, 1 AS correct UNION ALL
  SELECT @q1, 'B', 0 UNION ALL
  SELECT @q1, 'C', 0 UNION ALL
  SELECT @q1, 'D', 0 UNION ALL
  SELECT @q2, 'A', 0 UNION ALL
  SELECT @q2, 'B', 0 UNION ALL
  SELECT @q2, 'C', 1 UNION ALL
  SELECT @q2, 'D', 0
) o
WHERE o.qid IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM (SELECT question_id, option_key FROM mcq_options) x
    WHERE x.question_id = o.qid AND x.option_key = o.okey
  );

INSERT INTO `mcq_options_translations` (`mcq_option_id`, `language_id`, `option_text`, `is_active`)
SELECT mo.id, l.id, CASE WHEN l.code = 'en' THEN t.text_en ELSE t.text_ar END, 1
FROM (
  SELECT @q1 AS qid, 'A' AS okey, '{ ٢ ، ٣ }'            AS text_ar, '{ 2, 3 }' AS text_en UNION ALL
  SELECT @q1, 'B', '{ ١ ، ٦ }',                 '{ 1, 6 }' UNION ALL
  SELECT @q1, 'C', '{ −٢ ، −٣ }',               '{ -2, -3 }' UNION ALL
  SELECT @q1, 'D', 'لا يوجد حل حقيقي',           'No real solution' UNION ALL
  SELECT @q2, 'A', 'جذران حقيقيان مختلفان',      'Two distinct real roots' UNION ALL
  SELECT @q2, 'B', 'جذر حقيقي واحد مكرّر',        'One repeated real root' UNION ALL
  SELECT @q2, 'C', 'لا جذور حقيقية',             'No real roots' UNION ALL
  SELECT @q2, 'D', 'ثلاثة جذور حقيقية',          'Three real roots'
) t
JOIN `mcq_options` mo ON mo.question_id = t.qid AND mo.option_key = t.okey
CROSS JOIN `languages` l
WHERE l.is_active = 1
  AND NOT EXISTS (
    SELECT 1 FROM (SELECT mcq_option_id, language_id FROM mcq_options_translations) x
    WHERE x.mcq_option_id = mo.id AND x.language_id = l.id
  );


-- ─── ٨. إجابة سؤال الصواب والخطأ ────────────────────────────────────────────
INSERT INTO `true_false_answers` (`question_id`, `correct_answer`, `is_active`)
SELECT @q3, 1, 1 FROM DUAL
WHERE @q3 IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT question_id FROM true_false_answers) x WHERE x.question_id = @q3);


-- ─── ٩. العدّادات ───────────────────────────────────────────────────────────
-- عدد الدروس مخزَّن على الوحدة وعلى الكورس، ولا يُحسب عند العرض. فلو تُرك على
-- صفره ظهر الكورس فارغًا في القوائم رغم امتلائه.

UPDATE `units` u
   SET u.lessons_count = (SELECT COUNT(*) FROM course_videos cv WHERE cv.unit_id = u.id AND cv.is_active = 1)
 WHERE u.course_id = @course_id;

UPDATE `courses` c
   SET c.lessons_count = (SELECT COUNT(*) FROM course_videos cv WHERE cv.course_id = @course_id AND cv.is_active = 1)
 WHERE c.id = @course_id;


-- ─── ١٠. التحقّق ────────────────────────────────────────────────────────────
SELECT
  (SELECT COUNT(*) FROM units          WHERE course_id = @course_id) AS units,
  (SELECT COUNT(*) FROM course_videos  WHERE course_id = @course_id) AS lessons,
  (SELECT COUNT(*) FROM course_exams   WHERE course_id = @course_id) AS exams,
  (SELECT COUNT(*) FROM questions      WHERE course_id = @course_id) AS questions,
  (SELECT COUNT(*) FROM mcq_options mo JOIN questions q ON q.id = mo.question_id WHERE q.course_id = @course_id) AS mcq_options,
  (SELECT lessons_count FROM courses   WHERE id = @course_id)        AS course_lessons_count;
