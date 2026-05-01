<?php

namespace App\Models;
use CodeIgniter\Model;

class HorarioFuncionamentoModel extends Model
{

    protected $table = 'horarios_funcionamento';
    protected $primaryKey = 'id';

     protected $allowedFields = [
    'id_estacionamento',
    'dia_semana',
    'hora_abertura',
    'hora_fechamento',
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

        if (!empty($filtros['dia_semana'])) {
            $builder = $builder->where('dia_semana', $filtros['dia_semana']);
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