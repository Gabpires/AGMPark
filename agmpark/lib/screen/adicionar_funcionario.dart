import 'package:agmpark/services/auth_service.dart';
import 'package:agmpark/services/funcionario_estacionamento_service.dart';
import 'package:agmpark/widgets/acesso_restrito.dart';
import 'package:flutter/material.dart';

class AdicionarFuncionarioPage extends StatefulWidget {
  final int idEstacionamento;

  const AdicionarFuncionarioPage({super.key, required this.idEstacionamento});

  @override
  State<AdicionarFuncionarioPage> createState() =>
      _AdicionarFuncionarioPageState();
}

class _AdicionarFuncionarioPageState extends State<AdicionarFuncionarioPage> {
  final _service = FuncionarioEstacionamentoService();
  final _emailController = TextEditingController();
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
    _emailController.dispose();
    super.dispose();
  }

  Future<void> cadastrar() async {
    if (podeAcessar != true) {
      _mostrarErro('Somente proprietarios podem cadastrar funcionarios');
      return;
    }

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _mostrarErro('Informe o e-mail do funcionário');
      return;
    }

    setState(() {
      cadastrando = true;
    });

    try {
      await _service.vincularPorEmail(
        idEstacionamento: widget.idEstacionamento,
        email: email,
      );

      if (!mounted) {
        return;
      }

      await _mostrarSucesso();

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _mostrarErro(e.toString().replaceFirst('Exception: ', ''));
      }
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
                const Text('Sucesso', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF21B573),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 34),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Processo realizado com sucesso',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF21B573),
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
        title: const Text(
          'Adicionar Funcionário',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: podeAcessar == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF21B573)),
            )
          : podeAcessar == false
          ? const AcessoRestrito(
              mensagem: 'Somente proprietarios podem cadastrar funcionarios.',
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                child: Column(
                  children: [
                    const Icon(Icons.account_box_outlined, size: 78),
                    const SizedBox(height: 22),
                    const Text(
                      'Para adicionar um novo funcionário ao sistema, digite o endereço de e-mail que ele utilizou no momento do cadastro da conta de funcionário.',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _emailController,
                      enabled: !cadastrando,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                          borderSide: const BorderSide(
                            color: Color(0xFFBDBDBD),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                          borderSide: const BorderSide(
                            color: Color(0xFF21B573),
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF21B573),
                          disabledBackgroundColor: const Color(0xFF21B573),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: cadastrando ? null : cadastrar,
                        child: cadastrando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Cadastrar Funcionário',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Certifique-se de que o e-mail informado está correto e vinculado a um perfil válido, pois é através dele que o sistema irá identificar e conceder as permissões de acesso adequadas.',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
