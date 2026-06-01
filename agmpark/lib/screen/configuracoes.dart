import 'package:agmpark/screen/fale_conosco.dart';
import 'package:agmpark/screen/dados_estacionamento.dart';
import 'package:agmpark/screen/login.dart';
import 'package:agmpark/screen/meus_dados.dart';
import 'package:agmpark/models/estacionamento_model.dart';
import 'package:agmpark/services/auth_service.dart';
import 'package:agmpark/services/estacionamento_service.dart';
import 'package:flutter/material.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  final EstacionamentoService estacionamentoService = EstacionamentoService();
  String nomeUsuario = 'Usuário';
  bool carregandoPerfil = true;
  bool abrindoDadosEstacionamento = false;

  @override
  void initState() {
    super.initState();
    carregarPerfil();
  }

  Future<void> carregarPerfil() async {
    setState(() {
      carregandoPerfil = true;
    });

    try {
      final dados = await ApiService.usuarioLogado();
      final nome = dados['primeiro_nome']?.toString().trim();

      if (mounted && nome != null && nome.isNotEmpty) {
        setState(() {
          nomeUsuario = nome;
        });
      }
    } catch (e) {
      final payload = await ApiService.payloadToken();
      final email = payload?['email']?.toString();

      if (mounted && email != null && email.isNotEmpty) {
        setState(() {
          nomeUsuario = email;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          carregandoPerfil = false;
        });
      }
    }
  }

  Future<void> sair() async {
    await ApiService.logout();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> abrirMeusDados() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MeusDadosPage()),
    );

    if (mounted) {
      carregarPerfil();
    }
  }

  Future<void> abrirDadosEstacionamento() async {
    if (abrindoDadosEstacionamento) {
      return;
    }

    setState(() {
      abrindoDadosEstacionamento = true;
    });

    try {
      final estacionamentos = await estacionamentoService.listar();

      if (!mounted) {
        return;
      }

      if (estacionamentos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum estacionamento encontrado para este usuario'),
          ),
        );
        return;
      }

      final estacionamento = estacionamentos.length == 1
          ? estacionamentos.first
          : await _selecionarEstacionamento(estacionamentos);

      if (!mounted || estacionamento == null) {
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DadosEstacionamentoPage(estacionamento: estacionamento),
        ),
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
          abrindoDadosEstacionamento = false;
        });
      }
    }
  }

  Future<EstacionamentoModel?> _selecionarEstacionamento(
    List<EstacionamentoModel> estacionamentos,
  ) {
    return showModalBottomSheet<EstacionamentoModel>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selecione o estacionamento',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: estacionamentos.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final estacionamento = estacionamentos[index];

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.business,
                          color: Color(0xFF21B573),
                        ),
                        title: Text(estacionamento.nome),
                        subtitle: Text(
                          '${estacionamento.rua}, ${estacionamento.numero_estacionamento}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pop(context, estacionamento),
                      );
                    },
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const _ConfiguracoesHeader(),
                      const SizedBox(height: 46),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.account_circle,
                              size: 108,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 26),
                            Expanded(
                              child: Text(
                                carregandoPerfil
                                    ? 'Carregando...'
                                    : nomeUsuario,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  height: 1.15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 34),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          children: [
                            _OpcaoConfiguracao(
                              titulo: 'Meus Dados',
                              onTap: abrirMeusDados,
                            ),
                            _OpcaoConfiguracao(
                              titulo: 'Dados do estacionamento',
                              onTap: abrindoDadosEstacionamento
                                  ? null
                                  : abrirDadosEstacionamento,
                              carregando: abrindoDadosEstacionamento,
                            ),
                            _OpcaoConfiguracao(
                              titulo: 'Fale Conosco',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const FaleConoscoPage(),
                                  ),
                                );
                              },
                            ),
                            _OpcaoConfiguracao(titulo: 'Sair', onTap: sair),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const _LogoRodape(),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ConfiguracoesHeader extends StatelessWidget {
  const _ConfiguracoesHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          const SizedBox(width: 12),
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 22,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Configurações',
            style: TextStyle(fontSize: 17, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class _LogoRodape extends StatelessWidget {
  const _LogoRodape();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.hub_outlined, size: 96, color: Color(0xFF21B573)),
        SizedBox(height: 8),
        Text(
          'A G M',
          style: TextStyle(
            color: Color(0xFF9DFF6A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 6,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'PARK',
          style: TextStyle(
            color: Color(0xFF9DFF6A),
            fontSize: 12,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

class _OpcaoConfiguracao extends StatelessWidget {
  final String titulo;
  final VoidCallback? onTap;
  final bool carregando;

  const _OpcaoConfiguracao({
    required this.titulo,
    this.onTap,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.centerLeft,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFD6D6D6), width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
            if (carregando)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF21B573),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
