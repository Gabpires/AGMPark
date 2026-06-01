import 'package:flutter/material.dart';

class FiltroEstacionamentos extends StatefulWidget {
  const FiltroEstacionamentos({super.key, this.titulo ='Filtrar Estacionamentos'});

  final String titulo;

  @override
  State<FiltroEstacionamentos> createState() => _FiltroEstacionamentosState();
}

class _FiltroEstacionamentosState extends State<FiltroEstacionamentos> {
  final filtroController = TextEditingController();

  @override
  void dispose() {
    filtroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 30,
        right: 30,
        top: 30,
        bottom: MediaQuery.of(context).viewInsets.bottom + 30,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filtrar Estacionamentos', style: TextStyle(fontSize: 24)),

          const SizedBox(height: 35),

          const Text(
            'Filtrar por Palavra-Chave:',
            style: TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: filtroController,
            decoration: InputDecoration(
              hintText: 'Palavra-Chave',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF21B573),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, filtroController.text);
              },
              child: const Text(
                'Filtrar',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
