<?php


namespace App\Models;
use CodeIgniter\Model;

class PagamentoModel extends Model
{ 

    protected $table = 'pagamentos';
    protected $primaryKey = 'id_pagamento';


   protected $allowedFields = [
    'id_estadia',
    'valor',
    'taxa_app',
    'forma_pagamento',
    'data_pagamento',
    'status'
];

    function inserir(array $data) {
        return $this->insert($data);
    }

    function listar($filtros = [])
    {
        $builder = $this;

        if (!empty($filtros['id_pagamento'])) {
            $builder = $builder->where('id_pagamento', $filtros['id_pagamento']);
        }

        if (!empty($filtros['id_estadia'])) {
            $builder = $builder->where('id_estadia', $filtros['id_estadia']);
        }

        if (!empty($filtros['data_pagamento'])) {
            $builder = $builder->where('data_pagamento', $filtros['data_pagamento']);
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