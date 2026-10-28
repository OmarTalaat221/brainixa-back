<?php

/**
 * Zoom for 1:1 consultation slots ("الاستشارات"), played inside Brainixa - same rule as the
 * package-session and class_sessions live classes: nobody is ever handed a zoom.us link. A
 * teacher or admin presses Start and gets back a meeting number plus a signature that says "you
 * are the host"; the one student booked into this slot asks to join and gets the same meeting
 * number with a signature that says "you are an attendee".
 *
 * consultation_slots is a 1:1 booking (single student_id column), unlike
 * teacher_availability_slots which can hold several bookings per slot - so the entitlement check
 * here is simply "is this your own booked slot", not a join against a bookings table.
 */

require_once __DIR__ . '/../../helpers/functions.php';
require_once __DIR__ . '/../../helpers/zoom.php';
require_once __DIR__ . '/../../app/teacher/consultations/manage.php';

if (!function_exists('consultation_zoom_slot_row')) {
    function consultation_zoom_slot_row($con, int $slotId): ?array {
        $stmt = mysqli_prepare($con, "SELECT id, teacher_id, student_id, slot_date, slot_time, started_at, ended_at, zoom_meeting_id, zoom_password FROM consultation_slots WHERE id = ? LIMIT 1");
        if (!$stmt) return null;
        mysqli_stmt_bind_param($stmt, "i", $slotId);
        mysqli_stmt_execute($stmt);
        $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));
        return $row ?: null;
    }
}

if (!function_exists('consultation_zoom_is_live')) {
    function consultation_zoom_is_live(array $slot): bool {
        return !empty($slot['zoom_meeting_id']) && empty($slot['ended_at']);
    }
}

if (!function_exists('consultation_zoom_start_core')) {
    /**
     * $teacherScope limits Start to one teacher's own slot; null lets the admin act on any slot,
     * exactly like consultation_set_live_state_core() itself.
     */
    function consultation_zoom_start_core($con, int $slotId, ?int $teacherScope, string $hostName, string $hostEmail): array {
        if (!zoom_is_configured()) return zoom_not_configured_error();
        if ($slotId <= 0) {
            return ['status' => 'error', 'message' => 'slot_id is required'];
        }

        // Ownership check, the started_at/status update, and the student notification are all
        // already correct here - reused rather than re-implemented, so the plain-link and Zoom
        // paths can never drift on who is allowed to press Start.
        $stateResult = consultation_set_live_state_core($con, $slotId, true, $teacherScope);
        if (($stateResult['status'] ?? '') !== 'success') {
            return $stateResult;
        }

        $slot = consultation_zoom_slot_row($con, $slotId);
        if (!$slot) {
            return ['status' => 'error', 'message' => 'Slot not found'];
        }

        if (!empty($slot['zoom_meeting_id'])) {
            // Starting again after an End reuses the same room, exactly like the plain-link path
            // reopens the same stored link rather than handing out a new one each time.
            $meetingId = $slot['zoom_meeting_id'];
            $password  = $slot['zoom_password'];
        } else {
            $topic = 'Brainixa - استشارة رقم ' . $slotId;
            $created = zoom_create_meeting($con, $topic, 30);

            if (!$created['ok']) {
                return [
                    'status' => 'error',
                    'message' => 'تعذر فتح غرفة Zoom: ' . ($created['error'] ?? 'سبب غير معروف'),
                ];
            }

            $meetingId = (string)($created['data']['id'] ?? '');
            $password  = (string)($created['data']['password'] ?? '');

            $mEsc = mysqli_real_escape_string($con, $meetingId);
            $pEsc = mysqli_real_escape_string($con, $password);
            mysqli_query($con, "UPDATE consultation_slots SET zoom_meeting_id = '{$mEsc}', zoom_password = '{$pEsc}' WHERE id = {$slotId}");
        }

        $zak = zoom_host_zak($con);
        if (!$zak) {
            return ['status' => 'error', 'message' => 'تعذر الحصول على صلاحية المضيف من Zoom'];
        }

        return [
            'status' => 'success',
            'message' => $stateResult['message'] ?? 'Zoom room is ready',
            'data' => [
                'slot_id'        => $slotId,
                'meeting_number' => $meetingId,
                'password'       => $password,
                'role'           => 1,
                'signature'      => zoom_sdk_signature($meetingId, 1),
                'zak'            => $zak,
                'sdk_key'        => zoom_config()['sdk']['client_id'],
                'user_name'      => $hostName,
                'user_email'     => $hostEmail,
            ],
        ];
    }
}

if (!function_exists('consultation_zoom_end_core')) {
    function consultation_zoom_end_core($con, int $slotId, ?int $teacherScope): array {
        if ($slotId <= 0) {
            return ['status' => 'error', 'message' => 'slot_id is required'];
        }

        $slot = consultation_zoom_slot_row($con, $slotId);

        // Same ownership + notification path as the plain-link End. Runs regardless of whether a
        // Zoom room was ever opened, so End always works even if Start failed midway.
        $stateResult = consultation_set_live_state_core($con, $slotId, false, $teacherScope);
        if (($stateResult['status'] ?? '') !== 'success') {
            return $stateResult;
        }

        if ($slot && !empty($slot['zoom_meeting_id'])) {
            // Zoom refuses to end a meeting nobody ever joined, and that refusal is not worth
            // surfacing - the slot is closed either way as far as Brainixa cares.
            zoom_end_meeting($con, $slot['zoom_meeting_id']);
        }

        return $stateResult;
    }
}

if (!function_exists('teacherStartConsultationZoom')) {
    function teacherStartConsultationZoom($con, $teacherData = null) {
        $teacherId = (int)($teacherData['id'] ?? $teacherData['teacher_id'] ?? 0);
        if ($teacherId <= 0) {
            return ['status' => 'error', 'message' => 'Teacher authentication is required'];
        }

        $body = read_json_body();
        $slotId = (int)($_GET['id'] ?? $body['slot_id'] ?? $body['id'] ?? 0);

        return consultation_zoom_start_core(
            $con,
            $slotId,
            $teacherId,
            (string)($teacherData['name'] ?? 'Teacher'),
            (string)($teacherData['email'] ?? '')
        );
    }
}

if (!function_exists('teacherEndConsultationZoom')) {
    function teacherEndConsultationZoom($con, $teacherData = null) {
        $teacherId = (int)($teacherData['id'] ?? $teacherData['teacher_id'] ?? 0);
        $body = read_json_body();
        $slotId = (int)($_GET['id'] ?? $body['slot_id'] ?? $body['id'] ?? 0);

        return consultation_zoom_end_core($con, $slotId, $teacherId);
    }
}

if (!function_exists('adminStartConsultationZoom')) {
    function adminStartConsultationZoom($con, $adminData = null) {
        $body = read_json_body();
        $slotId = (int)($_GET['id'] ?? $body['slot_id'] ?? $body['id'] ?? 0);

        return consultation_zoom_start_core(
            $con,
            $slotId,
            null,
            (string)($adminData['name'] ?? 'Admin'),
            (string)($adminData['email'] ?? '')
        );
    }
}

if (!function_exists('adminEndConsultationZoom')) {
    function adminEndConsultationZoom($con, $adminData = null) {
        $body = read_json_body();
        $slotId = (int)($_GET['id'] ?? $body['slot_id'] ?? $body['id'] ?? 0);

        return consultation_zoom_end_core($con, $slotId, null);
    }
}

if (!function_exists('studentJoinConsultationZoom')) {
    function studentJoinConsultationZoom($con, $studentData = null) {
        if (!zoom_is_configured()) return zoom_not_configured_error();

        $stId = (int)($studentData['id'] ?? $studentData['student_id'] ?? 0);
        if ($stId <= 0) {
            return ['status' => 'error', 'message' => 'Student authentication is required'];
        }

        $slotId = (int)($_GET['slot_id'] ?? read_json_body()['slot_id'] ?? 0);
        if ($slotId <= 0) {
            return ['status' => 'error', 'message' => 'slot_id is required'];
        }

        $slot = consultation_zoom_slot_row($con, $slotId);
        if (!$slot) {
            return ['status' => 'error', 'message' => 'Slot not found'];
        }

        if ((int)($slot['student_id'] ?? 0) !== $stId) {
            return ['status' => 'error', 'message' => 'أنت غير مسجل في هذه الاستشارة'];
        }

        if (!consultation_zoom_is_live($slot)) {
            return ['status' => 'error', 'message' => 'الاستشارة لم تبدأ بعد. انتظر حتى يفتحها المعلم.'];
        }

        return [
            'status' => 'success',
            'message' => 'Ready to join',
            'data' => [
                'slot_id'        => $slotId,
                'meeting_number' => $slot['zoom_meeting_id'],
                'password'       => $slot['zoom_password'],
                'role'           => 0,
                'signature'      => zoom_sdk_signature($slot['zoom_meeting_id'], 0),
                'sdk_key'        => zoom_config()['sdk']['client_id'],
                'user_name'      => (string)($studentData['name'] ?? 'Student'),
                'user_email'     => (string)($studentData['email'] ?? ''),
            ],
        ];
    }
}

if (!function_exists('studentConsultationZoomStatus')) {
    function studentConsultationZoomStatus($con, $studentData = null) {
        $stId = (int)($studentData['id'] ?? $studentData['student_id'] ?? 0);
        $slotId = (int)($_GET['slot_id'] ?? 0);
        if ($stId <= 0 || $slotId <= 0) {
            return ['status' => 'error', 'message' => 'slot_id is required'];
        }

        $slot = consultation_zoom_slot_row($con, $slotId);
        if (!$slot || (int)($slot['student_id'] ?? 0) !== $stId) {
            return ['status' => 'error', 'message' => 'أنت غير مسجل في هذه الاستشارة'];
        }

        return [
            'status' => 'success',
            'data' => [
                'slot_id' => $slotId,
                'is_live' => consultation_zoom_is_live($slot),
            ],
        ];
    }
}
