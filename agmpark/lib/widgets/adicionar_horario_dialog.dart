import 'package:flutter/material.dart';

class AdicionarHorarioDialog extends StatefulWidget {
  const AdicionarHorarioDialog({super.key});

  @override
  State<AdicionarHorarioDialog> createState() => _AdicionarHorarioDialogState();
}

class _AdicionarHorarioDialogState extends State<AdicionarHorarioDialog> {
  final Map<String, bool> diasSemana = {
    'Segunda': true,
    'Terça': false,
    'Quarta': false,
    'Quinta': false,
    'Sexta': false,
    'Sábado': false,
    'Domingo': false,
  };

  TimeOfDay horarioAbertura = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay horarioFechamento = const TimeOfDay(hour: 17, minute: 0);

  String formatarHorario(TimeOfDay horario) {
    final hora = horario.hour.toString().padLeft(2, '0');
    final minuto = horario.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  Future<void> selecionarHorarioAbertura() async {
    final TimeOfDay? horarioSelecionado = await showTimePicker(
      context: context,
      initialTime: horarioAbertura,
    );

    if (horarioSelecionado != null) {
      setState(() {
        horarioAbertura = horarioSelecionado;
      });
    }
  }

  Future<void> selecionarHorarioFechamento() async {
    final TimeOfDay? horarioSelecionado = await showTimePicker(
      context: context,
      initialTime: horarioFechamento,
    );

    if (horarioSelecionado != null) {
      setState(() {
        horarioFechamento = horarioSelecionado;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Adicionar Horário de\nFuncionamento',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 16),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Selecione os dias da semana:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _checkboxDia('Segunda'),
                      _checkboxDia('Quarta'),
                      _checkboxDia('Sexta'),
                      _checkboxDia('Domingo'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _checkboxDia('Terça'),
                      _checkboxDia('Quinta'),
                      _checkboxDia('Sábado'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Selecione o Horário em que o\nestacionamento está aberto:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 4),

            _campoHorario(
              texto: formatarHorario(horarioAbertura),
              onTap: selecionarHorarioAbertura,
            ),

            const SizedBox(height: 10),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Selecione o Horário em que o\nestacionamento fecha:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 4),

            _campoHorario(
              texto: formatarHorario(horarioFechamento),
              onTap: selecionarHorarioFechamento,
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 35,
              child: ElevatedButton(
                onPressed: () {
                  final diasSelecionados = diasSemana.entries
                      .where((dia) => dia.value)
                      .map((dia) => dia.key)
                      .toList();

                  print('Dias: $diasSelecionados');
                  print('Abertura: ${formatarHorario(horarioAbertura)}');
                  print('Fechamento: ${formatarHorario(horarioFechamento)}');

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22B96F),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  'Adicionar',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkboxDia(String dia) {
    return SizedBox(
      height: 22,
      child: Row(
        children: [
          Transform.scale(
            scale: 0.78,
            child: Checkbox(
              value: diasSemana[dia],
              activeColor: const Color(0xFF22B96F),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              onChanged: (value) {
                setState(() {
                  diasSemana[dia] = value ?? false;
                });
              },
            ),
          ),
          Text(
            dia,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoHorario({
    required String texto,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 29,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black26,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Text(
              texto,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.grey,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}