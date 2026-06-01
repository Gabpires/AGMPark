class PagamentoModel {
  final int idPagamento;
  final int idEstadia;
  final int? idEstacionamento;
  final String valor;
  final String formaPagamento;
  final String dataPagamento;
  final String status;
  final String modelo;
  final String marca;
  final String placa;
  final String numeroVaga;
  final String dataEntrada;
  final String dataSaida;

  PagamentoModel({
    required this.idPagamento,
    required this.idEstadia,
    required this.idEstacionamento,
    required this.valor,
    required this.formaPagamento,
    required this.dataPagamento,
    required this.status,
    required this.modelo,
    required this.marca,
    required this.placa,
    required this.numeroVaga,
    required this.dataEntrada,
    required this.dataSaida,
  });

  factory PagamentoModel.fromJson(Map<String, dynamic> json) {
    return PagamentoModel(
      idPagamento:
          _intValue(json, const ['id_pagamento', 'idPagamento', 'id']) ?? 0,
      idEstadia: _intValue(json, const ['id_estadia', 'idEstadia']) ?? 0,
      idEstacionamento: _intValue(json, const [
        'id_estacionamento',
        'idEstacionamento',
      ]),
      valor: _stringValue(json, const [
        'valor',
        'valor_recebido',
        'valor_total',
        'total',
      ]),
      formaPagamento: _stringValue(json, const [
        'forma_pagamento',
        'formaPagamento',
        'metodo_pagamento',
        'metodo',
      ]),
      dataPagamento: _stringValue(json, const [
        'data_pagamento',
        'dataPagamento',
        'created_at',
      ]),
      status: _stringValue(json, const ['status', 'status_pagamento']),
      modelo: _stringValue(json, const [
        'modelo',
        'modelo_carro',
        'veiculo_modelo',
      ]),
      marca: _stringValue(json, const ['marca', 'marca_carro']),
      placa: _stringValue(json, const ['placa', 'placa_carro']),
      numeroVaga: _stringValue(json, const ['numero_vaga', 'vaga']),
      dataEntrada: _stringValue(json, const ['data_entrada', 'entrada']),
      dataSaida: _stringValue(json, const ['data_saida', 'saida']),
    );
  }

  static String _stringValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return '';
  }

  static int? _intValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return int.tryParse(value.toString());
      }
    }

    return null;
  }
}
