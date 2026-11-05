<?php
require_once __DIR__ . '/../../../helpers/functions.php';
require_once __DIR__ . '/../../../helpers/language.php';
require_once __DIR__ . '/../../../helpers/upload.php';
require_once __DIR__ . '/../../../helpers/entities.php';

if (!function_exists('homework_students_table_exists')) {
    /**
     * Migration 126 is applied by hand on the server, so every read of the table is guarded. Until
     * it has run, targeting simply does not exist: homework stays visible to the whole subject,
     * which is what it did before, rather than the pages breaking.
     */
    function homework_students_table_exists($con): bool {
        static $exists = null;
        if ($exists === null) {
            $res = @mysqli_query($con, "SHOW TABLES LIKE 'homework_students'");
            $exists = $res && mysqli_num_rows($res) > 0;
        }
        return $exists;
    }
}

if (!function_exists('homework_target_student_ids')) {
    /** The students a homework is aimed at. An empty array means "everyone in the subject". */
    function homework_target_student_ids($con, int $homeworkId): array {
        if ($homeworkId <= 0 || !homework_students_table_exists($con)) return [];

        $stmt = mysqli_prepare($con, "SELECT student_id FROM homework_students WHERE homework_id = ? ORDER BY student_id ASC");
        if (!$stmt) return [];
        mysqli_stmt_bind_param($stmt, "i", $homeworkId);
        mysqli_stmt_execute($stmt);
        $res = mysqli_stmt_get_result($stmt);

        $ids = [];
        while ($row = mysqli_fetch_assoc($res)) {
            $ids[] = (int)$row['student_id'];
        }

        return $ids;
    }
}

if (!function_exists('homework_target_students')) {
    /** The same list with names on it, so a dashboard can show who a homework went to. */
    function homework_target_students($con, int $homeworkId): array {
        $ids = homework_target_student_ids($con, $homeworkId);
        if (empty($ids)) return [];

        $list = implode(',', array_map('intval', $ids));
        $res = @mysqli_query($con, "SELECT id, name FROM students WHERE id IN ({$list})");
        if (!$res) return [];

        $rows = [];
        while ($row = mysqli_fetch_assoc($res)) {
            $rows[] = ['id' => (int)$row['id'], 'name' => $row['name'] ?? ''];
        }

        return $rows;
    }
}

if (!function_exists('homework_student_may_see')) {
    /**
     * Whether this student is in a homework's audience.
     *
     * Subject access is checked by the caller; this answers only the second question. An untargeted
     * homework returns true for everyone, which is how the old behaviour survives untouched.
     */
    function homework_student_may_see($con, int $homeworkId, int $studentId): bool {
        $ids = homework_target_student_ids($con, $homeworkId);
        return empty($ids) || in_array($studentId, $ids, true);
    }
}

if (!function_exists('homework_sync_target_students')) {
    /**
     * Replaces a homework's audience with the given student ids.
     *
     * An empty array clears the targeting, which publishes the homework to the whole subject again -
     * so "for everyone" is reachable from the form rather than only at creation time.
     *
     * Students who cannot currently see the subject are reported back in $notEligible rather than
     * refused: the row would be harmless (a student still has to have the subject to see anything)
     * but silently keeping it would let a teacher believe they had sent work to someone who will
     * never be shown it.
     */
    function homework_sync_target_students($con, int $homeworkId, array $studentIds, ?array &$notEligible = null): bool {
        $notEligible = [];

        if ($homeworkId <= 0 || !homework_students_table_exists($con)) return false;

        $subjectStmt = mysqli_prepare($con, "SELECT subject_id FROM homework WHERE id = ? LIMIT 1");
        mysqli_stmt_bind_param($subjectStmt, "i", $homeworkId);
        mysqli_stmt_execute($subjectStmt);
        $subjectId = (int)(mysqli_fetch_assoc(mysqli_stmt_get_result($subjectStmt))['subject_id'] ?? 0);

        $clean = [];
        foreach ($studentIds as $raw) {
            $id = (int)$raw;
            if ($id > 0 && !in_array($id, $clean, true)) $clean[] = $id;
        }

        @mysqli_query($con, "DELETE FROM homework_students WHERE homework_id = " . (int)$homeworkId);

        if (empty($clean)) return true;

        // The eligibility rule is read from get_student_accessible_entities rather than rebuilt in
        // SQL here: it is the same function that decides what a student is shown, and a second
        // implementation of it would drift away from the first.
        require_once __DIR__ . '/../../user/student/subscriptions/manage.php';

        $insert = mysqli_prepare($con, "INSERT IGNORE INTO homework_students (homework_id, student_id) VALUES (?, ?)");
        if (!$insert) return false;

        foreach ($clean as $studentId) {
            $nameRes = @mysqli_query($con, "SELECT name FROM students WHERE id = " . (int)$studentId . " LIMIT 1");
            $name = $nameRes ? (mysqli_fetch_assoc($nameRes)['name'] ?? '') : '';
            if ($name === '' && (!$nameRes || mysqli_num_rows($nameRes) === 0)) {
                continue; // No such student; nothing to record and nothing to warn about.
            }

            if ($subjectId > 0 && function_exists('get_student_accessible_entities')) {
                $accessible = get_student_accessible_entities($con, $studentId);
                if (!in_array($subjectId, $accessible['subject_ids'] ?? [], true)) {
                    $notEligible[] = $name !== '' ? $name : ('#' . $studentId);
                }
            }

            mysqli_stmt_bind_param($insert, "ii", $homeworkId, $studentId);
            mysqli_stmt_execute($insert);
        }

        return true;
    }
}

if (!function_exists('homework_eligible_students')) {
    /**
     * The students who can currently see a subject - the audience a homework in that subject
     * would reach if it were not targeted, and therefore the list to pick from when targeting it.
     *
     * This is ONE aggregate query that mirrors the grant paths get_student_accessible_entities
     * walks per student: the subscription may name the subject directly, name a course that
     * belongs to it, or name a teacher who teaches it - and each of those three can arrive either
     * on the subscription itself or on the subscription code behind it.
     *
     * It is deliberately a picker, not an authority. Running the real function once per student
     * would cost thousands of queries to fill a dropdown; the save path still calls that function
     * for the handful of students actually chosen, so a name this query gets wrong is caught there
     * and reported rather than quietly acted on.
     */
    function homework_eligible_students($con, int $subjectId, string $search = '', int $limit = 200): array {
        if ($subjectId <= 0) return [];

        $now = date('Y-m-d H:i:s');
        $subject = (int)$subjectId;
        $limit = max(1, min(500, $limit));

        $activeSub = "(ss.is_active = 1 OR ss.is_active IS NULL)
            AND (ss.end_date IS NULL OR ss.end_date = '0000-00-00 00:00:00' OR ss.end_date = '0000-00-00' OR ss.end_date >= '{$now}')";

        // The courses and the teachers that carry this subject, named once and reused by both the
        // subscription paths and the code paths below.
        $coursesOfSubject = "SELECT id FROM courses WHERE subject_id = {$subject}";
        $teachersOfSubject = "SELECT teacher_id FROM teacher_subjects WHERE subject_id = {$subject}
            UNION SELECT teacher_id FROM courses WHERE subject_id = {$subject} AND teacher_id IS NOT NULL";

        $searchClause = '';
        if ($search !== '') {
            $pattern = '%' . mysqli_real_escape_string($con, $search) . '%';
            $searchClause = " AND (st.name LIKE '{$pattern}' OR st.email LIKE '{$pattern}' OR st.phone LIKE '{$pattern}')";
        }

        $sql = "
            SELECT DISTINCT st.id, st.name, st.email
            FROM student_subscriptions ss
            JOIN students st ON st.id = ss.student_id
            WHERE {$activeSub}
              AND (
                EXISTS (SELECT 1 FROM student_subscription_subjects x WHERE x.student_subscription_id = ss.id AND x.subject_id = {$subject})
                OR EXISTS (SELECT 1 FROM student_subscription_courses x WHERE x.student_subscription_id = ss.id AND x.course_id IN ({$coursesOfSubject}))
                OR EXISTS (SELECT 1 FROM student_subscription_teachers x WHERE x.student_subscription_id = ss.id AND x.teacher_id IN ({$teachersOfSubject}))
                OR (ss.subscription_code_id IS NOT NULL AND (
                    EXISTS (SELECT 1 FROM subscription_code_subjects x WHERE x.subscription_code_id = ss.subscription_code_id AND x.subject_id = {$subject})
                    OR EXISTS (SELECT 1 FROM subscription_code_courses x WHERE x.subscription_code_id = ss.subscription_code_id AND x.course_id IN ({$coursesOfSubject}))
                    OR EXISTS (SELECT 1 FROM subscription_code_teachers x WHERE x.subscription_code_id = ss.subscription_code_id AND x.teacher_id IN ({$teachersOfSubject}))
                ))
              )
              {$searchClause}
            ORDER BY st.name ASC
            LIMIT {$limit}
        ";

        $res = @mysqli_query($con, $sql);
        if (!$res) return [];

        $students = [];
        while ($row = mysqli_fetch_assoc($res)) {
            $students[] = [
                'id' => (int)$row['id'],
                'name' => $row['name'] ?? '',
                'email' => $row['email'] ?? '',
            ];
        }

        return $students;
    }
}

if (!function_exists('homeworkEligibleStudents')) {
    /** The picker's endpoint. Same answer for an admin and for a teacher: it is the subject's audience. */
    function homeworkEligibleStudents($con) {
        $subjectId = (int)($_GET['subject_id'] ?? 0);
        if ($subjectId <= 0) {
            return [
                'status' => 'error',
                'message' => app_text($con, 'رقم المادة مطلوب.', 'subject_id is required'),
            ];
        }

        $search = trim((string)($_GET['search'] ?? $_GET['q'] ?? ''));
        $limit = (int)($_GET['limit'] ?? 200);

        return [
            'status' => 'success',
            'data' => homework_eligible_students($con, $subjectId, $search, $limit),
        ];
    }
}

if (!function_exists('homework_targeting_notice')) {
    /**
     * Turns the ineligible-student list into a warning hung on an otherwise successful response.
     *
     * A warning rather than an error on purpose: the homework was saved, and failing the whole
     * request over one student who has not renewed their subscription would throw away work the
     * teacher had just typed.
     */
    function homework_targeting_notice($con, array $response, array $notEligible): array {
        if (empty($notEligible)) return $response;

        $names = implode('، ', $notEligible);

        $response['severity'] = 'warning';
        $response['message'] = app_text(
            $con,
            'تم الحفظ. لكن هؤلاء الطلاب غير مشتركين في هذه المادة حاليًا، فلن يظهر لهم الواجب: ' . $names,
            'Saved. These students are not currently subscribed to this subject, so the homework will not appear for them: ' . $names
        );
        $response['not_eligible'] = $notEligible;

        return $response;
    }
}

if (!function_exists('get_homework_details')) {
    function get_homework_details($con, int $homeworkId) {
        if ($homeworkId <= 0) return null;

        $stmt = mysqli_prepare($con, "SELECT id, teacher_id, subject_id, title, description, due_date, file_path, is_active, created_at FROM homework WHERE id = ? LIMIT 1");
        mysqli_stmt_bind_param($stmt, "i", $homeworkId);
        mysqli_stmt_execute($stmt);
        $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));
        if (!$row) return null;

        $row['id'] = (int)$row['id'];
        $row['teacher_id'] = (int)$row['teacher_id'];
        $row['subject_id'] = (int)$row['subject_id'];
        $row['is_active'] = (int)$row['is_active'];
        $row['subject'] = get_subject_details($con, $row['subject_id']);

        $cStmt = mysqli_prepare($con, "SELECT COUNT(*) AS total FROM homework_submissions WHERE homework_id = ?");
        mysqli_stmt_bind_param($cStmt, "i", $homeworkId);
        mysqli_stmt_execute($cStmt);
        $row['submissions_count'] = (int)(mysqli_fetch_assoc(mysqli_stmt_get_result($cStmt))['total'] ?? 0);

        // Added, never substituted: every field the app already reads is still here and still
        // means the same thing. `is_targeted` = 0 is the old behaviour (the whole subject), which
        // is also what an app that ignores these three fields will keep doing.
        $row['student_ids'] = homework_target_student_ids($con, $homeworkId);
        $row['students'] = homework_target_students($con, $homeworkId);
        $row['is_targeted'] = empty($row['student_ids']) ? 0 : 1;

        return format_response_images($row);
    }
}

if (!function_exists('teacherListHomework')) {
    function teacherListHomework($con, $teacherData) {
        $teacherId = (int)($teacherData['id'] ?? 0);
        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 10)));
        $offset = ($page - 1) * $limit;

        $statRes = mysqli_query($con, "SELECT COUNT(*) AS total FROM homework WHERE teacher_id = {$teacherId}");
        $totalRecords = (int)(mysqli_fetch_assoc($statRes)['total'] ?? 0);

        $stmt = mysqli_prepare($con, "SELECT id FROM homework WHERE teacher_id = ? ORDER BY id DESC LIMIT ? OFFSET ?");
        mysqli_stmt_bind_param($stmt, "iii", $teacherId, $limit, $offset);
        mysqli_stmt_execute($stmt);
        $res = mysqli_stmt_get_result($stmt);

        $items = [];
        while ($row = mysqli_fetch_assoc($res)) {
            $items[] = get_homework_details($con, (int)$row['id']);
        }

        return build_paginated_response($items, $page, $limit, $totalRecords);
    }
}

if (!function_exists('teacherCreateHomework')) {
    function teacherCreateHomework($con, $teacherData) {
        $teacherId = (int)($teacherData['id'] ?? 0);
        $body = read_json_body();

        $subjectId = (int)($body['subject_id'] ?? 0);
        $title = trim($body['title'] ?? '');
        $description = trim($body['description'] ?? '');
        $dueDate = !empty($body['due_date']) ? date('Y-m-d', strtotime($body['due_date'])) : null;
        $isActive = isset($body['is_active']) ? (int)$body['is_active'] : 1;

        if ($subjectId <= 0 || empty($title)) {
            return ['status' => 'error', 'message' => 'subject_id and title are required'];
        }

        $fileInput = $body['file'] ?? $body['file_path'] ?? null;
        $uploadedFile = $_FILES['file'] ?? $_FILES['pdf'] ?? null;
        $filePath = process_image_input($fileInput, 'homework', $uploadedFile);

        $stmt = mysqli_prepare($con, "INSERT INTO homework (teacher_id, subject_id, title, description, due_date, file_path, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)");
        mysqli_stmt_bind_param($stmt, "iissssi", $teacherId, $subjectId, $title, $description, $dueDate, $filePath, $isActive);
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
            'message' => 'Homework created successfully',
            'data' => get_homework_details($con, $homeworkId)
        ];

        return homework_targeting_notice($con, $response, $notEligible);
    }
}

if (!function_exists('teacherUpdateHomework')) {
    function teacherUpdateHomework($con, $teacherData) {
        $teacherId = (int)($teacherData['id'] ?? 0);
        $body = read_json_body();
        $id = (int)($body['id'] ?? 0);
        if ($id <= 0) return ['status' => 'error', 'message' => 'Homework ID is required'];

        $checkStmt = mysqli_prepare($con, "SELECT id FROM homework WHERE id = ? AND teacher_id = ? LIMIT 1");
        mysqli_stmt_bind_param($checkStmt, "ii", $id, $teacherId);
        mysqli_stmt_execute($checkStmt);
        if (!mysqli_fetch_assoc(mysqli_stmt_get_result($checkStmt))) {
            return ['status' => 'error', 'message' => 'Homework not found or not owned by you'];
        }

        $updateFields = [];
        $params = [];
        $types = "";

        if (isset($body['title'])) { $updateFields[] = "title = ?"; $params[] = trim($body['title']); $types .= "s"; }
        if (isset($body['description'])) { $updateFields[] = "description = ?"; $params[] = trim($body['description']); $types .= "s"; }
        if (isset($body['subject_id'])) { $updateFields[] = "subject_id = ?"; $params[] = (int)$body['subject_id']; $types .= "i"; }
        if (isset($body['due_date'])) { $updateFields[] = "due_date = ?"; $params[] = !empty($body['due_date']) ? date('Y-m-d', strtotime($body['due_date'])) : null; $types .= "s"; }
        if (isset($body['is_active'])) { $updateFields[] = "is_active = ?"; $params[] = (int)$body['is_active']; $types .= "i"; }

        $fileInput = $body['file'] ?? $body['file_path'] ?? null;
        $uploadedFile = $_FILES['file'] ?? $_FILES['pdf'] ?? null;
        $filePath = process_image_input($fileInput, 'homework', $uploadedFile);
        if ($filePath !== null) { $updateFields[] = "file_path = ?"; $params[] = $filePath; $types .= "s"; }

        if (!empty($updateFields)) {
            $params[] = $id;
            $types .= "i";
            $uStmt = mysqli_prepare($con, "UPDATE homework SET " . implode(", ", $updateFields) . " WHERE id = ?");
            mysqli_stmt_bind_param($uStmt, $types, ...$params);
            mysqli_stmt_execute($uStmt);
        }

        // Only touched when the key is sent. An older client that does not know about targeting
        // can still edit a title without silently publishing the homework to the whole subject.
        $notEligible = [];
        if (array_key_exists('student_ids', $body) && is_array($body['student_ids'])) {
            homework_sync_target_students($con, $id, $body['student_ids'], $notEligible);
        }

        $response = ['status' => 'success', 'message' => 'Homework updated successfully', 'data' => get_homework_details($con, $id)];

        return homework_targeting_notice($con, $response, $notEligible);
    }
}

if (!function_exists('teacherDeleteHomework')) {
    function teacherDeleteHomework($con, $teacherData) {
        $teacherId = (int)($teacherData['id'] ?? 0);
        $id = (int)($_GET['id'] ?? read_json_body()['id'] ?? 0);
        if ($id <= 0) return ['status' => 'error', 'message' => 'Homework ID is required'];

        $stmt = mysqli_prepare($con, "DELETE FROM homework WHERE id = ? AND teacher_id = ?");
        mysqli_stmt_bind_param($stmt, "ii", $id, $teacherId);
        if (mysqli_stmt_execute($stmt)) {
            @mysqli_query($con, "DELETE FROM homework_submissions WHERE homework_id = {$id}");
            return ['status' => 'success', 'message' => 'Homework deleted successfully'];
        }
        return ['status' => 'error', 'message' => 'Failed to delete homework'];
    }
}

if (!function_exists('get_submission_details')) {
    function get_submission_details($con, int $subId) {
        $stmt = mysqli_prepare($con, "SELECT hs.id, hs.homework_id, hs.student_id, hs.file_path, hs.status, hs.feedback_text, hs.feedback_rating, hs.submitted_at, hs.reviewed_at, s.name AS student_name, s.email AS student_email FROM homework_submissions hs JOIN students s ON hs.student_id = s.id WHERE hs.id = ? LIMIT 1");
        mysqli_stmt_bind_param($stmt, "i", $subId);
        mysqli_stmt_execute($stmt);
        $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));
        if (!$row) return null;
        $row['id'] = (int)$row['id'];
        $row['homework_id'] = (int)$row['homework_id'];
        $row['student_id'] = (int)$row['student_id'];
        $row['feedback_rating'] = $row['feedback_rating'] !== null ? (int)$row['feedback_rating'] : null;
        return format_response_images($row);
    }
}

if (!function_exists('teacherListHomeworkSubmissions')) {
    function teacherListHomeworkSubmissions($con, $teacherData) {
        $teacherId = (int)($teacherData['id'] ?? 0);
        $homeworkId = (int)($_GET['homework_id'] ?? 0);
        if ($homeworkId <= 0) return ['status' => 'error', 'message' => 'homework_id is required'];

        $checkStmt = mysqli_prepare($con, "SELECT id FROM homework WHERE id = ? AND teacher_id = ? LIMIT 1");
        mysqli_stmt_bind_param($checkStmt, "ii", $homeworkId, $teacherId);
        mysqli_stmt_execute($checkStmt);
        if (!mysqli_fetch_assoc(mysqli_stmt_get_result($checkStmt))) {
            return ['status' => 'error', 'message' => 'Homework not found or not owned by you'];
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

if (!function_exists('teacherGradeSubmission')) {
    function teacherGradeSubmission($con, $teacherData) {
        $teacherId = (int)($teacherData['id'] ?? 0);
        $body = read_json_body();
        $submissionId = (int)($body['submission_id'] ?? $body['id'] ?? 0);
        $feedbackText = trim($body['feedback_text'] ?? $body['feedback'] ?? '');
        $rating = isset($body['rating']) ? (int)$body['rating'] : null;

        if ($submissionId <= 0 || empty($feedbackText)) {
            return ['status' => 'error', 'message' => 'submission_id and feedback_text are required'];
        }

        $checkStmt = mysqli_prepare($con, "SELECT hs.id FROM homework_submissions hs JOIN homework h ON hs.homework_id = h.id WHERE hs.id = ? AND h.teacher_id = ? LIMIT 1");
        mysqli_stmt_bind_param($checkStmt, "ii", $submissionId, $teacherId);
        mysqli_stmt_execute($checkStmt);
        if (!mysqli_fetch_assoc(mysqli_stmt_get_result($checkStmt))) {
            return ['status' => 'error', 'message' => 'Submission not found or not owned by you'];
        }

        $stmt = mysqli_prepare($con, "UPDATE homework_submissions SET status = 'reviewed', feedback_text = ?, feedback_rating = ?, reviewed_at = NOW() WHERE id = ?");
        mysqli_stmt_bind_param($stmt, "sii", $feedbackText, $rating, $submissionId);
        mysqli_stmt_execute($stmt);

        return ['status' => 'success', 'message' => 'Feedback submitted successfully', 'data' => get_submission_details($con, $submissionId)];
    }
}
