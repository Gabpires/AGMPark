<?php

namespace App\Models;

use CodeIgniter\Model;




class VagaModel extends Model
{
    protected $table = 'vagas';
    protected $primaryKey = 'id_vaga';

    protected $allowedFields = [
        'id_estacionamento',
        'numero_vaga',
        'status',
        'status_fisico'
    ];

    protected $returnType = 'array';

        public function inserir(array $data) {
            return $this->insert($data);
        }

        public function listar($filtros = [])
        {
            $builder = $this;

            if (!empty($filtros['id_vaga'])) {
                $builder = $builder->where('id_vaga', $filtros['id_vaga']);
            }

            if (!empty($filtros['id_estacionamento'])) {
                $builder = $builder->where('id_estacionamento', $filtros['id_estacionamento']);
            }

            if (!empty($filtros['numero_vagas'])) {
                $builder = $builder->where('numero_vagas', $filtros['numero_vagas']);
            }

            if (!empty($filtros['status'])) {
                $builder = $builder->where('status', $filtros['status']);
            }

            return $builder->findAll();
        }


        function atualizar($id, $dados)
        {
            $registro = $this->find($id);

            if (!$registro) {
                return false;
            }

            return $this->update($id, $dados);
        }

        function atualizarStatusFisico($id, $status)
        {
            $registro = $this->find($id);

            if (!$registro) {
                return false;
            }

            return $this->update($id, ['status' => $status]);
        }


        function deletar($id)
        {
            $registro = $this->find($id);

            if (!$registro) {
                return false;
            }

            return $this->delete($id);

}
}