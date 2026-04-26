<?php

namespace App\Models;

use CodeIgniter\Model;

class ReservaModel extends Model
{
    protected $table = 'reservas';
    protected $primaryKey = 'id_reserva';

   protected $allowedFields = [
    'id_veiculo',
    'id_estacionamento',
    'id_vaga',
    'data_reserva',
    'data_expiracao',
    'data_cancelamento',
    'valor',
    'status'
];

    protected $returnType = 'array';

    public function inserir(array $data)
    {
        return $this->insert($data);
    }



    function listar($filtros = [])
    {
        $builder = $this;

        if (!empty($filtros['id_reserva'])) {
            $builder = $builder->where('id_reserva', $filtros['id_reserva']);
        }

        if (!empty($filtros['id_veiculo'])) {
            $builder = $builder->where('id_veiculo', $filtros['id_veiculo']);
        }

        if (!empty($filtros['id_estacionamento'])) {
            $builder = $builder->where('id_estacionamento', $filtros['id_estacionamento']);
        }

        if (!empty($filtros['status'])) {
            $builder = $builder->where('status', $filtros['status']);
        }

        return $builder->findAll();
    }



    function atualizar($id_reserva, array $data)
    {
        return $this->update($id_reserva, $data);
    }

    
    function deletar ($id_reserva)
    {
        return $this->delete($id_reserva);
    }

}