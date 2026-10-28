<?php

/**
 * Live classes over Zoom, played inside Brainixa.
 *
 * Nobody here is ever handed a zoom.us link. A teacher asks to start their class and gets back
 * the meeting number plus a signature that says "you are the host"; a student asks to join and
 * gets the same meeting number with a signature that says "you are an attendee". The Meeting SDK
 * in the browser turns that into the class, embedded in the page.
 *
 * The entitlement check is the point of this file. Zoom has no idea who paid for what, so the
 * decision of who may join is made here, from the subscription tables, and only then is a
 * signature minted. A student who is not subscribed never receives one, and a signature is good
 * for exactly one meeting.
 */

require_once __DIR__ . '/../../helpers/functions.php';
require_once __DIR__ . '/../../helpers/zoom.php';
require_once __DIR__ . '/../../helpers/entities.php';

if (!function_exists('zoom_session_row')) {
    function zoom_session_row($con, int $sessionId): ?array {
        $stmt = mysqli_prepare($con, "SELECT id, teacher_id, course_id, subject_id, start_time, end_time, is_online FROM class_sessions WHERE id = ? LIMIT 1");
        if (!$stmt) return null;
        mysqli_stmt_bind_param($stmt, "i", $sessionId);
        mysqli_stmt_execute($stmt);
        $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));
        return $row ?: null;
    }
}

if (!function_exists('zoom_session_duration_minutes')) {
    function zoom_session_duration_minutes(array $session): int {
        $start = strtotime($session['start_time'] ?? '00:00:00');
        $end   = strtotime($session['end_time'] ?? '00:00:00');
        $mins  = (int)round(($end - $start) / 60);
        // A session whose end time is before its start crosses midnight, or is simply wrong.
        // Either way an hour is a safer default than a negative duration Zoom would reject.
        return ($mins > 0 && $mins <= 1440) ? $mins : 60;
    }
}

if (!function_exists('zoom_live_meeting_for')) {
    /** The meeting for today's run of this class, if one is open. */
    function zoom_live_meeting_for($con, int $sessionId, string $date): ?array {
        $dateEsc = mysqli_real_escape_string($con, $date);
        $res = @mysqli_query($con, "SELECT * FROM session_zoom_meetings WHERE session_id = {$sessionId} AND session_date = '{$dateEsc}' LIMIT 1");
        $row = $res ? mysqli_fetch_assoc($res) : null;
        return $row ?: null;
    }
}

if (!function_exists('teacherStartZoomClass')) {
    /**
     * Opens — or re-opens — the Zoom room for today's run of this class.
     *
     * Pressing start twice must not create two rooms with half the class in each, so the
     * occurrence is looked up first and an existing live meeting is returned as-is. Only the
     * signature and ZAK are minted fresh each time, because both are short-lived by design.
     */
    function teacherStartZoomClass($con, $teacherData = null) {
        if (!zoom_is_configured()) return zoom_not_configured_error();

        $teacherId = (int)($teacherData['id'] ?? $teacherData['teacher_id'] ?? 0);
        if ($teacherId <= 0) {
            return ['status' => 'error', 'message' => 'Teacher authentication is required'];
        }

        $body = read_json_body();
        $sessionId = (int)($body['session_id'] ?? $body['id'] ?? $_GET['session_id'] ?? 0);
        if ($sessionId <= 0) {
            return ['status' => 'error', 'message' => 'session_id is required'];
        }

        $session = zoom_session_row($con, $sessionId);
        if (!$session) {
            return ['status' => 'error', 'message' => 'Session not found'];
        }
        if ((int)$session['teacher_id'] !== $teacherId) {
            return ['status' => 'error', 'message' => 'This session does not belong to you'];
        }

        $today = get_request_now()->format('Y-m-d');
        $existing = zoom_live_meeting_for($con, $sessionId, $today);

        if ($existing && $existing['status'] === 'live') {
            $meetingId = $existing['meeting_id'];
            $password  = $existing['password'];
        } else {
            $topic = 'Brainixa - حصة رقم ' . $sessionId;
            $created = zoom_create_meeting($con, $topic, zoom_session_duration_minutes($session));
            if (!$created['ok']) {
                return [
                    'status' => 'error',
                    'message' => 'تعذر فتح غرفة Zoom: ' . ($created['error'] ?? 'سبب غير معروف'),
                ];
            }

            $meetingId = (string)($created['data']['id'] ?? '');
            $password  = (string)($created['data']['password'] ?? '');
            $joinUrl   = (string)($created['data']['join_url'] ?? '');

            $mEsc = mysqli_real_escape_string($con, $meetingId);
            $pEsc = mysqli_real_escape_string($con, $password);
            $jEsc = mysqli_real_escape_string($con, $joinUrl);
            $dEsc = mysqli_real_escape_string($con, $today);

            // The unique key on (session_id, session_date) carries the weight here: two requests
            // racing to start the same class both end up pointing at one room.
            @mysqli_query($con, "
                INSERT INTO session_zoom_meetings
                    (session_id, session_date, teacher_id, meeting_id, password, join_url, status, started_at)
                VALUES
                    ({$sessionId}, '{$dEsc}', {$teacherId}, '{$mEsc}', '{$pEsc}', '{$jEsc}', 'live', NOW())
                ON DUPLICATE KEY UPDATE
                    meeting_id = VALUES(meeting_id),
                    password   = VALUES(password),
                    join_url   = VALUES(join_url),
                    status     = 'live',
                    started_at = NOW(),
                    ended_at   = NULL
            ");
        }

        $zak = zoom_host_zak($con);
        if (!$zak) {
            return ['status' => 'error', 'message' => 'تعذر الحصول على صلاحية المضيف من Zoom'];
        }

        return [
            'status' => 'success',
            'message' => 'Zoom room is ready',
            'data' => [
                'session_id'     => $sessionId,
                'meeting_number' => $meetingId,
                'password'       => $password,
                'role'           => 1,
                'signature'      => zoom_sdk_signature($meetingId, 1),
                'zak'            => $zak,
                'sdk_key'        => zoom_config()['sdk']['client_id'],
                'user_name'      => (string)($teacherData['name'] ?? 'Teacher'),
                'user_email'     => (string)($teacherData['email'] ?? ''),
            ],
        ];
    }
}

if (!function_exists('teacherEndZoomClass')) {
    function teacherEndZoomClass($con, $teacherData = null) {
        if (!zoom_is_configured()) return zoom_not_configured_error();

        $teacherId = (int)($teacherData['id'] ?? $teacherData['teacher_id'] ?? 0);
        $body = read_json_body();
        $sessionId = (int)($body['session_id'] ?? $body['id'] ?? $_GET['session_id'] ?? 0);
        if ($teacherId <= 0 || $sessionId <= 0) {
            return ['status' => 'error', 'message' => 'session_id is required'];
        }

        $today = get_request_now()->format('Y-m-d');
        $meeting = zoom_live_meeting_for($con, $sessionId, $today);
        if (!$meeting) {
            return ['status' => 'success', 'message' => 'No live Zoom room for this session today'];
        }
        if ((int)$meeting['teacher_id'] !== $teacherId) {
            return ['status' => 'error', 'message' => 'This session does not belong to you'];
        }

        // Zoom refuses to end a meeting nobody ever joined, and that refusal is not a failure
        // worth showing a teacher - the room is closed either way as far as Brainixa cares.
        zoom_end_meeting($con, $meeting['meeting_id']);

        @mysqli_query($con, "UPDATE session_zoom_meetings SET status = 'ended', ended_at = NOW() WHERE id = " . (int)$meeting['id']);

        return ['status' => 'success', 'message' => 'Zoom room closed'];
    }
}

if (!function_exists('studentJoinZoomClass')) {
    /**
     * Mints a student's join signature, but only after deciding they are allowed in.
     *
     * Order matters: entitlement first, then "is the room even open", then the signature. A
     * student who is not subscribed must not be able to learn whether a class is running.
     */
    function studentJoinZoomClass($con, $studentData = null) {
        if (!zoom_is_configured()) return zoom_not_configured_error();

        $stId = (int)($studentData['id'] ?? $studentData['student_id'] ?? 0);
        if ($stId <= 0) {
            return ['status' => 'error', 'message' => 'Student authentication is required'];
        }

        $sessionId = (int)($_GET['session_id'] ?? read_json_body()['session_id'] ?? 0);
        if ($sessionId <= 0) {
            return ['status' => 'error', 'message' => 'session_id is required'];
        }

        $session = zoom_session_row($con, $sessionId);
        if (!$session) {
            return ['status' => 'error', 'message' => 'Session not found'];
        }

        $courseId  = (int)($session['course_id'] ?? 0);
        $subjectId = (int)($session['subject_id'] ?? 0);

        // Lives in the subscriptions module, not in helpers/entities.php despite the name.
        if (!function_exists('get_student_accessible_entities')) {
            require_once __DIR__ . '/../subscriptions/student_subscriptions.php';
        }
        $accessible = get_student_accessible_entities($con, $stId);

        $allowed = ($courseId > 0 && in_array($courseId, $accessible['course_ids']))
                || ($subjectId > 0 && in_array($subjectId, $accessible['subject_ids']));

        if (!$allowed) {
            return ['status' => 'error', 'message' => 'أنت غير مشترك في هذه الحصة'];
        }

        $today = get_request_now()->format('Y-m-d');
        $meeting = zoom_live_meeting_for($con, $sessionId, $today);
        if (!$meeting || $meeting['status'] !== 'live') {
            return ['status' => 'error', 'message' => 'الحصة لم تبدأ بعد. انتظر حتى يفتحها المعلم.'];
        }

        return [
            'status' => 'success',
            'message' => 'Ready to join',
            'data' => [
                'session_id'     => $sessionId,
                'meeting_number' => $meeting['meeting_id'],
                'password'       => $meeting['password'],
                'role'           => 0,
                'signature'      => zoom_sdk_signature($meeting['meeting_id'], 0),
                'sdk_key'        => zoom_config()['sdk']['client_id'],
                'user_name'      => (string)($studentData['name'] ?? 'Student'),
                'user_email'     => (string)($studentData['email'] ?? ''),
            ],
        ];
    }
}

if (!function_exists('studentZoomClassStatus')) {
    /**
     * "Is my class live right now?" - cheap enough for the student dashboard to poll, and it
     * deliberately carries no signature. The join button calls the endpoint above.
     */
    function studentZoomClassStatus($con, $studentData = null) {
        $stId = (int)($studentData['id'] ?? $studentData['student_id'] ?? 0);
        $sessionId = (int)($_GET['session_id'] ?? 0);
        if ($stId <= 0 || $sessionId <= 0) {
            return ['status' => 'error', 'message' => 'session_id is required'];
        }

        $today = get_request_now()->format('Y-m-d');
        $meeting = zoom_live_meeting_for($con, $sessionId, $today);

        return [
            'status' => 'success',
            'data' => [
                'session_id' => $sessionId,
                'is_live' => (bool)($meeting && $meeting['status'] === 'live'),
            ],
        ];
    }
}
