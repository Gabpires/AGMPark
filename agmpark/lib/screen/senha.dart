import 'package:agmpark/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:agmpark/screen/estacionamentos.dart' deferred as estacionamentos;
import 'package:agmpark/screen/recuperar%20senha/esqueci_senha.dart'
    deferred as esqueci_senha;

class SenhaPage extends StatefulWidget {
  final String email;

  const SenhaPage({super.key, required this.email});

  @override
  State<SenhaPage> createState() => _SenhaPageState();
}

class _SenhaPageState extends State<SenhaPage> {
  final TextEditingController senhaController = TextEditingController();
  bool carregando = false;
  bool ocultarSenha = true;

  @override
  void dispose() {
    senhaController.dispose();
    super.dispose();
  }

  Future<void> entrar() async {
    final senha = senhaController.text.trim();

    if (senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe sua senha para entrar')),
      );
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      await ApiService.login(email: widget.email, senha: senha);
      await estacionamentos.loadLibrary();

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => estacionamentos.EstacionamentosPage(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: carregando ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Login',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(28, 40, 28, 24),
          child: Column(
            children: [
              Image.asset('assets/images/logoagm2.png', height: 200),

              const SizedBox(height: 34),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.email,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),

              const SizedBox(height: 12),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Informe sua senha:',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: senhaController,
                obscureText: ocultarSenha,
                enabled: !carregando,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => entrar(),
                decoration: InputDecoration(
                  hintText: 'Senha',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        ocultarSenha = !ocultarSenha;
                      });
                    },
                    icon: Icon(
                      ocultarSenha ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF25B96F),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF25B96F),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: carregando ? null : entrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25B96F),
                    disabledBackgroundColor: const Color(0xFF25B96F),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: carregando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 26,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 28),

              GestureDetector(
                onTap: carregando
                    ? null
                    : () async {
                        await esqueci_senha.loadLibrary();

                        if (!context.mounted) {
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                esqueci_senha.EsqueciSenhaEmailPage(),
                          ),
                        );
                      },
                child: const Text(
                  'Esqueceu sua senha?',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
