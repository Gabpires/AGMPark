import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reserva_model.dart';
import 'auth_service.dart';

class ReservaService {
  static String get baseUrl => ApiService.baseUrl;

  Future<List<ReservaModel>> listarReservas(int idEstacionamento) async {
    final uri = Uri.parse('$baseUrl/reservas/listar').replace(
      queryParameters: {'id_estacionamento': idEstacionamento.toString()},
    );

    final response = await http.get(
      uri,
      headers: await ApiService.authHeaders(),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final List dados = decoded['dados'] ?? [];

      return dados.map((e) => ReservaModel.fromJson(e)).toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }

    throw Exception('Erro ao listar reservas');
  }
}
