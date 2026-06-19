class VagaModel {
  final int id;
  final int idEstacionamento;
  final int numeroVaga;
  final String status;
  final String statusFisico;

  VagaModel({
    required this.id,
    required this.idEstacionamento,
    required this.numeroVaga,
    required this.status,
    required this.statusFisico,
  });

  factory VagaModel.fromJson(
    Map<String, dynamic> json, {
    bool considerarStatusFisico = true,
  }) {
    return VagaModel(
      id: _intValue(json['id_vaga']),
      idEstacionamento: _intValue(json['id_estacionamento']),
      numeroVaga: _intValue(json['numero_vaga']),
      status: _stringValue(json['status']).toUpperCase(),
      statusFisico: considerarStatusFisico
          ? _stringValue(json['status_fisico']).toUpperCase()
          : '',
    );
  }

  VagaModel ignorarStatusFisico() {
    if (statusFisico.isEmpty) {
      return this;
    }

    return VagaModel(
      id: id,
      idEstacionamento: idEstacionamento,
      numeroVaga: numeroVaga,
      status: status,
      statusFisico: '',
    );
  }

  bool get ocupada {
    return status == 'OCUPADA' || statusFisico == 'OCUPADA';
  }

  bool get reservada {
    return status == 'RESERVADA';
  }

  bool get emManutencao {
    return status == 'MANUTENCAO';
  }

  bool get livre {
    return status == 'LIVRE' &&
        (statusFisico.isEmpty || statusFisico == 'LIVRE');
  }

  bool get podeAlterarDisponibilidade {
    return !ocupada && !reservada;
  }

  String get textoStatus {
    if (ocupada) {
      return 'Ocupada';
    }

    if (reservada) {
      return 'Reservada';
    }

    if (emManutencao) {
      return 'Indisponível';
    }

    return 'Livre';
  }

  Map<String, dynamic> toUpdateJson(String novoStatus) {
    return {
      'id_estacionamento': idEstacionamento,
      'numero_vaga': numeroVaga,
      'status': novoStatus,
    };
  }

  static int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _stringValue(dynamic value) {
    return value?.toString().trim() ?? '';
  }
}
