-- ============================================================================
--  حساب اختبار Zoom لمطوّر الموبايل — student2005@example.com
--
--  الغرض: تجهيز حساب طالب جاهز تمامًا لتجربة البثّ المباشر داخل التطبيق، على
--  المسارين اللذين يعمل بهما Zoom فعليًّا:
--
--    ١) حصص الباقات  →  teacher_availability_slots + availability_slot_bookings
--    ٢) الاستشارات   →  consultation_slots
--
--  ويضيف كذلك — للاكتمال — حصص القالب الأسبوعي class_sessions، وهي المسار
--  الثالث الأقدم الذي ما زالت نقاطه قائمة في الـ API.
--
--  ما يُنشئه الملفّ:
--    • الطالب student2005@example.com بكلمة مرور 12345678 (كبقيّة حسابات الاختبار).
--    • باقة مخصّصة للاختبار slug = 'package-zoom-test-2026' مسنَدة إلى المعلّم
--      teacher1@brainixa.cloud، مع ترجمتَي عربي/إنجليزي.
--    • اشتراك فعّال للطالب في هذه الباقة لمدّة سنة.
--    • ٤٢ موعدًا (١٤ يومًا × ٣ مواعيد يوميًّا) + موعد إضافي يبدأ في الساعة الحاليّة،
--      أوّل ٧ أيّام منها محجوزة للطالب، والباقي متروك مفتوحًا لتجربة الحجز نفسه.
--    • ١٠ مواعيد استشارة: ٥ محجوزة ومعتمَدة للطالب (جاهزة للبدء)، و٥ متاحة للحجز.
--    • ٧ حصص أسبوعيّة في class_sessions (حصّة لكل يوم من أيّام الأسبوع).
--
--  التشغيل (من طرفيّة cPanel على الخادم، أو بلصق المحتوى في phpMyAdmin):
--      cd ~/public_html/brain-ixa
--      mysql -u campcod1_brain-ixa -p campcod1_brain-ixa < seed_zoom_test_student2005.sql
--
--  آمن للتشغيل أكثر من مرّة: كل إدراج محميّ إمّا بمفتاح فريد مع INSERT IGNORE
--  أو بفحص NOT EXISTS.
--
--  تحذير واحد: الملفّ يعيد ضبط كلمة مرور student2005@example.com إلى 12345678
--  حتى لو كان الحساب موجودًا مسبقًا بكلمة مرور أخرى.
-- ============================================================================

-- الترتيب (collation) مثبَّت صراحةً: كل الجداول utf8mb4_unicode_ci، بينما
-- SET NAMES المجرّدة تجعل ترتيب متغيّرات الجلسة utf8mb4_general_ci، فينشأ خطأ
-- "Illegal mix of collations" عند كل مقارنة `= @var`.
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET SESSION sql_mode = '';
START TRANSACTION;


-- ─── ٠) الثوابت ─────────────────────────────────────────────────────────────
SET @student_email  := 'student2005@example.com';
SET @student_name   := 'طالب اختبار الزوم 2005';
-- بصمة bcrypt لكلمة المرور 12345678 (نفس البصمة المستعملة في بقيّة حسابات الاختبار).
SET @password_hash  := '$2b$10$3lS8tBYLIKoH1oDOgnajzul6LsfMlkSEROaGVkCMnaDXSC4Z3Jz3a';
SET @teacher_email  := 'teacher1@brainixa.cloud';
SET @package_slug   := 'package-zoom-test-2026';
SET @marker         := 'zoom-test-student2005';

SET @admin_id   := (SELECT MIN(id) FROM admins);
SET @lang_ar    := (SELECT id FROM languages WHERE code = 'ar' LIMIT 1);
SET @lang_en    := (SELECT id FROM languages WHERE code = 'en' LIMIT 1);
SET @country_eg := (SELECT id FROM countries WHERE iso2 = 'EG' LIMIT 1);


-- ─── ١) المعلّم ─────────────────────────────────────────────────────────────
-- يُفضَّل teacher1@brainixa.cloud لأنّ كلمة مروره معروفة للمطوّر (12345678)، وهو
-- من سيضغط «ابدأ» فتُنشأ غرفة Zoom. وإن لم يوجد، فأوّل معلّم مفعَّل.
SET @teacher_id := (SELECT id FROM teachers WHERE email = @teacher_email LIMIT 1);
SET @teacher_id := COALESCE(@teacher_id, (SELECT id FROM teachers WHERE is_active = 1 ORDER BY id LIMIT 1));
SET @teacher_id := COALESCE(@teacher_id, (SELECT id FROM teachers ORDER BY id LIMIT 1));

UPDATE `teachers` SET `is_active` = 1, `is_email_verified` = 1 WHERE `id` = @teacher_id;


-- ─── ٢) المادّة والصفّ الدراسي ──────────────────────────────────────────────
SET @subject_id := COALESCE(
    (SELECT subject_id FROM teacher_subjects WHERE teacher_id = @teacher_id AND is_active = 1 ORDER BY id LIMIT 1),
    (SELECT subject_id FROM teachers WHERE id = @teacher_id),
    (SELECT id FROM subjects WHERE is_active = 1 ORDER BY id LIMIT 1)
);

SET @ay_id := COALESCE(
    (SELECT academic_year_id FROM teacher_subjects WHERE teacher_id = @teacher_id AND academic_year_id IS NOT NULL ORDER BY id LIMIT 1),
    (SELECT id FROM academic_years WHERE is_active = 1 ORDER BY id LIMIT 1)
);


-- ─── ٣) الباقة ──────────────────────────────────────────────────────────────
-- باقة مستقلّة مخصّصة للاختبار بدلًا من التعليق على باقة حقيقيّة: إضافة ٤٢ موعدًا
-- إلى باقة يشترك فيها طلّاب آخرون كانت ستغيّر ما يرونه هم أيضًا.
INSERT INTO `courses`
    (`subject_id`, `academic_year_id`, `teacher_id`, `slug`, `type`, `kind`,
     `duration_months`, `price`, `is_active`, `show_on_website`, `created_by_type`, `created_by_id`)
SELECT @subject_id, @ay_id, @teacher_id, @package_slug, 'recorded', 'package',
       12, 0.00, 1, 1, 'admin', @admin_id
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM courses WHERE slug = @package_slug) x);

SET @package_id := (SELECT id FROM courses WHERE slug = @package_slug LIMIT 1);

INSERT INTO `courses_translations` (`course_id`, `language_id`, `name`, `description`, `is_active`)
SELECT @package_id, @lang_ar,
       'باقة اختبار البثّ المباشر (Zoom)',
       'باقة مخصّصة لاختبار حصص Zoom داخل التطبيق: مواعيد محجوزة، ومواعيد متاحة للحجز، واستشارات.',
       1
FROM DUAL
WHERE @lang_ar IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM courses_translations WHERE course_id = @package_id AND language_id = @lang_ar) x);

INSERT INTO `courses_translations` (`course_id`, `language_id`, `name`, `description`, `is_active`)
SELECT @package_id, @lang_en,
       'Live Classes Test Package (Zoom)',
       'A package dedicated to testing in-app Zoom classes: booked slots, open slots, and consultations.',
       1
FROM DUAL
WHERE @lang_en IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM (SELECT id FROM courses_translations WHERE course_id = @package_id AND language_id = @lang_en) x);

INSERT INTO `course_teachers` (`course_id`, `teacher_id`, `is_active`)
SELECT @package_id, @teacher_id, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM course_teachers WHERE course_id = @package_id AND teacher_id = @teacher_id) x);


-- ─── ٤) الطالب ──────────────────────────────────────────────────────────────
INSERT INTO `students`
    (`name`, `email`, `password`, `phone`, `phone_country_code`, `country_id`,
     `academic_year_id`, `study_language`, `is_email_verified`, `is_active`)
SELECT @student_name, @student_email, @password_hash, '01092005205', '20', @country_eg,
       @ay_id, 'arabic', 1, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM students WHERE email = @student_email) x);

SET @student_id := (SELECT id FROM students WHERE email = @student_email ORDER BY id LIMIT 1);

-- يُطبَّق أيضًا على حساب موجود مسبقًا، حتى يصير «زيّ حساباتنا»: كلمة المرور
-- 12345678، مفعَّل، بريده موثَّق، ولا توكنات ملغاة تمنع الدخول.
UPDATE `students`
SET `password`            = @password_hash,
    `is_active`           = 1,
    `is_email_verified`   = 1,
    `academic_year_id`    = COALESCE(`academic_year_id`, @ay_id),
    `sessions_revoked_at` = NULL
WHERE `id` = @student_id;


-- ─── ٥) الاشتراك في الباقة ──────────────────────────────────────────────────
SET @sub_id := (
    SELECT ss.id
    FROM student_subscriptions ss
    JOIN student_subscription_courses ssc ON ssc.student_subscription_id = ss.id
    WHERE ss.student_id = @student_id AND ssc.course_id = @package_id
    ORDER BY ss.id DESC
    LIMIT 1
);

INSERT INTO `student_subscriptions`
    (`student_id`, `subscription_type`, `start_date`, `end_date`, `is_active`)
SELECT @student_id, 'package', NOW(), DATE_ADD(NOW(), INTERVAL 365 DAY), 1
FROM DUAL
WHERE @sub_id IS NULL;

SET @sub_id := COALESCE(@sub_id, LAST_INSERT_ID());

-- الحجز يرفض أيّ موعد تاريخه بعد نهاية الاشتراك، فالنهاية تُمدّ دائمًا إلى سنة
-- من اليوم إن كانت أقرب من ذلك.
UPDATE `student_subscriptions`
SET `is_active`    = 1,
    `paused_at`    = NULL,
    `cancelled_at` = NULL,
    `end_date`     = GREATEST(COALESCE(`end_date`, NOW()), DATE_ADD(NOW(), INTERVAL 365 DAY))
WHERE `id` = @sub_id;

INSERT INTO `student_subscription_courses` (`student_subscription_id`, `course_id`)
SELECT @sub_id, @package_id
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM (SELECT id FROM student_subscription_courses WHERE student_subscription_id = @sub_id AND course_id = @package_id) x);


-- ─── ٦) مواعيد الباقة (حصص Zoom) ────────────────────────────────────────────
-- ١٤ يومًا × ٣ مواعيد = ٤٢ موعدًا. السعة ٥ لكل موعد حتى يظلّ الموعد «متاحًا»
-- بعد حجز الطالب فيه، فيمكن اختبار حصّة جماعيّة أيضًا.
-- المفتاح الفريد (teacher_id, slot_date, start_time) هو ما يجعل INSERT IGNORE
-- كافيًا لإعادة التشغيل دون تكرار.
INSERT IGNORE INTO `teacher_availability_slots`
    (`teacher_id`, `course_id`, `subject_id`, `slot_date`, `start_time`, `end_time`,
     `capacity`, `booked_count`, `status`, `is_online`, `notes`, `created_by_type`, `created_by_id`)
SELECT @teacher_id, @package_id, @subject_id,
       DATE_ADD(CURDATE(), INTERVAL d.n DAY), t.st, t.et,
       5, 0, 'available', 1, @marker, 'admin', @admin_id
FROM (
    SELECT 0 AS n UNION ALL SELECT 1  UNION ALL SELECT 2  UNION ALL SELECT 3
    UNION ALL SELECT 4  UNION ALL SELECT 5  UNION ALL SELECT 6  UNION ALL SELECT 7
    UNION ALL SELECT 8  UNION ALL SELECT 9  UNION ALL SELECT 10 UNION ALL SELECT 11
    UNION ALL SELECT 12 UNION ALL SELECT 13
) d
CROSS JOIN (
    SELECT '10:00:00' AS st, '11:30:00' AS et
    UNION ALL SELECT '14:00:00', '15:30:00'
    UNION ALL SELECT '18:00:00', '19:30:00'
) t;

-- موعد إضافي يبدأ في الساعة الحاليّة، حتى تكون نافذة الوقت (is_live) مفتوحة
-- فور تشغيل الملفّ دون انتظار. يُتجاهَل تلقائيًّا إن صادف موعدًا قائمًا.
SET @now_start := SEC_TO_TIME(FLOOR(TIME_TO_SEC(CURTIME()) / 3600) * 3600);
SET @now_end   := IF(HOUR(CURTIME()) >= 23,
                     '23:59:00',
                     SEC_TO_TIME((FLOOR(TIME_TO_SEC(CURTIME()) / 3600) + 1) * 3600));

INSERT IGNORE INTO `teacher_availability_slots`
    (`teacher_id`, `course_id`, `subject_id`, `slot_date`, `start_time`, `end_time`,
     `capacity`, `booked_count`, `status`, `is_online`, `notes`, `created_by_type`, `created_by_id`)
VALUES
    (@teacher_id, @package_id, @subject_id, CURDATE(), @now_start, @now_end,
     5, 0, 'available', 1, @marker, 'admin', @admin_id);


-- ─── ٧) حجز الطالب في مواعيد أوّل ٧ أيّام ───────────────────────────────────
-- الباقي (أيّام ٧ إلى ١٣) يُترك مفتوحًا عمدًا ليختبر المطوّر الحجز نفسه من التطبيق.
INSERT IGNORE INTO `availability_slot_bookings`
    (`slot_id`, `student_id`, `student_subscription_id`, `status`, `booked_by_type`, `booked_by_id`)
SELECT s.id, @student_id, @sub_id, 'booked', 'admin', @admin_id
FROM `teacher_availability_slots` s
WHERE s.teacher_id = @teacher_id
  AND s.course_id  = @package_id
  AND s.slot_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 6 DAY);

-- booked_count و status نسخة مخزَّنة من جدول الحجوزات يعيد الباك حسابها بعد كل
-- كتابة؛ وهنا يُفعل الشيء نفسه يدويًّا.
UPDATE `teacher_availability_slots` s
SET s.`booked_count` = (
        SELECT COUNT(*) FROM `availability_slot_bookings` b
        WHERE b.slot_id = s.id AND b.status <> 'cancelled'
    )
WHERE s.`teacher_id` = @teacher_id AND s.`course_id` = @package_id;

UPDATE `teacher_availability_slots`
SET `status` = IF(`booked_count` >= `capacity`, 'full', 'available')
WHERE `teacher_id` = @teacher_id
  AND `course_id`  = @package_id
  AND `status` IN ('available', 'full');


-- ─── ٨) مواعيد الاستشارات ───────────────────────────────────────────────────
-- خمسة مواعيد محجوزة ومعتمَدة (status = 'approved') جاهزة ليضغط المعلّم «ابدأ»،
-- وخمسة متاحة ليختبر الطالب الحجز ثمّ يعتمدها المعلّم.
INSERT INTO `consultation_slots`
    (`teacher_id`, `subject_id`, `type`, `meeting_type`, `slot_date`, `slot_time`,
     `notes`, `is_booked`, `student_id`, `booked_at`, `status`, `is_active`)
SELECT @teacher_id, @subject_id, 'educational', 'online',
       DATE_ADD(CURDATE(), INTERVAL c.n DAY), c.tm,
       @marker,
       c.booked,
       IF(c.booked = 1, @student_id, NULL),
       IF(c.booked = 1, NOW(), NULL),
       IF(c.booked = 1, 'approved', 'available'),
       1
FROM (
    SELECT 0 AS n, '12:00:00' AS tm, 1 AS booked
    UNION ALL SELECT 0, '16:00:00', 1
    UNION ALL SELECT 1, '12:00:00', 1
    UNION ALL SELECT 2, '12:00:00', 1
    UNION ALL SELECT 3, '12:00:00', 1
    UNION ALL SELECT 1, '16:00:00', 0
    UNION ALL SELECT 2, '16:00:00', 0
    UNION ALL SELECT 3, '16:00:00', 0
    UNION ALL SELECT 4, '16:00:00', 0
    UNION ALL SELECT 5, '16:00:00', 0
) c
WHERE NOT EXISTS (
    SELECT 1 FROM (SELECT teacher_id, slot_date, slot_time FROM consultation_slots) x
    WHERE x.teacher_id = @teacher_id
      AND x.slot_date  = DATE_ADD(CURDATE(), INTERVAL c.n DAY)
      AND x.slot_time  = c.tm
);


-- ─── ٩) حصص القالب الأسبوعي (class_sessions) ────────────────────────────────
-- المسار الثالث للزوم، وهو ما تقرؤه شاشة «حصص اليوم». حصّة لكل يوم من أيّام
-- الأسبوع حتى يجد المطوّر حصّة اليوم أيًّا كان يوم التجربة.
INSERT INTO `class_sessions`
    (`teacher_id`, `subject_id`, `course_id`, `code`, `day_of_week`,
     `start_time`, `end_time`, `is_online`, `academic_year_id`, `is_active`)
SELECT @teacher_id, @subject_id, @package_id,
       CONCAT('zoom-test-2005-', w.d), w.d,
       '17:00:00', '18:00:00', 1, @ay_id, 1
FROM (
    SELECT 'Saturday' AS d UNION ALL SELECT 'Sunday'   UNION ALL SELECT 'Monday'
    UNION ALL SELECT 'Tuesday'  UNION ALL SELECT 'Wednesday'
    UNION ALL SELECT 'Thursday' UNION ALL SELECT 'Friday'
) w
WHERE NOT EXISTS (
    SELECT 1 FROM (SELECT code FROM class_sessions) x
    WHERE x.code = CONCAT('zoom-test-2005-', w.d)
);


COMMIT;


-- ─── ١٠) ملخّص ما تمّ ───────────────────────────────────────────────────────
SELECT 'student'              AS item, @student_id AS id_or_count, @student_email AS detail
UNION ALL SELECT 'password',            NULL, '12345678'
UNION ALL SELECT 'teacher',             @teacher_id, (SELECT email FROM teachers WHERE id = @teacher_id)
UNION ALL SELECT 'package course_id',   @package_id, @package_slug
UNION ALL SELECT 'subscription',        @sub_id, CAST((SELECT end_date FROM student_subscriptions WHERE id = @sub_id) AS CHAR)
UNION ALL SELECT 'package slots',       (SELECT COUNT(*) FROM teacher_availability_slots WHERE teacher_id = @teacher_id AND course_id = @package_id), 'total'
UNION ALL SELECT 'slots booked',        (SELECT COUNT(*) FROM availability_slot_bookings WHERE student_id = @student_id AND status = 'booked'), 'ready to join'
UNION ALL SELECT 'consult approved',    (SELECT COUNT(*) FROM consultation_slots WHERE student_id = @student_id AND status = 'approved'), 'ready to start'
UNION ALL SELECT 'consult available',   (SELECT COUNT(*) FROM consultation_slots WHERE teacher_id = @teacher_id AND status = 'available' AND slot_date >= CURDATE()), 'bookable'
UNION ALL SELECT 'class_sessions',      (SELECT COUNT(*) FROM class_sessions WHERE course_id = @package_id AND teacher_id = @teacher_id), 'weekly';

-- قائمة المواعيد بمعرِّفاتها، ليأخذ منها المطوّر أيّ slot_id يجرّب عليه مباشرةً.
SELECT s.id AS slot_id, s.slot_date, s.start_time, s.end_time, s.status,
       s.booked_count, s.capacity,
       IF(b.id IS NULL, 'مفتوح للحجز', 'محجوز للطالب') AS booking_state
FROM `teacher_availability_slots` s
LEFT JOIN `availability_slot_bookings` b
       ON b.slot_id = s.id AND b.student_id = @student_id AND b.status <> 'cancelled'
WHERE s.teacher_id = @teacher_id AND s.course_id = @package_id AND s.slot_date >= CURDATE()
ORDER BY s.slot_date, s.start_time;

SELECT id AS consultation_slot_id, slot_date, slot_time, status, is_booked, student_id
FROM `consultation_slots`
WHERE teacher_id = @teacher_id AND notes = @marker AND slot_date >= CURDATE()
ORDER BY slot_date, slot_time;
