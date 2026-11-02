-- ============================================================================
--  كورس اختبار بسعرين جنيه — لتجربة الدفع الحقيقي عبر EasyKash
--  مؤقّت. احذفه بعد الاختبار من القسم الأخير في آخر الملف.
--  غير مُودَع في Git عمدًا.
-- ============================================================================
--
--  لماذا ٢ جنيه: سألتُ EasyKash مباشرةً، فحدّها هو "أكثر من ١" حرفيًا
--  ({"message":"Amount must be more than 1"} على المبلغ ١). فـ٢ أقل رقم
--  عمليّ. وقد ترفض الفيزا أو فوري مبلغًا بهذا الصغر عند الدفع الفعلي؛
--  لو حدث، غيّر السعر إلى 20.00 من السطر المخصّص لذلك أدناه.
--
--  التشغيل:
--    mysql -u campcod1_brain-ixa -p campcod1_brain-ixa < test_course_2egp.sql
--  أو الصق المحتوى في phpMyAdmin.
-- ============================================================================


-- ─── ١. من أين تأتي التصنيفات ───────────────────────────────────────────────
-- لا أُثبّت أي معرّف برقم. الكورس الجديد يرث مادته وصفّه الدراسي ومدرّسه من
-- كورس ظاهر فعلًا على المنصة، لأن الطالب يُرشَّح له المحتوى حسب صفّه: كورس
-- بصفّ لا يخص student1 لن يراه، فيفشل الاختبار لسبب لا علاقة له بالدفع.

SET @src := (
  SELECT id FROM courses
  WHERE is_active = 1 AND show_on_website = 1 AND kind <> 'package'
  ORDER BY id DESC LIMIT 1
);

SET @subject_id        := COALESCE((SELECT subject_id        FROM courses WHERE id = @src),
                                   (SELECT MIN(id) FROM subjects        WHERE is_active = 1));
SET @academic_year_id  := COALESCE((SELECT academic_year_id  FROM courses WHERE id = @src),
                                   (SELECT MIN(id) FROM academic_years  WHERE is_active = 1));
SET @teacher_id        := COALESCE((SELECT teacher_id        FROM courses WHERE id = @src),
                                   (SELECT MIN(id) FROM teachers));
SET @category_id       := (SELECT category_id FROM courses WHERE id = @src);
SET @admin_id          := (SELECT MIN(id) FROM admins);

-- غيّر هذا وحده لو رفضت وسيلة الدفع مبلغًا بهذا الصغر:
SET @test_price := 2.00;


-- ─── ٢. الكورس ──────────────────────────────────────────────────────────────
-- الـ slug فريد ومميّز، فيسهل العثور عليه عند الحذف، ويستحيل أن يصطدم بكورس
-- حقيقي. التكرار محميّ بـ NOT EXISTS حتى لا يُنشأ كورسان لو شُغّل الملف مرتين.

INSERT INTO `courses`
  (`category_id`, `subject_id`, `academic_year_id`, `teacher_id`, `slug`, `type`, `kind`,
   `duration_months`, `allow_video_download`, `price`, `lessons_count`, `order_num`,
   `is_active`, `show_on_website`, `created_by_type`, `created_by_id`)
SELECT @category_id, @subject_id, @academic_year_id, @teacher_id,
       'payment-test-2egp', 'recorded', 'normal',
       NULL, 0, @test_price, 0, 999,
       1, 1, 'admin', @admin_id
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM courses WHERE slug = 'payment-test-2egp') AS x);

SET @course_id := (SELECT id FROM courses WHERE slug = 'payment-test-2egp' LIMIT 1);


-- ─── ٣. الاسم بكل لغة مفعّلة ────────────────────────────────────────────────
-- الاسم يعيش في جدول ترجمة لا في صف الكورس، ولغة واحدة لا تكفي: الصفحة تقرأ
-- ترجمة لغة الطلب، فلو نقصت ظهر الـ slug مكان الاسم.

INSERT INTO `courses_translations` (`course_id`, `language_id`, `name`, `description`, `is_active`)
SELECT @course_id, l.id,
       CASE WHEN l.code = 'en' THEN 'Payment test - 2 EGP (delete me)'
            ELSE 'اختبار الدفع - ٢ جنيه (للحذف)' END,
       CASE WHEN l.code = 'en' THEN 'Temporary course for testing the EasyKash payment flow. Safe to delete.'
            ELSE 'كورس مؤقت لاختبار الدفع عبر إيزي كاش. يُحذف بعد الاختبار.' END,
       1
FROM `languages` l
WHERE l.is_active = 1
  AND NOT EXISTS (
    SELECT 1 FROM (
      SELECT course_id, language_id FROM courses_translations WHERE course_id = @course_id
    ) AS t WHERE t.language_id = l.id
  );


-- ─── ٤. تأكيد ───────────────────────────────────────────────────────────────
SELECT c.id        AS course_id,
       ct.name     AS name,
       c.price     AS price,
       c.slug      AS slug,
       c.is_active, c.show_on_website,
       CONCAT('https://brainixa-student-dash.vercel.app/courses/', c.id, '?subscribe=1') AS buy_link
FROM courses c
LEFT JOIN courses_translations ct
       ON ct.course_id = c.id
      AND ct.language_id = (SELECT id FROM languages WHERE code = 'ar' LIMIT 1)
WHERE c.slug = 'payment-test-2egp';


-- ============================================================================
--  ٥. الحذف بعد الاختبار — أزل التعليق عن الكتلة التالية وشغّلها
-- ============================================================================
--  رتّب الحذف من الأبناء إلى الأب، وإلا رفضته قيود المفاتيح الأجنبية.
--  لاحظ: هذا يحذف الكورس واشتراكاته ومعاملاته، لا المال نفسه — استرداد
--  الجنيهين يبقى شأن EasyKash.
--
-- SET @course_id := (SELECT id FROM courses WHERE slug = 'payment-test-2egp' LIMIT 1);
--
-- -- أمسك الاشتراكات المرتبطة بالكورس أولًا، قبل حذف روابطها.
-- -- بعد حذف الروابط يستحيل معرفة أيّها كان للكورس الاختباري، وحذف "كل اشتراك
-- -- بلا روابط" حينئذٍ قد يبتلع اشتراكات لا علاقة لها بالاختبار.
-- CREATE TEMPORARY TABLE tmp_test_subs AS
--   SELECT DISTINCT student_subscription_id AS id
--   FROM student_subscription_courses
--   WHERE course_id = @course_id;
--
-- -- واستبعد أي اشتراك يغطي شيئًا آخر أيضًا: ذاك يخص الطالب فعلًا ويجب أن يبقى،
-- -- وكل ما يلزمه هو فكّ ارتباطه بالكورس الاختباري وحده.
-- DELETE t FROM tmp_test_subs t
--   WHERE EXISTS (SELECT 1 FROM student_subscription_courses  x WHERE x.student_subscription_id = t.id AND x.course_id <> @course_id)
--      OR EXISTS (SELECT 1 FROM student_subscription_subjects x WHERE x.student_subscription_id = t.id)
--      OR EXISTS (SELECT 1 FROM student_subscription_teachers x WHERE x.student_subscription_id = t.id)
--      OR EXISTS (SELECT 1 FROM student_subscription_books    x WHERE x.student_subscription_id = t.id)
--      OR EXISTS (SELECT 1 FROM (SELECT id FROM student_subscriptions WHERE subscription_code_id IS NOT NULL) s WHERE s.id = t.id);
--
-- DELETE FROM student_subscription_courses WHERE course_id = @course_id;
-- DELETE ss FROM student_subscriptions ss JOIN tmp_test_subs t ON t.id = ss.id;
-- DROP TEMPORARY TABLE tmp_test_subs;
--
-- DELETE FROM payment_transactions      WHERE item_type = 'course' AND item_id = @course_id;
-- DELETE FROM offline_payment_requests  WHERE item_type = 'course' AND item_id = @course_id;
-- DELETE FROM courses_translations      WHERE course_id = @course_id;
-- DELETE FROM courses                   WHERE id = @course_id;
