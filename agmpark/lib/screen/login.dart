import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:agmpark/screen/cadastroTipo.dart' deferred as cadastro_tipo;
import 'package:agmpark/screen/privacidade.dart' deferred as privacidade;
import 'package:agmpark/screen/senha.dart' deferred as senha;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> continuarParaSenha() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe seu e-mail para continuar')),
      );
      return;
    }

    await senha.loadLibrary();

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => senha.SenhaPage(email: email)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F3F3),
        elevation: 2,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Identificação',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),

              Image.asset(
                'assets/images/logoagm2.png',
                width: 120,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 32),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Informe seu e-mail:',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => continuarParaSenha(),
                decoration: InputDecoration(
                  hintText: 'E-mail',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 18),
                  filled: true,
                  fillColor: const Color(0xFFF3F3F3),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF22B573),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: continuarParaSenha,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22B573),
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Entrar',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              GestureDetector(
                onTap: () async {
                  await cadastro_tipo.loadLibrary();

                  if (!context.mounted) {
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          cadastro_tipo.CadastroTipoContaPage(
                            aceitouPolitica: true,
                          ),
                    ),
                  );
                },
                child: const Text(
                  'Cadastrar-se',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.2,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          'A gente se preocupa com a sua\n'
                          'privacidade. Por isso, preparamos um\n'
                          'documento transparente explicando\n'
                          'como coletamos, usamos e protegemos\n'
                          'seus dados. ',
                    ),
                    TextSpan(
                      text: 'POLÍTICAS DE PRIVACIDADE',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        color: Colors.black87,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          await privacidade.loadLibrary();

                          if (!context.mounted) {
                            return;
                          }

                          final aceitou = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  privacidade.PoliticasPrivacidadePage(),
                            ),
                          );

                          if (!context.mounted) {
                            return;
                          }

                          if (aceitou == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Política de Privacidade aceita com sucesso!',
                                ),
                                backgroundColor: Color(0xFF22B573),
                              ),
                            );
                          }
                        },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Fale Conosco',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
