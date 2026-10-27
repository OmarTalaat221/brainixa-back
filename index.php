<?php
error_reporting(E_ALL);
ini_set("display_errors", 1);

require_once "./config/serverConfig.php";
require_once "./helpers/functions.php";
require_once "./helpers/language.php";
require_once "./helpers/JWT.php";
require_once "./helpers/entities.php";
require_once "./helpers/email_verification.php";
require_once "./helpers/password_reset.php";
require_once "./helpers/rbac.php";
require_once "./config/connection.php";

if (!function_exists('handleRoute')) {
    function handleRoute($route, $currentMethod, $currentPath, $con)
    {
        $allowedMethods = is_array($route["method"] ?? null) ? $route["method"] : [$route["method"] ?? ""];
        if (!in_array($currentMethod, $allowedMethods, true)) {
            return;
        }

        if (isset($route["path"]) && $route["path"] === $currentPath) {
            $result = $route["handler"]($con);
            json_response($result);
            exit();
        }

        if (!empty($route["regex"])) {
            if (preg_match($route["regex"], $currentPath, $matches)) {
                $result = $route["handler"]($con, $matches);
                json_response($result);
                exit();
            }
        }
    }
}

if (!function_exists('handleTokenRefresh')) {
    function handleTokenRefresh(string $defaultRole = 'student') {
        $body = read_json_body();
        $refreshToken = trim($body['refresh_token'] ?? '');
        $role = strtolower(trim($body['role'] ?? $defaultRole));

        if (empty($refreshToken)) {
            json_response(['status' => 'error', 'message' => trans('refresh_token_required')], 400);
        }

        $decoded = verifyRefreshToken($refreshToken, $role);
        if (!$decoded) {
            json_response(['status' => 'error', 'message' => trans('invalid_refresh_token')], 401);
        }

        $tablesByRole = [
            'teacher' => 'teachers',
            'student' => 'students',
            'parent' => 'parents',
            'admin' => 'admins',
        ];
        $table = $tablesByRole[$role] ?? null;
        if ($table && !empty($decoded['id'])) {
            global $con;
            $stmt = mysqli_prepare($con, "SELECT is_active FROM {$table} WHERE id = ? LIMIT 1");
            $entityId = (int)$decoded['id'];
            mysqli_stmt_bind_param($stmt, "i", $entityId);
            mysqli_stmt_execute($stmt);
            $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));
            if (!$row || (int)$row['is_active'] === 0) {
                json_response(['status' => 'error', 'message' => trans('account_inactive')], 403);
            }

            // Gated here too, or a revoked device could mint itself fresh access tokens forever
            // and an admin reset would never actually end that session.
            if ($role === 'student') {
                require_once __DIR__ . '/helpers/devices.php';

                if (!empty($decoded['did']) && !device_is_authorized($con, 'student', $entityId, (string)$decoded['did'])) {
                    json_response([
                        'status' => 'error',
                        'message' => 'تم إلغاء تفعيل هذا الجهاز. يرجى تسجيل الدخول مرة أخرى أو التواصل مع الدعم الفني.',
                        'error_code' => 'device_revoked'
                    ], 403);
                }

                // A refresh token outlives an access token by a month, so this is the one that
                // matters most: without it, "sign out everywhere" would last an hour.
                if (session_is_revoked($con, $entityId, $decoded['iat'] ?? 0)) {
                    json_response([
                        'status' => 'error',
                        'message' => 'تم تسجيل خروجك من كل الأجهزة. يرجى تسجيل الدخول مرة أخرى.',
                        'error_code' => 'session_revoked'
                    ], 403);
                }
            }
        }

        unset($decoded['token_type'], $decoded['iat'], $decoded['exp'], $decoded['role']);

        $newTokens = generateTokens($decoded, $role);
        return [
            'status' => 'success',
            'message' => trans('tokens_refreshed_success'),
            'data' => $newTokens
        ];
    }
}

if (!function_exists('handleVerifyEmailOtp')) {
    function handleVerifyEmailOtp($con, string $defaultRole = 'student') {
        $body = read_json_body();
        $email = strtolower(trim($body['email'] ?? ''));
        $code = trim($body['code'] ?? $body['otp'] ?? $body['verification_code'] ?? '');
        $role = strtolower(trim($body['role'] ?? $body['user_type'] ?? $defaultRole));

        if (empty($email) || empty($code)) {
            json_response(['status' => 'error', 'message' => 'Email and verification OTP code (code or otp) are required'], 400);
        }

        $verified = verifyEmailWithOtp($con, $role, $email, $code);
        if (!$verified) {
            json_response(['status' => 'error', 'message' => trans('invalid_otp_code')], 400);
        }

        $tableMap = ['student' => 'students', 'teacher' => 'teachers', 'parent' => 'parents', 'admin' => 'admins'];
        $tableName = $tableMap[$role] ?? 'students';
        $stmt = mysqli_prepare($con, "SELECT id, name, email FROM {$tableName} WHERE email = ? LIMIT 1");
        $tokens = null;
        if ($stmt) {
            mysqli_stmt_bind_param($stmt, "s", $email);
            mysqli_stmt_execute($stmt);
            $uRow = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));
            if ($uRow) {
                $payload = [
                    'id' => (int)$uRow['id'],
                    'name' => $uRow['name'],
                    'email' => $uRow['email'],
                    'role' => $role
                ];
                $tokens = generateStudentTokens($payload);
            }
        }

        return [
            'status' => 'success',
            'message' => trans('email_verified_success'),
            'data' => [
                'is_email_verified' => true,
                'tokens' => $tokens
            ]
        ];
    }
}

if (!function_exists('handleResendOtp')) {
    function handleResendOtp($con, string $defaultRole = 'student') {
        $body = read_json_body();
        $email = strtolower(trim($body['email'] ?? ''));
        $role = strtolower(trim($body['role'] ?? $body['user_type'] ?? $defaultRole));

        if (empty($email)) {
            json_response(['status' => 'error', 'message' => trans('invalid_email')], 400);
        }

        $tableMap = ['student' => 'students', 'teacher' => 'teachers', 'parent' => 'parents', 'admin' => 'admins'];
        $tableName = $tableMap[$role] ?? 'students';

        $stmt = mysqli_prepare($con, "SELECT id FROM {$tableName} WHERE email = ? LIMIT 1");
        mysqli_stmt_bind_param($stmt, "s", $email);
        mysqli_stmt_execute($stmt);
        $res = mysqli_stmt_get_result($stmt);
        $row = mysqli_fetch_assoc($res);

        if (!$row) {
            json_response(['status' => 'error', 'message' => trans('profile_not_found')], 404);
        }

        $userId = (int)$row['id'];
        $otpInfo = generateAndSendOtp($con, $role, $userId, $email);

        return [
            'status' => 'success',
            'message' => trans('otp_sent_success'),
            'data' => [
                'otp_code' => $otpInfo['code'],
                'expires_at' => $otpInfo['expires_at']
            ]
        ];
    }
}

if (!function_exists('handleForgotPassword')) {
    function handleForgotPassword($con, string $defaultRole = 'student') {
        $body = read_json_body();
        $email = strtolower(trim($body['email'] ?? ''));
        $role = strtolower(trim($body['role'] ?? $body['user_type'] ?? $defaultRole));

        return sendPasswordResetOtp($con, $role, $email);
    }
}

if (!function_exists('handleVerifyResetCode')) {
    function handleVerifyResetCode($con, string $defaultRole = 'student') {
        $body = read_json_body();
        $email = strtolower(trim($body['email'] ?? ''));
        $code = trim($body['code'] ?? '');
        $role = strtolower(trim($body['role'] ?? $body['user_type'] ?? $defaultRole));

        return verifyPasswordResetOtp($con, $role, $email, $code);
    }
}

if (!function_exists('handleResetPassword')) {
    function handleResetPassword($con, string $defaultRole = 'student') {
        $body = read_json_body();
        $email = strtolower(trim($body['email'] ?? ''));
        $codeOrToken = trim($body['code'] ?? $body['reset_token'] ?? '');
        $newPassword = trim($body['new_password'] ?? $body['password'] ?? '');
        $role = strtolower(trim($body['role'] ?? $body['user_type'] ?? $defaultRole));

        return resetPasswordWithCodeOrToken($con, $role, $email, $codeOrToken, $newPassword);
    }
}

$method = strtoupper($_SERVER["REQUEST_METHOD"] ?? "GET");
if ($method === 'POST') {
    $override = $_POST['_method'] ?? $_GET['_method'] ?? $_SERVER['HTTP_X_HTTP_METHOD_OVERRIDE'] ?? null;
    if ($override) {
        $method = strtoupper($override);
    }
}
$path = parse_url($_SERVER["REQUEST_URI"] ?? "/", PHP_URL_PATH) ?: "/";
if ($path !== "/" && substr($path, -1) === "/") {
    $path = rtrim($path, "/");
}

$routes = [
    [
        "method" => "GET",
        "path" => "/brain-ixa",
        "handler" => function ($con) {
            return [
                "status" => "ok",
                "message" => "Welcome to Brainixa Platform API",
                "language" => get_request_lang($con)
            ];
        },
    ],

    // Global Verification, Token & Password Reset Endpoints ---
    [
        "method" => "POST",
        "path" => "/brain-ixa/auth/refresh",
        "handler" => function () {
            return handleTokenRefresh('student');
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/auth/verify-email",
        "handler" => function ($con) {
            return handleVerifyEmailOtp($con, 'student');
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/auth/resend-otp",
        "handler" => function ($con) {
            return handleResendOtp($con, 'student');
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/auth/forgot-password",
        "handler" => function ($con) {
            return handleForgotPassword($con, 'student');
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/auth/verify-reset-code",
        "handler" => function ($con) {
            return handleVerifyResetCode($con, 'student');
        },
    ],
           [
            "method" => "GET",
            "path" => "/brain-ixa/student/notifications",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/notifications/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentListNotifications($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/user/student/notifications",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/notifications/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentListNotifications($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/notifications/unread-count",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/notifications/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentGetNotificationUnreadCount($con, $studentData);
            },
        ],
         [
            "method" => "GET",
            "path" => "/brain-ixa/teacher/home",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/content/home.php";
                $teacherData = teacherAuthMiddleware();
                return teacherHome($con, $teacherData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/teacher/chat/directory",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/chat/directory.php";
                $teacherData = teacherAuthMiddleware();
                return chatListDirectory($con, $teacherData, 'teacher');
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/chat/directory",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/chat/directory.php";
                $studentData = studentAuthMiddleware();
                return chatListDirectory($con, $studentData, 'student');
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/parent/chat/directory",
            "handler" => function ($con) {
                include_once "./middlewares/parentauthmiddleware.php";
                include_once "./app/chat/directory.php";
                $parentData = parentAuthMiddleware();
                return chatListDirectory($con, $parentData, 'parent');
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/teacher/content/home",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/content/home.php";
                $teacherData = teacherAuthMiddleware();
                return teacherHome($con, $teacherData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/teacher/notifications",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/notifications/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherListNotifications($con, $teacherData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/teacher/notifications/unread-count",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/notifications/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherGetNotificationUnreadCount($con, $teacherData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/teacher/notifications/read",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/notifications/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherMarkNotificationRead($con, $teacherData);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/teacher/notifications/read",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/notifications/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherMarkNotificationRead($con, $teacherData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/teacher/notifications/mark-read",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/notifications/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherMarkNotificationRead($con, $teacherData);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/teacher/notifications",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/notifications/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherDeleteNotification($con, $teacherData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/teacher/notifications/delete",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/notifications/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherDeleteNotification($con, $teacherData);
            },
        ],
    

 
        // Student Auth
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/student/auth/login",
            "handler" => function ($con) {
                include_once "./app/user/student/auth/login.php";
                return studentLogin($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/student/auth/register",
            "handler" => function ($con) {
                include_once "./app/user/student/auth/register.php";
                return studentRegister($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/student/auth/verify-email",
            "handler" => function ($con) {
                return handleVerifyEmailOtp($con, 'student');
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/student/auth/resend-otp",
            "handler" => function ($con) {
                return handleResendOtp($con, 'student');
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/student/auth/forgot-password",
            "handler" => function ($con) {
                return handleForgotPassword($con, 'student');
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/student/auth/verify-reset-code",
            "handler" => function ($con) {
                return handleVerifyResetCode($con, 'student');
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/student/auth/reset-password",
            "handler" => function ($con) {
                return handleResetPassword($con, 'student');
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/student/auth/refresh",
            "handler" => function () {
                return handleTokenRefresh('student');
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/user/student/auth/profile",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/auth/profile.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentProfile($con, $studentData);
            },
        ],
        [
            "method" => ["PUT", "POST", "PATCH"],
            "path" => "/brain-ixa/user/student/auth/profile",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/auth/profile.php";
                $studentData = studentAuthMiddleware();
                return studentUpdateProfile($con, $studentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/student/fcm-token",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/auth/profile.php";
                $studentData = studentAuthMiddleware();
                return studentUpdateFcmToken($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/notifications",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/notifications/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentListNotifications($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/user/student/notifications",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/notifications/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentListNotifications($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/notifications/unread-count",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/notifications/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentGetNotificationUnreadCount($con, $studentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/student/notifications/read",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/notifications/manage.php";
                $studentData = studentAuthMiddleware();
                return studentMarkNotificationRead($con, $studentData);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/student/notifications/read",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/notifications/manage.php";
                $studentData = studentAuthMiddleware();
                return studentMarkNotificationRead($con, $studentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/student/notifications/mark-read",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/notifications/manage.php";
                $studentData = studentAuthMiddleware();
                return studentMarkNotificationRead($con, $studentData);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/student/notifications",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/notifications/manage.php";
                $studentData = studentAuthMiddleware();
                return studentDeleteNotification($con, $studentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/student/notifications/delete",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/notifications/manage.php";
                $studentData = studentAuthMiddleware();
                return studentDeleteNotification($con, $studentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/student/notifications/read",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/notifications/manage.php";
                $studentData = studentAuthMiddleware();
                return studentMarkNotificationRead($con, $studentData);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/student/notifications/read",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/notifications/manage.php";
                $studentData = studentAuthMiddleware();
                return studentMarkNotificationRead($con, $studentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/student/notifications/mark-read",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/notifications/manage.php";
                $studentData = studentAuthMiddleware();
                return studentMarkNotificationRead($con, $studentData);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/student/notifications",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/notifications/manage.php";
                $studentData = studentAuthMiddleware();
                return studentDeleteNotification($con, $studentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/student/notifications/delete",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/notifications/manage.php";
                $studentData = studentAuthMiddleware();
                return studentDeleteNotification($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/user/student/notifications/unread-count",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/notifications/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentGetNotificationUnreadCount($con, $studentData);
            },
        ],
        [
            "method" => ["POST", "PUT"],
            "path" => "/brain-ixa/user/student/notifications/read",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/notifications/manage.php";
                $studentData = studentAuthMiddleware();
                return studentMarkNotificationRead($con, $studentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/student/notifications/mark-read",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/notifications/manage.php";
                $studentData = studentAuthMiddleware();
                return studentMarkNotificationRead($con, $studentData);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/user/student/notifications",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/notifications/manage.php";
                $studentData = studentAuthMiddleware();
                return studentDeleteNotification($con, $studentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/student/notifications/delete",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/notifications/manage.php";
                $studentData = studentAuthMiddleware();
                return studentDeleteNotification($con, $studentData);
            },
        ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/auth/reset-password",
        "handler" => function ($con) {
            return handleResetPassword($con, 'student');
        },
    ],

    // Public Essential Lookup Routes ----------------------
    [
        "method" => "GET",
        "path" => "/brain-ixa/cities",
        "handler" => function ($con) {
            include_once "./app/user/student/lookups/cities.php";
            return studentListCities($con);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/school-types",
        "handler" => function ($con) {
            include_once "./app/user/student/lookups/school_types.php";
            return studentListSchoolTypes($con);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/schools",
        "handler" => function ($con) {
            include_once "./app/user/student/lookups/schools.php";
            return studentListSchools($con);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/subjects",
        "handler" => function ($con) {
            include_once "./app/user/student/lookups/subjects.php";
            return studentListSubjects($con);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/languages",
        "handler" => function ($con) {
            include_once "./app/user/student/lookups/languages.php";
            return studentListLanguages($con);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/academic-years",
        "handler" => function ($con) {
            include_once "./app/user/student/lookups/academic_years.php";
            return studentListAcademicYears($con);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/course-categories",
        "handler" => function ($con) {
            include_once "./app/user/student/lookups/course_categories.php";
            return studentListCourseCategories($con);
        },
    ],

    // Banners Public Routes --------------------------------
    [
        "method" => "GET",
        "path" => "/brain-ixa/banners",
        "handler" => function ($con) {
            include_once "./app/user/student/lookups/banners.php";
            return studentListBanners($con);
        },
    ],
    [
        // The website's hero backgrounds. Public and read-only: the landing page is seen by
        // visitors who have not signed in.
        "method" => "GET",
        "path" => "/brain-ixa/hero-slides",
        "handler" => function ($con) {
            include_once "./app/admin/hero_slides/manage.php";
            return publicHeroSlides($con);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/banners/view",
        "handler" => function ($con) {
            include_once "./app/user/student/lookups/banners.php";
            return studentTrackBannerView($con);
        },
    ],

    // Courses Public Routes --------------------------------
    [
        "method" => "GET",
        "path" => "/brain-ixa/courses",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/user/student/content/courses.php";
            $studentData = studentAuthMiddlewareOptional();
            return studentGetAllCoursesWithOwn($con, $studentData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/courses/show",
        "handler" => function ($con) {
            include_once "./app/user/student/content/courses.php";
            return studentGetCourseDetails($con);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/student/courses/units",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/user/student/content/units.php";
            $studentData = studentAuthMiddlewareOptional();
            return studentGetCourseUnitsOnly($con, $studentData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/student/units",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/user/student/content/units.php";
            $studentData = studentAuthMiddlewareOptional();
            return studentGetCourseUnitsOnly($con, $studentData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/student/units/videos",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/user/student/content/units.php";
            $studentData = studentAuthMiddlewareOptional();
            return studentGetUnitVideosOnly($con, $studentData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/student/unit/videos",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/user/student/content/units.php";
            $studentData = studentAuthMiddlewareOptional();
            return studentGetUnitVideosOnly($con, $studentData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/student/units/questions",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/user/student/content/units.php";
            $studentData = studentAuthMiddlewareOptional();
            return studentGetUnitQuestionsOnly($con, $studentData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/student/unit/questions",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/user/student/content/units.php";
            $studentData = studentAuthMiddlewareOptional();
            return studentGetUnitQuestionsOnly($con, $studentData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/student/questions/answer",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/user/student/content/questions.php";
            $studentData = studentAuthMiddleware();
            return studentSubmitQuestionAnswer($con, $studentData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/student/questions/submit-answer",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/user/student/content/questions.php";
            $studentData = studentAuthMiddleware();
            return studentSubmitQuestionAnswer($con, $studentData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/student/videos/show",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/user/student/content/videos.php";
            $studentData = studentAuthMiddlewareOptional();
            return studentGetVideoDetails($con, $studentData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/student/videos/details",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/user/student/content/videos.php";
            $studentData = studentAuthMiddlewareOptional();
            return studentGetVideoDetails($con, $studentData);
        },
    ],

    // Content Public Routes --------------------------------
    [
        "method" => "GET",
        "path" => "/brain-ixa/units",
        "handler" => function ($con) {
            include_once "./app/admin/courses/content.php";
            return adminListUnits($con);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/units/show",
        "handler" => function ($con) {
            include_once "./app/admin/courses/content.php";
            return adminGetUnit($con);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/videos",
        "handler" => function ($con) {
            include_once "./app/admin/courses/content.php";
            return adminListVideos($con);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/videos/show",
        "handler" => function ($con) {
            include_once "./app/admin/courses/content.php";
            return adminGetVideo($con);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/books",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/user/student/content/books.php";
            $studentData = studentAuthMiddlewareOptional();
            return studentGetAllBooksWithOwn($con, $studentData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/books/show",
        "handler" => function ($con) {
            include_once "./app/admin/courses/content.php";
            return adminGetBook($con);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/exams",
        "handler" => function ($con) {
            include_once "./app/admin/courses/content.php";
            return adminListExams($con);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/exams/show",
        "handler" => function ($con) {
            include_once "./app/admin/courses/content.php";
            return adminGetExam($con);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/questions",
        "handler" => function ($con) {
            include_once "./app/admin/courses/content.php";
            return adminListQuestions($con);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/questions/show",
        "handler" => function ($con) {
            include_once "./app/admin/courses/content.php";
            return adminGetQuestion($con);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/certificates",
        "handler" => function ($con) {
            include_once "./app/admin/courses/content.php";
            return adminListCertificates($con);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/certificates/show",
        "handler" => function ($con) {
            include_once "./app/admin/courses/content.php";
            return adminGetCertificate($con);
        },
    ],

    // Teacher Content & Courses Routes --------------------------------
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/units",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            $tId = (int)($teacherData['id'] ?? $teacherData['teacher_id'] ?? $teacherData->id ?? 0);
            if ($tId > 0 && !isset($_GET['teacher_id'])) {
                $_GET['teacher_id'] = $tId;
            }
            return adminListUnits($con);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/units",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            return adminCreateUnit($con, $teacherData);
        },
    ],
    [
        "method" => "PUT",
        "path" => "/brain-ixa/teacher/units",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            return adminUpdateUnit($con, $teacherData);
        },
    ],
    [
        "method" => "DELETE",
        "path" => "/brain-ixa/teacher/units",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            return adminDeleteUnit($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/units/reorder",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            return adminReorderUnits($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/videos",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            $tId = (int)($teacherData['id'] ?? $teacherData['teacher_id'] ?? $teacherData->id ?? 0);
            if ($tId > 0 && !isset($_GET['teacher_id'])) {
                $_GET['teacher_id'] = $tId;
            }
            return adminListVideos($con);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/videos",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            return adminCreateVideo($con, $teacherData);
        },
    ],
    [
        "method" => "PUT",
        "path" => "/brain-ixa/teacher/videos",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            return adminUpdateVideo($con, $teacherData);
        },
    ],
    [
        "method" => "DELETE",
        "path" => "/brain-ixa/teacher/videos",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            return adminDeleteVideo($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/videos/reorder",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            teacherAuthMiddleware();
            return adminReorderVideos($con);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/books",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            $tId = (int)($teacherData['id'] ?? $teacherData['teacher_id'] ?? $teacherData->id ?? 0);
            if ($tId > 0 && !isset($_GET['teacher_id'])) {
                $_GET['teacher_id'] = $tId;
            }
            return adminListBooks($con);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/books",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            return adminCreateBook($con, $teacherData);
        },
    ],
    [
        "method" => "PUT",
        "path" => "/brain-ixa/teacher/books",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            return adminUpdateBook($con, $teacherData);
        },
    ],
    [
        "method" => "DELETE",
        "path" => "/brain-ixa/teacher/books",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            return adminDeleteBook($con, $teacherData);
        },
    ],
    [
        // Teacher's own "Open" action for a view-only (allow_download = 0) book/exam - the same
        // authenticated stream a student gets, never the bare file.
        "method" => "GET",
        "path" => "/brain-ixa/teacher/books/stream",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            teacherAuthMiddleware();
            return adminStreamBookFile($con);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/books/reorder",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            teacherAuthMiddleware();
            return adminReorderBooks($con);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/books/grant-access",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            $bookManagePath = __DIR__ . "/app/teacher/books/manage.php";
            if (!file_exists($bookManagePath)) {
                return ['status' => 'error', 'message' => 'DIAGNOSTIC: file does not exist on server at ' . $bookManagePath];
            }
            include_once $bookManagePath;
            if (!function_exists('teacherGrantBookAccessToStudent')) {
                return ['status' => 'error', 'message' => 'DIAGNOSTIC: file exists (size ' . filesize($bookManagePath) . ' bytes) but function teacherGrantBookAccessToStudent is not defined after include'];
            }
            $teacherData = teacherAuthMiddleware();
            return teacherGrantBookAccessToStudent($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/books/purchase-requests",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            $bookManagePath = __DIR__ . "/app/teacher/books/manage.php";
            if (!file_exists($bookManagePath)) {
                return ['status' => 'error', 'message' => 'DIAGNOSTIC: file does not exist on server at ' . $bookManagePath];
            }
            include_once $bookManagePath;
            if (!function_exists('teacherListBookPurchaseRequests')) {
                return ['status' => 'error', 'message' => 'DIAGNOSTIC: file exists (size ' . filesize($bookManagePath) . ' bytes) but function teacherListBookPurchaseRequests is not defined after include'];
            }
            $teacherData = teacherAuthMiddleware();
            return teacherListBookPurchaseRequests($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/books/purchase-requests/review",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            $bookManagePath = __DIR__ . "/app/teacher/books/manage.php";
            if (!file_exists($bookManagePath)) {
                return ['status' => 'error', 'message' => 'DIAGNOSTIC: file does not exist on server at ' . $bookManagePath];
            }
            include_once $bookManagePath;
            if (!function_exists('teacherReviewBookRequest')) {
                return ['status' => 'error', 'message' => 'DIAGNOSTIC: file exists (size ' . filesize($bookManagePath) . ' bytes) but function teacherReviewBookRequest is not defined after include - check for a PHP parse error in that file (see server error log)'];
            }
            $teacherData = teacherAuthMiddleware();
            return teacherReviewBookRequest($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/exams",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            $tId = (int)($teacherData['id'] ?? $teacherData['teacher_id'] ?? $teacherData->id ?? 0);
            if ($tId > 0 && !isset($_GET['teacher_id'])) {
                $_GET['teacher_id'] = $tId;
            }
            return adminListExams($con);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/exams",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            return adminCreateExam($con, $teacherData);
        },
    ],
    [
        "method" => "PUT",
        "path" => "/brain-ixa/teacher/exams",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            return adminUpdateExam($con, $teacherData);
        },
    ],
    [
        "method" => "DELETE",
        "path" => "/brain-ixa/teacher/exams",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            return adminDeleteExam($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/questions",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            $tId = (int)($teacherData['id'] ?? $teacherData['teacher_id'] ?? $teacherData->id ?? 0);
            if ($tId > 0 && !isset($_GET['teacher_id'])) {
                $_GET['teacher_id'] = $tId;
            }
            return adminListQuestions($con);
        },
    ],
    // One question with everything on it - options, model answer, both translations. The teacher
    // exam screens never needed this because their listings carry full details already; the
    // question bank does, because its listing is deliberately lean and loads none of that.
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/questions/show",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            teacherAuthMiddleware();
            return adminGetQuestion($con);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/questions",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            return adminCreateQuestion($con, $teacherData);
        },
    ],
    [
        "method" => "PUT",
        "path" => "/brain-ixa/teacher/questions",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            return adminUpdateQuestion($con, $teacherData);
        },
    ],
    [
        "method" => "DELETE",
        "path" => "/brain-ixa/teacher/questions",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            return adminDeleteQuestion($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/questions/reorder",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            return adminReorderQuestions($con, $teacherData);
        },
    ],

    // Question bank. `$teacherData` is passed into every one of these: it is what limits a
    // teacher to the folders they created, on reads and on writes alike.
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/question-bank/folders",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/content/question_bank/manage.php";
            $teacherData = teacherAuthMiddleware();
            return questionBankListFolders($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/question-bank/folders",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/content/question_bank/manage.php";
            $teacherData = teacherAuthMiddleware();
            return questionBankCreateFolder($con, $teacherData);
        },
    ],
    [
        "method" => "PUT",
        "path" => "/brain-ixa/teacher/question-bank/folders",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/content/question_bank/manage.php";
            $teacherData = teacherAuthMiddleware();
            return questionBankUpdateFolder($con, $teacherData);
        },
    ],
    [
        "method" => "DELETE",
        "path" => "/brain-ixa/teacher/question-bank/folders",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/content/question_bank/manage.php";
            $teacherData = teacherAuthMiddleware();
            return questionBankDeleteFolder($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/question-bank/questions",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/content/question_bank/manage.php";
            $teacherData = teacherAuthMiddleware();
            return questionBankListQuestions($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/question-bank/move",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/content/question_bank/manage.php";
            $teacherData = teacherAuthMiddleware();
            return questionBankMoveQuestion($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/question-bank/copy-to-exam",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/content/question_bank/manage.php";
            $teacherData = teacherAuthMiddleware();
            return questionBankCopyToExam($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/certificates",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            $tId = (int)($teacherData['id'] ?? $teacherData['teacher_id'] ?? $teacherData->id ?? 0);
            if ($tId > 0 && !isset($_GET['teacher_id'])) {
                $_GET['teacher_id'] = $tId;
            }
            return adminListCertificates($con);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/certificates",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            return adminCreateCertificate($con, $teacherData);
        },
    ],
        [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/student-certificates",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            return adminAddStudentCertificate($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/student-certificates",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/content/certificates/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherListStudentCertificates($con, $teacherData);
        },
    ],
    [
        "method" => "DELETE",
        "path" => "/brain-ixa/teacher/student-certificates",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/content/certificates/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherRevokeStudentCertificate($con, $teacherData);
        },
    ],
        [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/course-student",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            return get_course_students($con, $teacherData);
        },
    ],
    [
        "method" => "PUT",
        "path" => "/brain-ixa/teacher/certificates",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            return adminUpdateCertificate($con, $teacherData);
        },
    ],
    [
        "method" => "DELETE",
        "path" => "/brain-ixa/teacher/certificates",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/content/manage.php";
            $teacherData = teacherAuthMiddleware();
            return adminDeleteCertificate($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/subscribed-students",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/subscriptions/students.php";
            $teacherData = teacherAuthMiddleware();
            return teacherGetSubscribedStudents($con, $teacherData);
        },
    ],

    // Teacher Homework Routes --------------------------------
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/homework",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/homework/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherListHomework($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/homework",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/homework/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherCreateHomework($con, $teacherData);
        },
    ],
    [
        "method" => "PUT",
        "path" => "/brain-ixa/teacher/homework",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/homework/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherUpdateHomework($con, $teacherData);
        },
    ],
    [
        "method" => "DELETE",
        "path" => "/brain-ixa/teacher/homework",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/homework/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherDeleteHomework($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/homework/submissions",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/homework/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherListHomeworkSubmissions($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/homework/feedback",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/homework/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherGradeSubmission($con, $teacherData);
        },
    ],

    // Student Homework Routes --------------------------------
    [
        "method" => "GET",
        "path" => "/brain-ixa/student/homework",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/student/homework/manage.php";
            $studentData = studentAuthMiddlewareOptional();
            return studentListHomework($con, $studentData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/student/homework/submit",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/student/homework/manage.php";
            $studentData = studentAuthMiddleware();
            return studentSubmitHomework($con, $studentData);
        },
    ],

    // Teacher Student Reports Routes --------------------------------
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/reports",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/reports/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherListStudentReports($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/reports/show",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/reports/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherGetStudentReport($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/reports",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/reports/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherCreateStudentReport($con, $teacherData);
        },
    ],
    [
        "method" => "PUT",
        "path" => "/brain-ixa/teacher/reports",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/reports/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherUpdateStudentReport($con, $teacherData);
        },
    ],
    [
        "method" => "DELETE",
        "path" => "/brain-ixa/teacher/reports",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/reports/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherDeleteStudentReport($con, $teacherData);
        },
    ],

    // Teacher Consultation Slots Routes --------------------------------
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/consultations",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/consultations/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherListConsultationSlots($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/consultations/bookings",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/consultations/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherListBookedConsultations($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/consultations/respond",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/consultations/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherRespondToConsultationBooking($con, $teacherData);
        },
    ],
    [
        "method" => "PUT",
        "path" => "/brain-ixa/teacher/consultations/respond",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/consultations/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherRespondToConsultationBooking($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/consultations",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/consultations/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherCreateConsultationSlot($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/consultations/recurring",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/consultations/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherCreateRecurringConsultationSlots($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/consultations/start",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/consultations/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherStartConsultation($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/consultations/end",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/consultations/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherEndConsultation($con, $teacherData);
        },
    ],
    [
        "method" => "DELETE",
        "path" => "/brain-ixa/teacher/consultations",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/consultations/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherDeleteConsultationSlot($con, $teacherData);
        },
    ],

    // Student Consultation Slots Routes --------------------------------
    [
        "method" => "GET",
        "path" => "/brain-ixa/student/consultations",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/teacher/consultations/manage.php";
            $studentData = studentAuthMiddlewareOptional();
            return studentListAvailableConsultationTeachers($con, $studentData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/student/consultations/slots",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/teacher/consultations/manage.php";
            $studentData = studentAuthMiddlewareOptional();
            return studentListAvailableConsultationSlots($con, $studentData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/student/consultations/my-bookings",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/teacher/consultations/manage.php";
            $studentData = studentAuthMiddlewareOptional();
            return studentListMyBookedConsultations($con, $studentData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/student/consultations/book",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/teacher/consultations/manage.php";
            $studentData = studentAuthMiddleware();
            return studentBookConsultationSlot($con, $studentData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/student/consultations/cancel",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/teacher/consultations/manage.php";
            $studentData = studentAuthMiddleware();
            return studentCancelConsultationBooking($con, $studentData);
        },
    ],
    [
        "method" => "DELETE",
        "path" => "/brain-ixa/student/consultations/cancel",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/teacher/consultations/manage.php";
            $studentData = studentAuthMiddleware();
            return studentCancelConsultationBooking($con, $studentData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/consultations/cancel",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/consultations/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherCancelConsultationBooking($con, $teacherData);
        },
    ],
    [
        "method" => "DELETE",
        "path" => "/brain-ixa/teacher/consultations/cancel",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/consultations/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherCancelConsultationBooking($con, $teacherData);
        },
    ],

    // Teacher Class Sessions Routes --------------------------------
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/sessions",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/sessions/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherListSessions($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/sessions",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/sessions/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherCreateSession($con, $teacherData);
        },
    ],
    [
        "method" => "PUT",
        "path" => "/brain-ixa/teacher/sessions",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/sessions/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherUpdateSession($con, $teacherData);
        },
    ],
    [
        "method" => "DELETE",
        "path" => "/brain-ixa/teacher/sessions",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/sessions/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherDeleteSession($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/sessions/start",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/sessions/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherStartSession($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/sessions/end",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/sessions/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherEndSession($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/sessions/reschedule-request",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/sessions/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherRequestReschedule($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/sessions/reschedule-requests",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/sessions/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherListRescheduleRequests($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/sessions/reschedule-requests/incoming",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/sessions/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherListIncomingRescheduleRequests($con, $teacherData);
        },
    ],
    [
        "method" => "PUT",
        "path" => "/brain-ixa/teacher/sessions/reschedule-requests/review",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/sessions/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherReviewRescheduleRequest($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/sessions/attendance/roster",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/sessions/attendance.php";
            $teacherData = teacherAuthMiddleware();
            return teacherGetSessionAttendanceRoster($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/sessions/attendance/mark",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/sessions/attendance.php";
            $teacherData = teacherAuthMiddleware();
            return teacherMarkSessionAttendance($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/sessions/attendance/stats",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/sessions/attendance.php";
            $teacherData = teacherAuthMiddleware();
            return teacherGetSessionAttendanceStats($con, $teacherData);
        },
    ],

    // Teacher Attendance Exceptions & Wallet Routes (Section 10) --------------------------------
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/attendance/exceptions",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/attendance/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherRequestAttendanceException($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/attendance/exceptions",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/attendance/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherListMyAttendanceExceptionRequests($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/wallet",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/attendance/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherGetWallet($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/wallet/transactions",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/attendance/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherListWalletTransactions($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/wallet/appeals",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/attendance/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherCreateDeductionAppeal($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/wallet/appeals",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/attendance/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherListMyAppeals($con, $teacherData);
        },
    ],

    // Teacher Session Files Routes --------------------------------
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/sessions/files",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/sessions/files.php";
            $teacherData = teacherAuthMiddleware();
            return teacherListSessionFiles($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/sessions/files",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/sessions/files.php";
            $teacherData = teacherAuthMiddleware();
            return teacherAddSessionFile($con, $teacherData);
        },
    ],
    [
        "method" => "PUT",
        "path" => "/brain-ixa/teacher/sessions/files",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/sessions/files.php";
            $teacherData = teacherAuthMiddleware();
            return teacherUpdateSessionFile($con, $teacherData);
        },
    ],
    [
        "method" => "DELETE",
        "path" => "/brain-ixa/teacher/sessions/files",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/sessions/files.php";
            $teacherData = teacherAuthMiddleware();
            return teacherDeleteSessionFile($con, $teacherData);
        },
    ],

    // Student Sessions Routes --------------------------------
    [
        "method" => "GET",
        "path" => "/brain-ixa/student/sessions/today",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/student/sessions/manage.php";
            $studentData = studentAuthMiddlewareOptional();
            return studentTodaySessions($con, $studentData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/student/sessions/reschedule-request",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/teacher/sessions/manage.php";
            $studentData = studentAuthMiddleware();
            return studentRequestReschedule($con, $studentData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/student/sessions/reschedule-requests",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/teacher/sessions/manage.php";
            $studentData = studentAuthMiddlewareOptional();
            return studentListMyRescheduleRequests($con, $studentData);
        },
    ],

    // Student Attendance Routes (Section 10) --------------------------------
    [
        "method" => "POST",
        "path" => "/brain-ixa/student/attendance/check-in",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/student/attendance/manage.php";
            $studentData = studentAuthMiddleware();
            return studentCheckInSession($con, $studentData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/student/attendance/exceptions",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/student/attendance/manage.php";
            $studentData = studentAuthMiddleware();
            return studentRequestAttendanceException($con, $studentData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/student/attendance/exceptions",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/student/attendance/manage.php";
            $studentData = studentAuthMiddleware();
            return studentListMyAttendanceExceptionRequests($con, $studentData);
        },
    ],

    // Student Session Files & Submissions Routes --------------------------------
    [
        "method" => "GET",
        "path" => "/brain-ixa/student/sessions/show",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/student/sessions/files.php";
            $studentData = studentAuthMiddlewareOptional();
            return studentGetSessionDetails($con, $studentData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/student/sessions/files",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/student/sessions/files.php";
            $studentData = studentAuthMiddlewareOptional();
            return studentGetSessionFiles($con, $studentData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/student/sessions/files/submit",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/student/sessions/files.php";
            $studentData = studentAuthMiddleware();
            return studentSubmitSessionFile($con, $studentData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/student/sessions/submissions",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/student/sessions/files.php";
            $studentData = studentAuthMiddlewareOptional();
            return studentGetMySubmissions($con, $studentData);
        },
    ],

    // Teacher Session Submissions & Grading Routes --------------------------------
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/sessions/files/submissions",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/sessions/files.php";
            $teacherData = teacherAuthMiddleware();
            return teacherListSubmissions($con, $teacherData);
        },
    ],
    [
        "method" => "PUT",
        "path" => "/brain-ixa/teacher/sessions/files/grade",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/sessions/files.php";
            $teacherData = teacherAuthMiddleware();
            return teacherGradeSubmission($con, $teacherData);
        },
    ],

    // Student Exams Routes --------------------------------
    [
        "method" => "GET",
        "path" => "/brain-ixa/student/exams",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/student/exams/manage.php";
            $studentData = studentAuthMiddlewareOptional();
            return studentListAvailableExams($con, $studentData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/student/exams/start",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/student/exams/manage.php";
            $studentData = studentAuthMiddleware();
            return studentStartExamAttempt($con, $studentData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/student/exams/submit",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/student/exams/manage.php";
            $studentData = studentAuthMiddleware();
            return studentSubmitExamAttempt($con, $studentData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/student/exams/results",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/student/exams/manage.php";
            $studentData = studentAuthMiddlewareOptional();
            return studentListExamResults($con, $studentData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/student/exams/results/show",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/student/exams/manage.php";
            $studentData = studentAuthMiddlewareOptional();
            return studentGetExamResultDetail($con, $studentData);
        },
    ],

    // Teacher Exam Attempts (Grading) Routes --------------------------------
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/exams/attempts",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/exams/attempts.php";
            $teacherData = teacherAuthMiddleware();
            return teacherListExamAttempts($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/exams/attempts/show",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/exams/attempts.php";
            $teacherData = teacherAuthMiddleware();
            return teacherGetExamAttemptDetail($con, $teacherData);
        },
    ],
    [
        "method" => "PUT",
        "path" => "/brain-ixa/teacher/exams/attempts",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/exams/attempts.php";
            $teacherData = teacherAuthMiddleware();
            return teacherGradeExamAttempt($con, $teacherData);
        }, 
    ],

    // Teacher Courses Routes --------------------------------
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/courses",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/courses/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherListMyCourses($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/courses/reorder",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/courses/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherReorderMyCourses($con, $teacherData);
        },
    ],
    [
        "method" => "POST",
        "path" => "/brain-ixa/teacher/courses",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/courses/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherCreateCourse($con, $teacherData);
        },
    ],
    [
        "method" => "PUT",
        "path" => "/brain-ixa/teacher/courses",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/courses/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherUpdateMyCourse($con, $teacherData);
        },
    ],
    [
        "method" => "DELETE",
        "path" => "/brain-ixa/teacher/courses",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/courses/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherDeleteMyCourse($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/subjects",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/lookups/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherListMySubjects($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/academic-years",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/lookups/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherListMyAcademicYears($con, $teacherData);
        },
    ],
    [
        "method" => "GET",
        "path" => "/brain-ixa/teacher/academic_years",
        "handler" => function ($con) {
            include_once "./middlewares/teacherauthmiddleware.php";
            include_once "./app/teacher/lookups/manage.php";
            $teacherData = teacherAuthMiddleware();
            return teacherListMyAcademicYears($con, $teacherData);
        },
    ],

    // Admin Routes ----------------------------------------
    
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/auth/login",
            "handler" => function ($con) {
                include_once "./app/admin/auth/login.php";
                return adminLogin($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/auth/refresh",
            "handler" => function () {
                return handleTokenRefresh('admin');
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/auth/profile",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/auth/profile.php";
                $adminData = adminAuthMiddleware();
                return adminProfile($con, $adminData);
            },
        ],
        [
            "method" => ["PUT", "POST", "PATCH"],
            "path" => "/brain-ixa/admin/auth/profile",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/auth/profile.php";
                $adminData = adminAuthMiddleware();
                return adminUpdateProfile($con, $adminData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/fcm-token",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/auth/profile.php";
                $adminData = adminAuthMiddleware();
                return adminUpdateFcmToken($con, $adminData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/student/onboard/start",
            "handler" => function ($con) {
                include_once "./app/user/student/onboard/manage.php";
                return studentOnboardStartWithCode($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/student/onboard/complete",
            "handler" => function ($con) {
                include_once "./app/user/student/onboard/manage.php";
                return studentOnboardComplete($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/parent/onboard/start",
            "handler" => function ($con) {
                include_once "./app/user/parent/onboard/manage.php";
                return parentOnboardStartWithCode($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/parent/onboard/complete",
            "handler" => function ($con) {
                include_once "./app/user/parent/onboard/manage.php";
                return parentOnboardComplete($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/notifications/send",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/notifications/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_notifications');
                return adminSendNotification($con, $adminData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/notifications",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/notifications/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_notifications');
                return adminListNotifications($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/notifications/inbox",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/notifications/inbox.php";
                $adminData = adminAuthMiddleware();
                return adminListMyNotifications($con, $adminData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/notifications/inbox/unread-count",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/notifications/inbox.php";
                $adminData = adminAuthMiddleware();
                return adminGetNotificationUnreadCount($con, $adminData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/notifications/inbox/read",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/notifications/inbox.php";
                $adminData = adminAuthMiddleware();
                return adminMarkNotificationRead($con, $adminData);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/notifications/inbox",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/notifications/inbox.php";
                $adminData = adminAuthMiddleware();
                return adminDeleteMyNotification($con, $adminData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/dashboard/statistics",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/dashboard/statistics.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'view_dashboard');
                return adminDashboardStatistics($con);
            },
        ],

        // 1. Admin Users Management (manage_admins)
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/admins",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/admins/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_admins');
                return adminListAdmins($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/admins/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/admins/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_admins');
                return adminGetAdmin($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/admins",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/admins/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_admins');
                return adminCreateAdminUser($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/admins",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/admins/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_admins');
                return adminUpdateAdminUser($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/admins",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/admins/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_admins');
                return adminDeleteAdminUser($con, $adminData);
            },
        ],

        // Admin: chat access gate (chat itself is Firebase, not this API) --
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/chat/access",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/chat/access.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_chat');
                return adminCheckChatAccess($con, $adminData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/chat/monitor/access",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/chat/access.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'monitor_chat');
                return adminCheckChatMonitorAccess($con, $adminData);
            },
        ],

        // Admin Student Reports Routes --------------------------------
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/reports",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/reports/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_reports');
                return adminListStudentReports($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/reports/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/reports/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_reports');
                return adminGetStudentReport($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/reports",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/reports/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_reports');
                return adminCreateStudentReport($con, $adminData);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/reports",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/reports/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_reports');
                return adminUpdateStudentReport($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/reports",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/reports/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_reports');
                return adminDeleteStudentReport($con);
            },
        ],

        // 2. Roles & Permissions Management (manage_roles)
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/roles",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/roles/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_roles');
                return adminListRoles($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/roles/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/roles/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_roles');
                return adminGetRole($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/roles",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/roles/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_roles');
                return adminCreateRole($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/roles",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/roles/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_roles');
                return adminUpdateRole($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/roles",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/roles/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_roles');
                return adminDeleteRole($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/permissions",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/roles/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_roles');
                return adminListPermissions($con);
            },
        ],

        // 3. Students Management (manage_students)
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/students",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/users/students.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_students');
                return adminListStudents($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/students/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/users/students.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_students');
                return adminGetStudent($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/students",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/users/students.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_students');
                return adminCreateStudent($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/students",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/users/students.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_students');
                return adminUpdateStudent($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/students",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/users/students.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_students');
                return adminDeleteStudent($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/students/export",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/export/export.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_students');
                adminExportStudents($con);
            },
        ],

        // Student Devices — how many devices an account may sign in from (manage_students)
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/students/devices",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/devices/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_students');
                return adminListStudentDevices($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/students/devices/reset",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/devices/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_students');
                return adminResetStudentDevices($con, $adminData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/students/logout-all",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/devices/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_students');
                return adminLogoutStudentEverywhere($con, $adminData);
            },
        ],
        [
            "method" => ["DELETE", "POST"],
            "path" => "/brain-ixa/admin/students/devices/revoke",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/devices/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_students');
                return adminRevokeStudentDevice($con, $adminData);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/students/device-limit",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/devices/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_students');
                return adminSetStudentDeviceLimit($con);
            },
        ],

        // 4. Teachers Management (manage_teachers)
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/teachers",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/users/teachers.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_teachers');
                return adminListTeachers($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/teachers/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/users/teachers.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_teachers');
                return adminGetTeacher($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/teachers",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/users/teachers.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_teachers');
                return adminCreateTeacher($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/teachers",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/users/teachers.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_teachers');
                return adminUpdateTeacher($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/teachers",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/users/teachers.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_teachers');
                return adminDeleteTeacher($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/teachers/export",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/export/export.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_teachers');
                adminExportTeachers($con);
            },
        ],

        // 5. Parents & Linkage Management (manage_parents)
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/parents",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/users/parents.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_parents');
                return adminListParents($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/parents/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/users/parents.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_parents');
                return adminGetParent($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/parents",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/users/parents.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_parents');
                return adminCreateParent($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/parents",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/users/parents.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_parents');
                return adminUpdateParent($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/parents",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/users/parents.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_parents');
                return adminDeleteParent($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/parents/export",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/export/export.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_parents');
                adminExportParents($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/parents/link-student",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/users/parents.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_parents');
                return adminLinkStudentToParent($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/parents/unlink-student",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/users/parents.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_parents');
                return adminUnlinkStudentFromParent($con);
            },
        ],

        // Banners CRUD & View Analytics (Protected by RBAC)
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/banners",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/banners/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_banners');
                return adminListBanners($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/banners/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/banners/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_banners');
                return adminGetBanner($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/banners",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/banners/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_banners');
                return adminCreateBanner($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/banners",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/banners/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_banners');
                return adminUpdateBanner($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/banners",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/banners/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_banners');
                return adminDeleteBanner($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/banners/views",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/banners/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_banners');
                return adminGetBannerViews($con);
            },
        ],

        // Hero slides: the landing page hero's own backgrounds. Separate from banners on
        // purpose - banners also feed the student app's home screen.
        // The manual sales sheet: what was sold off the platform, written down by the owner.
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/manual-sales",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/manual_sales/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_manual_sales');
                return adminListManualSales($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/manual-sales/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/manual_sales/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_manual_sales');
                return adminGetManualSale($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/manual-sales",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/manual_sales/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_manual_sales');
                return adminCreateManualSale($con, $adminData);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/manual-sales",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/manual_sales/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_manual_sales');
                return adminUpdateManualSale($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/manual-sales",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/manual_sales/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_manual_sales');
                return adminDeleteManualSale($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/hero-slides",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/hero_slides/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_hero_slides');
                return adminListHeroSlides($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/hero-slides/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/hero_slides/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_hero_slides');
                return adminGetHeroSlide($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/hero-slides",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/hero_slides/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_hero_slides');
                return adminCreateHeroSlide($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/hero-slides",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/hero_slides/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_hero_slides');
                return adminUpdateHeroSlide($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/hero-slides",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/hero_slides/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_hero_slides');
                return adminDeleteHeroSlide($con);
            },
        ],

        // 6. Lookups CRUD (Protected by RBAC)
        // Languages CRUD
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/languages",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/languages/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_languages');
                return adminListLanguages($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/languages/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/languages/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_languages');
                return adminGetLanguage($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/languages",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/languages/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_languages');
                return adminCreateLanguage($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/languages",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/languages/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_languages');
                return adminUpdateLanguage($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/languages",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/languages/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_languages');
                return adminDeleteLanguage($con);
            },
        ],

        // Cities CRUD
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/cities",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/cities/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_cities');
                return adminListCities($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/cities/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/cities/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_cities');
                return adminGetCity($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/cities",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/cities/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_cities');
                return adminCreateCity($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/cities",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/cities/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_cities');
                return adminUpdateCity($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/cities",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/cities/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_cities');
                return adminDeleteCity($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/cities/export",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/export/export.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_cities');
                adminExportCities($con);
            },
        ],

        // School Types CRUD
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/school-types",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/school_types/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_school_types');
                return adminListSchoolTypes($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/school-types/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/school_types/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_school_types');
                return adminGetSchoolType($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/school-types",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/school_types/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_school_types');
                return adminCreateSchoolType($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/school-types",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/school_types/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_school_types');
                return adminUpdateSchoolType($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/school-types",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/school_types/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_school_types');
                return adminDeleteSchoolType($con);
            },
        ],

        // Schools CRUD
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/schools",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/schools/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_schools');
                return adminListSchools($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/schools/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/schools/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_schools');
                return adminGetSchool($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/schools",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/schools/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_schools');
                return adminCreateSchool($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/schools",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/schools/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_schools');
                return adminUpdateSchool($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/schools",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/schools/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_schools');
                return adminDeleteSchool($con);
            },
        ],

        // Subjects CRUD
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/subjects",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/subjects/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_subjects');
                return adminListSubjects($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/subjects/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/subjects/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_subjects');
                return adminGetSubject($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/subjects",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/subjects/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_subjects');
                return adminCreateSubject($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/subjects",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/subjects/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_subjects');
                return adminUpdateSubject($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/subjects",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/subjects/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_subjects');
                return adminDeleteSubject($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/subjects/export",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/export/export.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_subjects');
                adminExportSubjects($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/subjects/link-academic-year",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/subjects/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_subjects');
                return adminLinkSubjectToAcademicYear($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/subjects/unlink-academic-year",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/subjects/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_subjects');
                return adminUnlinkSubjectFromAcademicYear($con);
            },
        ],

        // Courses CRUD (Protected by RBAC)
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/courses",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_courses');
                return adminListCourses($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/courses/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_courses');
                return adminGetCourse($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/courses/reorder",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_courses');
                return adminReorderCourses($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/courses",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_courses');
                return adminCreateCourse($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/courses",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_courses');
                return adminUpdateCourse($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/courses",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_courses');
                return adminDeleteCourse($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/courses/link-teacher",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_courses');
                return adminLinkTeacherToCourse($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/courses/unlink-teacher",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_courses');
                return adminUnlinkTeacherFromCourse($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/courses/seed",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_courses');
                return adminSeedCourses($con);
            },
        ],

        // Units CRUD
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/units",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_courses');
                return adminListUnits($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/units/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_courses');
                return adminGetUnit($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/units",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_courses');
                return adminCreateUnit($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/units",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_courses');
                return adminUpdateUnit($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/units",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_courses');
                return adminDeleteUnit($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/units/reorder",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_courses');
                return adminReorderUnits($con);
            },
        ],

        // Videos CRUD
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/videos",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_courses');
                return adminListVideos($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/videos/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_courses');
                return adminGetVideo($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/videos",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_courses');
                return adminCreateVideo($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/videos",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_courses');
                return adminUpdateVideo($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/videos",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_courses');
                return adminDeleteVideo($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/videos/reorder",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_courses');
                return adminReorderVideos($con);
            },
        ],

        // Books CRUD
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/books",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/books/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_books');
                return adminListBooks($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/books/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/books/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_books');
                return adminGetBook($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/books",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/books/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_books');
                return adminCreateBook($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/books",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/books/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_books');
                return adminUpdateBook($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/books",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/books/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_books');
                return adminDeleteBook($con);
            },
        ],
        [
            // Admin's own "Open" action for a view-only (allow_download = 0) book/exam - the same
            // authenticated stream a student gets, never the bare file.
            "method" => "GET",
            "path" => "/brain-ixa/admin/books/stream",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/books/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_books');
                return adminStreamBookFile($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/books/reorder",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/books/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_books');
                return adminReorderBooks($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/books/grant-access",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/books/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_books');
                return adminGrantBookAccessToStudent($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/books/purchase-requests",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/books/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_books');
                return adminListBookPurchaseRequests($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/books/purchase-requests/review",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/books/manage.php";
                $adminData = adminAuthMiddleware();
                return adminReviewBookRequest($con, $adminData);
            },
        ],

        // Exams CRUD
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/exams",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_exams');
                return adminListExams($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/exams/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_exams');
                return adminGetExam($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/exams",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_exams');
                return adminCreateExam($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/exams",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_exams');
                return adminUpdateExam($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/exams",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_exams');
                return adminDeleteExam($con);
            },
        ],

        // Questions CRUD
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/questions",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_exams');
                return adminListQuestions($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/questions/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_exams');
                return adminGetQuestion($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/questions",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_exams');
                return adminCreateQuestion($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/questions",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_exams');
                return adminUpdateQuestion($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/questions",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_exams');
                return adminDeleteQuestion($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/questions/reorder",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_exams');
                return adminReorderQuestions($con);
            },
        ],

        // Question bank - a global pool of questions, filed in folders, that exams are built from.
        // Gated on `manage_exams` like the question routes above: building the bank and building
        // an exam are the same job.
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/question-bank/folders",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/content/question_bank/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_exams');
                return questionBankListFolders($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/question-bank/folders",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/content/question_bank/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_exams');
                return questionBankCreateFolder($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/question-bank/folders",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/content/question_bank/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_exams');
                return questionBankUpdateFolder($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/question-bank/folders",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/content/question_bank/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_exams');
                return questionBankDeleteFolder($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/question-bank/questions",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/content/question_bank/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_exams');
                return questionBankListQuestions($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/question-bank/move",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/content/question_bank/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_exams');
                return questionBankMoveQuestion($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/question-bank/copy-to-exam",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/content/question_bank/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_exams');
                return questionBankCopyToExam($con);
            },
        ],

        // Certificates CRUD
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/certificates",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_certificates');
                return adminListCertificates($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/certificates/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_certificates');
                return adminGetCertificate($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/certificates",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_certificates');
                return adminCreateCertificate($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/certificates",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_certificates');
                return adminUpdateCertificate($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/certificates",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/content.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_certificates');
                return adminDeleteCertificate($con);
            },
        ],

        // Admin: certificates issued to students (not tied to any course) ----
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/student-certificates",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/content/certificates/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_certificates');
                return adminListStudentCertificates($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/student-certificates",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/content/certificates/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_certificates');
                return adminAddStudentCertificate($con, $adminData);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/student-certificates",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/content/certificates/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_certificates');
                return adminRevokeStudentCertificate($con);
            },
        ],

        // Offline payments (the student transfers the money; a reviewer confirms it) ----------
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/payment-accounts",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/payments/offline.php";
                // Optional: a logged-out visitor still gets the accounts, priced for wherever
                // their address puts them. A logged-in one gets their own saved country instead.
                $studentData = studentAuthMiddlewareOptional();
                return studentListPaymentAccounts($con, $studentData);
            },
        ],
        [
            "method" => ["POST", "GET"],
            "path" => "/brain-ixa/student/offline-payments/quote",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/payments/offline.php";
                $studentData = studentAuthMiddleware();
                return studentQuoteOfflinePayment($con, $studentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/student/offline-payments",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/payments/offline.php";
                $studentData = studentAuthMiddleware();
                return studentCreateOfflinePayment($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/offline-payments",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/payments/offline.php";
                $studentData = studentAuthMiddleware();
                return studentListMyOfflinePayments($con, $studentData);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/student/offline-payments",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/payments/offline.php";
                $studentData = studentAuthMiddleware();
                return studentCancelOfflinePayment($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/offline-payments",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/payments/offline.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_payments');
                return adminListOfflinePayments($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/offline-payments/review",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/payments/offline.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_payments');
                return adminReviewOfflinePayment($con, $adminData);
            },
        ],
        // Gateway (EasyKash) transactions. There was no admin view of these at all, which made a
        // refund impossible to act on: the EasyKash account belongs to the client, so the
        // platform cannot rely on being told when money goes back. `recheck` asks the gateway
        // itself; `revoke` is the manual last resort.
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/gateway-payments",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/payments/gateway.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_payments');
                return adminListGatewayPayments($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/gateway-payments/recheck",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/payments/gateway.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_payments');
                return adminRecheckGatewayPayment($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/gateway-payments/revoke",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/payments/gateway.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_payments');
                return adminRevokeGatewayPayment($con, $adminData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/payment-accounts",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/payments/offline.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_payments');
                return adminListPaymentAccounts($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/payment-accounts",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/payments/offline.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_payments');
                return adminCreatePaymentAccount($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/payment-accounts",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/payments/offline.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_payments');
                return adminUpdatePaymentAccount($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/payment-accounts",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/payments/offline.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_payments');
                return adminDeletePaymentAccount($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/teacher/offline-payments",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/payments/offline.php";
                $teacherData = teacherAuthMiddleware();
                return teacherListOfflinePayments($con, $teacherData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/teacher/offline-payments/review",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/payments/offline.php";
                $teacherData = teacherAuthMiddleware();
                return teacherReviewOfflinePayment($con, $teacherData);
            },
        ],

        // Pricing by country -------------------------------------------------------------------
        //
        // The three lookups are open. A country list is not a secret, and the price a visitor is
        // shown depends on which country they resolve to - if that answer changed when they
        // signed in, the price would change with it for no reason they could see.
        [
            "method" => "GET",
            "path" => "/brain-ixa/countries",
            "handler" => function ($con) {
                include_once "./app/common/pricing/lookups.php";
                return publicListCountries($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/currencies",
            "handler" => function ($con) {
                include_once "./app/common/pricing/lookups.php";
                return publicListCurrencies($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/pricing/context",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/common/pricing/lookups.php";
                $studentData = studentAuthMiddlewareOptional();
                return publicPricingContext($con, $studentData);
            },
        ],
        [
            "method" => ["POST", "PUT"],
            "path" => "/brain-ixa/student/pricing/country",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/common/pricing/lookups.php";
                $studentData = studentAuthMiddleware();
                return studentSetPricingCountry($con, $studentData);
            },
        ],

        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/countries",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/pricing/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_pricing');
                return adminListCountries($con);
            },
        ],
        [
            "method" => ["PUT", "POST"],
            "path" => "/brain-ixa/admin/countries",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/pricing/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_pricing');
                return adminUpdateCountry($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/currencies",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/pricing/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_pricing');
                return adminListCurrencies($con);
            },
        ],
        [
            "method" => ["PUT", "POST"],
            "path" => "/brain-ixa/admin/currencies",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/pricing/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_pricing');
                return adminUpdateCurrency($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/item-prices",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/pricing/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_pricing');
                return adminListItemPrices($con);
            },
        ],
        [
            "method" => ["POST", "PUT"],
            "path" => "/brain-ixa/admin/item-prices",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/pricing/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_pricing');
                return adminSaveItemPrices($con, $adminData);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/item-prices",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/pricing/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_pricing');
                return adminDeleteItemPrice($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/priced-items",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/pricing/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_pricing');
                return adminListPricedItems($con);
            },
        ],

        // A teacher prices their own work. No permission code: ownership is the permission, and
        // it is checked inside every one of these against the same rule the discount codes use.
        [
            "method" => "GET",
            "path" => "/brain-ixa/teacher/item-prices",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/pricing/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherListItemPrices($con, $teacherData);
            },
        ],
        [
            "method" => ["POST", "PUT"],
            "path" => "/brain-ixa/teacher/item-prices",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/pricing/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherSaveItemPrices($con, $teacherData);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/teacher/item-prices",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/pricing/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherDeleteItemPrice($con, $teacherData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/teacher/priced-items",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/pricing/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherListPricedItems($con, $teacherData);
            },
        ],

        // Discount codes (reduce a price; they never grant access) ----------
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/discount-codes",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/discounts/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_discounts');
                return adminListDiscountCodes($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/discount-codes/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/discounts/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_discounts');
                return adminGetDiscountCode($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/discount-codes",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/discounts/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_discounts');
                return adminCreateDiscountCode($con, $adminData);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/discount-codes",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/discounts/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_discounts');
                return adminUpdateDiscountCode($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/discount-codes",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/discounts/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_discounts');
                return adminDeleteDiscountCode($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/discount-codes/check",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/discounts/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_discounts');
                return adminCheckDiscountCode($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/discount-codes/redemptions",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/discounts/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_discounts');
                return adminListDiscountRedemptions($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/student/discount-codes/check",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/student/discounts/manage.php";
                $studentData = studentAuthMiddleware();
                return studentCheckDiscountCode($con, $studentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/student/discount-codes/apply",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/student/discounts/manage.php";
                $studentData = studentAuthMiddleware();
                return studentApplyDiscountCode($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/discount-codes/my-codes",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/student/discounts/manage.php";
                $studentData = studentAuthMiddleware();
                return studentListDiscountClaims($con, $studentData);
            },
        ],
        [
            "method" => ["DELETE", "POST"],
            "path" => "/brain-ixa/student/discount-codes/cancel",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/student/discounts/manage.php";
                $studentData = studentAuthMiddleware();
                return studentCancelDiscountClaim($con, $studentData);
            },
        ],

        // Discount Codes CRUD (Teacher - own courses only) --------------------------------
        [
            "method" => "GET",
            "path" => "/brain-ixa/teacher/discount-codes",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/discounts/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherListDiscountCodes($con, $teacherData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/teacher/discount-codes/show",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/discounts/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherGetDiscountCode($con, $teacherData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/teacher/discount-codes",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/discounts/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherCreateDiscountCode($con, $teacherData);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/teacher/discount-codes",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/discounts/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherUpdateDiscountCode($con, $teacherData);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/teacher/discount-codes",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/discounts/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherDeleteDiscountCode($con, $teacherData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/teacher/discount-codes/check",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/discounts/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherCheckDiscountCode($con, $teacherData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/teacher/discount-codes/redemptions",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/discounts/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherListDiscountRedemptions($con, $teacherData);
            },
        ],

        // Admin: Sales (overview, per-kind breakdown, trend) ----------------
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/sales/overview",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/sales/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'view_sales');
                return adminSalesOverview($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/sales/items",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/sales/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'view_sales');
                return adminSalesItems($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/sales/items/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/sales/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'view_sales');
                return adminSalesItemDetail($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/sales/trend",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/sales/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'view_sales');
                return adminSalesTrend($con);
            },
        ],

        // Subscriptions & Subscription Codes CRUD (Admin)
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/subscription-codes",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/subscriptions/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_subscriptions');
                return adminListSubscriptionCodes($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/subscription-codes/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/subscriptions/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_subscriptions');
                return adminGetSubscriptionCode($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/subscription-codes",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/subscriptions/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_subscriptions');
                return adminCreateSubscriptionCode($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/subscription-codes",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/subscriptions/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_subscriptions');
                return adminUpdateSubscriptionCode($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/subscription-codes",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/subscriptions/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_subscriptions');
                return adminDeleteSubscriptionCode($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/subscriptions",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/subscriptions/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_subscriptions');
                return adminListStudentSubscriptions($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/subscriptions",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/subscriptions/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_subscriptions');
                return adminCreateStudentSubscription($con, $adminData);
            },
        ],
        [
            // Pause, resume or cancel. Not a DELETE: cancelling keeps the row, with who did it
            // and why, because a student asking why their access stopped needs an answer.
            "method" => "PUT",
            "path" => "/brain-ixa/admin/subscriptions/status",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/subscriptions/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_subscriptions');
                return adminUpdateStudentSubscriptionStatus($con, $adminData);
            },
        ],
        [
            // The header search box. No permission of its own - each group inside is filtered by
            // the permission of the screen it links to, so the results are whatever this admin
            // could have found by opening those pages themselves.
            "method" => "GET",
            "path" => "/brain-ixa/admin/search",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/search/manage.php";
                $adminData = adminAuthMiddleware();
                return adminGlobalSearch($con, $adminData);
            },
        ],
        [
            // Super admin only, and deliberately not behind a grantable permission: editing a
            // live subscription moves content a student has already paid for, in a way the
            // payment records will not show.
            "method" => "PUT",
            "path" => "/brain-ixa/admin/subscriptions",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/subscriptions/manage.php";
                $adminData = adminAuthMiddleware();
                requireSuperAdmin($con, $adminData);
                return adminUpdateStudentSubscription($con, $adminData);
            },
        ],

        // Admin: Session Reschedule Requests
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/reschedule-requests",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/teacher/sessions/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_sessions');
                return adminListRescheduleRequests($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/reschedule-requests",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/teacher/sessions/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_sessions');
                return adminReviewRescheduleRequest($con);
            },
        ],

        // Admin: HR Policy Settings, Attendance Exceptions, Teacher Wallets & Appeals (Section 10)
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/hr-settings",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/hr_settings/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_hr');
                return adminGetHrPolicySettings($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/hr-settings",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/hr_settings/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_hr');
                return adminUpdateHrPolicySettings($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/teachers/pay-rate",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/hr_settings/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_teachers');
                return adminSetTeacherPayRate($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/teachers/pay-rate",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/hr_settings/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_teachers');
                return adminClearTeacherPayRate($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/attendance/exceptions",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/attendance/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_attendance');
                return adminListAttendanceExceptionRequests($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/attendance/exceptions",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/attendance/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_attendance');
                return adminReviewAttendanceExceptionRequest($con, $adminData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/teacher-wallets",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/attendance/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_wallets');
                return adminListTeacherWallets($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/teacher-wallets/ledger",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/attendance/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_wallets');
                return adminGetTeacherWalletLedger($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/teacher-wallets/adjust",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/attendance/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_wallets');
                return adminAdjustTeacherWallet($con, $adminData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/teacher-wallets/lift-suspension",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/attendance/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_wallets');
                return adminLiftTeacherAttendanceSuspension($con);
            },
        ],
        // Excel exports for the money-and-attendance screens. Each one honours the same filters
        // as the list it belongs to, so what downloads is what the admin is looking at.
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/teacher-wallets/export",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/export/hr_export.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_wallets');
                adminExportTeacherWallets($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/teacher-wallets/transactions/export",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/export/hr_export.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_wallets');
                adminExportWalletTransactions($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/deduction-appeals/export",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/export/hr_export.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_wallets');
                adminExportDeductionAppeals($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/attendance/exceptions/export",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/export/hr_export.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_attendance');
                adminExportAttendanceExceptions($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/reports/export",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/export/hr_export.php";
                // GET /admin/reports itself requires only an admin session, so gating the export
                // any harder would mean an admin who can read the reports cannot download them.
                adminAuthMiddleware();
                adminExportReports($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/deduction-appeals",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/attendance/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_wallets');
                return adminListDeductionAppeals($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/deduction-appeals",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/attendance/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_wallets');
                return adminReviewDeductionAppeal($con, $adminData);
            },
        ],

        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/consultations",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/consultations/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_consultations');
                return adminListConsultations($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/consultations",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/consultations/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_consultations');
                return adminUpdateConsultationSlot($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/consultations",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/consultations/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_consultations');
                return adminDeleteConsultationSlot($con);
            },
        ],
        [
            // The admin books a slot on a student's behalf, and both of them are notified.
            "method" => "POST",
            "path" => "/brain-ixa/admin/consultations/book",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/consultations/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_consultations');
                return adminBookConsultationForStudent($con, $adminData);
            },
        ],
        [
            // Approve or refuse a booking a student made, and start / end the consultation.
            // The student's screen is waiting on the last two.
            "method" => "POST",
            "path" => "/brain-ixa/admin/consultations/respond",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/consultations/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_consultations');
                return adminRespondToConsultationBooking($con, $adminData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/consultations/start",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/consultations/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_consultations');
                return adminStartConsultation($con, $adminData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/consultations/end",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/consultations/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_consultations');
                return adminEndConsultation($con, $adminData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/consultations/recurring",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/consultations/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_consultations');
                return adminCreateRecurringConsultationSlots($con, $adminData);
            },
        ],

        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/sessions",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/sessions/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_sessions');
                return adminListSessions($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/sessions",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/sessions/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_sessions');
                return adminCreateSession($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/sessions",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/sessions/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_sessions');
                return adminUpdateSession($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/sessions",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/sessions/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_sessions');
                return adminDeleteSession($con);
            },
        ],

        // Admin / Teacher / Student: dated availability slots -------------
        // Real-calendar appointments, a parallel layer to the weekly class_sessions pattern.
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/availability",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/availability/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_sessions');
                return adminListAvailabilitySlots($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/availability",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/availability/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_sessions');
                return adminCreateAvailabilitySlot($con, $adminData);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/availability",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/availability/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_sessions');
                return adminUpdateAvailabilitySlot($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/availability",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/availability/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_sessions');
                return adminDeleteAvailabilitySlot($con);
            },
        ],
        [
            // Start / end a package session. The meeting link stays hidden from the students
            // booked into it until it has been started, or its own hour has arrived.
            "method" => "POST",
            "path" => "/brain-ixa/admin/availability/start",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/availability/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_sessions');
                return adminStartAvailabilitySlot($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/availability/end",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/availability/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_sessions');
                return adminEndAvailabilitySlot($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/availability/generate",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/availability/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_sessions');
                return adminGenerateAvailabilitySlots($con, $adminData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/availability/book",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/availability/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_sessions');
                return adminBookStudentIntoSlot($con, $adminData);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/availability/book",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/availability/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_sessions');
                return adminCancelStudentBooking($con, $adminData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/availability/schedule-student",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/availability/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_sessions');
                return adminScheduleStudent($con, $adminData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/teacher/availability",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/availability/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherListAvailabilitySlots($con, $teacherData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/teacher/availability",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/availability/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherCreateAvailabilitySlot($con, $teacherData);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/teacher/availability",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/availability/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherUpdateAvailabilitySlot($con, $teacherData);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/teacher/availability",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/availability/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherDeleteAvailabilitySlot($con, $teacherData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/teacher/availability/generate",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/availability/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherGenerateAvailabilitySlots($con, $teacherData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/teacher/availability/start",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/availability/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherStartAvailabilitySlot($con, $teacherData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/teacher/availability/end",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/availability/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherEndAvailabilitySlot($con, $teacherData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/teacher/availability/book",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/availability/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherBookStudentIntoSlot($con, $teacherData);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/teacher/availability/book",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/availability/manage.php";
                $teacherData = teacherAuthMiddleware();
                return teacherCancelStudentBooking($con, $teacherData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/availability",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/student/availability/manage.php";
                $studentData = studentAuthMiddleware();
                return studentListAvailableSlots($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/availability/my-schedule",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/student/availability/manage.php";
                $studentData = studentAuthMiddleware();
                return studentMyScheduleSlots($con, $studentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/student/availability/book",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/student/availability/manage.php";
                $studentData = studentAuthMiddleware();
                return studentBookAvailabilitySlot($con, $studentData);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/student/availability/book",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/student/availability/manage.php";
                $studentData = studentAuthMiddleware();
                return studentCancelAvailabilityBooking($con, $studentData);
            },
        ],

        // Admin: Session Files --------------------------------
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/sessions/files",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/teacher/sessions/files.php";
                $adminData = adminAuthMiddleware();
                return adminListSessionFiles($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/sessions/files",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/teacher/sessions/files.php";
                $adminData = adminAuthMiddleware();
                return adminAddSessionFile($con, $adminData);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/sessions/files",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/teacher/sessions/files.php";
                $adminData = adminAuthMiddleware();
                return adminUpdateSessionFile($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/sessions/files",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/teacher/sessions/files.php";
                $adminData = adminAuthMiddleware();
                return adminDeleteSessionFile($con);
            },
        ],

        // Admin: Session File Submissions & Grading --------------------------------
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/sessions/files/submissions",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/teacher/sessions/files.php";
                $adminData = adminAuthMiddleware();
                return adminListSubmissions($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/sessions/files/grade",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/teacher/sessions/files.php";
                $adminData = adminAuthMiddleware();
                return adminGradeSubmission($con);
            },
        ],

        // Admin: Exam Attempts (Results & Grading)
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/exams/attempts",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/teacher/exams/attempts.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_exams');
                return adminListExamAttempts($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/exams/attempts/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/teacher/exams/attempts.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_exams');
                return adminGetExamAttemptDetail($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/exams/attempts",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/teacher/exams/attempts.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_exams');
                return adminGradeExamAttempt($con, $adminData);
            },
        ],

        // Academic Years CRUD
        [
            "method" => "GET",
            "path" => "/brain-ixa/landing",
            "handler" => function ($con) {
                header("Content-Type: text/html; charset=UTF-8");
                readfile(__DIR__ . "/website/index.html");
                exit();
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/home",
            "handler" => function ($con) {
                include_once "./app/admin/site_settings/manage.php";
                return getPublicLandingConfig($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/site-settings",
            "handler" => function ($con) {
                include_once "./app/admin/site_settings/manage.php";
                return getPublicLandingConfig($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/about-us",
            "handler" => function ($con) {
                include_once "./app/admin/site_settings/manage.php";
                return getPublicAboutUsConfig($con);
            },
        ],
        // The operational settings a client needs before anyone signs in: the support number, the
        // social links, and whether the platform is open. Separate from /site-settings, which is
        // the WEBSITE's landing payload - banners, courses and books - and is far too heavy to be
        // fetched for a phone number.
        [
            "method" => "GET",
            "path" => "/brain-ixa/app-config",
            "handler" => function ($con) {
                include_once "./helpers/app_settings.php";
                return getPublicAppConfig($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/site-settings",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/site_settings/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_settings');
                return adminGetSiteSettings($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/site-settings",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/site_settings/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_settings');
                return adminUpdateSiteSettings($con);
            },
        ],
        // Clears every active lockout at once. The escape hatch for a limit set too low, so that
        // fixing it never requires phpMyAdmin.
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/login-attempts/clear",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./helpers/app_settings.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_settings');
                $cleared = login_attempt_clear_all($con);
                return [
                    'status' => 'success',
                    'message' => app_text(
                        $con,
                        "تم إلغاء {$cleared} إيقاف مؤقت.",
                        "Released {$cleared} lockout" . ($cleared === 1 ? '' : 's') . "."
                    ),
                    'data' => ['cleared' => $cleared],
                ];
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/courses/toggle-website-visibility",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/courses/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_courses');
                return adminToggleCourseWebsiteVisibility($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/books/toggle-website-visibility",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/books/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_books');
                return adminToggleBookWebsiteVisibility($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/academic-years",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/academic_years/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_academic_years');
                return adminListAcademicYears($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/academic-years/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/academic_years/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_academic_years');
                return adminGetAcademicYear($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/academic-years",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/academic_years/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_academic_years');
                return adminCreateAcademicYear($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/academic-years",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/academic_years/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_academic_years');
                return adminUpdateAcademicYear($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/academic-years",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/academic_years/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_academic_years');
                return adminDeleteAcademicYear($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/academic-years/export",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/export/export.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_academic_years');
                adminExportAcademicYears($con);
            },
        ],

        // Course Categories CRUD
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/course-categories",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/course_categories/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_course_categories');
                return adminListCourseCategories($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/course-categories/show",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/course_categories/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_course_categories');
                return adminGetCourseCategory($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/course-categories",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/course_categories/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_course_categories');
                return adminCreateCourseCategory($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/course-categories",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/course_categories/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_course_categories');
                return adminUpdateCourseCategory($con);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/admin/course-categories",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/course_categories/manage.php";
                $adminData = adminAuthMiddleware();
                requirePermission($con, $adminData, 'manage_course_categories');
                return adminDeleteCourseCategory($con);
            },
        ],
    

    
        [
            "method" => "POST",
            "path" => "/brain-ixa/teacher/auth/login",
            "handler" => function ($con) {
                include_once "./app/teacher/auth/login.php";
                return teacherLogin($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/teacher/auth/register",
            "handler" => function ($con) {
                include_once "./app/teacher/auth/register.php";
                return teacherRegister($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/teacher/auth/verify-email",
            "handler" => function ($con) {
                return handleVerifyEmailOtp($con, 'teacher');
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/teacher/auth/resend-otp",
            "handler" => function ($con) {
                return handleResendOtp($con, 'teacher');
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/teacher/auth/forgot-password",
            "handler" => function ($con) {
                return handleForgotPassword($con, 'teacher');
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/teacher/auth/verify-reset-code",
            "handler" => function ($con) {
                return handleVerifyResetCode($con, 'teacher');
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/teacher/auth/reset-password",
            "handler" => function ($con) {
                return handleResetPassword($con, 'teacher');
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/teacher/auth/refresh",
            "handler" => function () {
                return handleTokenRefresh('teacher');
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/teacher/auth/profile",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/auth/profile.php";
                $teacherData = teacherAuthMiddleware();
                return teacherProfile($con, $teacherData);
            },
        ],
        [
            "method" => ["PUT", "POST", "PATCH"],
            "path" => "/brain-ixa/teacher/auth/profile",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/auth/profile.php";
                $teacherData = teacherAuthMiddleware();
                return teacherUpdateProfile($con, $teacherData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/teacher/fcm-token",
            "handler" => function ($con) {
                include_once "./middlewares/teacherauthmiddleware.php";
                include_once "./app/teacher/auth/profile.php";
                $teacherData = teacherAuthMiddleware();
                return teacherUpdateFcmToken($con, $teacherData);
            },
        ],
    
    
    
    [
        "method"  => "POST",
        "path"    => "/brain-ixa/parent/auth/login",
        "handler" => function ($con) {
            include_once "./app/parent/auth/login.php";
            return parentLogin($con);
        },
    ],
    [
        "method"  => "POST",
        "path"    => "/brain-ixa/parent/exams/exam_results",
        "handler" => function ($con) {
            include_once "./middlewares/studentauthmiddleware.php";
            include_once "./app/parent/exams/exam_results.php";
            $studentData = studentAuthMiddleware();

            $body      = read_json_body();
            $studentId = (int)($body['student_id'] ?? 0);

            if ($studentId <= 0) {
                return [
                    'status'  => 'error',
                    'message' => trans('student_id_required')
                ];
            }
            if ($studentId !== (int)($studentData['id'] ?? 0)) {
                return [
                    'status'  => 'error',
                    'message' => trans('unauthorized')
                ];
            }

            return [
                'status'  => 'success',
                'message' => trans('exams_fetched_successfully'),
                'data'    => get_student_exams_details($con, $studentId)
            ];
        },
    ],
    [
    "method"  => "POST",
    "path"    => "/brain-ixa/parent/courses/courses_progress",
    "handler" => function ($con) {
        include_once "./middlewares/studentauthmiddleware.php";
        include_once "./app/parent/courses/courses_progress.php";
        $studentData = studentAuthMiddleware();

        $body      = read_json_body();
        $studentId = (int)($body['student_id'] ?? 0);

        if ($studentId <= 0) {
            return [
                'status'  => 'error',
                'message' => trans('student_id_required')
            ];
        }
        if ($studentId !== (int)($studentData['id'] ?? 0)) {
            return [
                'status'  => 'error',
                'message' => trans('unauthorized')
            ];
        }

        return [
            'status'  => 'success',
            'message' => trans('courses_progress_fetched_successfully'),
            'data'    => get_student_courses_progress($con, $studentId)
        ];
    },
],
    [
    "method"  => "POST",
    "path"    => "/brain-ixa/parent/attendance/student_activity",
    "handler" => function ($con) {
        include_once "./middlewares/studentauthmiddleware.php";
        include_once "./app/parent/attendance/student_activity.php";
        $studentData = studentAuthMiddleware();

        $body      = read_json_body();
        $studentId = (int)($body['student_id'] ?? 0);

        if ($studentId <= 0) {
            return [
                'status'  => 'error',
                'message' => trans('student_id_required')
            ];
        }
        if ($studentId !== (int)($studentData['id'] ?? 0)) {
            return [
                'status'  => 'error',
                'message' => trans('unauthorized')
            ];
        }

        return [
            'status'  => 'success',
            'message' => trans('student_attendance_successfully'),
            'data'    => get_student_attendance($con, $studentId)
        ];
    },
],
    [
    "method"  => "POST",
    "path"    => "/brain-ixa/parent/subscription/student_subscriptions",
    "handler" => function ($con) {
        include_once "./middlewares/studentauthmiddleware.php";
        include_once "./app/parent/subscription/student_subscriptions.php";
        $studentData = studentAuthMiddleware();

        $body      = read_json_body();
        $studentId = (int)($body['student_id'] ?? 0);

        if ($studentId <= 0) {
            return [
                'status'  => 'error',
                'message' => trans('student_id_required')
            ];
        }
        if ($studentId !== (int)($studentData['id'] ?? 0)) {
            return [
                'status'  => 'error',
                'message' => trans('unauthorized')
            ];
        }

        return [
            'status'  => 'success',
            'message' => trans('student_subscriptions_successfully'),
            'data'    => get_student_subscriptions($con, $studentId)
        ];
    },
],
    [
    "method"  => "POST",
    "path"    => "/brain-ixa/parent/certifications/student_certificates",
    "handler" => function ($con) {
        include_once "./middlewares/studentauthmiddleware.php";
        include_once "./app/parent/certifications/student_certificates.php";
        $studentData = studentAuthMiddleware();

        $body      = read_json_body();
        $studentId = (int)($body['student_id'] ?? 0);

        if ($studentId <= 0) {
            return [
                'status'  => 'error',
                'message' => trans('student_id_required')
            ];
        }
        if ($studentId !== (int)($studentData['id'] ?? 0)) {
            return [
                'status'  => 'error',
                'message' => trans('unauthorized')
            ];
        }

        return [
            'status'  => 'success',
            'message' => trans('student_certificates_successfully'),
            'data'    => get_student_certificates($con, $studentId)
        ];
    },
],



   
        // Student Auth
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/student/auth/login",
            "handler" => function ($con) {
                include_once "./app/user/student/auth/login.php";
                return studentLogin($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/student/auth/register",
            "handler" => function ($con) {
                include_once "./app/user/student/auth/register.php";
                return studentRegister($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/student/auth/verify-email",
            "handler" => function ($con) {
                return handleVerifyEmailOtp($con, 'student');
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/student/auth/resend-otp",
            "handler" => function ($con) {
                return handleResendOtp($con, 'student');
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/student/auth/forgot-password",
            "handler" => function ($con) {
                return handleForgotPassword($con, 'student');
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/student/auth/verify-reset-code",
            "handler" => function ($con) {
                return handleVerifyResetCode($con, 'student');
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/student/auth/reset-password",
            "handler" => function ($con) {
                return handleResetPassword($con, 'student');
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/student/auth/refresh",
            "handler" => function () {
                return handleTokenRefresh('student');
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/user/student/auth/profile",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/auth/profile.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentProfile($con, $studentData);
            },
        ],
        [
            "method" => ["PUT", "POST", "PATCH"],
            "path" => "/brain-ixa/user/student/auth/profile",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/auth/profile.php";
                $studentData = studentAuthMiddleware();
                return studentUpdateProfile($con, $studentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/student/fcm-token",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/auth/profile.php";
                $studentData = studentAuthMiddleware();
                return studentUpdateFcmToken($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/devices",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/auth/devices.php";
                $studentData = studentAuthMiddleware();
                return studentListMyDevices($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/user/student/devices",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/auth/devices.php";
                $studentData = studentAuthMiddleware();
                return studentListMyDevices($con, $studentData);
            },
        ],
        [
            "method" => ["PUT", "POST", "PATCH"],
            "path" => "/brain-ixa/user/student/profile",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/auth/profile.php";
                $studentData = studentAuthMiddleware();
                return studentUpdateProfile($con, $studentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/student/subscriptions/redeem-code",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/subscriptions/manage.php";
                $studentData = studentAuthMiddleware();
                return studentRedeemSubscriptionCode($con, $studentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/student/payments/checkout",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/payments/manage.php";
                $studentData = studentAuthMiddleware();
                return studentInitiatePayment($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/payments/status",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/payments/manage.php";
                $studentData = studentAuthMiddleware();
                $transactionId = (int)($_GET['transaction_id'] ?? 0);
                return studentGetPaymentStatus($con, $studentData, $transactionId);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/student/payments/confirm",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/payments/manage.php";
                $studentData = studentAuthMiddleware();
                return studentConfirmPayment($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/payments/easykash/callback",
            "handler" => function ($con) {
                include_once "./helpers/easykash.php";
                include_once "./app/user/student/payments/manage.php";
                return paymentsEasykashCallback($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/payments/easykash/callback",
            "handler" => function ($con) {
                include_once "./helpers/easykash.php";
                include_once "./app/user/student/payments/manage.php";
                return paymentsEasykashCallback($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/subscriptions/my-subscriptions",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/subscriptions/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentListMySubscriptions($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/my-subscribed-courses",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/subscriptions/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentGetMySubscribedCourses($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/my-subscribed-subjects",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/subscriptions/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentGetMySubscribedSubjects($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/my-subscribed-teachers",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/subscriptions/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentGetMySubscribedTeachers($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/my-courses-progress",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentGetMySubscribedCoursesProgress($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/my-subscribed-courses-progress",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentGetMySubscribedCoursesProgress($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/my-subscribed-books",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentGetMySubscribedBooks($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/my-certificates",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentGetMyCertificates($con, $studentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/student/videos/track-progress",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/manage.php";
                $studentData = studentAuthMiddleware();
                return studentUpdateVideoProgress($con, $studentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/student/books/track-open",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/manage.php";
                $studentData = studentAuthMiddleware();
                return studentTrackBookOpen($con, $studentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/student/books/subscribe",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/books.php";
                $studentData = studentAuthMiddleware();
                return studentSubscribeBook($con, $studentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/student/books/buy",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/books.php";
                $studentData = studentAuthMiddleware();
                return studentSubscribeBook($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/books/purchase-requests",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/books.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentGetMyBookRequests($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/home",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentHome($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/courses-and-subjects",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/manage.php";
                return studentGetCoursesAndSubjects($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/all-courses-and-subjects",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/manage.php";
                return studentGetCoursesAndSubjects($con);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/courses",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentGetAllCoursesWithOwn($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/courses/show",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentGetCourseDetails($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/teacher-details",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentGetTeacherProfileDetails($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/teachers/show",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentGetTeacherProfileDetails($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/course-details",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentGetCourseDetails($con, $studentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/student/courses/rate",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/manage.php";
                $studentData = studentAuthMiddleware();
                return studentRateCourse($con, $studentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/student/teachers/rate",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/manage.php";
                $studentData = studentAuthMiddleware();
                return studentRateTeacher($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/books",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/books.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentGetAllBooksWithOwn($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/books/stream",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/books.php";
                $studentData = studentAuthMiddleware();
                studentStreamBookFile($con, $studentData);
            },
        ],

        // Parent Auth
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/parent/auth/login",
            "handler" => function ($con) {
                include_once "./app/user/parent/auth/login.php";
                return parentLogin($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/parent/auth/register",
            "handler" => function ($con) {
                include_once "./app/user/parent/auth/register.php";
                return parentRegister($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/parent/auth/verify-email",
            "handler" => function ($con) {
                return handleVerifyEmailOtp($con, 'parent');
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/parent/auth/resend-otp",
            "handler" => function ($con) {
                return handleResendOtp($con, 'parent');
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/parent/auth/forgot-password",
            "handler" => function ($con) {
                return handleForgotPassword($con, 'parent');
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/parent/auth/verify-reset-code",
            "handler" => function ($con) {
                return handleVerifyResetCode($con, 'parent');
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/parent/auth/reset-password",
            "handler" => function ($con) {
                return handleResetPassword($con, 'parent');
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/parent/auth/refresh",
            "handler" => function () {
                return handleTokenRefresh('parent');
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/user/parent/auth/profile",
            "handler" => function ($con) {
                include_once "./middlewares/parentauthmiddleware.php";
                include_once "./app/user/parent/auth/profile.php";
                $parentData = parentAuthMiddleware();
                return parentProfile($con, $parentData);
            },
        ],
        [
            "method" => ["PUT", "POST", "PATCH"],
            "path" => "/brain-ixa/user/parent/auth/profile",
            "handler" => function ($con) {
                include_once "./middlewares/parentauthmiddleware.php";
                include_once "./app/user/parent/auth/profile.php";
                $parentData = parentAuthMiddleware();
                return parentUpdateProfile($con, $parentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/user/parent/fcm-token",
            "handler" => function ($con) {
                include_once "./middlewares/parentauthmiddleware.php";
                include_once "./app/user/parent/auth/profile.php";
                $parentData = parentAuthMiddleware();
                return parentUpdateFcmToken($con, $parentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/user/parent/notifications",
            "handler" => function ($con) {
                include_once "./middlewares/parentauthmiddleware.php";
                include_once "./app/user/parent/notifications/manage.php";
                $parentData = parentAuthMiddleware();
                return parentListNotifications($con, $parentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/parent/notifications",
            "handler" => function ($con) {
                include_once "./middlewares/parentauthmiddleware.php";
                include_once "./app/user/parent/notifications/manage.php";
                $parentData = parentAuthMiddleware();
                return parentListNotifications($con, $parentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/parent/notifications/unread-count",
            "handler" => function ($con) {
                include_once "./middlewares/parentauthmiddleware.php";
                include_once "./app/user/parent/notifications/manage.php";
                $parentData = parentAuthMiddleware();
                return parentGetNotificationUnreadCount($con, $parentData);
            },
        ],
        [
            "method" => ["POST", "PUT"],
            "path" => "/brain-ixa/parent/notifications/read",
            "handler" => function ($con) {
                include_once "./middlewares/parentauthmiddleware.php";
                include_once "./app/user/parent/notifications/manage.php";
                $parentData = parentAuthMiddleware();
                return parentMarkNotificationRead($con, $parentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/parent/notifications/mark-read",
            "handler" => function ($con) {
                include_once "./middlewares/parentauthmiddleware.php";
                include_once "./app/user/parent/notifications/manage.php";
                $parentData = parentAuthMiddleware();
                return parentMarkNotificationRead($con, $parentData);
            },
        ],
        [
            "method" => "DELETE",
            "path" => "/brain-ixa/parent/notifications",
            "handler" => function ($con) {
                include_once "./middlewares/parentauthmiddleware.php";
                include_once "./app/user/parent/notifications/manage.php";
                $parentData = parentAuthMiddleware();
                return parentDeleteNotification($con, $parentData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/parent/notifications/delete",
            "handler" => function ($con) {
                include_once "./middlewares/parentauthmiddleware.php";
                include_once "./app/user/parent/notifications/manage.php";
                $parentData = parentAuthMiddleware();
                return parentDeleteNotification($con, $parentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/user/student/reports",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/reports.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentListMyReports($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/user/student/reports/show",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/reports.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentGetMyReport($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/reports",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/reports.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentListMyReports($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/reports/show",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/content/reports.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentGetMyReport($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/user/parent/reports",
            "handler" => function ($con) {
                include_once "./middlewares/parentauthmiddleware.php";
                include_once "./app/user/parent/reports/manage.php";
                $parentData = parentAuthMiddleware();
                return parentListChildrenReports($con, $parentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/user/parent/reports/show",
            "handler" => function ($con) {
                include_once "./middlewares/parentauthmiddleware.php";
                include_once "./app/user/parent/reports/manage.php";
                $parentData = parentAuthMiddleware();
                return parentGetChildReport($con, $parentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/parent/reports",
            "handler" => function ($con) {
                include_once "./middlewares/parentauthmiddleware.php";
                include_once "./app/user/parent/reports/manage.php";
                $parentData = parentAuthMiddleware();
                return parentListChildrenReports($con, $parentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/parent/reports/show",
            "handler" => function ($con) {
                include_once "./middlewares/parentauthmiddleware.php";
                include_once "./app/user/parent/reports/manage.php";
                $parentData = parentAuthMiddleware();
                return parentGetChildReport($con, $parentData);
            },
        ],

        // Parent: Children's Sessions --------------------------------
        [
            "method" => "GET",
            "path" => "/brain-ixa/parent/sessions",
            "handler" => function ($con) {
                include_once "./middlewares/parentauthmiddleware.php";
                include_once "./app/user/parent/sessions/manage.php";
                $parentData = parentAuthMiddleware();
                return parentGetChildSessions($con, $parentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/parent/sessions/files",
            "handler" => function ($con) {
                include_once "./middlewares/parentauthmiddleware.php";
                include_once "./app/user/parent/sessions/manage.php";
                $parentData = parentAuthMiddleware();
                return parentGetChildSessionFiles($con, $parentData);
            },
        ],
        // Student Affiliate Routes --------------------------------
        [
            "method" => "GET",
            "path" => "/brain-ixa/user/student/affiliate/info",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/affiliate/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentGetAffiliateInfo($con, $studentData);
            },
        ],
        [
            "method" => "GET",
            "path" => "/brain-ixa/student/affiliate/info",
            "handler" => function ($con) {
                include_once "./middlewares/studentauthmiddleware.php";
                include_once "./app/user/student/affiliate/manage.php";
                $studentData = studentAuthMiddlewareOptional();
                return studentGetAffiliateInfo($con, $studentData);
            },
        ],

        // Admin Affiliate Routes --------------------------------
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/affiliates/requests",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/affiliates/manage.php";
                $adminData = adminAuthMiddleware();
                return adminListAffiliateRequests($con, $adminData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/affiliates/approve",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/affiliates/manage.php";
                $adminData = adminAuthMiddleware();
                return adminApproveAffiliateRequest($con, $adminData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/affiliates/reject",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/affiliates/manage.php";
                $adminData = adminAuthMiddleware();
                return adminRejectAffiliateRequest($con, $adminData);
            },
        ],
        // What a referral earns, and what a point is worth in each currency.
        [
            "method" => "GET",
            "path" => "/brain-ixa/admin/points/settings",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/affiliates/manage.php";
                $adminData = adminAuthMiddleware();
                return adminGetPointsSettings($con);
            },
        ],
        [
            "method" => "PUT",
            "path" => "/brain-ixa/admin/points/settings",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/affiliates/manage.php";
                $adminData = adminAuthMiddleware();
                requireSuperAdmin($con, $adminData);
                return adminUpdatePointsSettings($con, $adminData);
            },
        ],
        [
            // Everything that has ever happened to one student's points, with the balance's worth.
            "method" => "GET",
            "path" => "/brain-ixa/admin/students/points",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/affiliates/manage.php";
                adminAuthMiddleware();
                return adminGetStudentPointsLedger($con);
            },
        ],
        [
            // One referral code's own earning rule, overriding the platform default.
            "method" => "PUT",
            "path" => "/brain-ixa/admin/affiliates/rule",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/affiliates/manage.php";
                $adminData = adminAuthMiddleware();
                requireSuperAdmin($con, $adminData);
                return adminSetAffiliateRule($con, $adminData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/affiliates/deduct-points",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/affiliates/manage.php";
                $adminData = adminAuthMiddleware();
                return adminDeductStudentPoints($con, $adminData);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/admin/students/deduct-points",
            "handler" => function ($con) {
                include_once "./middlewares/adminauthmiddleware.php";
                include_once "./app/admin/affiliates/manage.php";
                $adminData = adminAuthMiddleware();
                return adminDeductStudentPoints($con, $adminData);
            },
        ],

        // Audio & File Upload Endpoints --------------------------------
        [
            "method" => "POST",
            "path" => "/brain-ixa/common/upload/audio",
            "handler" => function ($con) {
                include_once "./middlewares/anyauthmiddleware.php";
                anyAuthMiddleware();
                include_once "./app/common/upload/manage.php";
                return handleAudioFileUpload($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/upload/audio",
            "handler" => function ($con) {
                include_once "./middlewares/anyauthmiddleware.php";
                anyAuthMiddleware();
                include_once "./app/common/upload/manage.php";
                return handleAudioFileUpload($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/common/upload",
            "handler" => function ($con) {
                include_once "./app/common/upload/manage.php";
                return handleGeneralFileUpload($con);
            },
        ],
        [
            "method" => "POST",
            "path" => "/brain-ixa/upload",
            "handler" => function ($con) {
                include_once "./app/common/upload/manage.php";
                return handleGeneralFileUpload($con);
            },
        ],
    
];

foreach ($routes as $key => $route) {
    if (is_array($route) && !isset($route["method"])) {
        foreach ($route as $subRoute) {
            handleRoute($subRoute, $method, $path, $con);
        }
    } else {
        handleRoute($route, $method, $path, $con);
    }
}

json_response(
    [
        "status" => "error",
        "message" => trans("route_not_found"),
        "method" => $method,
        "path" => $path,
    ],
    404
);
