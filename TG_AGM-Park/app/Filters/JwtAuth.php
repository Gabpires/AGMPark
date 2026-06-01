<?php

namespace App\Filters;

use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\Filters\FilterInterface;

class JwtAuth implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null)
    {
        try {
            if (!function_exists('get_bearer_token')) {
                helper('jwt');
            }

            $token = get_bearer_token();
            if (!$token) {
                return service('response')
                    ->setStatusCode(401)
                    ->setJSON(['sucesso' => false, 'erros' => [['codigo' => 401, 'msg' => 'Token não informado']]]);
            }

            $payload = jwt_decode($token);
            if (!$payload) {
                return service('response')
                    ->setStatusCode(401)
                    ->setJSON(['sucesso' => false, 'erros' => [['codigo' => 401, 'msg' => 'Token inválido ou expirado']]]);
            }

            return null;
        } catch (\Throwable $e) {
            log_message('error', 'JwtAuth filter error: ' . $e->getMessage());
            return service('response')
                ->setStatusCode(500)
                ->setJSON(['sucesso' => false, 'erros' => [['codigo' => 500, 'msg' => 'Erro interno no filtro de autenticação']]]);
        }
    }

    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null)
    {
        // nada a fazer
    }
}
