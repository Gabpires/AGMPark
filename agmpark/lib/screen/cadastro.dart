import 'package:agmpark/screen/login.dart';
import 'package:agmpark/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

class CadastroFormPage extends StatefulWidget {
  final String tipo;

  const CadastroFormPage({super.key, required this.tipo});

  @override
  State<CadastroFormPage> createState() => _CadastroFormPageState();
}

class _CadastroFormPageState extends State<CadastroFormPage> {
  final primeiroNomeController = TextEditingController();
  final cpfCnpjController = TextEditingController();
  final emailController = TextEditingController();
  final dataNascimentoController = TextEditingController();
  final telefoneController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();
  bool carregandoCadastro = false;

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
  }

  String tituloCalendario(DateTime data) {
    return '${meses[data.month - 1]} ${data.year}';
  }

  bool concordaTermos = true;

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  @override
  void dispose() {
    primeiroNomeController.dispose();
    cpfCnpjController.dispose();
    emailController.dispose();
    dataNascimentoController.dispose();
    telefoneController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  String formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  String formatarDataApi(DateTime data) {
    return '${data.year}-'
        '${data.month.toString().padLeft(2, '0')}-'
        '${data.day.toString().padLeft(2, '0')}';
  }

  Future<void> cadastrarUsuario() async {
    final nome = primeiroNomeController.text.trim();
    final cpfCnpj = cpfCnpjController.text.trim();
    final email = emailController.text.trim();
    final telefone = telefoneController.text.trim();
    final senha = senhaController.text;
    final confirmarSenha = confirmarSenhaController.text;

    if (!concordaTermos) {
      mostrarErro('Aceite os termos de uso para continuar');
      return;
    }

    if (nome.isEmpty ||
        cpfCnpj.isEmpty ||
        email.isEmpty ||
        selectedDay == null ||
        telefone.isEmpty ||
        senha.isEmpty ||
        confirmarSenha.isEmpty) {
      mostrarErro('Preencha todos os campos para cadastrar');
      return;
    }

    if (senha != confirmarSenha) {
      mostrarErro('As senhas não coincidem');
      return;
    }

    setState(() {
      carregandoCadastro = true;
    });

    try {
      await ApiService.cadastrar(
        nome: nome,
        cpfCnpj: cpfCnpj,
        email: email,
        dataNasc: formatarDataApi(selectedDay!),
        telefone: telefone,
        senha: senha,
        tipo: widget.tipo,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso. Faça login.'),
          backgroundColor: Color(0xFF22B573),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      mostrarErro(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          carregandoCadastro = false;
        });
      }
    }
  }

  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
    );
  }

  InputDecoration campoDecoracao({required String hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF22B573), width: 1.5),
      ),
    );
  }

  void abrirCalendario() {
    showDialog(
      context: context,
      builder: (context) {
        DateTime tempFocusedDay = focusedDay;
        DateTime? tempSelectedDay = selectedDay;

        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> selecionarMesEAno() async {
              int mesSelecionado = tempFocusedDay.month;
              int anoSelecionado = tempFocusedDay.year;

              await showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFFF7F7F7),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setBottomState) {
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
                                        setBottomState(() {
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
                                    items: List.generate(201, (index) {
                                      final ano = 1900 + index;

                                      return DropdownMenuItem(
                                        value: ano,
                                        child: Text(ano.toString()),
                                      );
                                    }),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setBottomState(() {
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
                                  backgroundColor: const Color(0xFF22B573),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  setModalState(() {
                                    tempFocusedDay = DateTime(
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

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: Container(
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
                          onPressed: () {
                            setModalState(() {
                              tempFocusedDay = DateTime(
                                tempFocusedDay.year,
                                tempFocusedDay.month - 1,
                              );
                            });
                          },
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Color(0xFFB7C0C8),
                            size: 32,
                          ),
                        ),

                        Expanded(
                          child: GestureDetector(
                            onTap: selecionarMesEAno,
                            child: Text(
                              tituloCalendario(tempFocusedDay),
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
                          onPressed: () {
                            setModalState(() {
                              tempFocusedDay = DateTime(
                                tempFocusedDay.year,
                                tempFocusedDay.month + 1,
                              );
                            });
                          },
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
                      firstDay: DateTime(1900),
                      lastDay: DateTime(2100),
                      focusedDay: tempFocusedDay,
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
                        return isSameDay(tempSelectedDay, day);
                      },
                      onPageChanged: (focused) {
                        setModalState(() {
                          tempFocusedDay = focused;
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
                          color: Color(0xFF22B573),
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
                          const labels = [
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
                      onDaySelected: (selected, focused) {
                        setState(() {
                          selectedDay = selected;
                          focusedDay = focused;
                          dataNascimentoController.text = formatarData(
                            selected,
                          );
                        });

                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget campoTitulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(fontSize: 12, color: Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: carregandoCadastro ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Cadastro',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conclua seu cadastro',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            const Text(
              'Conclua seu cadastro e comece a sua\n'
              'jornada no gerenciamento de\n'
              'estacionamentos de forma simplificada',
              style: TextStyle(fontSize: 11.5, color: Colors.grey, height: 1.2),
            ),

            const SizedBox(height: 14),

            campoTitulo('Primeiro nome'),
            const SizedBox(height: 4),
            TextField(
              controller: primeiroNomeController,
              enabled: !carregandoCadastro,
              decoration: campoDecoracao(hint: 'Primeiro nome'),
            ),

            const SizedBox(height: 8),

            campoTitulo('CPF / CNPJ'),
            const SizedBox(height: 4),
            TextField(
              controller: cpfCnpjController,
              enabled: !carregandoCadastro,
              keyboardType: TextInputType.number,
              decoration: campoDecoracao(hint: 'CPF / CNPJ'),
            ),

            const SizedBox(height: 8),

            campoTitulo('Endereço de Email'),
            const SizedBox(height: 4),
            TextField(
              controller: emailController,
              enabled: !carregandoCadastro,
              keyboardType: TextInputType.emailAddress,
              decoration: campoDecoracao(hint: 'Endereço de Email'),
            ),

            const SizedBox(height: 8),

            campoTitulo('Data de Nascimento'),
            const SizedBox(height: 4),
            TextField(
              controller: dataNascimentoController,
              enabled: !carregandoCadastro,
              readOnly: true,
              onTap: carregandoCadastro ? null : abrirCalendario,
              decoration: campoDecoracao(
                hint: 'Data de Nascimento',
                suffixIcon: IconButton(
                  onPressed: carregandoCadastro ? null : abrirCalendario,
                  icon: const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF22B573),
                    size: 20,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            campoTitulo('Telefone'),
            const SizedBox(height: 4),
            TextField(
              controller: telefoneController,
              enabled: !carregandoCadastro,
              keyboardType: TextInputType.phone,
              decoration: campoDecoracao(hint: '(XX) X XXXX-XXXX'),
            ),

            const SizedBox(height: 8),

            campoTitulo('Senha'),
            const SizedBox(height: 4),
            TextField(
              controller: senhaController,
              enabled: !carregandoCadastro,
              obscureText: true,
              decoration: campoDecoracao(hint: 'Senha'),
            ),

            const SizedBox(height: 8),

            campoTitulo('Confirmação de senha'),
            const SizedBox(height: 4),
            TextField(
              controller: confirmarSenhaController,
              enabled: !carregandoCadastro,
              obscureText: true,
              decoration: campoDecoracao(hint: 'Confirmação de senha'),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Checkbox(
                  value: concordaTermos,
                  activeColor: const Color(0xFF22B573),
                  onChanged: carregandoCadastro
                      ? null
                      : (value) {
                          setState(() {
                            concordaTermos = value ?? false;
                          });
                        },
                ),
                const Text(
                  'Eu concordo com os termo de uso.',
                  style: TextStyle(fontSize: 10.5, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: carregandoCadastro ? null : cadastrarUsuario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22B573),
                  disabledBackgroundColor: const Color(0xFF22B573),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: carregandoCadastro
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Cadastrar-se',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
