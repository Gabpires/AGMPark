<?php

namespace App\Models;

use CodeIgniter\Model;

class EstacionamentoModel extends Model
{
    protected $table = 'estacionamento';
    protected $primaryKey = 'id_estacionamento';

    protected $allowedFields = [
        'nome',
        'rua',
        'bairro',
        'cidade',
        'estado',
        'numero_estacionamento',
        'cep',
        'quantidade_tempo',
        'valor_tempo',
        'numero_vagas',
        'status'
    ];


///////////////////////////////////////

    public function inserir(array $data) {
        return $this->insert($data);
    }


    public function listar($filtros = [])
    {
        $builder = $this;

        if (!empty($filtros['id_estacionamento'])) {
            $builder = $builder->where('id_estacionamento', $filtros['id_estacionamento']);
        }

        if (!empty($filtros['status'])) {
            $builder = $builder->where('status', $filtros['status']);
        }

        return $builder->findAll();
    }



    public function atualizar($id, $dados)
    {
    $registro = $this->find($id);

    if (!$registro) {
        return false;
    }

    if ($registro['status'] === 'INATIVO') {
        return false;
    }

    return $this->update($id, $dados);
    }

    public function deletar($id)
{
    $registro = $this->find($id);

    if (!$registro) {
        return [
            'sucesso' => false,
            'msg' => 'Registro não encontrado'
        ];
    }

    if ($registro['status'] === 'INATIVO') {
        return [
            'sucesso' => false,
            'msg' => 'Já está inativo'
        ];
    }

    if ($this->update($id, ['status' => 'INATIVO'])) {
        return [
            'sucesso' => true
        ];
    }

    return [
        'sucesso' => false,
        'msg' => 'Erro ao atualizar'
    ];
}
}

