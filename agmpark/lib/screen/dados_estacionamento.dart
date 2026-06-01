import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/carro_estacionado_model.dart';
import '../models/estacionamento_model.dart';
import '../models/pagamento_model.dart';
import '../services/carro_estacionado_service.dart';
import '../services/pagamento_service.dart';

const _verde = Color(0xFF21B573);

class DadosEstacionamentoPage extends StatelessWidget {
  final EstacionamentoModel estacionamento;

  const DadosEstacionamentoPage({super.key, required this.estacionamento});

  int get _idEstacionamento {
    return estacionamento.id ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar('Dados do estacionamento'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MenuDadosItem(
                texto: 'Hist\u00f3rico de Vagas',
                icon: Icons.history_toggle_off,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistoricoEstadiasPage(
                        idEstacionamento: _idEstacionamento,
                        nomeEstacionamento: estacionamento.nome,
                      ),
                    ),
                  );
                },
              ),
              _MenuDadosItem(
                texto: 'Hist\u00f3rico de pagamentos',
                icon: Icons.payments_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistoricoPagamentosPage(
                        idEstacionamento: _idEstacionamento,
                      ),
                    ),
                  );
                },
              ),
              _MenuDadosItem(
                texto: 'Desempenho do estacionamento',
                icon: Icons.bar_chart,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DesempenhoEstacionamentoPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuDadosItem extends StatelessWidget {
  final String texto;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuDadosItem({
    required this.texto,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 26, color: Colors.black87),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  texto,
                  style: const TextStyle(fontSize: 22, color: Colors.black),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }
}

class DesempenhoEstacionamentoPage extends StatelessWidget {
  const DesempenhoEstacionamentoPage({super.key});

  @override
  Widget build(BuildContext context) {
    const meses = ['Jan', 'Fev', 'Mar', 'Abr', 'Maio', 'Jun'];
    const valores = [6.5, 8.0, 8.9, 4.1, 8.0, 5.3];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar('Desempenho do estacionamento'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 46, 24, 18),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 390,
                          width: double.infinity,
                          child: _GraficoDesempenho(
                            meses: meses,
                            valores: valores,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Container(width: 12, height: 12, color: _verde),
                            const SizedBox(width: 10),
                            const Text(
                              'Desempenho',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _verde,
                    elevation: 7,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Voltar',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GraficoDesempenho extends StatelessWidget {
  final List<String> meses;
  final List<double> valores;

  const _GraficoDesempenho({required this.meses, required this.valores});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GraficoDesempenhoPainter(meses: meses, valores: valores),
    );
  }
}

class _GraficoDesempenhoPainter extends CustomPainter {
  final List<String> meses;
  final List<double> valores;

  const _GraficoDesempenhoPainter({required this.meses, required this.valores});

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.4;
    final barPaint = Paint()..color = _verde;
    final left = 40.0;
    final top = 16.0;
    final bottom = size.height - 48.0;
    final right = size.width - 10.0;
    final height = bottom - top;
    final width = right - left;

    canvas.drawLine(Offset(left, top), Offset(left, bottom + 18), axisPaint);
    canvas.drawLine(
      Offset(left - 28, bottom),
      Offset(right, bottom),
      axisPaint,
    );

    for (var i = 0; i <= 10; i++) {
      final y = bottom - (i / 10) * height;
      _drawText(
        canvas,
        i.toString(),
        Offset(left - 34, y - 8),
        const TextStyle(fontSize: 12, color: Colors.black),
        width: 26,
        align: TextAlign.right,
      );
    }

    final slot = width / valores.length;
    final barWidth = math.min(48.0, slot * 0.68);

    for (var i = 0; i < valores.length; i++) {
      final value = valores[i].clamp(0, 10);
      final barHeight = (value / 10) * height;
      final x = left + slot * i + (slot - barWidth) / 2;
      final rect = Rect.fromLTWH(x, bottom - barHeight, barWidth, barHeight);
      canvas.drawRect(rect, barPaint);

      _drawText(
        canvas,
        meses[i],
        Offset(left + slot * i, bottom + 12),
        const TextStyle(fontSize: 14, color: Colors.black),
        width: slot,
        align: TextAlign.center,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style, {
    required double width,
    TextAlign align = TextAlign.left,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: align,
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: width);

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _GraficoDesempenhoPainter oldDelegate) {
    return oldDelegate.valores != valores || oldDelegate.meses != meses;
  }
}

class HistoricoEstadiasPage extends StatefulWidget {
  final int idEstacionamento;
  final String nomeEstacionamento;

  const HistoricoEstadiasPage({
    super.key,
    required this.idEstacionamento,
    required this.nomeEstacionamento,
  });

  @override
  State<HistoricoEstadiasPage> createState() => _HistoricoEstadiasPageState();
}

class _HistoricoEstadiasPageState extends State<HistoricoEstadiasPage> {
  final _service = CarroEstacionadoService();
  final _pesquisaController = TextEditingController();

  List<CarroEstacionadoModel> estadias = [];
  bool carregando = true;
  String? erro;
  String pesquisa = '';
  _HistoricoFiltro filtro = const _HistoricoFiltro();

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final dados = await _service.listarCarrosEstacionados(
        widget.idEstacionamento,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        estadias = dados;
        carregando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        erro = e.toString().replaceFirst('Exception: ', '');
        carregando = false;
      });
    }
  }

  List<CarroEstacionadoModel> get _estadiasFiltradas {
    final termo = _normalizar(pesquisa);
    final lista = estadias.where((estadia) {
      final textoBusca = _normalizar(
        [
          estadia.idEstadia.toString(),
          estadia.nomeUsuario,
          estadia.cpf,
          estadia.numeroVaga,
          estadia.placa,
          estadia.modelo,
          estadia.statusEstadia,
          widget.nomeEstacionamento,
        ].join(' '),
      );

      if (termo.isNotEmpty && !textoBusca.contains(termo)) {
        return false;
      }

      return _dataDentroDoFiltro(_parseData(estadia.dataHoraEstadia), filtro);
    }).toList();

    lista.sort((a, b) {
      final dataA =
          _parseData(a.dataHoraEstadia) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final dataB =
          _parseData(b.dataHoraEstadia) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final resultado = dataA.compareTo(dataB);
      return filtro.crescente ? resultado : -resultado;
    });

    return lista;
  }

  Future<void> _abrirFiltro() async {
    final novoFiltro = await showDialog<_HistoricoFiltro>(
      context: context,
      builder: (context) => _FiltroHistoricoDialog(filtro: filtro),
    );

    if (novoFiltro == null || !mounted) {
      return;
    }

    setState(() {
      filtro = novoFiltro;
    });
  }

  @override
  Widget build(BuildContext context) {
    final resultado = _estadiasFiltradas;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar('Hist\u00f3rico de Vagas'),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: _PesquisaHeader(
                titulo: 'Vagas',
                controller: _pesquisaController,
                onChanged: (valor) => setState(() => pesquisa = valor),
                onFilter: _abrirFiltro,
                filtroAtivo: filtro.ativo,
              ),
            ),
            Expanded(child: _buildConteudo(resultado)),
          ],
        ),
      ),
    );
  }

  Widget _buildConteudo(List<CarroEstacionadoModel> resultado) {
    if (carregando) {
      return const Center(child: CircularProgressIndicator(color: _verde));
    }

    if (erro != null) {
      return _ErroState(mensagem: erro!, onRetry: _carregar);
    }

    if (resultado.isEmpty) {
      return const _SecaoVazia(
        icon: Icons.history_toggle_off,
        texto: 'Nenhuma estadia encontrada',
      );
    }

    return RefreshIndicator(
      color: _verde,
      onRefresh: _carregar,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: resultado.length,
        itemBuilder: (context, index) {
          final estadia = resultado[index];

          return _EstadiaHistoricoCard(
            estadia: estadia,
            nomeEstacionamento: widget.nomeEstacionamento,
            onVerMais: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetalhesHistoricoEstadiaPage(
                    estadia: estadia,
                    nomeEstacionamento: widget.nomeEstacionamento,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class HistoricoPagamentosPage extends StatefulWidget {
  final int idEstacionamento;

  const HistoricoPagamentosPage({super.key, required this.idEstacionamento});

  @override
  State<HistoricoPagamentosPage> createState() =>
      _HistoricoPagamentosPageState();
}

class _HistoricoPagamentosPageState extends State<HistoricoPagamentosPage> {
  final _service = PagamentoService();
  final _pesquisaController = TextEditingController();

  List<PagamentoModel> pagamentos = [];
  bool carregando = true;
  String? erro;
  String pesquisa = '';
  _HistoricoFiltro filtro = const _HistoricoFiltro();

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final dados = await _service.listarPagamentos(widget.idEstacionamento);

      if (!mounted) {
        return;
      }

      setState(() {
        pagamentos = dados;
        carregando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        erro = e.toString().replaceFirst('Exception: ', '');
        carregando = false;
      });
    }
  }

  List<PagamentoModel> get _pagamentosFiltrados {
    final termo = _normalizar(pesquisa);
    final lista = pagamentos.where((pagamento) {
      final textoBusca = _normalizar(
        [
          pagamento.idPagamento.toString(),
          pagamento.idEstadia.toString(),
          pagamento.valor,
          pagamento.formaPagamento,
          pagamento.status,
          pagamento.modelo,
          pagamento.marca,
          pagamento.placa,
          pagamento.numeroVaga,
        ].join(' '),
      );

      if (termo.isNotEmpty && !textoBusca.contains(termo)) {
        return false;
      }

      return _dataDentroDoFiltro(_parseData(pagamento.dataPagamento), filtro);
    }).toList();

    lista.sort((a, b) {
      final dataA =
          _parseData(a.dataPagamento) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dataB =
          _parseData(b.dataPagamento) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final resultado = dataA.compareTo(dataB);
      return filtro.crescente ? resultado : -resultado;
    });

    return lista;
  }

  Future<void> _abrirFiltro() async {
    final novoFiltro = await showDialog<_HistoricoFiltro>(
      context: context,
      builder: (context) => _FiltroHistoricoDialog(filtro: filtro),
    );

    if (novoFiltro == null || !mounted) {
      return;
    }

    setState(() {
      filtro = novoFiltro;
    });
  }

  @override
  Widget build(BuildContext context) {
    final resultado = _pagamentosFiltrados;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar('Hist\u00f3rico de Pagamentos'),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: _PesquisaHeader(
                titulo: 'Pagamentos',
                controller: _pesquisaController,
                onChanged: (valor) => setState(() => pesquisa = valor),
                onFilter: _abrirFiltro,
                filtroAtivo: filtro.ativo,
              ),
            ),
            Expanded(child: _buildConteudo(resultado)),
          ],
        ),
      ),
    );
  }

  Widget _buildConteudo(List<PagamentoModel> resultado) {
    if (carregando) {
      return const Center(child: CircularProgressIndicator(color: _verde));
    }

    if (erro != null) {
      return _ErroState(mensagem: erro!, onRetry: _carregar);
    }

    if (resultado.isEmpty) {
      return const _SecaoVazia(
        icon: Icons.payments_outlined,
        texto: 'Nenhum pagamento encontrado',
      );
    }

    return RefreshIndicator(
      color: _verde,
      onRefresh: _carregar,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: resultado.length,
        itemBuilder: (context, index) {
          final pagamento = resultado[index];

          return _PagamentoHistoricoCard(
            pagamento: pagamento,
            onVerMais: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetalhesPagamentoPage(pagamento: pagamento),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PesquisaHeader extends StatelessWidget {
  final String titulo;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilter;
  final bool filtroAtivo;

  const _PesquisaHeader({
    required this.titulo,
    required this.controller,
    required this.onChanged,
    required this.onFilter,
    required this.filtroAtivo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: 'Palavra-chave',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    suffixIcon: const Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 32,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade500),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade500),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _verde, width: 1.4),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _BotaoFiltro(onTap: onFilter, ativo: filtroAtivo),
          ],
        ),
      ],
    );
  }
}

class _BotaoFiltro extends StatelessWidget {
  final VoidCallback onTap;
  final bool ativo;

  const _BotaoFiltro({required this.onTap, required this.ativo});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: ativo ? const Color(0xFF168E58) : _verde,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _verde.withValues(alpha: 0.24),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.tune, color: Colors.white, size: 30),
      ),
    );
  }
}

class _EstadiaHistoricoCard extends StatelessWidget {
  final CarroEstacionadoModel estadia;
  final String nomeEstacionamento;
  final VoidCallback onVerMais;

  const _EstadiaHistoricoCard({
    required this.estadia,
    required this.nomeEstacionamento,
    required this.onVerMais,
  });

  @override
  Widget build(BuildContext context) {
    return _HistoricoCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitulo(
            icon: Icons.call_received,
            titulo: _idEstadia(estadia.idEstadia),
          ),
          const SizedBox(height: 14),
          const _Label('Nome do Usu\u00e1rio:'),
          _Valor(_texto(estadia.nomeUsuario)),
          const SizedBox(height: 8),
          const _Label('CPF:'),
          _Valor(_texto(estadia.cpf)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _CampoDetalhe(
                  titulo: 'Vaga\nSelecionada',
                  valor: _texto(estadia.numeroVaga),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _CampoDetalhe(
                  titulo: 'Data e Hora\nde Entrada',
                  valor: _formatarData(estadia.dataHoraEstadia),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _CampoDetalhe(
                  titulo: 'Data e Hora\nde Sa\u00edda',
                  valor: _formatarData(estadia.dataHoraSaida),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _CampoDetalhe(
                  titulo: 'Carro',
                  valor: _carroDescricao(estadia),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _Label('Placa'),
          _Valor(_texto(estadia.placa)),
          const SizedBox(height: 8),
          const _Label('Nome do Estacionamento'),
          _Valor(_texto(nomeEstacionamento)),
          const SizedBox(height: 16),
          _BotaoVerMais(onPressed: onVerMais),
        ],
      ),
    );
  }
}

class _PagamentoHistoricoCard extends StatelessWidget {
  final PagamentoModel pagamento;
  final VoidCallback onVerMais;

  const _PagamentoHistoricoCard({
    required this.pagamento,
    required this.onVerMais,
  });

  @override
  Widget build(BuildContext context) {
    return _HistoricoCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitulo(
            icon: Icons.payments_outlined,
            titulo: _idPagamento(pagamento.idPagamento),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _CampoDetalhe(
                  titulo: 'Valor Recebido',
                  valor: _formatarValor(pagamento.valor),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _CampoDetalhe(
                  titulo: 'Status',
                  valor: _statusLegivel(pagamento.status),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _Label('Forma de pagamento'),
          _Valor(_formaPagamento(pagamento.formaPagamento)),
          const SizedBox(height: 12),
          const _Label('Estadia relacionada'),
          _Valor(_idEstadia(pagamento.idEstadia)),
          const SizedBox(height: 12),
          const _Label('Data e Hora de Pagamento'),
          _Valor(_formatarData(pagamento.dataPagamento)),
          const SizedBox(height: 16),
          _BotaoVerMais(onPressed: onVerMais),
        ],
      ),
    );
  }
}

class DetalhesHistoricoEstadiaPage extends StatelessWidget {
  final CarroEstacionadoModel estadia;
  final String nomeEstacionamento;

  const DetalhesHistoricoEstadiaPage({
    super.key,
    required this.estadia,
    required this.nomeEstacionamento,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar('Detalhes da Estadia'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardTitulo(
                icon: Icons.call_received,
                titulo: _idEstadia(estadia.idEstadia),
              ),
              const SizedBox(height: 20),
              _DetalheLinha(
                titulo: 'Nome do Usu\u00e1rio',
                valor: estadia.nomeUsuario,
              ),
              _DetalheLinha(titulo: 'CPF', valor: estadia.cpf),
              _DetalheLinha(
                titulo: 'Vaga selecionada',
                valor: estadia.numeroVaga,
              ),
              _DetalheLinha(
                titulo: 'Data e hora de entrada',
                valor: _formatarData(estadia.dataHoraEstadia),
              ),
              _DetalheLinha(
                titulo: 'Data e hora de sa\u00edda',
                valor: _formatarData(estadia.dataHoraSaida),
              ),
              _DetalheLinha(titulo: 'Carro', valor: _carroDescricao(estadia)),
              _DetalheLinha(titulo: 'Placa', valor: estadia.placa),
              _DetalheLinha(
                titulo: 'Valor total',
                valor: _formatarValor(estadia.valorTotal),
              ),
              _DetalheLinha(
                titulo: 'Status',
                valor: _statusLegivel(estadia.statusEstadia),
              ),
              _DetalheLinha(
                titulo: 'Nome do estacionamento',
                valor: nomeEstacionamento,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetalhesPagamentoPage extends StatelessWidget {
  final PagamentoModel pagamento;

  const DetalhesPagamentoPage({super.key, required this.pagamento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar('Detalhes do Pagamento'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardTitulo(
                icon: Icons.payments_outlined,
                titulo: _idPagamento(pagamento.idPagamento),
              ),
              const SizedBox(height: 20),
              _DetalheLinha(
                titulo: 'Valor recebido',
                valor: _formatarValor(pagamento.valor),
              ),
              _DetalheLinha(
                titulo: 'Forma de pagamento',
                valor: _formaPagamento(pagamento.formaPagamento),
              ),
              _DetalheLinha(
                titulo: 'Status',
                valor: _statusLegivel(pagamento.status),
              ),
              _DetalheLinha(
                titulo: 'Estadia relacionada',
                valor: _idEstadia(pagamento.idEstadia),
              ),
              _DetalheLinha(
                titulo: 'Data e hora de pagamento',
                valor: _formatarData(pagamento.dataPagamento),
              ),
              _DetalheLinha(titulo: 'Carro', valor: _texto(pagamento.modelo)),
              _DetalheLinha(titulo: 'Marca', valor: pagamento.marca),
              _DetalheLinha(titulo: 'Placa', valor: pagamento.placa),
              _DetalheLinha(titulo: 'Vaga', valor: pagamento.numeroVaga),
              _DetalheLinha(
                titulo: 'Entrada da estadia',
                valor: _formatarData(pagamento.dataEntrada),
              ),
              _DetalheLinha(
                titulo: 'Sa\u00edda da estadia',
                valor: _formatarData(pagamento.dataSaida),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetalheLinha extends StatelessWidget {
  final String titulo;
  final String valor;

  const _DetalheLinha({required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(titulo),
          const SizedBox(height: 3),
          _Valor(_texto(valor)),
        ],
      ),
    );
  }
}

class _HistoricoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;

  const _HistoricoCard({required this.child, required this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardTitulo extends StatelessWidget {
  final IconData icon;
  final String titulo;

  const _CardTitulo({required this.icon, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 28, color: Colors.black),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(fontSize: 22, color: Colors.black),
          ),
        ),
      ],
    );
  }
}

class _CampoDetalhe extends StatelessWidget {
  final String titulo;
  final String valor;

  const _CampoDetalhe({required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_Label(titulo), const SizedBox(height: 3), _Valor(valor)],
    );
  }
}

class _Label extends StatelessWidget {
  final String texto;

  const _Label(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(fontSize: 16, color: Colors.black, height: 1.08),
    );
  }
}

class _Valor extends StatelessWidget {
  final String texto;

  const _Valor(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      softWrap: true,
      style: const TextStyle(fontSize: 15, color: Colors.black, height: 1.18),
    );
  }
}

class _BotaoVerMais extends StatelessWidget {
  final VoidCallback onPressed;

  const _BotaoVerMais({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _verde,
          elevation: 5,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        onPressed: onPressed,
        child: const Text(
          'Ver mais',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}

class _ErroState extends StatelessWidget {
  final String mensagem;
  final Future<void> Function() onRetry;

  const _ErroState({required this.mensagem, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44, color: _verde),
            const SizedBox(height: 12),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 42,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _verde,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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

class _SecaoVazia extends StatelessWidget {
  final IconData icon;
  final String texto;

  const _SecaoVazia({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: _verde),
            const SizedBox(height: 12),
            Text(texto, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _HistoricoFiltro {
  final bool crescente;
  final DateTime? dataInicio;
  final DateTime? dataFim;

  const _HistoricoFiltro({
    this.crescente = true,
    this.dataInicio,
    this.dataFim,
  });

  bool get ativo {
    return !crescente || dataInicio != null || dataFim != null;
  }
}

class _FiltroHistoricoDialog extends StatefulWidget {
  final _HistoricoFiltro filtro;

  const _FiltroHistoricoDialog({required this.filtro});

  @override
  State<_FiltroHistoricoDialog> createState() => _FiltroHistoricoDialogState();
}

class _FiltroHistoricoDialogState extends State<_FiltroHistoricoDialog> {
  late bool crescente;
  DateTime? dataInicio;
  DateTime? dataFim;

  @override
  void initState() {
    super.initState();
    crescente = widget.filtro.crescente;
    dataInicio = widget.filtro.dataInicio;
    dataFim = widget.filtro.dataFim;
  }

  Future<void> _selecionarData({required bool inicio}) async {
    final atual = inicio ? dataInicio : dataFim;
    final selecionada = await showDatePicker(
      context: context,
      initialDate: atual ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: const ColorScheme.light(primary: _verde)),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (selecionada == null || !mounted) {
      return;
    }

    setState(() {
      if (inicio) {
        dataInicio = selecionada;
      } else {
        dataFim = selecionada;
      }
    });
  }

  void _aplicar() {
    Navigator.pop(
      context,
      _HistoricoFiltro(
        crescente: crescente,
        dataInicio: dataInicio,
        dataFim: dataFim,
      ),
    );
  }

  void _limpar() {
    Navigator.pop(context, const _HistoricoFiltro());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Filtrar pesquisa',
                style: TextStyle(fontSize: 26, color: Colors.black),
              ),
            ),
            const SizedBox(height: 24),
            const _Label('Ordem'),
            const SizedBox(height: 6),
            DropdownButtonFormField<bool>(
              initialValue: crescente,
              decoration: _campoFiltroDecoration(),
              items: const [
                DropdownMenuItem(value: true, child: Text('Data crescente')),
                DropdownMenuItem(value: false, child: Text('Data decrescente')),
              ],
              onChanged: (valor) {
                if (valor == null) {
                  return;
                }

                setState(() => crescente = valor);
              },
            ),
            const SizedBox(height: 18),
            const _Label('Selecione o in\u00edcio da data'),
            const SizedBox(height: 6),
            _DataFiltroCampo(
              texto: _formatarDataFiltro(dataInicio),
              onTap: () => _selecionarData(inicio: true),
            ),
            const SizedBox(height: 18),
            const _Label('Selecione o fim da data'),
            const SizedBox(height: 6),
            _DataFiltroCampo(
              texto: _formatarDataFiltro(dataFim),
              onTap: () => _selecionarData(inicio: false),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _verde,
                  elevation: 7,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _aplicar,
                child: const Text(
                  'Filtrar',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            TextButton(
              onPressed: _limpar,
              child: const Text(
                'Limpar filtros',
                style: TextStyle(color: _verde),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataFiltroCampo extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;

  const _DataFiltroCampo({required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: InputDecorator(
        decoration: _campoFiltroDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 18,
                  color: texto.contains('X')
                      ? Colors.grey.shade600
                      : Colors.black,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade700, size: 36),
          ],
        ),
      ),
    );
  }
}

PreferredSizeWidget _appBar(String titulo) {
  return AppBar(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 3,
    shadowColor: Colors.black26,
    title: Text(
      titulo,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
    ),
  );
}

InputDecoration _campoFiltroDecoration() {
  return InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade500),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _verde, width: 1.4),
    ),
  );
}

String _texto(String valor) {
  return valor.trim().isEmpty ? '---' : valor.trim();
}

String _idEstadia(int id) {
  return id == 0 ? 'Estadia #---' : 'Estadia #$id';
}

String _idPagamento(int id) {
  return id == 0 ? 'Pagamento #---' : 'Pagamento #$id';
}

String _carroDescricao(CarroEstacionadoModel estadia) {
  if (estadia.modelo.trim().isNotEmpty) {
    return estadia.modelo.trim();
  }

  return _texto(estadia.marca);
}

String _formatarData(String data) {
  final parsed = _parseData(data);

  if (parsed == null) {
    return _texto(data);
  }

  return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
}

String _formatarDataFiltro(DateTime? data) {
  if (data == null) {
    return 'XX/XX/XXXX';
  }

  return DateFormat('dd/MM/yyyy').format(data);
}

DateTime? _parseData(String data) {
  final texto = data.trim();

  if (texto.isEmpty) {
    return null;
  }

  final iso = DateTime.tryParse(texto);

  if (iso != null) {
    return iso;
  }

  for (final formato in ['dd/MM/yyyy HH:mm', 'dd/MM/yyyy']) {
    try {
      return DateFormat(formato).parseStrict(texto);
    } catch (e) {
      continue;
    }
  }

  return null;
}

bool _dataDentroDoFiltro(DateTime? data, _HistoricoFiltro filtro) {
  if (filtro.dataInicio == null && filtro.dataFim == null) {
    return true;
  }

  if (data == null) {
    return false;
  }

  final inicio = filtro.dataInicio;
  final fim = filtro.dataFim == null
      ? null
      : DateTime(
          filtro.dataFim!.year,
          filtro.dataFim!.month,
          filtro.dataFim!.day,
          23,
          59,
          59,
        );

  if (inicio != null && data.isBefore(inicio)) {
    return false;
  }

  if (fim != null && data.isAfter(fim)) {
    return false;
  }

  return true;
}

String _formatarValor(String valor) {
  final texto = valor.trim();

  if (texto.isEmpty) {
    return '---';
  }

  var normalizado = texto
      .replaceAll('R\$', '')
      .replaceAll(RegExp(r'[^0-9,.-]'), '')
      .trim();

  if (normalizado.contains(',') && normalizado.contains('.')) {
    normalizado = normalizado.replaceAll('.', '').replaceAll(',', '.');
  } else {
    normalizado = normalizado.replaceAll(',', '.');
  }

  final numero = num.tryParse(normalizado);

  if (numero == null) {
    return texto;
  }

  return 'R\$ ${numero.toStringAsFixed(2).replaceAll('.', ',')}';
}

String _formaPagamento(String valor) {
  final status = valor.trim().toUpperCase();

  if (status.isEmpty) {
    return '---';
  }

  switch (status) {
    case 'DEBITO':
    case 'D\u00c9BITO':
      return 'D\u00e9bito';
    case 'CREDITO':
    case 'CR\u00c9DITO':
      return 'Cr\u00e9dito';
    case 'CARTAO_CREDITO':
    case 'CARTAO DE CREDITO':
      return 'Cart\u00e3o de cr\u00e9dito';
    case 'CARTAO_DEBITO':
    case 'CARTAO DE DEBITO':
      return 'Cart\u00e3o de d\u00e9bito';
    case 'PIX':
      return 'Pix';
    case 'DINHEIRO':
      return 'Dinheiro';
    default:
      return _statusLegivel(status);
  }
}

String _statusLegivel(String valor) {
  final texto = valor.trim();

  if (texto.isEmpty) {
    return '---';
  }

  return texto
      .replaceAll('_', ' ')
      .toLowerCase()
      .split(' ')
      .where((parte) => parte.isNotEmpty)
      .map((parte) => parte[0].toUpperCase() + parte.substring(1))
      .join(' ');
}

String _normalizar(String texto) {
  return texto
      .toLowerCase()
      .replaceAll(RegExp('[\u00e1\u00e0\u00e3\u00e2\u00e4]'), 'a')
      .replaceAll(RegExp('[\u00e9\u00e8\u00ea\u00eb]'), 'e')
      .replaceAll(RegExp('[\u00ed\u00ec\u00ee\u00ef]'), 'i')
      .replaceAll(RegExp('[\u00f3\u00f2\u00f5\u00f4\u00f6]'), 'o')
      .replaceAll(RegExp('[\u00fa\u00f9\u00fb\u00fc]'), 'u')
      .replaceAll('\u00e7', 'c');
}
