import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/funcionario_estacionamento_model.dart';
import 'auth_service.dart';

class FuncionarioEstacionamentoService {
  static String get baseUrl => ApiService.baseUrl;

  Future<List<FuncionarioEstacionamentoModel>> listar(
    int idEstacionamento,
  ) async {
    final uri = Uri.parse('$baseUrl/FuncionarioEstacionamento/listar').replace(
      queryParameters: {'id_estacionamento': idEstacionamento.toString()},
    );

    final response = await http.get(
      uri,
      headers: await ApiService.authHeaders(),
    );
    final decoded = _decodeResponse(response.body);

    if (response.statusCode == 200 && decoded['sucesso'] == true) {
      final List dados = decoded['dados'] ?? [];
      return dados
          .map((item) => FuncionarioEstacionamentoModel.fromJson(item))
          .toList();
    }

    final erros = decoded['erros'];

    if (response.statusCode == 200 &&
        erros is List &&
        erros.any((erro) => erro is Map && erro['codigo'] == 404)) {
      return [];
    }

    throw Exception(_mensagemErro(decoded, 'Erro ao listar funcionários'));
  }

  Future<void> vincularPorEmail({
    required int idEstacionamento,
    required String email,
  }) async {
    final funcionario = await _buscarFuncionarioPorEmail(email);

    final response = await http.post(
      Uri.parse('$baseUrl/FuncionarioEstacionamento/inserir'),
      headers: await ApiService.authHeaders(contentType: true),
      body: jsonEncode({
        'id_funcionario': funcionario['id_funcionario'],
        'id_estacionamento': idEstacionamento,
      }),
    );

    final decoded = _decodeResponse(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        decoded['sucesso'] == true) {
      return;
    }

    throw Exception(_mensagemErro(decoded, 'Erro ao cadastrar funcionário'));
  }

  Future<void> remover(int idVinculo) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/FuncionarioEstacionamento/deletar/$idVinculo'),
      headers: await ApiService.authHeaders(),
    );

    final decoded = _decodeResponse(response.body);

    if ((response.statusCode == 200 || response.statusCode == 204) &&
        decoded['sucesso'] == true) {
      return;
    }

    throw Exception(_mensagemErro(decoded, 'Erro ao remover funcionário'));
  }

  Future<Map<String, dynamic>> _buscarFuncionarioPorEmail(String email) async {
    final uri = Uri.parse('$baseUrl/usuarios/listar').replace(
      queryParameters: {
        'email': email,
        'tipo': 'FUNCIONARIO',
        'status': 'ATIVO',
      },
    );

    final response = await http.get(
      uri,
      headers: await ApiService.authHeaders(),
    );
    final decoded = _decodeResponse(response.body);

    if (response.statusCode == 200 && decoded['sucesso'] == true) {
      final List dados = decoded['dados'] ?? [];

      if (dados.isNotEmpty) {
        return Map<String, dynamic>.from(dados.first);
      }
    }

    throw Exception('Funcionário ativo não encontrado para este e-mail');
  }

  Map<String, dynamic> _decodeResponse(String body) {
    if (body.trim().isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (e) {
      return {};
    }

    return {};
  }

  String _mensagemErro(Map<String, dynamic> data, String fallback) {
    final erros = data['erros'];

    if (erros is List && erros.isNotEmpty) {
      return erros
          .map((erro) {
            if (erro is Map && erro['msg'] != null) {
              return erro['msg'].toString();
            }

            return erro.toString();
          })
          .join('\n');
    }

    if (data['msg'] != null) {
      return data['msg'].toString();
    }

    return fallback;
  }
}
