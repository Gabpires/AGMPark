<?php
namespace App\Controllers;
use App\Models\ReservaModel;
use App\Models\VeiculoModel;
use App\Models\EstacionamentoModel;
use App\Models\VagaModel;
use Exception;

class Reservas extends BaseController
{
    public function inserir()
{
    helper('helper');

    $erros = [];
    $sucesso = false;

    try {

        $resultado = $this->request->getJSON();

        // =====================================================
        // JSON
        // =====================================================
        if (!$resultado) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 400,
                    'msg' => 'JSON inválido ou vazio'
                ]]
            ]);
        }

        // =====================================================
        // VALIDA CAMPOS OBRIGATÓRIOS
        // =====================================================
        $retIdVeiculo        = validarDados($resultado->id_veiculo ?? null, 'int', true);
        $retIdEstacionamento = validarDados($resultado->id_estacionamento ?? null, 'int', true);
        $retDataReserva      = validarDados($resultado->data_reserva ?? null, 'date', true);
        $retDataExpiracao    = validarDados($resultado->data_expiracao ?? null, 'date', true);
        $retValor            = validarDados($resultado->valor ?? null, 'float', true);

        $validacoes = [
            ['ret' => $retIdVeiculo,        'campo' => 'id_veiculo'],
            ['ret' => $retIdEstacionamento, 'campo' => 'id_estacionamento'],
            ['ret' => $retDataReserva,      'campo' => 'data_reserva'],
            ['ret' => $retDataExpiracao,    'campo' => 'data_expiracao'],
            ['ret' => $retValor,            'campo' => 'valor']
        ];

        foreach ($validacoes as $v) {
            if ($v['ret']['codigoHelper'] != 0) {
                $erros[] = [
                    'campo' => $v['campo'],
                    'msg'   => $v['ret']['msg']
                ];
            }
        }

        if (!empty($erros)) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => $erros
            ]);
        }

        // =====================================================
        // MODELS
        // =====================================================
        $reservaModel        = new ReservaModel();
        $veiculoModel        = new VeiculoModel();
        $estacionamentoModel = new EstacionamentoModel();
        $vagaModel           = new VagaModel();

        // =====================================================
        // VEÍCULO EXISTE E ESTÁ ATIVO
        // =====================================================
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

        // =====================================================
        // ESTACIONAMENTO EXISTE E ATIVO
        // =====================================================
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
                    'msg' => 'Estacionamento inativo'
                ]]
            ]);
        }

        // =====================================================
        // VEÍCULO JÁ POSSUI RESERVA ATIVA?
        // =====================================================
        $reservaAtiva = $reservaModel
            ->where('id_veiculo', $resultado->id_veiculo)
            ->whereIn('status', ['ATIVA', 'EM_USO'])
            ->first();

        if ($reservaAtiva) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 50,
                    'msg' => 'Veículo já possui reserva ativa'
                ]]
            ]);
        }

        // =====================================================
        // VERIFICA DISPONIBILIDADE DE VAGAS
        // =====================================================
        $ocupadas = $vagaModel
            ->where('id_estacionamento', $resultado->id_estacionamento)
            ->where('status', 'OCUPADA')
            ->countAllResults();

        if ($ocupadas >= $estacionamento['numero_vagas']) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 45,
                    'msg' => 'Não há vagas disponíveis para reserva'
                ]]
            ]);
        }

        // =====================================================
        // INSERE RESERVA
        // =====================================================
        $dados = [
            'id_veiculo'        => $resultado->id_veiculo,
            'id_estacionamento' => $resultado->id_estacionamento,
            'id_vaga'           => null,
            'data_reserva'      => $resultado->data_reserva,
            'data_expiracao'    => $resultado->data_expiracao,
            'data_checkin'      => null,
            'data_checkout'     => null,
            'data_cancelamento' => null,
            'valor'             => $resultado->valor,
            'status'            => 'ATIVA'
        ];

        $res = $reservaModel->insert($dados);

        if ($res) {
            $sucesso = true;
        } else {
            $erros[] = [
                'codigo' => 500,
                'msg' => 'Erro ao cadastrar reserva',
                'detalhes' => $reservaModel->errors()
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
        'msg' => $sucesso ? 'Reserva cadastrada com sucesso' : null,
        'erros' => $sucesso ? [] : $erros
    ]);
}



     public function listar()
{
    helper('helper');

    try {

        $model = new ReservaModel();

        $dados = $model
            ->select('
                reservas.id_reserva,
                reservas.id_veiculo,
                reservas.id_estacionamento,
                reservas.id_vaga,
                reservas.data_reserva,
                reservas.data_expiracao,
                reservas.data_checkin,
                reservas.data_checkout,
                reservas.data_cancelamento,
                reservas.valor,
                reservas.status
            ')
            ->orderBy('reservas.id_reserva', 'DESC')
            ->findAll();

        if (!$dados) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'msg' => 'Nenhuma reserva encontrada'
                ]]
            ]);
        }

        return $this->response->setJSON([
            'sucesso' => true,
            'total'   => count($dados),
            'dados'   => $dados
        ]);

    } catch (Exception $e) {

        return $this->response->setJSON([
            'sucesso' => false,
            'erros' => [[
                'codigo' => 0,
                'msg' => $e->getMessage()
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

        // ==================================================
        // ID DA URL
        // ==================================================
        $retId = validarDados($id, 'int', true);

        if ($retId['codigoHelper'] != 0) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'campo' => 'id_reserva',
                    'msg' => $retId['msg']
                ]]
            ]);
        }

        if (!$resultado) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 400,
                    'msg' => 'JSON inválido'
                ]]
            ]);
        }

        $model = new ReservaModel();

        // ==================================================
        // EXISTE RESERVA?
        // ==================================================
        $reserva = $model->find($id);

        if (!$reserva) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'msg' => 'Reserva não encontrada'
                ]]
            ]);
        }

        // ==================================================
        // NÃO ALTERA FINALIZADAS
        // ==================================================
        if (in_array($reserva['status'], ['CONCLUIDA', 'CANCELADA'])) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 51,
                    'msg' => 'Reserva finalizada não pode ser alterada'
                ]]
            ]);
        }

        // ==================================================
        // VALIDA CAMPOS
        // ==================================================
        $retDataReserva   = validarDados($resultado->data_reserva ?? null, 'date', true);
        $retExpiracao     = validarDados($resultado->data_expiracao ?? null, 'date', true);
        $retValor         = validarDados($resultado->valor ?? null, 'float', true);

        $validacoes = [
            ['ret' => $retDataReserva, 'campo' => 'data_reserva'],
            ['ret' => $retExpiracao, 'campo' => 'data_expiracao'],
            ['ret' => $retValor, 'campo' => 'valor']
        ];

        foreach ($validacoes as $v) {
            if ($v['ret']['codigoHelper'] != 0) {
                $erros[] = [
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

        // ==================================================
        // UPDATE
        // ==================================================
        $dados = [
            'data_reserva'   => $resultado->data_reserva,
            'data_expiracao' => $resultado->data_expiracao,
            'valor'          => $resultado->valor
        ];

        if ($model->update($id, $dados)) {
            $sucesso = true;
        } else {
            $erros[] = [
                'codigo' => 500,
                'msg' => 'Erro ao atualizar reserva',
                'detalhes' => $model->errors()
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
        'msg' => $sucesso ? 'Reserva atualizada com sucesso' : null,
        'erros' => $sucesso ? [] : $erros
    ]);
}





   public function deletar($id)
{
    helper('helper');

    $erros = [];
    $sucesso = false;

    try {

        // ==========================================
        // VALIDA ID
        // ==========================================
        $retId = validarDados($id, 'int', true);

        if ($retId['codigoHelper'] != 0) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'campo' => 'id_reserva',
                    'msg'   => $retId['msg']
                ]]
            ]);
        }

        $model = new ReservaModel();

        // ==========================================
        // VERIFICA EXISTÊNCIA
        // ==========================================
        $reserva = $model->find($id);

        if (!$reserva) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'msg' => 'Reserva não encontrada'
                ]]
            ]);
        }

        // ==========================================
        // NÃO PERMITE APAGAR CONCLUÍDA
        // ==========================================
        if ($reserva['status'] === 'CONCLUIDA') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 52,
                    'msg' => 'Reserva concluída não pode ser removida'
                ]]
            ]);
        }

        // ==========================================
        // SOFT DELETE
        // ==========================================
        $dados = [
            'status' => 'CANCELADA',
            'data_cancelamento' => date('Y-m-d H:i:s')
        ];

        if ($model->update($id, $dados)) {
            $sucesso = true;
        } else {
            $erros[] = [
                'codigo' => 500,
                'msg' => 'Erro ao cancelar reserva',
                'detalhes' => $model->errors()
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
        'msg' => $sucesso ? 'Reserva cancelada com sucesso' : null,
        'erros' => $sucesso ? [] : $erros
    ]);
}

}