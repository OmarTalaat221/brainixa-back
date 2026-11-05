<?php
/**
 * Attendance, read back as a report.
 *
 * Every live class has been writing attendance for a long time - `session_attendance` for the
 * students, `teacher_session_attendance` for the teacher, the second of which also drives the
 * earnings and the deductions in the wallet. None of it could be read from the admin side. The
 * only attendance endpoint an admin had was the list of EXCEPTION requests: the excuses, not the
 * attendance. A teacher could see their own sessions and a parent could see their own child, and
 * nobody could see the school.
 *
 * Nothing here records anything. It reads what the classes already wrote, which is why it needed
 * no migration and no change to how attendance is taken.
 *
 * The figures are taken from the attendance rows themselves rather than from the weekly
 * `class_sessions` template. The template says a class is meant to happen on Mondays; the rows
 * say what actually happened, which is the only thing a report should be willing to state.
 */

require_once __DIR__ . '/../../../helpers/functions.php';
require_once __DIR__ . '/../../../helpers/language.php';
require_once __DIR__ . '/../../../helpers/entities.php';
require_once __DIR__ . '/../export/export.php';

if (!function_exists('attendance_report_range')) {
    /**
     * The window being reported on. Defaults to the last 30 days including today, because an
     * unbounded attendance report over a platform's whole life answers nobody's question and
     * scans every row to do it.
     */
    function attendance_report_range(): array {
        $today = get_request_now();

        $from = trim($_GET['date_from'] ?? $_GET['from'] ?? '');
        $to = trim($_GET['date_to'] ?? $_GET['to'] ?? '');

        $fromDate = $from !== '' && strtotime($from)
            ? date('Y-m-d', strtotime($from))
            : (clone $today)->modify('-29 days')->format('Y-m-d');

        $toDate = $to !== '' && strtotime($to)
            ? date('Y-m-d', strtotime($to))
            : $today->format('Y-m-d');

        // A range entered backwards is a slip, not a request for nothing.
        if ($fromDate > $toDate) {
            [$fromDate, $toDate] = [$toDate, $fromDate];
        }

        return [$fromDate, $toDate];
    }
}

if (!function_exists('attendance_rate')) {
    /** Present and late both count as turning up. Only an absence is not attendance. */
    function attendance_rate(int $present, int $late, int $total): float {
        return $total > 0 ? round((($present + $late) / $total) * 100, 1) : 0.0;
    }
}

if (!function_exists('attendance_status_counts')) {
    /**
     * The same four counters for either table, which differ only in the name of their date
     * column - `session_date` for students, `occurrence_date` for teachers.
     */
    function attendance_status_counts($con, string $table, string $dateColumn, string $from, string $to): array {
        $sql = "SELECT
                    COUNT(*) AS total,
                    COALESCE(SUM(status = 'present'), 0) AS present,
                    COALESCE(SUM(status = 'late'), 0) AS late_count,
                    COALESCE(SUM(status = 'absent'), 0) AS absent,
                    COALESCE(SUM(status = 'absent' AND is_excused = 1), 0) AS excused_absent,
                    COALESCE(SUM(minutes_late), 0) AS minutes_late
                FROM `{$table}`
                WHERE `{$dateColumn}` BETWEEN ? AND ?";

        $stmt = mysqli_prepare($con, $sql);
        if (!$stmt) {
            return ['total' => 0, 'present' => 0, 'late' => 0, 'absent' => 0, 'excused_absent' => 0, 'minutes_late' => 0, 'attendance_rate' => 0.0];
        }

        mysqli_stmt_bind_param($stmt, "ss", $from, $to);
        mysqli_stmt_execute($stmt);
        $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt)) ?: [];

        $present = (int)($row['present'] ?? 0);
        $late = (int)($row['late_count'] ?? 0);
        $total = (int)($row['total'] ?? 0);

        return [
            'total' => $total,
            'present' => $present,
            'late' => $late,
            'absent' => (int)($row['absent'] ?? 0),
            'excused_absent' => (int)($row['excused_absent'] ?? 0),
            'minutes_late' => (int)($row['minutes_late'] ?? 0),
            'attendance_rate' => attendance_rate($present, $late, $total),
        ];
    }
}

if (!function_exists('adminAttendanceReportOverview')) {
    /**
     * The two sides of the same classes, side by side.
     *
     * A school where the students turn up and the teachers do not has a different problem from
     * one where it is the other way round, and a single blended "attendance rate" hides which it
     * is - so the two are never added together here.
     */
    function adminAttendanceReportOverview($con) {
        [$from, $to] = attendance_report_range();

        $students = attendance_status_counts($con, 'session_attendance', 'session_date', $from, $to);
        $teachers = attendance_status_counts($con, 'teacher_session_attendance', 'occurrence_date', $from, $to);

        // An "occurrence" is one class on one day. Counted across both tables because a class
        // where only the teacher was marked still happened.
        $occurrenceStmt = mysqli_prepare($con, "
            SELECT COUNT(*) AS held FROM (
                SELECT session_id, session_date AS day FROM session_attendance WHERE session_date BETWEEN ? AND ?
                UNION
                SELECT session_id, occurrence_date AS day FROM teacher_session_attendance WHERE occurrence_date BETWEEN ? AND ?
            ) AS occurrences
        ");

        $held = 0;
        if ($occurrenceStmt) {
            mysqli_stmt_bind_param($occurrenceStmt, "ssss", $from, $to, $from, $to);
            mysqli_stmt_execute($occurrenceStmt);
            $held = (int)(mysqli_fetch_assoc(mysqli_stmt_get_result($occurrenceStmt))['held'] ?? 0);
        }

        $distinct = function (string $table, string $dateColumn, string $idColumn) use ($con, $from, $to) {
            $stmt = mysqli_prepare($con, "SELECT COUNT(DISTINCT `{$idColumn}`) AS c FROM `{$table}` WHERE `{$dateColumn}` BETWEEN ? AND ?");
            if (!$stmt) return 0;
            mysqli_stmt_bind_param($stmt, "ss", $from, $to);
            mysqli_stmt_execute($stmt);
            return (int)(mysqli_fetch_assoc(mysqli_stmt_get_result($stmt))['c'] ?? 0);
        };

        return [
            'status' => 'success',
            'data' => [
                'range' => ['date_from' => $from, 'date_to' => $to],
                'sessions_held' => $held,
                'students' => $students + ['people' => $distinct('session_attendance', 'session_date', 'student_id')],
                'teachers' => $teachers + ['people' => $distinct('teacher_session_attendance', 'occurrence_date', 'teacher_id')],
            ],
        ];
    }
}

if (!function_exists('attendance_people_report')) {
    /**
     * One row per person, for either side. Students and teachers differ in three names - the
     * table, its date column and the people table it joins - and in nothing else, so they share
     * this rather than being written out twice and drifting apart.
     */
    function attendance_people_report($con, string $side) {
        [$from, $to] = attendance_report_range();

        $isTeacher = $side === 'teacher';
        $table = $isTeacher ? 'teacher_session_attendance' : 'session_attendance';
        $dateColumn = $isTeacher ? 'occurrence_date' : 'session_date';
        $idColumn = $isTeacher ? 'teacher_id' : 'student_id';
        $peopleTable = $isTeacher ? 'teachers' : 'students';

        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 20)));
        $offset = ($page - 1) * $limit;
        $search = trim($_GET['search'] ?? $_GET['q'] ?? '');

        $where = "a.`{$dateColumn}` BETWEEN ? AND ?";
        $types = "ss";
        $params = [$from, $to];

        if ($search !== '') {
            $where .= " AND p.name LIKE ?";
            $types .= "s";
            $params[] = '%' . $search . '%';
        }

        $countStmt = mysqli_prepare($con, "
            SELECT COUNT(DISTINCT a.`{$idColumn}`) AS total
            FROM `{$table}` a
            JOIN `{$peopleTable}` p ON p.id = a.`{$idColumn}`
            WHERE {$where}
        ");

        $totalRecords = 0;
        if ($countStmt) {
            mysqli_stmt_bind_param($countStmt, $types, ...$params);
            mysqli_stmt_execute($countStmt);
            $totalRecords = (int)(mysqli_fetch_assoc(mysqli_stmt_get_result($countStmt))['total'] ?? 0);
        }

        // Ordered by absences first: a report whose job is to show who is missing classes should
        // open on the people who are missing them, not on whoever happens to have the lowest id.
        $earningColumn = $isTeacher ? ", COALESCE(SUM(a.earning_amount), 0) AS earnings" : "";

        $sql = "SELECT
                    a.`{$idColumn}` AS person_id,
                    p.name AS person_name,
                    COUNT(*) AS total,
                    COALESCE(SUM(a.status = 'present'), 0) AS present,
                    COALESCE(SUM(a.status = 'late'), 0) AS late_count,
                    COALESCE(SUM(a.status = 'absent'), 0) AS absent,
                    COALESCE(SUM(a.status = 'absent' AND a.is_excused = 1), 0) AS excused_absent,
                    COALESCE(SUM(a.minutes_late), 0) AS minutes_late
                    {$earningColumn}
                FROM `{$table}` a
                JOIN `{$peopleTable}` p ON p.id = a.`{$idColumn}`
                WHERE {$where}
                GROUP BY a.`{$idColumn}`, p.name
                ORDER BY absent DESC, late_count DESC, p.name ASC
                LIMIT ? OFFSET ?";

        $stmt = mysqli_prepare($con, $sql);
        if (!$stmt) {
            return build_paginated_response([], $page, $limit, 0);
        }

        mysqli_stmt_bind_param($stmt, $types . "ii", ...array_merge($params, [$limit, $offset]));
        mysqli_stmt_execute($stmt);
        $res = mysqli_stmt_get_result($stmt);

        $items = [];
        while ($row = mysqli_fetch_assoc($res)) {
            $present = (int)$row['present'];
            $late = (int)$row['late_count'];
            $total = (int)$row['total'];

            $item = [
                'id' => (int)$row['person_id'],
                'name' => $row['person_name'],
                'total' => $total,
                'present' => $present,
                'late' => $late,
                'absent' => (int)$row['absent'],
                'excused_absent' => (int)$row['excused_absent'],
                'unexcused_absent' => (int)$row['absent'] - (int)$row['excused_absent'],
                'minutes_late' => (int)$row['minutes_late'],
                'attendance_rate' => attendance_rate($present, $late, $total),
            ];

            if ($isTeacher) {
                $item['earnings'] = round((float)($row['earnings'] ?? 0), 2);
            }

            $items[] = $item;
        }

        $response = build_paginated_response($items, $page, $limit, $totalRecords);
        $response['range'] = ['date_from' => $from, 'date_to' => $to];

        return $response;
    }
}

if (!function_exists('adminAttendanceReportStudents')) {
    function adminAttendanceReportStudents($con) {
        return attendance_people_report($con, 'student');
    }
}

if (!function_exists('adminAttendanceReportTeachers')) {
    function adminAttendanceReportTeachers($con) {
        return attendance_people_report($con, 'teacher');
    }
}

if (!function_exists('attendance_sessions_rows')) {
    /**
     * One row per class that happened: the day, who taught it, how many of its students turned
     * up, and whether the teacher did.
     *
     * The list of occurrences is the UNION of the two tables rather than either one of them. A
     * class where the teacher was marked and no student was still happened, and so did one where
     * the students were marked and the teacher's row never landed - and a report that quietly
     * dropped either would be understating the term.
     */
    function attendance_sessions_rows($con, string $from, string $to, int $limit = 0, int $offset = 0): array {
        $limitSql = $limit > 0 ? "LIMIT {$limit} OFFSET {$offset}" : "";

        // The names live in translation tables. Read as correlated subqueries rather than by
        // calling get_subject_details() per row: a page of twenty classes would otherwise be
        // forty extra round trips, and an export of a term would be thousands.
        $langId = (int)(get_language_info($con)['id'] ?? 1);

        $sql = "SELECT
                    o.session_id,
                    o.day AS occurrence_date,
                    cs.teacher_id,
                    t.name AS teacher_name,
                    cs.start_time,
                    cs.end_time,
                    cs.room,
                    cs.is_online,
                    (SELECT stx.name FROM subjects_translations stx
                      WHERE stx.subject_id = cs.subject_id
                      ORDER BY (stx.language_id = {$langId}) DESC, stx.id ASC LIMIT 1) AS subject_name,
                    (SELECT ctx.name FROM courses_translations ctx
                      WHERE ctx.course_id = cs.course_id
                      ORDER BY (ctx.language_id = {$langId}) DESC, ctx.id ASC LIMIT 1) AS course_name,
                    COALESCE(st.total, 0) AS students_marked,
                    COALESCE(st.present, 0) AS students_present,
                    COALESCE(st.late_count, 0) AS students_late,
                    COALESCE(st.absent, 0) AS students_absent,
                    ta.status AS teacher_status,
                    ta.minutes_late AS teacher_minutes_late,
                    ta.is_excused AS teacher_is_excused
                FROM (
                    SELECT session_id, session_date AS day FROM session_attendance WHERE session_date BETWEEN ? AND ?
                    UNION
                    SELECT session_id, occurrence_date AS day FROM teacher_session_attendance WHERE occurrence_date BETWEEN ? AND ?
                ) o
                LEFT JOIN class_sessions cs ON cs.id = o.session_id
                LEFT JOIN teachers t ON t.id = cs.teacher_id
                LEFT JOIN (
                    SELECT session_id, session_date,
                           COUNT(*) AS total,
                           COALESCE(SUM(status = 'present'), 0) AS present,
                           COALESCE(SUM(status = 'late'), 0) AS late_count,
                           COALESCE(SUM(status = 'absent'), 0) AS absent
                    FROM session_attendance
                    WHERE session_date BETWEEN ? AND ?
                    GROUP BY session_id, session_date
                ) st ON st.session_id = o.session_id AND st.session_date = o.day
                LEFT JOIN teacher_session_attendance ta
                       ON ta.session_id = o.session_id AND ta.occurrence_date = o.day
                ORDER BY o.day DESC, o.session_id DESC
                {$limitSql}";

        $stmt = mysqli_prepare($con, $sql);
        if (!$stmt) return [];

        mysqli_stmt_bind_param($stmt, "ssssss", $from, $to, $from, $to, $from, $to);
        mysqli_stmt_execute($stmt);
        $res = mysqli_stmt_get_result($stmt);

        $rows = [];
        while ($row = mysqli_fetch_assoc($res)) {
            $marked = (int)$row['students_marked'];
            $present = (int)$row['students_present'];
            $late = (int)$row['students_late'];

            $rows[] = [
                'session_id' => (int)$row['session_id'],
                'occurrence_date' => $row['occurrence_date'],
                'teacher_id' => $row['teacher_id'] ? (int)$row['teacher_id'] : null,
                'teacher_name' => $row['teacher_name'] ?? '',
                'start_time' => $row['start_time'] ?? null,
                'end_time' => $row['end_time'] ?? null,
                'room' => $row['room'] ?? null,
                'is_online' => (int)($row['is_online'] ?? 0),
                'subject_name' => $row['subject_name'] ?? '',
                'course_name' => $row['course_name'] ?? '',
                'students_marked' => $marked,
                'students_present' => $present,
                'students_late' => $late,
                'students_absent' => (int)$row['students_absent'],
                'students_attendance_rate' => attendance_rate($present, $late, $marked),
                // Null rather than 'absent' when the teacher has no row at all: not recorded is
                // not the same as recorded absent, and only one of the two costs them money.
                'teacher_status' => $row['teacher_status'] ?? null,
                'teacher_minutes_late' => (int)($row['teacher_minutes_late'] ?? 0),
                'teacher_is_excused' => (int)($row['teacher_is_excused'] ?? 0),
            ];
        }

        return $rows;
    }
}

if (!function_exists('adminAttendanceReportSessions')) {
    function adminAttendanceReportSessions($con) {
        [$from, $to] = attendance_report_range();

        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 20)));
        $offset = ($page - 1) * $limit;

        $countStmt = mysqli_prepare($con, "
            SELECT COUNT(*) AS total FROM (
                SELECT session_id, session_date AS day FROM session_attendance WHERE session_date BETWEEN ? AND ?
                UNION
                SELECT session_id, occurrence_date AS day FROM teacher_session_attendance WHERE occurrence_date BETWEEN ? AND ?
            ) o
        ");

        $totalRecords = 0;
        if ($countStmt) {
            mysqli_stmt_bind_param($countStmt, "ssss", $from, $to, $from, $to);
            mysqli_stmt_execute($countStmt);
            $totalRecords = (int)(mysqli_fetch_assoc(mysqli_stmt_get_result($countStmt))['total'] ?? 0);
        }

        $response = build_paginated_response(
            attendance_sessions_rows($con, $from, $to, $limit, $offset),
            $page,
            $limit,
            $totalRecords
        );
        $response['range'] = ['date_from' => $from, 'date_to' => $to];

        return $response;
    }
}

if (!function_exists('adminExportAttendanceReport')) {
    /**
     * The same three reports as a spreadsheet, over the same range the screen is filtered to.
     */
    function adminExportAttendanceReport($con) {
        $lang = get_request_lang($con);
        [$from, $to] = attendance_report_range();
        $type = strtolower(trim($_GET['type'] ?? 'students'));

        if ($type === 'sessions') {
            $header = $lang === 'ar'
                ? ['التاريخ', 'المعلم', 'المادة', 'الكورس', 'من', 'إلى', 'طلاب مسجّلون', 'حاضر', 'متأخر', 'غائب', 'نسبة حضور الطلاب %', 'حالة المعلم', 'تأخير المعلم (دقيقة)']
                : ['Date', 'Teacher', 'Subject', 'Course', 'From', 'To', 'Students marked', 'Present', 'Late', 'Absent', 'Student attendance %', 'Teacher status', 'Teacher minutes late'];

            $rows = [];
            foreach (attendance_sessions_rows($con, $from, $to) as $row) {
                $rows[] = [
                    $row['occurrence_date'],
                    $row['teacher_name'],
                    $row['subject_name'],
                    $row['course_name'],
                    $row['start_time'],
                    $row['end_time'],
                    $row['students_marked'],
                    $row['students_present'],
                    $row['students_late'],
                    $row['students_absent'],
                    $row['students_attendance_rate'],
                    $row['teacher_status'] ?? ($lang === 'ar' ? 'غير مسجَّل' : 'Not recorded'),
                    $row['teacher_minutes_late'],
                ];
            }

            sendExcelExport($header, $rows, $lang === 'ar' ? 'حضور الحصص' : 'Session attendance', $lang, 'attendance_sessions');
            return;
        }

        $isTeacher = $type === 'teachers';

        // The export is the whole filtered range, not the page being looked at, so the limit is
        // lifted for it - but only here.
        $_GET['limit'] = 100;
        $_GET['page'] = 1;

        $header = $lang === 'ar'
            ? ['المعرف', $isTeacher ? 'المعلم' : 'الطالب', 'إجمالي الحصص', 'حاضر', 'متأخر', 'غائب', 'غياب بعذر', 'غياب بدون عذر', 'دقائق التأخير', 'نسبة الحضور %']
            : ['ID', $isTeacher ? 'Teacher' : 'Student', 'Sessions', 'Present', 'Late', 'Absent', 'Excused absence', 'Unexcused absence', 'Minutes late', 'Attendance %'];

        if ($isTeacher) {
            $header[] = $lang === 'ar' ? 'الأرباح' : 'Earnings';
        }

        $rows = [];
        $page = 1;

        // Paged through rather than pulled in one query: the report groups by person, and a
        // school with thousands of them should not need one enormous result set to export.
        do {
            $_GET['page'] = $page;
            $chunk = attendance_people_report($con, $isTeacher ? 'teacher' : 'student');
            $items = $chunk['data'] ?? [];

            foreach ($items as $row) {
                $line = [
                    $row['id'],
                    $row['name'],
                    $row['total'],
                    $row['present'],
                    $row['late'],
                    $row['absent'],
                    $row['excused_absent'],
                    $row['unexcused_absent'],
                    $row['minutes_late'],
                    $row['attendance_rate'],
                ];

                if ($isTeacher) {
                    $line[] = $row['earnings'] ?? 0;
                }

                $rows[] = $line;
            }

            $page++;
        } while (count($items) === 100 && $page <= 200);

        sendExcelExport(
            $header,
            $rows,
            $lang === 'ar' ? ($isTeacher ? 'حضور المعلمين' : 'حضور الطلاب') : ($isTeacher ? 'Teacher attendance' : 'Student attendance'),
            $lang,
            $isTeacher ? 'attendance_teachers' : 'attendance_students'
        );
    }
}
