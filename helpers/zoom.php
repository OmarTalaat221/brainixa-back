<?php

/**
 * Zoom integration.
 *
 * Two credentials, two jobs, and keeping them apart is the whole design:
 *
 *   Server-to-Server OAuth — the backend acting on the Zoom account with nobody signed in. It
 *   creates the meeting behind a live class, ends it, and fetches the host's ZAK.
 *
 *   Meeting SDK — signing a join. The secret never leaves this server. A browser gets a
 *   short-lived JWT that lets it open THAT meeting and nothing else, so the class plays inside
 *   Brainixa instead of bouncing the student to zoom.us.
 *
 * Credentials live in config/zoomConfig.php, which is deliberately not in git. If that file is
 * missing, every function here fails closed with a clear message rather than half-working.
 */

require_once __DIR__ . '/functions.php';

if (!function_exists('zoom_config')) {
    function zoom_config(): array {
        static $cfg = null;
        if ($cfg !== null) return $cfg;

        $path = __DIR__ . '/../config/zoomConfig.php';
        $cfg = file_exists($path) ? (array)require $path : [];
        return $cfg;
    }
}

if (!function_exists('zoom_is_configured')) {
    function zoom_is_configured(): bool {
        $c = zoom_config();
        return !empty($c['s2s']['account_id'])
            && !empty($c['s2s']['client_id'])
            && !empty($c['s2s']['client_secret'])
            && !empty($c['sdk']['client_id'])
            && !empty($c['sdk']['client_secret']);
    }
}

if (!function_exists('zoom_not_configured_error')) {
    function zoom_not_configured_error(): array {
        return [
            'status' => 'error',
            'message' => 'لم يتم ضبط تكامل Zoom على هذا الخادم بعد. ارفع ملف config/zoomConfig.php.',
        ];
    }
}

if (!function_exists('zoom_base64url')) {
    function zoom_base64url(string $raw): string {
        return rtrim(strtr(base64_encode($raw), '+/', '-_'), '=');
    }
}

if (!function_exists('zoom_jwt_hs256')) {
    /** Minimal HS256 JWT. Zoom's SDK signature is nothing more than this. */
    function zoom_jwt_hs256(array $payload, string $secret): string {
        $header = zoom_base64url(json_encode(['alg' => 'HS256', 'typ' => 'JWT']));
        $body   = zoom_base64url(json_encode($payload));
        $sig    = zoom_base64url(hash_hmac('sha256', $header . '.' . $body, $secret, true));
        return $header . '.' . $body . '.' . $sig;
    }
}

if (!function_exists('zoom_access_token')) {
    /**
     * A Server-to-Server OAuth access token, cached in the database until shortly before it
     * expires.
     *
     * The cache matters more than it looks: Zoom rate-limits token requests, and without it every
     * single class action would burn one. The row is refreshed 5 minutes early so a token never
     * expires mid-request.
     *
     * Returns null on failure and writes the reason into $error, because the callers need to tell
     * a misconfiguration apart from Zoom being down.
     */
    function zoom_access_token($con, ?string &$error = null): ?string {
        $error = null;

        if (!zoom_is_configured()) {
            $error = 'Zoom is not configured on this server';
            return null;
        }

        $cfg = zoom_config()['s2s'];

        $res = @mysqli_query($con, "SELECT access_token FROM zoom_oauth_tokens WHERE id = 1 AND expires_at > DATE_ADD(NOW(), INTERVAL 5 MINUTE) LIMIT 1");
        if ($res && $row = mysqli_fetch_assoc($res)) {
            return $row['access_token'];
        }

        $url = $cfg['token_url'] . '?' . http_build_query([
            'grant_type' => 'account_credentials',
            'account_id' => $cfg['account_id'],
        ]);

        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => '',
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 20,
            CURLOPT_HTTPHEADER => [
                'Authorization: Basic ' . base64_encode($cfg['client_id'] . ':' . $cfg['client_secret']),
                'Content-Type: application/x-www-form-urlencoded',
            ],
        ]);
        $raw = curl_exec($ch);
        $code = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $curlErr = curl_error($ch);
        curl_close($ch);

        if ($raw === false) {
            $error = 'Could not reach Zoom: ' . $curlErr;
            return null;
        }

        $data = json_decode($raw, true);
        if ($code !== 200 || empty($data['access_token'])) {
            $error = 'Zoom refused the token request (HTTP ' . $code . '): ' . substr($raw, 0, 300);
            return null;
        }

        $token = $data['access_token'];
        $ttl = max(60, (int)($data['expires_in'] ?? 3600));

        $tokEsc = mysqli_real_escape_string($con, $token);
        @mysqli_query($con, "
            INSERT INTO zoom_oauth_tokens (id, access_token, expires_at, updated_at)
            VALUES (1, '{$tokEsc}', DATE_ADD(NOW(), INTERVAL {$ttl} SECOND), NOW())
            ON DUPLICATE KEY UPDATE
                access_token = VALUES(access_token),
                expires_at = VALUES(expires_at),
                updated_at = NOW()
        ");

        return $token;
    }
}

if (!function_exists('zoom_api')) {
    /**
     * One call to the Zoom REST API.
     *
     * Always returns an array shaped ['ok' => bool, 'status' => int, 'data' => array, 'error' =>
     * ?string]. Zoom answers a DELETE with an empty body and 204, which json_decode would turn
     * into null, so an empty body on a 2xx is reported as success with no data rather than as a
     * parse failure.
     */
    function zoom_api($con, string $method, string $path, ?array $body = null): array {
        $token = zoom_access_token($con, $tokenError);
        if (!$token) {
            return ['ok' => false, 'status' => 0, 'data' => [], 'error' => $tokenError];
        }

        $cfg = zoom_config()['s2s'];
        $ch = curl_init($cfg['api_base'] . $path);

        $headers = ['Authorization: Bearer ' . $token];
        $opts = [
            CURLOPT_CUSTOMREQUEST => strtoupper($method),
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 25,
        ];
        if ($body !== null) {
            $opts[CURLOPT_POSTFIELDS] = json_encode($body, JSON_UNESCAPED_UNICODE);
            $headers[] = 'Content-Type: application/json';
        }
        $opts[CURLOPT_HTTPHEADER] = $headers;
        curl_setopt_array($ch, $opts);

        $raw = curl_exec($ch);
        $status = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $curlErr = curl_error($ch);
        curl_close($ch);

        if ($raw === false) {
            return ['ok' => false, 'status' => 0, 'data' => [], 'error' => 'Could not reach Zoom: ' . $curlErr];
        }

        $trimmed = trim($raw);
        $data = $trimmed === '' ? [] : json_decode($trimmed, true);
        if (!is_array($data)) $data = [];

        $ok = $status >= 200 && $status < 300;

        return [
            'ok' => $ok,
            'status' => $status,
            'data' => $data,
            'error' => $ok ? null : ($data['message'] ?? ('Zoom returned HTTP ' . $status)),
        ];
    }
}

if (!function_exists('zoom_sdk_signature')) {
    /**
     * The JWT the Meeting SDK needs in order to open one specific meeting.
     *
     * $role is 1 for the host (the teacher) and 0 for an attendee (the student). It is decided
     * here from server-side facts, never from anything the client sent — a student who could ask
     * for role 1 could mute the class and remove people from it.
     *
     * The token is deliberately short-lived. It is minted when someone presses Join and is of no
     * use once the class is over.
     */
    function zoom_sdk_signature(string $meetingNumber, int $role, int $ttlSeconds = 7200): string {
        $cfg = zoom_config()['sdk'];

        $now = time() - 30;                       // a little slack for clock drift
        $exp = $now + max(1800, min($ttlSeconds, 172800));  // Zoom allows 30 minutes to 48 hours

        return zoom_jwt_hs256([
            'appKey'   => $cfg['client_id'],
            'sdkKey'   => $cfg['client_id'],
            'mn'       => $meetingNumber,
            'role'     => $role,
            'iat'      => $now,
            'exp'      => $exp,
            'tokenExp' => $exp,
        ], $cfg['client_secret']);
    }
}

if (!function_exists('zoom_host_zak')) {
    /**
     * The host's Zoom Access Key.
     *
     * A signature alone lets someone join a meeting; it does not let them START one. The ZAK is
     * what tells Zoom "this person is the host", and without it the teacher sits in the waiting
     * room of their own class. It is short-lived and must never be handed to a student.
     */
    function zoom_host_zak($con, string $hostUserId = 'me'): ?string {
        $res = zoom_api($con, 'GET', '/users/' . rawurlencode($hostUserId) . '/token?type=zak');
        return $res['ok'] ? ($res['data']['token'] ?? null) : null;
    }
}

if (!function_exists('zoom_create_meeting')) {
    /**
     * Creates the Zoom meeting for one occurrence of a class.
     *
     * `join_before_host` is on deliberately: students arriving a couple of minutes early should
     * see the room rather than a "waiting for host" screen, and the waiting room is off for the
     * same reason — the platform has already decided who is allowed in before it ever mints a
     * signature.
     */
    function zoom_create_meeting($con, string $topic, int $durationMinutes, string $hostUserId = 'me'): array {
        $cfg = zoom_config();

        return zoom_api($con, 'POST', '/users/' . rawurlencode($hostUserId) . '/meetings', [
            'topic'      => mb_substr($topic, 0, 200),
            'type'       => 1,                       // instant: the class is starting now
            'duration'   => max(5, $durationMinutes),
            'timezone'   => $cfg['timezone'] ?? 'Africa/Cairo',
            'settings'   => [
                'host_video'        => true,
                'participant_video' => false,
                'join_before_host'  => true,
                'waiting_room'      => false,
                'mute_upon_entry'   => true,
                'approval_type'     => 2,            // no registration
                'audio'             => 'both',
                'auto_recording'    => 'none',
            ],
        ]);
    }
}

if (!function_exists('zoom_end_meeting')) {
    function zoom_end_meeting($con, string $meetingId): array {
        return zoom_api($con, 'PUT', '/meetings/' . rawurlencode($meetingId) . '/status', [
            'action' => 'end',
        ]);
    }
}
