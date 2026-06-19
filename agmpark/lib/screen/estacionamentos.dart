import 'package:agmpark/models/estacionamento_model.dart';
import 'package:agmpark/services/auth_service.dart';
import 'package:agmpark/services/estacionamento_service.dart';
import 'package:agmpark/widgets/filtro.dart';
import 'package:flutter/material.dart';
import 'package:agmpark/screen/cadastro_estacionamento.dart'
    deferred as cadastro_estacionamento;
import 'package:agmpark/screen/configuracoes.dart' deferred as configuracoes;
import 'package:agmpark/screen/detalhe_estacionamento.dart'
    deferred as detalhe_estacionamento;
import 'package:agmpark/screen/notificacoes.dart' deferred as notificacoes;

class EstacionamentosPage extends StatefulWidget {
  const EstacionamentosPage({super.key});

  @override
  State<EstacionamentosPage> createState() => _EstacionamentosPageState();
}

class _EstacionamentosPageState extends State<EstacionamentosPage> {
  final EstacionamentoService estacionamentoService = EstacionamentoService();

  List<EstacionamentoModel> estacionamentos = [];
  bool carregando = true;
  bool podeAcessarProprietario = false;

  @override
  void initState() {
    super.initState();
    carregarPermissao();
    listarEstacionamentos();
  }

  Future<void> carregarPermissao() async {
    final podeAcessar = await ApiService.possuiAcessoProprietario();

    if (!mounted) {
      return;
    }

    setState(() {
      podeAcessarProprietario = podeAcessar;
    });
  }

  Future<void> listarEstacionamentos() async {
    try {
      final dados = await estacionamentoService.listar();

      setState(() {
        estacionamentos = dados;
        carregando = false;
      });
    } catch (e) {
      setState(() {
        carregando = false;
      });

      print('Erro ao listar: $e');
    }
  }

  Future<void> abrirConfiguracoes() async {
    await configuracoes.loadLibrary();

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => configuracoes.ConfiguracoesPage()),
    );
  }

  Future<void> abrirNotificacoes() async {
    await notificacoes.loadLibrary();

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => notificacoes.NotificacoesPage()),
    );
  }

  Future<void> abrirCadastroEstacionamento() async {
    await cadastro_estacionamento.loadLibrary();

    if (!mounted) {
      return;
    }

    final cadastrou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            cadastro_estacionamento.CadastroEstacionamentoPage(),
      ),
    );

    if (cadastrou == true) {
      listarEstacionamentos();
    }
  }

  Future<void> abrirDetalhes(EstacionamentoModel estacionamento) async {
    await detalhe_estacionamento.loadLibrary();

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => detalhe_estacionamento.DetalhesEstacionamentoPage(
          estacionamento: estacionamento,
        ),
      ),
    );
  }

  Widget _linhaInfo({required IconData icon, required String texto}) {
    return Row(
      children: [
        Icon(icon, size: 34, color: Colors.black),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(fontSize: 21, color: Colors.black),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            // Topo
            // Topo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Configurações
                  InkWell(
                    onTap: abrirConfiguracoes,
                    child: const Icon(
                      Icons.settings,
                      color: Color(0xFF21B573),
                      size: 32,
                    ),
                  ),

                  const Icon(
                    Icons.hub_outlined,
                    color: Color(0xFF21B573),
                    size: 32,
                  ),

                  // Notificações
                  InkWell(
                    onTap: abrirNotificacoes,
                    child: const Icon(
                      Icons.notifications,
                      color: Color(0xFF21B573),
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),

            // Título
            const Padding(
              padding: EdgeInsets.only(left: 20, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Estacionamentos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
              ),
            ),

            // Botões
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (podeAcessarProprietario)
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: abrirCadastroEstacionamento,
                      child: Container(
                        height: 45,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Color(0xFF21B573),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Cadastrar\nEstacionamento',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(width: 12),
                            Icon(
                              Icons.add_circle_outline,
                              color: Colors.white,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),

                  const Spacer(),

                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      final filtro = await showModalBottomSheet<String>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: const Color(0xFFF8F3FA),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                        ),
                        builder: (context) => const FiltroEstacionamentos(),
                      );

                      if (filtro != null && filtro.isNotEmpty) {
                        print('Filtro digitado: $filtro');
                      }
                    },
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFF21B573),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.tune, // melhor ícone pra filtro
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Estado listagem
            Expanded(
              child: carregando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF21B573),
                      ),
                    )
                  : estacionamentos.isEmpty
                  ? Center(
                      child: Text(
                        podeAcessarProprietario
                            ? 'Nenhum estacionamento cadastrado'
                            : 'Nenhum estacionamento vinculado',
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: estacionamentos.length,
                      itemBuilder: (context, index) {
                        final est = estacionamentos[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _linhaInfo(icon: Icons.business, texto: est.nome),

                              const SizedBox(height: 18),

                              _linhaInfo(
                                icon: Icons.location_on_outlined,
                                texto:
                                    'Local:  ${est.rua}, ${est.numero_estacionamento}',
                              ),

                              const SizedBox(height: 18),

                              _linhaInfo(
                                icon: Icons.traffic,
                                texto:
                                    '${est.numero_vagas} vagas | Disponíveis: ${est.numero_vagas}',
                              ),

                              const SizedBox(height: 28),

                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF21B573),
                                    elevation: 6,
                                    shadowColor: Colors.black38,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () => abrirDetalhes(est),
                                  child: const Text(
                                    'Detalhes',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
