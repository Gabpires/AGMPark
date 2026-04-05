<?php

namespace App\Controllers;

use App\Models\EstacionamentoModel;
use Exception;

class Estacionamentos extends BaseController
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
                    'erros' => [
                        [
                            'codigo' => 400,
                            'msg' => 'JSON inválido ou vazio'
                        ]
                    ]
                ]);
            }

            // Campos esperados
            $lista = [
                'nome' => '0',
                'rua' => '0',
                'bairro' => '0',
                'cidade' => '0',
                'estado' => '0',
                'numeroEstacionamento' => '0',
                'cep' => '0',
                'quantidadeTempo' => '0',
                'valorTempo' => '0',
                'numeroVagas' => '0'
            ];

            if (verificarParam($resultado, $lista) != 1) {
                $erros[] = [
                    'codigo' => 99,
                    'msg' => 'Campos inexistentes'
                ];
            } else {

                // Validações
                $retNome = validarDados($resultado->nome, 'string', true);
                $retRua = validarDados($resultado->rua, 'string', true);
                $retBairro = validarDados($resultado->bairro, 'string', true);
                $retCidade = validarDados($resultado->cidade, 'string', true);

                // estado (UF)
                $retEstado = validarDados($resultado->estado, 'string', true);
                if (strlen($resultado->estado) != 2) {
                    $retEstado = [
                        'codigoHelper' => 1,
                        'msg' => 'Estado deve ter 2 caracteres (UF)'
                    ];
                }

                $retNumeroEstacionamento = validarDados($resultado->numeroEstacionamento, 'int', true);
                $retCep = validarCEPCompleto($resultado->cep);
                $retQuantidadeTempo = validarDados($resultado->quantidadeTempo, 'int', true);
                $retValorTempo = validarDados($resultado->valorTempo, 'float', true);
                $retNumeroVagas = validarDados($resultado->numeroVagas, 'int', true);

                // Tratamento de erros
                $validacoes = [
                    ['ret' => $retNome, 'campo' => 'Nome'],
                    ['ret' => $retRua, 'campo' => 'Rua'],
                    ['ret' => $retBairro, 'campo' => 'Bairro'],
                    ['ret' => $retCidade, 'campo' => 'Cidade'],
                    ['ret' => $retEstado, 'campo' => 'Estado'],
                    ['ret' => $retNumeroEstacionamento, 'campo' => 'NumeroEstacionamento'],
                    ['ret' => $retCep, 'campo' => 'CEP'],
                    ['ret' => $retQuantidadeTempo, 'campo' => 'QuantidadeTempo'],
                    ['ret' => $retValorTempo, 'campo' => 'ValorTempo'],
                    ['ret' => $retNumeroVagas, 'campo' => 'NumeroVagas']
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

                // Se não houver erros
                if (empty($erros)) {

                    $model = new EstacionamentoModel();

                    $dados = [
                        'nome' => $resultado->nome,
                        'rua' => $resultado->rua,
                        'bairro' => $resultado->bairro,
                        'cidade' => $resultado->cidade,
                        'estado' => strtoupper($resultado->estado),
                        'numero_estacionamento' => $resultado->numeroEstacionamento,
                        'cep' => $resultado->cep,
                        'quantidade_tempo' => $resultado->quantidadeTempo,
                        'valor_tempo' => $resultado->valorTempo,
                        'numero_vagas' => $resultado->numeroVagas,
                        'status' => 'ATIVO'
                    ];

                    // INSERT padrão do CodeIgniter
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
                'erros' => [
                    [
                        'codigo' => 0,
                        'msg' => 'Erro: ' . $e->getMessage()
                    ]
                ]
            ]);
        }

        if ($sucesso) {
            return $this->response->setJSON([
                'sucesso' => true,
                'msg' => 'Estacionamento cadastrado com sucesso'
            ]);
        }

        return $this->response->setJSON([
            'sucesso' => false,
            'erros' => $erros
        ]);
    }


   public function listar()
{
    helper('helper');

    $erros = [];
    $sucesso = false;
    $dados = [];

    try {

        // Parâmetros via GET (opcional)
        $id = $this->request->getGet('id_estacionamento');
        $status = $this->request->getGet('status');

        $model = new EstacionamentoModel();

        // Monta a query dinamicamente
        if ($id) {
            $retId = validarDados($id, 'int', true);

            if ($retId['codigoHelper'] != 0) {
                $erros[] = [
                    'codigo' => $retId['codigoHelper'],
                    'campo' => 'id_estacionamento',
                    'msg' => $retId['msg']
                ];
            } else {
                $model->where('id_estacionamento', $id);
            }
        }

        if ($status) {
            $model->where('status', strtoupper($status));
        }

        // Se não houver erro de validação
        if (empty($erros)) {

            $resultado = $model->findAll();

            if ($resultado) {
                $sucesso = true;
                $dados = $resultado;
            } else {
                $erros[] = [
                    'codigo' => 404,
                    'msg' => 'Nenhum registro encontrado'
                ];
            }
        }

    } catch (Exception $e) {
        return $this->response->setJSON([
            'sucesso' => false,
            'erros' => [
                [
                    'codigo' => 0,
                    'msg' => 'Erro: ' . $e->getMessage()
                ]
            ]
        ]);
    }

    if ($sucesso) {
        return $this->response->setJSON([
            'sucesso' => true,
            'dados' => $dados
        ]);
    }

    return $this->response->setJSON([
        'sucesso' => false,
        'erros' => $erros
    ]);
}


public function atualizar()
{
    helper('helper');

    $erros = [];
    $sucesso = false;

    try {
        $resultado = $this->request->getJSON();

        if (!$resultado) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [
                    [
                        'codigo' => 400,
                        'msg' => 'JSON inválido ou vazio'
                    ]
                ]
            ]);
        }

        // ID obrigatório para atualizar
        if (!isset($resultado->id_estacionamento)) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [
                    [
                        'codigo' => 98,
                        'msg' => 'ID do estacionamento é obrigatório'
                    ]
                ]
            ]);
        }

        // Validação do ID
        $retId = validarDados($resultado->id_estacionamento, 'int', true);
        if ($retId['codigoHelper'] != 0) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [
                    [
                        'codigo' => $retId['codigoHelper'],
                        'campo' => 'id_estacionamento',
                        'msg' => $retId['msg']
                    ]
                ]
            ]);
        }

        $model = new EstacionamentoModel();

        // Verifica se existe
        $registro = $model->find($resultado->id_estacionamento);

        if (!$registro) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [
                    [
                        'codigo' => 404,
                        'msg' => 'Estacionamento não encontrado'
                    ]
                ]
            ]);
        }

        // BLOQUEIO SE INATIVO (regra de negócio)
        if ($registro['status'] === 'INATIVO') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [
                    [
                        'codigo' => 403,
                        'msg' => 'Não é possível alterar um estacionamento inativo'
                    ]
                ]
            ]);
        }

        // Campos esperados
        $lista = [
            'nome' => '0',
            'rua' => '0',
            'bairro' => '0',
            'cidade' => '0',
            'estado' => '0',
            'numeroEstacionamento' => '0',
            'cep' => '0',
            'quantidadeTempo' => '0',
            'valorTempo' => '0',
            'numeroVagas' => '0'
        ];

        if (verificarParam($resultado, $lista) != 1) {
            $erros[] = [
                'codigo' => 99,
                'msg' => 'Campos inexistentes'
            ];
        } else {

            // Validações
            $retNome = validarDados($resultado->nome, 'string', true);
            $retRua = validarDados($resultado->rua, 'string', true);
            $retBairro = validarDados($resultado->bairro, 'string', true);
            $retCidade = validarDados($resultado->cidade, 'string', true);

            $retEstado = validarDados($resultado->estado, 'string', true);
            if (strlen($resultado->estado) != 2) {
                $retEstado = [
                    'codigoHelper' => 1,
                    'msg' => 'Estado deve ter 2 caracteres (UF)'
                ];
            }

            $retNumeroEstacionamento = validarDados($resultado->numeroEstacionamento, 'int', true);
            $retCep = validarDados($resultado->cep, 'string', true);
            $retQuantidadeTempo = validarDados($resultado->quantidadeTempo, 'int', true);
            $retValorTempo = validarDados($resultado->valorTempo, 'float', true);
            $retNumeroVagas = validarDados($resultado->numeroVagas, 'int', true);

            // Tratamento de erros
            $validacoes = [
                ['ret' => $retNome, 'campo' => 'Nome'],
                ['ret' => $retRua, 'campo' => 'Rua'],
                ['ret' => $retBairro, 'campo' => 'Bairro'],
                ['ret' => $retCidade, 'campo' => 'Cidade'],
                ['ret' => $retEstado, 'campo' => 'Estado'],
                ['ret' => $retNumeroEstacionamento, 'campo' => 'NumeroEstacionamento'],
                ['ret' => $retCep, 'campo' => 'CEP'],
                ['ret' => $retQuantidadeTempo, 'campo' => 'QuantidadeTempo'],
                ['ret' => $retValorTempo, 'campo' => 'ValorTempo'],
                ['ret' => $retNumeroVagas, 'campo' => 'NumeroVagas']
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

            // Se não houver erros
            if (empty($erros)) {

                $dados = [
                    'nome' => $resultado->nome,
                    'rua' => $resultado->rua,
                    'bairro' => $resultado->bairro,
                    'cidade' => $resultado->cidade,
                    'estado' => strtoupper($resultado->estado),
                    'numero_estacionamento' => $resultado->numeroEstacionamento,
                    'cep' => $resultado->cep,
                    'quantidade_tempo' => $resultado->quantidadeTempo,
                    'valor_tempo' => $resultado->valorTempo,
                    'numero_vagas' => $resultado->numeroVagas
                ];

                // UPDATE padrão
                if ($model->update($resultado->id_estacionamento, $dados)) {
                    $sucesso = true;
                } else {
                    $erros[] = [
                        'codigo' => 500,
                        'msg' => 'Erro ao atualizar no banco',
                        'detalhes' => $model->errors()
                    ];
                }
            }
        }

    } catch (Exception $e) {
        return $this->response->setJSON([
            'sucesso' => false,
            'erros' => [
                [
                    'codigo' => 0,
                    'msg' => 'Erro: ' . $e->getMessage()
                ]
            ]
        ]);
    }

    if ($sucesso) {
        return $this->response->setJSON([
            'sucesso' => true,
            'msg' => 'Estacionamento atualizado com sucesso'
        ]);
    }

    return $this->response->setJSON([
        'sucesso' => false,
        'erros' => $erros
    ]);
}



public function deletar($id = null)
{
    helper('helper');

    $erros = [];
    $sucesso = false;

    try {

        // ID obrigatório
        if (!$id) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [
                    [
                        'codigo' => 98,
                        'msg' => 'ID do estacionamento é obrigatório'
                    ]
                ]
            ]);
        }

        // Validação do ID
        $retId = validarDados($id, 'int', true);
        if ($retId['codigoHelper'] != 0) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [
                    [
                        'codigo' => $retId['codigoHelper'],
                        'campo' => 'id_estacionamento',
                        'msg' => $retId['msg']
                    ]
                ]
            ]);
        }

        $model = new EstacionamentoModel();

        // Verifica se existe
        $registro = $model->find($id);

        if (!$registro) {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [
                    [
                        'codigo' => 404,
                        'msg' => 'Estacionamento não encontrado'
                    ]
                ]
            ]);
        }

        // Já está inativo
        if ($registro['status'] === 'INATIVO') {
            return $this->response->setJSON([
                'sucesso' => false,
                'erros' => [
                    [
                        'codigo' => 409,
                        'msg' => 'Estacionamento já está inativo'
                    ]
                ]
            ]);
        }

        // Soft delete
        if ($model->update($id, ['status' => 'INATIVO'])) {
            $sucesso = true;
        } else {
            $erros[] = [
                'codigo' => 500,
                'msg' => 'Erro ao deletar',
                'detalhes' => $model->errors()
            ];
        }

    } catch (Exception $e) {
        return $this->response->setJSON([
            'sucesso' => false,
            'erros' => [
                [
                    'codigo' => 0,
                    'msg' => 'Erro: ' . $e->getMessage()
                ]
            ]
        ]);
    }

    if ($sucesso) {
        return $this->response->setJSON([
            'sucesso' => true,
            'msg' => 'Estacionamento inativado com sucesso'
        ]);
    }

    return $this->response->setJSON([
        'sucesso' => false,
        'erros' => $erros
    ]);
}




}