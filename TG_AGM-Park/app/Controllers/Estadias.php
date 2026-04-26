<?php

namespace App\Controllers;

use App\Models\EstadiaModel;
use App\Models\VeiculoModel;
use App\Models\VagaModel;

use Exception;

class Estadias extends BaseController
{

public function inserir()
{
    helper('helper');

    $erros = [];
    $sucesso = false;

    try {
        $resultado = $this->request->getJSON();

        if (!$resultado) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 400,
                    'msg' => 'JSON inválido ou vazio'
                ]]
            ]);
        }

        // Validações básicas
        $retIdVeiculo = validarDados($resultado->id_veiculo ?? null, 'int', true);
        $retIdVaga = validarDados($resultado->id_vaga ?? null, 'int', true);

        $validacoes = [
            ['ret' => $retIdVeiculo, 'campo' => 'id_veiculo'],
            ['ret' => $retIdVaga, 'campo' => 'id_vaga']
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
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => $erros
            ]);
        }

        $estadiaModel = new EstadiaModel();
        $veiculoModel = new VeiculoModel();
        $vagaModel = new VagaModel();

        // Verifica veículo
        $veiculo = $veiculoModel->find($resultado->id_veiculo);

        if (!$veiculo) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'msg' => 'Veículo não encontrado'
                ]]
            ]);
        }

        if ($veiculo['status'] !== 'ATIVO') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 42,
                    'msg' => 'Veículo inativo'
                ]]
            ]);
        }

        // Verifica vaga
        $vaga = $vagaModel->find($resultado->id_vaga);

        if (!$vaga) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'msg' => 'Vaga não encontrada'
                ]]
            ]);
        }

        if ($vaga['status'] !== 'LIVRE') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 60,
                    'msg' => 'Vaga não está livre'
                ]]
            ]);
        }

        // Verifica se o veículo já tem estadia em andamento
        $estadiaAberta = $estadiaModel
            ->where('id_veiculo', $resultado->id_veiculo)
            ->where('status', 'EM_ANDAMENTO')
            ->first();

        if ($estadiaAberta) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 61,
                    'msg' => 'Veículo já possui estadia em andamento'
                ]]
            ]);
        }

        // Insere estadia
        $dados = [
            'id_veiculo' => $resultado->id_veiculo,
            'id_vaga' => $resultado->id_vaga,
            'id_reserva' => $resultado->id_reserva ?? null,
            'data_entrada' => date('Y-m-d H:i:s'),
            'data_saida' => null,
            'valor_total' => 0.00,
            'status' => 'EM_ANDAMENTO'
        ];

        if ($estadiaModel->insert($dados)) {

            // Atualiza vaga para OCUPADA
            $vagaModel->update($resultado->id_vaga, [
                'status' => 'OCUPADA'
            ]);

            $sucesso = true;

        } else {
            $erros[] = [
                'codigo' => 500,
                'msg' => 'Erro ao iniciar estadia',
                'detalhes' => $estadiaModel->errors()
            ];
        }

    } catch (Exception $e) {
        return $this->response->setJSON([
            'sucesso' => false,
            'erros' => [[
                'codigo' => 0,
                'msg' => 'Erro: ' . $e->getMessage()
            ]]
        ]);
    }

    return $this->response->setJSON([
        'sucesso' => $sucesso,
        'msg' => $sucesso ? 'Estadia iniciada com sucesso' : null,
        'erros' => $sucesso ? [] : $erros
    ]);
}



public function listar()
{
    helper('helper');

    try {
        $model = new \App\Models\EstadiaModel();

        $dados = $model
            ->select('
                estadias.id_estadia,
                estadias.id_veiculo,
                estadias.id_vaga,
                estadias.id_reserva,
                estadias.data_entrada,
                estadias.data_saida,
                estadias.valor_total,
                estadias.status,

                veiculos.modelo,
                veiculos.marca,
                veiculos.placa,

                vagas.numero_vaga,
                vagas.status AS status_vaga,

                estacionamento.id_estacionamento,
                estacionamento.nome AS nome_estacionamento
            ')
            ->join('veiculos', 'veiculos.id_veiculo = estadias.id_veiculo')
            ->join('vagas', 'vagas.id_vaga = estadias.id_vaga')
            ->join('estacionamento', 'estacionamento.id_estacionamento = vagas.id_estacionamento')
            ->orderBy('estadias.id_estadia', 'DESC')
            ->findAll();

        if (!$dados) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'msg' => 'Nenhuma estadia encontrada'
                ]]
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
            'erros' => [[
                'codigo' => 0,
                'msg' => 'Erro: ' . $e->getMessage()
            ]]
        ]);
    }
}


  public function atualizar($id)
{
    helper('helper');

    $erros = [];
    $sucesso = false;

    try {

        $resultado = $this->request->getJSON();

        if (!$resultado) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 400,
                    'msg' => 'JSON inválido ou vazio'
                ]]
            ]);
        }

        // =============================
        // VALIDAÇÕES BÁSICAS
        // =============================
        $retId = validarDados($id, 'int', true);
        $retIdVeiculo = validarDados($resultado->id_veiculo ?? null, 'int', true);
        $retIdVaga = validarDados($resultado->id_vaga ?? null, 'int', true);
        $retDataEntrada = validarDados($resultado->data_entrada ?? null, 'datetime', true);
        $retDataSaida = validarDados($resultado->data_saida ?? null, 'datetime', false);
        $retValor = validarDados($resultado->valor_total ?? null, 'float', false);

        $validacoes = [
            ['ret' => $retId, 'campo' => 'id_estadia'],
            ['ret' => $retIdVeiculo, 'campo' => 'id_veiculo'],
            ['ret' => $retIdVaga, 'campo' => 'id_vaga'],
            ['ret' => $retDataEntrada, 'campo' => 'data_entrada'],
            ['ret' => $retDataSaida, 'campo' => 'data_saida'],
            ['ret' => $retValor, 'campo' => 'valor_total']
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
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => $erros
            ]);
        }

        // =============================
        // MODELS
        // =============================
        $estadiaModel = new \App\Models\EstadiaModel();
        $veiculoModel = new \App\Models\VeiculoModel();
        $vagaModel = new \App\Models\VagaModel();

        $estadia = $estadiaModel->find($id);

        if (!$estadia) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'msg' => 'Estadia não encontrada'
                ]]
            ]);
        }

        // =============================
        // NÃO PERMITE ALTERAR FINALIZADA
        // =============================
        if ($estadia['status'] === 'FINALIZADA') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 70,
                    'msg' => 'Estadia finalizada não pode ser alterada'
                ]]
            ]);
        }

        // =============================
        // VALIDA VEÍCULO
        // =============================
        $veiculo = $veiculoModel->find($resultado->id_veiculo);

        if (!$veiculo) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'msg' => 'Veículo não encontrado'
                ]]
            ]);
        }

        if ($veiculo['status'] !== 'ATIVO') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 42,
                    'msg' => 'Veículo inativo'
                ]]
            ]);
        }

        // =============================
        // VALIDA VAGA
        // =============================
        $vaga = $vagaModel->find($resultado->id_vaga);

        if (!$vaga) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'msg' => 'Vaga não encontrada'
                ]]
            ]);
        }

        // =============================
        // ALTERAÇÃO DE VAGA
        // =============================
        if ($estadia['id_vaga'] != $resultado->id_vaga) {

            // libera antiga
            if (!empty($estadia['id_vaga'])) {
                $vagaModel->update($estadia['id_vaga'], [
                    'status' => 'LIVRE'
                ]);
            }

            // nova vaga deve estar livre
            if ($vaga['status'] !== 'LIVRE') {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [[
                        'codigo' => 71,
                        'msg' => 'Nova vaga não está disponível'
                    ]]
                ]);
            }

            // ocupa nova
            $vagaModel->update($resultado->id_vaga, [
                'status' => 'OCUPADA'
            ]);
        }

        // =============================
        // FINALIZAÇÃO AUTOMÁTICA
        // =============================
        $status = 'EM_ANDAMENTO';

        if (!empty($resultado->data_saida)) {
            $status = 'FINALIZADA';

            // libera vaga
            $vagaModel->update($resultado->id_vaga, [
                'status' => 'LIVRE'
            ]);
        }

        // =============================
        // UPDATE
        // =============================
        $dados = [
            'id_veiculo' => $resultado->id_veiculo,
            'id_vaga' => $resultado->id_vaga,
            'data_entrada' => $resultado->data_entrada,
            'data_saida' => $resultado->data_saida,
            'valor_total' => $resultado->valor_total,
            'status' => $status
        ];

        if ($estadiaModel->update($id, $dados)) {
            $sucesso = true;
        } else {
            $erros[] = [
                'codigo' => 500,
                'msg' => 'Erro ao atualizar estadia',
                'detalhes' => $estadiaModel->errors()
            ];
        }

    } catch (Exception $e) {
        return $this->response->setJSON([
            'sucesso' => false,
            'erros' => [[
                'codigo' => 0,
                'msg' => $e->getMessage()
            ]]
        ]);
    }

    return $this->response->setJSON([
        'sucesso' => $sucesso,
        'msg' => $sucesso ? 'Estadia atualizada com sucesso' : null,
        'erros' => $sucesso ? [] : $erros
    ]);
}

public function deletar($id)
{
    helper('helper');

    $erros = [];
    $sucesso = false;

    try {
        $retId = validarDados($id, 'int', true);

        if ($retId['codigoHelper'] != 0) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => $retId['codigoHelper'],
                    'campo' => 'id_estadia',
                    'msg' => $retId['msg']
                ]]
            ]);
        }

        $estadiaModel = new \App\Models\EstadiaModel();
        $vagaModel = new \App\Models\VagaModel();

        $estadia = $estadiaModel->find($id);

        if (!$estadia) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'msg' => 'Estadia não encontrada'
                ]]
            ]);
        }

        if ($estadia['status'] === 'CANCELADA') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 72,
                    'msg' => 'Estadia já está cancelada'
                ]]
            ]);
        }

        if ($estadia['status'] === 'FINALIZADA') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 73,
                    'msg' => 'Estadia finalizada não pode ser cancelada'
                ]]
            ]);
        }

        if (!empty($estadia['id_vaga'])) {
            $vagaModel->update($estadia['id_vaga'], [
                'status' => 'LIVRE'
            ]);
        }

        $dados = [
            'status' => 'CANCELADA',
            'data_saida' => date('Y-m-d H:i:s')
        ];

        if ($estadiaModel->update($id, $dados)) {
            $sucesso = true;
        } else {
            $erros[] = [
                'codigo' => 500,
                'msg' => 'Erro ao cancelar estadia',
                'detalhes' => $estadiaModel->errors()
            ];
        }

    } catch (Exception $e) {
        return $this->response->setJSON([
            'sucesso' => false,
            'erros' => [[
                'codigo' => 0,
                'msg' => 'Erro: ' . $e->getMessage()
            ]]
        ]);
    }

    return $this->response->setJSON([
        'sucesso' => $sucesso,
        'msg' => $sucesso ? 'Estadia cancelada com sucesso' : null,
        'erros' => $sucesso ? [] : $erros
    ]);
}



}






