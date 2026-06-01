class FuncionarioEstacionamentoModel {
  final int idVinculo;
  final int idFuncionario;
  final int idEstacionamento;
  final String nome;
  final String cpfCnpj;
  final String email;
  final String tipoUsuario;
  final String statusFuncionario;

  FuncionarioEstacionamentoModel({
    required this.idVinculo,
    required this.idFuncionario,
    required this.idEstacionamento,
    required this.nome,
    required this.cpfCnpj,
    required this.email,
    required this.tipoUsuario,
    required this.statusFuncionario,
  });

  factory FuncionarioEstacionamentoModel.fromJson(Map<String, dynamic> json) {
    return FuncionarioEstacionamentoModel(
      idVinculo: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      idFuncionario:
          int.tryParse(json['id_funcionario']?.toString() ?? '') ?? 0,
      idEstacionamento:
          int.tryParse(json['id_estacionamento']?.toString() ?? '') ?? 0,
      nome: json['primeiro_nome']?.toString() ?? '',
      cpfCnpj: json['cpf_cnpj']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      tipoUsuario: json['tipo_usuario']?.toString() ?? '',
      statusFuncionario: json['status_funcionario']?.toString() ?? '',
    );
  }
}
