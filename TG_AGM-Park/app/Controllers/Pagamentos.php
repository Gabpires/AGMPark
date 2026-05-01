<?php

namespace App\Controllers;

use App\Models\PagamentoModel;
use App\Models\EstadiaModel;

use Exception;

class Pagamentos extends BaseController
{

  public function inserir()
{
    helper('helper');

    try {
        $resultado = $this->request->getJSON();

        if (!$resultado) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [['codigo' => 400, 'msg' => 'JSON inválido ou vazio']]
            ]);
        }

        $erros = [];

        $validacoes = [
            ['ret' => validarDados($resultado->id_estadia ?? null, 'int', true), 'campo' => 'id_estadia'],
            ['ret' => validarDados($resultado->valor ?? null, 'float', true), 'campo' => 'valor'],
            ['ret' => validarDados($resultado->taxa_app ?? 0, 'float', false), 'campo' => 'taxa_app'],
            ['ret' => validarDados($resultado->forma_pagamento ?? null, 'string', true), 'campo' => 'forma_pagamento']
        ];

        foreach ($validacoes as $v) {
            if ($v['ret']['codigoHelper'] != 0) {
                $erros[] = [
                    'codigo' => $v['ret']['codigoHelper'],
                    'campo' => $v['campo'],
                    'msg' => $v['ret']['msg']
                ];
            }
        }

        if (!empty($erros)) {
            return $this->response->setJSON(['sucesso' => false, 'erros' => $erros]);
        }

        $pagamentoModel = new \App\Models\PagamentoModel();
        $estadiaModel = new \App\Models\EstadiaModel();

        $estadia = $estadiaModel->find($resultado->id_estadia);

        if (!$estadia) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [['codigo' => 404, 'campo' => 'id_estadia', 'msg' => 'Estadia não encontrada']]
            ]);
        }

        if ($estadia['status'] !== 'FINALIZADA') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [['codigo' => 60, 'campo' => 'id_estadia', 'msg' => 'Só é possível pagar uma estadia finalizada']]
            ]);
        }

        $pagamentoExistente = $pagamentoModel
            ->where('id_estadia', $resultado->id_estadia)
            ->where('status', 'PAGO')
            ->first();

        if ($pagamentoExistente) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [['codigo' => 61, 'campo' => 'id_estadia', 'msg' => 'Esta estadia já possui pagamento ativo']]
            ]);
        }

        $formasPermitidas = ['DINHEIRO', 'PIX', 'CARTAO', 'DEBITO', 'CREDITO'];

        if (!in_array(strtoupper($resultado->forma_pagamento), $formasPermitidas)) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [['codigo' => 62, 'campo' => 'forma_pagamento', 'msg' => 'Forma de pagamento inválida']]
            ]);
        }

        $dados = [
            'id_estadia' => $resultado->id_estadia,
            'valor' => $resultado->valor,
            'taxa_app' => $resultado->taxa_app ?? 0.00,
            'forma_pagamento' => strtoupper($resultado->forma_pagamento),
            'status' => 'PAGO'
        ];

        if ($pagamentoModel->insert($dados)) {
            return $this->response->setJSON([
                'sucesso' => true,
                'msg' => 'Pagamento registrado com sucesso'
            ]);
        }

        return $this->response->setJSON([
            'sucesso' => false,
            'erros' => [['codigo' => 500, 'msg' => 'Erro ao registrar pagamento', 'detalhes' => $pagamentoModel->errors()]]
        ]);

    } catch (Exception $e) {
        return $this->response->setJSON([
            'sucesso' => false,
            'erros' => [['codigo' => 0, 'msg' => 'Erro: ' . $e->getMessage()]]
        ]);
    }
}

  

    public function listar()
{
    helper('helper');

    try {
        $model = new \App\Models\PagamentoModel();

        $dados = $model
            ->select('
                pagamentos.id_pagamento,
                pagamentos.id_estadia,
                pagamentos.valor,
                pagamentos.taxa_app,
                pagamentos.forma_pagamento,
                pagamentos.data_pagamento,
                pagamentos.status,

                estadias.id_veiculo,
                estadias.id_vaga,
                estadias.data_entrada,
                estadias.data_saida,
                estadias.valor_total,
                estadias.status AS status_estadia,

                veiculos.modelo,
                veiculos.marca,
                veiculos.placa,

                vagas.numero_vaga
            ')
            ->join('estadias', 'estadias.id_estadia = pagamentos.id_estadia')
            ->join('veiculos', 'veiculos.id_veiculo = estadias.id_veiculo')
            ->join('vagas', 'vagas.id_vaga = estadias.id_vaga')
            ->orderBy('pagamentos.id_pagamento', 'DESC')
            ->findAll();

        if (!$dados) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [['codigo' => 404, 'msg' => 'Nenhum pagamento encontrado']]
            ]);
        }

        return $this->response->setJSON([
            'sucesso' => true,
            'total' => count($dados),
            'dados' => $dados
        ]);

    } catch (Exception $e) {
        return $this->response->setJSON([
            'sucesso' => false,
            'erros' => [['codigo' => 0, 'msg' => 'Erro: ' . $e->getMessage()]]
        ]);
    }
}


   public function atualizar($id)
{
    helper('helper');

    try {
        $resultado = $this->request->getJSON();

        if (!$resultado) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [['codigo' => 400, 'msg' => 'JSON inválido ou vazio']]
            ]);
        }

        $erros = [];

        $validacoes = [
            ['ret' => validarDados($id, 'int', true), 'campo' => 'id_pagamento'],
            ['ret' => validarDados($resultado->id_estadia ?? null, 'int', true), 'campo' => 'id_estadia'],
            ['ret' => validarDados($resultado->valor ?? null, 'float', true), 'campo' => 'valor'],
            ['ret' => validarDados($resultado->taxa_app ?? 0, 'float', false), 'campo' => 'taxa_app'],
            ['ret' => validarDados($resultado->forma_pagamento ?? null, 'string', true), 'campo' => 'forma_pagamento']
        ];

        foreach ($validacoes as $v) {
            if ($v['ret']['codigoHelper'] != 0) {
                $erros[] = [
                    'codigo' => $v['ret']['codigoHelper'],
                    'campo' => $v['campo'],
                    'msg' => $v['ret']['msg']
                ];
            }
        }

        if (!empty($erros)) {
            return $this->response->setJSON(['sucesso' => false, 'erros' => $erros]);
        }

        $pagamentoModel = new \App\Models\PagamentoModel();
        $estadiaModel = new \App\Models\EstadiaModel();

        $pagamento = $pagamentoModel->find($id);

        if (!$pagamento) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [['codigo' => 404, 'campo' => 'id_pagamento', 'msg' => 'Pagamento não encontrado']]
            ]);
        }

        if ($pagamento['status'] === 'CANCELADO') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [['codigo' => 63, 'campo' => 'status', 'msg' => 'Pagamento cancelado não pode ser alterado']]
            ]);
        }

        $estadia = $estadiaModel->find($resultado->id_estadia);

        if (!$estadia) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [['codigo' => 404, 'campo' => 'id_estadia', 'msg' => 'Estadia não encontrada']]
            ]);
        }

        if ($estadia['status'] !== 'FINALIZADA') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [['codigo' => 60, 'campo' => 'id_estadia', 'msg' => 'Só é possível atualizar pagamento de estadia finalizada']]
            ]);
        }

        $pagamentoExistente = $pagamentoModel
            ->where('id_estadia', $resultado->id_estadia)
            ->where('status', 'PAGO')
            ->where('id_pagamento !=', $id)
            ->first();

        if ($pagamentoExistente) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [['codigo' => 61, 'campo' => 'id_estadia', 'msg' => 'Esta estadia já possui outro pagamento ativo']]
            ]);
        }

        $formasPermitidas = ['DINHEIRO', 'PIX', 'CARTAO', 'DEBITO', 'CREDITO'];

        if (!in_array(strtoupper($resultado->forma_pagamento), $formasPermitidas)) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [['codigo' => 62, 'campo' => 'forma_pagamento', 'msg' => 'Forma de pagamento inválida']]
            ]);
        }

        $dados = [
            'id_estadia' => $resultado->id_estadia,
            'valor' => $resultado->valor,
            'taxa_app' => $resultado->taxa_app ?? 0.00,
            'forma_pagamento' => strtoupper($resultado->forma_pagamento),
            'status' => 'PAGO'
        ];

        if ($pagamentoModel->update($id, $dados)) {
            return $this->response->setJSON([
                'sucesso' => true,
                'msg' => 'Pagamento atualizado com sucesso'
            ]);
        }

        return $this->response->setJSON([
            'sucesso' => false,
            'erros' => [['codigo' => 500, 'msg' => 'Erro ao atualizar pagamento', 'detalhes' => $pagamentoModel->errors()]]
        ]);

    } catch (Exception $e) {
        return $this->response->setJSON([
            'sucesso' => false,
            'erros' => [['codigo' => 0, 'msg' => 'Erro: ' . $e->getMessage()]]
        ]);
    }
}



   public function deletar($id)
{
    helper('helper');

    try {
        $retId = validarDados($id, 'int', true);

        if ($retId['codigoHelper'] != 0) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => $retId['codigoHelper'],
                    'campo' => 'id_pagamento',
                    'msg' => $retId['msg']
                ]]
            ]);
        }

        $pagamentoModel = new \App\Models\PagamentoModel();

        $pagamento = $pagamentoModel->find($id);

        if (!$pagamento) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [['codigo' => 404, 'msg' => 'Pagamento não encontrado']]
            ]);
        }

        if ($pagamento['status'] === 'CANCELADO') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [['codigo' => 64, 'msg' => 'Pagamento já está cancelado']]
            ]);
        }

        if ($pagamentoModel->update($id, ['status' => 'CANCELADO'])) {
            return $this->response->setJSON([
                'sucesso' => true,
                'msg' => 'Pagamento cancelado com sucesso'
            ]);
        }

        return $this->response->setJSON([
            'sucesso' => false,
            'erros' => [['codigo' => 500, 'msg' => 'Erro ao cancelar pagamento', 'detalhes' => $pagamentoModel->errors()]]
        ]);

    } catch (Exception $e) {
        return $this->response->setJSON([
            'sucesso' => false,
            'erros' => [['codigo' => 0, 'msg' => 'Erro: ' . $e->getMessage()]]
        ]);
    }
}


}