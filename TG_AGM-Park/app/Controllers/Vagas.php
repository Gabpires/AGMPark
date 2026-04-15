<?php

namespace App\Controllers;

use App\Models\VagaModel;
use App\Models\VeiculoModel;
use App\Models\EstacionamentoModel;
use Exception;

class vagas extends BaseController
{
    public function inserir()
    {
        helper('helper');

        $erros = [];
        $sucesso = false;

        try {
            $resultado = $this->request->getJSON();

            // JSON inválido
            if (!$resultado) {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [[
                        'codigo' => 400,
                        'msg' => 'JSON inválido ou vazio'
                    ]]
                ]);
            }

            // VALIDA CAMPOS
            $retIdVeiculo = validarDados($resultado->id_veiculo ?? null, 'int', true);
            $retIdEstacionamento = validarDados($resultado->id_estacionamento ?? null, 'int', true);

            if ($retIdVeiculo['codigoHelper'] != 0) {
                $erros[] = ['campo' => 'id_veiculo', 'msg' => $retIdVeiculo['msg']];
            }

            if ($retIdEstacionamento['codigoHelper'] != 0) {
                $erros[] = ['campo' => 'id_estacionamento', 'msg' => $retIdEstacionamento['msg']];
            }

            if (!empty($erros)) {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => $erros
                ]);
            }

            // MODELS
            $vagaModel = new VagaModel();
            $veiculoModel = new VeiculoModel();
            $estacionamentoModel = new EstacionamentoModel();

            // VALIDA VEÍCULO
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
                        'msg' => 'Veículo está inativo'
                    ]]
                ]);
            }

            // VALIDA ESTACIONAMENTO
            $estacionamento = $estacionamentoModel->find($resultado->id_estacionamento);

            if (!$estacionamento) {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [[
                        'codigo' => 404,
                        'msg' => 'Estacionamento não encontrado'
                    ]]
                ]);
            }

            if ($estacionamento['status'] !== 'ATIVO') {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [[
                        'codigo' => 43,
                        'msg' => 'Estacionamento está inativo'
                    ]]
                ]);
            }

            // VEÍCULO JÁ OCUPADO
            $ocupado = $vagaModel
                ->where('id_veiculo', $resultado->id_veiculo)
                ->where('status', 'OCUPADA')
                ->first();

            if ($ocupado) {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [[
                        'codigo' => 41,
                        'msg' => 'Veículo já está ocupando uma vaga'
                    ]]
                ]);
            }

            // PROCURA VAGA LIVRE
            $vagaLivre = $vagaModel
                ->where('id_estacionamento', $resultado->id_estacionamento)
                ->where('status', 'LIVRE')
                ->first();

            if ($vagaLivre) {

                // REUTILIZA VAGA
                $res = $vagaModel->update($vagaLivre['id_vaga'], [
                    'id_veiculo' => $resultado->id_veiculo,
                    'status' => 'OCUPADA'
                ]);
            } else {

                // CONTA TOTAL DE VAGAS DO ESTACIONAMENTO
                $total = $vagaModel
                    ->where('id_estacionamento', $resultado->id_estacionamento)
                    ->countAllResults();

                // LIMITE ATINGIDO
                if ($total >= $estacionamento['numero_vagas']) {
                    return $this->response->setJSON([
                        'sucesso' => false,
                        'erros' => [[
                            'codigo' => 45,
                            'msg' => 'Limite de vagas atingido'
                        ]]
                    ]);
                }

                // CRIA NOVA VAGA
                $res = $vagaModel->insert([
                    'id_veiculo' => $resultado->id_veiculo,
                    'id_estacionamento' => $resultado->id_estacionamento,
                    'status' => 'OCUPADA'
                ]);
            }

            if ($res) {
                $sucesso = true;
            } else {
                $erros[] = [
                    'codigo' => 500,
                    'msg' => 'Erro ao salvar vaga',
                    'detalhes' => $vagaModel->errors()
                ];
            }
        } catch (\Exception $e) {
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
            'msg' => $sucesso ? 'Vaga ocupada com sucesso' : null,
            'erros' => $sucesso ? [] : $erros
        ]);
    }



    public function listar()
    {
        try {
            $model = new \App\Models\VagaModel();
            $dados = $model->findAll();

            return $this->response->setJSON([
                'sucesso' => true,
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

            // JSON inválido
            if (!$resultado) {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [[
                        'codigo' => 400,
                        'msg' => 'JSON inválido ou vazio'
                    ]]
                ]);
            }

            // VALIDA ID
            $retId = validarDados($id, 'int', true);
            if ($retId['codigoHelper'] != 0) {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [[
                        'codigo' => $retId['codigoHelper'],
                        'campo' => 'id_vaga',
                        'msg' => $retId['msg']
                    ]]
                ]);
            }

            // VALIDA CAMPOS
            $retIdVeiculo = validarDados($resultado->id_veiculo ?? null, 'int', true);
            $retIdEstacionamento = validarDados($resultado->id_estacionamento ?? null, 'int', true);

            if ($retIdVeiculo['codigoHelper'] != 0) {
                $erros[] = ['campo' => 'id_veiculo', 'msg' => $retIdVeiculo['msg']];
            }

            if ($retIdEstacionamento['codigoHelper'] != 0) {
                $erros[] = ['campo' => 'id_estacionamento', 'msg' => $retIdEstacionamento['msg']];
            }

            if (!empty($erros)) {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => $erros
                ]);
            }

            // MODELS
            $vagaModel = new VagaModel();
            $veiculoModel = new VeiculoModel();
            $estacionamentoModel = new EstacionamentoModel();

            // 🔍 VAGA EXISTE?
            $vaga = $vagaModel->find($id);

            if (!$vaga) {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [[
                        'codigo' => 404,
                        'msg' => 'Vaga não encontrada'
                    ]]
                ]);
            }

            // VALIDA VEÍCULO
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
                        'msg' => 'Veículo está inativo'
                    ]]
                ]);
            }

            // VALIDA ESTACIONAMENTO
            $estacionamento = $estacionamentoModel->find($resultado->id_estacionamento);

            if (!$estacionamento) {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [[
                        'codigo' => 404,
                        'msg' => 'Estacionamento não encontrado'
                    ]]
                ]);
            }

            if ($estacionamento['status'] !== 'ATIVO') {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [[
                        'codigo' => 43,
                        'msg' => 'Estacionamento está inativo'
                    ]]
                ]);
            }

            // VEÍCULO JÁ OCUPA OUTRA VAGA
            $ocupado = $vagaModel
                ->where('id_veiculo', $resultado->id_veiculo)
                ->where('status', 'OCUPADA')
                ->where('id_vaga !=', $id)
                ->first();

            if ($ocupado) {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [[
                        'codigo' => 41,
                        'msg' => 'Veículo já está ocupando outra vaga'
                    ]]
                ]);
            }

            // CONTROLE DE LIMITE (caso troque de estacionamento)
            if ($vaga['id_estacionamento'] != $resultado->id_estacionamento) {

                $total = $vagaModel
                    ->where('id_estacionamento', $resultado->id_estacionamento)
                    ->where('status', 'OCUPADA')
                    ->countAllResults();

                if ($total >= $estacionamento['numero_vagas']) {
                    return $this->response->setJSON([
                        'sucesso' => false,
                        'erros' => [[
                            'codigo' => 45,
                            'msg' => 'Limite de vagas atingido'
                        ]]
                    ]);
                }
            }

            // ATUALIZA VAGA
            $res = $vagaModel->update($id, [
                'id_veiculo' => $resultado->id_veiculo,
                'id_estacionamento' => $resultado->id_estacionamento,
                'status' => 'OCUPADA'
            ]);

            if ($res) {
                $sucesso = true;
            } else {
                $erros[] = [
                    'codigo' => 500,
                    'msg' => 'Erro ao atualizar vaga',
                    'detalhes' => $vagaModel->errors()
                ];
            }
        } catch (\Exception $e) {
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
            'msg' => $sucesso ? 'Vaga atualizada com sucesso' : null,
            'erros' => $sucesso ? [] : $erros
        ]);
    }


    public function deletar($id)
    {
        helper('helper');

        $erros = [];
        $sucesso = false;

        try {

            // 🔎 Valida ID
            $retId = validarDados($id, 'int', true);

            if ($retId['codigoHelper'] != 0) {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [[
                        'codigo' => $retId['codigoHelper'],
                        'campo' => 'id_vaga',
                        'msg' => $retId['msg']
                    ]]
                ]);
            }

            $model = new VagaModel();

            // Busca vaga
            $vaga = $model->find($id);

            if (!$vaga) {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [[
                        'codigo' => 404,
                        'msg' => 'Vaga não encontrada'
                    ]]
                ]);
            }

            // Se já estiver livre
            if ($vaga['status'] === 'LIVRE') {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [[
                        'codigo' => 46,
                        'msg' => 'Vaga já está livre'
                    ]]
                ]);
            }

            // ♻️ SOFT DELETE (libera vaga)
            $res = $model->update($id, [
                'id_veiculo' => null,
                'status' => 'LIVRE'
            ]);

            if ($res) {
                $sucesso = true;
            } else {
                $erros[] = [
                    'codigo' => 500,
                    'msg' => 'Erro ao liberar vaga',
                    'detalhes' => $model->errors()
                ];
            }
        } catch (\Exception $e) {
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
            'msg' => $sucesso ? 'Vaga liberada com sucesso' : null,
            'erros' => $sucesso ? [] : $erros
        ]);
    }
}
