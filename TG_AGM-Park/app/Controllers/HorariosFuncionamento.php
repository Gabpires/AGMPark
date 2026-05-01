<?php

namespace App\Controllers;

use App\Models\HorarioFuncionamentoModel;
use Exception;

class HorariosFuncionamento extends BaseController
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

        // =============================
        // VALIDAÇÕES
        // =============================
        $retIdEstacionamento = validarDados($resultado->id_estacionamento ?? null, 'int', true);
        $retDiaSemana = validarDados($resultado->dia_semana ?? null, 'string', true);
        $retHoraAbertura = validarDados($resultado->hora_abertura ?? null, 'hora', true);
        $retHoraFechamento = validarDados($resultado->hora_fechamento ?? null, 'hora', true);

        $validacoes = [
            ['ret' => $retIdEstacionamento, 'campo' => 'id_estacionamento'],
            ['ret' => $retDiaSemana, 'campo' => 'dia_semana'],
            ['ret' => $retHoraAbertura, 'campo' => 'hora_abertura'],
            ['ret' => $retHoraFechamento, 'campo' => 'hora_fechamento']
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

        // =============================
        // VALIDA DIA DA SEMANA
        // =============================
        $diasPermitidos = ['SEG','TER','QUA','QUI','SEX','SAB','DOM'];
        $diaSemana = strtoupper($resultado->dia_semana ?? '');

        if (!in_array($diaSemana, $diasPermitidos)) {
            $erros[] = [
                'codigo' => 30,
                'campo' => 'dia_semana',
                'msg' => 'Dia da semana inválido'
            ];
        }

        // =============================
        // VALIDA HORÁRIO
        // =============================
        if (!empty($resultado->hora_abertura) && !empty($resultado->hora_fechamento)) {
            if ($resultado->hora_abertura >= $resultado->hora_fechamento) {
                $erros[] = [
                    'codigo' => 31,
                    'campo' => 'hora_fechamento',
                    'msg' => 'Hora de fechamento deve ser maior que a de abertura'
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
        $model = new \App\Models\HorarioFuncionamentoModel();
        $estacionamentoModel = new \App\Models\EstacionamentoModel();

        // =============================
        // VERIFICA ESTACIONAMENTO
        // =============================
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

        // =============================
        // DUPLICIDADE (IGNORA INATIVOS)
        // =============================
        $horarioExiste = $model
            ->where('id_estacionamento', $resultado->id_estacionamento)
            ->where('dia_semana', $diaSemana)
            ->where('status', 'ATIVO')
            ->first();

        if ($horarioExiste) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 50,
                    'msg' => 'Já existe horário ativo para este dia neste estacionamento'
                ]]
            ]);
        }

        // =============================
        // INSERT
        // =============================
        $dados = [
            'id_estacionamento' => $resultado->id_estacionamento,
            'dia_semana' => $diaSemana,
            'hora_abertura' => $resultado->hora_abertura,
            'hora_fechamento' => $resultado->hora_fechamento,
            'status' => 'ATIVO'
        ];

        if ($model->insert($dados)) {
            $sucesso = true;
        } else {
            $erros[] = [
                'codigo' => 500,
                'msg' => 'Erro ao cadastrar horário',
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
        'msg' => $sucesso ? 'Horário cadastrado com sucesso' : null,
        'erros' => $sucesso ? [] : $erros
    ]);
}



   
   public function listar()
{
    helper('helper');

    try {
        $model = new \App\Models\HorarioFuncionamentoModel();

        $dados = $model
            ->select('
                horarios_funcionamento.id,
                horarios_funcionamento.id_estacionamento,
                horarios_funcionamento.dia_semana,
                horarios_funcionamento.hora_abertura,
                horarios_funcionamento.hora_fechamento,
                horarios_funcionamento.status,

                estacionamento.nome AS nome_estacionamento,
                estacionamento.cidade,
                estacionamento.estado,
                estacionamento.status AS status_estacionamento
            ')
            ->join(
                'estacionamento',
                'estacionamento.id_estacionamento = horarios_funcionamento.id_estacionamento'
            )
            ->where('horarios_funcionamento.status', 'ATIVO')
            ->orderBy('horarios_funcionamento.id_estacionamento', 'ASC')
            ->orderBy('horarios_funcionamento.id', 'ASC')
            ->findAll();

        if (!$dados) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'msg' => 'Nenhum horário ativo encontrado'
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
        $retDiaSemana = validarDados($resultado->dia_semana ?? null, 'string', true);
        $retHoraAbertura = validarDados($resultado->hora_abertura ?? null, 'hora', true);
        $retHoraFechamento = validarDados($resultado->hora_fechamento ?? null, 'hora', true);

        $validacoes = [
            ['ret' => $retId, 'campo' => 'id'],
            ['ret' => $retIdEstacionamento, 'campo' => 'id_estacionamento'],
            ['ret' => $retDiaSemana, 'campo' => 'dia_semana'],
            ['ret' => $retHoraAbertura, 'campo' => 'hora_abertura'],
            ['ret' => $retHoraFechamento, 'campo' => 'hora_fechamento']
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

        $diasPermitidos = ['SEG','TER','QUA','QUI','SEX','SAB','DOM'];
        $diaSemana = strtoupper($resultado->dia_semana ?? '');

        if (!in_array($diaSemana, $diasPermitidos)) {
            $erros[] = [
                'codigo' => 30,
                'campo' => 'dia_semana',
                'msg' => 'Dia da semana inválido'
            ];
        }

        if (!empty($resultado->hora_abertura) && !empty($resultado->hora_fechamento)) {
            if ($resultado->hora_abertura >= $resultado->hora_fechamento) {
                $erros[] = [
                    'codigo' => 31,
                    'campo' => 'hora_fechamento',
                    'msg' => 'Hora de fechamento deve ser maior que a de abertura'
                ];
            }
        }

        if (!empty($erros)) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => $erros
            ]);
        }

        $model = new \App\Models\HorarioFuncionamentoModel();
        $estacionamentoModel = new \App\Models\EstacionamentoModel();

        $horario = $model->find($id);

        if (!$horario) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'campo' => 'id',
                    'msg' => 'Horário de funcionamento não encontrado'
                ]]
            ]);
        }

        if ($horario['status'] === 'INATIVO') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 403,
                    'campo' => 'status',
                    'msg' => 'Horário inativo não pode ser alterado'
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

        $horarioExiste = $model
            ->where('id_estacionamento', $resultado->id_estacionamento)
            ->where('dia_semana', $diaSemana)
            ->where('status', 'ATIVO')
            ->where('id !=', $id)
            ->first();

        if ($horarioExiste) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 50,
                    'msg' => 'Já existe horário ativo para este dia neste estacionamento'
                ]]
            ]);
        }

        $dados = [
            'id_estacionamento' => $resultado->id_estacionamento,
            'dia_semana' => $diaSemana,
            'hora_abertura' => $resultado->hora_abertura,
            'hora_fechamento' => $resultado->hora_fechamento,
            'status' => 'ATIVO'
        ];

        if ($model->update($id, $dados)) {
            $sucesso = true;
        } else {
            $erros[] = [
                'codigo' => 500,
                'msg' => 'Erro ao atualizar horário',
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
        'msg' => $sucesso ? 'Horário atualizado com sucesso' : null,
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

        $model = new \App\Models\HorarioFuncionamentoModel();

        $horario = $model->find($id);

        if (!$horario) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'msg' => 'Horário de funcionamento não encontrado'
                ]]
            ]);
        }

        if ($horario['status'] === 'INATIVO') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 403,
                    'msg' => 'Horário já está inativo'
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
                'msg' => 'Erro ao inativar horário',
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
        'msg' => $sucesso ? 'Horário inativado com sucesso' : null,
        'erros' => $sucesso ? [] : $erros
    ]);
}


}