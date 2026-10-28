<?php

/**
 * Template for config/zoomConfig.php, which is deliberately NOT in git.
 *
 * Copy this file to config/zoomConfig.php on each machine and on the server, fill in the real
 * values, and never commit that copy. Unlike the database and EasyKash credentials - which were
 * already in the repo before this rule existed - Zoom's secrets stay out of version control, so
 * a `git pull` on the server never carries them and a clone never leaks them.
 *
 * Two separate Marketplace apps, and they are NOT interchangeable:
 *
 *   Server-to-Server OAuth ("Brainixa Backend")
 *     How the backend acts on the Zoom account with nobody signed in: it creates, updates and
 *     deletes the meeting behind a scheduled class, and reads the host's ZAK token so a teacher
 *     can start that meeting from inside Brainixa instead of on zoom.us.
 *     Required scopes: meeting write/read/update/delete (:admin), user:read:user:admin,
 *     user:read:zak:admin, report:read:list_meeting_participants:admin.
 *
 *   Meeting SDK ("Brainixa Meeting SDK")
 *     Used only to SIGN a join. The secret never leaves the server: the browser and the mobile
 *     app receive a short-lived signature, never the key itself.
 *
 * Account limit worth remembering before promising anything: the account is Zoom Workplace Pro
 * with ONE licensed user, and a licensed user hosts one meeting at a time. That means one live
 * class at a time, platform-wide, until more licenses are bought.
 */

return [
    's2s' => [
        'account_id'    => '',
        'client_id'     => '',
        'client_secret' => '',
        'token_url'     => 'https://zoom.us/oauth/token',
        'api_base'      => 'https://api.zoom.us/v2',
    ],

    'sdk' => [
        'client_id'     => '',
        'client_secret' => '',
    ],

    // Set once the webhook endpoint is registered in the Marketplace app.
    'webhook_secret_token' => '',

    // Meetings are created under this account user. 'me' resolves to the S2S app's owner, which
    // is the only licensed host today. When per-teacher licenses are bought this stops being a
    // single value and becomes a per-teacher Zoom user id stored on the teachers table.
    'default_host' => 'me',

    'timezone' => 'Africa/Cairo',
];
