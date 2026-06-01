import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/vaga_model.dart';
import '../services/vaga_service.dart';

class MudancaDisponibilidadePage extends StatefulWidget {
  final int idEstacionamento;

  const MudancaDisponibilidadePage({super.key, required this.idEstacionamento});

  @override
  State<MudancaDisponibilidadePage> createState() =>
      _MudancaDisponibilidadePageState();
}

class _MudancaDisponibilidadePageState
    extends State<MudancaDisponibilidadePage> {
  final _service = VagaService();

  List<VagaModel> vagas = [];
  bool carregando = true;
  bool salvando = false;
  bool modoAutomatico = false;
  bool vagasDisponiveis = true;
  String? erro;

  String get _chaveModoAutomatico {
    return 'agmpark_modo_automatico_${widget.idEstacionamento}';
  }

  @override
  void initState() {
    super.initState();
    inicializar();
  }

  Future<void> inicializar() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final prefs = SharedPreferencesAsync();
      final modoSalvo = await prefs.getBool(_chaveModoAutomatico) ?? false;
      final dados = await _service.listar(widget.idEstacionamento);

      if (!mounted) {
        return;
      }

      setState(() {
        modoAutomatico = modoSalvo;
        vagas = dados;
        vagasDisponiveis = _calcularDisponibilidade(dados);
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

  Future<void> alterarModoAutomatico(bool valor) async {
    setState(() {
      modoAutomatico = valor;
    });

    final prefs = SharedPreferencesAsync();
    await prefs.setBool(_chaveModoAutomatico, valor);

    if (valor) {
      await carregarVagas();
    }
  }

  Future<void> carregarVagas() async {
    try {
      final dados = await _service.listar(widget.idEstacionamento);

      if (!mounted) {
        return;
      }

      setState(() {
        vagas = dados;
        vagasDisponiveis = _calcularDisponibilidade(dados);
      });
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
    }
  }

  Future<void> alterarDisponibilidade(bool valor) async {
    setState(() {
      salvando = true;
      vagasDisponiveis = valor;
    });

    try {
      final dados = await _service.alterarDisponibilidade(
        idEstacionamento: widget.idEstacionamento,
        disponivel: valor,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        vagas = dados;
        vagasDisponiveis = _calcularDisponibilidade(dados);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disponibilidade atualizada'),
          backgroundColor: Color(0xFF21B573),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        vagasDisponiveis = !valor;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  bool _calcularDisponibilidade(List<VagaModel> dados) {
    final controlaveis = dados.where((vaga) => vaga.podeAlterarDisponibilidade);

    if (controlaveis.isEmpty) {
      return false;
    }

    return controlaveis.any((vaga) => vaga.status == 'LIVRE');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 3,
        title: const Text(
          'Mudança de Disponibilidade',
          style: TextStyle(fontSize: 17),
        ),
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
              const SizedBox(height: 14),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF21B573),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                onPressed: inicializar,
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

    return RefreshIndicator(
      color: const Color(0xFF21B573),
      onRefresh: carregarVagas,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
        children: [
          _SwitchLinha(
            texto: 'Modo Automático',
            valor: modoAutomatico,
            onChanged: salvando ? null : alterarModoAutomatico,
          ),
          const SizedBox(height: 12),
          _SwitchLinha(
            texto: 'Vagas Disponíveis',
            valor: vagasDisponiveis,
            onChanged: modoAutomatico || salvando
                ? null
                : alterarDisponibilidade,
          ),
          const SizedBox(height: 24),
          const Text(
            'Instruções:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            modoAutomatico
                ? 'O modo automático mantém a disponibilidade sincronizada com as leituras do sistema.'
                : 'Escolha entre o modo automático, onde o sistema detecta vagas disponíveis, ou o modo manual, onde você mesmo sinaliza a disponibilidade.',
            style: const TextStyle(fontSize: 10, height: 1.15),
          ),
          const SizedBox(height: 42),
          Center(
            child: SizedBox(
              width: 86,
              height: 86,
              child: CustomPaint(painter: _ConePainter()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchLinha extends StatelessWidget {
  final String texto;
  final bool valor;
  final ValueChanged<bool>? onChanged;

  const _SwitchLinha({
    required this.texto,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15),
          ),
        ),
        Transform.scale(
          scale: 0.78,
          child: Switch(
            value: valor,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF21B573),
            inactiveThumbColor: Colors.black,
            inactiveTrackColor: const Color(0xFFDADADA),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _ConePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final width = size.width;
    final height = size.height;

    final cone = Path()
      ..moveTo(width * 0.5, height * 0.08)
      ..lineTo(width * 0.28, height * 0.72)
      ..lineTo(width * 0.72, height * 0.72)
      ..close();

    canvas.drawPath(cone, paint);

    final clearPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(width * 0.36, height * 0.39, width * 0.28, height * 0.08),
        const Radius.circular(12),
      ),
      clearPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(width * 0.31, height * 0.59, width * 0.38, height * 0.08),
        const Radius.circular(12),
      ),
      clearPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(width * 0.18, height * 0.72, width * 0.64, height * 0.13),
        const Radius.circular(5),
      ),
      paint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(width * 0.08, height * 0.84, width * 0.84, height * 0.1),
        const Radius.circular(999),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
