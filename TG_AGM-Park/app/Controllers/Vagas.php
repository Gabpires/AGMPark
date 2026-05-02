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

            // =====================================
            // VALIDA JSON
            // =====================================
            if (!$resultado) {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [[
                        'codigo' => 400,
                        'msg' => 'JSON inválido ou vazio'
                    ]]
                ]);
            }

            // =====================================
            // CAMPOS ESPERADOS
            // =====================================
            $lista = [
                'id_estacionamento' => '0',
                'numero_vaga'       => '0'
            ];

            if (verificarParam($resultado, $lista) != 1) {
                $erros[] = [
                    'codigo' => 99,
                    'msg' => 'Campos inexistentes'
                ];
            } else {

                // =====================================
                // VALIDAÇÕES
                // =====================================
                $retIdEstacionamento = validarDados($resultado->id_estacionamento, 'int', true);
                $retNumeroVaga       = validarDados($resultado->numero_vaga, 'int', true);

                $validacoes = [
                    ['ret' => $retIdEstacionamento, 'campo' => 'id_estacionamento'],
                    ['ret' => $retNumeroVaga,       'campo' => 'numero_vaga']
                ];

                foreach ($validacoes as $v) {

                    if ($v['ret']['codigoHelper'] != 0) {

                        $erros[] = [
                            'codigo' => $v['ret']['codigoHelper'],
                            'campo'  => $v['campo'],
                            'msg'    => $v['ret']['msg']
                        ];
                    }
                }

                // numero_vaga > 0
                if (($resultado->numero_vaga ?? 0) <= 0) {
                    $erros[] = [
                        'codigo' => 31,
                        'campo' => 'numero_vaga',
                        'msg' => 'Número da vaga deve ser maior que zero'
                    ];
                }

                if (empty($erros)) {

                    $model = new \App\Models\VagaModel();
                    $estacionamentoModel = new \App\Models\EstacionamentoModel();

                    // =====================================
                    // VERIFICA ESTACIONAMENTO
                    // =====================================
                    $estacionamento = $estacionamentoModel
                        ->find($resultado->id_estacionamento);

                    if (!$estacionamento) {
                        return $this->response->setJSON([
                            'sucesso' => false,
                            'erros' => [[
                                'codigo' => 404,
                                'campo' => 'id_estacionamento',
                                'msg' => 'Estacionamento não encontrado'
                            ]]
                        ]);
                    }

                    // status ativo
                    if ($estacionamento['status'] == 'INATIVO') {
                        return $this->response->setJSON([
                            'sucesso' => false,
                            'erros' => [[
                                'codigo' => 403,
                                'campo' => 'id_estacionamento',
                                'msg' => 'Estacionamento inativo'
                            ]]
                        ]);
                    }

                    // =====================================
                    // LIMITE DE VAGAS
                    // =====================================
                    $total = $model
                        ->where('id_estacionamento', $resultado->id_estacionamento)
                        ->countAllResults();

                    if ($total >= $estacionamento['numero_vagas']) {
                        return $this->response->setJSON([
                            'sucesso' => false,
                            'erros' => [[
                                'codigo' => 45,
                                'msg' => 'Limite máximo de vagas atingido'
                            ]]
                        ]);
                    }

                    // =====================================
                    // DUPLICIDADE numero_vaga
                    // =====================================
                    $vagaExiste = $model
                        ->where('id_estacionamento', $resultado->id_estacionamento)
                        ->where('numero_vaga', $resultado->numero_vaga)
                        ->first();

                    if ($vagaExiste) {
                        return $this->response->setJSON([
                            'sucesso' => false,
                            'erros' => [[
                                'codigo' => 30,
                                'campo' => 'numero_vaga',
                                'msg' => 'Número de vaga já existe neste estacionamento'
                            ]]
                        ]);
                    }

                    // =====================================
                    // INSERT
                    // =====================================
                    $dados = [
                        'id_estacionamento' => $resultado->id_estacionamento,
                        'numero_vaga'       => $resultado->numero_vaga,
                        'status'            => 'LIVRE'
                    ];

                    if ($model->insert($dados)) {

                        $sucesso = true;
                    } else {

                        $erros[] = [
                            'codigo' => 500,
                            'msg' => 'Erro ao inserir vaga',
                            'detalhes' => $model->errors()
                        ];
                    }
                }
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
            'msg' => $sucesso ? 'Vaga cadastrada com sucesso' : null,
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

            // =====================================
            // VALIDA JSON
            // =====================================
            if (!$resultado) {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [[
                        'codigo' => 400,
                        'msg' => 'JSON inválido ou vazio'
                    ]]
                ]);
            }

            // =====================================
            // VALIDA ID DA URL
            // =====================================
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

            // =====================================
            // CAMPOS ESPERADOS
            // =====================================
            $lista = [
                'id_estacionamento' => '0',
                'numero_vaga'       => '0',
                'status'            => '0'
            ];

            if (verificarParam($resultado, $lista) != 1) {

                $erros[] = [
                    'codigo' => 99,
                    'msg' => 'Campos inexistentes'
                ];
            } else {

                $model = new \App\Models\VagaModel();
                $estacionamentoModel = new \App\Models\EstacionamentoModel();

                // =====================================
                // VERIFICA EXISTÊNCIA DA VAGA
                // =====================================
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

                // =====================================
                // VALIDAÇÕES
                // =====================================
                $retIdEstacionamento = validarDados($resultado->id_estacionamento, 'int', true);
                $retNumeroVaga       = validarDados($resultado->numero_vaga, 'int', true);
                $retStatus           = validarDados($resultado->status, 'string', true);

                $validacoes = [
                    ['ret' => $retIdEstacionamento, 'campo' => 'id_estacionamento'],
                    ['ret' => $retNumeroVaga,       'campo' => 'numero_vaga'],
                    ['ret' => $retStatus,           'campo' => 'status']
                ];

                foreach ($validacoes as $v) {

                    if ($v['ret']['codigoHelper'] != 0) {

                        $erros[] = [
                            'codigo' => $v['ret']['codigoHelper'],
                            'campo'  => $v['campo'],
                            'msg'    => $v['ret']['msg']
                        ];
                    }
                }

                // número vaga > 0
                if (($resultado->numero_vaga ?? 0) <= 0) {
                    $erros[] = [
                        'codigo' => 31,
                        'campo' => 'numero_vaga',
                        'msg' => 'Número da vaga deve ser maior que zero'
                    ];
                }

                // valida status permitido
                $statusPermitidos = ['LIVRE', 'OCUPADA', 'MANUTENCAO'];

                if (!in_array(strtoupper($resultado->status), $statusPermitidos)) {
                    $erros[] = [
                        'codigo' => 32,
                        'campo' => 'status',
                        'msg' => 'Status inválido'
                    ];
                }

                if (empty($erros)) {

                    // =====================================
                    // VERIFICA ESTACIONAMENTO
                    // =====================================
                    $estacionamento = $estacionamentoModel
                        ->find($resultado->id_estacionamento);

                    if (!$estacionamento) {
                        return $this->response->setJSON([
                            'sucesso' => false,
                            'erros' => [[
                                'codigo' => 404,
                                'campo' => 'id_estacionamento',
                                'msg' => 'Estacionamento não encontrado'
                            ]]
                        ]);
                    }

                    if ($estacionamento['status'] == 'INATIVO') {
                        return $this->response->setJSON([
                            'sucesso' => false,
                            'erros' => [[
                                'codigo' => 403,
                                'campo' => 'id_estacionamento',
                                'msg' => 'Estacionamento inativo'
                            ]]
                        ]);
                    }

                    // =====================================
                    // DUPLICIDADE número vaga
                    // =====================================
                    $vagaExiste = $model
                        ->where('id_estacionamento', $resultado->id_estacionamento)
                        ->where('numero_vaga', $resultado->numero_vaga)
                        ->where('id_vaga !=', $id)
                        ->first();

                    if ($vagaExiste) {
                        return $this->response->setJSON([
                            'sucesso' => false,
                            'erros' => [[
                                'codigo' => 30,
                                'campo' => 'numero_vaga',
                                'msg' => 'Número da vaga já existe neste estacionamento'
                            ]]
                        ]);
                    }

                    // =====================================
                    // UPDATE
                    // =====================================
                    $dados = [
                        'id_estacionamento' => $resultado->id_estacionamento,
                        'numero_vaga'       => $resultado->numero_vaga,
                        'status'            => strtoupper($resultado->status)
                    ];

                    if ($model->update($id, $dados)) {

                        $sucesso = true;
                    } else {

                        $erros[] = [
                            'codigo' => 500,
                            'msg' => 'Erro ao atualizar vaga',
                            'detalhes' => $model->errors()
                        ];
                    }
                }
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
            'msg' => $sucesso ? 'Vaga atualizada com sucesso' : null,
            'erros' => $sucesso ? [] : $erros
        ]);
    }

    public function atualizarStatusFisico($id)
    {
        helper('helper');

        try {

            // pega da URL
            $statusFisico = strtoupper($this->request->getGet('status'));

            // valida ID
            $retId = validarDados($id, 'int', true);

            if ($retId['codigoHelper'] != 0) {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [[
                        'msg' => 'ID inválido'
                    ]]
                ]);
            }

            // valida status
            $permitidos = ['LIVRE', 'OCUPADA'];

            if (!in_array($statusFisico, $permitidos)) {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [[
                        'msg' => 'Status inválido'
                    ]]
                ]);
            }

            $model = new \App\Models\VagaModel();

            if (!$model->find($id)) {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [[
                        'msg' => 'Vaga não encontrada'
                    ]]
                ]);
            }

            $model->update($id, [
                'status_fisico' => $statusFisico
            ]);

            return $this->response->setJSON([
                'sucesso' => true,
                'msg' => 'Atualizado com sucesso'
            ]);
        } catch (Exception $e) {

            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'msg' => $e->getMessage()
                ]]
            ]);
        }
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
