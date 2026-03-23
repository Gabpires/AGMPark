<?php

if (!function_exists('verificarParam')) {
    function verificarParam($atributos, $lista): int
    {
        if (!is_object($atributos)) {
            return 0;
        }

        $atributosArray = get_object_vars($atributos);

        foreach ($lista as $key => $value) {
            if (!array_key_exists($key, $atributosArray)) {
                return 0;
            }
        }

        return 1;
    }
}

if (!function_exists('validarDados')) {
    function validarDados($valor, string $tipo, bool $tamanhoZero = true): array
    {
        if (is_null($valor) || $valor === '') {
            return ['codigoHelper' => 2, 'msg' => 'Conteúdo nulo ou vazio.'];
        }

        if ($tamanhoZero && ($valor === 0 || $valor === '0')) {
            return ['codigoHelper' => 3, 'msg' => 'Conteúdo zerado.'];
        }

        switch ($tipo) {
            case 'int':
                if (filter_var($valor, FILTER_VALIDATE_INT) === false) {
                    return ['codigoHelper' => 4, 'msg' => 'Conteúdo não inteiro.'];
                }
                break;

            case 'string':
                if (!is_string($valor) || trim($valor) === '') {
                    return ['codigoHelper' => 5, 'msg' => 'Conteúdo não é um texto.'];
                }
                break;

            case 'date':
                if (!preg_match('/^(\d{4})-(\d{2})-(\d{2})$/', (string) $valor)) {
                    return ['codigoHelper' => 6, 'msg' => 'Data em formato inválido.'];
                }

                $d = DateTime::createFromFormat('Y-m-d', (string) $valor);
                if (!$d || $d->format('Y-m-d') !== $valor) {
                    return ['codigoHelper' => 6, 'msg' => 'Data inválida.'];
                }
                break;

            case 'hora':
                if (!preg_match('/^(?:[01]\d|2[0-3]):[0-5]\d$/', (string) $valor)) {
                    return ['codigoHelper' => 7, 'msg' => 'Hora em formato inválido.'];
                }
                break;

            case 'email':
                if (!filter_var($valor, FILTER_VALIDATE_EMAIL)) {
                    return ['codigoHelper' => 8, 'msg' => 'Email em formato inválido.'];
                }
                break;

            default:
                return ['codigoHelper' => 97, 'msg' => 'Tipo de dado não definido.'];
        }

        return ['codigoHelper' => 0, 'msg' => 'Validação correta.'];
    }
}

if (!function_exists('validarDadosConsulta')) {
    function validarDadosConsulta($valor, string $tipo): array
    {
        if ($valor === '' || $valor === null) {
            return ['codigoHelper' => 0, 'msg' => 'Validação correta.'];
        }

        switch ($tipo) {
            case 'int':
                if (filter_var($valor, FILTER_VALIDATE_INT) === false) {
                    return ['codigoHelper' => 4, 'msg' => 'Conteúdo não inteiro.'];
                }
                break;

            case 'string':
                if (!is_string($valor) || trim($valor) === '') {
                    return ['codigoHelper' => 5, 'msg' => 'Conteúdo não é um texto.'];
                }
                break;

            case 'date':
                if (!preg_match('/^(\d{4})-(\d{2})-(\d{2})$/', (string) $valor)) {
                    return ['codigoHelper' => 6, 'msg' => 'Data em formato inválido.'];
                }

                $d = \DateTime::createFromFormat('Y-m-d', (string) $valor);
                if (!$d || $d->format('Y-m-d') !== $valor) {
                    return ['codigoHelper' => 6, 'msg' => 'Data inválida.'];
                }
                break;

            case 'hora':
                if (!preg_match('/^(?:[01]\d|2[0-3]):[0-5]\d$/', (string) $valor)) {
                    return ['codigoHelper' => 7, 'msg' => 'Hora em formato inválido.'];
                }
                break;

            case 'email':
                if (!filter_var($valor, FILTER_VALIDATE_EMAIL)) {
                    return ['codigoHelper' => 8, 'msg' => 'Email em formato inválido.'];
                }
                break;

            default:
                return ['codigoHelper' => 97, 'msg' => 'Tipo de dado não definido.'];
        }

        return ['codigoHelper' => 0, 'msg' => 'Validação correta.'];
    }
}

if (!function_exists('validarCPF')) {
    function validarCPF(string $cpf): array
    {
        $cpf = preg_replace('/[^0-9]/', '', $cpf);

        if (strlen($cpf) !== 11) {
            return ['codigoHelper' => 15, 'msg' => 'CPF com menos de 11 dígitos.'];
        }

        if (preg_match('/^(\d)\1{10}$/', $cpf)) {
            return ['codigoHelper' => 16, 'msg' => 'CPF com todos dígitos iguais.'];
        }

        for ($t = 9; $t < 11; $t++) {
            $soma = 0;

            for ($i = 0; $i < $t; $i++) {
                $soma += $cpf[$i] * (($t + 1) - $i);
            }

            $digito = ((10 * $soma) % 11) % 10;

            if ((int) $cpf[$t] !== $digito) {
                return ['codigoHelper' => 17, 'msg' => 'CPF com dígitos verificadores incorretos.'];
            }
        }

        return ['codigoHelper' => 0, 'msg' => 'CPF válido.'];
    }
}
