<?php

/**
 * What a teacher owns, defined once.
 *
 * Moved here from app/teacher/books/manage.php so that code outside the teacher's book screens -
 * discount codes, first of all - asks the same question and gets the same answer. The discount
 * helper had its own two-route version of "this teacher's book", while the store listing used all
 * seven routes below. The result: a teacher's own product, listed on their own store screen, was
 * refused as "not yours" the moment they tried to put a discount code on it.
 *
 * Since migration 131 there are two different questions here, and they must not be mixed:
 *   - a STORE ITEM is a `products` row, and a teacher owns it when they created it or are
 *     assigned to it in `book_teachers` (teacher_store_item_ownership_clause and friends);
 *   - a LESSON FILE is a `course_books` row, owned through its course/unit/subject
 *     (teacher_book_ownership_clause, unchanged).
 * The two id ranges never overlap (course_books continues from 1,000,000), so a `book_id` column
 * that may hold either still answers both questions correctly.
 */

if (!function_exists('teacher_store_item_ownership_clause')) {
    /**
     * "This teacher's store item" as a SQL condition over a `products` alias. The same rule as
     * store_item_owner_teacher_ids(): its creator when that was a teacher, or an active
     * `book_teachers` assignment - nothing else. A subject the teacher happens to teach no longer
     * makes another teacher's product theirs.
     */
    function teacher_store_item_ownership_clause(int $teacherId, string $alias = 'p'): string {
        return "(
            ({$alias}.created_by_type = 'teacher' AND {$alias}.created_by_id = {$teacherId})
            OR {$alias}.id IN (SELECT book_id FROM book_teachers WHERE teacher_id = {$teacherId} AND is_active = 1)
        )";
    }
}

if (!function_exists('teacher_owned_store_item_ids')) {
    /** Every `products` id this teacher owns, by teacher_store_item_ownership_clause(). One query. */
    function teacher_owned_store_item_ids($con, int $teacherId): array {
        if ($teacherId <= 0) return [];
        $ids = [];
        $res = @mysqli_query($con, "SELECT p.id FROM products p WHERE " . teacher_store_item_ownership_clause($teacherId, 'p'));
        while ($res && ($row = mysqli_fetch_assoc($res))) {
            $ids[] = (int)$row['id'];
        }
        return $ids;
    }
}

if (!function_exists('teacher_owns_store_item')) {
    function teacher_owns_store_item($con, int $teacherId, int $itemId): bool {
        if ($teacherId <= 0 || $itemId <= 0) return false;
        $res = @mysqli_query($con, "SELECT p.id FROM products p WHERE p.id = {$itemId} AND " . teacher_store_item_ownership_clause($teacherId, 'p') . " LIMIT 1");
        return $res && mysqli_num_rows($res) > 0;
    }
}

if (!function_exists('teacher_book_ownership_clause')) {
    /**
     * "This teacher's LESSON FILE", as a SQL condition over the alias `cb` (course_books). Store
     * items are not in course_books any more; use teacher_store_item_ownership_clause() for them.
     *
     * It exists because the listing and the review check used to disagree: the list matched eight
     * ownership routes, the review only three, so a teacher saw purchase requests with a working
     * Approve button that always came back "You are not authorized to review this book request".
     * Both now call this, so what is shown is exactly what can be acted on.
     *
     * Note the `created_by_type = 'teacher'` guard on the creator test. Without it the condition
     * is `created_by_id = <teacher id>` alone, which also matches books created by the *admin*
     * whose id happens to equal this teacher's — ids are only unique within their own table.
     */
    function teacher_book_ownership_clause(int $teacherId): string {
        return "(
            (cb.created_by_type = 'teacher' AND cb.created_by_id = {$teacherId})
            OR cb.id IN (SELECT book_id FROM book_teachers WHERE teacher_id = {$teacherId} AND is_active = 1)
            OR cb.course_id IN (SELECT id FROM courses WHERE teacher_id = {$teacherId} OR (created_by_type = 'teacher' AND created_by_id = {$teacherId}))
            OR cb.course_id IN (SELECT course_id FROM course_teachers WHERE teacher_id = {$teacherId} AND is_active = 1)
            OR cb.unit_id IN (SELECT id FROM units WHERE (created_by_type = 'teacher' AND created_by_id = {$teacherId}))
            OR cb.unit_id IN (SELECT unit_id FROM unit_teachers WHERE teacher_id = {$teacherId} AND is_active = 1)
            OR cb.subject_id IN (SELECT subject_id FROM teacher_subjects WHERE teacher_id = {$teacherId})
        )";
    }
}

if (!function_exists('teacher_owned_lesson_file_ids')) {
    /** Every course_books (lesson file) id this teacher owns, by teacher_book_ownership_clause(). */
    function teacher_owned_lesson_file_ids($con, int $teacherId): array {
        if ($teacherId <= 0) return [];
        $ids = [];
        $res = @mysqli_query($con, "SELECT DISTINCT cb.id FROM course_books cb WHERE " . teacher_book_ownership_clause($teacherId));
        while ($res && ($row = mysqli_fetch_assoc($res))) {
            $ids[] = (int)$row['id'];
        }
        return $ids;
    }
}

if (!function_exists('teacher_owned_book_ids')) {
    /**
     * The store items this teacher owns (R7: creator or assigned), as `book_id` values.
     *
     * Its callers (discount codes above all) ask about the things the store sells, and those are
     * products now. It used to answer from course_books, where no store item lives any more, so
     * every teacher's discount picker would have come back empty.
     */
    function teacher_owned_book_ids($con, int $teacherId): array {
        return teacher_owned_store_item_ids($con, $teacherId);
    }
}

if (!function_exists('teacher_owns_course')) {
    /** The teacher teaches this course (its teacher, an active course_teachers row) or created it. */
    function teacher_owns_course($con, int $teacherId, int $courseId): bool {
        if ($teacherId <= 0 || $courseId <= 0) return false;
        $res = @mysqli_query($con, "
            SELECT id FROM courses WHERE id = {$courseId} AND (
                teacher_id = {$teacherId}
                OR (created_by_type = 'teacher' AND created_by_id = {$teacherId})
                OR id IN (SELECT course_id FROM course_teachers WHERE teacher_id = {$teacherId} AND is_active = 1)
            ) LIMIT 1");
        return $res && mysqli_num_rows($res) > 0;
    }
}

if (!function_exists('teacher_owns_unit')) {
    /** The unit's course is the teacher's, or the teacher created or is assigned to the unit. */
    function teacher_owns_unit($con, int $teacherId, int $unitId): bool {
        if ($teacherId <= 0 || $unitId <= 0) return false;
        $res = @mysqli_query($con, "
            SELECT id, course_id FROM units WHERE id = {$unitId} AND (
                (created_by_type = 'teacher' AND created_by_id = {$teacherId})
                OR id IN (SELECT unit_id FROM unit_teachers WHERE teacher_id = {$teacherId} AND is_active = 1)
            ) LIMIT 1");
        if ($res && mysqli_num_rows($res) > 0) return true;
        $u = @mysqli_query($con, "SELECT course_id FROM units WHERE id = {$unitId} LIMIT 1");
        $row = $u ? mysqli_fetch_assoc($u) : null;
        return $row && teacher_owns_course($con, $teacherId, (int)$row['course_id']);
    }
}

if (!function_exists('teacher_can_edit_lesson_file')) {
    /**
     * Whether a teacher may change or delete this lesson file: they created it, are assigned to it,
     * or it sits in their own course or unit. Deliberately NOT "any file of a subject they teach"
     * (teacher_book_ownership_clause's widest test) - that let one teacher delete another's files.
     */
    function teacher_can_edit_lesson_file($con, int $teacherId, int $fileId): bool {
        if ($teacherId <= 0 || $fileId <= 0) return false;
        $res = @mysqli_query($con, "SELECT id, course_id, unit_id, created_by_type, created_by_id FROM course_books WHERE id = {$fileId} LIMIT 1");
        $f = $res ? mysqli_fetch_assoc($res) : null;
        if (!$f) return false;
        if ($f['created_by_type'] === 'teacher' && (int)$f['created_by_id'] === $teacherId) return true;
        $bt = @mysqli_query($con, "SELECT id FROM book_teachers WHERE book_id = {$fileId} AND teacher_id = {$teacherId} AND is_active = 1 LIMIT 1");
        if ($bt && mysqli_num_rows($bt) > 0) return true;
        if (!empty($f['unit_id']) && teacher_owns_unit($con, $teacherId, (int)$f['unit_id'])) return true;
        return !empty($f['course_id']) && teacher_owns_course($con, $teacherId, (int)$f['course_id']);
    }
}

if (!function_exists('teacher_can_read_book')) {
    /** Whether a teacher may stream this file: one of their lesson files, or one of their products. */
    function teacher_can_read_book($con, int $teacherId, int $id): bool {
        if ($teacherId <= 0 || $id <= 0) return false;
        $res = @mysqli_query($con, "SELECT cb.id FROM course_books cb WHERE cb.id = {$id} AND " . teacher_book_ownership_clause($teacherId) . " LIMIT 1");
        if ($res && mysqli_num_rows($res) > 0) return true;
        return teacher_owns_store_item($con, $teacherId, $id);
    }
}
