<?php
require_once __DIR__ . '/../../../../helpers/functions.php';
require_once __DIR__ . '/../../../../helpers/language.php';
require_once __DIR__ . '/../../../../helpers/upload.php';
require_once __DIR__ . '/../../../../helpers/pricing.php';
require_once __DIR__ . '/../../../../helpers/store_items.php';
require_once __DIR__ . '/../../../content/helpers.php';
require_once __DIR__ . '/../subscriptions/manage.php';
require_once __DIR__ . '/../../../../helpers/admin_notifications.php';

/*
 * Two kinds of thing answer to "a book" on these endpoints since migration 131:
 *
 *   - a lesson file: a `course_books` row tied to a course or a unit (ids from 1,000,000 up for
 *     new ones), opened from inside the course it belongs to;
 *   - a store item: a `products` row, which is what every standalone book became, with the same
 *     id it had as a book.
 *
 * The ids never collide, so an endpoint that takes a `book_id` looks in `products` first and
 * falls back to `course_books`. Store items are returned in the book shape (store_item_as_book)
 * because the mobile app reads them as books.
 */

if (!function_exists('enrich_student_book_details')) {
    function enrich_student_book_details($con, array $row) {
        $bookId = (int)$row['id'];
        $courseId = $row['course_id'] ? (int)$row['course_id'] : 0;
        $subjectId = $row['subject_id'] ? (int)$row['subject_id'] : 0;
        $unitId = $row['unit_id'] ? (int)$row['unit_id'] : 0;

        $row['unit'] = null;
        if ($unitId > 0) {
            $uStmt = mysqli_prepare($con, "SELECT u.id, u.course_id, u.subject_id, (SELECT name FROM units_translations ut WHERE ut.unit_id = u.id AND ut.language_id = 1 LIMIT 1) AS unit_name FROM units u WHERE u.id = ? LIMIT 1");
            if ($uStmt) {
                mysqli_stmt_bind_param($uStmt, "i", $unitId);
                mysqli_stmt_execute($uStmt);
                $uRow = mysqli_fetch_assoc(mysqli_stmt_get_result($uStmt));
                if ($uRow) {
                    $uRow['id'] = (int)$uRow['id'];
                    $row['unit'] = $uRow;
                    if ($courseId <= 0 && !empty($uRow['course_id'])) {
                        $courseId = (int)$uRow['course_id'];
                        $row['course_id'] = $courseId;
                    }
                    if ($subjectId <= 0 && !empty($uRow['subject_id'])) {
                        $subjectId = (int)$uRow['subject_id'];
                        $row['subject_id'] = $subjectId;
                    }
                }
            }
        }

        if ($subjectId <= 0 && $courseId > 0) {
            $cRes = mysqli_query($con, "SELECT subject_id FROM courses WHERE id = {$courseId} LIMIT 1");
            if ($cRes && $cRow = mysqli_fetch_assoc($cRes)) {
                if ($cRow['subject_id']) {
                    $subjectId = (int)$cRow['subject_id'];
                    $row['subject_id'] = $subjectId;
                }
            }
        }

        $row['subject'] = $subjectId > 0 ? get_subject_details($con, $subjectId) : null;

        $row['course'] = null;
        if ($courseId > 0) {
            $cStmt = mysqli_prepare($con, "SELECT c.id, c.price, c.image, c.teacher_id,
                                                  (SELECT name FROM courses_translations ct WHERE ct.course_id = c.id AND ct.language_id = 1 LIMIT 1) AS course_name
                                           FROM courses c WHERE c.id = ? LIMIT 1");
            if ($cStmt) {
                mysqli_stmt_bind_param($cStmt, "i", $courseId);
                mysqli_stmt_execute($cStmt);
                $cRow = mysqli_fetch_assoc(mysqli_stmt_get_result($cStmt));
                if ($cRow) {
                    $cRow['id'] = (int)$cRow['id'];
                    $cRow['price'] = (float)$cRow['price'];
                    $cRow['image'] = format_image_url($cRow['image']);
                    $row['course'] = $cRow;
                }
            }
        }

        $teacherId = 0;
        if (($row['created_by_type'] ?? '') === 'teacher' && ($row['created_by_id'] ?? 0) > 0) {
            $teacherId = (int)$row['created_by_id'];
        } elseif (!empty($row['course']['teacher_id'])) {
            $teacherId = (int)$row['course']['teacher_id'];
        } else {
            $btRes = mysqli_query($con, "SELECT teacher_id FROM book_teachers WHERE book_id = {$bookId} LIMIT 1");
            if ($btRes && $btRow = mysqli_fetch_assoc($btRes)) {
                $teacherId = (int)$btRow['teacher_id'];
            }
        }

        $row['teacher'] = null;
        if ($teacherId > 0) {
            $tStmt = mysqli_prepare($con, "SELECT id, name, email, specialization, image, rating FROM teachers WHERE id = ? LIMIT 1");
            if ($tStmt) {
                mysqli_stmt_bind_param($tStmt, "i", $teacherId);
                mysqli_stmt_execute($tStmt);
                $tRow = mysqli_fetch_assoc(mysqli_stmt_get_result($tStmt));
                if ($tRow) {
                    $tRow['id'] = (int)$tRow['id'];
                    $tRow['rating'] = $tRow['rating'] !== null ? (float)$tRow['rating'] : 5.0;
                    $row['teacher'] = format_response_images($tRow);
                }
            }
        }

        $row['price'] = isset($row['price']) ? (float)$row['price'] : (!empty($row['course']['price']) ? (float)$row['course']['price'] : 0.00);
        $row['rating'] = isset($row['rating']) ? (float)$row['rating'] : (!empty($row['teacher']['rating']) ? (float)$row['teacher']['rating'] : 5.0);

        // Both listings of books and the single-book endpoint all pass through here, so this is
        // the one place the country price has to be applied for it to be applied everywhere.
        pricing_decorate_row($con, $row, 'book');

        // The course attached to a book carries its own price and its own country prices; it is a
        // course, so it is priced as one rather than inheriting the book's currency.
        if (is_array($row['course'] ?? null) && isset($row['course']['id'])) {
            pricing_decorate_row($con, $row['course'], 'course');
        }

        return format_response_images($row);
    }
}

if (!function_exists('student_book_stream_url')) {
    function student_book_stream_url(int $bookId): string {
        return 'https://camp-coding.online/brain-ixa/student/books/stream?book_id=' . $bookId;
    }
}

if (!function_exists('apply_student_book_file_access')) {
    // Owned book: either expose the raw downloadable URL, or (when
    // allow_download = 0) hide it and expose only an authenticated
    // view-only streaming endpoint instead.
    function apply_student_book_file_access(array &$row, int $bookId): void {
        // A physical store item is handed over off the platform: there is no file to open, and a
        // stream URL would only lead to "file not available".
        if (($row['item_type'] ?? '') === 'product' && ($row['product_type'] ?? '') === 'physical') {
            $row['file_path'] = null;
            $row['link'] = null;
            $row['view_url'] = null;
            return;
        }

        if ((int)($row['allow_download'] ?? 1) === 1) {
            $row['file_path'] = format_image_url($row['file_path'] ?: $row['link']);
            $row['view_url'] = $row['file_path'];
            return;
        }

        $row['file_path'] = null;
        $row['link'] = null;
        $row['view_url'] = student_book_stream_url($bookId);
    }
}

if (!function_exists('student_store_items_access')) {
    /**
     * Whether the student owns each of these store items, and the latest purchase request on it,
     * in a fixed number of queries however long the list.
     *
     * A store item is owned through a purchase (`student_book_subscriptions`), a subscription
     * that names it (`student_subscription_books`), or its subject being one the student is
     * subscribed to - the rules a standalone book had. Its teacher counts only when the item also
     * has a subject: an item with no course, no unit and no subject was always bought on its own,
     * even from a teacher the student follows.
     *
     * @param array<int, array> $products raw `products` rows keyed by id
     * @return array<int, array{own: bool, request_status: ?string, request_review_notes: ?string}>
     */
    function student_store_items_access($con, int $stId, array $products, ?array $accessible = null): array {
        $out = [];
        foreach ($products as $id => $p) {
            $out[(int)$id] = ['own' => false, 'request_status' => null, 'request_review_notes' => null];
        }
        if ($stId <= 0 || !$out) {
            return $out;
        }

        $idList = implode(',', array_keys($out));
        $direct = [];
        $res = @mysqli_query($con, "SELECT book_id FROM student_book_subscriptions WHERE student_id = {$stId} AND is_active = 1 AND book_id IN ({$idList})");
        while ($res && ($r = mysqli_fetch_assoc($res))) {
            $direct[(int)$r['book_id']] = true;
        }
        $res = @mysqli_query($con, "SELECT ssb.book_id FROM student_subscription_books ssb JOIN student_subscriptions ss ON ssb.student_subscription_id = ss.id WHERE ss.student_id = {$stId} AND ss.is_active = 1 AND ssb.book_id IN ({$idList})");
        while ($res && ($r = mysqli_fetch_assoc($res))) {
            $direct[(int)$r['book_id']] = true;
        }

        if ($accessible === null) {
            $accessible = get_student_accessible_entities($con, $stId);
        }
        $subjectIds = array_map('intval', $accessible['subject_ids'] ?? []);
        $teacherIds = array_map('intval', $accessible['teacher_ids'] ?? []);

        foreach ($products as $id => $p) {
            $id = (int)$id;
            $sId = (int)($p['subject_id'] ?? 0);
            $own = isset($direct[$id])
                || ($sId > 0 && in_array($sId, $subjectIds, true))
                || ($sId > 0 && ($p['created_by_type'] ?? '') === 'teacher' && in_array((int)($p['created_by_id'] ?? 0), $teacherIds, true));
            $out[$id]['own'] = $own;
        }

        // The latest request per item, for the "under review" / "rejected because" state.
        $res = @mysqli_query($con, "SELECT book_id, status, review_notes FROM student_book_purchase_requests WHERE student_id = {$stId} AND book_id IN ({$idList}) ORDER BY id DESC");
        $seen = [];
        while ($res && ($r = mysqli_fetch_assoc($res))) {
            $bId = (int)$r['book_id'];
            if (isset($seen[$bId]) || !isset($out[$bId])) continue;
            $seen[$bId] = true;
            if (!$out[$bId]['own']) {
                $out[$bId]['request_status'] = $r['status'];
                $out[$bId]['request_review_notes'] = $r['review_notes'] ?: null;
            }
        }

        return $out;
    }
}

if (!function_exists('student_store_item_book_row')) {
    /**
     * A store item as a student's book row: the book shape, with `price` set to what the student
     * would pay before any country price - the sale price while the item is on sale.
     */
    function student_store_item_book_row($con, array $p, ?array $names = null, ?int $langId = null): array {
        $row = store_item_as_book($con, $p, $names, $langId);
        $effective = store_item_effective_price($p);
        $row['price'] = $effective !== null ? $effective : 0.0;
        // Every row of these lists used to say 'course_books'. Kept as it was, so a client that
        // ever branched on it sees no difference; `item_type` is what tells a store item apart.
        $row['src_table'] = 'course_books';
        return $row;
    }
}

if (!function_exists('student_books_page_refs')) {
    /**
     * One page of a list that mixes lesson files and store items, ordered as the old single-table
     * list was (order_num, then id), with the total across both. Each source is given as the
     * FROM ... WHERE part of its query (alias `b` for course_books, `p` for products), or null to
     * leave it out.
     *
     * @return array{total:int, refs: array<int, array{id:int, src:string}>}|array{error:string}
     */
    function student_books_page_refs($con, ?string $lessonFrom, ?string $productFrom, int $limit, int $offset): array {
        $total = 0;
        $parts = [];

        if ($lessonFrom !== null) {
            $res = mysqli_query($con, "SELECT COUNT(DISTINCT b.id) AS total {$lessonFrom}");
            if ($res === false) {
                return ['error' => 'Books count query failed: ' . mysqli_error($con)];
            }
            $total += (int)(mysqli_fetch_assoc($res)['total'] ?? 0);
            $parts[] = "(SELECT DISTINCT b.id AS id, b.order_num AS order_num, 'lesson' AS src {$lessonFrom})";
        }
        if ($productFrom !== null) {
            $res = mysqli_query($con, "SELECT COUNT(*) AS total {$productFrom}");
            if ($res === false) {
                return ['error' => 'Books count query failed: ' . mysqli_error($con)];
            }
            $total += (int)(mysqli_fetch_assoc($res)['total'] ?? 0);
            $parts[] = "(SELECT p.id AS id, p.order_num AS order_num, 'product' AS src {$productFrom})";
        }

        if (!$parts || $total === 0) {
            return ['total' => $total, 'refs' => []];
        }

        $res = mysqli_query($con, "
            SELECT x.id, x.src FROM (" . implode(" UNION ALL ", $parts) . ") x
            ORDER BY x.order_num ASC, x.id ASC
            LIMIT {$limit} OFFSET {$offset}
        ");
        if ($res === false) {
            return ['error' => 'Books query failed: ' . mysqli_error($con)];
        }

        $refs = [];
        while ($r = mysqli_fetch_assoc($res)) {
            $refs[] = ['id' => (int)$r['id'], 'src' => $r['src']];
        }
        return ['total' => $total, 'refs' => $refs];
    }
}

if (!function_exists('student_lesson_book_rows')) {
    /** Lesson-file rows by id, in the columns the student lists have always returned. */
    function student_lesson_book_rows($con, array $ids, int $langId, bool $withPrice): array {
        $ids = array_values(array_unique(array_filter(array_map('intval', $ids), fn($i) => $i > 0)));
        if (!$ids) return [];
        $priceCol = $withPrice ? "b.price, " : "";
        $srcCol = $withPrice ? ", 'course_books' AS src_table" : "";
        $res = mysqli_query($con, "
            SELECT b.id, b.unit_id, b.subject_id, b.course_id, b.file_type, b.category, b.extension, b.link, b.file_path, b.cover_image, {$priceCol}b.allow_download,
                   b.created_by_type, b.created_by_id, b.is_active, b.created_at,
                   COALESCE(bt.title, b.file_path) AS title, bt.description{$srcCol}
            FROM course_books b
            LEFT JOIN course_books_translations bt ON b.id = bt.book_id AND bt.language_id = {$langId}
            WHERE b.id IN (" . implode(',', $ids) . ")
        ");
        $out = [];
        while ($res && ($row = mysqli_fetch_assoc($res))) {
            if (!isset($out[(int)$row['id']])) {
                $out[(int)$row['id']] = $row;
            }
        }
        return $out;
    }
}

if (!function_exists('student_store_items_ready')) {
    /** The store reads `products` only once migration 131 gave it the columns a book had. */
    function student_store_items_ready($con): bool {
        return function_exists('store_products_ready') && store_products_ready($con);
    }
}

if (!function_exists('student_book_exists')) {
    /** A store item or a lesson file with this id. */
    function student_book_exists($con, int $bookId): bool {
        if ($bookId <= 0) return false;
        if (student_store_items_ready($con) && store_item_find($con, $bookId)) {
            return true;
        }
        $res = mysqli_query($con, "SELECT id FROM course_books WHERE id = {$bookId} LIMIT 1");
        return $res && mysqli_num_rows($res) > 0;
    }
}

if (!function_exists('student_books_request_filters')) {
    /** The filters both student book lists accept, from the query string or the body. */
    function student_books_request_filters(): array {
        $body = read_json_body();
        $qsParams = [];
        if (!empty($_SERVER['QUERY_STRING'])) {
            parse_str(str_replace('?', '&', $_SERVER['QUERY_STRING']), $qsParams);
        }

        $search = trim($_GET['search'] ?? $_GET['q'] ?? $qsParams['search'] ?? $qsParams['q'] ?? $body['search'] ?? $body['q'] ?? '');
        $unitId = (int)($_GET['unit_id'] ?? $_GET['unitId'] ?? $qsParams['unit_id'] ?? $qsParams['unitId'] ?? $body['unit_id'] ?? $body['unitId'] ?? $_REQUEST['unit_id'] ?? $_REQUEST['unitId'] ?? 0);
        $subjectId = (int)($_GET['subject_id'] ?? $_GET['subjectId'] ?? $qsParams['subject_id'] ?? $qsParams['subjectId'] ?? $body['subject_id'] ?? $body['subjectId'] ?? $_REQUEST['subject_id'] ?? $_REQUEST['subjectId'] ?? 0);
        $courseId = (int)($_GET['course_id'] ?? $_GET['courseId'] ?? $qsParams['course_id'] ?? $qsParams['courseId'] ?? $body['course_id'] ?? $body['courseId'] ?? $_REQUEST['course_id'] ?? $_REQUEST['courseId'] ?? 0);
        $category = in_array(trim($_GET['category'] ?? $qsParams['category'] ?? $body['category'] ?? ''), ['summary', 'exam'], true)
            ? trim($_GET['category'] ?? $qsParams['category'] ?? $body['category'])
            : '';

        return [
            'body' => $body,
            'qs' => $qsParams,
            'search' => $search,
            'unit_id' => $unitId,
            'subject_id' => $subjectId,
            'course_id' => $courseId,
            'category' => $category,
        ];
    }
}

if (!function_exists('student_store_items_filter_sql')) {
    /**
     * The WHERE conditions a store item has to meet for the same filters a lesson file is listed
     * by. A store item belongs to no course and no unit, so a course or unit filter excludes the
     * store altogether - the caller checks that before asking.
     *
     * A store item that is not a book has no category; it was a 'summary' as a book row and is
     * still reported as one, so it is found under that filter too.
     */
    function student_store_items_filter_sql($con, array $f, int $langId): array {
        $where = ["p.is_active = 1"];
        if ($f['category'] === 'exam') {
            $where[] = "p.book_category = 'exam'";
        } elseif ($f['category'] === 'summary') {
            $where[] = "(p.book_category = 'summary' OR p.book_category IS NULL)";
        }
        if ($f['subject_id'] > 0) {
            $where[] = "p.subject_id = " . (int)$f['subject_id'];
        }
        if ($f['search'] !== '') {
            $sp = '%' . mysqli_real_escape_string($con, $f['search']) . '%';
            $where[] = "EXISTS (SELECT 1 FROM products_translations pt WHERE pt.product_id = p.id AND pt.language_id = {$langId} AND (pt.name LIKE '{$sp}' OR pt.description LIKE '{$sp}'))";
        }
        return $where;
    }
}

if (!function_exists('studentGetAllBooksWithOwn')) {
    function studentGetAllBooksWithOwn($con, $studentData = null) {
        $stId = 0;
        if (is_array($studentData)) {
            $stId = (int)($studentData['id'] ?? $studentData['student_id'] ?? 0);
        } elseif (is_object($studentData)) {
            $stId = (int)($studentData->id ?? $studentData->student_id ?? 0);
        }
        if ($stId <= 0) {
            $stId = (int)($_GET['student_id'] ?? 0);
        }

        $accessible = get_student_accessible_entities($con, $stId);
        $accessibleCourseIds = $accessible['course_ids'];
        $accessibleSubjectIds = $accessible['subject_ids'];
        $accessibleTeacherIds = $accessible['teacher_ids'];

        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 10)));
        $offset = ($page - 1) * $limit;

        $f = student_books_request_filters();
        $body = $f['body'];
        $qsParams = $f['qs'];
        $search = $f['search'];
        $unitId = $f['unit_id'];
        $subjectId = $f['subject_id'];
        $courseId = $f['course_id'];
        $category = $f['category'];

        $langInfo = get_language_info($con);
        $langId = (int)($langInfo['id'] ?? 1);

        // The store sells standalone items only. A row tied to a course or a unit is that
        // course's own content, opened from inside it - and the purchase endpoint refuses it
        // outright ("bundled with its course"), so listing it in the store offered a sale that
        // could never go through. Opt-in, so every existing caller keeps the full list.
        $standaloneOnly = in_array(
            strtolower(trim($_GET['standalone'] ?? $qsParams['standalone'] ?? $body['standalone'] ?? '')),
            ['1', 'true', 'yes'],
            true
        );

        // Lesson files: course_books, which since migration 131 holds nothing else.
        $lessonFrom = null;
        if (!$standaloneOnly) {
            $cbWhere = ["b.is_active = 1"];
            if ($unitId > 0) {
                $cbWhere[] = "b.unit_id = {$unitId}";
            }
            if ($category !== '') {
                $cbWhere[] = "b.category = '{$category}'";
            }
            if ($courseId > 0) {
                $cbWhere[] = "(b.course_id = {$courseId} OR b.unit_id IN (SELECT id FROM units WHERE course_id = {$courseId}))";
            }
            if ($subjectId > 0) {
                $cbWhere[] = "((b.subject_id IS NOT NULL AND b.subject_id = {$subjectId}) OR (b.subject_id IS NULL AND (b.course_id IN (SELECT id FROM courses WHERE subject_id = {$subjectId}) OR b.unit_id IN (SELECT u.id FROM units u JOIN courses c ON u.course_id = c.id WHERE c.subject_id = {$subjectId}))))";
            }
            if (!empty($search)) {
                $sp = '%' . mysqli_real_escape_string($con, $search) . '%';
                $cbWhere[] = "(bt.title LIKE '{$sp}' OR bt.description LIKE '{$sp}')";
            }
            $lessonFrom = "FROM course_books b
                LEFT JOIN course_books_translations bt ON b.id = bt.book_id AND bt.language_id = {$langId}
                WHERE " . implode(" AND ", $cbWhere);
        }

        // Store items: products. They have no course and no unit, so either filter leaves them out.
        $productFrom = null;
        if ($unitId <= 0 && $courseId <= 0 && student_store_items_ready($con)) {
            $pWhere = student_store_items_filter_sql($con, $f, $langId);
            // One rule for the whole shelf (see store_visible_sql): an item is listed while it is
            // live. `show_on_website` is the landing page's switch, as it always was for a book.
            $productFrom = "FROM products p WHERE " . implode(" AND ", $pWhere);
        }

        $paged = student_books_page_refs($con, $lessonFrom, $productFrom, $limit, $offset);
        if (isset($paged['error'])) {
            return ['status' => 'error', 'message' => $paged['error']];
        }
        $totalRecords = $paged['total'];

        $lessonIds = [];
        $productIds = [];
        foreach ($paged['refs'] as $ref) {
            if ($ref['src'] === 'product') {
                $productIds[] = $ref['id'];
            } else {
                $lessonIds[] = $ref['id'];
            }
        }
        $lessonRows = student_lesson_book_rows($con, $lessonIds, $langId, true);
        $products = $productIds ? store_items_find($con, $productIds) : [];
        $productNames = $productIds ? store_item_names($con, $productIds, $langId) : [];
        $productAccess = student_store_items_access($con, $stId, $products, $accessible);

        $books = [];
        foreach ($paged['refs'] as $ref) {
            $bId = $ref['id'];

            if ($ref['src'] === 'product') {
                if (!isset($products[$bId])) continue;
                $row = student_store_item_book_row($con, $products[$bId], $productNames[$bId] ?? null);
                $access = $productAccess[$bId];
                $isOwn = $access['own'];
                $row['own'] = $isOwn;
                $row['is_subscribed'] = $isOwn;
                $row['is_locked'] = !$isOwn;
                $row['is_open'] = $isOwn;
                $row['request_status'] = $access['request_status'];
                $row['request_review_notes'] = $access['request_review_notes'];
            } else {
                if (!isset($lessonRows[$bId])) continue;
                $row = $lessonRows[$bId];
                $cId = $row['course_id'] ? (int)$row['course_id'] : 0;
                $sId = $row['subject_id'] ? (int)$row['subject_id'] : 0;
                $uId = $row['unit_id'] ? (int)$row['unit_id'] : 0;
                $createdById = (int)$row['created_by_id'];

                if ($cId <= 0 && $uId > 0) {
                    $uRes = mysqli_query($con, "SELECT course_id, subject_id FROM units WHERE id = {$uId} LIMIT 1");
                    if ($uRes && $uRow = mysqli_fetch_assoc($uRes)) {
                        if ($uRow['course_id']) $cId = (int)$uRow['course_id'];
                        if ($uRow['subject_id']) $sId = (int)$uRow['subject_id'];
                    }
                }
                if ($sId <= 0 && $cId > 0) {
                    $cRes = mysqli_query($con, "SELECT subject_id FROM courses WHERE id = {$cId} LIMIT 1");
                    if ($cRes && $cRow = mysqli_fetch_assoc($cRes)) {
                        if ($cRow['subject_id']) $sId = (int)$cRow['subject_id'];
                    }
                }

                $row['id'] = $bId;
                $row['unit_id'] = $uId ?: null;
                $row['subject_id'] = $sId ?: null;
                $row['course_id'] = $cId ?: null;
                $row['is_active'] = (int)$row['is_active'];
                $row['category'] = $row['category'] ?: 'summary';

                $isDirectSub = false;
                if ($stId > 0) {
                    $subChk = @mysqli_query($con, "SELECT id FROM student_book_subscriptions WHERE student_id = {$stId} AND book_id = {$bId} AND is_active = 1 LIMIT 1");
                    if ($subChk && mysqli_num_rows($subChk) > 0) {
                        $isDirectSub = true;
                    } else {
                        $subChk2 = @mysqli_query($con, "SELECT ssb.id FROM student_subscription_books ssb JOIN student_subscriptions ss ON ssb.student_subscription_id = ss.id WHERE ss.student_id = {$stId} AND ssb.book_id = {$bId} AND ss.is_active = 1 LIMIT 1");
                        if ($subChk2 && mysqli_num_rows($subChk2) > 0) {
                            $isDirectSub = true;
                        }
                    }
                }

                // A lesson file is opened by owning its course, its subject, or its teacher.
                $isOwn = (
                    $isDirectSub ||
                    ($cId > 0 && in_array($cId, $accessibleCourseIds)) ||
                    ($sId > 0 && in_array($sId, $accessibleSubjectIds)) ||
                    (($cId > 0 || $sId > 0) && $row['created_by_type'] === 'teacher' && in_array($createdById, $accessibleTeacherIds))
                );

                $row['own'] = $isOwn;
                $row['is_subscribed'] = $isOwn;
                $row['is_locked'] = !$isOwn;
                $row['is_open'] = $isOwn;

                // The standing purchase request, so the card can show "قيد المراجعة" or the reason it
                // was rejected without the app having to call a second endpoint.
                $row['request_status'] = null;
                $row['request_review_notes'] = null;
                if ($stId > 0 && !$isOwn) {
                    $rqChk = @mysqli_query($con, "SELECT status, review_notes FROM student_book_purchase_requests WHERE student_id = {$stId} AND book_id = {$bId} ORDER BY id DESC LIMIT 1");
                    if ($rqChk && $rqRow = mysqli_fetch_assoc($rqChk)) {
                        $row['request_status'] = $rqRow['status'];
                        $row['request_review_notes'] = $rqRow['review_notes'] ?: null;
                    }
                }
            }

            $row['allow_download'] = (int)($row['allow_download'] ?? 1);

            if ($isOwn) {
                apply_student_book_file_access($row, $bId);
            } else {
                $row['file_path'] = null;
                $row['link'] = null;
                $row['view_url'] = null;
            }

            $books[] = enrich_student_book_details($con, $row);
        }

        // The price a student in this country actually pays, in that country's currency.
        pricing_decorate_rows($con, $books, 'book', $stId);

        return build_admin_paginated_response($books, $page, $limit, $totalRecords, ['total_count' => $totalRecords]);
    }
}

if (!function_exists('studentGetMySubscribedBooks')) {
    function studentGetMySubscribedBooks($con, $studentData = null) {
        $stId = 0;
        if (is_array($studentData)) {
            $stId = (int)($studentData['id'] ?? $studentData['student_id'] ?? 0);
        } elseif (is_object($studentData)) {
            $stId = (int)($studentData->id ?? $studentData->student_id ?? 0);
        }
        if ($stId <= 0) {
            $stId = (int)($_GET['student_id'] ?? 0);
        }
        if ($stId <= 0) {
            return build_admin_paginated_response([], 1, 10, 0, ['total_count' => 0]);
        }

        $accessible = get_student_accessible_entities($con, $stId);
        $courseIds = $accessible['course_ids'];
        $subjectIds = $accessible['subject_ids'];
        $teacherIds = $accessible['teacher_ids'];

        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 10)));
        $offset = ($page - 1) * $limit;

        $f = student_books_request_filters();
        $search = $f['search'];
        $unitId = $f['unit_id'];
        $subjectId = $f['subject_id'];
        $courseId = $f['course_id'];
        $category = $f['category'];

        $langInfo = get_language_info($con);
        $langId = (int)($langInfo['id'] ?? 1);

        $sList = !empty($subjectIds) ? implode(',', array_map('intval', $subjectIds)) : '';
        $tList = !empty($teacherIds) ? implode(',', array_map('intval', $teacherIds)) : '';

        // The store sells standalone items only; `standalone=1` asks for those alone.
        $standaloneOnly = in_array(strtolower(trim($_GET['standalone'] ?? '')), ['1', 'true', 'yes'], true);

        // Lesson files the student can open.
        $lessonFrom = null;
        if (!$standaloneOnly) {
            $orConditions = [];
            if (!empty($courseIds)) {
                $cList = implode(',', array_map('intval', $courseIds));
                $orConditions[] = "b.course_id IN ({$cList})";
            }
            if ($sList !== '') {
                $orConditions[] = "b.subject_id IN ({$sList})";
            }
            if ($tList !== '') {
                $orConditions[] = "(b.created_by_type = 'teacher' AND b.created_by_id IN ({$tList}) AND (b.course_id IS NOT NULL OR b.unit_id IS NOT NULL OR b.subject_id IS NOT NULL))";
                $orConditions[] = "(b.id IN (SELECT book_id FROM book_teachers WHERE teacher_id IN ({$tList}) AND is_active = 1) AND (b.course_id IS NOT NULL OR b.unit_id IS NOT NULL OR b.subject_id IS NOT NULL))";
            }
            $orConditions[] = "b.id IN (SELECT book_id FROM student_book_subscriptions WHERE student_id = {$stId} AND is_active = 1)";
            $orConditions[] = "b.id IN (SELECT ssb.book_id FROM student_subscription_books ssb JOIN student_subscriptions ss ON ssb.student_subscription_id = ss.id WHERE ss.student_id = {$stId} AND ss.is_active = 1)";

            $whereSearch = "";
            if ($unitId > 0) {
                $whereSearch .= " AND b.unit_id = {$unitId}";
            }
            if ($courseId > 0) {
                $whereSearch .= " AND (b.course_id = {$courseId} OR b.unit_id IN (SELECT id FROM units WHERE course_id = {$courseId}))";
            }
            if ($subjectId > 0) {
                $whereSearch .= " AND (b.subject_id = {$subjectId} OR b.course_id IN (SELECT id FROM courses WHERE subject_id = {$subjectId}) OR b.unit_id IN (SELECT u.id FROM units u JOIN courses c ON u.course_id = c.id WHERE c.subject_id = {$subjectId}))";
            }
            if (!empty($search)) {
                $sp = '%' . mysqli_real_escape_string($con, $search) . '%';
                $whereSearch .= " AND (bt.title LIKE '{$sp}' OR bt.description LIKE '{$sp}')";
            }
            if ($category !== '') {
                $whereSearch .= " AND b.category = '{$category}'";
            }

            $lessonFrom = "FROM course_books b
                LEFT JOIN course_books_translations bt ON b.id = bt.book_id AND bt.language_id = {$langId}
                WHERE b.is_active = 1 AND (" . implode(" OR ", $orConditions) . ") {$whereSearch}";
        }

        // Store items the student owns: bought, named in a subscription, or unlocked by the
        // subject (and, for an item that has a subject, by its teacher) - the rules a standalone
        // book had.
        $productFrom = null;
        if ($unitId <= 0 && $courseId <= 0 && student_store_items_ready($con)) {
            $pOr = [
                "p.id IN (SELECT book_id FROM student_book_subscriptions WHERE student_id = {$stId} AND is_active = 1)",
                "p.id IN (SELECT ssb.book_id FROM student_subscription_books ssb JOIN student_subscriptions ss ON ssb.student_subscription_id = ss.id WHERE ss.student_id = {$stId} AND ss.is_active = 1)",
            ];
            if ($sList !== '') {
                $pOr[] = "p.subject_id IN ({$sList})";
            }
            if ($tList !== '') {
                $pOr[] = "(p.created_by_type = 'teacher' AND p.created_by_id IN ({$tList}) AND p.subject_id IS NOT NULL)";
                $pOr[] = "(p.id IN (SELECT book_id FROM book_teachers WHERE teacher_id IN ({$tList}) AND is_active = 1) AND p.subject_id IS NOT NULL)";
            }
            $pWhere = student_store_items_filter_sql($con, $f, $langId);
            $pWhere[] = "(" . implode(" OR ", $pOr) . ")";
            $productFrom = "FROM products p WHERE " . implode(" AND ", $pWhere);
        }

        $paged = student_books_page_refs($con, $lessonFrom, $productFrom, $limit, $offset);
        if (isset($paged['error'])) {
            return ['status' => 'error', 'message' => $paged['error']];
        }
        $totalRecords = $paged['total'];

        $lessonIds = [];
        $productIds = [];
        foreach ($paged['refs'] as $ref) {
            if ($ref['src'] === 'product') {
                $productIds[] = $ref['id'];
            } else {
                $lessonIds[] = $ref['id'];
            }
        }
        $lessonRows = student_lesson_book_rows($con, $lessonIds, $langId, false);
        $products = $productIds ? store_items_find($con, $productIds) : [];
        $productNames = $productIds ? store_item_names($con, $productIds, $langId) : [];

        $books = [];
        foreach ($paged['refs'] as $ref) {
            $bId = $ref['id'];
            if ($ref['src'] === 'product') {
                if (!isset($products[$bId])) continue;
                $row = student_store_item_book_row($con, $products[$bId], $productNames[$bId] ?? null);
                unset($row['src_table']);
                // This list never selected a price: the enricher below fills it the way it
                // always has (0 for an item with no course), and the country pricing runs on
                // that. Kept as it was - the student already owns everything listed here.
                unset($row['price']);
            } else {
                if (!isset($lessonRows[$bId])) continue;
                $row = $lessonRows[$bId];
                $row['id'] = (int)$row['id'];
                $row['unit_id'] = $row['unit_id'] ? (int)$row['unit_id'] : null;
                $row['subject_id'] = $row['subject_id'] ? (int)$row['subject_id'] : null;
                $row['course_id'] = $row['course_id'] ? (int)$row['course_id'] : null;
                $row['is_active'] = (int)$row['is_active'];
                $row['category'] = $row['category'] ?: 'summary';
            }
            $row['allow_download'] = (int)($row['allow_download'] ?? 1);
            apply_student_book_file_access($row, $bId);
            $row['own'] = true;
            $row['is_subscribed'] = true;
            $books[] = enrich_student_book_details($con, $row);
        }

        // The price a student in this country actually pays, in that country's currency.
        pricing_decorate_rows($con, $books, 'book', $stId);

        return build_admin_paginated_response($books, $page, $limit, $totalRecords, ['total_count' => $totalRecords]);
    }
}

if (!function_exists('studentTrackBookOpen')) {
    function studentTrackBookOpen($con, $studentData = null) {
        $body = read_json_body();
        $stId = 0;
        if (is_array($studentData)) {
            $stId = (int)($studentData['id'] ?? $studentData['student_id'] ?? 0);
        } elseif (is_object($studentData)) {
            $stId = (int)($studentData->id ?? $studentData->student_id ?? 0);
        }
        if ($stId <= 0) {
            $stId = (int)($_GET['student_id'] ?? 0);
        }
        if ($stId <= 0) {
            return ['status' => 'error', 'message' => 'Student authentication is required'];
        }

        $bookId = (int)($body['book_id'] ?? 0);
        if ($bookId <= 0) {
            return ['status' => 'error', 'message' => 'book_id is required'];
        }

        // A store item (products) or a lesson file (course_books); the ids never collide.
        if (!student_book_exists($con, $bookId)) {
            return ['status' => 'error', 'message' => 'Book not found'];
        }

        // Ownership is decided by the one helper every other book endpoint uses. The old check
        // here looked only at the course/subject the book belongs to, and a standalone purchasable
        // book has neither by definition — so every approved purchase was refused access.
        if (!student_owns_book($con, $stId, $bookId)) {
            return ['status' => 'error', 'message' => 'You must be subscribed to access this book'];
        }

        return ['status' => 'success', 'message' => 'Book access granted'];
    }
}

if (!function_exists('ensure_books_schema')) {
    function ensure_books_schema($con) {
    }
}

if (!function_exists('studentSubscribeBook')) {
    function studentSubscribeBook($con, $studentData = null) {
        ensure_books_schema($con);
        $stId = 0;
        if (is_array($studentData)) {
            $stId = (int)($studentData['id'] ?? $studentData['student_id'] ?? 0);
        } elseif (is_object($studentData)) {
            $stId = (int)($studentData->id ?? $studentData->student_id ?? 0);
        }
        if ($stId <= 0) {
            $stId = (int)($_GET['student_id'] ?? 0);
        }
        if ($stId <= 0) {
            return ['status' => 'error', 'message' => 'Student authentication is required'];
        }

        $body = read_json_body();
        $bookId = (int)($body['book_id'] ?? $body['id'] ?? $_GET['book_id'] ?? 0);
        if ($bookId <= 0) {
            return ['status' => 'error', 'message' => 'book_id is required'];
        }

        // What is sold is a store item, a `products` row - every standalone book became one with
        // the same id, which is the id the app sends.
        $item = student_store_items_ready($con) ? store_item_find($con, $bookId) : null;
        if (!$item) {
            // Course/unit-bundled books are never purchased on their own — access comes
            // automatically from owning the course. Said so plainly rather than "not found",
            // because the student is looking at the file inside the course.
            $bRes = mysqli_query($con, "SELECT id FROM course_books WHERE id = {$bookId} LIMIT 1");
            if ($bRes && mysqli_num_rows($bRes) > 0) {
                return ['status' => 'error', 'message' => 'This book is bundled with its course and cannot be purchased separately. You already have access to it if you own the related course.'];
            }
            return ['status' => 'error', 'message' => 'Book not found'];
        }

        // Inactive or sold out: refused before anything is written, with the same words every
        // purchase path uses.
        $block = store_item_sale_block($con, $item);
        if ($block) {
            return $block;
        }

        $activeChk = mysqli_query($con, "SELECT id FROM student_book_subscriptions WHERE student_id = {$stId} AND book_id = {$bookId} AND is_active = 1 LIMIT 1");
        if ($activeChk && mysqli_num_rows($activeChk) > 0) {
            return ['status' => 'error', 'message' => 'You are already subscribed to this book'];
        }

        $rChk = mysqli_query($con, "SELECT id, status FROM student_book_purchase_requests WHERE student_id = {$stId} AND book_id = {$bookId} ORDER BY id DESC LIMIT 1");
        if ($rChk && $rRow = mysqli_fetch_assoc($rChk)) {
            if ($rRow['status'] === 'pending') {
                return ['status' => 'error', 'message' => 'Your purchase request is already pending review'];
            }
            if ($rRow['status'] === 'approved') {
                return ['status' => 'error', 'message' => 'You are already subscribed to this book'];
            }
        }

        // The price this student is quoted: the sale price while the item is on sale, overridden
        // by a price for the student's country. NULL is "no price" - not for sale, and never
        // free: `(float)null` is 0, and 0 would grant the item outright with no one reviewing it.
        // A price for the student's country still makes an unpriced item buyable.
        $effective = store_item_effective_price($item);
        $quote = pricing_for_item($con, 'book', $bookId, (float)($effective ?? 0.0), $stId);
        if ($effective === null && empty($quote['is_country_price'])) {
            return ['status' => 'error', 'error_code' => 'not_for_sale', 'message' => price_not_for_sale_message($con)];
        }
        if (empty($quote['is_priced'])) {
            return ['status' => 'error', 'error_code' => 'not_for_sale', 'message' => price_not_for_sale_message($con)];
        }

        // A free item has nothing to review. Making a teacher approve a price-0 item by hand was
        // pure friction: there is no payment to confirm and no reason to refuse.
        if ((float)($quote['price'] ?? 0) <= 0) {
            mysqli_query($con, "INSERT INTO student_book_purchase_requests (student_id, book_id, status, review_notes) VALUES ({$stId}, {$bookId}, 'approved', 'كتاب مجاني — مُنح تلقائيًا')");
            mysqli_query($con, "INSERT INTO student_book_subscriptions (student_id, book_id, granted_by_type, granted_by_id, price, is_active) VALUES ({$stId}, {$bookId}, 'student', {$stId}, 0.00, 1)");
            store_item_take_stock($con, $bookId);

            return [
                'status' => 'success',
                'message' => 'Access to this free book has been granted',
                'data' => [
                    'book_id' => $bookId,
                    'request_status' => 'approved'
                ]
            ];
        }

        mysqli_query($con, "INSERT INTO student_book_purchase_requests (student_id, book_id, status) VALUES ({$stId}, {$bookId}, 'pending')");

        notify_of_book_purchase_request($con, $stId, $bookId);

        return [
            'status' => 'success',
            'message' => 'Purchase request submitted successfully, awaiting approval',
            'data' => [
                'book_id' => $bookId,
                'request_status' => 'pending'
            ]
        ];
    }
}

if (!function_exists('student_owns_book')) {
    function student_owns_book($con, int $stId, int $bookId): bool {
        if ($stId <= 0 || $bookId <= 0) return false;

        $subChk = @mysqli_query($con, "SELECT id FROM student_book_subscriptions WHERE student_id = {$stId} AND book_id = {$bookId} AND is_active = 1 LIMIT 1");
        if ($subChk && mysqli_num_rows($subChk) > 0) return true;

        $subChk2 = @mysqli_query($con, "SELECT ssb.id FROM student_subscription_books ssb JOIN student_subscriptions ss ON ssb.student_subscription_id = ss.id WHERE ss.student_id = {$stId} AND ssb.book_id = {$bookId} AND ss.is_active = 1 LIMIT 1");
        if ($subChk2 && mysqli_num_rows($subChk2) > 0) return true;

        // A store item: owned through its subject (or, when it has one, its teacher).
        $item = student_store_items_ready($con) ? store_item_find($con, $bookId) : null;
        if ($item) {
            return student_store_items_access($con, $stId, [$bookId => $item])[$bookId]['own'] ?? false;
        }

        $bRes = mysqli_query($con, "SELECT unit_id, subject_id, course_id, created_by_type, created_by_id FROM course_books WHERE id = {$bookId} LIMIT 1");
        $bRow = $bRes ? mysqli_fetch_assoc($bRes) : null;
        if (!$bRow) return false;

        $cId = (int)($bRow['course_id'] ?? 0);
        $sId = (int)($bRow['subject_id'] ?? 0);
        $uId = (int)($bRow['unit_id'] ?? 0);
        if ($cId <= 0 && $uId > 0) {
            $uRes = mysqli_query($con, "SELECT course_id, subject_id FROM units WHERE id = {$uId} LIMIT 1");
            if ($uRes && $uRow = mysqli_fetch_assoc($uRes)) {
                if ($uRow['course_id']) $cId = (int)$uRow['course_id'];
                if ($uRow['subject_id']) $sId = (int)$uRow['subject_id'];
            }
        }
        if ($sId <= 0 && $cId > 0) {
            $cRes = mysqli_query($con, "SELECT subject_id FROM courses WHERE id = {$cId} LIMIT 1");
            if ($cRes && $cRow = mysqli_fetch_assoc($cRes)) {
                if ($cRow['subject_id']) $sId = (int)$cRow['subject_id'];
            }
        }

        $accessible = get_student_accessible_entities($con, $stId);
        $createdById = (int)($bRow['created_by_id'] ?? 0);

        return (
            ($cId > 0 && in_array($cId, $accessible['course_ids'])) ||
            ($sId > 0 && in_array($sId, $accessible['subject_ids'])) ||
            (($cId > 0 || $sId > 0) && ($bRow['created_by_type'] ?? '') === 'teacher' && in_array($createdById, $accessible['teacher_ids']))
        );
    }
}

if (!function_exists('studentStreamBookFile')) {
    // Authenticated, ownership-checked file stream — used for books with
    // allow_download = 0 instead of exposing a raw permanent public URL.
    function studentStreamBookFile($con, $studentData = null) {
        $stId = 0;
        if (is_array($studentData)) {
            $stId = (int)($studentData['id'] ?? $studentData['student_id'] ?? 0);
        } elseif (is_object($studentData)) {
            $stId = (int)($studentData->id ?? $studentData->student_id ?? 0);
        }
        if ($stId <= 0) {
            return ['status' => 'error', 'message' => 'Student authentication is required'];
        }

        $bookId = (int)($_GET['book_id'] ?? $_GET['id'] ?? 0);
        if ($bookId <= 0) {
            return ['status' => 'error', 'message' => 'book_id is required'];
        }

        if (!student_owns_book($con, $stId, $bookId)) {
            return ['status' => 'error', 'message' => 'You must be subscribed to access this book'];
        }

        $item = student_store_items_ready($con) ? store_item_find($con, $bookId) : null;
        if ($item) {
            // A physical item has no file; it is handed over off the platform.
            if (($item['product_type'] ?? 'physical') === 'physical') {
                return ['status' => 'error', 'message' => 'Book file is not available'];
            }
            $source = trim($item['file_path'] ?: ($item['link'] ?? '') ?: '');
            $fileType = store_item_file_type($item);
        } else {
            $bRes = mysqli_query($con, "SELECT file_path, link, file_type FROM course_books WHERE id = {$bookId} LIMIT 1");
            $bRow = $bRes ? mysqli_fetch_assoc($bRes) : null;
            if (!$bRow) {
                return ['status' => 'error', 'message' => 'Book not found'];
            }
            $source = trim($bRow['file_path'] ?: $bRow['link'] ?: '');
            $fileType = trim($bRow['file_type'] ?? 'pdf');
        }

        if ($source === '') {
            return ['status' => 'error', 'message' => 'Book file is not available'];
        }

        $mime = ($fileType === 'pdf') ? 'application/pdf' : 'application/octet-stream';

        if (preg_match('/^https?:\/\//i', $source)) {
            $ch = curl_init($source);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
            curl_setopt($ch, CURLOPT_TIMEOUT, 30);
            $content = curl_exec($ch);
            $ok = ($content !== false && curl_getinfo($ch, CURLINFO_HTTP_CODE) < 400);
            curl_close($ch);

            if (!$ok) {
                return ['status' => 'error', 'message' => 'Failed to load book file'];
            }

            header('Content-Type: ' . $mime);
            header('Content-Disposition: inline; filename="book-' . $bookId . '"');
            header('X-Content-Type-Options: nosniff');
            echo $content;
            exit();
        }

        $localPath = realpath(__DIR__ . '/../../../../' . ltrim($source, '/'));
        $uploadsRoot = realpath(__DIR__ . '/../../../../');
        if (!$localPath || !$uploadsRoot || !str_starts_with($localPath, $uploadsRoot) || !is_file($localPath)) {
            return ['status' => 'error', 'message' => 'Book file is not available'];
        }

        header('Content-Type: ' . $mime);
        header('Content-Disposition: inline; filename="' . basename($localPath) . '"');
        header('Content-Length: ' . filesize($localPath));
        header('X-Content-Type-Options: nosniff');
        readfile($localPath);
        exit();
    }
}

if (!function_exists('studentGetMyBookRequests')) {
    function studentGetMyBookRequests($con, $studentData = null) {
        $stId = 0;
        if (is_array($studentData)) {
            $stId = (int)($studentData['id'] ?? $studentData['student_id'] ?? 0);
        } elseif (is_object($studentData)) {
            $stId = (int)($studentData->id ?? $studentData->student_id ?? 0);
        }
        if ($stId <= 0) {
            $stId = (int)($_GET['student_id'] ?? 0);
        }
        if ($stId <= 0) {
            return build_admin_paginated_response([], 1, 10, 0, ['total_count' => 0]);
        }

        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 10)));
        $offset = ($page - 1) * $limit;

        $statusFilter = trim($_GET['status'] ?? '');
        $whereExtra = '';
        $allowed = ['pending', 'approved', 'rejected'];
        if (in_array($statusFilter, $allowed)) {
            $sf = mysqli_real_escape_string($con, $statusFilter);
            $whereExtra = " AND r.status = '{$sf}'";
        }

        $langInfo = get_language_info($con);
        $langId = (int)($langInfo['id'] ?? 1);

        $countRes = mysqli_query($con, "SELECT COUNT(*) AS total FROM student_book_purchase_requests r WHERE r.student_id = {$stId}{$whereExtra}");
        $total = $countRes ? (int)(mysqli_fetch_assoc($countRes)['total'] ?? 0) : 0;

        // A request names a store item (products). A very old request may still name a lesson
        // file from before purchases of those were refused, so course_books stays as a fallback.
        $productName = store_name_sql($langId, 'p');
        $sql = "
            SELECT r.id, r.book_id, r.status, r.notes, r.reviewed_by_type, r.reviewed_by_id, r.created_at, r.updated_at,
                   COALESCE({$productName}, bt.title, cb.file_path) AS book_title,
                   COALESCE(p.image, cb.link) AS book_cover
            FROM student_book_purchase_requests r
            LEFT JOIN products p ON r.book_id = p.id
            LEFT JOIN course_books cb ON r.book_id = cb.id
            LEFT JOIN course_books_translations bt ON cb.id = bt.book_id AND bt.language_id = {$langId}
            WHERE r.student_id = {$stId}{$whereExtra}
            ORDER BY r.id DESC
            LIMIT {$limit} OFFSET {$offset}
        ";

        $res = mysqli_query($con, $sql);
        $items = [];
        if ($res) {
            while ($row = mysqli_fetch_assoc($res)) {
                $row['id'] = (int)$row['id'];
                $row['book_id'] = (int)$row['book_id'];
                $row['reviewed_by_id'] = $row['reviewed_by_id'] ? (int)$row['reviewed_by_id'] : null;
                $row['book_cover'] = format_image_url($row['book_cover']);
                $items[] = $row;
            }
        }

        return build_admin_paginated_response($items, $page, $limit, $total, ['total_count' => $total]);
    }
}

if (!function_exists('student_public_store_item_details')) {
    /**
     * A store item in the shape `/books/show` returned for a book (get_book_details), plus the
     * product's own fields and its price for this visitor. The file keys are decided by the
     * caller, as for a lesson file.
     */
    function student_public_store_item_details($con, array $item, int $stId): array {
        $id = (int)$item['id'];
        $book = student_store_item_book_row($con, $item);
        unset($book['src_table']);
        $book['updated_at'] = $item['updated_at'] ?? null;
        $book['created_by'] = function_exists('get_course_created_by_details')
            ? get_course_created_by_details($con, $book['created_by_type'], $book['created_by_id'])
            : null;
        $book['teachers'] = get_content_teachers_details($con, 'book', $id);
        $book['teacher_ids'] = array_values(array_map(fn($t) => (int)$t['id'], $book['teachers']));
        pricing_decorate_row($con, $book, 'book', $stId);
        return format_response_images($book);
    }
}

if (!function_exists('studentGetPublicBookDetails')) {
    /**
     * Public book details for `/books/show`.
     *
     * That route is deliberately open — the landing page and a logged-out visitor both use it —
     * but it used to hand `adminGetBook()`'s full record straight back, file path and all. Anyone
     * who could guess an id could download any paid book without buying it.
     *
     * The record still comes back for any id, so no existing client starts seeing "not found"
     * where it used to see a book. What changes is the file: `file_path` and `link` are blanked
     * unless the caller is a logged-in student who actually owns the book. The keys stay present
     * and stay strings, so nothing breaks on their absence.
     */
    function studentGetPublicBookDetails($con, $studentData = null) {
        $stId = 0;
        if (is_array($studentData)) {
            $stId = (int)($studentData['id'] ?? $studentData['student_id'] ?? 0);
        } elseif (is_object($studentData)) {
            $stId = (int)($studentData->id ?? $studentData->student_id ?? 0);
        }

        // A store item first (products, where every standalone book now lives under its old id),
        // then a lesson file. The ids never collide.
        $id = (int)($_GET['id'] ?? read_json_body()['id'] ?? 0);
        $item = ($id > 0 && student_store_items_ready($con)) ? store_item_find($con, $id) : null;

        if ($item) {
            $result = ['status' => 'success', 'data' => student_public_store_item_details($con, $item, $stId)];
            $allowDownload = (int)($item['allow_download'] ?? 1) === 1;
            $hasFile = ($item['product_type'] ?? 'physical') !== 'physical';
        } else {
            require_once __DIR__ . '/../../../content/books/manage.php';
            $result = adminGetBook($con);
            if (($result['status'] ?? '') !== 'success' || !is_array($result['data'] ?? null)) {
                return $result;
            }
            $allowDownload = true;
            $hasFile = true;
            $lessonId = (int)($result['data']['id'] ?? 0);
            $adRes = $lessonId > 0 ? @mysqli_query($con, "SELECT allow_download FROM course_books WHERE id = {$lessonId} LIMIT 1") : false;
            if ($adRes && ($adRow = mysqli_fetch_assoc($adRes))) {
                $allowDownload = (int)($adRow['allow_download'] ?? 1) === 1;
            }
        }

        $book = $result['data'];
        $bookId = (int)($book['id'] ?? 0);
        $owns = $stId > 0 && student_owns_book($con, $stId, $bookId);

        // The file goes out only to an owner of a downloadable item. A view-only item is read
        // through the stream endpoint, never through its path - the same rule as the lists.
        if (!$owns || !$allowDownload || !$hasFile) {
            // Every key that can carry the file, not just file_path. get_book_details() already
            // ran format_response_images(), which copies file_path into `file` — and the pass
            // that runs again on the way out does `file_path = file` whenever both keys exist.
            // Blanking file_path alone was therefore undone a moment later, and the PDF URL went
            // out to anonymous callers exactly as before.
            foreach (['file_path', 'link', 'file', 'file_url', 'pdf', 'pdf_url', 'document', 'doc_url', 'view_url'] as $fileKey) {
                if (array_key_exists($fileKey, $book)) {
                    $book[$fileKey] = '';
                }
            }
            if ($owns && $hasFile && !$allowDownload) {
                $book['view_url'] = student_book_stream_url($bookId);
            }
        }
        $book['own'] = $owns;
        $book['is_subscribed'] = $owns;
        $book['is_locked'] = !$owns;

        $result['data'] = $book;
        return $result;
    }
}
