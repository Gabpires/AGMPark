import 'package:agmpark/screen/cadastro.dart';
import 'package:flutter/material.dart';

class CadastroTipoContaPage extends StatefulWidget {
  final bool aceitouPolitica;

  const CadastroTipoContaPage({super.key, required this.aceitouPolitica});

  @override
  State<CadastroTipoContaPage> createState() => _CadastroTipoContaPageState();
}

class _CadastroTipoContaPageState extends State<CadastroTipoContaPage> {
  String? tipoConta;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Cadastro',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            const Text(
              'Faça seu cadastro',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Crie sua conta e dê o primeiro passo para\n'
              'controlar estacionamentos com\n'
              'praticidade e eficiência',
              style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.3),
            ),

            const SizedBox(height: 55),

            const Text(
              'Qual tipo de conta você\ndeseja cadastrar?',
              style: TextStyle(fontSize: 18, color: Colors.black, height: 1.2),
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: tipoConta,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey,
                    size: 32,
                  ),
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                  dropdownColor: Colors.white,
                  items: const [
                    DropdownMenuItem(
                      value: 'PROPRIETARIO',
                      child: Text(
                        'Proprietário',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'FUNCIONARIO',
                      child: Text(
                        'Funcionário',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      tipoConta = value;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 42),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // ação do botão continuar
                  if (tipoConta == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Selecione um tipo de conta para continuar',
                        ),
                      ),
                    );
                    return;
                  }

                  if (!widget.aceitouPolitica) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Aceite a Política de Privacidade para continuar',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CadastroFormPage(tipo: tipoConta!),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22B573),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
