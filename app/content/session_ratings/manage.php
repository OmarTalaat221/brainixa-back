<?php
/**
 * Rating one live class, after it has happened.
 *
 * The platform already had `teacher_ratings` and `course_ratings`. Neither can answer the
 * question an academy actually asks after a class, because neither has a session in it: a
 * student rates their teacher once, and that single number has to stand for a whole term. It
 * cannot say that last Tuesday's class went badly while the rest went well, and it cannot be
 * averaged per week, per subject or per session.
 *
 * What is rated here is one OCCURRENCE - `class_sessions` is a weekly template, and the thing
 * that happened was Monday the 9th of it. The key is the same (session_id, occurrence_date) pair
 * the attendance tables use, so a rating and the attendance it belongs to line up exactly, and
 * "who rated the class they were actually in" is a join rather than a guess.
 *
 * Needs migration 125. Until it has run, every endpoint here answers politely with nothing rather
 * than failing, in the same way the rest of this codebase treats a column that is not there yet.
 */

require_once __DIR__ . '/../../../helpers/functions.php';
require_once __DIR__ . '/../../../helpers/language.php';
require_once __DIR__ . '/../../../helpers/entities.php';
require_once __DIR__ . '/../../../helpers/upload.php';
// app_text() lives here. Every file below calls it and most reached it only by luck, through
// whatever else their chain happened to pull in - session_ratings did not, and died with a
// PHP fatal that came back as an HTML page where the client expected JSON.
require_once __DIR__ . '/../../../helpers/app_settings.php';

if (!function_exists('session_ratings_table_exists')) {
    function session_ratings_table_exists($con): bool {
        static $cached = null;

        if ($cached !== null) {
            return $cached;
        }

        $res = @mysqli_query($con, "SHOW TABLES LIKE 'session_ratings'");

        return $cached = (bool)($res && mysqli_num_rows($res) > 0);
    }
}

if (!function_exists('session_ratings_not_ready')) {
    function session_ratings_not_ready($con): array {
        return [
            'status' => 'error',
            'message' => app_text(
                $con,
                'تقييم الحصص لسه مش مفعّل على السيرفر (محتاج migration 125).',
                'Session rating is not enabled on this server yet (migration 125 has not run).'
            ),
        ];
    }
}

if (!function_exists('session_rating_range')) {
    /** Same window convention as the attendance report: the last 30 days unless asked otherwise. */
    function session_rating_range(): array {
        $today = get_request_now();

        $from = trim($_GET['date_from'] ?? $_GET['from'] ?? '');
        $to = trim($_GET['date_to'] ?? $_GET['to'] ?? '');

        $fromDate = $from !== '' && strtotime($from)
            ? date('Y-m-d', strtotime($from))
            : (clone $today)->modify('-29 days')->format('Y-m-d');

        $toDate = $to !== '' && strtotime($to)
            ? date('Y-m-d', strtotime($to))
            : $today->format('Y-m-d');

        if ($fromDate > $toDate) {
            [$fromDate, $toDate] = [$toDate, $fromDate];
        }

        return [$fromDate, $toDate];
    }
}

/* =================================================================================================
   Student
================================================================================================= */

if (!function_exists('studentListRatableSessions')) {
    /**
     * The classes this student may still rate: ones they were marked present or late for, that
     * have already happened, and that they have not rated yet.
     *
     * Absences are excluded on purpose. A rating of a class nobody attended is not feedback about
     * the class, and letting it through would quietly turn the teacher's average into a measure of
     * who was annoyed at being marked absent.
     */
    function studentListRatableSessions($con, $studentData) {
        if (!session_ratings_table_exists($con)) {
            return build_paginated_response([], 1, 20, 0);
        }

        $studentId = (int)($studentData['id'] ?? 0);
        if ($studentId <= 0) {
            return ['status' => 'error', 'message' => trans('unauthorized')];
        }

        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 20)));
        $offset = ($page - 1) * $limit;
        $today = get_request_now()->format('Y-m-d');
        $langId = (int)(get_language_info($con)['id'] ?? 1);

        $countStmt = mysqli_prepare($con, "
            SELECT COUNT(*) AS total
            FROM session_attendance sa
            LEFT JOIN session_ratings sr
                   ON sr.session_id = sa.session_id
                  AND sr.occurrence_date = sa.session_date
                  AND sr.student_id = sa.student_id
            WHERE sa.student_id = ?
              AND sa.status <> 'absent'
              AND sa.session_date <= ?
              AND sr.id IS NULL
        ");

        $totalRecords = 0;
        if ($countStmt) {
            mysqli_stmt_bind_param($countStmt, "is", $studentId, $today);
            mysqli_stmt_execute($countStmt);
            $totalRecords = (int)(mysqli_fetch_assoc(mysqli_stmt_get_result($countStmt))['total'] ?? 0);
        }

        $stmt = mysqli_prepare($con, "
            SELECT
                sa.session_id,
                sa.session_date AS occurrence_date,
                cs.teacher_id,
                t.name AS teacher_name,
                t.image AS teacher_image,
                cs.start_time,
                cs.end_time,
                (SELECT stx.name FROM subjects_translations stx
                  WHERE stx.subject_id = cs.subject_id
                  ORDER BY (stx.language_id = {$langId}) DESC, stx.id ASC LIMIT 1) AS subject_name,
                (SELECT ctx.name FROM courses_translations ctx
                  WHERE ctx.course_id = cs.course_id
                  ORDER BY (ctx.language_id = {$langId}) DESC, ctx.id ASC LIMIT 1) AS course_name
            FROM session_attendance sa
            JOIN class_sessions cs ON cs.id = sa.session_id
            LEFT JOIN teachers t ON t.id = cs.teacher_id
            LEFT JOIN session_ratings sr
                   ON sr.session_id = sa.session_id
                  AND sr.occurrence_date = sa.session_date
                  AND sr.student_id = sa.student_id
            WHERE sa.student_id = ?
              AND sa.status <> 'absent'
              AND sa.session_date <= ?
              AND sr.id IS NULL
            ORDER BY sa.session_date DESC, sa.session_id DESC
            LIMIT ? OFFSET ?
        ");

        if (!$stmt) {
            return build_paginated_response([], $page, $limit, 0);
        }

        mysqli_stmt_bind_param($stmt, "isii", $studentId, $today, $limit, $offset);
        mysqli_stmt_execute($stmt);
        $res = mysqli_stmt_get_result($stmt);

        $items = [];
        while ($row = mysqli_fetch_assoc($res)) {
            $items[] = format_response_images([
                'session_id' => (int)$row['session_id'],
                'occurrence_date' => $row['occurrence_date'],
                'teacher_id' => $row['teacher_id'] ? (int)$row['teacher_id'] : null,
                'teacher_name' => $row['teacher_name'] ?? '',
                'image' => $row['teacher_image'] ?? null,
                'start_time' => $row['start_time'] ?? null,
                'end_time' => $row['end_time'] ?? null,
                'subject_name' => $row['subject_name'] ?? '',
                'course_name' => $row['course_name'] ?? '',
            ]);
        }

        return build_paginated_response($items, $page, $limit, $totalRecords);
    }
}

if (!function_exists('studentRateSession')) {
    /**
     * One rating per student per occurrence. Sending a second one edits the first rather than
     * adding a vote, which is what the unique key in migration 125 enforces underneath.
     */
    function studentRateSession($con, $studentData) {
        if (!session_ratings_table_exists($con)) {
            return session_ratings_not_ready($con);
        }

        $studentId = (int)($studentData['id'] ?? 0);
        if ($studentId <= 0) {
            return ['status' => 'error', 'message' => trans('unauthorized')];
        }

        $body = read_json_body();
        $sessionId = (int)($body['session_id'] ?? 0);
        $occurrenceDate = !empty($body['occurrence_date'] ?? $body['session_date'] ?? '')
            ? date('Y-m-d', strtotime($body['occurrence_date'] ?? $body['session_date']))
            : '';
        $rating = (int)($body['rating'] ?? 0);
        $comment = trim((string)($body['comment'] ?? ''));

        if ($sessionId <= 0 || $occurrenceDate === '') {
            return [
                'status' => 'error',
                'message' => app_text($con, 'محتاج الحصة وتاريخها.', 'Both the session and its date are required.'),
            ];
        }

        if ($rating < 1 || $rating > 5) {
            return [
                'status' => 'error',
                'message' => app_text($con, 'التقييم لازم يكون من 1 لـ 5.', 'The rating must be between 1 and 5.'),
            ];
        }

        // Rating a class you were not in is not feedback. The attendance row is the proof that
        // this student was there, and it is checked here rather than trusted from the request.
        $attendStmt = mysqli_prepare($con, "
            SELECT sa.id, cs.teacher_id
            FROM session_attendance sa
            JOIN class_sessions cs ON cs.id = sa.session_id
            WHERE sa.student_id = ? AND sa.session_id = ? AND sa.session_date = ? AND sa.status <> 'absent'
            LIMIT 1
        ");

        if (!$attendStmt) {
            return ['status' => 'error', 'message' => 'Database error'];
        }

        mysqli_stmt_bind_param($attendStmt, "iis", $studentId, $sessionId, $occurrenceDate);
        mysqli_stmt_execute($attendStmt);
        $attendance = mysqli_fetch_assoc(mysqli_stmt_get_result($attendStmt));

        if (!$attendance) {
            return [
                'status' => 'error',
                'message' => app_text(
                    $con,
                    'مينفعش تقيّم حصة مش مسجَّل إنك حضرتها.',
                    'You can only rate a class you are recorded as having attended.'
                ),
            ];
        }

        if ($occurrenceDate > get_request_now()->format('Y-m-d')) {
            return [
                'status' => 'error',
                'message' => app_text($con, 'الحصة دي لسه مجاتش.', 'That class has not happened yet.'),
            ];
        }

        $teacherId = (int)($attendance['teacher_id'] ?? 0);

        $stmt = mysqli_prepare($con, "
            INSERT INTO session_ratings (session_id, occurrence_date, student_id, teacher_id, rating, comment)
            VALUES (?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE rating = VALUES(rating), comment = VALUES(comment)
        ");

        if (!$stmt) {
            return ['status' => 'error', 'message' => 'Database error: ' . mysqli_error($con)];
        }

        mysqli_stmt_bind_param($stmt, "isiiis", $sessionId, $occurrenceDate, $studentId, $teacherId, $rating, $comment);

        if (!mysqli_stmt_execute($stmt)) {
            return ['status' => 'error', 'message' => 'Database error: ' . mysqli_stmt_error($stmt)];
        }

        return [
            'status' => 'success',
            'message' => app_text($con, 'تم تسجيل تقييمك للحصة.', 'Your rating for the class has been saved.'),
            'data' => [
                'session_id' => $sessionId,
                'occurrence_date' => $occurrenceDate,
                'rating' => $rating,
            ],
        ];
    }
}

/* =================================================================================================
   Reading the ratings back - admin and teacher
================================================================================================= */

if (!function_exists('session_ratings_list')) {
    /**
     * The ratings themselves, newest first. `$teacherScope` limits the list to one teacher, which
     * is how the teacher's own endpoint reuses this without being able to read anybody else's.
     */
    function session_ratings_list($con, ?int $teacherScope = null) {
        if (!session_ratings_table_exists($con)) {
            return build_paginated_response([], 1, 20, 0);
        }

        [$from, $to] = session_rating_range();
        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 20)));
        $offset = ($page - 1) * $limit;
        $langId = (int)(get_language_info($con)['id'] ?? 1);

        $where = "sr.occurrence_date BETWEEN ? AND ?";
        $types = "ss";
        $params = [$from, $to];

        $teacherId = $teacherScope ?? (isset($_GET['teacher_id']) ? (int)$_GET['teacher_id'] : 0);
        if ($teacherId > 0) {
            $where .= " AND sr.teacher_id = ?";
            $types .= "i";
            $params[] = $teacherId;
        }

        if (isset($_GET['rating']) && (int)$_GET['rating'] >= 1 && (int)$_GET['rating'] <= 5) {
            $where .= " AND sr.rating = ?";
            $types .= "i";
            $params[] = (int)$_GET['rating'];
        }

        // "Only the ones with something written in them" - the comments are the part worth
        // reading, and a screenful of bare 5s buries them.
        if (!empty($_GET['with_comment'])) {
            $where .= " AND sr.comment IS NOT NULL AND TRIM(sr.comment) <> ''";
        }

        $search = trim($_GET['search'] ?? $_GET['q'] ?? '');
        if ($search !== '') {
            $where .= " AND (t.name LIKE ? OR s.name LIKE ? OR sr.comment LIKE ?)";
            $types .= "sss";
            $pattern = '%' . $search . '%';
            $params[] = $pattern;
            $params[] = $pattern;
            $params[] = $pattern;
        }

        $countStmt = mysqli_prepare($con, "
            SELECT COUNT(*) AS total
            FROM session_ratings sr
            LEFT JOIN teachers t ON t.id = sr.teacher_id
            LEFT JOIN students s ON s.id = sr.student_id
            WHERE {$where}
        ");

        $totalRecords = 0;
        if ($countStmt) {
            mysqli_stmt_bind_param($countStmt, $types, ...$params);
            mysqli_stmt_execute($countStmt);
            $totalRecords = (int)(mysqli_fetch_assoc(mysqli_stmt_get_result($countStmt))['total'] ?? 0);
        }

        $stmt = mysqli_prepare($con, "
            SELECT
                sr.id, sr.session_id, sr.occurrence_date, sr.rating, sr.comment, sr.created_at,
                sr.teacher_id, t.name AS teacher_name,
                sr.student_id, s.name AS student_name,
                cs.start_time, cs.end_time,
                (SELECT stx.name FROM subjects_translations stx
                  WHERE stx.subject_id = cs.subject_id
                  ORDER BY (stx.language_id = {$langId}) DESC, stx.id ASC LIMIT 1) AS subject_name,
                (SELECT ctx.name FROM courses_translations ctx
                  WHERE ctx.course_id = cs.course_id
                  ORDER BY (ctx.language_id = {$langId}) DESC, ctx.id ASC LIMIT 1) AS course_name
            FROM session_ratings sr
            LEFT JOIN teachers t ON t.id = sr.teacher_id
            LEFT JOIN students s ON s.id = sr.student_id
            LEFT JOIN class_sessions cs ON cs.id = sr.session_id
            WHERE {$where}
            ORDER BY sr.occurrence_date DESC, sr.id DESC
            LIMIT ? OFFSET ?
        ");

        if (!$stmt) {
            return build_paginated_response([], $page, $limit, 0);
        }

        mysqli_stmt_bind_param($stmt, $types . "ii", ...array_merge($params, [$limit, $offset]));
        mysqli_stmt_execute($stmt);
        $res = mysqli_stmt_get_result($stmt);

        $items = [];
        while ($row = mysqli_fetch_assoc($res)) {
            $items[] = [
                'id' => (int)$row['id'],
                'session_id' => (int)$row['session_id'],
                'occurrence_date' => $row['occurrence_date'],
                'rating' => (int)$row['rating'],
                'comment' => $row['comment'] ?: '',
                'created_at' => $row['created_at'],
                'teacher_id' => $row['teacher_id'] ? (int)$row['teacher_id'] : null,
                'teacher_name' => $row['teacher_name'] ?? '',
                'student_id' => $row['student_id'] ? (int)$row['student_id'] : null,
                'student_name' => $row['student_name'] ?? '',
                'start_time' => $row['start_time'] ?? null,
                'end_time' => $row['end_time'] ?? null,
                'subject_name' => $row['subject_name'] ?? '',
                'course_name' => $row['course_name'] ?? '',
            ];
        }

        $response = build_paginated_response($items, $page, $limit, $totalRecords);
        $response['range'] = ['date_from' => $from, 'date_to' => $to];

        return $response;
    }
}

if (!function_exists('session_ratings_summary')) {
    /**
     * One row per teacher: their average over the window, how many classes were rated, and how
     * the stars fell. The distribution matters as much as the mean - a teacher averaging 4 from
     * all 4s is a different teacher from one averaging 4 from 5s and 2s.
     */
    function session_ratings_summary($con, ?int $teacherScope = null) {
        if (!session_ratings_table_exists($con)) {
            return ['status' => 'success', 'data' => ['overall' => null, 'teachers' => []]];
        }

        [$from, $to] = session_rating_range();

        $where = "sr.occurrence_date BETWEEN ? AND ?";
        $types = "ss";
        $params = [$from, $to];

        if ($teacherScope !== null && $teacherScope > 0) {
            $where .= " AND sr.teacher_id = ?";
            $types .= "i";
            $params[] = $teacherScope;
        }

        $overallStmt = mysqli_prepare($con, "
            SELECT COUNT(*) AS ratings, AVG(sr.rating) AS average,
                   COUNT(DISTINCT sr.session_id, sr.occurrence_date) AS sessions_rated
            FROM session_ratings sr
            WHERE {$where}
        ");

        $overall = null;
        if ($overallStmt) {
            mysqli_stmt_bind_param($overallStmt, $types, ...$params);
            mysqli_stmt_execute($overallStmt);
            $row = mysqli_fetch_assoc(mysqli_stmt_get_result($overallStmt)) ?: [];
            $overall = [
                'ratings' => (int)($row['ratings'] ?? 0),
                'sessions_rated' => (int)($row['sessions_rated'] ?? 0),
                'average' => $row['average'] !== null ? round((float)$row['average'], 2) : null,
            ];
        }

        $stmt = mysqli_prepare($con, "
            SELECT sr.teacher_id, t.name AS teacher_name,
                   COUNT(*) AS ratings,
                   AVG(sr.rating) AS average,
                   COUNT(DISTINCT sr.session_id, sr.occurrence_date) AS sessions_rated,
                   COALESCE(SUM(sr.rating = 5), 0) AS five,
                   COALESCE(SUM(sr.rating = 4), 0) AS four,
                   COALESCE(SUM(sr.rating = 3), 0) AS three,
                   COALESCE(SUM(sr.rating = 2), 0) AS two_count,
                   COALESCE(SUM(sr.rating = 1), 0) AS one_count
            FROM session_ratings sr
            LEFT JOIN teachers t ON t.id = sr.teacher_id
            WHERE {$where}
            GROUP BY sr.teacher_id, t.name
            ORDER BY average ASC, ratings DESC
        ");

        $teachers = [];
        if ($stmt) {
            mysqli_stmt_bind_param($stmt, $types, ...$params);
            mysqli_stmt_execute($stmt);
            $res = mysqli_stmt_get_result($stmt);

            while ($row = mysqli_fetch_assoc($res)) {
                $teachers[] = [
                    'teacher_id' => $row['teacher_id'] ? (int)$row['teacher_id'] : null,
                    'teacher_name' => $row['teacher_name'] ?? '',
                    'ratings' => (int)$row['ratings'],
                    'sessions_rated' => (int)$row['sessions_rated'],
                    'average' => $row['average'] !== null ? round((float)$row['average'], 2) : null,
                    'distribution' => [
                        '5' => (int)$row['five'],
                        '4' => (int)$row['four'],
                        '3' => (int)$row['three'],
                        '2' => (int)$row['two_count'],
                        '1' => (int)$row['one_count'],
                    ],
                ];
            }
        }

        return [
            'status' => 'success',
            'data' => [
                'range' => ['date_from' => $from, 'date_to' => $to],
                'overall' => $overall,
                'teachers' => $teachers,
            ],
        ];
    }
}

if (!function_exists('adminListSessionRatings')) {
    function adminListSessionRatings($con) {
        return session_ratings_list($con, null);
    }
}

if (!function_exists('adminSessionRatingsSummary')) {
    function adminSessionRatingsSummary($con) {
        return session_ratings_summary($con, null);
    }
}

if (!function_exists('teacherListSessionRatings')) {
    function teacherListSessionRatings($con, $teacherData) {
        return session_ratings_list($con, (int)($teacherData['id'] ?? 0));
    }
}

if (!function_exists('teacherSessionRatingsSummary')) {
    function teacherSessionRatingsSummary($con, $teacherData) {
        return session_ratings_summary($con, (int)($teacherData['id'] ?? 0));
    }
}
