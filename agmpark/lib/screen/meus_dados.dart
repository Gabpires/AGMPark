import 'package:agmpark/services/auth_service.dart';
import 'package:flutter/material.dart';

class MeusDadosPage extends StatefulWidget {
  const MeusDadosPage({super.key});

  @override
  State<MeusDadosPage> createState() => _MeusDadosPageState();
}

class _MeusDadosPageState extends State<MeusDadosPage> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();

  bool carregando = true;
  bool atualizando = false;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    super.dispose();
  }

  Future<void> carregarDados() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final dados = await ApiService.usuarioLogado();

      nomeController.text = _valor(dados['primeiro_nome']);
      emailController.text = _valor(dados['email']);
      telefoneController.text = _valor(dados['telefone']);
    } catch (e) {
      erro = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  Future<void> atualizar() async {
    final nome = nomeController.text.trim();
    final email = emailController.text.trim();
    final telefone = telefoneController.text.trim();

    if (nome.isEmpty || email.isEmpty || telefone.isEmpty) {
      _mostrarErro('Preencha nome, e-mail e telefone');
      return;
    }

    setState(() {
      atualizando = true;
    });

    try {
      final dados = await ApiService.atualizarMeusDados(
        nome: nome,
        email: email,
        telefone: telefone,
      );

      nomeController.text = _valor(dados['primeiro_nome']);
      emailController.text = _valor(dados['email']);
      telefoneController.text = _valor(dados['telefone']);

      if (!mounted) {
        return;
      }

      await _mostrarSucesso();
    } catch (e) {
      if (mounted) {
        _mostrarErro(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          atualizando = false;
        });
      }
    }
  }

  String _valor(dynamic value) {
    return value?.toString() ?? '';
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
        title: const Text('Meus Dados', style: TextStyle(fontSize: 18)),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (carregando) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF21B573)),
      );
    }

    if (erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF21B573),
                ),
                onPressed: carregarDados,
                child: const Text(
                  'Tentar novamente',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Altere os dados da conta:',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
          const SizedBox(height: 18),
          _CampoDados(
            label: 'Nome',
            hint: 'Nome',
            controller: nomeController,
            enabled: !atualizando,
          ),
          _CampoDados(
            label: 'Endereço de Email',
            hint: 'Endereço de Email',
            controller: emailController,
            enabled: !atualizando,
            keyboardType: TextInputType.emailAddress,
          ),
          _CampoDados(
            label: 'Telefone',
            hint: '(XX) X XXXX-XXXX',
            controller: telefoneController,
            enabled: !atualizando,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF21B573),
                disabledBackgroundColor: const Color(0xFF21B573),
                elevation: 5,
                shadowColor: Colors.black38,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              onPressed: atualizando ? null : atualizar,
              child: atualizando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Atualizar',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CampoDados extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType? keyboardType;

  const _CampoDados({
    required this.label,
    required this.hint,
    required this.controller,
    required this.enabled,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 3),
          SizedBox(
            height: 44,
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
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
          ),
        ],
      ),
    );
  }
}
