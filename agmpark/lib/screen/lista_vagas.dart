import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/vaga_model.dart';
import '../services/vaga_service.dart';

class ListaVagasPage extends StatefulWidget {
  final int idEstacionamento;

  const ListaVagasPage({super.key, required this.idEstacionamento});

  @override
  State<ListaVagasPage> createState() => _ListaVagasPageState();
}

class _ListaVagasPageState extends State<ListaVagasPage> {
  final _service = VagaService();

  List<VagaModel> vagas = [];
  bool carregando = true;
  bool modoAutomatico = false;
  int? idVagaSalvando;
  String? erro;

  String get _chaveModoAutomatico {
    return VagaService.chaveModoAutomatico(widget.idEstacionamento);
  }

  @override
  void initState() {
    super.initState();
    carregarVagas();
  }

  Future<void> carregarVagas() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final prefs = SharedPreferencesAsync();
      final modoSalvo = await prefs.getBool(_chaveModoAutomatico) ?? false;
      final dados = await _service.listar(
        widget.idEstacionamento,
        considerarStatusFisico: modoSalvo,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        modoAutomatico = modoSalvo;
        vagas = dados;
        carregando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        carregando = false;
        erro = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> abrirAlteracaoStatus(VagaModel vaga) async {
    if (modoAutomatico) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Desative o modo automático para alterar o status manualmente.',
          ),
        ),
      );
      return;
    }

    if (idVagaSalvando != null) {
      return;
    }

    final status = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alterar status da vaga',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  'Vaga ${vaga.numeroVaga}',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 14),
                _OpcaoStatus(
                  texto: 'Livre',
                  status: 'LIVRE',
                  statusAtual: vaga.status,
                  icon: Icons.local_parking,
                ),
                _OpcaoStatus(
                  texto: 'Ocupada',
                  status: 'OCUPADA',
                  statusAtual: vaga.status,
                  icon: Icons.directions_car_filled,
                ),
                _OpcaoStatus(
                  texto: 'Indisponível',
                  status: 'MANUTENCAO',
                  statusAtual: vaga.status,
                  icon: Icons.block,
                ),
              ],
            ),
          ),
        );
      },
    );

    if (status == null || status == vaga.status) {
      return;
    }

    await alterarStatusVaga(vaga, status);
  }

  Future<void> alterarStatusVaga(VagaModel vaga, String status) async {
    setState(() {
      idVagaSalvando = vaga.id;
    });

    try {
      await _service.atualizarStatus(vaga, status);
      final dados = await _service.listar(
        widget.idEstacionamento,
        considerarStatusFisico: modoAutomatico,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        vagas = dados;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status alterado para ${_textoStatus(status)}.'),
          backgroundColor: const Color(0xFF21B573),
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
          idVagaSalvando = null;
        });
      }
    }
  }

  String _textoStatus(String status) {
    switch (status.toUpperCase()) {
      case 'OCUPADA':
        return 'Ocupada';
      case 'RESERVADA':
        return 'Reservada';
      case 'MANUTENCAO':
        return 'Indisponível';
      default:
        return 'Livre';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 3,
        title: const Text('Lista de Vagas', style: TextStyle(fontSize: 18)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (carregando) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF21B573)),
      );
    }

    if (erro != null) {
      return _ErroVagas(mensagem: erro!, onRetry: carregarVagas);
    }

    if (vagas.isEmpty) {
      return RefreshIndicator(
        color: const Color(0xFF21B573),
        onRefresh: carregarVagas,
        child: ListView(
          children: const [
            SizedBox(height: 220),
            Center(child: Text('Nenhuma vaga cadastrada')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF21B573),
      onRefresh: carregarVagas,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final colunas = constraints.maxWidth >= 560 ? 3 : 2;
          const horizontalPadding = 16.0;
          const espacamento = 18.0;
          final larguraItem =
              (constraints.maxWidth -
                  (horizontalPadding * 2) -
                  (espacamento * (colunas - 1))) /
              colunas;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              horizontalPadding,
              20,
              horizontalPadding,
              24,
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: espacamento,
              runSpacing: 42,
              children: [
                for (final vaga in vagas)
                  SizedBox(
                    width: larguraItem,
                    height: 150,
                    child: _VagaTile(
                      vaga: vaga,
                      modoAutomatico: modoAutomatico,
                      salvando: idVagaSalvando == vaga.id,
                      onTap: () => abrirAlteracaoStatus(vaga),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _VagaTile extends StatelessWidget {
  final VagaModel vaga;
  final bool modoAutomatico;
  final bool salvando;
  final VoidCallback onTap;

  const _VagaTile({
    required this.vaga,
    required this.modoAutomatico,
    required this.salvando,
    required this.onTap,
  });

  String get _textoStatus {
    if (modoAutomatico) {
      return vaga.textoStatus;
    }

    switch (vaga.status) {
      case 'OCUPADA':
        return 'Ocupada';
      case 'RESERVADA':
        return 'Reservada';
      case 'MANUTENCAO':
        return 'Indisponível';
      default:
        return 'Livre';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Vaga ${vaga.numeroVaga} $_textoStatus',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: salvando ? null : onTap,
        child: Opacity(
          opacity: salvando ? 0.55 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Vaga ${vaga.numeroVaga}',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                _textoStatus,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
              const SizedBox(height: 7),
              Expanded(
                child: salvando
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF21B573),
                          ),
                        ),
                      )
                    : _VagaIcon(vaga: vaga, modoAutomatico: modoAutomatico),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpcaoStatus extends StatelessWidget {
  final String texto;
  final String status;
  final String statusAtual;
  final IconData icon;

  const _OpcaoStatus({
    required this.texto,
    required this.status,
    required this.statusAtual,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final selecionado = status == statusAtual;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: selecionado ? const Color(0xFF21B573) : null),
      title: Text(texto),
      trailing: selecionado
          ? const Icon(Icons.check, color: Color(0xFF21B573))
          : null,
      onTap: () => Navigator.pop(context, status),
    );
  }
}

class _VagaIcon extends StatelessWidget {
  final VagaModel vaga;
  final bool modoAutomatico;

  const _VagaIcon({required this.vaga, required this.modoAutomatico});

  bool get _ocupada {
    return modoAutomatico ? vaga.ocupada : vaga.status == 'OCUPADA';
  }

  bool get _emManutencao {
    return vaga.status == 'MANUTENCAO';
  }

  @override
  Widget build(BuildContext context) {
    if (_ocupada) {
      return const Align(
        alignment: Alignment.topCenter,
        child: Icon(
          Icons.directions_car_filled,
          size: 46,
          color: Color(0xFF5DA883),
        ),
      );
    }

    if (_emManutencao) {
      return const Align(
        alignment: Alignment.topCenter,
        child: Icon(Icons.block, size: 40, color: Colors.black),
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 62,
        height: 50,
        child: Stack(
          children: [
            const Positioned(
              left: 8,
              top: 0,
              child: Icon(Icons.local_parking, size: 28, color: Colors.black),
            ),
            Positioned(
              left: 22,
              top: 28,
              child: Container(width: 4, height: 18, color: Colors.black),
            ),
            Positioned(
              left: 2,
              bottom: 0,
              child: Container(width: 58, height: 1, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErroVagas extends StatelessWidget {
  final String mensagem;
  final VoidCallback onRetry;

  const _ErroVagas({required this.mensagem, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42, color: Color(0xFF21B573)),
            const SizedBox(height: 12),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 42,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF21B573),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                onPressed: onRetry,
                child: const Text(
                  'Tentar novamente',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
