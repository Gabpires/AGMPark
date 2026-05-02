<?php

namespace App\Models;

use CodeIgniter\Model; 

class EstadiaModel extends Model
{
    protected $table = 'estadias';
    protected $primaryKey = 'id_estadia';

    protected $allowedFields = [
    'id_veiculo',
    'id_vaga',
    'id_reserva',
    'data_entrada',
    'data_saida',
    'valor_total',
    'status'
];

    protected $returnType = 'array';

        public function inserir(array $data) {
            return $this->insert($data);
        }

        public function listar($filtros = [])
        {
            $builder = $this;

            if (!empty($filtros['id_estadia'])) {
                $builder = $builder->where('id_estadia', $filtros['id_estadia']);
            }

            if (!empty($filtros['id_veiculo'])) {
                $builder = $builder->where('id_veiculo', $filtros['id_veiculo']);
            }

            if (!empty($filtros['id_vaga'])) {
                $builder = $builder->where('id_vaga', $filtros['id_vaga']);
            }

            if (!empty($filtros['data_hora_entrada'])) {
                $builder = $builder->where('data_hora_entrada', $filtros['data_hora_entrada']);
            }

            if (!empty($filtros['data_hora_saida'])) {
                $builder = $builder->where('data_hora_saida', $filtros['data_hora_saida']);
            }

            return $builder->findAll();
        }

}