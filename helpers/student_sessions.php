<?php
/**
 * Which weekly classes a student is allowed to see — in ONE place.
 *
 * This condition existed twice, written out by hand, and the two copies did not agree. The home
 * screen's copy was tightened after a real leak was found: a session tied to a specific course
 * was passing through on subject-wide access, so a student holding a broad subject subscription
 * saw every teacher's weekly class in that subject rather than the course they had actually paid
 * for. `GET /student/sessions/today` — the endpoint that feeds the student's actual timetable,
 * and so the one read far more often — kept the loose version, and additionally let any session
 * through on `teacher_id` alone: being subscribed to one package with a teacher showed you that
 * teacher's whole week.
 *
 * Measured on the live API before this was shared: the same student, the same day, one session on
 * the home screen and two on the timetable.
 *
 * So the rule is a function now rather than a paragraph of SQL copied between two files. The next
 * change to who may see what happens once, and the two screens cannot drift apart again.
 *
 * The rule itself, unchanged from the home screen's corrected version:
 *
 *   - A session that belongs to a course is visible only to a student with access to THAT course.
 *   - A session with no course is a teacher's general class for a whole subject, and is visible
 *     on subject access — gated on the student's academic year where the session names one.
 *   - Being subscribed to a teacher grants nothing by itself. Access is to courses and subjects;
 *     the teacher is who happens to be teaching them.
 */

if (!function_exists('student_session_access_condition')) {
    /**
     * A `class_sessions` WHERE fragment, already parenthesised, or null when the student can see
     * nothing at all — which the caller must treat as an empty result rather than as "no filter".
     *
     * The ids are cast to int and written into the SQL rather than bound: they come from the
     * student's own subscriptions as integers, and a list whose length varies per student is what
     * made both call sites build placeholder strings by hand in the first place.
     */
    function student_session_access_condition(array $courseIds, array $subjectIds, ?int $academicYearId): ?string {
        $branches = [];

        $courseIds = array_values(array_unique(array_map('intval', $courseIds)));
        $subjectIds = array_values(array_unique(array_map('intval', $subjectIds)));

        if (!empty($courseIds)) {
            $list = implode(',', $courseIds);
            $branches[] = "(course_id IS NOT NULL AND course_id IN ({$list}))";
        }

        if (!empty($subjectIds)) {
            $list = implode(',', $subjectIds);
            // A subject-wide class may be tagged with a grade. A student of another grade is not
            // its audience; an untagged class is everybody's, which is the older behaviour and
            // still the common case.
            $grade = $academicYearId
                ? "(academic_year_id IS NULL OR academic_year_id = " . (int)$academicYearId . ")"
                : "academic_year_id IS NULL";
            $branches[] = "(course_id IS NULL AND subject_id IN ({$list}) AND {$grade})";
        }

        if (empty($branches)) {
            return null;
        }

        return '(' . implode(' OR ', $branches) . ')';
    }
}

if (!function_exists('student_session_mark_access')) {
    /**
     * Stamps a session with the four flags the home screen has always carried and the timetable
     * carried none of: `has_access`, `is_subscribed`, `is_locked`, `is_open`. Without them a
     * client reading the timetable had no way at all to tell a class the student holds from one
     * shown as a preview, so it had to assume every row was theirs.
     *
     * A preview is the one case where a session is deliberately shown without access: a package's
     * weekly schedule on its details page, so somebody can see the days and times before paying.
     * Its link is removed here rather than at each call site.
     */
    function student_session_mark_access(array $session, array $courseIds, array $subjectIds, bool $isPreviewOnly): array {
        $subscribed = !$isPreviewOnly && student_session_is_subscribed($session, $courseIds, $subjectIds);

        $session['has_access'] = $subscribed;
        $session['is_subscribed'] = $subscribed;
        $session['is_locked'] = !$subscribed;
        $session['is_open'] = $subscribed;

        if (!$subscribed) {
            $session['meeting_link'] = null;
        }

        return $session;
    }
}

if (!function_exists('student_session_is_subscribed')) {
    /**
     * Whether a session the student is being shown is one they actually hold, as opposed to one
     * shown to them as a preview. Kept beside the condition above because the two have to agree:
     * a row the condition admits must read as subscribed, or the screen contradicts the query.
     */
    function student_session_is_subscribed(array $session, array $courseIds, array $subjectIds): bool {
        $courseId = (int)($session['course_id'] ?? 0);
        $subjectId = (int)($session['subject_id'] ?? 0);

        if ($courseId > 0) {
            return in_array($courseId, array_map('intval', $courseIds), true);
        }

        return $subjectId > 0 && in_array($subjectId, array_map('intval', $subjectIds), true);
    }
}
