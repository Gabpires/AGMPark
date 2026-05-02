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

        if (!$resultado) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 400,
                    'msg' => 'JSON inválido ou vazio'
                ]]
            ]);
        }

        $retIdVeiculo = validarDados($resultado->id_veiculo ?? null, 'int', true);
        $retIdEstacionamento = validarDados($resultado->id_estacionamento ?? null, 'int', true);
        $retIdVaga = validarDados($resultado->id_vaga ?? null, 'int', true);
        $retDataReserva = validarDados($resultado->data_reserva ?? null, 'datetime', true);
        $retDataExpiracao = validarDados($resultado->data_expiracao ?? null, 'datetime', true);
        $retValor = validarDados($resultado->valor ?? null, 'float', false);

        $validacoes = [
            ['ret' => $retIdVeiculo, 'campo' => 'id_veiculo'],
            ['ret' => $retIdEstacionamento, 'campo' => 'id_estacionamento'],
            ['ret' => $retIdVaga, 'campo' => 'id_vaga'],
            ['ret' => $retDataReserva, 'campo' => 'data_reserva'],
            ['ret' => $retDataExpiracao, 'campo' => 'data_expiracao'],
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

        if (!empty($erros)) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => $erros
            ]);
        }

        $reservaModel = new \App\Models\ReservaModel();
        $veiculoModel = new \App\Models\VeiculoModel();
        $estacionamentoModel = new \App\Models\EstacionamentoModel();
        $vagaModel = new \App\Models\VagaModel();

        $veiculo = $veiculoModel->find($resultado->id_veiculo);

        if (!$veiculo) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'campo' => 'id_veiculo',
                    'msg' => 'Veículo não encontrado'
                ]]
            ]);
        }

        if ($veiculo['status'] !== 'ATIVO') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 42,
                    'campo' => 'id_veiculo',
                    'msg' => 'Veículo inativo'
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

        $vaga = $vagaModel->find($resultado->id_vaga);

        if (!$vaga) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'campo' => 'id_vaga',
                    'msg' => 'Vaga não encontrada'
                ]]
            ]);
        }

        if ($vaga['id_estacionamento'] != $resultado->id_estacionamento) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 44,
                    'campo' => 'id_vaga',
                    'msg' => 'Esta vaga não pertence ao estacionamento informado'
                ]]
            ]);
        }

        if ($vaga['status'] !== 'LIVRE') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 45,
                    'campo' => 'id_vaga',
                    'msg' => 'Vaga não está disponível para reserva'
                ]]
            ]);
        }

        $reservaAtiva = $reservaModel
            ->where('id_veiculo', $resultado->id_veiculo)
            ->whereIn('status', ['ATIVA'])
            ->first();

        if ($reservaAtiva) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 50,
                    'campo' => 'id_veiculo',
                    'msg' => 'Veículo já possui uma reserva ativa'
                ]]
            ]);
        }

        $dados = [
            'id_veiculo' => $resultado->id_veiculo,
            'id_estacionamento' => $resultado->id_estacionamento,
            'id_vaga' => $resultado->id_vaga,
            'data_reserva' => $resultado->data_reserva,
            'data_expiracao' => $resultado->data_expiracao,
            'data_cancelamento' => null,
            'valor' => $resultado->valor,
            'status' => 'ATIVA'
        ];

        if ($reservaModel->insert($dados)) {
            $vagaModel->update($resultado->id_vaga, [
                'status' => 'RESERVADA'
            ]);

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
                'msg' => 'Erro: ' . $e->getMessage()
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
        $model = new \App\Models\ReservaModel();

        $dados = $model
            ->select('
                reservas.id_reserva,
                reservas.id_veiculo,
                reservas.id_estacionamento,
                reservas.id_vaga,
                reservas.data_reserva,
                reservas.data_expiracao,
                reservas.data_cancelamento,
                reservas.valor,
                reservas.status,
                reservas.created_at,
                reservas.updated_at,

                veiculos.modelo,
                veiculos.marca,
                veiculos.placa,

                estacionamento.nome AS nome_estacionamento,
                estacionamento.cidade,
                estacionamento.estado,

                vagas.numero_vaga,
                vagas.status AS status_vaga
            ')
            ->join('veiculos', 'veiculos.id_veiculo = reservas.id_veiculo')
            ->join('estacionamento', 'estacionamento.id_estacionamento = reservas.id_estacionamento')
            ->join('vagas', 'vagas.id_vaga = reservas.id_vaga', 'left')
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
        $retIdVeiculo = validarDados($resultado->id_veiculo ?? null, 'int', true);
        $retIdEstacionamento = validarDados($resultado->id_estacionamento ?? null, 'int', true);
        $retIdVaga = validarDados($resultado->id_vaga ?? null, 'int', true);
        $retDataReserva = validarDados($resultado->data_reserva ?? null, 'datetime', true);
        $retDataExpiracao = validarDados($resultado->data_expiracao ?? null, 'datetime', true);
        $retValor = validarDados($resultado->valor ?? null, 'float', false);

        $validacoes = [
            ['ret' => $retId, 'campo' => 'id_reserva'],
            ['ret' => $retIdVeiculo, 'campo' => 'id_veiculo'],
            ['ret' => $retIdEstacionamento, 'campo' => 'id_estacionamento'],
            ['ret' => $retIdVaga, 'campo' => 'id_vaga'],
            ['ret' => $retDataReserva, 'campo' => 'data_reserva'],
            ['ret' => $retDataExpiracao, 'campo' => 'data_expiracao'],
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

        if (!empty($erros)) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => $erros
            ]);
        }

        $reservaModel = new \App\Models\ReservaModel();
        $veiculoModel = new \App\Models\VeiculoModel();
        $estacionamentoModel = new \App\Models\EstacionamentoModel();
        $vagaModel = new \App\Models\VagaModel();

        $reserva = $reservaModel->find($id);

        if (!$reserva) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'campo' => 'id_reserva',
                    'msg' => 'Reserva não encontrada'
                ]]
            ]);
        }

        if ($reserva['status'] !== 'ATIVA') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 51,
                    'campo' => 'status',
                    'msg' => 'Apenas reservas ATIVAS podem ser atualizadas'
                ]]
            ]);
        }

        $veiculo = $veiculoModel->find($resultado->id_veiculo);

        if (!$veiculo) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'campo' => 'id_veiculo',
                    'msg' => 'Veículo não encontrado'
                ]]
            ]);
        }

        if ($veiculo['status'] !== 'ATIVO') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 42,
                    'campo' => 'id_veiculo',
                    'msg' => 'Veículo inativo'
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

        $vaga = $vagaModel->find($resultado->id_vaga);

        if (!$vaga) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'campo' => 'id_vaga',
                    'msg' => 'Vaga não encontrada'
                ]]
            ]);
        }

        if ($vaga['id_estacionamento'] != $resultado->id_estacionamento) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 44,
                    'campo' => 'id_vaga',
                    'msg' => 'Esta vaga não pertence ao estacionamento informado'
                ]]
            ]);
        }

        if ($vaga['status'] !== 'LIVRE' && $vaga['id_vaga'] != $reserva['id_vaga']) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 45,
                    'campo' => 'id_vaga',
                    'msg' => 'Vaga não está disponível para reserva'
                ]]
            ]);
        }

        $reservaAtiva = $reservaModel
            ->where('id_veiculo', $resultado->id_veiculo)
            ->where('status', 'ATIVA')
            ->where('id_reserva !=', $id)
            ->first();

        if ($reservaAtiva) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 50,
                    'campo' => 'id_veiculo',
                    'msg' => 'Veículo já possui outra reserva ativa'
                ]]
            ]);
        }

        if ($reserva['id_vaga'] != $resultado->id_vaga) {
            $vagaModel->update($reserva['id_vaga'], [
                'status' => 'LIVRE'
            ]);

            $vagaModel->update($resultado->id_vaga, [
                'status' => 'RESERVADA'
            ]);
        }

        $dados = [
            'id_veiculo' => $resultado->id_veiculo,
            'id_estacionamento' => $resultado->id_estacionamento,
            'id_vaga' => $resultado->id_vaga,
            'data_reserva' => $resultado->data_reserva,
            'data_expiracao' => $resultado->data_expiracao,
            'valor' => $resultado->valor,
            'status' => 'ATIVA'
        ];

        if ($reservaModel->update($id, $dados)) {
            $sucesso = true;
        } else {
            $erros[] = [
                'codigo' => 500,
                'msg' => 'Erro ao atualizar reserva',
                'detalhes' => $reservaModel->errors()
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
        // Valida ID
        $retId = validarDados($id, 'int', true);

        if ($retId['codigoHelper'] != 0) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => $retId['codigoHelper'],
                    'campo' => 'id_reserva',
                    'msg' => $retId['msg']
                ]]
            ]);
        }

        $reservaModel = new \App\Models\ReservaModel();
        $vagaModel = new \App\Models\VagaModel();

        // Verifica se a reserva existe
        $reserva = $reservaModel->find($id);

        if (!$reserva) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 404,
                    'msg' => 'Reserva não encontrada'
                ]]
            ]);
        }

        // Não permite cancelar reserva já concluída
        if ($reserva['status'] === 'CONCLUIDA') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 51,
                    'msg' => 'Reserva concluída não pode ser cancelada'
                ]]
            ]);
        }

        // Não permite cancelar novamente
        if ($reserva['status'] === 'CANCELADA') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [[
                    'codigo' => 52,
                    'msg' => 'Reserva já está cancelada'
                ]]
            ]);
        }

        // Libera a vaga se a reserva tiver uma vaga vinculada
        if (!empty($reserva['id_vaga'])) {
            $vagaModel->update($reserva['id_vaga'], [
                'status' => 'LIVRE'
            ]);
        }

        // Soft delete da reserva
        $dados = [
            'status' => 'CANCELADA',
            'data_cancelamento' => date('Y-m-d H:i:s')
        ];

        if ($reservaModel->update($id, $dados)) {
            $sucesso = true;
        } else {
            $erros[] = [
                'codigo' => 500,
                'msg' => 'Erro ao cancelar reserva',
                'detalhes' => $reservaModel->errors()
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
        'msg' => $sucesso ? 'Reserva cancelada com sucesso' : null,
        'erros' => $sucesso ? [] : $erros
    ]);
}

  


}