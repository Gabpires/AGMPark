import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pagamento_model.dart';
import 'auth_service.dart';

class PagamentoService {
  static String get baseUrl => ApiService.baseUrl;

  Future<List<PagamentoModel>> listarPagamentos(int idEstacionamento) async {
    final uri = Uri.parse('$baseUrl/pagamentos/listar').replace(
      queryParameters: {'id_estacionamento': idEstacionamento.toString()},
    );

    final response = await http.get(
      uri,
      headers: await ApiService.authHeaders(),
    );

    final decoded = _decodeResponse(response.body);

    if (response.statusCode == 200) {
      final dados = _listaDados(decoded);
      final pagamentos = dados.map(PagamentoModel.fromJson).toList();

      return pagamentos.where((pagamento) {
        return pagamento.idEstacionamento == null ||
            pagamento.idEstacionamento == idEstacionamento;
      }).toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Sessao expirada. Faca login novamente.');
    }

    throw Exception(_mensagemErro(decoded, 'Erro ao listar pagamentos'));
  }

  dynamic _decodeResponse(String body) {
    if (body.trim().isEmpty) {
      return {};
    }

    try {
      return jsonDecode(body);
    } catch (e) {
      return {};
    }
  }

  List<Map<String, dynamic>> _listaDados(dynamic decoded) {
    final dynamic dados;

    if (decoded is List) {
      dados = decoded;
    } else if (decoded is Map) {
      dados = decoded['dados'] ?? [];
    } else {
      dados = [];
    }

    if (dados is! List) {
      return [];
    }

    return dados
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  String _mensagemErro(dynamic decoded, String fallback) {
    if (decoded is Map) {
      final erros = decoded['erros'];

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

      if (decoded['msg'] != null) {
        return decoded['msg'].toString();
      }

      if (decoded['message'] != null) {
        return decoded['message'].toString();
      }
    }

    return fallback;
  }
}
