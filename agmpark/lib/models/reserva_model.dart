class ReservaModel {
  final int idReserva;
  final String modelo;
  final String marca;
  final String placa;
  final String nomeEstacionamento;
  final String numeroVaga;
  final String statusVaga;
  final String dataReserva;
  final String dataExpiracao;
  final String valor;
  final String status;

  ReservaModel({
    required this.idReserva,
    required this.modelo,
    required this.marca,
    required this.placa,
    required this.nomeEstacionamento,
    required this.numeroVaga,
    required this.statusVaga,
    required this.dataReserva,
    required this.dataExpiracao,
    required this.valor,
    required this.status,
  });

  factory ReservaModel.fromJson(Map<String, dynamic> json) {
    return ReservaModel(
      idReserva: int.tryParse(json['id_reserva'].toString()) ?? 0,
      modelo: json['modelo'] ?? '',
      marca: json['marca'] ?? '',
      placa: json['placa'] ?? '',
      nomeEstacionamento: json['nome_estacionamento'] ?? '',
      numeroVaga: json['numero_vaga'] ?? '',
      statusVaga: json['status_vaga'] ?? '',
      dataReserva: json['data_reserva'] ?? '',
      dataExpiracao: json['data_expiracao'] ?? '',
      valor: json['valor'] ?? '',
      status: json['status'] ?? '',
    );
  }
}