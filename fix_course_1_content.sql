-- ============================================================================
--  تصحيح محتوى كورس «رياضيات — الصف الثاني الثانوي» (course_id = 1)
--
--  يُشغَّل بعد seed_course_1_content.sql ويُصحّح خطأً فيه.
--
--  التشغيل:
--    mysql -u campcod1_brain-ixa -p campcod1_brain-ixa < fix_course_1_content.sql
--
--  آمن للتشغيل مرّتين.
-- ============================================================================
--
--  ─── ما الذي كان خطأً ─────────────────────────────────────────────────────
--
--  في قاعدة البيانات جدولان للفيديو: `videos` و`course_videos`. كتب السكربت
--  السابق الدروس في `course_videos`، والمنصّة كلّها — لوحة الأدمن ولوحة المعلّم
--  وتطبيق الطالب — تقرأ من `videos`. فظهرت الوحدات الثلاث وبقيت فارغة.
--
--  و`course_videos` ليس جدولًا ميتًا تمامًا، وهذا ما يجعل تركه خطرًا: تطبيق
--  الطالب يرجع إليه حين لا يجد في `videos` شيئًا (app/user/student/content/
--  units.php)، كما يضمّه بـ LEFT JOIN على **المعرّف** في videos.php — فصفٌّ
--  هناك يحمل معرّفًا يصادف معرّف فيديو حقيقي يسرّب عنوانه إليه. لذلك تُحذف
--  صفوف السكربت السابق، لا تُترك نائمة.
--
--  الفروق بين الجدولين ليست في الاسم وحده:
--    · `videos.code`            مطلوب، وفريد مع الوحدة
--    · `videos.duration_seconds` عدد ثوانٍ، لا نصّ مثل "14:20"
--    · `videos.publish_status`   يبدأ 'draft'، فلا يُعرض حتى يصير 'published'
--    · `videos_translations.name` اسم العمود، لا `title`
--
--  ويضيف هذا الملفّ أيضًا ما لم يكن في السابق: ملخّص PDF لكل وحدة.
-- ============================================================================


-- ─── ٠. الهدف ───────────────────────────────────────────────────────────────
SET @course_id := 1;
SET @video_url := 'https://camp-coding.online/brain-ixa/uploads/videos/vid_6ad4b3273623f8.23283842.mp4';

SET @subject_id := (SELECT subject_id FROM courses WHERE id = @course_id);
SET @admin_id   := (SELECT MIN(id) FROM admins);

SET @u1 := (SELECT id FROM units WHERE course_id = @course_id AND code = 'g11-math-algebra'  LIMIT 1);
SET @u2 := (SELECT id FROM units WHERE course_id = @course_id AND code = 'g11-math-trig'     LIMIT 1);
SET @u3 := (SELECT id FROM units WHERE course_id = @course_id AND code = 'g11-math-calculus' LIMIT 1);

SELECT @u1 AS unit_1, @u2 AS unit_2, @u3 AS unit_3;


-- ─── ١. سحب ما كُتب في الجدول الخطأ ─────────────────────────────────────────
-- يُطابَق بعنوان الفيديو لا بالوحدة، حتى لا يُمسّ صفٌّ قديم لا علاقة له بنا.

DELETE cvt FROM course_videos_translations cvt
  JOIN course_videos cv ON cv.id = cvt.video_id
 WHERE cv.course_id = @course_id AND cv.video_url = @video_url;

DELETE FROM course_videos
 WHERE course_id = @course_id AND video_url = @video_url;


-- ─── ٢. الدروس في الجدول الصحيح ─────────────────────────────────────────────
-- `code` فريد داخل الوحدة، فهو ما يمنع التكرار عند إعادة التشغيل.
-- و`publish_status = 'published'` ضروري: الافتراضي 'draft' لا يظهر لأحد.

INSERT INTO `videos` (`unit_id`, `order_num`, `code`, `video_url`, `duration_seconds`, `publish_status`, `is_active`)
SELECT v.unit_id, v.order_num, v.code, @video_url, v.secs, 'published', 1
FROM (
  SELECT @u1 AS unit_id, 1 AS order_num, 'alg-01'  AS code,  860 AS secs UNION ALL
  SELECT @u1, 2, 'alg-02', 1085 UNION ALL
  SELECT @u1, 3, 'alg-03',  760 UNION ALL
  SELECT @u2, 1, 'trg-01',  970 UNION ALL
  SELECT @u2, 2, 'trg-02', 1295 UNION ALL
  SELECT @u2, 3, 'trg-03',  950 UNION ALL
  SELECT @u3, 1, 'clc-01', 1165 UNION ALL
  SELECT @u3, 2, 'clc-02', 1395
) v
WHERE v.unit_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM (SELECT unit_id, code FROM videos) x
    WHERE x.unit_id = v.unit_id AND x.code = v.code
  );


-- ─── ٣. أسماء الدروس ────────────────────────────────────────────────────────
-- العمود اسمه `name` هنا، بخلاف `title` في جدول الترجمة المهجور.

INSERT INTO `videos_translations` (`video_id`, `language_id`, `name`, `description`, `is_active`)
SELECT vd.id, l.id,
       CASE WHEN l.code = 'en' THEN t.name_en ELSE t.name_ar END,
       CASE WHEN l.code = 'en' THEN t.desc_en ELSE t.desc_ar END,
       1
FROM (
  SELECT @u1 AS unit_id, 'alg-01' AS vcode,
         'المعادلات التربيعية — الحل بالتحليل' AS name_ar, 'Quadratic equations - solving by factorisation' AS name_en,
         'تحليل الحد الثلاثي إلى عاملين، ومتى يصلح التحليل ومتى لا يصلح.' AS desc_ar,
         'Factorising a trinomial, and when factorisation works and when it does not.' AS desc_en
  UNION ALL SELECT @u1, 'alg-02', 'المميز وطبيعة الجذور', 'The discriminant and the nature of the roots',
         'قيمة المميز وماذا تقول عن عدد الجذور الحقيقية قبل حلّ المعادلة.',
         'What the discriminant says about the number of real roots before solving.'
  UNION ALL SELECT @u1, 'alg-03', 'المتباينات التربيعية', 'Quadratic inequalities',
         'حل المتباينة بيانيًّا وبجدول الإشارة.',
         'Solving an inequality graphically and with a sign table.'
  UNION ALL SELECT @u2, 'trg-01', 'الدوال المثلثية في المثلث القائم', 'Trigonometric functions in a right triangle',
         'الجيب وجيب التمام والظل، وعلاقة كلٍّ منها بأضلاع المثلث.',
         'Sine, cosine and tangent, and how each relates to the triangle sides.'
  UNION ALL SELECT @u2, 'trg-02', 'قانون الجيب وقانون جيب التمام', 'The sine rule and the cosine rule',
         'متى يُستعمل كل قانون، مع أمثلة على المثلث غير القائم.',
         'When to use each rule, with worked examples on a non-right triangle.'
  UNION ALL SELECT @u2, 'trg-03', 'المتطابقات المثلثية الأساسية', 'The basic trigonometric identities',
         'المتطابقة الفيثاغورية ومتطابقات الزاوية المزدوجة.',
         'The Pythagorean identity and the double-angle identities.'
  UNION ALL SELECT @u3, 'clc-01', 'النهايات ومفهوم الاتصال', 'Limits and continuity',
         'معنى النهاية، وشروط اتصال الدالة عند نقطة.',
         'What a limit means, and the conditions for a function to be continuous at a point.'
  UNION ALL SELECT @u3, 'clc-02', 'المشتقة الأولى وقواعد الاشتقاق', 'The first derivative and the rules of differentiation',
         'تعريف المشتقة، وقاعدة القوة وقاعدتا الضرب والقسمة.',
         'The definition of the derivative, the power rule, and the product and quotient rules.'
) t
JOIN `videos` vd ON vd.unit_id = t.unit_id AND vd.code = t.vcode
CROSS JOIN `languages` l
WHERE l.is_active = 1
  AND NOT EXISTS (
    SELECT 1 FROM (SELECT video_id, language_id FROM videos_translations) x
    WHERE x.video_id = vd.id AND x.language_id = l.id
  );


-- ─── ٤. ملخّص PDF لكل وحدة ──────────────────────────────────────────────────
-- `category = 'summary'` هو ما يجعله «ملخّصًا» لا «اختبارًا» في الواجهة.
-- و`cover_image` مطلوب بلا قيمة افتراضية، فيُكتب فارغًا صراحةً.
-- والطالب يقرأ `file_path` ويرجع إلى `link` عند خلوّه، فيكفي ملء الأول.

INSERT INTO `course_books`
  (`subject_id`, `course_id`, `unit_id`, `file_type`, `category`, `extension`,
   `link`, `file_path`, `cover_image`, `price`, `allow_download`, `order_num`,
   `is_active`, `show_on_website`, `created_by_type`, `created_by_id`)
SELECT @subject_id, @course_id, b.unit_id, 'pdf', 'summary', 'pdf',
       '', b.url, '', 0, 1, 1, 1, 1, 'admin', @admin_id
FROM (
  SELECT @u1 AS unit_id, 'https://camp-coding.online/brain-ixa/uploads/documents/doc_6ad4b694517e71.96169744.pdf' AS url UNION ALL
  SELECT @u2, 'https://camp-coding.online/brain-ixa/uploads/documents/doc_6ad4b695090043.74079801.pdf' UNION ALL
  SELECT @u3, 'https://camp-coding.online/brain-ixa/uploads/documents/doc_6ad4b695ba6569.16172135.pdf'
) b
WHERE b.unit_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM (SELECT unit_id, file_path FROM course_books) x
    WHERE x.unit_id = b.unit_id AND x.file_path = b.url
  );

INSERT INTO `course_books_translations` (`book_id`, `language_id`, `title`, `description`)
SELECT cb.id, l.id,
       CASE WHEN l.code = 'en' THEN t.title_en ELSE t.title_ar END,
       CASE WHEN l.code = 'en' THEN t.desc_en  ELSE t.desc_ar  END
FROM (
  SELECT @u1 AS unit_id,
         'ملخّص الوحدة الأولى — الجبر والمتباينات' AS title_ar, 'Unit 1 summary - Algebra and Inequalities' AS title_en,
         'المعادلة التربيعية، المميز وطبيعة الجذور، والمتباينات التربيعية في صفحة واحدة.' AS desc_ar,
         'The quadratic equation, the discriminant, and quadratic inequalities on one page.' AS desc_en
  UNION ALL SELECT @u2,
         'ملخّص الوحدة الثانية — حساب المثلثات', 'Unit 2 summary - Trigonometry',
         'الدوال المثلثية، قانونا الجيب وجيب التمام، والمتطابقات الأساسية.',
         'Trigonometric functions, the sine and cosine rules, and the basic identities.'
  UNION ALL SELECT @u3,
         'ملخّص الوحدة الثالثة — مقدمة في التفاضل', 'Unit 3 summary - Introduction to Calculus',
         'النهايات والاتصال، والمشتقة الأولى وقواعد الاشتقاق.',
         'Limits and continuity, and the first derivative with its rules.'
) t
JOIN `course_books` cb ON cb.unit_id = t.unit_id AND cb.course_id = @course_id AND cb.category = 'summary'
CROSS JOIN `languages` l
WHERE l.is_active = 1
  AND NOT EXISTS (
    SELECT 1 FROM (SELECT book_id, language_id FROM course_books_translations) x
    WHERE x.book_id = cb.id AND x.language_id = l.id
  );


-- ─── ٥. العدّادات ───────────────────────────────────────────────────────────
-- تُحسب من `videos` الآن، لا من الجدول المهجور.

UPDATE `units` u
   SET u.lessons_count = (SELECT COUNT(*) FROM videos v WHERE v.unit_id = u.id AND v.is_active = 1)
 WHERE u.course_id = @course_id;

UPDATE `courses` c
   SET c.lessons_count = (
         SELECT COUNT(*) FROM videos v
         JOIN units un ON un.id = v.unit_id
        WHERE un.course_id = @course_id AND v.is_active = 1)
 WHERE c.id = @course_id;


-- ─── ٦. التحقّق ─────────────────────────────────────────────────────────────
-- المتوقّع: ٣ وحدات · ٨ دروس منشورة · ٣ ملخّصات · اختبار واحد بثلاثة أسئلة ·
-- وصفر في العمود الأخير، فلا يبقى شيء في الجدول المهجور.

SELECT
  (SELECT COUNT(*) FROM units  WHERE course_id = @course_id)                      AS units,
  (SELECT COUNT(*) FROM videos v JOIN units u ON u.id = v.unit_id
    WHERE u.course_id = @course_id)                                               AS lessons,
  (SELECT COUNT(*) FROM videos v JOIN units u ON u.id = v.unit_id
    WHERE u.course_id = @course_id AND v.publish_status = 'published')            AS published,
  (SELECT COUNT(*) FROM videos_translations vt JOIN videos v ON v.id = vt.video_id
     JOIN units u ON u.id = v.unit_id WHERE u.course_id = @course_id)             AS lesson_names,
  (SELECT COUNT(*) FROM course_books WHERE course_id = @course_id
     AND category = 'summary')                                                    AS summaries,
  (SELECT COUNT(*) FROM course_exams WHERE course_id = @course_id
     AND unit_id IS NOT NULL AND unit_id = @u1)                                   AS unit1_exams,
  (SELECT lessons_count FROM courses WHERE id = @course_id)                       AS course_lessons_count,
  (SELECT COUNT(*) FROM course_videos WHERE course_id = @course_id
     AND video_url = @video_url)                                                  AS stale_rows_left;
