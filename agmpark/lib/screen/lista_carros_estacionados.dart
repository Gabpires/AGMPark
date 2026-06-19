import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/carro_estacionado_model.dart';
import '../services/carro_estacionado_service.dart';
import 'detalhes_estadia.dart' deferred as detalhes_estadia;

class ListaCarrosEstacionadosPage extends StatefulWidget {
  final int idEstacionamento;

  const ListaCarrosEstacionadosPage({
    super.key,
    required this.idEstacionamento,
  });

  @override
  State<ListaCarrosEstacionadosPage> createState() =>
      _ListaCarrosEstacionadosPageState();
}

class _ListaCarrosEstacionadosPageState
    extends State<ListaCarrosEstacionadosPage> {
  final CarroEstacionadoService service = CarroEstacionadoService();

  List<CarroEstacionadoModel> carros = [];
  bool carregando = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregarCarrosEstacionados();
  }

  Future<void> carregarCarrosEstacionados() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final dados = await service.listarCarrosEstacionados(
        widget.idEstacionamento,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        carros = dados;
        carregando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        carregando = false;
        erro = e.toString();
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
        title: const Text(
          'Lista de Carros Estacionados',
          style: TextStyle(fontSize: 18),
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
              const Icon(
                Icons.error_outline,
                size: 44,
                color: Color(0xFF21B573),
              ),
              const SizedBox(height: 12),
              const Text(
                'Não foi possível carregar os carros estacionados.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF21B573),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: carregarCarrosEstacionados,
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

    if (carros.isEmpty) {
      return const Center(child: Text('Nenhum carro estacionado encontrado'));
    }

    return RefreshIndicator(
      color: const Color(0xFF21B573),
      onRefresh: carregarCarrosEstacionados,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: carros.length,
        itemBuilder: (context, index) {
          return CarroEstacionadoCard(
            carro: carros[index],
            idEstacionamento: widget.idEstacionamento,
            onChanged: carregarCarrosEstacionados,
          );
        },
      ),
    );
  }
}

class CarroEstacionadoCard extends StatelessWidget {
  final CarroEstacionadoModel carro;
  final int idEstacionamento;
  final Future<void> Function() onChanged;

  const CarroEstacionadoCard({
    super.key,
    required this.carro,
    required this.idEstacionamento,
    required this.onChanged,
  });

  String _formatarData(String data) {
    if (data.isEmpty) {
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
    if (carro.tempoRestante.isNotEmpty) {
      return carro.tempoRestante;
    }

    if (carro.dataFimEstadia.isEmpty) {
      return '---';
    }

    try {
      final fim = DateTime.parse(carro.dataFimEstadia);
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
      return carro.dataFimEstadia;
    }
  }

  String _texto(String valor) {
    return valor.trim().isEmpty ? '---' : valor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ImagemCarro(url: carro.imagemUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('Carro'),
                    _Valor(_texto(carro.modelo)),
                    const SizedBox(height: 8),
                    const _Label('Placa'),
                    _Valor(_texto(carro.placa)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _Label('Nome do Usuário:'),
          _Valor(_texto(carro.nomeUsuario)),
          const SizedBox(height: 8),
          const _Label('CPF:'),
          _Valor(_texto(carro.cpf)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('Vaga Estacionado'),
                    _Valor(_texto(carro.numeroVaga)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('Data e Hora da Estadia'),
                    _Valor(_formatarData(carro.dataHoraEstadia)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _Label('Tempo Restante'),
          _Valor(_tempoRestante()),
          const SizedBox(height: 10),
          const _Label('Status da Estadia'),
          _Valor(_texto(carro.statusEstadia)),
          const SizedBox(height: 14),
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
              onPressed: () => _abrirDetalhes(context),
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

  Future<void> _abrirDetalhes(BuildContext context) async {
    await detalhes_estadia.loadLibrary();

    if (!context.mounted) {
      return;
    }

    final vagaLiberada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => detalhes_estadia.DetalhesEstadiaPage(
          carro: carro,
          idEstacionamento: idEstacionamento,
        ),
      ),
    );

    if (vagaLiberada == true) {
      await onChanged();
    }
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 112,
        height: 76,
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

class _Label extends StatelessWidget {
  final String texto;

  const _Label(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.1),
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
      overflow: TextOverflow.visible,
      softWrap: true,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.black,
        fontWeight: FontWeight.w500,
        height: 1.15,
      ),
    );
  }
}
