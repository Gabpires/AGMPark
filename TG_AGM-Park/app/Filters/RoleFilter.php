<?php

namespace App\Filters;

use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\Filters\FilterInterface;

class RoleFilter implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null)
    {
        try {
            if (!function_exists('get_jwt_payload')) {
                helper('jwt');
            }

            // $arguments é uma string com roles separadas por vírgula
            $allowed = [];
            if (is_array($arguments)) {
                $allowed = $arguments;
            } elseif (is_string($arguments) && strlen($arguments) > 0) {
                $allowed = array_map('trim', explode(',', $arguments));
            }

            $payload = get_jwt_payload();
            if (!$payload) {
                return service('response')
                    ->setStatusCode(401)
                    ->setJSON(['sucesso' => false, 'erros' => [['codigo' => 401, 'msg' => 'Token ausente ou inválido']]]);
            }

            $tipo = $payload['tipo_usuario'] ?? null;
            // ADMINISTRADOR e PROPRIETARIO têm acesso total
            if (in_array($tipo, ['ADMINISTRADOR', 'PROPRIETARIO'], true)) {
                return null;
            }

            if (empty($allowed)) {
                return service('response')
                    ->setStatusCode(403)
                    ->setJSON(['sucesso' => false, 'erros' => [['codigo' => 403, 'msg' => 'Acesso negado']]]);
            }

        if (!in_array($tipo, $allowed)) {
            return service('response')
                ->setStatusCode(403)
                ->setJSON(['sucesso' => false, 'erros' => [['codigo' => 403, 'msg' => 'Função não autorizada para este recurso']]]);
        }

        return null;
        } catch (\Throwable $e) {
            log_message('error', 'RoleFilter error: ' . $e->getMessage());
            return service('response')
                ->setStatusCode(500)
                ->setJSON(['sucesso' => false, 'erros' => [['codigo' => 500, 'msg' => 'Erro interno no filtro de roles']]]);
        }
    }

    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null)
    {
    }
}
