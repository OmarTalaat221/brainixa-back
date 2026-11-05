<?php
require_once __DIR__ . '/../../../helpers/functions.php';
require_once __DIR__ . '/../../../helpers/language.php';
require_once __DIR__ . '/../../../helpers/upload.php';
require_once __DIR__ . '/../../../helpers/entities.php';
// get_homework_details() and get_submission_details() already exist for the teacher side and are
// guarded with function_exists, so they are shared rather than copied: an admin and a teacher
// looking at the same homework should not be shown two different shapes of it.
require_once __DIR__ . '/../../teacher/homework/manage.php';

/**
 * Homework, from the admin's side.
 *
 * Until now only a teacher could set homework, which meant an academy running a subject without
 * a teacher account - or wanting to post something themselves - had no way to do it at all.
 *
 * The difference from the teacher handlers is ownership: a teacher may only ever touch their own
 * rows, so `teacher_id` is taken from their token and every query is filtered by it. An admin
 * works across everyone, so the teacher is a field they choose and the filters are optional.
 */

if (!function_exists('admin_homework_teacher_name')) {
    function admin_homework_teacher_name($con, int $teacherId): ?string {
        if ($teacherId <= 0) return null;

        $stmt = mysqli_prepare($con, "SELECT name FROM teachers WHERE id = ? LIMIT 1");
        mysqli_stmt_bind_param($stmt, "i", $teacherId);
        mysqli_stmt_execute($stmt);
        $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));

        return $row['name'] ?? null;
    }
}

if (!function_exists('admin_homework_row')) {
    /**
     * The teacher's row plus the teacher's name. The teacher's own screen never needed it - every
     * row there is theirs - but an admin list of everybody's homework without a name against it
     * is unreadable.
     */
    function admin_homework_row($con, int $homeworkId) {
        $row = get_homework_details($con, $homeworkId);
        if (!$row) return null;

        $row['teacher_name'] = admin_homework_teacher_name($con, (int)$row['teacher_id']);

        return $row;
    }
}

if (!function_exists('adminListHomework')) {
    function adminListHomework($con) {
        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 10)));
        $offset = ($page - 1) * $limit;

        $teacherId = (int)($_GET['teacher_id'] ?? 0);
        $subjectId = (int)($_GET['subject_id'] ?? 0);
        $search = trim((string)($_GET['search'] ?? $_GET['q'] ?? ''));

        $where = ['1 = 1'];
        $params = [];
        $types = '';

        if ($teacherId > 0) {
            $where[] = 'teacher_id = ?';
            $params[] = $teacherId;
            $types .= 'i';
        }

        if ($subjectId > 0) {
            $where[] = 'subject_id = ?';
            $params[] = $subjectId;
            $types .= 'i';
        }

        if ($search !== '') {
            $where[] = '(title LIKE ? OR description LIKE ?)';
            $like = '%' . $search . '%';
            $params[] = $like;
            $params[] = $like;
            $types .= 'ss';
        }

        $whereSql = implode(' AND ', $where);

        $countStmt = mysqli_prepare($con, "SELECT COUNT(*) AS total FROM homework WHERE {$whereSql}");
        if (!empty($params)) {
            mysqli_stmt_bind_param($countStmt, $types, ...$params);
        }
        mysqli_stmt_execute($countStmt);
        $totalRecords = (int)(mysqli_fetch_assoc(mysqli_stmt_get_result($countStmt))['total'] ?? 0);

        $listStmt = mysqli_prepare(
            $con,
            "SELECT id FROM homework WHERE {$whereSql} ORDER BY id DESC LIMIT ? OFFSET ?"
        );
        $listParams = array_merge($params, [$limit, $offset]);
        mysqli_stmt_bind_param($listStmt, $types . 'ii', ...$listParams);
        mysqli_stmt_execute($listStmt);
        $res = mysqli_stmt_get_result($listStmt);

        $items = [];
        while ($row = mysqli_fetch_assoc($res)) {
            $items[] = admin_homework_row($con, (int)$row['id']);
        }

        return build_paginated_response($items, $page, $limit, $totalRecords);
    }
}

if (!function_exists('adminCreateHomework')) {
    function adminCreateHomework($con) {
        $body = read_json_body();

        $teacherId = (int)($body['teacher_id'] ?? 0);
        $subjectId = (int)($body['subject_id'] ?? 0);
        $title = trim($body['title'] ?? '');
        $description = trim($body['description'] ?? '');
        $dueDate = !empty($body['due_date']) ? date('Y-m-d', strtotime($body['due_date'])) : null;
        $isActive = isset($body['is_active']) ? (int)$body['is_active'] : 1;

        // teacher_id is required here where it is implicit for a teacher: `homework.teacher_id` is
        // NOT NULL, and it is the name every student sees against the assignment.
        if ($teacherId <= 0 || $subjectId <= 0 || $title === '') {
            return [
                'status' => 'error',
                'message' => app_text(
                    $con,
                    'المعلّم والمادة والعنوان مطلوبين.',
                    'teacher_id, subject_id and title are required'
                ),
            ];
        }

        if (admin_homework_teacher_name($con, $teacherId) === null) {
            return [
                'status' => 'error',
                'message' => app_text($con, 'المعلّم غير موجود.', 'That teacher does not exist.'),
            ];
        }

        $fileInput = $body['file'] ?? $body['file_path'] ?? null;
        $uploadedFile = $_FILES['file'] ?? $_FILES['pdf'] ?? null;
        $filePath = process_image_input($fileInput, 'homework', $uploadedFile);

        $stmt = mysqli_prepare(
            $con,
            "INSERT INTO homework (teacher_id, subject_id, title, description, due_date, file_path, is_active)
             VALUES (?, ?, ?, ?, ?, ?, ?)"
        );
        mysqli_stmt_bind_param(
            $stmt,
            "iissssi",
            $teacherId,
            $subjectId,
            $title,
            $description,
            $dueDate,
            $filePath,
            $isActive
        );

        if (!mysqli_stmt_execute($stmt)) {
            return ['status' => 'error', 'message' => 'Failed to create homework: ' . mysqli_error($con)];
        }

        $homeworkId = mysqli_insert_id($con);

        $notEligible = [];
        if (!empty($body['student_ids']) && is_array($body['student_ids'])) {
            homework_sync_target_students($con, $homeworkId, $body['student_ids'], $notEligible);
        }

        $response = [
            'status' => 'success',
            'message' => app_text($con, 'تم إنشاء الواجب بنجاح.', 'Homework created successfully'),
            'data' => admin_homework_row($con, $homeworkId),
        ];

        return homework_targeting_notice($con, $response, $notEligible);
    }
}

if (!function_exists('adminUpdateHomework')) {
    function adminUpdateHomework($con) {
        $body = read_json_body();
        $id = (int)($body['id'] ?? $_GET['id'] ?? 0);
        if ($id <= 0) {
            return ['status' => 'error', 'message' => app_text($con, 'رقم الواجب مطلوب.', 'Homework ID is required')];
        }

        // No ownership filter, unlike the teacher's version: an admin edits anyone's homework.
        $checkStmt = mysqli_prepare($con, "SELECT id FROM homework WHERE id = ? LIMIT 1");
        mysqli_stmt_bind_param($checkStmt, "i", $id);
        mysqli_stmt_execute($checkStmt);
        if (!mysqli_fetch_assoc(mysqli_stmt_get_result($checkStmt))) {
            return ['status' => 'error', 'message' => app_text($con, 'الواجب غير موجود.', 'Homework not found')];
        }

        $updateFields = [];
        $params = [];
        $types = '';

        if (isset($body['title'])) { $updateFields[] = "title = ?"; $params[] = trim($body['title']); $types .= 's'; }
        if (isset($body['description'])) { $updateFields[] = "description = ?"; $params[] = trim($body['description']); $types .= 's'; }
        if (isset($body['subject_id'])) { $updateFields[] = "subject_id = ?"; $params[] = (int)$body['subject_id']; $types .= 'i'; }
        if (isset($body['is_active'])) { $updateFields[] = "is_active = ?"; $params[] = (int)$body['is_active']; $types .= 'i'; }

        if (isset($body['teacher_id'])) {
            $newTeacherId = (int)$body['teacher_id'];
            if (admin_homework_teacher_name($con, $newTeacherId) === null) {
                return [
                    'status' => 'error',
                    'message' => app_text($con, 'المعلّم غير موجود.', 'That teacher does not exist.'),
                ];
            }
            $updateFields[] = "teacher_id = ?";
            $params[] = $newTeacherId;
            $types .= 'i';
        }

        if (isset($body['due_date'])) {
            $updateFields[] = "due_date = ?";
            $params[] = !empty($body['due_date']) ? date('Y-m-d', strtotime($body['due_date'])) : null;
            $types .= 's';
        }

        $fileInput = $body['file'] ?? $body['file_path'] ?? null;
        $uploadedFile = $_FILES['file'] ?? $_FILES['pdf'] ?? null;
        $filePath = process_image_input($fileInput, 'homework', $uploadedFile);
        if ($filePath !== null) { $updateFields[] = "file_path = ?"; $params[] = $filePath; $types .= 's'; }

        if (!empty($updateFields)) {
            $params[] = $id;
            $types .= 'i';
            $uStmt = mysqli_prepare($con, "UPDATE homework SET " . implode(", ", $updateFields) . " WHERE id = ?");
            mysqli_stmt_bind_param($uStmt, $types, ...$params);
            mysqli_stmt_execute($uStmt);
        }

        $notEligible = [];
        if (array_key_exists('student_ids', $body) && is_array($body['student_ids'])) {
            homework_sync_target_students($con, $id, $body['student_ids'], $notEligible);
        }

        $response = [
            'status' => 'success',
            'message' => app_text($con, 'تم تحديث الواجب بنجاح.', 'Homework updated successfully'),
            'data' => admin_homework_row($con, $id),
        ];

        return homework_targeting_notice($con, $response, $notEligible);
    }
}

if (!function_exists('adminDeleteHomework')) {
    function adminDeleteHomework($con) {
        $id = (int)($_GET['id'] ?? read_json_body()['id'] ?? 0);
        if ($id <= 0) {
            return ['status' => 'error', 'message' => app_text($con, 'رقم الواجب مطلوب.', 'Homework ID is required')];
        }

        $stmt = mysqli_prepare($con, "DELETE FROM homework WHERE id = ?");
        mysqli_stmt_bind_param($stmt, "i", $id);

        if (mysqli_stmt_execute($stmt)) {
            // The submissions go with it, exactly as on the teacher side - a submission whose
            // homework is gone cannot be opened, graded or explained.
            @mysqli_query($con, "DELETE FROM homework_submissions WHERE homework_id = {$id}");
            return ['status' => 'success', 'message' => app_text($con, 'تم حذف الواجب.', 'Homework deleted successfully')];
        }

        return ['status' => 'error', 'message' => 'Failed to delete homework'];
    }
}

if (!function_exists('adminListHomeworkSubmissions')) {
    function adminListHomeworkSubmissions($con) {
        $homeworkId = (int)($_GET['homework_id'] ?? 0);
        if ($homeworkId <= 0) {
            return ['status' => 'error', 'message' => app_text($con, 'رقم الواجب مطلوب.', 'homework_id is required')];
        }

        $stmt = mysqli_prepare($con, "SELECT id FROM homework_submissions WHERE homework_id = ? ORDER BY id DESC");
        mysqli_stmt_bind_param($stmt, "i", $homeworkId);
        mysqli_stmt_execute($stmt);
        $res = mysqli_stmt_get_result($stmt);

        $items = [];
        while ($row = mysqli_fetch_assoc($res)) {
            $items[] = get_submission_details($con, (int)$row['id']);
        }

        return ['status' => 'success', 'data' => $items];
    }
}

if (!function_exists('adminGradeHomeworkSubmission')) {
    function adminGradeHomeworkSubmission($con) {
        $body = read_json_body();
        $submissionId = (int)($body['submission_id'] ?? $body['id'] ?? 0);
        $feedbackText = trim($body['feedback_text'] ?? $body['feedback'] ?? '');
        $rating = isset($body['rating']) ? (int)$body['rating'] : null;

        if ($submissionId <= 0 || $feedbackText === '') {
            return [
                'status' => 'error',
                'message' => app_text(
                    $con,
                    'رقم التسليم ونصّ الملاحظة مطلوبين.',
                    'submission_id and feedback_text are required'
                ),
            ];
        }

        $checkStmt = mysqli_prepare($con, "SELECT id FROM homework_submissions WHERE id = ? LIMIT 1");
        mysqli_stmt_bind_param($checkStmt, "i", $submissionId);
        mysqli_stmt_execute($checkStmt);
        if (!mysqli_fetch_assoc(mysqli_stmt_get_result($checkStmt))) {
            return ['status' => 'error', 'message' => app_text($con, 'التسليم غير موجود.', 'Submission not found')];
        }

        $stmt = mysqli_prepare(
            $con,
            "UPDATE homework_submissions
                SET status = 'reviewed', feedback_text = ?, feedback_rating = ?, reviewed_at = NOW()
              WHERE id = ?"
        );
        mysqli_stmt_bind_param($stmt, "sii", $feedbackText, $rating, $submissionId);
        mysqli_stmt_execute($stmt);

        return [
            'status' => 'success',
            'message' => app_text($con, 'تم حفظ الملاحظة.', 'Feedback submitted successfully'),
            'data' => get_submission_details($con, $submissionId),
        ];
    }
}
