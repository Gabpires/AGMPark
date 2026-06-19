import 'package:agmpark/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../models/estacionamento_model.dart';
import 'package:agmpark/screen/dados_estacionamento.dart'
    deferred as dados_estacionamento;
import 'package:agmpark/screen/gerenciar_funcionarios.dart'
    deferred as gerenciar_funcionarios;
import 'package:agmpark/screen/lista_carros_estacionados.dart'
    deferred as lista_carros_estacionados;
import 'package:agmpark/screen/lista_reserva.dart' deferred as lista_reserva;
import 'package:agmpark/screen/lista_vagas.dart' deferred as lista_vagas;
import 'package:agmpark/screen/mudanca_disponibilidade.dart'
    deferred as mudanca_disponibilidade;

class DetalhesEstacionamentoPage extends StatefulWidget {
  final EstacionamentoModel estacionamento;

  const DetalhesEstacionamentoPage({super.key, required this.estacionamento});

  @override
  State<DetalhesEstacionamentoPage> createState() =>
      _DetalhesEstacionamentoPageState();
}

class _DetalhesEstacionamentoPageState
    extends State<DetalhesEstacionamentoPage> {
  late EstacionamentoModel estacionamento;
  bool podeAcessarProprietario = false;

  @override
  void initState() {
    super.initState();
    estacionamento = widget.estacionamento;
    carregarPermissao();
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

  Future<void> abrirReservas() async {
    await lista_reserva.loadLibrary();

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => lista_reserva.ListaReservasPage(
          idEstacionamento: estacionamento.id!,
        ),
      ),
    );
  }

  Future<void> abrirCarrosEstacionados() async {
    await lista_carros_estacionados.loadLibrary();

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => lista_carros_estacionados.ListaCarrosEstacionadosPage(
          idEstacionamento: estacionamento.id ?? 0,
        ),
      ),
    );
  }

  Future<void> abrirVagas() async {
    await lista_vagas.loadLibrary();

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => lista_vagas.ListaVagasPage(
          idEstacionamento: estacionamento.id ?? 0,
        ),
      ),
    );
  }

  Future<void> abrirDadosEstacionamento() async {
    await dados_estacionamento.loadLibrary();

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => dados_estacionamento.DadosEstacionamentoPage(
          estacionamento: estacionamento,
        ),
      ),
    );
  }

  Future<void> abrirMudancaDisponibilidade() async {
    await mudanca_disponibilidade.loadLibrary();

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => mudanca_disponibilidade.MudancaDisponibilidadePage(
          idEstacionamento: estacionamento.id ?? 0,
        ),
      ),
    );
  }

  Future<void> abrirGerenciarFuncionarios() async {
    await gerenciar_funcionarios.loadLibrary();

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => gerenciar_funcionarios.GerenciarFuncionariosPage(
          idEstacionamento: estacionamento.id ?? 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 4,
        title: const Text('Detalhes do Estacionamento'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, size: 32),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    estacionamento.nome,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, size: 50),
            ),

            const SizedBox(height: 16),

            const Text(
              'Endereço:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${estacionamento.rua}, ${estacionamento.numero_estacionamento}',
            ),
            Text(estacionamento.bairro),
            Text(estacionamento.cidade),
            Text('Estado: ${estacionamento.estado}'),
            Text('CEP: ${estacionamento.cep}'),

            const SizedBox(height: 16),

            const Text(
              'Vagas Disponíveis:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('${estacionamento.numero_vagas} vagas'),

            const SizedBox(height: 20),

            const Text(
              'Ações disponíveis:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2, // controla altura
              children: [
                BotaoAcaoDetalhe(
                  texto: 'Lista de\nReservas',
                  icon: Icons.send,
                  onTap: abrirReservas,
                ),
                BotaoAcaoDetalhe(
                  texto: 'Lista de Carros\nEstacionados',
                  icon: Icons.local_parking,
                  onTap: abrirCarrosEstacionados,
                ),
                BotaoAcaoDetalhe(
                  texto: 'Visualização\ndas vagas',
                  icon: Icons.grid_view,
                  onTap: abrirVagas,
                ),
                BotaoAcaoDetalhe(
                  texto: 'Dados do\nEstacionamento',
                  icon: Icons.analytics_outlined,
                  onTap: abrirDadosEstacionamento,
                ),
                BotaoAcaoDetalhe(
                  texto: 'Mudança de\nDisponibilidade',
                  icon: Icons.toggle_on,
                  onTap: abrirMudancaDisponibilidade,
                ),
                if (podeAcessarProprietario)
                  BotaoAcaoDetalhe(
                    texto: 'Gerenciar\nFuncionários',
                    icon: Icons.person,
                    onTap: abrirGerenciarFuncionarios,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BotaoAcaoDetalhe extends StatelessWidget {
  final String texto;
  final IconData icon;
  final VoidCallback? onTap;

  const BotaoAcaoDetalhe({
    super.key,
    required this.texto,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF21B573),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 10),
              Text(
                texto,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
