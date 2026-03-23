<?php

namespace App\Models;

use CodeIgniter\Model;

class UsuarioModel extends Model
{
    protected $table = 'funcionario';
    protected $primaryKey = 'id_funcionario';

    protected $allowedFields = [
        'primeiro_nome',
        'cpf_cnpj',
        'email',
        'data_nascimento',
        'telefone',
        'senha',
        'tipo_usuario',
        'istatus',
        'data_cadastro',
        'ultimo_login'
    ];

    public function inserir(array $data)
    {
        return $this->insert($data);
    }

    public function listar()
    {
        return $this->findAll();
    }

    public function buscarPorId($id)
    {
        return $this->where('id_funcionario', $id)->first();
    }

    public function atualizarUsuario($id, array $data)
    {
        return $this->update($id, $data);
    }

    public function deletarUsuario($id)
    {
        return $this->delete($id);
    }
}