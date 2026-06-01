import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/carro_estacionado_model.dart';
import '../models/vaga_model.dart';
import '../services/carro_estacionado_service.dart';
import '../services/vaga_service.dart';

class DetalhesEstadiaPage extends StatefulWidget {
  final CarroEstacionadoModel carro;
  final int idEstacionamento;

  const DetalhesEstadiaPage({
    super.key,
    required this.carro,
    required this.idEstacionamento,
  });

  @override
  State<DetalhesEstadiaPage> createState() => _DetalhesEstadiaPageState();
}

class _DetalhesEstadiaPageState extends State<DetalhesEstadiaPage> {
  final _estadiaService = CarroEstacionadoService();
  final _vagaService = VagaService();
  bool liberandoVaga = false;

  Future<void> _confirmarLiberacaoVaga() async {
    if (liberandoVaga) {
      return;
    }

    final confirmado = await _mostrarConfirmacaoLiberarVaga();

    if (confirmado != true || !mounted) {
      return;
    }

    await _liberarVaga();
  }

  Future<void> _liberarVaga() async {
    if (liberandoVaga) {
      return;
    }

    final numeroVaga = _numeroVaga();

    if (numeroVaga == null) {
      _mostrarErro('Não foi possível identificar a vaga da estadia.');
      return;
    }

    if (widget.carro.idEstadia == 0) {
      _mostrarErro('Não foi possível identificar a estadia.');
      return;
    }

    setState(() {
      liberandoVaga = true;
    });

    try {
      final vagas = await _vagaService.listar(widget.idEstacionamento);
      VagaModel? vaga;

      for (final item in vagas) {
        if (item.numeroVaga == numeroVaga) {
          vaga = item;
          break;
        }
      }

      if (vaga == null) {
        throw Exception('Vaga não encontrada.');
      }

      await _estadiaService.finalizarEstadia(
        carro: widget.carro,
        idVaga: widget.carro.idVaga ?? vaga.id,
        dataSaida: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      );
      await _vagaService.atualizarStatus(vaga, 'LIVRE');

      if (!mounted) {
        return;
      }

      setState(() {
        liberandoVaga = false;
      });

      await _mostrarSucessoLiberacao();

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        liberandoVaga = false;
      });

      _mostrarErro(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  int? _numeroVaga() {
    final texto = widget.carro.numeroVaga.trim();

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

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
    );
  }

  Future<bool?> _mostrarConfirmacaoLiberarVaga() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 18, 12, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Deseja Liberar vaga?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF3B30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            'Não',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 22),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF21B573),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Sim',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _mostrarSucessoLiberacao() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sucesso',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF21B573),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 34),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Vaga liberada com sucesso',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.black54),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF21B573),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _entrarEmContato() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contato ainda não disponível.')),
    );
  }

  String _texto(String valor, {String fallback = '---'}) {
    return valor.trim().isEmpty ? fallback : valor.trim();
  }

  String _idEstadia() {
    return widget.carro.idEstadia == 0
        ? 'Estadia #---'
        : 'Estadia #${widget.carro.idEstadia}';
  }

  String _carroDescricao() {
    if (widget.carro.modelo.trim().isNotEmpty) {
      return widget.carro.modelo.trim();
    }

    return _texto(widget.carro.marca);
  }

  String _formatarData(String data) {
    if (data.trim().isEmpty) {
      return '---';
    }

    try {
      final dataConvertida = DateTime.parse(data);
      return DateFormat('dd/MM/yyyy HH:mm').format(dataConvertida);
    } catch (e) {
      return data;
    }
  }

  String _tempoRestante() {
    if (widget.carro.tempoRestante.trim().isNotEmpty) {
      return widget.carro.tempoRestante.trim();
    }

    if (widget.carro.dataFimEstadia.trim().isEmpty) {
      return '---';
    }

    try {
      final fim = DateTime.parse(widget.carro.dataFimEstadia);
      final diferenca = fim.difference(DateTime.now());

      if (diferenca.isNegative) {
        return 'Expirado';
      }

      final dias = diferenca.inDays;
      final horas = diferenca.inHours.remainder(24);
      final minutos = diferenca.inMinutes.remainder(60);

      if (dias > 0) {
        return '${dias}d ${horas}h';
      }

      if (horas > 0) {
        return '${horas}h ${minutos}min';
      }

      return '${minutos}min';
    } catch (e) {
      return widget.carro.dataFimEstadia;
    }
  }

  String _valorTotal() {
    final valor = widget.carro.valorTotal.trim();

    if (valor.isEmpty) {
      return '---';
    }

    final numero = num.tryParse(valor.replaceAll(',', '.'));

    if (numero == null) {
      return valor;
    }

    return 'R\$ ${numero.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _status() {
    final status = widget.carro.statusEstadia.trim();

    if (status.isEmpty) {
      return 'Em andamento';
    }

    return status
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .where((parte) => parte.isNotEmpty)
        .map((parte) => parte[0].toUpperCase() + parte.substring(1))
        .join(' ');
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
          'Detalhes da Estadia',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CabecalhoEstadia(titulo: _idEstadia()),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ImagemCarro(url: widget.carro.imagemUrl),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Carro'),
                        _Valor(_carroDescricao()),
                        const SizedBox(height: 8),
                        const _Label('Placa'),
                        _Valor(_texto(widget.carro.placa)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _Label('Nome do Usuário:'),
              _Valor(_texto(widget.carro.nomeUsuario)),
              const SizedBox(height: 8),
              const _Label('CPF:'),
              _Valor(_texto(widget.carro.cpf)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _CampoDetalhe(
                      titulo: 'Vaga\nSelecionada',
                      valor: _texto(widget.carro.numeroVaga),
                    ),
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: _CampoDetalhe(
                      titulo: 'Data e Hora\nde Entrada',
                      valor: _formatarData(widget.carro.dataHoraEstadia),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _CampoDetalhe(
                      titulo: 'Data e Hora\nde Saída',
                      valor: _formatarData(widget.carro.dataHoraSaida),
                    ),
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: _CampoDetalhe(
                      titulo: 'Tempo Restante\nda Estadia',
                      valor: _tempoRestante(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const _Label('Valor total da estadia'),
              _Valor(_valorTotal()),
              const SizedBox(height: 8),
              const _Label('Status da Estadia'),
              _Valor(_status()),
              const SizedBox(height: 16),
              Center(
                child: _LiberarVagaButton(
                  carregando: liberandoVaga,
                  onPressed: _confirmarLiberacaoVaga,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 38,
                child: ElevatedButton(
                  onPressed: _entrarEmContato,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF21B573),
                    elevation: 6,
                    shadowColor: Colors.black38,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: const Text(
                    'Entrar em contato',
                    style: TextStyle(color: Colors.white, fontSize: 12),
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

class _CabecalhoEstadia extends StatelessWidget {
  final String titulo;

  const _CabecalhoEstadia({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1.8),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.call_received, size: 22, color: Colors.black),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ],
    );
  }
}

class _ImagemCarro extends StatelessWidget {
  final String url;

  const _ImagemCarro({required this.url});

  @override
  Widget build(BuildContext context) {
    final imageUrl = _urlCompleta(url);
    final hasImage = imageUrl.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: 112,
        height: 74,
        color: Colors.grey.shade300,
        child: hasImage
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.directions_car,
                    size: 48,
                    color: Colors.black54,
                  );
                },
              )
            : const Icon(Icons.directions_car, size: 48, color: Colors.black54),
      ),
    );
  }

  String _urlCompleta(String valor) {
    final caminho = valor.trim();

    if (caminho.isEmpty) {
      return '';
    }

    final uri = Uri.tryParse(caminho);

    if (uri != null && uri.hasScheme) {
      return caminho;
    }

    if (caminho.startsWith('/')) {
      return '${CarroEstacionadoService.baseUrl}$caminho';
    }

    return '${CarroEstacionadoService.baseUrl}/$caminho';
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
      children: [_Label(titulo), const SizedBox(height: 1), _Valor(valor)],
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
      style: const TextStyle(fontSize: 14, color: Colors.black, height: 1.05),
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
      style: const TextStyle(fontSize: 12, color: Colors.black, height: 1.15),
    );
  }
}

class _LiberarVagaButton extends StatelessWidget {
  final bool carregando;
  final VoidCallback onPressed;

  const _LiberarVagaButton({required this.carregando, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 90,
      child: ElevatedButton(
        onPressed: carregando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF21B573),
          disabledBackgroundColor: const Color(0xFF21B573),
          elevation: 6,
          shadowColor: Colors.black38,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        ),
        child: carregando
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 42,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Liberar Vaga',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }
}
