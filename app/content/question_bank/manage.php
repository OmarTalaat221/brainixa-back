<?php
require_once __DIR__ . '/../../../helpers/functions.php';
require_once __DIR__ . '/../../../helpers/language.php';
require_once __DIR__ . '/../../../helpers/entities.php';
// format_response_images() lives in upload.php and app_text() in app_settings.php; both are called
// below, and neither is pulled in by the question handlers.
require_once __DIR__ . '/../../../helpers/upload.php';
require_once __DIR__ . '/../../../helpers/app_settings.php';
// get_json_input() and json_error() are defined there, as are the create/update/delete handlers
// the bank reuses for its questions.
require_once __DIR__ . '/../questions/manage.php';

/**
 * The question bank: a global pool of questions, filed in folders, that exams are built from.
 *
 * Two things only happen here that the ordinary question handlers do not already do - moving a
 * question between folders, and copying one into an exam. Creating, editing and deleting a bank
 * question goes through `adminCreateQuestion` / `adminUpdateQuestion` / `adminDeleteQuestion` with
 * `is_bank = 1`, so the bank gets every question type, every translation and every answer shape
 * for free, and cannot drift from how exam questions behave.
 *
 * Ownership: a teacher sees only the folders they created; an admin sees all of them.
 */

if (!function_exists('question_bank_actor')) {
    /**
     * Who is asking, as the ('admin'|'teacher', id) pair the `created_by_*` columns store.
     *
     * The teacher routes hand their own identity down; the admin routes pass nothing, and an admin
     * is never filtered by ownership anyway.
     */
    function question_bank_actor($actorData = null): array {
        if ($actorData && (isset($actorData['teacher_id']) || (isset($actorData['role_id']) && $actorData['role_id'] === 'teacher'))) {
            return ['teacher', (int)($actorData['id'] ?? $actorData['teacher_id'] ?? 0)];
        }
        return ['admin', (int)($actorData['id'] ?? 1)];
    }
}

if (!function_exists('question_bank_owner_sql')) {
    /**
     * The WHERE fragment that limits a teacher to their own folders. Empty for an admin, who sees
     * the whole bank.
     */
    function question_bank_owner_sql(?array $actorData, string $alias = 'f'): string {
        [$type, $id] = question_bank_actor($actorData);
        if ($type !== 'teacher') return '';
        return " AND {$alias}.created_by_type = 'teacher' AND {$alias}.created_by_id = " . (int)$id;
    }
}

if (!function_exists('question_bank_can_touch_folder')) {
    /**
     * True when this actor may write to this folder. An admin may touch any; a teacher only their
     * own. Returns false for a folder that does not exist, so callers get one check, not two.
     */
    function question_bank_can_touch_folder($con, int $folderId, ?array $actorData): bool {
        if ($folderId <= 0) return false;

        $row = mysqli_fetch_assoc(mysqli_query($con, "SELECT created_by_type, created_by_id FROM question_bank_folders WHERE id = {$folderId} LIMIT 1"));
        if (!$row) return false;

        [$type, $id] = question_bank_actor($actorData);
        if ($type !== 'teacher') return true;

        return $row['created_by_type'] === 'teacher' && (int)$row['created_by_id'] === $id;
    }
}

// =================================================================================================
// Folders
// =================================================================================================

if (!function_exists('questionBankListFolders')) {
    function questionBankListFolders($con, $actorData = null) {
        $search = trim($_GET['search'] ?? $_GET['q'] ?? '');

        $where = ["1=1"];
        if ($search !== '') {
            $sp = '%' . mysqli_real_escape_string($con, $search) . '%';
            $where[] = "f.name LIKE '{$sp}'";
        }
        $whereSql = implode(' AND ', $where) . question_bank_owner_sql($actorData, 'f');

        // The question count comes from the same query rather than one COUNT per folder, because
        // the folder list is the bank's front page and would otherwise cost a query per row.
        $res = mysqli_query($con, "
            SELECT f.id, f.name, f.description, f.is_active, f.created_by_type, f.created_by_id,
                   f.created_at, f.updated_at,
                   COALESCE(q.total, 0) AS questions_count
            FROM question_bank_folders f
            LEFT JOIN (
                -- Every question in the folder, inactive ones included. The badge has to
                -- agree with what opening the folder shows, and that listing is unfiltered
                -- until someone picks a status - a folder reading 80 that then lists 85 rows
                -- just looks broken.
                SELECT bank_folder_id, COUNT(*) AS total
                FROM questions
                WHERE is_bank = 1
                GROUP BY bank_folder_id
            ) q ON q.bank_folder_id = f.id
            WHERE {$whereSql}
            ORDER BY f.name ASC, f.id ASC
        ");

        $items = [];
        if ($res) {
            while ($r = mysqli_fetch_assoc($res)) {
                $items[] = [
                    'id' => (int)$r['id'],
                    'name' => $r['name'],
                    'description' => $r['description'],
                    'is_active' => (int)$r['is_active'],
                    'created_by_type' => $r['created_by_type'],
                    'created_by_id' => $r['created_by_id'] !== null ? (int)$r['created_by_id'] : null,
                    'questions_count' => (int)$r['questions_count'],
                    'created_at' => $r['created_at'],
                    'updated_at' => $r['updated_at'],
                ];
            }
        }

        return ['status' => 'success', 'data' => $items];
    }
}

if (!function_exists('questionBankCreateFolder')) {
    function questionBankCreateFolder($con, $actorData = null) {
        $input = get_json_input();
        $name = trim($input['name'] ?? '');
        if ($name === '') {
            return json_error(app_text($con, 'اسم الفولدر مطلوب.', 'A folder name is required.'), 422);
        }

        $description = trim($input['description'] ?? '');
        [$byType, $byId] = question_bank_actor($actorData);

        $stmt = mysqli_prepare($con, "INSERT INTO question_bank_folders (name, description, is_active, created_by_type, created_by_id) VALUES (?, ?, 1, ?, ?)");
        if (!$stmt) return json_error('Database error: ' . mysqli_error($con), 500);

        mysqli_stmt_bind_param($stmt, "sssi", $name, $description, $byType, $byId);
        if (!mysqli_stmt_execute($stmt)) {
            return json_error('Failed to create the folder: ' . mysqli_stmt_error($stmt), 500);
        }

        $id = (int)mysqli_insert_id($con);
        mysqli_stmt_close($stmt);

        return [
            'status' => 'success',
            'message' => app_text($con, 'تم إنشاء الفولدر.', 'Folder created.'),
            'data' => ['id' => $id, 'name' => $name, 'description' => $description, 'questions_count' => 0],
        ];
    }
}

if (!function_exists('questionBankUpdateFolder')) {
    function questionBankUpdateFolder($con, $actorData = null) {
        $input = get_json_input();
        $id = (int)($input['id'] ?? 0);

        if (!question_bank_can_touch_folder($con, $id, $actorData)) {
            return json_error(app_text($con, 'الفولدر ده مش موجود أو مش بتاعك.', 'That folder does not exist or is not yours.'), 404);
        }

        $existing = mysqli_fetch_assoc(mysqli_query($con, "SELECT name, description, is_active FROM question_bank_folders WHERE id = {$id} LIMIT 1"));

        $name = isset($input['name']) ? trim($input['name']) : $existing['name'];
        if ($name === '') {
            return json_error(app_text($con, 'اسم الفولدر مطلوب.', 'A folder name is required.'), 422);
        }
        $description = isset($input['description']) ? trim($input['description']) : $existing['description'];
        $isActive = isset($input['is_active']) ? (int)$input['is_active'] : (int)$existing['is_active'];

        $stmt = mysqli_prepare($con, "UPDATE question_bank_folders SET name = ?, description = ?, is_active = ? WHERE id = ?");
        if (!$stmt) return json_error('Database error: ' . mysqli_error($con), 500);

        mysqli_stmt_bind_param($stmt, "ssii", $name, $description, $isActive, $id);
        mysqli_stmt_execute($stmt);
        mysqli_stmt_close($stmt);

        return ['status' => 'success', 'message' => app_text($con, 'تم تحديث الفولدر.', 'Folder updated.')];
    }
}

if (!function_exists('questionBankDeleteFolder')) {
    /**
     * Deleting a folder deletes the questions filed in it - the FK is ON DELETE CASCADE. Exams
     * built from those questions are untouched, because each one owns its own copy.
     *
     * The count is reported back so the dashboard can say what it is about to destroy.
     */
    function questionBankDeleteFolder($con, $actorData = null) {
        $input = get_json_input();
        $id = (int)($input['id'] ?? $_GET['id'] ?? 0);

        if (!question_bank_can_touch_folder($con, $id, $actorData)) {
            return json_error(app_text($con, 'الفولدر ده مش موجود أو مش بتاعك.', 'That folder does not exist or is not yours.'), 404);
        }

        $countRow = mysqli_fetch_assoc(mysqli_query($con, "SELECT COUNT(*) AS total FROM questions WHERE is_bank = 1 AND bank_folder_id = {$id}"));
        $removed = (int)($countRow['total'] ?? 0);

        if (!mysqli_query($con, "DELETE FROM question_bank_folders WHERE id = {$id}")) {
            return json_error('Failed to delete the folder: ' . mysqli_error($con), 500);
        }

        return [
            'status' => 'success',
            'message' => app_text($con, 'تم حذف الفولدر.', 'Folder deleted.'),
            'data' => ['deleted_questions' => $removed],
        ];
    }
}

if (!function_exists('question_bank_identical_in_exam_sql')) {
    /**
     * An SQL EXISTS clause answering: does this exam already hold a question identical to the bank
     * question at `$bankRef` (an expression - "q.id" in a listing, a literal id in a guard)?
     *
     * IDENTICAL means three things, and deliberately not a fourth:
     *
     *   1. the same question type;
     *   2. the same text, character for character, in every language it is written in;
     *   3. the same CORRECT answer - the right option's text for an mcq, the true/false value,
     *      the model answer for a written one.
     *
     * The WRONG options are not compared. Rewording a distractor does not make it another
     * question, so a bank question whose decoys were tidied up still counts as the one already in
     * the exam. Change the right answer and it becomes a different question again.
     *
     * COLLATE utf8mb4_bin throughout: the columns' own utf8mb4_unicode_ci calls two strings equal
     * when they differ only by a diacritic or a kashida, and the rule is that one changed letter
     * makes it a different question.
     *
     * The mcq check runs in both directions so that adding or removing a correct option counts as
     * a change, not just editing one.
     */
    function question_bank_identical_in_exam_sql(int $examId, string $bankRef): string {
        $bin = 'COLLATE utf8mb4_bin';

        return "EXISTS (
            SELECT 1 FROM questions eq
            WHERE eq.exam_id = {$examId}
              AND eq.is_bank = 0
              AND eq.question_type = (SELECT bq.question_type FROM questions bq WHERE bq.id = {$bankRef})

              -- The text, in every language the bank question has.
              AND NOT EXISTS (
                  SELECT 1 FROM questions_translations bt
                  LEFT JOIN questions_translations et
                         ON et.question_id = eq.id AND et.language_id = bt.language_id
                  WHERE bt.question_id = {$bankRef}
                    AND (et.question_text IS NULL
                         OR et.question_text {$bin} <> bt.question_text {$bin})
              )

              -- true/false: the answer itself. -1 stands in for 'no row', so a question missing
              -- its answer never matches one that has it.
              AND COALESCE((SELECT tf.correct_answer FROM true_false_answers tf
                             WHERE tf.question_id = eq.id LIMIT 1), -1)
                = COALESCE((SELECT tf2.correct_answer FROM true_false_answers tf2
                             WHERE tf2.question_id = {$bankRef} LIMIT 1), -1)

              -- written: the model answer, in every language.
              AND NOT EXISTS (
                  SELECT 1 FROM written_model_answers bwa
                  JOIN written_model_answers_translations bmt
                       ON bmt.written_model_answer_id = bwa.id
                  WHERE bwa.question_id = {$bankRef}
                    AND NOT EXISTS (
                        SELECT 1 FROM written_model_answers ewa
                        JOIN written_model_answers_translations emt
                             ON emt.written_model_answer_id = ewa.id
                        WHERE ewa.question_id = eq.id
                          AND emt.language_id = bmt.language_id
                          AND emt.model_answer {$bin} = bmt.model_answer {$bin}
                    )
              )

              -- mcq: every correct option of the bank question is a correct option of the exam's.
              AND NOT EXISTS (
                  SELECT 1 FROM mcq_options bmo
                  JOIN mcq_options_translations bot ON bot.mcq_option_id = bmo.id
                  WHERE bmo.question_id = {$bankRef} AND bmo.is_correct = 1
                    AND NOT EXISTS (
                        SELECT 1 FROM mcq_options emo
                        JOIN mcq_options_translations eot ON eot.mcq_option_id = emo.id
                        WHERE emo.question_id = eq.id AND emo.is_correct = 1
                          AND eot.language_id = bot.language_id
                          AND eot.option_text {$bin} = bot.option_text {$bin}
                    )
              )
              -- ...and the other way round, so an added or removed right answer is a change too.
              AND NOT EXISTS (
                  SELECT 1 FROM mcq_options emo
                  JOIN mcq_options_translations eot ON eot.mcq_option_id = emo.id
                  WHERE emo.question_id = eq.id AND emo.is_correct = 1
                    AND NOT EXISTS (
                        SELECT 1 FROM mcq_options bmo
                        JOIN mcq_options_translations bot ON bot.mcq_option_id = bmo.id
                        WHERE bmo.question_id = {$bankRef} AND bmo.is_correct = 1
                          AND bot.language_id = eot.language_id
                          AND bot.option_text {$bin} = eot.option_text {$bin}
                    )
              )
        )";
    }
}

// =================================================================================================
// Listing the questions in a folder
// =================================================================================================

if (!function_exists('questionBankListQuestions')) {
    /**
     * The questions in one folder, as a flat list built for picking from.
     *
     * Deliberately NOT `adminListQuestions`, which calls `adminGetQuestionDetails` once per row -
     * and that in turn queries translations, options and model answers separately. Listing a
     * hundred-question folder through it costs several hundred queries, which is exactly what the
     * "tick the ones you want" screen does on every page change.
     *
     * This is two queries total: one count, one page. The option list is not fetched at all,
     * because the picker shows the question text and type - a caller that wants everything about
     * one question already has `/questions/show`.
     */
    function questionBankListQuestions($con, $actorData = null) {
        $langInfo = get_language_info($con);
        $langId = (int)($langInfo['id'] ?? 1);

        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 20)));
        $offset = ($page - 1) * $limit;

        $folderId = isset($_GET['folder_id']) ? (int)$_GET['folder_id'] : (int)($_GET['bank_folder_id'] ?? 0);
        // When the caller names an exam, every row says whether that exam already holds an
        // identical question, so the picker can show it as taken instead of letting someone add
        // the same question twice.
        $examId = isset($_GET['exam_id']) ? (int)$_GET['exam_id'] : 0;
        $search = trim($_GET['search'] ?? $_GET['q'] ?? '');
        $questionType = in_array(trim($_GET['question_type'] ?? ''), ['mcq', 'true_false', 'written'], true) ? trim($_GET['question_type']) : '';

        $where = ["q.is_bank = 1"];
        if ($folderId > 0) $where[] = "q.bank_folder_id = {$folderId}";
        if ($questionType !== '') $where[] = "q.question_type = '{$questionType}'";
        if (isset($_GET['is_active']) && $_GET['is_active'] !== '') {
            $where[] = "q.is_active = " . ((int)$_GET['is_active'] === 1 ? 1 : 0);
        }
        if ($search !== '') {
            $sp = '%' . mysqli_real_escape_string($con, $search) . '%';
            $where[] = "EXISTS (SELECT 1 FROM questions_translations qt WHERE qt.question_id = q.id AND qt.question_text LIKE '{$sp}')";
        }
        // The join to folders is what enforces ownership: a teacher never sees a question filed in
        // someone else's folder, whichever folder id they ask for.
        $whereSql = implode(' AND ', $where) . question_bank_owner_sql($actorData, 'f');

        $countRow = mysqli_fetch_assoc(mysqli_query($con, "
            SELECT COUNT(*) AS total
            FROM questions q
            JOIN question_bank_folders f ON f.id = q.bank_folder_id
            WHERE {$whereSql}
        "));
        $total = (int)($countRow['total'] ?? 0);

        // The text is read through subqueries rather than a second LEFT JOIN plus GROUP BY: a
        // question has one translation row per language, so joining them would multiply the rows
        // and the GROUP BY that hid it would then depend on ONLY_FULL_GROUP_BY being off. This
        // way each question is one row no matter how many languages it was written in, and the
        // fallback to any other language is explicit.
        $alreadySql = $examId > 0
            ? question_bank_identical_in_exam_sql($examId, 'q.id')
            : '0';

        $res = mysqli_query($con, "
            SELECT q.id, q.question_type, q.score, q.is_active, q.order_num, q.question_image,
                   q.bank_folder_id, f.name AS folder_name,
                   {$alreadySql} AS already_in_exam,
                   COALESCE(
                       (SELECT qt.question_text FROM questions_translations qt
                         WHERE qt.question_id = q.id AND qt.language_id = {$langId} LIMIT 1),
                       (SELECT qt2.question_text FROM questions_translations qt2
                         WHERE qt2.question_id = q.id LIMIT 1),
                       ''
                   ) AS question_text
            FROM questions q
            JOIN question_bank_folders f ON f.id = q.bank_folder_id
            WHERE {$whereSql}
            ORDER BY q.order_num ASC, q.id ASC
            LIMIT {$limit} OFFSET {$offset}
        ");

        $items = [];
        if ($res) {
            while ($r = mysqli_fetch_assoc($res)) {
                $items[] = format_response_images([
                    'id' => (int)$r['id'],
                    'question_text' => $r['question_text'],
                    'question_type' => $r['question_type'],
                    'question_image' => $r['question_image'],
                    'score' => (float)$r['score'],
                    'is_active' => (int)$r['is_active'],
                    'order_num' => (int)$r['order_num'],
                    'bank_folder_id' => (int)$r['bank_folder_id'],
                    'folder_name' => $r['folder_name'],
                    'already_in_exam' => (int)$r['already_in_exam'] === 1,
                ]);
            }
        }

        return build_admin_paginated_response($items, $page, $limit, $total);
    }
}

// =================================================================================================
// Moving a question between folders
// =================================================================================================

if (!function_exists('questionBankMoveQuestion')) {
    /**
     * Moves one or many questions into a folder. Takes `question_ids` (an array) or a single
     * `question_id`, so a multi-select moves in one request rather than one request per tick.
     */
    function questionBankMoveQuestion($con, $actorData = null) {
        $input = get_json_input();
        $targetFolderId = (int)($input['bank_folder_id'] ?? $input['folder_id'] ?? 0);

        $ids = $input['question_ids'] ?? $input['question_id'] ?? $input['id'] ?? [];
        if (!is_array($ids)) $ids = [$ids];
        $ids = array_values(array_unique(array_filter(array_map('intval', $ids), function ($v) { return $v > 0; })));

        if (!$ids || $targetFolderId <= 0) {
            return json_error(app_text($con, 'محتاج الأسئلة والفولدر اللي هتنتقل ليه.', 'Both the questions and the destination folder are required.'), 422);
        }

        // The destination is checked once; the sources are checked as a set below.
        if (!question_bank_can_touch_folder($con, $targetFolderId, $actorData)) {
            return json_error(app_text($con, 'الفولدر ده مش موجود أو مش بتاعك.', 'That folder does not exist or is not yours.'), 404);
        }

        // One query decides the whole batch. A teacher may not move a question out of someone
        // else's folder, so the join to folders carries the ownership filter.
        $idList = implode(',', $ids);
        $ownerSql = question_bank_owner_sql($actorData, 'f');
        $movable = [];
        $permRes = mysqli_query($con, "
            SELECT q.id
            FROM questions q
            JOIN question_bank_folders f ON f.id = q.bank_folder_id
            WHERE q.is_bank = 1 AND q.bank_folder_id <> {$targetFolderId} AND q.id IN ({$idList}){$ownerSql}
        ");
        if ($permRes) {
            while ($r = mysqli_fetch_assoc($permRes)) {
                $movable[] = (int)$r['id'];
            }
        }

        if (!$movable) {
            return ['status' => 'success', 'message' => app_text($con, 'مفيش سؤال محتاج ينتقل.', 'Nothing needed moving.'), 'data' => ['moved' => 0]];
        }

        // They land at the end of the destination folder rather than keeping positions that
        // belonged to a different folder's ordering. Numbered in one UPDATE: the row's position in
        // the batch is added to whatever the folder's highest order already is.
        $nextRow = mysqli_fetch_assoc(mysqli_query($con, "SELECT COALESCE(MAX(order_num), 0) AS max_order FROM questions WHERE is_bank = 1 AND bank_folder_id = {$targetFolderId}"));
        $base = (int)($nextRow['max_order'] ?? 0);

        $cases = [];
        foreach ($movable as $i => $qid) {
            $cases[] = "WHEN {$qid} THEN " . ($base + $i + 1);
        }
        $caseSql = implode(' ', $cases);
        $movableList = implode(',', $movable);

        if (!mysqli_query($con, "
            UPDATE questions
            SET bank_folder_id = {$targetFolderId},
                order_num = CASE id {$caseSql} END
            WHERE id IN ({$movableList})
        ")) {
            return json_error('Failed to move the questions: ' . mysqli_error($con), 500);
        }

        $moved = count($movable);
        return [
            'status' => 'success',
            'message' => app_text($con, 'تم نقل ' . $moved . ' سؤال.', 'Moved ' . $moved . ' question(s).'),
            'data' => ['moved' => $moved, 'moved_question_ids' => $movable],
        ];
    }
}

// =================================================================================================
// Copying a bank question into an exam
// =================================================================================================

if (!function_exists('question_bank_duplicate_into_exam')) {
    /**
     * Copies one bank question, and everything hanging off it, into an exam. Returns the new
     * question's id, or 0 if the row could not be written.
     *
     * A copy and not a link, deliberately: the exam's question is its own row from this moment on.
     * Editing the bank original later cannot rewrite an exam a student has already answered, and
     * `exam_attempt_answers` keeps pointing at exactly the question that was asked.
     *
     * The copy inherits the EXAM's course, unit and subject - the bank original has none of them.
     */
    function question_bank_duplicate_into_exam($con, int $bankQuestionId, int $examId, array $examRow, int $orderNum, ?string &$failure = null): int {
        $failure = null;

        $src = mysqli_fetch_assoc(mysqli_query($con, "SELECT question_type, question_image, score, is_active FROM questions WHERE id = {$bankQuestionId} AND is_bank = 1 LIMIT 1"));
        if (!$src) {
            $failure = 'the bank question no longer exists';
            return 0;
        }

        $courseId = !empty($examRow['course_id']) ? (int)$examRow['course_id'] : null;
        $unitId = !empty($examRow['unit_id']) ? (int)$examRow['unit_id'] : null;
        $subjectId = !empty($examRow['subject_id']) ? (int)$examRow['subject_id'] : null;

        $qType = $src['question_type'];
        $qImage = (string)($src['question_image'] ?? '');
        $score = (float)$src['score'];
        $isActive = (int)$src['is_active'];

        $stmt = mysqli_prepare($con, "INSERT INTO questions (exam_id, is_bank, bank_folder_id, course_id, unit_id, subject_id, question_type, question_image, order_num, score, is_active, created_by_type, created_by_id) SELECT ?, 0, NULL, ?, ?, ?, ?, ?, ?, ?, ?, created_by_type, created_by_id FROM questions WHERE id = ?");
        if (!$stmt) {
            // Swallowing this is what made the failure impossible to explain from outside: the
            // screen said "no question could be added" and the reason died right here.
            $failure = mysqli_error($con) ?: 'the insert could not be prepared';
            return 0;
        }

        mysqli_stmt_bind_param($stmt, "iiiissidii", $examId, $courseId, $unitId, $subjectId, $qType, $qImage, $orderNum, $score, $isActive, $bankQuestionId);
        if (!mysqli_stmt_execute($stmt)) {
            $failure = mysqli_stmt_error($stmt) ?: mysqli_error($con) ?: 'the insert was refused';
            mysqli_stmt_close($stmt);
            return 0;
        }
        $newId = (int)mysqli_insert_id($con);
        mysqli_stmt_close($stmt);

        // The question text, in every language it was written in.
        mysqli_query($con, "
            INSERT INTO questions_translations (question_id, language_id, question_text)
            SELECT {$newId}, language_id, question_text FROM questions_translations WHERE question_id = {$bankQuestionId}
        ");

        if ($qType === 'mcq') {
            // Options are copied one at a time because each one's translations hang off the id the
            // insert generates - a set-based copy would have nothing to attach them to.
            $optRes = mysqli_query($con, "SELECT id, option_key, option_image, is_correct, is_active FROM mcq_options WHERE question_id = {$bankQuestionId} ORDER BY id ASC");
            if ($optRes) {
                while ($opt = mysqli_fetch_assoc($optRes)) {
                    $oldOptId = (int)$opt['id'];
                    $optStmt = mysqli_prepare($con, "INSERT INTO mcq_options (question_id, option_key, option_image, is_correct, is_active) VALUES (?, ?, ?, ?, ?)");
                    if (!$optStmt) continue;

                    $optKey = (string)$opt['option_key'];
                    $optImage = (string)($opt['option_image'] ?? '');
                    $isCorrect = (int)$opt['is_correct'];
                    $optActive = (int)$opt['is_active'];

                    mysqli_stmt_bind_param($optStmt, "issii", $newId, $optKey, $optImage, $isCorrect, $optActive);
                    mysqli_stmt_execute($optStmt);
                    $newOptId = (int)mysqli_insert_id($con);
                    mysqli_stmt_close($optStmt);

                    mysqli_query($con, "
                        INSERT INTO mcq_options_translations (mcq_option_id, language_id, option_text)
                        SELECT {$newOptId}, language_id, option_text FROM mcq_options_translations WHERE mcq_option_id = {$oldOptId}
                    ");
                }
            }
        } elseif ($qType === 'true_false') {
            mysqli_query($con, "
                INSERT INTO true_false_answers (question_id, correct_answer, is_active)
                SELECT {$newId}, correct_answer, is_active FROM true_false_answers WHERE question_id = {$bankQuestionId}
            ");
        } elseif ($qType === 'written') {
            $srcAns = mysqli_fetch_assoc(mysqli_query($con, "SELECT id, is_active FROM written_model_answers WHERE question_id = {$bankQuestionId} LIMIT 1"));
            if ($srcAns) {
                $oldAnsId = (int)$srcAns['id'];
                $ansActive = (int)$srcAns['is_active'];
                mysqli_query($con, "INSERT INTO written_model_answers (question_id, is_active) VALUES ({$newId}, {$ansActive})");
                $newAnsId = (int)mysqli_insert_id($con);

                mysqli_query($con, "
                    INSERT INTO written_model_answers_translations (written_model_answer_id, language_id, model_answer)
                    SELECT {$newAnsId}, language_id, model_answer FROM written_model_answers_translations WHERE written_model_answer_id = {$oldAnsId}
                ");
            }
        }

        return $newId;
    }
}

if (!function_exists('questionBankCopyToExam')) {
    /**
     * Copies one or more bank questions into an exam. Takes `question_ids` (an array) or a single
     * `question_id`, so the dashboard can tick several and add them in one go.
     */
    function questionBankCopyToExam($con, $actorData = null) {
        $input = get_json_input();
        $examId = (int)($input['exam_id'] ?? 0);

        $ids = $input['question_ids'] ?? $input['question_id'] ?? [];
        if (!is_array($ids)) $ids = [$ids];
        $ids = array_values(array_unique(array_filter(array_map('intval', $ids), function ($v) { return $v > 0; })));

        if ($examId <= 0 || !$ids) {
            return json_error(app_text($con, 'محتاج الامتحان والأسئلة اللي هتتضاف.', 'Both the exam and the questions to add are required.'), 422);
        }

        $examRow = mysqli_fetch_assoc(mysqli_query($con, "SELECT id, course_id, unit_id, subject_id FROM course_exams WHERE id = {$examId} LIMIT 1"));
        if (!$examRow) {
            return json_error(app_text($con, 'الامتحان ده مش موجود.', 'That exam does not exist.'), 404);
        }

        // An exam can outlive the course it belongs to. `course_exams` has no foreign key to
        // `courses`, so deleting a course leaves its exams behind pointing at an id that is gone -
        // while `questions.course_id` DOES have that key. Every insert into such an exam is then
        // refused by the database, and the exam can never hold a question again, however many
        // times an admin ticks the boxes.
        //
        // Checked here, before anything is attempted, so the screen can say what is actually
        // wrong instead of reporting that the questions could not be copied. The same goes for a
        // deleted unit: the unit key is ON DELETE SET NULL, which clears the exam's own column but
        // does nothing for a row being inserted now.
        $missing = [];

        $examCourseId = (int)($examRow['course_id'] ?? 0);
        if ($examCourseId > 0 && !mysqli_fetch_assoc(mysqli_query($con, "SELECT id FROM courses WHERE id = {$examCourseId} LIMIT 1"))) {
            $missing[] = app_text(
                $con,
                'الكورس المرتبط بالامتحان ده (رقم ' . $examCourseId . ') مش موجود - يبدو إنه اتمسح والامتحان فضل مكانه.',
                'The course this exam belongs to (id ' . $examCourseId . ') no longer exists - it looks deleted, and the exam was left behind.'
            );
        }

        $examUnitId = (int)($examRow['unit_id'] ?? 0);
        if ($examUnitId > 0 && !mysqli_fetch_assoc(mysqli_query($con, "SELECT id FROM units WHERE id = {$examUnitId} LIMIT 1"))) {
            $missing[] = app_text(
                $con,
                'الوحدة المرتبطة بالامتحان ده (رقم ' . $examUnitId . ') مش موجودة.',
                'The unit this exam belongs to (id ' . $examUnitId . ') no longer exists.'
            );
        }

        if ($missing) {
            return [
                'status' => 'success',
                'severity' => 'warning',
                'message' => implode(' ', $missing) . ' ' . app_text(
                    $con,
                    'عشان كده مفيش سؤال ينفع يتضاف للامتحان ده، والطالب أصلًا مش بيشوفه. امسح الامتحان أو اعمله من جديد تحت كورس موجود.',
                    'That is why no question can be added to this exam, and why no student can reach it either. Delete the exam, or recreate it under a course that exists.'
                ),
                'data' => [
                    'copied_question_ids' => [],
                    'exam_is_orphaned' => true,
                    'missing_course_id' => $examCourseId,
                    'missing_unit_id' => $examUnitId,
                ],
            ];
        }

        $nextRow = mysqli_fetch_assoc(mysqli_query($con, "SELECT COALESCE(MAX(order_num), 0) + 1 AS next_order FROM questions WHERE exam_id = {$examId}"));
        $orderNum = (int)($nextRow['next_order'] ?? 1);

        // Which of these ids this actor is actually allowed to copy, settled in ONE query for the
        // whole batch. Checking per question meant two queries each before any copying began, so
        // ticking fifty questions cost a hundred round trips to decide nothing.
        $idList = implode(',', $ids);
        $ownerSql = question_bank_owner_sql($actorData, 'f');
        $allowed = [];
        $permRes = mysqli_query($con, "
            SELECT q.id
            FROM questions q
            JOIN question_bank_folders f ON f.id = q.bank_folder_id
            WHERE q.is_bank = 1 AND q.id IN ({$idList}){$ownerSql}
        ");
        if ($permRes) {
            while ($r = mysqli_fetch_assoc($permRes)) {
                $allowed[(int)$r['id']] = true;
            }
        }

        // Questions this exam already holds, character for character, in every language. Skipped
        // rather than copied: the picker greys these out, but the bank screen's own "add to exam"
        // chooses the exam after the questions and cannot, so the rule is enforced here instead of
        // relying on the UI to prevent it.
        $duplicate = [];
        $dupRes = mysqli_query($con, "
            SELECT q.id
            FROM questions q
            WHERE q.is_bank = 1 AND q.id IN ({$idList})
              AND " . question_bank_identical_in_exam_sql($examId, 'q.id') . "
        ");
        if ($dupRes) {
            while ($r = mysqli_fetch_assoc($dupRes)) {
                $duplicate[(int)$r['id']] = true;
            }
        }

        $copied = [];
        $notAllowed = [];
        $failed = [];
        $failures = [];
        $skippedDuplicates = [];
        foreach ($ids as $bankId) {
            if (!empty($duplicate[$bankId])) {
                $skippedDuplicates[] = $bankId;
                continue;
            }
            if (empty($allowed[$bankId])) {
                $notAllowed[] = $bankId;
                continue;
            }

            $why = null;
            $newId = question_bank_duplicate_into_exam($con, $bankId, $examId, $examRow, $orderNum, $why);
            if ($newId > 0) {
                $copied[] = $newId;
                $orderNum++;
            } else {
                $failed[] = $bankId;
                if ($why) $failures[] = $why;
            }
        }

        $dupCount = count($skippedDuplicates);

        if (!$copied) {
            // Nothing being added is almost never a broken request, so none of these answer with
            // an error. An error makes an admin think the platform is down, when the commonest
            // case by far is that the exam already holds the questions they ticked.
            //
            // `severity` rides along so the dashboard can pick the right colour without parsing
            // the sentence, and every branch stays `success`: the request was understood and
            // carried out, there was simply nothing left for it to do.
            $parts = [];

            if ($dupCount) {
                $parts[] = app_text(
                    $con,
                    $dupCount . ' سؤال منهم موجود في الامتحان بالفعل بنفس النصّ ونفس الإجابة الصحيحة، فاتساب زي ما هو.',
                    $dupCount . ' of them are already in this exam, word for word and with the same correct answer, so they were left alone.'
                );
            }

            if ($notAllowed) {
                $parts[] = app_text(
                    $con,
                    count($notAllowed) . ' سؤال مش في بنك أسئلة تقدر تقرأه، أو اتشال من البنك، فمينفعش يتنسخ.',
                    count($notAllowed) . ' are not in a bank folder you can read, or were removed from the bank, so they could not be copied.'
                );
            }

            if ($failed) {
                $detail = $failures ? ' (' . implode(' | ', array_unique($failures)) . ')' : '';
                $parts[] = app_text(
                    $con,
                    'قاعدة البيانات رفضت نسخ ' . count($failed) . ' سؤال' . $detail . '.',
                    'The database refused to copy ' . count($failed) . ' question(s)' . $detail . '.'
                );
            }

            if (!$parts) {
                $parts[] = app_text($con, 'مفيش سؤال محدَّد ينفع يتضاف.', 'None of the selected questions could be added.');
            }

            return [
                'status' => 'success',
                'severity' => 'warning',
                'message' => app_text($con, 'مفيش حاجة اتضافت. ', 'Nothing was added. ') . implode(' ', $parts),
                'data' => [
                    'copied_question_ids' => [],
                    'skipped_duplicate_ids' => $skippedDuplicates,
                    'not_allowed_ids' => $notAllowed,
                    'failed_ids' => $failed,
                    'failure_reasons' => array_values(array_unique($failures)),
                ],
            ];
        }

        $message = app_text(
            $con,
            'تم إضافة ' . count($copied) . ' سؤال للامتحان.',
            'Added ' . count($copied) . ' question(s) to the exam.'
        );
        if ($dupCount) {
            $message .= ' ' . app_text(
                $con,
                'و' . $dupCount . ' سؤال كان موجود قبل كده فاتساب زي ما هو.',
                $dupCount . ' already in the exam were left alone.'
            );
        }

        return [
            'status' => 'success',
            'message' => $message,
            'data' => [
                'copied_question_ids' => $copied,
                'skipped_question_ids' => $skipped,
                'skipped_duplicate_ids' => $skippedDuplicates,
            ],
        ];
    }
}
