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
                $retornoCpfCnpj = validarCPF($resultado->cpfCnpj, 'string', true);
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
                        'istatus'         => 'ATIVO'
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
}
