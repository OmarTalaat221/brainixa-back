<?php
require_once __DIR__ . '/functions.php';
require_once __DIR__ . '/availability.php';
require_once __DIR__ . '/notifications.php';
require_once __DIR__ . '/admin_notifications.php';
require_once __DIR__ . '/hr_policy.php';

/**
 * Moving a PACKAGE APPOINTMENT to another date and time (migration 132).
 *
 * A student booked into "17 November 16:30" asks for "18 November 17:30". The request goes into
 * the same `session_reschedule_requests` table as the weekly-session requests, told apart by
 * `slot_id`, so the admin's "reschedule requests" screen and the teacher's incoming list show both.
 * Either reviewer may decide it: the admin any request, a teacher only requests for their own
 * appointments. Approving moves the student's booking - nothing else about the appointment
 * changes (teacher, package, length, link) - and tells the student.
 */

if (!function_exists('slot_reschedule_ready')) {
    /** Whether migration 132 has run. */
    function slot_reschedule_ready($con): bool {
        static $ready = null;
        if ($ready !== null) return $ready;
        $res = @mysqli_query($con, "SHOW COLUMNS FROM session_reschedule_requests LIKE 'slot_id'");
        $ready = $res && mysqli_num_rows($res) > 0;
        return $ready;
    }
}

if (!function_exists('slot_reschedule_not_ready')) {
    function slot_reschedule_not_ready(): array {
        return ['status' => 'error', 'message' => 'Rescheduling a package appointment needs migration 132 to be run on the database'];
    }
}

if (!function_exists('slot_reschedule_time')) {
    /** "17:30", "17:30:00" or "5:30 PM" as HH:MM:SS, or null. */
    function slot_reschedule_time($value): ?string {
        $value = trim((string)$value);
        if ($value === '') return null;
        $ts = strtotime($value);
        return $ts === false ? null : date('H:i:s', $ts);
    }
}

if (!function_exists('slot_reschedule_teacher_busy')) {
    /**
     * Whether the teacher already has another live appointment overlapping [start, end) that
     * day - other than `$exceptSlotId` (the slot the booking is leaving) and other than an exact
     * same-time slot, which the move may simply join if it has room.
     */
    function slot_reschedule_teacher_busy($con, int $teacherId, string $date, string $start, string $end, int $exceptSlotId): ?array {
        $stmt = mysqli_prepare($con, "
            SELECT id, start_time, end_time FROM teacher_availability_slots
            WHERE teacher_id = ? AND slot_date = ? AND id <> ? AND status <> 'cancelled'
              AND start_time < ? AND end_time > ? AND start_time <> ?
            LIMIT 1
        ");
        mysqli_stmt_bind_param($stmt, "isisss", $teacherId, $date, $exceptSlotId, $end, $start, $start);
        mysqli_stmt_execute($stmt);
        return mysqli_fetch_assoc(mysqli_stmt_get_result($stmt)) ?: null;
    }
}

if (!function_exists('slot_reschedule_create')) {
    /**
     * POST /student/sessions/reschedule-request with `slot_id`.
     * Body: slot_id, new_date (YYYY-MM-DD), new_start_time, new_end_time (optional: keeps the
     * appointment's length), reason (optional).
     */
    function slot_reschedule_create($con, int $studentId, array $body): array {
        if (!slot_reschedule_ready($con)) return slot_reschedule_not_ready();

        $slotId = (int)($body['slot_id'] ?? 0);
        $slot = $slotId > 0 ? get_availability_slot_details($con, $slotId, false) : null;
        if (!$slot) {
            return ['status' => 'error', 'message' => 'الموعد غير موجود'];
        }

        $bk = mysqli_prepare($con, "SELECT id FROM availability_slot_bookings WHERE slot_id = ? AND student_id = ? AND status = 'booked' LIMIT 1");
        mysqli_stmt_bind_param($bk, "ii", $slotId, $studentId);
        mysqli_stmt_execute($bk);
        if (!mysqli_fetch_assoc(mysqli_stmt_get_result($bk))) {
            return ['status' => 'error', 'message' => 'هذا الموعد ليس محجوزًا باسمك'];
        }

        $now = get_request_now();
        $oldStart = $slot['slot_date'] . ' ' . $slot['start_time'];
        if (!empty($slot['started_at']) || !empty($slot['ended_at']) || in_array($slot['status'], ['completed', 'cancelled', 'in_progress'], true)
            || strtotime($oldStart) <= $now->getTimestamp()) {
            return ['status' => 'error', 'message' => 'لا يمكن تغيير موعد بدأ أو انتهى'];
        }

        $newDate = trim((string)($body['new_date'] ?? $body['date'] ?? ''));
        $d = DateTime::createFromFormat('!Y-m-d', $newDate);
        if (!$d || $d->format('Y-m-d') !== $newDate) {
            return ['status' => 'error', 'message' => 'new_date مطلوب بصيغة YYYY-MM-DD'];
        }
        $newStart = slot_reschedule_time($body['new_start_time'] ?? $body['start_time'] ?? '');
        if (!$newStart) {
            return ['status' => 'error', 'message' => 'new_start_time مطلوب'];
        }
        $length = max(60, strtotime($slot['end_time']) - strtotime($slot['start_time']));
        $newEnd = slot_reschedule_time($body['new_end_time'] ?? $body['end_time'] ?? '')
            ?: date('H:i:s', strtotime($newStart) + $length);
        if ($newEnd <= $newStart) {
            return ['status' => 'error', 'message' => 'وقت النهاية يجب أن يكون بعد وقت البداية'];
        }
        if (strtotime($newDate . ' ' . $newStart) <= $now->getTimestamp()) {
            return ['status' => 'error', 'message' => 'الموعد الجديد يجب أن يكون في المستقبل'];
        }
        if ($newDate === $slot['slot_date'] && $newStart === $slot['start_time']) {
            return ['status' => 'error', 'message' => 'الموعد الجديد هو نفس الموعد الحالي'];
        }

        $subscription = availability_find_student_subscription($con, $studentId, $slot['course_id'] ? (int)$slot['course_id'] : null);
        if ($subscription && !empty($subscription['end_date']) && strtotime($newDate) > strtotime(date('Y-m-d', strtotime($subscription['end_date'])))) {
            return ['status' => 'error', 'message' => 'الموعد الجديد بعد انتهاء اشتراكك (' . date('Y-m-d', strtotime($subscription['end_date'])) . ')'];
        }

        // Said now rather than at review: the student cannot see the teacher's calendar.
        $busy = slot_reschedule_teacher_busy($con, (int)$slot['teacher_id'], $newDate, $newStart, $newEnd, $slotId);
        if ($busy) {
            return ['status' => 'error', 'message' => 'المعلم لديه موعد آخر في هذا الوقت (' . substr($busy['start_time'], 0, 5) . ' - ' . substr($busy['end_time'], 0, 5) . ')، اختر وقتًا آخر'];
        }

        $pending = mysqli_prepare($con, "SELECT id FROM session_reschedule_requests WHERE slot_id = ? AND requested_by_type = 'student' AND requested_by_id = ? AND status = 'pending' LIMIT 1");
        mysqli_stmt_bind_param($pending, "ii", $slotId, $studentId);
        mysqli_stmt_execute($pending);
        if (mysqli_fetch_assoc(mysqli_stmt_get_result($pending))) {
            return ['status' => 'error', 'message' => 'لديك طلب تغيير قيد المراجعة لهذا الموعد بالفعل'];
        }

        $policy = get_hr_policy_settings($con);
        if (count_reschedule_requests_this_month($con, 'student', $studentId) >= $policy['student_max_reschedule_per_month']) {
            return ['status' => 'error', 'message' => trans('max_reschedule_requests_reached')];
        }

        $teacherId = (int)$slot['teacher_id'];
        $newDay = date('l', strtotime($newDate));
        $reason = trim((string)($body['reason'] ?? ''));
        $origDate = $slot['slot_date'];
        $origStart = $slot['start_time'];
        $origEnd = $slot['end_time'];

        $ins = mysqli_prepare($con, "
            INSERT INTO session_reschedule_requests
                (session_id, slot_id, teacher_id, requested_by_type, requested_by_id, new_day, new_date,
                 new_start_time, new_end_time, original_date, original_start_time, original_end_time, reason)
            VALUES (NULL, ?, ?, 'student', ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        mysqli_stmt_bind_param($ins, "iiissssssss", $slotId, $teacherId, $studentId, $newDay, $newDate, $newStart, $newEnd, $origDate, $origStart, $origEnd, $reason);
        if (!mysqli_stmt_execute($ins)) {
            return ['status' => 'error', 'message' => 'تعذّر إرسال الطلب: ' . mysqli_error($con)];
        }
        $requestId = (int)mysqli_insert_id($con);

        $name = admin_notify_get_student_name($con, $studentId);
        $from = $origDate . ' ' . substr($origStart, 0, 5);
        $to = $newDate . ' ' . substr($newStart, 0, 5);
        $text = "الطالب {$name} يطلب نقل موعده من {$from} إلى {$to}.";
        send_notification_to_users($con, 'teacher', [$teacherId], 'طلب تغيير موعد', $text, ['type' => 'reschedule_request_created', 'request_id' => $requestId, 'slot_id' => $slotId], 'system', null, ['push']);
        notify_admins($con, 'طلب تغيير موعد', $text, ['type' => 'reschedule_request_created', 'request_id' => $requestId, 'slot_id' => $slotId]);

        return [
            'status' => 'success',
            'message' => 'تم إرسال طلب تغيير الموعد، وسيصلك الرد بعد مراجعته',
            'data' => get_reschedule_request_details($con, $requestId),
        ];
    }
}

if (!function_exists('slot_reschedule_apply')) {
    /**
     * Approve-side of a package-appointment request: move the student's booking. `$overrides`
     * may carry new_date / new_start_time / new_end_time from the reviewer, who can settle on a
     * slightly different time than the one asked for. Returns ['status' => ...]; on success,
     * data.new_slot_id. Runs in one transaction - a half-moved booking is never left behind.
     */
    function slot_reschedule_apply($con, array $req, string $byType, ?int $byId, array $overrides = []): array {
        $oldSlotId = (int)$req['slot_id'];
        $studentId = (int)$req['requested_by_id'];
        $old = get_availability_slot_details($con, $oldSlotId, false);
        if (!$old) {
            return ['status' => 'error', 'message' => 'الموعد الأصلي لم يعد موجودًا'];
        }

        $bkStmt = mysqli_prepare($con, "SELECT id, student_subscription_id FROM availability_slot_bookings WHERE slot_id = ? AND student_id = ? AND status = 'booked' LIMIT 1");
        mysqli_stmt_bind_param($bkStmt, "ii", $oldSlotId, $studentId);
        mysqli_stmt_execute($bkStmt);
        $booking = mysqli_fetch_assoc(mysqli_stmt_get_result($bkStmt));
        if (!$booking) {
            return ['status' => 'error', 'message' => 'لم يعد الطالب محجوزًا في الموعد الأصلي'];
        }

        $date = trim((string)($overrides['new_date'] ?? '')) ?: $req['new_date'];
        $start = slot_reschedule_time($overrides['new_start_time'] ?? '') ?: $req['new_start_time'];
        $end = slot_reschedule_time($overrides['new_end_time'] ?? '') ?: $req['new_end_time'];
        $d = DateTime::createFromFormat('!Y-m-d', (string)$date);
        if (!$d || $d->format('Y-m-d') !== $date || !$start || !$end || $end <= $start) {
            return ['status' => 'error', 'message' => 'تاريخ أو وقت الموعد الجديد غير صالح'];
        }
        if (strtotime($date . ' ' . $start) <= get_request_now()->getTimestamp()) {
            return ['status' => 'error', 'message' => 'الموعد الجديد أصبح في الماضي؛ اختر وقتًا آخر قبل الموافقة'];
        }

        $teacherId = (int)$old['teacher_id'];
        $busy = slot_reschedule_teacher_busy($con, $teacherId, $date, $start, $end, $oldSlotId);
        if ($busy) {
            return ['status' => 'error', 'message' => 'المعلم لديه موعد آخر في هذا الوقت (' . substr($busy['start_time'], 0, 5) . ' - ' . substr($busy['end_time'], 0, 5) . ')'];
        }

        mysqli_begin_transaction($con);
        try {
            // An exact same-time slot of this teacher is joined if it has room; otherwise a new
            // slot is made with the old one's package, capacity, link and place.
            $ex = mysqli_prepare($con, "SELECT id FROM teacher_availability_slots WHERE teacher_id = ? AND slot_date = ? AND start_time = ? AND status <> 'cancelled' LIMIT 1");
            mysqli_stmt_bind_param($ex, "iss", $teacherId, $date, $start);
            mysqli_stmt_execute($ex);
            $exRow = mysqli_fetch_assoc(mysqli_stmt_get_result($ex));

            if ($exRow) {
                $newSlotId = (int)$exRow['id'];
                if ($newSlotId === $oldSlotId) {
                    throw new RuntimeException('الموعد الجديد هو نفس الموعد الحالي');
                }
                $target = get_availability_slot_details($con, $newSlotId, false);
                if ((int)$target['booked_count'] >= (int)$target['capacity']) {
                    throw new RuntimeException('يوجد موعد للمعلم في هذا الوقت وهو ممتلئ');
                }
            } else {
                $created = availability_create_slot($con, $teacherId, [
                    'slot_date' => $date,
                    'start_time' => $start,
                    'end_time' => $end,
                    'course_id' => $old['course_id'],
                    'subject_id' => $old['subject_id'],
                    'capacity' => max(1, (int)$old['capacity']),
                    'is_online' => $old['is_online'],
                    'meeting_link' => $old['meeting_link'] ?? null,
                    'room' => $old['room'] ?? null,
                    'notes' => $old['notes'] ?? null,
                ], $byType, $byId);
                if (($created['status'] ?? '') !== 'success') {
                    throw new RuntimeException($created['message'] ?? 'تعذّر إنشاء الموعد الجديد');
                }
                $newSlotId = (int)($created['data']['id'] ?? 0);
                if ($newSlotId <= 0) {
                    throw new RuntimeException('تعذّر إنشاء الموعد الجديد');
                }
            }

            // The booking itself moves: the old row is cancelled, the new one carries the same
            // subscription. Done directly rather than through book/cancel, which would send the
            // student two notices ("cancelled", "booked") for what is one change.
            $subId = $booking['student_subscription_id'] !== null ? (int)$booking['student_subscription_id'] : null;
            $prev = mysqli_prepare($con, "SELECT id FROM availability_slot_bookings WHERE slot_id = ? AND student_id = ? LIMIT 1");
            mysqli_stmt_bind_param($prev, "ii", $newSlotId, $studentId);
            mysqli_stmt_execute($prev);
            $prevRow = mysqli_fetch_assoc(mysqli_stmt_get_result($prev));
            if ($prevRow) {
                $up = mysqli_prepare($con, "UPDATE availability_slot_bookings SET status = 'booked', student_subscription_id = ?, booked_by_type = ?, booked_by_id = ?, cancelled_at = NULL WHERE id = ?");
                $pid = (int)$prevRow['id'];
                mysqli_stmt_bind_param($up, "isii", $subId, $byType, $byId, $pid);
                if (!mysqli_stmt_execute($up)) throw new RuntimeException(mysqli_error($con));
            } else {
                $ins = mysqli_prepare($con, "INSERT INTO availability_slot_bookings (slot_id, student_id, student_subscription_id, booked_by_type, booked_by_id, notes) VALUES (?, ?, ?, ?, ?, ?)");
                $note = 'نُقل من ' . $old['slot_date'] . ' ' . substr($old['start_time'], 0, 5) . ' (طلب تغيير موعد #' . (int)$req['id'] . ')';
                mysqli_stmt_bind_param($ins, "iiisis", $newSlotId, $studentId, $subId, $byType, $byId, $note);
                if (!mysqli_stmt_execute($ins)) throw new RuntimeException(mysqli_error($con));
            }

            $cancel = mysqli_prepare($con, "UPDATE availability_slot_bookings SET status = 'cancelled', cancelled_at = NOW() WHERE id = ?");
            $bid = (int)$booking['id'];
            mysqli_stmt_bind_param($cancel, "i", $bid);
            if (!mysqli_stmt_execute($cancel)) throw new RuntimeException(mysqli_error($con));

            availability_recompute_slot($con, $newSlotId);
            availability_recompute_slot($con, $oldSlotId);

            // A one-seat appointment left with nobody in it was this student's own; it goes, so the
            // calendar does not keep showing the old time as if it still stood. A group slot with
            // other students, or room published on purpose, stays.
            $after = get_availability_slot_details($con, $oldSlotId, false);
            if ($after && (int)$after['booked_count'] === 0 && (int)$after['capacity'] <= 1 && empty($after['started_at'])) {
                $delB = mysqli_prepare($con, "DELETE FROM availability_slot_bookings WHERE slot_id = ?");
                mysqli_stmt_bind_param($delB, "i", $oldSlotId);
                mysqli_stmt_execute($delB);
                $delS = mysqli_prepare($con, "DELETE FROM teacher_availability_slots WHERE id = ?");
                mysqli_stmt_bind_param($delS, "i", $oldSlotId);
                mysqli_stmt_execute($delS);
            }

            $reqId = (int)$req['id'];
            $mark = mysqli_prepare($con, "UPDATE session_reschedule_requests SET new_slot_id = ?, new_date = ?, new_start_time = ?, new_end_time = ?, new_day = ? WHERE id = ?");
            $day = date('l', strtotime($date));
            mysqli_stmt_bind_param($mark, "issssi", $newSlotId, $date, $start, $end, $day, $reqId);
            mysqli_stmt_execute($mark);

            mysqli_commit($con);
        } catch (Throwable $e) {
            mysqli_rollback($con);
            return ['status' => 'error', 'message' => $e->getMessage()];
        }

        return ['status' => 'success', 'data' => ['new_slot_id' => $newSlotId, 'new_date' => $date, 'new_start_time' => $start, 'new_end_time' => $end]];
    }
}

if (!function_exists('slot_reschedule_review')) {
    /**
     * Decide a package-appointment request (admin, or the appointment's own teacher). Approving
     * moves the booking first and records the decision only if the move worked, so a refused move
     * ("the teacher is busy then") leaves the request pending for another try.
     * `$body` may carry new_date / new_start_time / new_end_time to settle on another time.
     */
    function slot_reschedule_review($con, array $req, string $decision, string $note, string $byType, ?int $byId, array $body = []): array {
        if (!slot_reschedule_ready($con)) return slot_reschedule_not_ready();
        $id = (int)$req['id'];

        if ($decision === 'approved') {
            $moved = slot_reschedule_apply($con, $req, $byType, $byId, [
                'new_date' => $body['new_date'] ?? null,
                'new_start_time' => $body['new_start_time'] ?? null,
                'new_end_time' => $body['new_end_time'] ?? null,
            ]);
            if (($moved['status'] ?? '') !== 'success') {
                return $moved;
            }
            $req = array_merge($req, $moved['data']);
        }

        $up = mysqli_prepare($con, "UPDATE session_reschedule_requests SET status = ?, admin_note = ?, reviewed_by_type = ?, reviewed_by_id = ?, reviewed_at = NOW() WHERE id = ? AND status = 'pending'");
        mysqli_stmt_bind_param($up, "sssii", $decision, $note, $byType, $byId, $id);
        mysqli_stmt_execute($up);

        slot_reschedule_notify_student($con, $req, $decision, $note, $byType === 'teacher' ? 'teacher' : 'system', $byType === 'teacher' ? $byId : null);

        return [
            'status' => 'success',
            'message' => $decision === 'approved' ? 'تمت الموافقة ونُقل الموعد' : 'تم رفض الطلب',
            'data' => get_reschedule_request_details($con, $id),
        ];
    }
}

if (!function_exists('slot_reschedule_notify_student')) {
    function slot_reschedule_notify_student($con, array $req, string $decision, string $note, string $senderType, ?int $senderId): void {
        $studentId = (int)($req['requested_by_id'] ?? 0);
        if ($studentId <= 0) return;
        $from = ($req['original_date'] ?? '') . ' ' . substr((string)($req['original_start_time'] ?? ''), 0, 5);
        $to = ($req['new_date'] ?? '') . ' ' . substr((string)($req['new_start_time'] ?? ''), 0, 5);
        if ($decision === 'approved') {
            $title = 'تم تغيير موعدك';
            $body = "تمت الموافقة على طلبك: موعدك أصبح {$to} بدلًا من {$from}.";
        } else {
            $title = 'رُفض طلب تغيير الموعد';
            $body = "طلب نقل موعد {$from} لم تتم الموافقة عليه، والموعد باقٍ كما هو." . ($note !== '' ? " ملاحظة: {$note}" : '');
        }
        send_notification_to_users($con, 'student', [$studentId], $title, $body, [
            'type' => 'reschedule_request_reviewed', 'request_id' => (int)$req['id'], 'decision' => $decision,
            'slot_id' => (int)($req['new_slot_id'] ?? 0) ?: (int)$req['slot_id'],
        ], $senderType, $senderId, ['push']);
    }
}
