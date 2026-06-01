import 'package:agmpark/models/estacionamento_model.dart';
import 'package:agmpark/services/auth_service.dart';
import 'package:agmpark/services/estacionamento_service.dart';
import 'package:agmpark/widgets/acesso_restrito.dart';
import 'package:flutter/material.dart';

class CadastroEstacionamentoPage extends StatefulWidget {
  const CadastroEstacionamentoPage({super.key});

  static const Color verde = Color(0xFF21B573);

  @override
  State<CadastroEstacionamentoPage> createState() =>
      _CadastroEstacionamentoPageState();
}

class _CadastroEstacionamentoPageState
    extends State<CadastroEstacionamentoPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = EstacionamentoService();

  final nomeController = TextEditingController();
  final ruaController = TextEditingController();
  final numeroController = TextEditingController();
  final bairroController = TextEditingController();
  final cidadeController = TextEditingController();
  final estadoController = TextEditingController();
  final cepController = TextEditingController();
  final vagasController = TextEditingController();
  final quantidadeTempoController = TextEditingController();
  final valorTempoController = TextEditingController();

  bool cadastrando = false;
  bool? podeAcessar;

  @override
  void initState() {
    super.initState();
    verificarPermissao();
  }

  Future<void> verificarPermissao() async {
    final permitido = await ApiService.possuiAcessoProprietario();

    if (!mounted) {
      return;
    }

    setState(() {
      podeAcessar = permitido;
    });
  }

  @override
  void dispose() {
    nomeController.dispose();
    ruaController.dispose();
    numeroController.dispose();
    bairroController.dispose();
    cidadeController.dispose();
    estadoController.dispose();
    cepController.dispose();
    vagasController.dispose();
    quantidadeTempoController.dispose();
    valorTempoController.dispose();
    super.dispose();
  }

  Future<void> cadastrarEstacionamento() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      cadastrando = true;
    });

    final estacionamento = EstacionamentoModel(
      nome: nomeController.text.trim(),
      estado: estadoController.text.trim().toUpperCase(),
      rua: ruaController.text.trim(),
      numero_estacionamento: int.parse(numeroController.text.trim()),
      bairro: bairroController.text.trim(),
      cidade: cidadeController.text.trim(),
      cep: cepController.text.trim(),
      numero_vagas: int.parse(vagasController.text.trim()),
      quantidadeTempo: int.parse(quantidadeTempoController.text.trim()),
      valorTempo: valorTempoController.text.trim().replaceAll(',', '.'),
    );

    try {
      await _service.cadastrar(estacionamento);

      if (!mounted) {
        return;
      }

      await _mostrarSucesso();

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      _mostrarErro(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          cadastrando = false;
        });
      }
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
    );
  }

  Future<void> _mostrarSucesso() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sucesso',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: CadastroEstacionamentoPage.verde,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 34),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Estacionamento cadastrado com sucesso',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CadastroEstacionamentoPage.verde,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 3,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: cadastrando ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Cadastro do Estacionamento',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: podeAcessar == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF21B573)),
            )
          : podeAcessar == false
          ? const AcessoRestrito(
              mensagem:
                  'Somente proprietarios podem cadastrar estacionamentos.',
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dados do estacionamento',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      CampoTexto(
                        label: 'Nome do Estacionamento',
                        hint: 'Nome do Estacionamento',
                        controller: nomeController,
                        enabled: !cadastrando,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Endereço',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: CampoTexto(
                              label: 'Rua, Avenida ...',
                              hint: 'Rua, Avenida ...',
                              controller: ruaController,
                              enabled: !cadastrando,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CampoTexto(
                              label: 'Número',
                              hint: 'Nº',
                              controller: numeroController,
                              enabled: !cadastrando,
                              keyboardType: TextInputType.number,
                              validator: validarInteiro,
                            ),
                          ),
                        ],
                      ),
                      CampoTexto(
                        label: 'Bairro',
                        hint: 'Bairro',
                        controller: bairroController,
                        enabled: !cadastrando,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: CampoTexto(
                              label: 'Cidade',
                              hint: 'Cidade',
                              controller: cidadeController,
                              enabled: !cadastrando,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CampoTexto(
                              label: 'UF',
                              hint: 'SP',
                              controller: estadoController,
                              enabled: !cadastrando,
                              textCapitalization: TextCapitalization.characters,
                              validator: validarUf,
                            ),
                          ),
                        ],
                      ),
                      CampoTexto(
                        label: 'CEP',
                        hint: '00000-000',
                        controller: cepController,
                        enabled: !cadastrando,
                        keyboardType: TextInputType.number,
                        validator: validarCep,
                      ),
                      CampoTexto(
                        label: 'Número de Vagas no Estacionamento',
                        hint: 'Número de Vagas',
                        controller: vagasController,
                        enabled: !cadastrando,
                        keyboardType: TextInputType.number,
                        validator: validarInteiro,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Valores da estadia',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CampoTexto(
                              label: 'Tempo em minutos',
                              hint: '60',
                              controller: quantidadeTempoController,
                              enabled: !cadastrando,
                              keyboardType: TextInputType.number,
                              validator: validarInteiro,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CampoTexto(
                              label: 'Valor',
                              hint: '8.00',
                              controller: valorTempoController,
                              enabled: !cadastrando,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: validarValor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CadastroEstacionamentoPage.verde,
                            disabledBackgroundColor:
                                CadastroEstacionamentoPage.verde,
                            elevation: 5,
                            shadowColor: Colors.black38,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: cadastrando
                              ? null
                              : cadastrarEstacionamento,
                          child: cadastrando
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Cadastrar Estacionamento',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  String? validarObrigatorio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    return null;
  }

  String? validarInteiro(String? value) {
    final obrigatorio = validarObrigatorio(value);

    if (obrigatorio != null) {
      return obrigatorio;
    }

    final numero = int.tryParse(value!.trim());

    if (numero == null || numero <= 0) {
      return 'Informe um número válido';
    }

    return null;
  }

  String? validarUf(String? value) {
    final obrigatorio = validarObrigatorio(value);

    if (obrigatorio != null) {
      return obrigatorio;
    }

    if (value!.trim().length != 2) {
      return 'Use a UF com 2 letras';
    }

    return null;
  }

  String? validarCep(String? value) {
    final obrigatorio = validarObrigatorio(value);

    if (obrigatorio != null) {
      return obrigatorio;
    }

    final cep = value!.replaceAll(RegExp(r'[^0-9]'), '');

    if (cep.length != 8) {
      return 'Informe um CEP válido';
    }

    return null;
  }

  String? validarValor(String? value) {
    final obrigatorio = validarObrigatorio(value);

    if (obrigatorio != null) {
      return obrigatorio;
    }

    final valor = double.tryParse(value!.trim().replaceAll(',', '.'));

    if (valor == null || valor <= 0) {
      return 'Informe um valor válido';
    }

    return null;
  }
}

class CampoTexto extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  const CampoTexto({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.enabled,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            validator: validator ?? _validarObrigatorio,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: CadastroEstacionamentoPage.verde,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validarObrigatorio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    return null;
  }
}
