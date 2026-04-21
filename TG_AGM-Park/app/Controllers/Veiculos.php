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
            'modelo' => '0',
            'marca'  => '0',
            'placa'  => '0'
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
            $retModelo = validarDados($resultado->modelo, 'string', true);
            $retMarca  = validarDados($resultado->marca, 'string', true);
            $retPlaca  = validarDados($resultado->placa, 'string', true);

            // normaliza placa
            $placa = strtoupper(trim($resultado->placa));

            // valida tamanho da placa
            if (strlen($placa) < 7 || strlen($placa) > 10) {
                $retPlaca = [
                    'codigoHelper' => 31,
                    'msg' => 'Placa inválida'
                ];
            }

            // =====================================
            // TRATAMENTO DE ERROS
            // =====================================
            $validacoes = [
                ['ret' => $retModelo, 'campo' => 'Modelo'],
                ['ret' => $retMarca,  'campo' => 'Marca'],
                ['ret' => $retPlaca,  'campo' => 'Placa']
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

            // =====================================
            // SEM ERROS
            // =====================================
            if (empty($erros)) {

                $model = new \App\Models\VeiculoModel();

                // verifica placa duplicada
                $existe = $model
                    ->where('placa', $placa)
                    ->first();

                if ($existe) {

                    return $this->response->setJSON([
                        'sucesso' => false,
                        'erros' => [[
                            'codigo' => 30,
                            'campo' => 'Placa',
                            'msg' => 'Placa já cadastrada'
                        ]]
                    ]);
                }

                // =====================================
                // INSERT
                // =====================================
                $dados = [
                    'modelo' => trim($resultado->modelo),
                    'marca'  => trim($resultado->marca),
                    'placa'  => $placa,
                    'status' => 'ATIVO'
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
        // VALIDA ID
        // =====================================
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

        $model = new \App\Models\VeiculoModel();

        // =====================================
        // VERIFICA EXISTÊNCIA
        // =====================================
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

        // =====================================
        // BLOQUEIA ALTERAÇÃO SE INATIVO
        // =====================================
        if ($veiculo['status'] == 'INATIVO') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 403,
                    'msg' => 'Veículo inativo não pode ser alterado'
                ]]
            ]);
        }

        // =====================================
        // CAMPOS ESPERADOS
        // =====================================
        $lista = [
            'modelo' => '0',
            'marca'  => '0',
            'placa'  => '0'
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
            $retModelo = validarDados($resultado->modelo, 'string', true);
            $retMarca  = validarDados($resultado->marca, 'string', true);
            $retPlaca  = validarDados($resultado->placa, 'string', true);

            $placa = strtoupper(trim($resultado->placa));

            if (strlen($placa) < 7 || strlen($placa) > 10) {
                $retPlaca = [
                    'codigoHelper' => 31,
                    'msg' => 'Placa inválida'
                ];
            }

            $validacoes = [
                ['ret' => $retModelo, 'campo' => 'Modelo'],
                ['ret' => $retMarca,  'campo' => 'Marca'],
                ['ret' => $retPlaca,  'campo' => 'Placa']
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

            // =====================================
            // VERIFICA DUPLICIDADE DE PLACA
            // =====================================
            if (empty($erros)) {

                $placaExistente = $model
                    ->where('placa', $placa)
                    ->where('id_veiculo !=', $id)
                    ->first();

                if ($placaExistente) {
                    $erros[] = [
                        'codigo' => 30,
                        'campo' => 'Placa',
                        'msg' => 'Placa já cadastrada em outro veículo'
                    ];
                }
            }

            // =====================================
            // UPDATE
            // =====================================
            if (empty($erros)) {

                $dados = [
                    'modelo' => trim($resultado->modelo),
                    'marca'  => trim($resultado->marca),
                    'placa'  => $placa
                ];

                if ($model->update($id, $dados)) {
                    $sucesso = true;
                } else {
                    $erros[] = [
                        'codigo' => 500,
                        'msg' => 'Erro ao atualizar veículo',
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