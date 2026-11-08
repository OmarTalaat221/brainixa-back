<?php
require_once __DIR__ . '/../../../../helpers/functions.php';
require_once __DIR__ . '/../../../../helpers/language.php';
require_once __DIR__ . '/../../../../helpers/upload.php';
require_once __DIR__ . '/../../../../helpers/pricing.php';
require_once __DIR__ . '/../../../content/helpers.php';
require_once __DIR__ . '/../subscriptions/manage.php';
require_once __DIR__ . '/../../../teacher/sessions/manage.php'; // get_class_session_details / class_session_is_available_now
require_once __DIR__ . '/../../../teacher/consultations/manage.php'; // get_consultation_slot_details
require_once __DIR__ . '/../../../../helpers/availability.php'; // get_availability_slot_details

if (!function_exists('studentHome')) {
    function studentHome($con, $studentData = null) {
        $stId = 0;
        if (is_array($studentData)) {
            $stId = (int)($studentData['id'] ?? $studentData['student_id'] ?? 0);
        } elseif (is_object($studentData)) {
            $stId = (int)($studentData->id ?? $studentData->student_id ?? 0);
        }
        if ($stId <= 0) {
            $stId = (int)($_GET['student_id'] ?? 0);
        }

        $langInfo = get_language_info($con);
        $langId = (int)($langInfo['id'] ?? 1);

        $certCountRes = mysqli_query($con, "SELECT COUNT(*) AS total FROM student_certificates WHERE student_id = {$stId}");
        $certificatesCount = (int)(mysqli_fetch_assoc($certCountRes)['total'] ?? 0);

        $notifCount = 0;
        $unreadNotifCount = 0;
        $nRes = mysqli_query($con, "SELECT COUNT(*) AS total, SUM(CASE WHEN is_read = 0 THEN 1 ELSE 0 END) AS unread FROM notification_recipients WHERE user_type = 'student' AND user_id = {$stId}");
        if ($nRes && ($nRow = mysqli_fetch_assoc($nRes)) && $nRow['total'] > 0) {
            $notifCount = (int)($nRow['total'] ?? 0);
            $unreadNotifCount = (int)($nRow['unread'] ?? 0);
        } else {
            $checkNotifTable = mysqli_query($con, "SHOW TABLES LIKE 'student_notifications'");
            if ($checkNotifTable && mysqli_num_rows($checkNotifTable) > 0) {
                $nRes2 = mysqli_query($con, "SELECT COUNT(*) AS total, SUM(CASE WHEN is_read = 0 THEN 1 ELSE 0 END) AS unread FROM student_notifications WHERE student_id = {$stId}");
                if ($nRes2 && ($nRow2 = mysqli_fetch_assoc($nRes2))) {
                    $notifCount = (int)($nRow2['total'] ?? 0);
                    $unreadNotifCount = (int)($nRow2['unread'] ?? 0);
                }
            }
        }

        $banners = [];
        $bRes = mysqli_query($con, "SELECT id, title_ar, title_en, image_ar, image_en, link, type, created_at FROM banners WHERE is_active = 1 ORDER BY id DESC LIMIT 10");
        if ($bRes) {
            while ($bRow = mysqli_fetch_assoc($bRes)) {
                $bRow['id'] = (int)$bRow['id'];
                $bRow['title'] = ($langId == 2 && !empty($bRow['title_en'])) ? $bRow['title_en'] : $bRow['title_ar'];
                $bRow['image'] = ($langId == 2 && !empty($bRow['image_en'])) ? $bRow['image_en'] : $bRow['image_ar'];
                $bRow['target_url'] = $bRow['link'];
                $banners[] = format_response_images($bRow);
            }
        }

        $accessible = get_student_accessible_entities($con, $stId);
        $courseIds = $accessible['course_ids'];
        $subjectIds = $accessible['subject_ids'];
        $teacherIds = $accessible['teacher_ids'];

        
        $todaySessions = [];
        $now = get_request_now();
        $todayName = $now->format('l');
        $sessionWhere = ["is_active = 1", "day_of_week = '{$todayName}'"];

        $studentAcademicYearId = get_student_academic_year_id($con, $stId);

        // A session tied to a specific course (scope='course') must be gated on course access
        // alone - it used to also pass through on subject-wide access, which let a student with
        // a broad subject subscription see every teacher's weekly class in that subject, not
        // only the course they actually subscribed to. A session with no course (scope='subject',
        // a teacher's general class for the whole subject) still goes through subject access,
        // since that is exactly what a subject-level subscription is for.
        $subWhere = [];
        if (!empty($courseIds)) {
            $cList = implode(',', array_map('intval', $courseIds));
            $subWhere[] = "(course_id IS NOT NULL AND course_id IN ({$cList}))";
        }
        if (!empty($subjectIds)) {
            $sList = implode(',', array_map('intval', $subjectIds));
            $gradeCondition = $studentAcademicYearId
                ? "(academic_year_id IS NULL OR academic_year_id = " . (int)$studentAcademicYearId . ")"
                : "academic_year_id IS NULL";
            $subWhere[] = "(course_id IS NULL AND subject_id IN ({$sList}) AND {$gradeCondition})";
        }

        if (empty($subWhere)) {
            $sessRes = false;
        } else {
            $sessionWhere[] = "(" . implode(' OR ', $subWhere) . ")";
            $sessRes = mysqli_query($con, "SELECT id FROM class_sessions WHERE " . implode(' AND ', $sessionWhere) . " ORDER BY start_time ASC");
        }

        if ($sessRes) {
            while ($sessRow = mysqli_fetch_assoc($sessRes)) {
                $sessDetails = get_class_session_details($con, (int)$sessRow['id']);
                if ($sessDetails) {
                    $sessCourseId = (int)($sessDetails['course_id'] ?? 0);
                    $sessSubId = (int)($sessDetails['subject_id'] ?? 0);
                    $isSessSubscribed = (
                        ($sessCourseId > 0 && in_array($sessCourseId, $courseIds)) ||
                        ($sessSubId > 0 && in_array($sessSubId, $subjectIds))
                    );
                    $sessDetails['has_access'] = $isSessSubscribed;
                    $sessDetails['is_subscribed'] = $isSessSubscribed;
                    $sessDetails['is_locked'] = !$isSessSubscribed;
                    $sessDetails['is_open'] = $isSessSubscribed;
                    if (!$isSessSubscribed) {
                        $sessDetails['meeting_link'] = null;
                    }
                    $todaySessions[] = $sessDetails;
                }
            }
        }

        // ---- Upcoming consultations booked by this student (approved, from today onward) ----
        // Served under `upcoming_consultations`, NOT inside `today_sessions`.
        //
        // These used to be folded into `today_sessions` so the "next session" card would see them
        // without learning a second vocabulary. The cost was that one key answered three different
        // questions at once: a weekly class the student may or may not be subscribed to, a 1:1
        // consultation, and a package appointment - all wearing the same shape, told apart only by
        // a `scope` string a caller had to know to read. `today_sessions` now means today's
        // classes and nothing else.
        //
        // The rows are still normalized to the class_sessions shape, so a client that wants the
        // old combined list can concatenate the three keys and get exactly what it had before.
        $upcomingConsultations = [];
        $upcomingPackageSessions = [];

        $todayDateStr = $now->format('Y-m-d');
        $consultRes = @mysqli_query($con, "
            SELECT id FROM consultation_slots
            WHERE student_id = {$stId} AND is_booked = 1 AND status = 'approved'
              AND is_active = 1 AND slot_date >= '{$todayDateStr}'
            ORDER BY slot_date ASC, slot_time ASC
            LIMIT 5
        ");
        if ($consultRes) {
            while ($cRow = mysqli_fetch_assoc($consultRes)) {
                $slot = get_consultation_slot_details($con, (int)$cRow['id']);
                if (!$slot) continue;

                $isEndedConsult = !empty($slot['ended_at']);
                $isLiveConsult = !empty($slot['is_live']);

                $upcomingConsultations[] = [
                    'id' => $slot['id'],
                    'teacher_id' => $slot['teacher_id'],
                    'subject_id' => $slot['subject_id'],
                    'course_id' => null,
                    'course' => null,
                    'code' => null,
                    'scope' => 'consultation',
                    // Additive field, ignored by anything that does not know it yet: lets the
                    // card show "استشارة تربوية" instead of falling back to a bare subject name.
                    'type_label' => $slot['type_label'] ?? null,
                    'is_online' => 1,
                    'date' => $slot['slot_date'],
                    'session_date' => $slot['slot_date'],
                    'start_time' => $slot['slot_time'],
                    'end_time' => null,
                    'subject' => $slot['subject'],
                    'teacher' => $slot['teacher'],
                    'meeting_link' => $slot['meeting_link'],
                    'has_zoom' => $slot['has_zoom'] ?? false,
                    'zoom_is_live' => $slot['zoom_is_live'] ?? false,
                    'is_available_now' => $isLiveConsult ? 1 : 0,
                    // Translated into the same three words class_sessions uses, so the frontend's
                    // existing status filter keeps working without needing to know this came
                    // from a different table.
                    'status' => $isEndedConsult ? 'ended' : ($isLiveConsult ? 'started' : 'not_started'),
                    'is_started' => $isLiveConsult || $isEndedConsult ? 1 : 0,
                    'is_ended' => $isEndedConsult ? 1 : 0,
                    // Always this student's own confirmed booking - there is no "not subscribed"
                    // state for a consultation the way there is for a shared class.
                    'has_access' => true,
                    'is_subscribed' => true,
                    'is_locked' => false,
                    'is_open' => true,
                ];
            }
        }

        // ---- Upcoming package-session appointments booked by this student (مواعيد الباقات) ----
        // Served under `upcoming_package_sessions`, for the same reason as the consultations
        // above. Still normalized to the class_sessions shape, and still the thing the home's
        // "next session" card most often has to show: real live classes mostly do not run on the
        // generic weekly schedule any more, so a home that reads `today_sessions` alone will be
        // empty for a student whose next appointment is a package one.
        $availRes = @mysqli_query($con, "
            SELECT sb.slot_id FROM availability_slot_bookings sb
            INNER JOIN teacher_availability_slots s ON s.id = sb.slot_id
            WHERE sb.student_id = {$stId} AND sb.status = 'booked'
              AND s.slot_date >= '{$todayDateStr}'
            ORDER BY s.slot_date ASC, s.start_time ASC
            LIMIT 5
        ");
        if ($availRes) {
            while ($aRow = mysqli_fetch_assoc($availRes)) {
                $slot = get_availability_slot_details($con, (int)$aRow['slot_id'], false);
                if (!$slot) continue;

                $isEndedSlot = !empty($slot['ended_at']);
                $isLiveSlot = !empty($slot['is_live']);

                $upcomingPackageSessions[] = [
                    'id' => $slot['id'],
                    'teacher_id' => $slot['teacher_id'],
                    'subject_id' => $slot['subject_id'],
                    'course_id' => $slot['course_id'],
                    'course' => $slot['course'],
                    'code' => $slot['course']['slug'] ?? null,
                    'scope' => 'package',
                    'is_online' => $slot['is_online'],
                    'date' => $slot['slot_date'],
                    'session_date' => $slot['slot_date'],
                    'start_time' => $slot['start_time'],
                    'end_time' => $slot['end_time'],
                    'subject' => $slot['subject'],
                    'teacher' => $slot['teacher'],
                    'meeting_link' => $slot['meeting_link'],
                    // Additive: lets the frontend open the embedded Zoom room instead of a bare
                    // link, and tells a room that was opened once but already ended apart from
                    // one that is actually open right now - same fields the availability and
                    // consultation endpoints already expose.
                    'has_zoom' => $slot['has_zoom'],
                    'zoom_is_live' => $slot['zoom_is_live'],
                    'is_available_now' => $isLiveSlot ? 1 : 0,
                    'status' => $isEndedSlot ? 'ended' : ($isLiveSlot ? 'started' : 'not_started'),
                    'is_started' => $isLiveSlot || $isEndedSlot ? 1 : 0,
                    'is_ended' => $isEndedSlot ? 1 : 0,
                    // Always this student's own confirmed booking - there is no "not subscribed"
                    // state for a package appointment the way there is for a shared class.
                    'has_access' => true,
                    'is_subscribed' => true,
                    'is_locked' => false,
                    'is_open' => true,
                ];
            }
        }

        $booksCount = 0;
        if (!empty($courseIds) || !empty($subjectIds) || !empty($teacherIds)) {
            $orConds = [];
            if (!empty($courseIds)) {
                $cList = implode(',', array_map('intval', $courseIds));
                $orConds[] = "b.course_id IN ({$cList})";
            }
            if (!empty($subjectIds)) {
                $sList = implode(',', array_map('intval', $subjectIds));
                $orConds[] = "b.subject_id IN ({$sList})";
            }
            if (!empty($teacherIds)) {
                $tList = implode(',', array_map('intval', $teacherIds));
                $orConds[] = "(b.created_by_type = 'teacher' AND b.created_by_id IN ({$tList}))";
                $orConds[] = "b.id IN (SELECT book_id FROM book_teachers WHERE teacher_id IN ({$tList}) AND is_active = 1)";
            }
            $subClause = "(" . implode(" OR ", $orConds) . ")";
            $bkRes = mysqli_query($con, "SELECT COUNT(DISTINCT b.id) AS total FROM course_books b WHERE b.is_active = 1 AND {$subClause}");
            if ($bkRes) {
                $booksCount = (int)(mysqli_fetch_assoc($bkRes)['total'] ?? 0);
            }
        }

        $allCourses = [];
        $subscribedCourses = [];
        $totalProgressSum = 0;
        $totalCoursesWithLessons = 0;

        $body = read_json_body();
        $typeFilter = strtolower(trim($_GET['type'] ?? $_GET['course_type'] ?? $_GET['type_id'] ?? $body['type'] ?? $body['course_type'] ?? ''));
        $typeCondition = "";
        if (!empty($typeFilter)) {
            $tp = mysqli_real_escape_string($con, $typeFilter);
            $typeCondition = " AND c.type = '{$tp}'";
        }

        $sql = "
            SELECT c.id, c.subject_id, c.academic_year_id, c.teacher_id, c.slug, c.type, c.kind, c.price, c.image, c.is_active, c.created_at,
                   COALESCE(ct.name, c.slug) AS name, ct.description
            FROM courses c
            LEFT JOIN courses_translations ct ON c.id = ct.course_id AND ct.language_id = {$langId}
            WHERE c.is_active = 1 {$typeCondition}
            ORDER BY c.order_num ASC, c.id DESC
        ";
        $res = mysqli_query($con, $sql);
        if ($res) {
            while ($row = mysqli_fetch_assoc($res)) {
                $cId = (int)$row['id'];
                $row['id'] = $cId;
                $row['type'] = $row['type'] ?? 'recorded';
                $row['price'] = (float)$row['price'];

                $isOwn = in_array($cId, $courseIds);
                $row['own'] = $isOwn;
                $row['is_subscribed'] = $isOwn;
                $row['is_locked'] = !$isOwn;
                $row['is_open'] = $isOwn;

                if ($isOwn) {
                    $stats = get_student_course_progress_stats($con, $stId, $cId);
                    $progressPct = $stats['progress_percentage'];
                    $row['total_lessons_count'] = $stats['total_lessons_count'];
                    $row['units_count'] = $stats['units_count'];
                    $row['completed_lessons_count'] = $stats['completed_lessons_count'];
                    $row['progress_percentage'] = $progressPct;

                    if ($stats['total_lessons_count'] > 0) {
                        $totalProgressSum += $progressPct;
                        $totalCoursesWithLessons++;
                    }

                    $subscribedCourses[] = format_response_images($row);
                } else {
                    $stats = get_student_course_progress_stats($con, 0, $cId);
                    $row['total_lessons_count'] = $stats['total_lessons_count'];
                    $row['units_count'] = $stats['units_count'];
                    $row['completed_lessons_count'] = 0;
                    $row['progress_percentage'] = 0.00;
                }

                $allCourses[] = format_response_images($row);
            }
        }

        // Both lists, because the landing page shows a price on the ones the student does not own
        // yet and those are exactly the ones a country price is for.
        pricing_decorate_rows($con, $subscribedCourses, 'course', $stId);
        pricing_decorate_rows($con, $allCourses, 'course', $stId);

        // Counts the courses actually listed below it, not raw subscription rows - a student can
        // hold several active subscriptions (course/subject/package/teacher) that, once resolved,
        // point at the same course, an inactive one, or none at all. Counting the rows directly
        // produced a number with no relationship to what the page shows under it.
        $subscriptionsCount = count($subscribedCourses);

        $overallProgress = $totalCoursesWithLessons > 0 ? round($totalProgressSum / $totalCoursesWithLessons, 2) : 0.00;

        return [
            'status' => 'success',
            'data' => [
                'overall_progress' => $overallProgress,
                'subscriptions_count' => $subscriptionsCount,
                'certificates_count' => $certificatesCount,
                'books_count' => $booksCount,
                'notifications_count' => $notifCount,
                'unread_notifications_count' => $unreadNotifCount,
                // Today's weekly classes, and only those. The student's booked consultations and
                // package appointments are their own keys below rather than being mixed in here.
                'today_sessions' => $todaySessions,
                'upcoming_consultations' => $upcomingConsultations,
                'upcoming_package_sessions' => $upcomingPackageSessions,
                'banners' => $banners,
                'subscribed_courses' => $subscribedCourses,
                'all_courses' => $allCourses
            ]
        ];
    }
}
