<?php

defined('JWT_KEY') || define('JWT_KEY', 'minha_chave_secreta_fixa_12345');
defined('JWT_ISSUER') || define('JWT_ISSUER', 'AGMParkAPI');

function base64url_encode($data)
{
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

function base64url_decode($data)
{
    $remainder = strlen($data) % 4;
    if ($remainder) {
        $data .= str_repeat('=', 4 - $remainder);
    }
    return base64_decode(strtr($data, '-_', '+/'));
}

function jwt_encode(array $payload, $expSeconds = 3600)
{
    $header = ['alg' => 'HS256', 'typ' => 'JWT'];

    $iat = time();
    $payload['iss'] = JWT_ISSUER;
    $payload['iat'] = $iat;
    $payload['exp'] = $iat + $expSeconds;

    $segments = [];
    $segments[] = base64url_encode(json_encode($header));
    $segments[] = base64url_encode(json_encode($payload));

    $signing_input = implode('.', $segments);
    $signature = hash_hmac('sha256', $signing_input, JWT_KEY, true);
    $segments[] = base64url_encode($signature);

    return implode('.', $segments);
}

function jwt_decode($token)
{
    try {
        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            return null;
        }

        list($headb64, $bodyb64, $cryptob64) = $parts;

        $header = json_decode(base64url_decode($headb64), true);
        $payload = json_decode(base64url_decode($bodyb64), true);
        $signature = base64url_decode($cryptob64);

        $valid = hash_hmac('sha256', $headb64 . '.' . $bodyb64, JWT_KEY, true);

        if (!hash_equals($valid, $signature)) {
            return null;
        }

        if (isset($payload['exp']) && time() > $payload['exp']) {
            return null;
        }

        return $payload;
    } catch (Exception $e) {
        return null;
    }
}

function get_bearer_token()
{
    $request = service('request');
    $auth = $request->getHeaderLine('Authorization');
    if (!$auth) {
        return null;
    }
    if (preg_match('/Bearer\s+(.*)$/i', $auth, $matches)) {
        return $matches[1];
    }
    return null;
}

function get_jwt_payload()
{
    $token = get_bearer_token();
    if (!$token) return null;
    return jwt_decode($token);
}
