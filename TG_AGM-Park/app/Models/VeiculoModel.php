<?php

namespace App\Models;

use CodeIgniter\Model;

class VeiculoModel extends Model
{
    protected $table = 'veiculos';
    protected $primaryKey = 'id_veiculo';

    protected $allowedFields = [
        'modelo',
        'placa',
        'status'
    ];

   public function inserir(array $data) {
        return $this->insert($data);
    }

    public function listar($filtros = [])
    {
        $builder = $this;

        if (!empty($filtros['id_veiculo'])) {
            $builder = $builder->where('id_veiculo', $filtros['id_veiculo']);
        }

        

        return $builder->findAll();
    }

    public function atualizar($id, $dados)
    {
        $registro = $this->find($id);

        if (!$registro) {
            return false;
        }

        return $this->update($id, $dados);
    }

    public function deletar($id)
    {
        $registro = $this->find($id);

        if (!$registro) {
            return false;
        }

        return $this->delete($id);
    }
}