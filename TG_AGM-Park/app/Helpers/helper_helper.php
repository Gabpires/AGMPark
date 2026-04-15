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

    case 'float':
        if (!is_numeric($valor)) {
            return ['codigoHelper' => 9, 'msg' => 'Conteúdo não é um número decimal.'];
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

//         switch ($tipo) {
//             case 'int':
//                 if (filter_var($valor, FILTER_VALIDATE_INT) === false) {
//                     return ['codigoHelper' => 4, 'msg' => 'Conteúdo não inteiro.'];
//                 }
//                 break;

//             case 'string':
//                 if (!is_string($valor) || trim($valor) === '') {
//                     return ['codigoHelper' => 5, 'msg' => 'Conteúdo não é um texto.'];
//                 }
//                 break;

//             case 'date':
//                 if (!preg_match('/^(\d{4})-(\d{2})-(\d{2})$/', (string) $valor)) {
//                     return ['codigoHelper' => 6, 'msg' => 'Data em formato inválido.'];
//                 }

//                 $d = DateTime::createFromFormat('Y-m-d', (string) $valor);
//                 if (!$d || $d->format('Y-m-d') !== $valor) {
//                     return ['codigoHelper' => 6, 'msg' => 'Data inválida.'];
//                 }
//                 break;

//             case 'hora':
//                 if (!preg_match('/^(?:[01]\d|2[0-3]):[0-5]\d$/', (string) $valor)) {
//                     return ['codigoHelper' => 7, 'msg' => 'Hora em formato inválido.'];
//                 }
//                 break;

//             case 'email':
//                 if (!filter_var($valor, FILTER_VALIDATE_EMAIL)) {
//                     return ['codigoHelper' => 8, 'msg' => 'Email em formato inválido.'];
//                 }
//                 break;

//             default:
//                 return ['codigoHelper' => 97, 'msg' => 'Tipo de dado não definido.'];
//         }

//         return ['codigoHelper' => 0, 'msg' => 'Validação correta.'];
//     }
// }

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


//     if (!function_exists('validarCNPJ')) {
//     function validarCNPJ(string $cnpj): array
//     {
//         // Remove tudo que não for número
//         $cnpj = preg_replace('/[^0-9]/', '', $cnpj);

//         // Valida tamanho
//         if (strlen($cnpj) !== 14) {
//             return ['codigoHelper' => 18, 'msg' => 'CNPJ deve conter 14 dígitos.'];
//         }

//         // Verifica se todos os dígitos são iguais
//         if (preg_match('/^(\d)\1{13}$/', $cnpj)) {
//             return ['codigoHelper' => 19, 'msg' => 'CNPJ com todos dígitos iguais.'];
//         }

//         // Validação do 1º dígito verificador
//         $pesos1 = [5,4,3,2,9,8,7,6,5,4,3,2];
//         $soma = 0;

//         for ($i = 0; $i < 12; $i++) {
//             $soma += $cnpj[$i] * $pesos1[$i];
//         }

//         $resto = $soma % 11;
//         $digito1 = ($resto < 2) ? 0 : 11 - $resto;

//         if ((int)$cnpj[12] !== $digito1) {
//             return ['codigoHelper' => 20, 'msg' => 'CNPJ inválido (1º dígito verificador).'];
//         }

//         // Validação do 2º dígito verificador
//         $pesos2 = [6,5,4,3,2,9,8,7,6,5,4,3,2];
//         $soma = 0;

//         for ($i = 0; $i < 13; $i++) {
//             $soma += $cnpj[$i] * $pesos2[$i];
//         }

//         $resto = $soma % 11;
//         $digito2 = ($resto < 2) ? 0 : 11 - $resto;

//         if ((int)$cnpj[13] !== $digito2) {
//             return ['codigoHelper' => 21, 'msg' => 'CNPJ inválido (2º dígito verificador).'];
//         }

//         return ['codigoHelper' => 0, 'msg' => 'CNPJ válido.'];
//     }
// }


if (!function_exists('validarDocumento')) {
    function validarDocumento(string $valor): array
    {
        // Remove caracteres não numéricos
        $valor = preg_replace('/[^0-9]/', '', $valor);

        // Detecta tipo
        if (strlen($valor) === 11) {
            // ===== CPF =====
            if (preg_match('/^(\d)\1{10}$/', $valor)) {
                return ['codigoHelper' => 16, 'msg' => 'CPF com todos dígitos iguais.'];
            }

            for ($t = 9; $t < 11; $t++) {
                $soma = 0;

                for ($i = 0; $i < $t; $i++) {
                    $soma += $valor[$i] * (($t + 1) - $i);
                }

                $digito = ((10 * $soma) % 11) % 10;

                if ((int)$valor[$t] !== $digito) {
                    return ['codigoHelper' => 17, 'msg' => 'CPF inválido.'];
                }
            }

            return ['codigoHelper' => 0, 'msg' => 'CPF válido.'];
        }

        elseif (strlen($valor) === 14) {
            // ===== CNPJ =====
            if (preg_match('/^(\d)\1{13}$/', $valor)) {
                return ['codigoHelper' => 19, 'msg' => 'CNPJ com todos dígitos iguais.'];
            }

            $pesos1 = [5,4,3,2,9,8,7,6,5,4,3,2];
            $soma = 0;

            for ($i = 0; $i < 12; $i++) {
                $soma += $valor[$i] * $pesos1[$i];
            }

            $resto = $soma % 11;
            $digito1 = ($resto < 2) ? 0 : 11 - $resto;

            if ((int)$valor[12] !== $digito1) {
                return ['codigoHelper' => 20, 'msg' => 'CNPJ inválido.'];
            }

            $pesos2 = [6,5,4,3,2,9,8,7,6,5,4,3,2];
            $soma = 0;

            for ($i = 0; $i < 13; $i++) {
                $soma += $valor[$i] * $pesos2[$i];
            }

            $resto = $soma % 11;
            $digito2 = ($resto < 2) ? 0 : 11 - $resto;

            if ((int)$valor[13] !== $digito2) {
                return ['codigoHelper' => 21, 'msg' => 'CNPJ inválido.'];
            }

            return ['codigoHelper' => 0, 'msg' => 'CNPJ válido.'];
        }

        // ===== TAMANHO INVÁLIDO =====
        return [
            'codigoHelper' => 22,
            'msg' => 'Documento deve ser CPF (11) ou CNPJ (14).'
        ];
    }
}


function validarCEPCompleto(string $cep): array
{
    $cepLimpo = preg_replace('/[^0-9]/', '', $cep);

    if (strlen($cepLimpo) !== 8) {
        return ['codigoHelper' => 30, 'msg' => 'CEP inválido.'];
    }

    $url = "https://viacep.com.br/ws/{$cepLimpo}/json/";
    $response = @file_get_contents($url);

    if (!$response) {
        return ['codigoHelper' => 31, 'msg' => 'Erro ao consultar CEP.'];
    }

    $data = json_decode($response, true);

    if (isset($data['erro'])) {
        return ['codigoHelper' => 32, 'msg' => 'CEP não encontrado.'];
    }

    return ['codigoHelper' => 0, 'msg' => 'CEP válido.'];
}
}