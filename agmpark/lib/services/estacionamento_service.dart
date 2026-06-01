import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/estacionamento_model.dart';
import 'auth_service.dart';

class EstacionamentoService {
  static String get baseUrl => ApiService.baseUrl;

  Future<List<EstacionamentoModel>> listar() async {
    final tipoUsuario = await ApiService.tipoUsuario();

    if (tipoUsuario == 'FUNCIONARIO') {
      return _listarVinculadosAoFuncionario();
    }

    return _listarAtivos();
  }

  Future<List<EstacionamentoModel>> _listarAtivos() async {
    final uri = Uri.parse(
      '$baseUrl/estacionamentos/listar',
    ).replace(queryParameters: {'status': 'ATIVO'});

    final response = await http.get(
      uri,
      headers: await ApiService.authHeaders(),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final List dados = decoded['dados'] ?? [];
      return dados
          .map((e) => EstacionamentoModel.fromJson(e))
          .where((estacionamento) => estacionamento.ativo)
          .toList();
    }

    throw Exception('Erro ao listar estacionamentos');
  }

  Future<List<EstacionamentoModel>> _listarVinculadosAoFuncionario() async {
    final payload = await ApiService.payloadToken();
    final idFuncionario = payload?['id']?.toString();

    if (idFuncionario == null || idFuncionario.isEmpty) {
      return [];
    }

    final uri = Uri.parse('$baseUrl/FuncionarioEstacionamento/listar').replace(
      queryParameters: {
        'id_funcionario': idFuncionario,
        'status_estacionamento': 'ATIVO',
      },
    );

    final response = await http.get(
      uri,
      headers: await ApiService.authHeaders(),
    );
    final decoded = _decodeResponse(response.body);

    if (response.statusCode == 200 && decoded['sucesso'] == true) {
      final dados = decoded['dados'];

      if (dados is! List) {
        return [];
      }

      final estacionamentos = dados
          .map(
            (e) => EstacionamentoModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .where((estacionamento) => estacionamento.ativo)
          .toList();

      final idsAdicionados = <int>{};

      return estacionamentos.where((estacionamento) {
        final id = estacionamento.id;

        if (id == null) {
          return true;
        }

        return idsAdicionados.add(id);
      }).toList();
    }

    final erros = decoded['erros'];

    if (response.statusCode == 200 &&
        erros is List &&
        erros.any((erro) => erro is Map && erro['codigo'] == 404)) {
      return [];
    }

    throw Exception(_mensagemErro(decoded, 'Erro ao listar estacionamentos'));
  }

  Future<Map<String, dynamic>> cadastrar(
    EstacionamentoModel estacionamento,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/estacionamentos/inserir'),
      headers: await ApiService.authHeaders(contentType: true),
      body: jsonEncode(estacionamento.toJson()),
    );

    final decoded = _decodeResponse(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        decoded['sucesso'] == true) {
      return decoded;
    }

    throw Exception(_mensagemErro(decoded, 'Erro ao cadastrar estacionamento'));
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
            if (erro is Map) {
              final campo = erro['campo']?.toString();
              final msg = erro['msg']?.toString();

              if (campo != null && msg != null) {
                return '$campo: $msg';
              }

              if (msg != null) {
                return msg;
              }
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
