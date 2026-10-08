<?php


return [
    'api_key' => '4jf8kp3wkcn3409n',
    'hmac_secret' => '9d948f21f018132086a815f38ee8fa0e',
    'pay_url' => 'https://back.easykash.net/api/directpayv1/pay',
    'inquire_url' => 'https://back.easykash.net/api/cash-api/inquire',
    'currency' => 'EGP',
    // The STUDENT DASHBOARD, not the landing page. Every payment starts from a signed-in student
    // there - the landing page sends visitors over rather than charging them itself - so this is
    // where the gateway must hand them back. It used to point at brain-ixa.vercel.app, which is
    // the landing page, so a paying student was dropped on a marketing site with no idea whether
    // their money had gone through.
    'default_redirect_url' => 'https://brainixa-student-dash.vercel.app/payment/result',
];
