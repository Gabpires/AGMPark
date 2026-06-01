import 'package:flutter/material.dart';

class PoliticasPrivacidadePage extends StatefulWidget {
  const PoliticasPrivacidadePage({super.key});

  @override
  State<PoliticasPrivacidadePage> createState() =>
      _PoliticasPrivacidadePageState();
}

class _PoliticasPrivacidadePageState extends State<PoliticasPrivacidadePage> {
  final ScrollController _scrollController = ScrollController();

  bool chegouNoFinal = false;
  bool aceitouPolitica = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 20) {
        setState(() {
          chegouNoFinal = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get podeAceitar => chegouNoFinal && aceitouPolitica;

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
          onPressed: () => Navigator.pop(context, false),
        ),
        title: const Text(
          'Privacidade',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
          child: Column(
            children: [
              const Text(
                'Políticas de Privacidade',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 18),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TituloPolitica('1. Coleta de Dados'),
                        _TextoPolitica(
                          'Coletamos dados pessoais fornecidos pelo usuário, como nome, e-mail e informações necessárias para o funcionamento do sistema AGM Park. Esses dados são coletados de forma transparente e com o seu consentimento.',
                        ),

                        _TituloPolitica('2. Uso das Informações'),
                        _TextoPolitica(
                          'As informações coletadas são utilizadas para identificação do usuário, acesso ao sistema, controle administrativo do estacionamento, melhoria da experiência e segurança da aplicação.',
                        ),

                        _TituloPolitica('3. Compartilhamento de Dados'),
                        _TextoPolitica(
                          'Os dados pessoais não serão vendidos ou compartilhados indevidamente com terceiros. O compartilhamento poderá ocorrer apenas quando necessário para cumprimento de obrigação legal ou mediante consentimento do usuário.',
                        ),

                        _TituloPolitica('4. Armazenamento e Segurança'),
                        _TextoPolitica(
                          'Adotamos medidas técnicas e administrativas para proteger os dados contra acessos não autorizados, perda, alteração, divulgação ou qualquer forma de tratamento inadequado.',
                        ),

                        _TituloPolitica('5. Direitos do Titular'),
                        _TextoPolitica(
                          'Conforme a LGPD, o usuário pode solicitar acesso, correção, atualização, exclusão ou informações sobre o tratamento de seus dados pessoais.',
                        ),

                        _TituloPolitica('6. Consentimento'),
                        _TextoPolitica(
                          'Ao marcar a opção de aceite, o usuário declara estar ciente e concordar com esta Política de Privacidade e com o tratamento dos dados necessários para utilização do sistema.',
                        ),

                        _TituloPolitica('7. Alterações nesta Política'),
                        _TextoPolitica(
                          'Esta política poderá ser atualizada periodicamente. Recomendamos que o usuário revise este conteúdo sempre que houver alterações no aplicativo.',
                        ),

                        SizedBox(height: 12),
                        Center(
                          child: Text(
                            'Fim da política',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              AnimatedOpacity(
                opacity: chegouNoFinal ? 1 : 0.45,
                duration: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    Checkbox(
                      value: aceitouPolitica,
                      activeColor: const Color(0xFF22B573),
                      onChanged: chegouNoFinal
                          ? (value) {
                              setState(() {
                                aceitouPolitica = value ?? false;
                              });
                            }
                          : null,
                    ),
                    const Expanded(
                      child: Text(
                        'Li e aceito a Política de Privacidade',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),

              if (!chegouNoFinal)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Role até o final para liberar o aceite.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),

              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: podeAceitar
                      ? () {
                          Navigator.pop(context, true);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22B573),
                    disabledBackgroundColor: Colors.grey.shade400,
                    elevation: podeAceitar ? 4 : 0,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Aceitar',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
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

class _TituloPolitica extends StatelessWidget {
  final String texto;

  const _TituloPolitica(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _TextoPolitica extends StatelessWidget {
  final String texto;

  const _TextoPolitica(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      textAlign: TextAlign.justify,
      style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.35),
    );
  }
}
