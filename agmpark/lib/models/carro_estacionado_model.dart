class CarroEstacionadoModel {
  final int idEstadia;
  final int? idVeiculo;
  final int? idVaga;
  final int? idReserva;
  final int? idEstacionamento;
  final String modelo;
  final String marca;
  final String placa;
  final String nomeUsuario;
  final String cpf;
  final String numeroVaga;
  final String dataHoraEstadia;
  final String dataFimEstadia;
  final String dataHoraSaida;
  final String tempoRestante;
  final String statusEstadia;
  final String valorTotal;
  final String imagemUrl;

  CarroEstacionadoModel({
    required this.idEstadia,
    required this.idVeiculo,
    required this.idVaga,
    required this.idReserva,
    required this.idEstacionamento,
    required this.modelo,
    required this.marca,
    required this.placa,
    required this.nomeUsuario,
    required this.cpf,
    required this.numeroVaga,
    required this.dataHoraEstadia,
    required this.dataFimEstadia,
    required this.dataHoraSaida,
    required this.tempoRestante,
    required this.statusEstadia,
    required this.valorTotal,
    required this.imagemUrl,
  });

  factory CarroEstacionadoModel.fromJson(Map<String, dynamic> json) {
    return CarroEstacionadoModel(
      idEstadia: _intValue(json, const ['id_estadia', 'idEstadia', 'id']) ?? 0,
      idVeiculo: _intValue(json, const ['id_veiculo', 'idVeiculo']),
      idVaga: _intValue(json, const ['id_vaga', 'idVaga']),
      idReserva: _intValue(json, const ['id_reserva', 'idReserva']),
      idEstacionamento: _intValue(json, const [
        'id_estacionamento',
        'idEstacionamento',
      ]),
      modelo: _stringValue(json, const [
        'modelo',
        'modelo_carro',
        'carro_modelo',
        'veiculo_modelo',
      ]),
      marca: _stringValue(json, const [
        'marca',
        'marca_carro',
        'carro_marca',
        'veiculo_marca',
      ]),
      placa: _stringValue(json, const [
        'placa',
        'placa_carro',
        'carro_placa',
        'veiculo_placa',
      ]),
      nomeUsuario: _stringValue(json, const [
        'nome_usuario',
        'usuario_nome',
        'nome_cliente',
        'cliente_nome',
        'nome',
      ]),
      cpf: _stringValue(json, const [
        'cpf',
        'cpf_usuario',
        'usuario_cpf',
        'cpf_cliente',
        'cliente_cpf',
      ]),
      numeroVaga: _stringValue(json, const [
        'numero_vaga',
        'vaga',
        'vaga_estacionada',
        'vaga_selecionada',
      ]),
      dataHoraEstadia: _stringValue(json, const [
        'data_hora_estadia',
        'data_estadia',
        'data_entrada',
        'entrada',
        'inicio_estadia',
      ]),
      dataFimEstadia: _stringValue(json, const [
        'data_fim_estadia',
        'data_saida_prevista',
        'data_expiracao',
        'fim_estadia',
      ]),
      dataHoraSaida: _stringValue(json, const [
        'data_hora_saida',
        'data_saida',
        'saida',
        'fim_real_estadia',
      ]),
      tempoRestante: _stringValue(json, const [
        'tempo_restante',
        'tempoRestante',
      ]),
      statusEstadia: _stringValue(json, const [
        'status_estadia',
        'status',
        'situacao',
      ]),
      valorTotal: _stringValue(json, const [
        'valor_total',
        'valor_total_estadia',
        'valor_estadia',
        'valor',
        'total',
      ]),
      imagemUrl: _stringValue(json, const [
        'imagem_url',
        'imagem',
        'foto',
        'foto_carro',
        'url_imagem',
      ]),
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
