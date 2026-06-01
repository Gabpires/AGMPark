import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/vaga_model.dart';
import 'auth_service.dart';

class VagaService {
  static String get baseUrl => ApiService.baseUrl;

  Future<List<VagaModel>> listar(int idEstacionamento) async {
    final uri = Uri.parse('$baseUrl/vagas/listar').replace(
      queryParameters: {'id_estacionamento': idEstacionamento.toString()},
    );

    final response = await http.get(
      uri,
      headers: await ApiService.authHeaders(),
    );
    final decoded = _decodeResponse(response.body);

    if (response.statusCode == 200 && decoded['sucesso'] == true) {
      final dados = decoded['dados'];

      if (dados is List) {
        return dados
            .map((item) => VagaModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }

      return [];
    }

    throw Exception(_mensagemErro(decoded, 'Erro ao listar vagas'));
  }

  Future<List<VagaModel>> alterarDisponibilidade({
    required int idEstacionamento,
    required bool disponivel,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/vagas/disponibilidade/$idEstacionamento'),
      headers: await ApiService.authHeaders(contentType: true),
      body: jsonEncode({'disponivel': disponivel}),
    );

    final decoded = _decodeResponse(response.body);

    if (response.statusCode == 200 && decoded['sucesso'] == true) {
      final dados = decoded['dados'];

      if (dados is List) {
        return dados
            .map((item) => VagaModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }

      return listar(idEstacionamento);
    }

    throw Exception(_mensagemErro(decoded, 'Erro ao alterar disponibilidade'));
  }

  Future<void> atualizarStatus(VagaModel vaga, String status) async {
    if (status == 'RESERVADA') {
      throw Exception(
        'Para reservar uma vaga, crie uma reserva. A API não aceita reserva manual nesse endpoint.',
      );
    }

    final response = await http.put(
      Uri.parse('$baseUrl/vagas/atualizar/${vaga.id}'),
      headers: await ApiService.authHeaders(contentType: true),
      body: jsonEncode(vaga.toUpdateJson(status)),
    );

    final decoded = _decodeResponse(response.body);

    if (response.statusCode == 200 && decoded['sucesso'] == true) {
      return;
    }

    throw Exception(_mensagemErro(decoded, 'Erro ao atualizar vaga'));
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
