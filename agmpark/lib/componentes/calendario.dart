import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
// ignore: unused_import
import 'package:intl/intl.dart';

class CalendarioCustomPage extends StatefulWidget {
  const CalendarioCustomPage({super.key});

  @override
  State<CalendarioCustomPage> createState() => _CalendarioCustomPageState();
}

class _CalendarioCustomPageState extends State<CalendarioCustomPage> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  final List<String> meses = const [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    selectedDay = DateTime.now();
  }

  void _mesAnterior() {
    setState(() {
      focusedDay = DateTime(focusedDay.year, focusedDay.month - 1);
    });
  }

  void _proximoMes() {
    setState(() {
      focusedDay = DateTime(focusedDay.year, focusedDay.month + 1);
    });
  }

  Future<void> _selecionarMesEAno() async {
    int mesSelecionado = focusedDay.month;
    int anoSelecionado = focusedDay.year;

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF7F7F7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Selecionar mês e ano',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4D5965),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: mesSelecionado,
                          decoration: InputDecoration(
                            labelText: 'Mês',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          items: List.generate(12, (index) {
                            return DropdownMenuItem(
                              value: index + 1,
                              child: Text(meses[index]),
                            );
                          }),
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() {
                                mesSelecionado = value;
                              });
                            }
                          },
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: anoSelecionado,
                          decoration: InputDecoration(
                            labelText: 'Ano',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          items: List.generate(101, (index) {
                            final ano = DateTime.now().year - 50 + index;

                            return DropdownMenuItem(
                              value: ano,
                              child: Text(ano.toString()),
                            );
                          }),
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() {
                                anoSelecionado = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF29B46E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          focusedDay = DateTime(
                            anoSelecionado,
                            mesSelecionado,
                          );
                        });

                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _tituloCalendario() {
    final mes = meses[focusedDay.month - 1];
    final ano = focusedDay.year;

    return '$mes $ano';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBDBDBD)),
            boxShadow: const [
              BoxShadow(
                blurRadius: 20,
                offset: Offset(0, 8),
                color: Colors.black26,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _mesAnterior,
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFFB7C0C8),
                      size: 32,
                    ),
                  ),

                  Expanded(
                    child: GestureDetector(
                      onTap: _selecionarMesEAno,
                      child: Text(
                        _tituloCalendario(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4D5965),
                        ),
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: _proximoMes,
                    icon: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFFB7C0C8),
                      size: 32,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              TableCalendar(
                locale: 'pt_BR',
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                focusedDay: focusedDay,
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Mês',
                },
                startingDayOfWeek: StartingDayOfWeek.sunday,
                headerVisible: false,
                daysOfWeekHeight: 32,
                rowHeight: 46,
                sixWeekMonthsEnforced: false,
                shouldFillViewport: false,
                selectedDayPredicate: (day) {
                  return isSameDay(selectedDay, day);
                },
                onPageChanged: (focused) {
                  focusedDay = focused;
                },
                onDaySelected: (selected, focused) {
                  setState(() {
                    selectedDay = selected;
                    focusedDay = focused;
                  });
                },
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: Color(0xFFB7C0C8),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                  weekendStyle: TextStyle(
                    color: Color(0xFFB7C0C8),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  isTodayHighlighted: false,
                  cellMargin: EdgeInsets.all(4),
                  defaultTextStyle: TextStyle(
                    color: Color(0xFF4D5965),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  weekendTextStyle: TextStyle(
                    color: Color(0xFF4D5965),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF29B46E),
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  dowBuilder: (context, day) {
                    final labels = [
                      'DOM',
                      'SEG',
                      'TER',
                      'QUA',
                      'QUI',
                      'SEX',
                      'SÁB',
                    ];

                    return Center(
                      child: Text(
                        labels[day.weekday % 7],
                        style: const TextStyle(
                          color: Color(0xFFB7C0C8),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}