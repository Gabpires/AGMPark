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
        'status',
        'data_cadastro',
        'ultimo_login'
    ];

    public function inserir(array $data)
    {
        return $this->insert($data);
    }

    public function listar($filtros = [])
{
    $builder = $this;

    if (!empty($filtros['nome'])) {
        $builder = $builder->like('primeiro_nome', $filtros['nome']);
    }

    if (!empty($filtros['cpfCnpj'])) {
        $builder = $builder->where('cpf_cnpj', $filtros['cpfCnpj']);
    }

    if (!empty($filtros['email'])) {
        $builder = $builder->where('email', $filtros['email']);
    }

    if (!empty($filtros['dataNasc'])) {
        $builder = $builder->where('data_nascimento', $filtros['dataNasc']);
    }

    if (!empty($filtros['telefone'])) {
        $builder = $builder->where('telefone', $filtros['telefone']);
    }

    if (!empty($filtros['tipo'])) {
        $builder = $builder->where('tipo_usuario', $filtros['tipo']);
    }

    if (!empty($filtros['status'])) {
        $builder = $builder->where('status', $filtros['status']);
    }

    return $builder->findAll();
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