<?php

namespace App\Controllers;

use App\Models\VeiculoModel;
use Exception;

class Veiculos extends BaseController
{
public function inserir()
{
    helper('helper');

    $erros = [];
    $sucesso = false;

    try {
        $resultado = $this->request->getJSON();

        // Valida JSON
        if (!$resultado) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 400,
                    'msg' => 'JSON inválido ou vazio'
                ]]
            ]);
        }

        // Campos esperados
        $lista = [
            'modelo' => '0',
            'placa' => '0'
        ];

        if (verificarParam($resultado, $lista) != 1) {
            $erros[] = [
                'codigo' => 99,
                'msg' => 'Campos inexistentes'
            ];
        } else {

            // Validações
            $retModelo = validarDados($resultado->modelo, 'string', true);
            $retPlaca = validarDados($resultado->placa, 'string', true);


            // Tratamento de erros
            $validacoes = [
                ['ret' => $retModelo, 'campo' => 'Modelo'],
                ['ret' => $retPlaca, 'campo' => 'Placa']
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

            if (empty($erros)) {

                $model = new \App\Models\VeiculoModel();

                //  Verifica duplicidade (placa)
                if ($model->where('placa', strtoupper($resultado->placa))->first()) {
                    return $this->response->setJSON([
                        'sucesso' => false,
                        'erros' => [[
                            'codigo' => 30,
                            'campo' => 'placa',
                            'msg' => 'Placa já cadastrada'
                        ]]
                    ]);
                }


                $dados = [
                    'modelo' => $resultado->modelo,
                    'placa' => strtoupper($resultado->placa)
                ];

                if ($model->insert($dados)) {
                    $sucesso = true;
                } else {
                    $erros[] = [
                        'codigo' => 500,
                        'msg' => 'Erro ao inserir no banco',
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
        'msg' => $sucesso ? 'Veículo cadastrado com sucesso' : null,
        'erros' => $sucesso ? [] : $erros
    ]);
}


public function listar()
{
    $model = new VeiculoModel();

    $dados = $model->findAll();

    return $this->response->setJSON([
        'sucesso' => true,
        'dados' => $dados
    ]);
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

        $model = new VeiculoModel();

        $veiculo = $model->find($id);

        if (!$veiculo) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'msg' => 'Veículo não encontrado'
                ]]
            ]);
        }

        // BLOQUEIO se INATIVO
        if ($veiculo['status'] === 'INATIVO') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 403,
                    'msg' => 'Não é possível alterar um veículo inativo'
                ]]
            ]);
        }

        // Campos esperados
        $lista = [
            'modelo' => '0',
            'placa' => '0'
        ];

        if (verificarParam($resultado, $lista) != 1) {
            $erros[] = [
                'codigo' => 99,
                'msg' => 'Campos inexistentes'
            ];
        } else {

            // Validações
            $retModelo = validarDados($resultado->modelo, 'string', true);
            $retPlaca = validarDados($resultado->placa, 'string', true);

            $placa = strtoupper($resultado->placa);

            // Validação placa
            if (!preg_match('/^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$/', $placa) &&
                !preg_match('/^[A-Z]{3}-?[0-9]{4}$/', $placa)) {

                $retPlaca = [
                    'codigoHelper' => 40,
                    'msg' => 'Formato de placa inválido'
                ];
            }

            // Verifica duplicidade (exceto o próprio ID)
            $placaExistente = $model->where('placa', $placa)
                                    ->where('id_veiculo !=', $id)
                                    ->first();

            if ($placaExistente) {
                $retPlaca = [
                    'codigoHelper' => 41,
                    'msg' => 'Placa já cadastrada'
                ];
            }

            // Tratamento de erros
            $validacoes = [
                ['ret' => $retModelo, 'campo' => 'Modelo'],
                ['ret' => $retPlaca, 'campo' => 'Placa']
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

            if (empty($erros)) {

                $dados = [
                    'modelo' => $resultado->modelo,
                    'placa' => $placa
                ];

                if ($model->update($id, $dados)) {
                    $sucesso = true;
                } else {
                    $erros[] = [
                        'codigo' => 500,
                        'msg' => 'Erro ao atualizar',
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
                'msg' => $e->getMessage()
            ]]
        ]);
    }

    return $this->response->setJSON([
        'sucesso' => $sucesso,
        'msg' => $sucesso ? 'Veículo atualizado com sucesso' : null,
        'erros' => $sucesso ? [] : $erros
    ]);
}

public function deletar($id)
{
    helper('helper');

    $erros = [];
    $sucesso = false;

    try {
        $model = new VeiculoModel();

        // Valida ID
        $retId = validarDados($id, 'int', true);

        if ($retId['codigoHelper'] != 0) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => $retId['codigoHelper'],
                    'campo' => 'id_veiculo',
                    'msg' => $retId['msg']
                ]]
            ]);
        }

        // Verifica se existe
        $veiculo = $model->find($id);

        if (!$veiculo) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'msg' => 'Veículo não encontrado'
                ]]
            ]);
        }

        // Já está inativo
        if ($veiculo['status'] === 'INATIVO') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 403,
                    'msg' => 'Veículo já está inativo'
                ]]
            ]);
        }

        // DELETE LÓGICO (update status)
        if ($model->update($id, ['status' => 'INATIVO'])) {
            $sucesso = true;
        } else {
            $erros[] = [
                'codigo' => 500,
                'msg' => 'Erro ao deletar',
                'detalhes' => $model->errors()
            ];
        }

    } catch (\Exception $e) {
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
        'msg' => $sucesso ? 'Veículo inativado com sucesso' : null,
        'erros' => $sucesso ? [] : $erros
    ]);
}

}