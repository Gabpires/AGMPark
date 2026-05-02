<?php

namespace App\Controllers;

use App\Models\UsuarioModel;
use Exception;

class Usuarios extends BaseController
{
    private $idFuncionario;
    private $nome;
    private $cpfCnpj;
    private $email;
    private $dataNasc;
    private $telefone;
    private $senha;
    private $tipoUsuario;
    private $status;

    public function getStatus()
    {
        return $this->status;
    }

    public function setStatus($statusFront)
    {
        $this->status = $statusFront;
    }

    public function getIdFuncionario()
    {
        return $this->idFuncionario;
    }

    public function setIdFuncionario($idFuncionarioFront)
    {
        $this->idFuncionario = $idFuncionarioFront;
    }

    public function getNome()
    {
        return $this->nome;
    }

    public function setNome($nomeFront)
    {
        $this->nome = $nomeFront;
    }

    public function getCpfCnpj()
    {
        return $this->cpfCnpj;
    }

    public function setCpfCnpj($cpfCnpjFront)
    {
        $this->cpfCnpj = $cpfCnpjFront;
    }

    public function getEmail()
    {
        return $this->email;
    }

    public function setEmail($emailFront)
    {
        $this->email = $emailFront;
    }

    public function getDataNasc()
    {
        return $this->dataNasc;
    }

    public function setDataNasc($dataNascFront)
    {
        $this->dataNasc = $dataNascFront;
    }

    public function getTelefone()
    {
        return $this->telefone;
    }

    public function setTelefone($telefoneFront)
    {
        $this->telefone = $telefoneFront;
    }

    public function getSenha()
    {
        return $this->senha;
    }

    public function setSenha($senhaFront)
    {
        $this->senha = $senhaFront;
    }

    public function getTipoUsuario()
    {
        return $this->tipoUsuario;
    }

    public function setTipoUsuario($tipoUsuarioFront)
    {
        $this->tipoUsuario = $tipoUsuarioFront;
    }

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

            $lista = [
                'nome' => '0',
                'cpfCnpj' => '0',
                'email' => '0',
                'dataNasc' => '0',
                'telefone' => '0',
                'senha' => '0',
                'tipo' => '0',
            ];

            if (verificarParam($resultado, $lista) != 1) {
                $erros[] = [
                    'codigo' => 99,
                    'msg' => 'Campo não existe'
                ];
            } else {

                $retornoNome = validarDados($resultado->nome, 'string', true);
                $retornoCpfCnpj = validarDocumento($resultado->cpfCnpj);
                $retornoEmail = validarDados($resultado->email, 'email', true);
                $retornoDataNasc = validarDados($resultado->dataNasc, 'date', true);
                $retornoTelefone = validarDados($resultado->telefone, 'string', true);
                $retornoSenha = validarDados($resultado->senha, 'string', true);
                $retornoTipo = validarDados($resultado->tipo, 'string', true);

                if ($retornoNome['codigoHelper'] != 0) {
                    $erros[] = [
                        'codigo' => $retornoNome['codigoHelper'],
                        'campo' => 'Nome',
                        'msg' => $retornoNome['msg']
                    ];
                }

                if ($retornoCpfCnpj['codigoHelper'] != 0) {
                    $erros[] = [
                        'codigo' => $retornoCpfCnpj['codigoHelper'],
                        'campo' => 'CPF/CNPJ',
                        'msg' => $retornoCpfCnpj['msg']
                    ];
                }

                if ($retornoEmail['codigoHelper'] != 0) {
                    $erros[] = [
                        'codigo' => $retornoEmail['codigoHelper'],
                        'campo' => 'Email',
                        'msg' => $retornoEmail['msg']
                    ];
                }

                if ($retornoDataNasc['codigoHelper'] != 0) {
                    $erros[] = [
                        'codigo' => $retornoDataNasc['codigoHelper'],
                        'campo' => 'Data Nascimento',
                        'msg' => $retornoDataNasc['msg']
                    ];
                }

                if ($retornoTelefone['codigoHelper'] != 0) {
                    $erros[] = [
                        'codigo' => $retornoTelefone['codigoHelper'],
                        'campo' => 'Telefone',
                        'msg' => $retornoTelefone['msg']
                    ];
                }

                if ($retornoSenha['codigoHelper'] != 0) {
                    $erros[] = [
                        'codigo' => $retornoSenha['codigoHelper'],
                        'campo' => 'Senha',
                        'msg' => $retornoSenha['msg']
                    ];
                }

                if ($retornoTipo['codigoHelper'] != 0) {
                    $erros[] = [
                        'codigo' => $retornoTipo['codigoHelper'],
                        'campo' => 'Tipo',
                        'msg' => $retornoTipo['msg']
                    ];
                }

                if (!in_array($resultado->tipo, ['PROPRIETARIO', 'FUNCIONARIO'])) {
                    $erros[] = [
                        'codigo' => 100,
                        'campo' => 'Tipo',
                        'msg' => 'O campo tipo deve ser PROPRIETARIO ou FUNCIONARIO'
                    ];
                }

                if (empty($erros)) {
                    $this->setNome($resultado->nome);
                    $this->setCpfCnpj($resultado->cpfCnpj);
                    $this->setEmail($resultado->email);
                    $this->setDataNasc($resultado->dataNasc);
                    $this->setTelefone($resultado->telefone);
                    $this->setSenha(password_hash($resultado->senha, PASSWORD_DEFAULT));
                    $this->setTipoUsuario($resultado->tipo);

                    $model = new UsuarioModel();

                    $dados = [
                        'primeiro_nome'   => $this->getNome(),
                        'cpf_cnpj'        => $this->getCpfCnpj(),
                        'email'           => $this->getEmail(),
                        'data_nascimento' => $this->getDataNasc(),
                        'telefone'        => $this->getTelefone(),
                        'senha'           => $this->getSenha(),
                        'tipo_usuario'    => $this->getTipoUsuario(),
                        'status'         => 'ATIVO'
                    ];

                    $resBanco = $model->inserir($dados);

                    if ($resBanco) {
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
                'msg' => 'Funcionário cadastrado com sucesso'
            ]);
        }

        return $this->response->setJSON([
            'sucesso' => false,
            'erros' => $erros
        ]);
    }

    // essa parte eu acrecentei Adriano


    public function listar()
    {
        helper('helper');

        $erros = [];
        $sucesso = false;

        try {
            // GET → pega da URL (query params)
            $nome      = $this->request->getGet('nome');
            $cpfCnpj   = $this->request->getGet('cpfCnpj');
            $email     = $this->request->getGet('email');
            $dataNasc  = $this->request->getGet('dataNasc');
            $telefone  = $this->request->getGet('telefone');
            $tipo      = $this->request->getGet('tipo');
            $status    = $this->request->getGet('status');

            // Valida somente se vier preenchido
            if ($nome) {
                $retorno = validarDadosConsulta($nome, 'string');
                if ($retorno['codigoHelper'] != 0) {
                    $erros[] = ['campo' => 'Nome', 'msg' => $retorno['msg']];
                }
            }

            if ($cpfCnpj) {
                $retorno = validarDocumento($cpfCnpj);
                if ($retorno['codigoHelper'] != 0) {
                    $erros[] = ['campo' => 'CPF/CNPJ', 'msg' => $retorno['msg']];
                }
            }

            if ($email) {
                $retorno = validarDadosConsulta($email, 'email');
                if ($retorno['codigoHelper'] != 0) {
                    $erros[] = ['campo' => 'Email', 'msg' => $retorno['msg']];
                }
            }

            if ($tipo) {
                if (!in_array($tipo, ['PROPRIETARIO', 'FUNCIONARIO'])) {
                    $erros[] = [
                        'campo' => 'Tipo',
                        'msg' => 'Tipo deve ser PROPRIETARIO ou FUNCIONARIO'
                    ];
                }
            }

            // Se não houver erros
            if (empty($erros)) {

                // Setters (opcional, mas mantendo seu padrão)
                $this->setNome($nome);
                $this->setCpfCnpj($cpfCnpj);
                $this->setEmail($email);
                $this->setDataNasc($dataNasc);
                $this->setTelefone($telefone);
                $this->setTipoUsuario($tipo);
                $this->setStatus($status);

                $model = new UsuarioModel();

                // Monta filtros
                $filtros = [
                    'nome'     => $this->getNome(),
                    'cpfCnpj'  => $this->getCpfCnpj(),
                    'email'    => $this->getEmail(),
                    'dataNasc' => $this->getDataNasc(),
                    'telefone' => $this->getTelefone(),
                    'tipo'     => $this->getTipoUsuario(),
                    'status'   => $this->getStatus()
                ];

                $dados = $model->listar($filtros);

                $sucesso = true;

                return $this->response->setJSON([
                    'sucesso' => true,
                    'dados' => $dados
                ]);
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

        return $this->response->setJSON([
            'sucesso' => false,
            'erros' => $erros
        ]);
    }


    public function atualizar($id = null)
    {
        helper('helper');

        $erros = [];
        $sucesso = false;

        try {
            // Valida ID
            if (!$id) {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [
                        [
                            'codigo' => 400,
                            'msg' => 'ID não informado'
                        ]
                    ]
                ]);
            }

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

            // Validação (somente se vier preenchido)
            if (!empty($resultado->nome)) {
                $ret = validarDados($resultado->nome, 'string', true);
                if ($ret['codigoHelper'] != 0) {
                    $erros[] = ['campo' => 'Nome', 'msg' => $ret['msg']];
                }
            }

            if (!empty($resultado->cpfCnpj)) {
                $ret = validarDocumento($resultado->cpfCnpj);
                if ($ret['codigoHelper'] != 0) {
                    $erros[] = ['campo' => 'CPF/CNPJ', 'msg' => $ret['msg']];
                }
            }

            if (!empty($resultado->email)) {
                $ret = validarDados($resultado->email, 'email', true);
                if ($ret['codigoHelper'] != 0) {
                    $erros[] = ['campo' => 'Email', 'msg' => $ret['msg']];
                }
            }

            if (!empty($resultado->dataNasc)) {
                $ret = validarDados($resultado->dataNasc, 'date', true);
                if ($ret['codigoHelper'] != 0) {
                    $erros[] = ['campo' => 'Data Nascimento', 'msg' => $ret['msg']];
                }
            }

            if (!empty($resultado->telefone)) {
                $ret = validarDados($resultado->telefone, 'string', true);
                if ($ret['codigoHelper'] != 0) {
                    $erros[] = ['campo' => 'Telefone', 'msg' => $ret['msg']];
                }
            }

            if (!empty($resultado->senha)) {
                $ret = validarDados($resultado->senha, 'string', true);
                if ($ret['codigoHelper'] != 0) {
                    $erros[] = ['campo' => 'Senha', 'msg' => $ret['msg']];
                }
            }

            if (!empty($resultado->tipo)) {
                if (!in_array($resultado->tipo, ['PROPRIETARIO', 'FUNCIONARIO'])) {
                    $erros[] = [
                        'campo' => 'Tipo',
                        'msg' => 'Tipo deve ser PROPRIETARIO ou FUNCIONARIO'
                    ];
                }
            }

            // Se não houver erros
            if (empty($erros)) {

                // Setters (somente se vier valor)
                if (isset($resultado->nome)) {
                    $this->setNome($resultado->nome);
                }

                if (isset($resultado->cpfCnpj)) {
                    $this->setCpfCnpj($resultado->cpfCnpj);
                }

                if (isset($resultado->email)) {
                    $this->setEmail($resultado->email);
                }

                if (isset($resultado->dataNasc)) {
                    $this->setDataNasc($resultado->dataNasc);
                }

                if (isset($resultado->telefone)) {
                    $this->setTelefone($resultado->telefone);
                }

                if (isset($resultado->senha)) {
                    $this->setSenha(password_hash($resultado->senha, PASSWORD_DEFAULT));
                }

                if (isset($resultado->tipo)) {
                    $this->setTipoUsuario($resultado->tipo);
                }

                if (isset($resultado->status)) {
                    $this->setStatus($resultado->status);
                }

                $model = new UsuarioModel();

                // Monta apenas os campos que vieram
                $dados = [];

                if ($this->getNome()) {
                    $dados['primeiro_nome'] = $this->getNome();
                }

                if ($this->getCpfCnpj()) {
                    $dados['cpf_cnpj'] = $this->getCpfCnpj();
                }

                if ($this->getEmail()) {
                    $dados['email'] = $this->getEmail();
                }

                if ($this->getDataNasc()) {
                    $dados['data_nascimento'] = $this->getDataNasc();
                }

                if ($this->getTelefone()) {
                    $dados['telefone'] = $this->getTelefone();
                }

                if ($this->getSenha()) {
                    $dados['senha'] = $this->getSenha();
                }

                if ($this->getTipoUsuario()) {
                    $dados['tipo_usuario'] = $this->getTipoUsuario();
                }

                if ($this->getStatus()) {
                    $dados['status'] = $this->getStatus();
                }

                if (empty($dados)) {
                    return $this->response->setJSON([
                        'sucesso' => false,
                        'erros' => [
                            [
                                'codigo' => 400,
                                'msg' => 'Nenhum dado para atualizar'
                            ]
                        ]
                    ]);
                }


                $resBanco = $model->update($id, $dados);

                // parte de não poder realizar alteraçõee em usuario já inativo
                $model = new UsuarioModel();

                $usuario = $model->find($id);

                // Não existe
                if (!$usuario) {
                    return $this->response->setJSON([
                        'sucesso' => false,
                        'erros' => [
                            [
                                'codigo' => 404,
                                'msg' => 'Usuário não encontrado'
                            ]
                        ]
                    ]);
                }

                // BLOQUEIO PRINCIPAL
                if ($usuario['status'] === 'INATIVO') {
                    return $this->response->setJSON([
                        'sucesso' => false,
                        'erros' => [
                            [
                                'codigo' => 403,
                                'msg' => 'Usuário INATIVO não pode ser alterado'
                            ]
                        ]
                    ]);
                }


                ///////////////////////////////////////////////////////////////



                if ($resBanco) {
                    $sucesso = true;
                } else {
                    $erros[] = [
                        'codigo' => 500,
                        'msg' => 'Erro ao atualizar no banco',
                        'detalhes' => $model->errors()
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
                'msg' => 'Usuário atualizado com sucesso'
            ]);
        }

        return $this->response->setJSON([
            'sucesso' => false,
            'erros' => $erros
        ]);
    }


    public function deletar($id = null)
    {
        $erros = [];
        $sucesso = false;

        try {
            // Valida ID
            if (!$id) {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [
                        [
                            'codigo' => 400,
                            'msg' => 'ID não informado'
                        ]
                    ]
                ]);
            }

            $model = new UsuarioModel();

            // Verifica se existe
            $usuario = $model->find($id);

            if (!$usuario) {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [
                        [
                            'codigo' => 404,
                            'msg' => 'Usuário não encontrado'
                        ]
                    ]
                ]);
            }

            ///deletar usuario não podendo atualizar dado de um usuário já deletado
            if ($usuario['status'] === 'INATIVO') {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [
                        [
                            'codigo' => 400,
                            'msg' => 'Usuário já está inativo'
                        ]
                    ]
                ]);
            }


            ///////////////////////////////////////////

            // Verifica se já está inativo
            if ($usuario['status'] === 'INATIVO') {
                return $this->response->setJSON([
                    'sucesso' => false,
                    'erros' => [
                        [
                            'codigo' => 400,
                            'msg' => 'Usuário já está inativo'
                        ]
                    ]
                ]);
            }

            // Atualiza status para INATIVO
            $resBanco = $model->update($id, [
                'status' => 'INATIVO'
            ]);

            if ($resBanco) {
                $sucesso = true;
            } else {
                $erros[] = [
                    'codigo' => 500,
                    'msg' => 'Erro ao desabilitar usuário',
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
                'msg' => 'Usuário desabilitado com sucesso'
            ]);
        }

        return $this->response->setJSON([
            'sucesso' => false,
            'erros' => $erros
        ]);
    }
}
