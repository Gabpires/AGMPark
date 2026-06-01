import 'package:agmpark/screen/detalhe_reserva.dart';
import 'package:flutter/material.dart';
import '../models/reserva_model.dart';
import '../services/reserva_service.dart';
import 'package:intl/intl.dart';

class ListaReservasPage extends StatefulWidget {
  final int idEstacionamento;

  const ListaReservasPage({super.key, required this.idEstacionamento});

  @override
  State<ListaReservasPage> createState() => _ListaReservasPageState();
}

class _ListaReservasPageState extends State<ListaReservasPage> {
  final ReservaService service = ReservaService();

  List<ReservaModel> reservas = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarReservas();
  }

  Future<void> carregarReservas() async {
    try {
      final dados = await service.listarReservas(widget.idEstacionamento);

      setState(() {
        reservas = dados;
        carregando = false;
      });
    } catch (e) {
      print('Erro ao carregar reservas: $e');

      setState(() {
        carregando = false;
      });
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
        title: const Text('Lista de Reservas', style: TextStyle(fontSize: 18)),
      ),

      body: carregando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF21B573)),
            )
          : reservas.isEmpty
          ? const Center(child: Text('Nenhuma reserva encontrada'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reservas.length,
              itemBuilder: (context, index) {
                final reserva = reservas[index];

                return ReservaCard(
                  reserva: reserva,
                  idEstacionamento: widget.idEstacionamento,
                );
              },
            ),
    );
  }
}

class ReservaCard extends StatelessWidget {
  final ReservaModel reserva;
  final int idEstacionamento;

  const ReservaCard({
    super.key,
    required this.reserva,
    required this.idEstacionamento,
  });

  @override
  Widget build(BuildContext context) {
    // Formatar data e hora
    String formatarData(String data) {
      try {
        final dataConvertida = DateTime.parse(data);
        return DateFormat('dd/MM/yyyy HH:mm').format(dataConvertida);
      } catch (e) {
        return data; // fallback caso dê erro
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔝 IMAGEM + INFO DO CARRO
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 130,
                height: 85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade300,
                ),
                child: const Icon(
                  Icons.directions_car,
                  size: 50,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Carro'),
                    Text(
                      reserva.modelo,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),

                    const SizedBox(height: 8),

                    const Text('Placa'),
                    Text(
                      reserva.placa,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 👤 NOME
          const Text('Nome do Usuário:'),
          Text(
            '---', // 👉 ainda não vem da API
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 8),

          // 📄 CPF
          const Text('CPF:'),
          Text(
            '---', // 👉 ainda não vem da API
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 10),

          // 🧩 VAGA + DATA
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Vaga Selecionada'),
                    Text(
                      reserva.numeroVaga,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Data e Hora de Reserva'),
                    Text(
                      formatarData(reserva.dataReserva),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 📊 STATUS
          const Text('Status da Reserva'),
          Text(
            reserva.status,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 14),

          // 🔘 BOTÃO
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF21B573),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetalhesReservaPage(
                      reserva: reserva,
                      idEstacionamento: idEstacionamento,
                    ),
                  ),
                );
              },
              child: const Text(
                'Ver mais',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
