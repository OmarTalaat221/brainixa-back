<?php

/**
 * Zoom credentials. Two separate Marketplace apps, and they are not interchangeable.
 *
 * The Server-to-Server OAuth app is how the backend acts on the account with no user signed in:
 * it creates, updates and deletes the meeting behind a scheduled class, and reads the host's ZAK
 * token so a teacher can start that meeting from inside Brainixa instead of in zoom.us.
 *
 * The Meeting SDK app is only ever used to SIGN a join. Its secret never leaves the server - the
 * browser and the mobile app receive a short-lived signature, never the key itself.
 *
 * Both sets were verified live on 2026-10-28: a token was issued, a meeting created, its ZAK
 * fetched, then the meeting deleted.
 *
 * Account limit worth remembering before promising anything: this account is Zoom Workplace Pro
 * with ONE licensed user, and a licensed user hosts one meeting at a time. One live class at a
 * time, platform-wide, until more licenses are bought.
 */

return [
    // Server-to-Server OAuth app ("Brainixa Backend").
    's2s' => [
        'account_id'    => 'k9hmzdB2Rc60y0a3xGI_Mw',
        'client_id'     => 'pRx20KdmSIqj4H7jFZsTvA',
        'client_secret' => 'zQk8RlpWt3CeVlz6X1fiE4ZbCCLTen0Q',
        'token_url'     => 'https://zoom.us/oauth/token',
        'api_base'      => 'https://api.zoom.us/v2',
    ],

    // Meeting SDK app ("Brainixa Meeting SDK") - signing only.
    'sdk' => [
        'client_id'     => 'andQ8D6ATQbS6uGVhpQ7g',
        'client_secret' => 'glhXyG1RSQDs1PD8eLA2a62qBU7N6PI6',
    ],

    // Set once the webhook endpoint is registered in the Marketplace app.
    'webhook_secret_token' => '',

    // Meetings are created under this account user. 'me' resolves to the S2S app's owner, which
    // is the only licensed host today. When per-teacher licenses are bought, this stops being a
    // single value and becomes a per-teacher Zoom user id on the teachers table.
    'default_host' => 'me',

    'timezone' => 'Africa/Cairo',
];
