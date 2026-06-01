<?php

namespace App\Controllers;

use App\Models\UsuarioModel;

class Auth extends BaseController
{
    public function login()
    {
        helper('jwt');

        $data = $this->request->getJSON();
        if (!$data || empty($data->email) || empty($data->senha)) {
            return $this->response->setStatusCode(400)->setJSON(['sucesso' => false, 'erros' => [['codigo' => 400, 'msg' => 'Email e senha obrigatórios']]]);
        }

        $model = new UsuarioModel();
        $user = $model->where('email', $data->email)->first();

        if (!$user) {
            return $this->response->setStatusCode(401)->setJSON(['sucesso' => false, 'erros' => [['codigo' => 401, 'msg' => 'Credenciais inválidas']]]);
        }

        if (!password_verify($data->senha, $user['senha'])) {
            return $this->response->setStatusCode(401)->setJSON(['sucesso' => false, 'erros' => [['codigo' => 401, 'msg' => 'Credenciais inválidas']]]);
        }

        if (isset($user['status']) && $user['status'] !== 'ATIVO') {
            return $this->response->setStatusCode(403)->setJSON(['sucesso' => false, 'erros' => [['codigo' => 403, 'msg' => 'Usuário inativo']]]);
        }

        $payload = [
            'id' => $user['id_funcionario'],
            'email' => $user['email'],
            'tipo_usuario' => $user['tipo_usuario'] ?? 'FUNCIONARIO'
        ];

        $token = jwt_encode($payload, 3600);

        // atualiza ultimo_login
        //$model->update($user['id_funcionario'], ['ultimo_login' => date('Y-m-d H:i:s')]);

        return $this->response->setJSON(['sucesso' => true, 'token' => $token]);
    }

    public function checkAuth()
    {
        helper('jwt');
        $payload = get_jwt_payload();
        if (!$payload) {
            return $this->response->setStatusCode(401)->setJSON(['sucesso' => false, 'erros' => [['codigo' => 401, 'msg' => 'Não autenticado']]]);
        }

        return $this->response->setJSON(['sucesso' => true, 'dados' => $payload]);
    }
}
