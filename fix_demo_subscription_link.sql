-- ============================================================================
--  يُصلح خطأً مني في setup_demo_student_course.sql: الاشتراك أُنشئ فعلًا لكن
--  لم يُربط بالكورس، فظهر «NULL» في سطر التحقّق الأخير بدل ١.
--
--  السبب: السطر الذي يقرأ معرّف الاشتراك الجديد كان يبحث عنه عبر الربط مع
--  الكورس — والربط هذا لم يكن قد كُتب بعد في تلك اللحظة من الملفّ نفسه.
--  فبقي الاشتراك يتيمًا: موجودًا، نشطًا، لكن غير مرتبط بأي كورس.
--
--  هذا الملفّ لا يُنشئ اشتراكًا جديدًا — فذلك يُكرّر الصفّ اليتيم بصفّ آخر
--  يتيم مثله. يبحث عن الاشتراك اليتيم نفسه الذي خلّفه التشغيل السابق ويربطه.
--
--  آمن للتشغيل مرّتين: لو كان الربط موجودًا بالفعل فلا شيء يتغيّر.
-- ============================================================================

SET @student_email := 'demo.student@brainixa.cloud';
SET @course_slug    := 'demo-math-g11';

SET @student_id := (SELECT id FROM students WHERE email = @student_email LIMIT 1);
SET @course_id   := (SELECT id FROM courses WHERE slug = @course_slug LIMIT 1);

-- الاشتراك اليتيم: نشط، من نوع كورس، يخصّ هذا الطالب، ولا يملك أي ربط بأي
-- كورس إطلاقًا — لا هذا الكورس ولا غيره، فهذا ما يعنيه «لم يُربط بعد».
SET @orphan_sub_id := (
    SELECT ss.id FROM student_subscriptions ss
    WHERE ss.student_id = @student_id
      AND ss.subscription_type = 'course'
      AND ss.is_active = 1
      AND NOT EXISTS (SELECT 1 FROM student_subscription_courses ssc WHERE ssc.student_subscription_id = ss.id)
    ORDER BY ss.id DESC
    LIMIT 1
);

INSERT INTO `student_subscription_courses` (`student_subscription_id`, `course_id`)
SELECT @orphan_sub_id, @course_id
FROM DUAL
WHERE @orphan_sub_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM student_subscription_courses WHERE student_subscription_id = @orphan_sub_id AND course_id = @course_id) x);


-- ─── التحقّق ───────────────────────────────────────────────────────────────
SELECT
    'orphan_sub_id الذي رُبط' AS what, @orphan_sub_id AS value
UNION ALL
SELECT
    'الاشتراك فعّال؟',
    (SELECT ss.is_active FROM student_subscriptions ss
     JOIN student_subscription_courses ssc ON ssc.student_subscription_id = ss.id
     WHERE ss.student_id = @student_id AND ssc.course_id = @course_id AND ss.is_active = 1
     LIMIT 1);
