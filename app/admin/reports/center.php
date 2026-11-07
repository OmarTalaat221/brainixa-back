<?php
/**
 * مركز التقارير — Report Center.
 *
 * One place that pulls the four reports the platform was asked for straight out of the rows the
 * system already writes, with no new table and nothing to enter by hand:
 *
 *   sales      — المبيعات: every revenue source, over a range, with a daily series and top items
 *   attendance — حضور وغياب الطلاب والمعلمين في الحصص المباشرة
 *   payroll    — الرواتب والخصومات: earnings, fines, appeals and the net payable per teacher
 *   ratings    — تقييم الحصة المباشرة بعد كل حصة
 *
 * Nothing here records anything. Each report delegates to the module that already owns its
 * numbers — helpers/sales.php and statistics.php for money, attendance/reports.php for
 * attendance, session_ratings/manage.php for the stars — so "what counts as revenue" and "what
 * counts as attendance" are never defined a second time here and cannot drift. Payroll is the one
 * report with its own queries, because the wallet had a ledger and a balance but never a
 * per-period payslip.
 *
 * Every report answers the same two query parameters, `date_from` and `date_to`, and every one of
 * them can be downloaded as .xlsx over the same range.
 */

require_once __DIR__ . '/../../../helpers/functions.php';
require_once __DIR__ . '/../../../helpers/language.php';
require_once __DIR__ . '/../../../helpers/sales.php';
require_once __DIR__ . '/../../../helpers/pricing.php';
require_once __DIR__ . '/../dashboard/statistics.php';
require_once __DIR__ . '/../attendance/reports.php';
require_once __DIR__ . '/../export/export.php';
require_once __DIR__ . '/../../content/session_ratings/manage.php';

if (!function_exists('report_center_range')) {
    /**
     * The window every report in the centre is read over. Shared with the attendance report so a
     * range typed once means the same thing on all four screens; defaults to the last 30 days.
     */
    function report_center_range(): array {
        return attendance_report_range();
    }
}

if (!function_exists('report_center_catalog')) {
    /**
     * What the centre can produce, as data rather than as four hard-coded screens — so the
     * dashboard renders the list of reports from the API and a fifth report needs no front-end
     * release to appear.
     */
    function report_center_catalog(): array {
        return [
            [
                'key' => 'sales',
                'title_ar' => 'تقرير المبيعات',
                'title_en' => 'Sales report',
                'description_ar' => 'الإيرادات على مدى فترة، موزّعة على مصادرها، مع سلسلة يومية وأعلى الكورسات والكتب بيعًا.',
                'endpoint' => '/admin/report-center/sales',
                'export' => '/admin/report-center/export?type=sales',
                'filters' => ['date_from', 'date_to'],
            ],
            [
                'key' => 'attendance',
                'title_ar' => 'تقرير الحضور والغياب',
                'title_en' => 'Attendance report',
                'description_ar' => 'حضور الطلاب والمعلمين في الحصص المباشرة، كل جانب على حدة، مع نسب الحضور ودقائق التأخير.',
                'endpoint' => '/admin/report-center/attendance',
                'export' => '/admin/report-center/export?type=attendance&side=students',
                'filters' => ['date_from', 'date_to', 'side', 'search', 'page', 'limit'],
            ],
            [
                'key' => 'payroll',
                'title_ar' => 'تقرير الرواتب والخصومات',
                'title_en' => 'Payroll & deductions report',
                'description_ar' => 'أرباح كل معلم وخصوماته وتسويات الإدارة خلال الفترة، والصافي المستحق، وعدد التظلمات المعلّقة.',
                'endpoint' => '/admin/report-center/payroll',
                'export' => '/admin/report-center/export?type=payroll',
                'filters' => ['date_from', 'date_to', 'teacher_id', 'search', 'page', 'limit'],
            ],
            [
                'key' => 'ratings',
                'title_ar' => 'تقرير تقييم الحصص المباشرة',
                'title_en' => 'Live class ratings report',
                'description_ar' => 'متوسط تقييم كل معلم بعد الحصص، وتوزيع النجوم، وأقل الحصص تقييمًا مع تعليقات الطلاب.',
                'endpoint' => '/admin/report-center/ratings',
                'export' => '/admin/report-center/export?type=ratings',
                'filters' => ['date_from', 'date_to', 'teacher_id', 'rating', 'with_comment'],
            ],
        ];
    }
}

if (!function_exists('adminReportCenterCatalog')) {
    function adminReportCenterCatalog($con) {
        [$from, $to] = report_center_range();

        return [
            'status' => 'success',
            'data' => [
                'default_range' => ['date_from' => $from, 'date_to' => $to],
                'currency' => pricing_base_currency($con),
                'reports' => report_center_catalog(),
            ],
        ];
    }
}

/* ============================ المبيعات — Sales ============================ */

if (!function_exists('report_center_sales_data')) {
    /**
     * Revenue over the range, per source and per day.
     *
     * Read through `dashboard_revenue_sources()` rather than through `transactions` alone: a sale
     * on this platform can arrive as a gateway payment, a redeemed code, an approved bank
     * transfer, a book granted by hand or a subscription an admin typed in, and a "sales report"
     * that sees only one of those is wrong by however much the others are worth.
     */
    function report_center_sales_data($con, string $from, string $to): array {
        $sources = [];
        $daily = [];
        $total = 0.0;
        $orders = 0;

        foreach (dashboard_revenue_sources() as $key => $src) {
            $dateExpr = sales_date_filter($src['date'], $from, $to);

            $row = dashboard_fetch_row($con, "
                SELECT COALESCE(SUM({$src['amount']}), 0) AS total, COUNT(*) AS orders
                FROM {$src['from']}
                WHERE {$src['where']} {$dateExpr}
            ");

            $sourceTotal = round((float)($row['total'] ?? 0), 2);
            $sourceOrders = (int)($row['orders'] ?? 0);

            $total += $sourceTotal;
            $orders += $sourceOrders;

            $sources[] = [
                'key' => $key,
                'label_ar' => $src['label_ar'],
                'total' => $sourceTotal,
                'orders' => $sourceOrders,
            ];

            // One bucket per calendar day, summed across the sources into a single series: the
            // question a trend line answers is "how much came in that day", not "how much came in
            // that day through this particular door".
            foreach (dashboard_fetch_all($con, "
                SELECT DATE({$src['date']}) AS day,
                       COALESCE(SUM({$src['amount']}), 0) AS total,
                       COUNT(*) AS orders
                FROM {$src['from']}
                WHERE {$src['where']} {$dateExpr}
                GROUP BY DATE({$src['date']})
            ") as $bucket) {
                $day = $bucket['day'] ?? null;
                if (!$day) continue;

                if (!isset($daily[$day])) {
                    $daily[$day] = ['date' => $day, 'total' => 0.0, 'orders' => 0];
                }
                $daily[$day]['total'] += (float)($bucket['total'] ?? 0);
                $daily[$day]['orders'] += (int)($bucket['orders'] ?? 0);
            }
        }

        ksort($daily);
        $daily = array_values(array_map(function ($bucket) {
            $bucket['total'] = round($bucket['total'], 2);
            return $bucket;
        }, $daily));

        // Highest earning first, so the report opens on where the money actually comes from.
        usort($sources, fn($a, $b) => $b['total'] <=> $a['total']);

        $topItems = [];
        foreach ([['course', 'normal'], ['package', 'package']] as [$kind, $courseKind]) {
            foreach (sales_aggregate_courses($con, $courseKind, $from, $to) as $item) {
                $topItems[] = [
                    'kind' => $kind,
                    'id' => $item['id'] ?? ($item['course_id'] ?? null),
                    'name' => $item['name'] ?? '',
                    'sales_count' => (int)($item['sales_count'] ?? 0),
                    'revenue' => round((float)($item['revenue'] ?? 0), 2),
                ];
            }
        }
        foreach (sales_aggregate_books($con, $from, $to) as $item) {
            $topItems[] = [
                'kind' => 'book',
                'id' => $item['id'] ?? ($item['book_id'] ?? null),
                'name' => $item['name'] ?? '',
                'sales_count' => (int)($item['sales_count'] ?? 0),
                'revenue' => round((float)($item['revenue'] ?? 0), 2),
            ];
        }

        $topItems = array_values(array_filter($topItems, fn($i) => $i['sales_count'] > 0 || $i['revenue'] > 0));
        usort($topItems, fn($a, $b) => $b['revenue'] <=> $a['revenue']);
        $topItems = array_slice($topItems, 0, 20);

        $days = max(1, (int)((strtotime($to) - strtotime($from)) / 86400) + 1);

        return [
            'range' => ['date_from' => $from, 'date_to' => $to, 'days' => $days],
            'currency' => pricing_base_currency($con),
            'summary' => [
                'total' => round($total, 2),
                'orders' => $orders,
                'average_order' => $orders > 0 ? round($total / $orders, 2) : 0.0,
                'daily_average' => round($total / $days, 2),
            ],
            'sources' => $sources,
            'daily' => $daily,
            'top_items' => $topItems,
        ];
    }
}

if (!function_exists('adminReportCenterSales')) {
    function adminReportCenterSales($con) {
        [$from, $to] = report_center_range();

        return [
            'status' => 'success',
            'data' => report_center_sales_data($con, $from, $to),
        ];
    }
}

/* ======================= الحضور والغياب — Attendance ======================= */

if (!function_exists('adminReportCenterAttendance')) {
    /**
     * The attendance report as the centre serves it: both sides' totals on top, and one page of
     * per-person rows for whichever side is being looked at. The figures come from the attendance
     * report module, not from a second set of queries here.
     */
    function adminReportCenterAttendance($con) {
        [$from, $to] = report_center_range();

        $side = strtolower(trim($_GET['side'] ?? 'students'));
        $side = in_array($side, ['teachers', 'teacher'], true) ? 'teacher' : 'student';

        $overview = adminAttendanceReportOverview($con);
        $people = attendance_people_report($con, $side);

        return [
            'status' => 'success',
            'data' => [
                'range' => ['date_from' => $from, 'date_to' => $to],
                'side' => $side === 'teacher' ? 'teachers' : 'students',
                'summary' => $overview['data'] ?? [],
                'people' => $people['data'] ?? [],
                'pagination' => $people['pagination'] ?? null,
            ],
        ];
    }
}

/* ===================== الرواتب والخصومات — Payroll ===================== */

if (!function_exists('report_center_payroll_rows')) {
    /**
     * One payslip-shaped row per teacher for the range.
     *
     * The wallet already held every figure needed: `teacher_wallet_transactions` is written by the
     * attendance run (an earning per class held, a fine per late arrival or absence) and by admin
     * adjustments and approved appeals. What was missing was reading it per PERIOD instead of as a
     * running balance — an owner paying monthly cannot pay out of a lifetime total.
     *
     * The money is taken from the ledger rather than recomputed from the pay rate times the hours:
     * the ledger is what the teacher was actually credited, including any correction an admin has
     * since made, and a report that disagrees with the wallet is a report nobody can pay from.
     */
    function report_center_payroll_rows($con, string $from, string $to, array $opts = []): array {
        $fromAt = $from . ' 00:00:00';
        $toAt = $to . ' 23:59:59';

        $where = "w.created_at BETWEEN ? AND ?";
        $types = "ss";
        $params = [$fromAt, $toAt];

        $teacherId = (int)($opts['teacher_id'] ?? 0);
        if ($teacherId > 0) {
            $where .= " AND w.teacher_id = ?";
            $types .= "i";
            $params[] = $teacherId;
        }

        $search = trim((string)($opts['search'] ?? ''));
        if ($search !== '') {
            $where .= " AND (t.name LIKE ? OR t.email LIKE ?)";
            $types .= "ss";
            $pattern = '%' . $search . '%';
            $params[] = $pattern;
            $params[] = $pattern;
        }

        $stmt = mysqli_prepare($con, "
            SELECT
                w.teacher_id,
                COALESCE(t.name, CONCAT('#', w.teacher_id)) AS teacher_name,
                t.email AS teacher_email,
                t.wallet_balance,
                t.is_attendance_suspended,
                COALESCE(SUM(CASE WHEN w.type = 'earning' THEN w.amount ELSE 0 END), 0) AS earnings,
                COALESCE(SUM(CASE WHEN w.type = 'fine' THEN ABS(w.amount) ELSE 0 END), 0) AS fines,
                COALESCE(SUM(CASE WHEN w.type = 'refund' THEN w.amount ELSE 0 END), 0) AS refunds,
                COALESCE(SUM(CASE WHEN w.type = 'admin_adjustment' THEN w.amount ELSE 0 END), 0) AS adjustments,
                COALESCE(SUM(w.amount), 0) AS net,
                COALESCE(SUM(w.type = 'earning'), 0) AS earning_entries,
                COALESCE(SUM(w.type = 'fine'), 0) AS fine_entries
            FROM teacher_wallet_transactions w
            LEFT JOIN teachers t ON t.id = w.teacher_id
            WHERE {$where}
            GROUP BY w.teacher_id, t.name, t.email, t.wallet_balance, t.is_attendance_suspended
            ORDER BY net DESC
        ");

        if (!$stmt) {
            return [];
        }

        mysqli_stmt_bind_param($stmt, $types, ...$params);
        mysqli_stmt_execute($stmt);
        $res = mysqli_stmt_get_result($stmt);

        $rows = [];
        $ids = [];
        while ($row = mysqli_fetch_assoc($res)) {
            $id = (int)$row['teacher_id'];
            $ids[] = $id;
            $rows[$id] = [
                'teacher_id' => $id,
                'teacher_name' => $row['teacher_name'] ?? '',
                'teacher_email' => $row['teacher_email'] ?? null,
                'earnings' => round((float)$row['earnings'], 2),
                'fines' => round((float)$row['fines'], 2),
                'refunds' => round((float)$row['refunds'], 2),
                'adjustments' => round((float)$row['adjustments'], 2),
                'net' => round((float)$row['net'], 2),
                'earning_entries' => (int)$row['earning_entries'],
                'fine_entries' => (int)$row['fine_entries'],
                'wallet_balance' => round((float)$row['wallet_balance'], 2),
                'is_attendance_suspended' => (int)$row['is_attendance_suspended'] === 1,
                // Filled in below. Declared here so every row has the same shape even when a
                // teacher has wallet entries but no attendance rows in the range.
                'sessions_held' => 0,
                'sessions_late' => 0,
                'sessions_absent' => 0,
                'minutes_late' => 0,
                'pay_model' => null,
                'pay_rate' => null,
                'pending_appeals' => 0,
            ];
        }

        if (!$rows) {
            return [];
        }

        $idList = implode(',', array_map('intval', $ids));

        // How the money was earned, from the attendance side of the same classes. Kept as a
        // separate pass rather than joined in: joining attendance rows onto wallet rows multiplies
        // one against the other and every sum comes back inflated.
        foreach (dashboard_fetch_all($con, "
            SELECT teacher_id,
                   COALESCE(SUM(status IN ('present','late')), 0) AS held,
                   COALESCE(SUM(status = 'late'), 0) AS late_count,
                   COALESCE(SUM(status = 'absent'), 0) AS absent,
                   COALESCE(SUM(minutes_late), 0) AS minutes_late
            FROM teacher_session_attendance
            WHERE teacher_id IN ({$idList})
              AND occurrence_date BETWEEN '{$from}' AND '{$to}'
            GROUP BY teacher_id
        ") as $att) {
            $id = (int)$att['teacher_id'];
            if (!isset($rows[$id])) continue;
            $rows[$id]['sessions_held'] = (int)$att['held'];
            $rows[$id]['sessions_late'] = (int)$att['late_count'];
            $rows[$id]['sessions_absent'] = (int)$att['absent'];
            $rows[$id]['minutes_late'] = (int)$att['minutes_late'];
        }

        // The rate in force, so a net figure can be checked against what it was supposed to be.
        foreach (dashboard_fetch_all($con, "
            SELECT teacher_id, pay_model, rate_amount
            FROM teacher_pay_rates
            WHERE teacher_id IN ({$idList})
            ORDER BY id ASC
        ") as $rate) {
            $id = (int)$rate['teacher_id'];
            if (!isset($rows[$id])) continue;
            $rows[$id]['pay_model'] = $rate['pay_model'];
            $rows[$id]['pay_rate'] = round((float)$rate['rate_amount'], 2);
        }

        // A disputed deduction is still deducted while the appeal is open, so a payroll row that
        // does not say one is pending invites paying a figure that is about to change.
        foreach (dashboard_fetch_all($con, "
            SELECT teacher_id, COUNT(*) AS pending
            FROM teacher_deduction_appeals
            WHERE teacher_id IN ({$idList}) AND status = 'pending'
            GROUP BY teacher_id
        ") as $appeal) {
            $id = (int)$appeal['teacher_id'];
            if (!isset($rows[$id])) continue;
            $rows[$id]['pending_appeals'] = (int)$appeal['pending'];
        }

        return array_values($rows);
    }
}

if (!function_exists('adminReportCenterPayroll')) {
    function adminReportCenterPayroll($con) {
        [$from, $to] = report_center_range();

        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 20)));

        $rows = report_center_payroll_rows($con, $from, $to, [
            'teacher_id' => (int)($_GET['teacher_id'] ?? 0),
            'search' => $_GET['search'] ?? $_GET['q'] ?? '',
        ]);

        $totals = [
            'teachers' => count($rows),
            'earnings' => round(array_sum(array_column($rows, 'earnings')), 2),
            'fines' => round(array_sum(array_column($rows, 'fines')), 2),
            'refunds' => round(array_sum(array_column($rows, 'refunds')), 2),
            'adjustments' => round(array_sum(array_column($rows, 'adjustments')), 2),
            'net_payable' => round(array_sum(array_column($rows, 'net')), 2),
            'sessions_held' => array_sum(array_column($rows, 'sessions_held')),
            'pending_appeals' => array_sum(array_column($rows, 'pending_appeals')),
        ];

        $response = sales_paginate($rows, $page, $limit);
        $response['range'] = ['date_from' => $from, 'date_to' => $to];
        $response['currency'] = pricing_base_currency($con);
        $response['statistics'] = $totals;

        return $response;
    }
}

/* =================== تقييم الحصص المباشرة — Ratings =================== */

if (!function_exists('adminReportCenterRatings')) {
    /**
     * The ratings report: the per-teacher averages and star distribution the summary endpoint
     * already produces, plus the individual ratings behind them. The per-teacher list is ordered
     * worst average first, which is what the summary endpoint already does, so the teacher who
     * needs looking at is the first row rather than something to be found by sorting.
     *
     * The individual ratings come back newest first; `rating=1` or `with_comment=1` narrow them to
     * the bad ones and the ones with something written in them, which is the part anybody acts on.
     */
    function adminReportCenterRatings($con) {
        [$from, $to] = report_center_range();

        $summary = session_ratings_summary($con, null);
        $list = session_ratings_list($con, null);

        return [
            'status' => 'success',
            'data' => [
                'range' => ['date_from' => $from, 'date_to' => $to],
                'overall' => $summary['data']['overall'] ?? null,
                'teachers' => $summary['data']['teachers'] ?? [],
                'ratings' => $list['data'] ?? [],
                'pagination' => $list['pagination'] ?? null,
            ],
        ];
    }
}

/* ============================ التصدير — Export ============================ */

if (!function_exists('adminReportCenterExport')) {
    /**
     * Any of the four reports as a spreadsheet, over the same range the screen is filtered to.
     * Attendance is handed to the attendance module's own export rather than re-tabulated here.
     */
    function adminReportCenterExport($con) {
        $lang = get_request_lang($con);
        [$from, $to] = report_center_range();
        $type = strtolower(trim($_GET['type'] ?? 'sales'));

        if ($type === 'attendance') {
            // `type` means the report here and the side there, so it is translated on the way in.
            $side = strtolower(trim($_GET['side'] ?? 'students'));
            $_GET['type'] = in_array($side, ['teachers', 'teacher'], true)
                ? 'teachers'
                : ($side === 'sessions' ? 'sessions' : 'students');
            return adminExportAttendanceReport($con);
        }

        if ($type === 'payroll') {
            $header = $lang === 'ar'
                ? ['المعرف', 'المعلم', 'البريد', 'حصص تمّت', 'تأخير (حصص)', 'غياب (حصص)', 'دقائق التأخير', 'الأرباح', 'الخصومات', 'المرتجعات', 'تسويات الإدارة', 'الصافي', 'نموذج الأجر', 'قيمة الأجر', 'تظلمات معلّقة', 'رصيد المحفظة', 'موقوف للحضور']
                : ['ID', 'Teacher', 'Email', 'Sessions held', 'Late sessions', 'Absent sessions', 'Minutes late', 'Earnings', 'Fines', 'Refunds', 'Adjustments', 'Net', 'Pay model', 'Pay rate', 'Pending appeals', 'Wallet balance', 'Attendance suspended'];

            $rows = [];
            foreach (report_center_payroll_rows($con, $from, $to, [
                'teacher_id' => (int)($_GET['teacher_id'] ?? 0),
                'search' => $_GET['search'] ?? $_GET['q'] ?? '',
            ]) as $row) {
                $rows[] = [
                    $row['teacher_id'],
                    $row['teacher_name'],
                    $row['teacher_email'] ?? '-',
                    $row['sessions_held'],
                    $row['sessions_late'],
                    $row['sessions_absent'],
                    $row['minutes_late'],
                    $row['earnings'],
                    $row['fines'],
                    $row['refunds'],
                    $row['adjustments'],
                    $row['net'],
                    $row['pay_model'] ?? '-',
                    $row['pay_rate'] ?? '-',
                    $row['pending_appeals'],
                    $row['wallet_balance'],
                    exportYesNo($row['is_attendance_suspended'], $lang),
                ];
            }

            sendExcelExport(
                $header,
                $rows,
                $lang === 'ar' ? 'الرواتب والخصومات' : 'Payroll',
                $lang,
                'payroll_' . $from . '_' . $to
            );
            return;
        }

        if ($type === 'ratings') {
            $header = $lang === 'ar'
                ? ['المعرف', 'المعلم', 'عدد التقييمات', 'حصص مُقيَّمة', 'المتوسط', '5 نجوم', '4 نجوم', '3 نجوم', 'نجمتان', 'نجمة']
                : ['ID', 'Teacher', 'Ratings', 'Sessions rated', 'Average', '5 stars', '4 stars', '3 stars', '2 stars', '1 star'];

            $summary = session_ratings_summary($con, null);
            $rows = [];
            foreach ($summary['data']['teachers'] ?? [] as $row) {
                $rows[] = [
                    $row['teacher_id'] ?? '-',
                    $row['teacher_name'],
                    $row['ratings'],
                    $row['sessions_rated'],
                    $row['average'] ?? '-',
                    $row['distribution']['5'] ?? 0,
                    $row['distribution']['4'] ?? 0,
                    $row['distribution']['3'] ?? 0,
                    $row['distribution']['2'] ?? 0,
                    $row['distribution']['1'] ?? 0,
                ];
            }

            sendExcelExport(
                $header,
                $rows,
                $lang === 'ar' ? 'تقييم الحصص' : 'Session ratings',
                $lang,
                'session_ratings_' . $from . '_' . $to
            );
            return;
        }

        // Sales. Two blocks in one sheet - the sources, then the day-by-day - because an owner
        // reading a sales export wants the split and the trend together, not two files.
        $data = report_center_sales_data($con, $from, $to);
        $currency = $data['currency'];

        $header = $lang === 'ar'
            ? ['البند', 'التفصيل', 'عدد العمليات', 'الإيراد (' . $currency . ')']
            : ['Section', 'Detail', 'Orders', 'Revenue (' . $currency . ')'];

        $rows = [];
        $sectionSources = $lang === 'ar' ? 'مصدر الإيراد' : 'Revenue source';
        $sectionDaily = $lang === 'ar' ? 'يومي' : 'Daily';
        $sectionItems = $lang === 'ar' ? 'الأكثر بيعًا' : 'Top selling';
        $sectionTotal = $lang === 'ar' ? 'الإجمالي' : 'Total';

        foreach ($data['sources'] as $src) {
            $rows[] = [$sectionSources, $src['label_ar'], $src['orders'], $src['total']];
        }
        $rows[] = [$sectionTotal, $lang === 'ar' ? 'إجمالي الفترة' : 'Range total', $data['summary']['orders'], $data['summary']['total']];
        foreach ($data['daily'] as $day) {
            $rows[] = [$sectionDaily, $day['date'], $day['orders'], $day['total']];
        }
        foreach ($data['top_items'] as $item) {
            $rows[] = [$sectionItems, $item['name'], $item['sales_count'], $item['revenue']];
        }

        sendExcelExport(
            $header,
            $rows,
            $lang === 'ar' ? 'المبيعات' : 'Sales',
            $lang,
            'sales_report_' . $from . '_' . $to
        );
    }
}
