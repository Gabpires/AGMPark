import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/reserva_model.dart';
import '../models/vaga_model.dart';
import '../services/vaga_service.dart';
import 'lista_carros_estacionados.dart' deferred as lista_carros_estacionados;

class DetalhesReservaPage extends StatefulWidget {
  final ReservaModel reserva;
  final int idEstacionamento;

  const DetalhesReservaPage({
    super.key,
    required this.reserva,
    required this.idEstacionamento,
  });

  @override
  State<DetalhesReservaPage> createState() => _DetalhesReservaPageState();
}

class _DetalhesReservaPageState extends State<DetalhesReservaPage> {
  late ReservaModel reserva;
  final VagaService _vagaService = VagaService();
  bool confirmandoEstadia = false;

  @override
  void initState() {
    super.initState();
    reserva = widget.reserva;
  }

  String formatarData(String data) {
    try {
      final d = DateTime.parse(data);
      return DateFormat('dd/MM/yyyy HH:mm').format(d);
    } catch (e) {
      return data;
    }
  }

  Future<void> confirmarEstadia() async {
    if (confirmandoEstadia) {
      return;
    }

    setState(() {
      confirmandoEstadia = true;
    });

    try {
      final vaga = await _buscarVagaDaReserva();

      if (vaga == null) {
        throw Exception('Nao foi possivel encontrar a vaga da reserva.');
      }

      if (!vaga.ocupada) {
        await _vagaService.atualizarStatus(vaga, 'OCUPADA');
      }

      if (!mounted) {
        return;
      }

      setState(() {
        confirmandoEstadia = false;
      });

      await abrirListaCarrosEstacionados();
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        confirmandoEstadia = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<VagaModel?> _buscarVagaDaReserva() async {
    final numeroVaga = _numeroVagaSelecionada();

    if (numeroVaga == null) {
      return null;
    }

    final vagas = await _vagaService.listar(widget.idEstacionamento);

    for (final vaga in vagas) {
      if (vaga.numeroVaga == numeroVaga) {
        return vaga;
      }
    }

    return null;
  }

  int? _numeroVagaSelecionada() {
    final texto = reserva.numeroVaga.trim();

    if (texto.isEmpty) {
      return null;
    }

    final numero = int.tryParse(texto);

    if (numero != null) {
      return numero;
    }

    final match = RegExp(r'\d+').firstMatch(texto);
    return int.tryParse(match?.group(0) ?? '');
  }

  Future<void> abrirListaCarrosEstacionados() async {
    await lista_carros_estacionados.loadLibrary();

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => lista_carros_estacionados.ListaCarrosEstacionadosPage(
          idEstacionamento: widget.idEstacionamento,
        ),
      ),
    );
  }

  void cancelar() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 4,
        title: Text('Detalhes da Reserva'),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, size: 28),
                SizedBox(width: 8),
                Text('Reserva #${reserva.idReserva}'),
              ],
            ),

            SizedBox(height: 16),

            Row(
              children: [
                Container(
                  width: 120,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade300,
                  ),
                  child: Icon(Icons.directions_car, size: 50),
                ),

                SizedBox(width: 12),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Carro'),
                    Text(reserva.modelo),
                    SizedBox(height: 8),
                    Text('Placa'),
                    Text(reserva.placa),
                  ],
                ),
              ],
            ),

            SizedBox(height: 12),

            Text('Nome do Usuário:'),
            Text('---'),

            SizedBox(height: 8),

            Text('CPF:'),
            Text('---'),

            SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vaga Selecionada'),
                      Text(reserva.numeroVaga),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Data e Hora de Reserva'),
                      Text(formatarData(reserva.dataReserva)),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            Text('Status da Reserva'),
            Text(reserva.status),

            SizedBox(height: 10),

            Text('Tempo restante até reserva expirar'),
            Text(formatarData(reserva.dataExpiracao)),

            SizedBox(height: 10),

            Text('Valor da reserva'),
            Text('R\$ ${reserva.valor}'),

            SizedBox(height: 10),

            Text('Tempo de estadia previsto'),
            Text('---'),

            SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: BotaoReservaAcao(
                    icon: Icons.check_circle_outline,
                    texto: 'Confirmar\nEstadia',
                    carregando: confirmandoEstadia,
                    onTap: confirmarEstadia,
                  ),
                ),

                SizedBox(width: 22),

                Expanded(
                  child: BotaoReservaAcao(
                    icon: Icons.door_front_door_outlined,
                    texto: 'Cancelar',
                    onTap: confirmandoEstadia ? null : cancelar,
                  ),
                ),
              ],
            ),

            SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF21B573),
                  elevation: 6,
                  shadowColor: Colors.black38,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  'Entrar em contato',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BotaoReservaAcao extends StatelessWidget {
  final IconData icon;
  final String texto;
  final VoidCallback? onTap;
  final bool carregando;

  const BotaoReservaAcao({
    super.key,
    required this.icon,
    required this.texto,
    required this.onTap,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF21B573),
          disabledBackgroundColor: Color(0xFF21B573).withValues(alpha: 0.65),
          elevation: 6,
          shadowColor: Colors.black38,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.all(10),
        ),
        onPressed: carregando ? null : onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            carregando
                ? SizedBox(
                    width: 42,
                    height: 42,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                : Icon(icon, color: Colors.white, size: 52),
            SizedBox(height: 12),
            Text(
              carregando ? 'Confirmando...' : texto,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.1),
            ),
          ],
        ),
      ),
    );
  }
}
