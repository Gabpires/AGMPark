<?php

namespace App\Controllers;

use App\Controllers\BaseController;
use app\moodels\TarifaModel;
use Exception;

class Tarifas extends BaseController
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

        $retIdEstacionamento = validarDados($resultado->id_estacionamento ?? null, 'int', true);
        $retTempo = validarDados($resultado->tempo ?? null, 'int', true);
        $retValor = validarDados($resultado->valor ?? null, 'float', true);

        $validacoes = [
            ['ret' => $retIdEstacionamento, 'campo' => 'id_estacionamento'],
            ['ret' => $retTempo, 'campo' => 'tempo'],
            ['ret' => $retValor, 'campo' => 'valor']
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

        if (($resultado->tempo ?? 0) <= 0) {
            $erros[] = [
                'codigo' => 30,
                'campo' => 'tempo',
                'msg' => 'Tempo deve ser maior que zero'
            ];
        }

        if (($resultado->valor ?? 0) <= 0) {
            $erros[] = [
                'codigo' => 31,
                'campo' => 'valor',
                'msg' => 'Valor deve ser maior que zero'
            ];
        }

        if (!empty($erros)) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => $erros
            ]);
        }

        $model = new \App\Models\TarifaModel();
        $estacionamentoModel = new \App\Models\EstacionamentoModel();

        $estacionamento = $estacionamentoModel->find($resultado->id_estacionamento);

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

        if ($estacionamento['status'] !== 'ATIVO') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 43,
                    'campo' => 'id_estacionamento',
                    'msg' => 'Estacionamento inativo'
                ]]
            ]);
        }

        $tarifaExiste = $model
            ->where('id_estacionamento', $resultado->id_estacionamento)
            ->where('tempo', $resultado->tempo)
            ->where('status', 'ATIVO')
            ->first();

        if ($tarifaExiste) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 50,
                    'msg' => 'Já existe tarifa ativa cadastrada para esse tempo'
                ]]
            ]);
        }

        $dados = [
            'id_estacionamento' => $resultado->id_estacionamento,
            'tempo' => $resultado->tempo,
            'unidade' => 'MINUTO',
            'valor' => $resultado->valor,
            'status' => 'ATIVO'
        ];

        if ($model->insert($dados)) {
            $sucesso = true;
        } else {
            $erros[] = [
                'codigo' => 500,
                'msg' => 'Erro ao cadastrar tarifa',
                'detalhes' => $model->errors()
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
        'msg' => $sucesso ? 'Tarifa cadastrada com sucesso' : null,
        'erros' => $sucesso ? [] : $erros
    ]);
}


    public function listar()
{
    helper('helper');

    try {
        $model = new \App\Models\TarifaModel();

        $dados = $model
            ->select('
                tarifas.id,
                tarifas.id_estacionamento,
                tarifas.tempo,
                tarifas.unidade,
                tarifas.valor,
                tarifas.status,

                estacionamento.nome AS nome_estacionamento,
                estacionamento.cidade,
                estacionamento.estado,
                estacionamento.status AS status_estacionamento
            ')
            ->join(
                'estacionamento',
                'estacionamento.id_estacionamento = tarifas.id_estacionamento'
            )
            ->where('tarifas.status', 'ATIVO')
            ->orderBy('tarifas.id_estacionamento', 'ASC')
            ->orderBy('tarifas.tempo', 'ASC')
            ->findAll();

        if (!$dados) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'msg' => 'Nenhuma tarifa ativa encontrada'
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

        $retId = validarDados($id, 'int', true);
        $retIdEstacionamento = validarDados($resultado->id_estacionamento ?? null, 'int', true);
        $retTempo = validarDados($resultado->tempo ?? null, 'int', true);
        $retValor = validarDados($resultado->valor ?? null, 'float', true);

        $validacoes = [
            ['ret' => $retId, 'campo' => 'id'],
            ['ret' => $retIdEstacionamento, 'campo' => 'id_estacionamento'],
            ['ret' => $retTempo, 'campo' => 'tempo'],
            ['ret' => $retValor, 'campo' => 'valor']
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

        if (($resultado->tempo ?? 0) <= 0) {
            $erros[] = [
                'codigo' => 30,
                'campo' => 'tempo',
                'msg' => 'Tempo deve ser maior que zero'
            ];
        }

        if (($resultado->valor ?? 0) <= 0) {
            $erros[] = [
                'codigo' => 31,
                'campo' => 'valor',
                'msg' => 'Valor deve ser maior que zero'
            ];
        }

        if (!empty($erros)) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => $erros
            ]);
        }

        $model = new \App\Models\TarifaModel();
        $estacionamentoModel = new \App\Models\EstacionamentoModel();

        $tarifa = $model->find($id);

        if (!$tarifa) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'campo' => 'id',
                    'msg' => 'Tarifa não encontrada'
                ]]
            ]);
        }

        if ($tarifa['status'] === 'INATIVO') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 403,
                    'campo' => 'status',
                    'msg' => 'Tarifa inativa não pode ser alterada'
                ]]
            ]);
        }

        $estacionamento = $estacionamentoModel->find($resultado->id_estacionamento);

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

        if ($estacionamento['status'] !== 'ATIVO') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 43,
                    'campo' => 'id_estacionamento',
                    'msg' => 'Estacionamento inativo'
                ]]
            ]);
        }

        $tarifaExiste = $model
            ->where('id_estacionamento', $resultado->id_estacionamento)
            ->where('tempo', $resultado->tempo)
            ->where('status', 'ATIVO')
            ->where('id !=', $id)
            ->first();

        if ($tarifaExiste) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 50,
                    'msg' => 'Já existe tarifa ativa cadastrada para esse tempo'
                ]]
            ]);
        }

        $dados = [
            'id_estacionamento' => $resultado->id_estacionamento,
            'tempo' => $resultado->tempo,
            'unidade' => 'MINUTO',
            'valor' => $resultado->valor,
            'status' => 'ATIVO'
        ];

        if ($model->update($id, $dados)) {
            $sucesso = true;
        } else {
            $erros[] = [
                'codigo' => 500,
                'msg' => 'Erro ao atualizar tarifa',
                'detalhes' => $model->errors()
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
        'msg' => $sucesso ? 'Tarifa atualizada com sucesso' : null,
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
                    'campo' => 'id',
                    'msg' => $retId['msg']
                ]]
            ]);
        }

        $model = new \App\Models\TarifaModel();

        $tarifa = $model->find($id);

        if (!$tarifa) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'msg' => 'Tarifa não encontrada'
                ]]
            ]);
        }

        if ($tarifa['status'] === 'INATIVO') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 403,
                    'msg' => 'Tarifa já está inativa'
                ]]
            ]);
        }

        $dados = [
            'status' => 'INATIVO'
        ];

        if ($model->update($id, $dados)) {
            $sucesso = true;
        } else {
            $erros[] = [
                'codigo' => 500,
                'msg' => 'Erro ao inativar tarifa',
                'detalhes' => $model->errors()
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
        'msg' => $sucesso ? 'Tarifa inativada com sucesso' : null,
        'erros' => $sucesso ? [] : $erros
    ]);
}

   
}