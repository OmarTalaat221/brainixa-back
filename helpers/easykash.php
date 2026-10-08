<?php

if (!function_exists('easykash_config')) {
    function easykash_config(): array {
        static $config = null;
        if ($config === null) {
            $config = require __DIR__ . '/../config/easykashConfig.php';
        }
        return $config;
    }
}

if (!function_exists('easykash_describe_rejection')) {
    /**
     * Turns whatever EasyKash answered into one readable line.
     *
     * Their rejections come in at least three shapes: a list of field errors
     * (`[{"message":"Currency is required","field":"currency"}]`), an object with a `message`,
     * and occasionally a bare string. Anything unrecognised falls back to a trimmed copy of the
     * body, so an unfamiliar shape still leaves a trail instead of an empty string.
     */
    function easykash_describe_rejection($decoded, $raw): string {
        if (is_array($decoded)) {
            $parts = [];

            if (isset($decoded['message']) && is_string($decoded['message'])) {
                $parts[] = $decoded['message'];
            }

            foreach ($decoded as $entry) {
                if (is_array($entry) && isset($entry['message'])) {
                    $field = isset($entry['field']) ? $entry['field'] . ': ' : '';
                    $parts[] = $field . $entry['message'];
                }
            }

            if ($parts) {
                return implode('; ', array_unique($parts));
            }
        }

        if (is_string($decoded) && $decoded !== '') {
            return $decoded;
        }

        return trim(substr((string)$raw, 0, 300));
    }
}

if (!function_exists('easykash_create_payment')) {
    function easykash_create_payment(array $params): array {
        $config = easykash_config();

        $payload = [
            'amount' => (float)$params['amount'],
            'currency' => $params['currency'] ?? $config['currency'],
            'name' => $params['name'],
            'email' => $params['email'],
            'mobile' => $params['mobile'],
            'redirectUrl' => $params['redirectUrl'],
            'customerReference' => (int)$params['customerReference'],
        ];

        $ch = curl_init();
        curl_setopt_array($ch, [
            CURLOPT_URL => $config['pay_url'],
            CURLOPT_POST => true,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => [
                'authorization: ' . $config['api_key'],
                'Content-Type: application/json',
            ],
            CURLOPT_POSTFIELDS => json_encode($payload, JSON_UNESCAPED_UNICODE),
            CURLOPT_TIMEOUT => 30,
        ]);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $curlError = curl_error($ch);
        curl_close($ch);

        if ($response === false) {
            // A blocked outbound connection from the host looks identical to a rejected payment
            // from the student's side, so the two are told apart here rather than guessed at.
            easykash_log('Pay request could not reach EasyKash: ' . $curlError);
            return ['status' => 'error', 'message' => 'Curl error while contacting EasyKash', 'error' => $curlError];
        }

        $decoded = json_decode($response, true);

        if ($httpCode < 200 || $httpCode >= 300 || empty($decoded['redirectUrl'])) {
            // EasyKash says exactly what is wrong - it answers a bad field with HTTP 460 and
            // `[{"message":"Currency is required","field":"currency",...}]`. That answer used to
            // be returned in a key nobody read and never written down, so every failure reached
            // the student as "Failed to initiate payment with EasyKash" and reached the
            // maintainer as nothing at all. It is recorded here and summarised for the caller.
            $reason = easykash_describe_rejection($decoded, $response);

            easykash_log(
                'Pay request rejected: http=' . $httpCode .
                ' customerReference=' . (int)$params['customerReference'] .
                ' amount=' . (float)$params['amount'] .
                ' currency=' . ($payload['currency'] ?? '') .
                ' reason=' . $reason
            );

            return [
                'status' => 'error',
                'message' => 'EasyKash rejected the payment request',
                'reason' => $reason,
                'http_code' => $httpCode,
                'response' => $decoded ?: $response,
            ];
        }

        return ['status' => 'success', 'redirectUrl' => $decoded['redirectUrl']];
    }
}


if (!function_exists('easykash_inquire_payment')) {
    /**
     * Asks EasyKash what actually happened to a transaction.
     *
     * This is the trustworthy way to settle a payment from the browser's "I'm back from the
     * gateway" moment. The browser can claim anything; this answer comes from EasyKash over a
     * connection we opened and authenticated with our own API key, so there is nothing for a
     * caller to forge - which is why the result needs no HMAC of its own.
     *
     * `status` comes back as one of: DELIVERED, EXPIRED, FAILED, NEW, PAID, REFUNDED, CANCELED.
     */
    function easykash_inquire_payment($customerReference): array {
        $config = easykash_config();
        $url = $config['inquire_url'] ?? 'https://back.easykash.net/api/cash-api/inquire';

        $ch = curl_init();
        curl_setopt_array($ch, [
            CURLOPT_URL => $url,
            CURLOPT_POST => true,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => [
                'authorization: ' . $config['api_key'],
                'Content-Type: application/json',
            ],
            CURLOPT_POSTFIELDS => json_encode(
                ['customerReference' => (string)$customerReference],
                JSON_UNESCAPED_UNICODE
            ),
            CURLOPT_TIMEOUT => 30,
        ]);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $curlError = curl_error($ch);
        curl_close($ch);

        if ($response === false) {
            return ['status' => 'error', 'message' => 'Curl error while contacting EasyKash', 'error' => $curlError];
        }

        $decoded = json_decode($response, true);

        if ($httpCode < 200 || $httpCode >= 300 || !is_array($decoded)) {
            return [
                'status' => 'error',
                'message' => 'EasyKash rejected the inquiry',
                'http_code' => $httpCode,
                'response' => $decoded ?: $response,
            ];
        }

        return ['status' => 'success', 'data' => $decoded];
    }
}


/**
 * EasyKash's own docs/examples are inconsistent about field casing (ProductCode vs
 * productCode, etc). Look up a callback field regardless of how it was actually cased.
 */
if (!function_exists('easykash_ci_get')) {
    function easykash_ci_get(array $data, string $key): string {
        foreach ($data as $k => $v) {
            if (strcasecmp((string)$k, $key) === 0) {
                return (string)$v;
            }
        }
        return '';
    }
}

if (!function_exists('easykash_log')) {
    function easykash_log(string $message): void {
        $dir = __DIR__ . '/../logs';
        if (!is_dir($dir)) {
            @mkdir($dir, 0775, true);
        }
        @file_put_contents(
            $dir . '/easykash_callback.log',
            '[' . date('Y-m-d H:i:s') . '] ' . $message . PHP_EOL,
            FILE_APPEND
        );
    }
}

if (!function_exists('easykash_verify_callback_signature')) {
    function easykash_verify_callback_signature(array $data): bool {
        $config = easykash_config();

        $signatureHash = easykash_ci_get($data, 'signatureHash');
        if (empty($signatureHash)) {
            return false;
        }

        $concatenated =
            easykash_ci_get($data, 'ProductCode') .
            easykash_ci_get($data, 'Amount') .
            easykash_ci_get($data, 'ProductType') .
            easykash_ci_get($data, 'PaymentMethod') .
            easykash_ci_get($data, 'status') .
            easykash_ci_get($data, 'easykashRef') .
            easykash_ci_get($data, 'customerReference');

        $computed = hash_hmac('sha512', $concatenated, $config['hmac_secret']);
        $isValid = hash_equals($computed, (string)$signatureHash);

        if (!$isValid) {
            // The computed signature is NEVER written down. It used to be, next to the exact
            // string it was computed from - which turned this function into a signing oracle:
            // post any payload you like, let verification fail, read the log, and you have a
            // valid signature for that payload without ever knowing the secret. Only the
            // reference and the claimed hash are recorded, which is enough to investigate a
            // genuine mismatch and useless to an attacker.
            easykash_log(
                'Signature mismatch for customerReference=' .
                easykash_ci_get($data, 'customerReference') .
                ' received=' . substr((string)$signatureHash, 0, 12) . '...'
            );
        }

        return $isValid;
    }
}
