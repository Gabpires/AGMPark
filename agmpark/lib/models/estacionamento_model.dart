class EstacionamentoModel {
  final int? id;
  final String nome;
  final String estado;
  final String rua;
  final int numero_estacionamento;
  final String bairro;
  final String cidade;
  final String cep;
  final int numero_vagas;
  final int quantidadeTempo;
  final String valorTempo;
  final String status;

  EstacionamentoModel({
    this.id,
    required this.nome,
    required this.estado,
    required this.rua,
    required this.numero_estacionamento,
    required this.bairro,
    required this.cidade,
    required this.cep,
    required this.numero_vagas,
    this.quantidadeTempo = 0,
    this.valorTempo = '',
    this.status = 'ATIVO',
  });

  Map<String, dynamic> toJson() {
    return {
      'id_estacionamento': id,
      'nome': nome,
      'estado': estado,
      'rua': rua,
      'numeroEstacionamento': numero_estacionamento,
      'bairro': bairro,
      'cidade': cidade,
      'cep': cep,
      'quantidadeTempo': quantidadeTempo,
      'valorTempo': valorTempo,
      'numeroVagas': numero_vagas,
    };
  }

  factory EstacionamentoModel.fromJson(Map<String, dynamic> json) {
    return EstacionamentoModel(
      id: int.tryParse(json['id_estacionamento'].toString()),
      nome: json['nome'] ?? json['nome_estacionamento'] ?? '',
      estado: json['estado'] ?? '',
      rua: json['rua'] ?? '',
      numero_estacionamento:
          int.tryParse(json['numero_estacionamento'].toString()) ?? 0,
      bairro: json['bairro'] ?? '',
      cidade: json['cidade'] ?? '',
      cep: json['cep'] ?? '',
      numero_vagas: int.tryParse(json['numero_vagas'].toString()) ?? 0,
      quantidadeTempo:
          int.tryParse(json['quantidade_tempo']?.toString() ?? '') ?? 0,
      valorTempo: json['valor_tempo']?.toString() ?? '',
      status:
          (json['status'] ?? json['status_estacionamento'])
              ?.toString()
              .toUpperCase() ??
          'ATIVO',
    );
  }

  bool get ativo {
    return status == 'ATIVO';
  }
}
