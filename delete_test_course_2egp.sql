-- ============================================================================
--  حذف كامل لكورس وكل ما يتفرّع عنه
--  كُتب لكورس اختبار الدفع (٢ جنيه)، ويصلح لأي كورس بتغيير السطر الأول وحده.
--
--  التشغيل:
--    mysql -u campcod1_brain-ixa -p campcod1_brain-ixa < delete_test_course_2egp.sql
--  أو الصق المحتوى في phpMyAdmin.
--
--  آمن للتشغيل مرّتين: لو كان الكورس محذوفًا فالمعرّف يصير NULL ولا يطابق صفًّا.
-- ============================================================================
--
--  لماذا هذا الملف طويل إلى هذا الحدّ:
--
--  تسعة عشر جدولًا في قاعدة البيانات تحمل عمود `course_id`، لكن **خمسة فقط**
--  منها لها مفتاح أجنبي حقيقي نحو `courses`. أي أن حذف صف الكورس وحده لا
--  يُسقط إلا خُمس ما يخصّه، ويترك الباقي صفوفًا يتيمة تشير إلى معرّف لم يعد
--  موجودًا — وهذا أخطر ممّا يبدو، لأن MySQL يعيد استعمال المعرّفات: كورس
--  جديد قد يرث يومًا ما اشتراكات الكورس المحذوف وتقييماته.
--
--  والأعمق من ذلك: أبناء الأبناء (ترجمات الفيديوهات، تقدّم الطلاب في الكتب،
--  حضور الحصص، محاولات الامتحانات) كلّها بلا قيود أيضًا. لذلك يُجمع كل مستوى
--  في جدول مؤقّت قبل حذف أبيه، إذ بعد حذف الأب يستحيل معرفة من كان ابنه.
--
--  ملاحظة: هذا يحذف الكورس ومعاملاته من قاعدة البيانات، لا المال نفسه —
--  استرداد ما دُفع يبقى شأن بوابة الدفع.
-- ============================================================================


-- ─── ٠. الهدف ───────────────────────────────────────────────────────────────
SET @slug      := 'payment-test-2egp';
SET @course_id := (SELECT id FROM courses WHERE slug = @slug LIMIT 1);

SELECT @course_id AS will_delete_course_id,
       (SELECT name FROM courses_translations WHERE course_id = @course_id LIMIT 1) AS course_name;


-- ─── ١. جمع الأبناء قبل المساس بآبائهم ──────────────────────────────────────
-- جداول مؤقّتة لأن الصلة تُفقد بمجرّد حذف الأب. وكل واحد منها يُقرأ مرّة واحدة
-- في كل استعلام: MySQL لا يسمح بذكر الجدول المؤقّت مرّتين في الاستعلام نفسه.

DROP TEMPORARY TABLE IF EXISTS t_unit, t_video, t_exam, t_book, t_cert, t_session, t_sub;

CREATE TEMPORARY TABLE t_unit    AS SELECT id FROM units         WHERE course_id = @course_id;
CREATE TEMPORARY TABLE t_exam    AS SELECT id FROM course_exams  WHERE course_id = @course_id;
CREATE TEMPORARY TABLE t_book    AS SELECT id FROM course_books  WHERE course_id = @course_id;
CREATE TEMPORARY TABLE t_cert    AS SELECT id FROM certificates  WHERE course_id = @course_id;
CREATE TEMPORARY TABLE t_session AS SELECT id FROM class_sessions WHERE course_id = @course_id;
-- فيديو قد يُربط بالكورس مباشرةً أو بوحدة من وحداته، فالاثنان يُجمعان معًا.
CREATE TEMPORARY TABLE t_video   AS
  SELECT id FROM course_videos
  WHERE course_id = @course_id
     OR unit_id IN (SELECT id FROM t_unit);


-- ─── ٢. الفيديوهات ──────────────────────────────────────────────────────────
DELETE FROM course_videos_translations WHERE video_id IN (SELECT id FROM t_video);
DELETE FROM student_video_progress     WHERE video_id IN (SELECT id FROM t_video);
DELETE FROM video_teachers             WHERE video_id IN (SELECT id FROM t_video);
DELETE FROM course_videos              WHERE id       IN (SELECT id FROM t_video);


-- ─── ٣. الامتحانات ──────────────────────────────────────────────────────────
-- محاولات الامتحان وأسئلته تُحذف بالتتابع تلقائيًّا (لهما مفتاح أجنبي حقيقي)،
-- ومعها إجابات المحاولات وخيارات الأسئلة. الباقي يدويّ.
DELETE FROM course_exams_translations WHERE exam_id IN (SELECT id FROM t_exam);
DELETE FROM exam_teachers             WHERE exam_id IN (SELECT id FROM t_exam);
DELETE FROM student_certificates      WHERE exam_id IN (SELECT id FROM t_exam);
DELETE FROM course_exams              WHERE id      IN (SELECT id FROM t_exam);


-- ─── ٤. الكتب ───────────────────────────────────────────────────────────────
DELETE FROM course_books_translations      WHERE book_id IN (SELECT id FROM t_book);
DELETE FROM book_teachers                  WHERE book_id IN (SELECT id FROM t_book);
DELETE FROM student_book_progress          WHERE book_id IN (SELECT id FROM t_book);
DELETE FROM student_book_purchase_requests WHERE book_id IN (SELECT id FROM t_book);
DELETE FROM student_book_subscriptions     WHERE book_id IN (SELECT id FROM t_book);
DELETE FROM student_subscription_books     WHERE book_id IN (SELECT id FROM t_book);
DELETE FROM course_books                   WHERE id      IN (SELECT id FROM t_book);


-- ─── ٥. الشهادات ────────────────────────────────────────────────────────────
DELETE FROM certificate_teachers     WHERE certificate_id IN (SELECT id FROM t_cert);
DELETE FROM certificates_translations WHERE certificate_id IN (SELECT id FROM t_cert);
DELETE FROM student_certificates     WHERE certificate_id IN (SELECT id FROM t_cert);
DELETE FROM certificates             WHERE id             IN (SELECT id FROM t_cert);


-- ─── ٦. الحصص المباشرة وما عُلّق بها ─────────────────────────────────────────
DELETE FROM attendance_exception_requests  WHERE session_id IN (SELECT id FROM t_session);
DELETE FROM class_session_notification_log WHERE session_id IN (SELECT id FROM t_session);
DELETE FROM session_attendance             WHERE session_id IN (SELECT id FROM t_session);
DELETE FROM session_files                  WHERE session_id IN (SELECT id FROM t_session);
DELETE FROM session_reschedule_requests    WHERE session_id IN (SELECT id FROM t_session);
DELETE FROM teacher_session_attendance     WHERE session_id IN (SELECT id FROM t_session);
DELETE FROM student_reports                WHERE session_id IN (SELECT id FROM t_session);
DELETE FROM class_sessions                 WHERE id         IN (SELECT id FROM t_session);


-- ─── ٧. الوحدات ─────────────────────────────────────────────────────────────
-- ترجمات الوحدة وفيديوهاتها وأسئلتها ومواردها تتبعها تلقائيًّا بالمفتاح الأجنبي.
DELETE FROM unit_teachers            WHERE unit_id IN (SELECT id FROM t_unit);
DELETE FROM student_question_answers WHERE unit_id IN (SELECT id FROM t_unit);
DELETE FROM units                    WHERE course_id = @course_id;


-- ─── ٨. ما يشير إلى الكورس مباشرةً ───────────────────────────────────────────
DELETE FROM course_ratings            WHERE course_id = @course_id;
DELETE FROM discount_code_courses     WHERE course_id = @course_id;
DELETE FROM discount_code_redemptions WHERE course_id = @course_id;
DELETE FROM subscription_code_courses WHERE course_id = @course_id;
DELETE FROM teacher_availability_slots WHERE course_id = @course_id;
DELETE FROM student_question_answers  WHERE course_id = @course_id;
DELETE FROM student_certificates      WHERE course_id = @course_id;
DELETE FROM student_reports           WHERE course_id = @course_id;
DELETE FROM certificates              WHERE course_id = @course_id;
-- course_teachers وcourses_translations وquestions وresources تتبع الكورس
-- تلقائيًّا بالمفتاح الأجنبي، لكن حذفها صراحةً لا يضرّ ويجعل الملف مقروءًا
-- وحده دون الرجوع إلى المخطّط.
DELETE FROM course_teachers           WHERE course_id = @course_id;


-- ─── ٩. المال والتسعير ──────────────────────────────────────────────────────
-- خمسة جداول تشير إلى أي شيء يُباع بزوج (item_type, item_id) بلا مفتاح أجنبي،
-- فلا شيء منها يُحذف من تلقاء نفسه. المعاملة تُحذف لأن الكورس الذي تخصّه لم
-- يعد موجودًا، لا لأن الدفعة أُلغيت.
DELETE FROM transaction_items        WHERE item_type = 'course' AND item_id = @course_id;
DELETE FROM payment_transactions     WHERE item_type = 'course' AND item_id = @course_id;
DELETE FROM offline_payment_requests WHERE item_type = 'course' AND item_id = @course_id;
DELETE FROM affiliate_commissions    WHERE item_type = 'course' AND item_id = @course_id;
DELETE FROM item_country_prices      WHERE item_type = 'course' AND item_id = @course_id;


-- ─── ١٠. الاشتراكات ─────────────────────────────────────────────────────────
-- أدقّ جزء في الملف. الاشتراك قد يغطّي الكورس الاختباري وغيره معًا؛ ذاك اشتراك
-- حقيقي للطالب ويجب أن يبقى، وكل ما يلزمه فكّ ارتباطه بالكورس وحده. ولا يُحذف
-- إلا الاشتراك الذي لا يبقى له بعد ذلك ما يغطّيه.
CREATE TEMPORARY TABLE t_sub AS
  SELECT DISTINCT student_subscription_id AS id
  FROM student_subscription_courses
  WHERE course_id = @course_id;

DELETE t FROM t_sub t
 WHERE EXISTS (SELECT 1 FROM student_subscription_courses  x WHERE x.student_subscription_id = t.id AND x.course_id <> @course_id)
    OR EXISTS (SELECT 1 FROM student_subscription_subjects x WHERE x.student_subscription_id = t.id)
    OR EXISTS (SELECT 1 FROM student_subscription_teachers x WHERE x.student_subscription_id = t.id)
    OR EXISTS (SELECT 1 FROM student_subscription_books    x WHERE x.student_subscription_id = t.id)
    OR EXISTS (SELECT 1 FROM (SELECT id FROM student_subscriptions WHERE subscription_code_id IS NOT NULL) s WHERE s.id = t.id);

DELETE FROM student_subscription_courses WHERE course_id = @course_id;
DELETE ss FROM student_subscriptions ss JOIN t_sub t ON t.id = ss.id;


-- ─── ١١. الكورس نفسه ────────────────────────────────────────────────────────
DELETE FROM courses_translations WHERE course_id = @course_id;
DELETE FROM courses              WHERE id        = @course_id;

DROP TEMPORARY TABLE IF EXISTS t_unit, t_video, t_exam, t_book, t_cert, t_session, t_sub;


-- ─── ١٢. التحقّق ────────────────────────────────────────────────────────────
-- يجب أن تعود الأصفار كلّها. أي رقم غير صفر يعني صفًّا يتيمًا نجا من الحذف.
SELECT
  (SELECT COUNT(*) FROM courses                   WHERE id        = @course_id) AS course_row,
  (SELECT COUNT(*) FROM courses_translations      WHERE course_id = @course_id) AS translations,
  (SELECT COUNT(*) FROM units                     WHERE course_id = @course_id) AS units,
  (SELECT COUNT(*) FROM course_videos             WHERE course_id = @course_id) AS videos,
  (SELECT COUNT(*) FROM course_exams              WHERE course_id = @course_id) AS exams,
  (SELECT COUNT(*) FROM course_books              WHERE course_id = @course_id) AS books,
  (SELECT COUNT(*) FROM class_sessions            WHERE course_id = @course_id) AS sessions,
  (SELECT COUNT(*) FROM student_subscription_courses WHERE course_id = @course_id) AS subscription_links,
  (SELECT COUNT(*) FROM payment_transactions      WHERE item_type = 'course' AND item_id = @course_id) AS transactions,
  (SELECT COUNT(*) FROM affiliate_commissions     WHERE item_type = 'course' AND item_id = @course_id) AS commissions,
  (SELECT COUNT(*) FROM item_country_prices       WHERE item_type = 'course' AND item_id = @course_id) AS country_prices;
