import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/carro_estacionado_model.dart';
import 'auth_service.dart';

class CarroEstacionadoService {
  static String get baseUrl => ApiService.baseUrl;

  Future<List<CarroEstacionadoModel>> listarCarrosEstacionados(
    int idEstacionamento,
  ) async {
    final uri = Uri.parse('$baseUrl/estadias/listar').replace(
      queryParameters: {'id_estacionamento': idEstacionamento.toString()},
    );

    final response = await http.get(
      uri,
      headers: await ApiService.authHeaders(),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List dados = decoded is List ? decoded : decoded['dados'] ?? [];

      final carros = dados
          .map((e) => CarroEstacionadoModel.fromJson(e))
          .toList();

      return carros.where((carro) {
        return carro.idEstacionamento == null ||
            carro.idEstacionamento == idEstacionamento;
      }).toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Não autorizado ao listar carros estacionados');
    }

    throw Exception('Erro ao listar carros estacionados');
  }

  Future<void> finalizarEstadia({
    required CarroEstacionadoModel carro,
    required int idVaga,
    required String dataSaida,
  }) async {
    if (carro.idVeiculo == null || carro.idVeiculo == 0) {
      throw Exception('Não foi possível identificar o veículo da estadia.');
    }

    if (idVaga == 0) {
      throw Exception('Não foi possível identificar a vaga da estadia.');
    }

    if (carro.dataHoraEstadia.trim().isEmpty) {
      throw Exception('Não foi possível identificar a entrada da estadia.');
    }

    final body = <String, dynamic>{
      'id_veiculo': carro.idVeiculo,
      'id_vaga': idVaga,
      'data_entrada': carro.dataHoraEstadia,
      'data_saida': dataSaida,
      'valor_total': carro.valorTotal.trim().isEmpty
          ? '0.00'
          : carro.valorTotal,
      'status': 'FINALIZADA',
    };

    if (carro.idReserva != null && carro.idReserva != 0) {
      body['id_reserva'] = carro.idReserva;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/estadias/atualizar/${carro.idEstadia}'),
      headers: await ApiService.authHeaders(contentType: true),
      body: jsonEncode(body),
    );

    final decoded = _decodeResponse(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        decoded['sucesso'] != false) {
      return;
    }

    throw Exception(_mensagemErro(decoded, 'Erro ao atualizar estadia'));
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

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
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

    if (data['message'] != null) {
      return data['message'].toString();
    }

    return fallback;
  }
}
