import 'package:flutter/material.dart';
import 'nova_senha.dart';

class VerificarEmailPage extends StatefulWidget {
  final String email;

  const VerificarEmailPage({
    super.key,
    required this.email,
  });

  @override
  State<VerificarEmailPage> createState() => _VerificarEmailPageState();
}

class _VerificarEmailPageState extends State<VerificarEmailPage> {
  final List<TextEditingController> codigoControllers = List.generate(
    5,
    (index) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(
    5,
    (index) => FocusNode(),
  );

  @override
  void dispose() {
    for (final controller in codigoControllers) {
      controller.dispose();
    }

    for (final focus in focusNodes) {
      focus.dispose();
    }

    super.dispose();
  }

  void continuar() {
    final codigo = codigoControllers.map((controller) => controller.text).join();

    if (codigo.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o código completo')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NovaSenhaPage(),
      ),
    );
  }

  void reenviarEmail() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Código reenviado para ${widget.email}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Esqueci minha senha',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verifique seu email',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Enviamos um código de 5 dígitos para o\nseu email, digite ele abaixo para que você\npossa definir uma nova senha',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  return SizedBox(
                    width: 42,
                    height: 46,
                    child: TextField(
                      controller: codigoControllers[index],
                      focusNode: focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color(0xFF25B96F),
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 4) {
                          focusNodes[index + 1].requestFocus();
                        }

                        if (value.isEmpty && index > 0) {
                          focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: continuar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25B96F),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Center(
                child: Column(
                  children: [
                    const Text(
                      'Não recebeu o email?',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),

                    GestureDetector(
                      onTap: reenviarEmail,
                      child: const Text(
                        'Reenvie',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}