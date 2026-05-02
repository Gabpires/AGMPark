<?php

namespace App\Models;
use CodeIgniter\Model;

class TarifaModel extends Model
{

    protected $table = 'tarifas';
    protected $primaryKey = 'id';

    protected $allowedFields = [
    'id_estacionamento',
    'tempo',  
    'unidade',
    'valor',
    'status'
];

    function inserir(array $data) {
        return $this->insert($data);
    }

    function listar($filtros = [])
    {
        $builder = $this;

        if (!empty($filtros['id'])) {
            $builder = $builder->where('id', $filtros['id']);
        }

        if (!empty($filtros['id_estacionamento'])) {
            $builder = $builder->where('id_estacionamento', $filtros['id_estacionamento']);
        }

        return $builder->findAll();
    }

    function atualizar($id, array $data) {
        return $this->update($id, $data);
    }

    function deletar($id) {
        return $this->delete($id);
    }




}