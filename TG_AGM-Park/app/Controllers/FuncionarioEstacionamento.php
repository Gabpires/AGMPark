<?php

namespace App\Controllers;

use App\Models\FuncionarioEstacionamentoModel;
use App\Models\UsuarioModelModel;
use App\Models\EstacionamentoModel;

use Exception;

class FuncionarioEstacionamento extends BaseController
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

        $retIdFuncionario = validarDados($resultado->id_funcionario ?? null, 'int', true);
        $retIdEstacionamento = validarDados($resultado->id_estacionamento ?? null, 'int', true);

        $validacoes = [
            ['ret' => $retIdFuncionario, 'campo' => 'id_funcionario'],
            ['ret' => $retIdEstacionamento, 'campo' => 'id_estacionamento']
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

        $model = new \App\Models\FuncionarioEstacionamentoModel();
        $funcionarioModel = new \App\Models\UsuarioModel();
        $estacionamentoModel = new \App\Models\EstacionamentoModel();

        $funcionario = $funcionarioModel->find($resultado->id_funcionario);

        if (!$funcionario) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'campo' => 'id_funcionario',
                    'msg' => 'Funcionário não encontrado'
                ]]
            ]);
        }

        if ($funcionario['status'] !== 'ATIVO') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 42,
                    'campo' => 'id_funcionario',
                    'msg' => 'Funcionário inativo'
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

        $vinculoExiste = $model
            ->where('id_funcionario', $resultado->id_funcionario)
            ->where('id_estacionamento', $resultado->id_estacionamento)
            ->first();

        if ($vinculoExiste) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 50,
                    'msg' => 'Este funcionário já está vinculado a este estacionamento'
                ]]
            ]);
        }

        $dados = [
            'id_funcionario' => $resultado->id_funcionario,
            'id_estacionamento' => $resultado->id_estacionamento
        ];

        if ($model->insert($dados)) {
            $sucesso = true;
        } else {
            $erros[] = [
                'codigo' => 500,
                'msg' => 'Erro ao vincular funcionário ao estacionamento',
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
        'msg' => $sucesso ? 'Funcionário vinculado ao estacionamento com sucesso' : null,
        'erros' => $sucesso ? [] : $erros
    ]);
}


    public function listar()
{
    helper('helper');

    try {
        $model = new \App\Models\FuncionarioEstacionamentoModel();

        $dados = $model
            ->select('
                funcionario_estacionamento.id,
                funcionario_estacionamento.id_funcionario,
                funcionario_estacionamento.id_estacionamento,

                funcionario.primeiro_nome,
                funcionario.cpf_cnpj,
                funcionario.email,
                funcionario.tipo_usuario,
                funcionario.status AS status_funcionario,

                estacionamento.nome AS nome_estacionamento,
                estacionamento.rua,
                estacionamento.bairro,
                estacionamento.cidade,
                estacionamento.estado,
                estacionamento.status AS status_estacionamento
            ')
            ->join('funcionario', 'funcionario.id_funcionario = funcionario_estacionamento.id_funcionario')
            ->join('estacionamento', 'estacionamento.id_estacionamento = funcionario_estacionamento.id_estacionamento')
            ->orderBy('funcionario_estacionamento.id', 'DESC')
            ->findAll();

        if (!$dados) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'msg' => 'Nenhum vínculo encontrado'
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
        $retIdFuncionario = validarDados($resultado->id_funcionario ?? null, 'int', true);
        $retIdEstacionamento = validarDados($resultado->id_estacionamento ?? null, 'int', true);

        $validacoes = [
            ['ret' => $retId, 'campo' => 'id'],
            ['ret' => $retIdFuncionario, 'campo' => 'id_funcionario'],
            ['ret' => $retIdEstacionamento, 'campo' => 'id_estacionamento']
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

        $model = new \App\Models\FuncionarioEstacionamentoModel();
        $funcionarioModel = new \App\Models\UsuarioModel();
        $estacionamentoModel = new \App\Models\EstacionamentoModel();

        $vinculo = $model->find($id);

        if (!$vinculo) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'campo' => 'id',
                    'msg' => 'Vínculo não encontrado'
                ]]
            ]);
        }

        $funcionario = $funcionarioModel->find($resultado->id_funcionario);

        if (!$funcionario) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'campo' => 'id_funcionario',
                    'msg' => 'Funcionário não encontrado'
                ]]
            ]);
        }

        if ($funcionario['status'] !== 'ATIVO') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 42,
                    'campo' => 'id_funcionario',
                    'msg' => 'Funcionário inativo'
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

        $vinculoExiste = $model
            ->where('id_funcionario', $resultado->id_funcionario)
            ->where('id_estacionamento', $resultado->id_estacionamento)
            ->where('id !=', $id)
            ->first();

        if ($vinculoExiste) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 50,
                    'msg' => 'Este funcionário já está vinculado a este estacionamento'
                ]]
            ]);
        }

        $dados = [
            'id_funcionario' => $resultado->id_funcionario,
            'id_estacionamento' => $resultado->id_estacionamento
        ];

        if ($model->update($id, $dados)) {
            $sucesso = true;
        } else {
            $erros[] = [
                'codigo' => 500,
                'msg' => 'Erro ao atualizar vínculo',
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
        'msg' => $sucesso ? 'Vínculo atualizado com sucesso' : null,
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

        $model = new \App\Models\FuncionarioEstacionamentoModel();

        $vinculo = $model->find($id);

        if (!$vinculo) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'msg' => 'Vínculo não encontrado'
                ]]
            ]);
        }

        if ($model->delete($id)) {
            $sucesso = true;
        } else {
            $erros[] = [
                'codigo' => 500,
                'msg' => 'Erro ao deletar vínculo',
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
        'msg' => $sucesso ? 'Vínculo deletado com sucesso' : null,
        'erros' => $sucesso ? [] : $erros
    ]);
}

}