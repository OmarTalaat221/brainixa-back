<?php

/**
 * Zoom for package session slots ("مواعيد الباقات" / "مواعيدي المتاحة"), played inside Brainixa.
 *
 * This is the real feature live classes run on - `teacher_availability_slots`, one row per
 * dated appointment, booked into through `availability_slot_bookings` - not the generic weekly
 * `class_sessions` template that app/sessions/zoom.php wires up. The two are kept separate
 * because their entitlement checks differ: a class_sessions join checks a course/subject
 * subscription, a slot join checks an actual booking row for THIS specific date.
 *
 * Same rule as everywhere else in this integration: nobody is ever handed a zoom.us link. A
 * teacher presses Start and gets back a meeting number plus a signature that says "you are the
 * host"; a booked student asks to join and gets the same meeting number with a signature that
 * says "you are an attendee". Access is decided here, from the booking table, before a
 * signature is ever minted.
 */

require_once __DIR__ . '/../../helpers/functions.php';
require_once __DIR__ . '/../../helpers/zoom.php';
require_once __DIR__ . '/../../helpers/availability.php';

if (!function_exists('availability_zoom_slot_row')) {
    function availability_zoom_slot_row($con, int $slotId): ?array {
        $stmt = mysqli_prepare($con, "SELECT id, teacher_id, course_id, subject_id, slot_date, start_time, end_time, started_at, ended_at, zoom_meeting_id, zoom_password FROM teacher_availability_slots WHERE id = ? LIMIT 1");
        if (!$stmt) return null;
        mysqli_stmt_bind_param($stmt, "i", $slotId);
        mysqli_stmt_execute($stmt);
        $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));
        return $row ?: null;
    }
}

if (!function_exists('availability_zoom_slot_is_live')) {
    /**
     * Unlike class_sessions, a slot has no "within the clock window" auto-open: without Start
     * being pressed, no Zoom room was ever created to join. So this is just "was a room opened,
     * and has it not been closed" - the two columns this file itself maintains.
     */
    function availability_zoom_slot_is_live(array $slot): bool {
        return !empty($slot['zoom_meeting_id']) && empty($slot['ended_at']);
    }
}

if (!function_exists('teacherStartZoomSlot')) {
    function teacherStartZoomSlot($con, $teacherData = null) {
        if (!zoom_is_configured()) return zoom_not_configured_error();

        $teacherId = (int)($teacherData['id'] ?? $teacherData['teacher_id'] ?? 0);
        if ($teacherId <= 0) {
            return ['status' => 'error', 'message' => 'Teacher authentication is required'];
        }

        $body = read_json_body();
        $slotId = (int)($body['slot_id'] ?? $body['id'] ?? $_GET['id'] ?? 0);
        if ($slotId <= 0) {
            return ['status' => 'error', 'message' => 'slot_id is required'];
        }

        // Ownership check, the started_at/status update, and the student notification are all
        // already correct here - reused rather than re-implemented, so the two code paths
        // (plain link and Zoom) can never drift on who is allowed to press Start.
        $stateResult = availability_set_live_state($con, $slotId, true, $teacherId);
        if (($stateResult['status'] ?? '') !== 'success') {
            return $stateResult;
        }

        $slot = availability_zoom_slot_row($con, $slotId);
        if (!$slot) {
            return ['status' => 'error', 'message' => 'Slot not found'];
        }

        if (!empty($slot['zoom_meeting_id'])) {
            // Starting again after an End reuses the same room, exactly like the plain-link
            // path reopens the same stored link rather than handing out a new one each time.
            $meetingId = $slot['zoom_meeting_id'];
            $password  = $slot['zoom_password'];
        } else {
            $topic = 'Brainixa - موعد رقم ' . $slotId;
            $duration = max(5, (int)round((strtotime($slot['end_time']) - strtotime($slot['start_time'])) / 60));
            $created = zoom_create_meeting($con, $topic, $duration > 0 ? $duration : 60);

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
            mysqli_query($con, "UPDATE teacher_availability_slots SET zoom_meeting_id = '{$mEsc}', zoom_password = '{$pEsc}' WHERE id = {$slotId}");
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
                'user_name'      => (string)($teacherData['name'] ?? 'Teacher'),
                'user_email'     => (string)($teacherData['email'] ?? ''),
            ],
        ];
    }
}

if (!function_exists('teacherEndZoomSlot')) {
    function teacherEndZoomSlot($con, $teacherData = null) {
        $teacherId = (int)($teacherData['id'] ?? $teacherData['teacher_id'] ?? 0);
        $body = read_json_body();
        $slotId = (int)($body['slot_id'] ?? $body['id'] ?? $_GET['id'] ?? 0);
        if ($teacherId <= 0 || $slotId <= 0) {
            return ['status' => 'error', 'message' => 'slot_id is required'];
        }

        $slot = availability_zoom_slot_row($con, $slotId);

        // Same ownership + notification path as the plain-link End. Runs regardless of whether
        // a Zoom room was ever opened, so End always works even if Start failed midway.
        $stateResult = availability_set_live_state($con, $slotId, false, $teacherId);
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

if (!function_exists('studentJoinZoomSlot')) {
    function studentJoinZoomSlot($con, $studentData = null) {
        if (!zoom_is_configured()) return zoom_not_configured_error();

        $stId = (int)($studentData['id'] ?? $studentData['student_id'] ?? 0);
        if ($stId <= 0) {
            return ['status' => 'error', 'message' => 'Student authentication is required'];
        }

        $slotId = (int)($_GET['slot_id'] ?? read_json_body()['slot_id'] ?? 0);
        if ($slotId <= 0) {
            return ['status' => 'error', 'message' => 'slot_id is required'];
        }

        $booked = mysqli_query($con, "SELECT id FROM availability_slot_bookings WHERE slot_id = {$slotId} AND student_id = {$stId} AND status = 'booked' LIMIT 1");
        if (!$booked || mysqli_num_rows($booked) === 0) {
            return ['status' => 'error', 'message' => 'أنت غير مسجل في هذا الموعد'];
        }

        $slot = availability_zoom_slot_row($con, $slotId);
        if (!$slot) {
            return ['status' => 'error', 'message' => 'Slot not found'];
        }

        if (!availability_zoom_slot_is_live($slot)) {
            return ['status' => 'error', 'message' => 'الحصة لم تبدأ بعد. انتظر حتى يفتحها المعلم.'];
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

if (!function_exists('studentZoomSlotStatus')) {
    function studentZoomSlotStatus($con, $studentData = null) {
        $stId = (int)($studentData['id'] ?? $studentData['student_id'] ?? 0);
        $slotId = (int)($_GET['slot_id'] ?? 0);
        if ($stId <= 0 || $slotId <= 0) {
            return ['status' => 'error', 'message' => 'slot_id is required'];
        }

        $booked = mysqli_query($con, "SELECT id FROM availability_slot_bookings WHERE slot_id = {$slotId} AND student_id = {$stId} AND status = 'booked' LIMIT 1");
        if (!$booked || mysqli_num_rows($booked) === 0) {
            return ['status' => 'error', 'message' => 'أنت غير مسجل في هذا الموعد'];
        }

        $slot = availability_zoom_slot_row($con, $slotId);

        return [
            'status' => 'success',
            'data' => [
                'slot_id' => $slotId,
                'is_live' => $slot ? availability_zoom_slot_is_live($slot) : false,
            ],
        ];
    }
}
