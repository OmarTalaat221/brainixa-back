<?php

/**
 * What a teacher owns, defined once.
 *
 * Moved here from app/teacher/books/manage.php so that code outside the teacher's book screens -
 * discount codes, first of all - asks the same question and gets the same answer. The discount
 * helper had its own two-route version of "this teacher's book", while the store listing used all
 * seven routes below. The result: a teacher's own product, listed on their own store screen, was
 * refused as "not yours" the moment they tried to put a discount code on it.
 */

if (!function_exists('teacher_book_ownership_clause')) {
    /**
     * The one definition of "this teacher's book", as a SQL condition over the alias `cb`
     * (course_books).
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

if (!function_exists('teacher_owned_book_ids')) {
    /** Every course_books id this teacher owns, by teacher_book_ownership_clause(). One query. */
    function teacher_owned_book_ids($con, int $teacherId): array {
        if ($teacherId <= 0) return [];
        $ids = [];
        $res = @mysqli_query($con, "SELECT DISTINCT cb.id FROM course_books cb WHERE " . teacher_book_ownership_clause($teacherId));
        while ($res && ($row = mysqli_fetch_assoc($res))) {
            $ids[] = (int)$row['id'];
        }
        return $ids;
    }
}
