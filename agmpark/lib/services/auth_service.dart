import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _apiBaseUrl =
      'https://163-176-245-26.sslip.io';
  static const String _localWebProxyBaseUrl =
      'https://163-176-245-26.sslip.io';
  static const String _baseUrlOverride = String.fromEnvironment(
    'AGMPARK_API_BASE_URL',
  );
  static const Duration _requestTimeout = Duration(seconds: 20);

  static String get baseUrl {
    if (_baseUrlOverride.isNotEmpty) {
      return _baseUrlOverride;
    }

    if (kIsWeb && _hostLocal(Uri.base.host)) {
      return _localWebProxyBaseUrl;
    }

    return _apiBaseUrl;
  }

  static const String _tokenKey = 'agmpark_jwt_token';

  static Future<Map<String, dynamic>> login({
    required String email,
    required String senha,
  }) async {
    final response = await _post(
      Uri.parse('$baseUrl/auth/login'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    final data = _decodeResponse(response.body);

    if (_isSuccess(response.statusCode, data) && data['token'] != null) {
      await salvarToken(data['token'].toString());
      return data;
    }

    throw Exception(_mensagemErro(data, 'Erro ao fazer login'));
  }

  static Future<Map<String, dynamic>> cadastrar({
    required String nome,
    required String cpfCnpj,
    required String email,
    required String dataNasc,
    required String telefone,
    required String senha,
    required String tipo,
  }) async {
    final response = await _post(
      Uri.parse('$baseUrl/usuarios/inserir'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nome': nome,
        'cpfCnpj': cpfCnpj,
        'email': email,
        'dataNasc': dataNasc,
        'telefone': telefone,
        'senha': senha,
        'tipo': tipo,
      }),
    );

    final data = _decodeResponse(response.body);

    if (_isSuccess(response.statusCode, data)) {
      return data;
    }

    throw Exception(_mensagemErro(data, 'Erro ao cadastrar usuário'));
  }

  static Future<Map<String, dynamic>> usuarioLogado() async {
    final response = await _get(
      Uri.parse('$baseUrl/usuarios/me'),
      headers: await authHeaders(),
    );

    final data = _decodeResponse(response.body);

    if (_isSuccess(response.statusCode, data) && data['dados'] is Map) {
      return Map<String, dynamic>.from(data['dados']);
    }

    if (response.statusCode == 401) {
      await logout();
    }

    throw Exception(_mensagemErro(data, 'Erro ao carregar dados do usuário'));
  }

  static Future<Map<String, dynamic>> atualizarMeusDados({
    required String nome,
    required String email,
    required String telefone,
  }) async {
    final response = await _put(
      Uri.parse('$baseUrl/usuarios/me'),
      headers: await authHeaders(contentType: true),
      body: jsonEncode({'nome': nome, 'email': email, 'telefone': telefone}),
    );

    final data = _decodeResponse(response.body);

    if (_isSuccess(response.statusCode, data) && data['dados'] is Map) {
      return Map<String, dynamic>.from(data['dados']);
    }

    if (response.statusCode == 401) {
      await logout();
    }

    throw Exception(_mensagemErro(data, 'Erro ao atualizar dados'));
  }

  static Future<Map<String, dynamic>?> payloadToken() async {
    final token = await getToken();

    if (token == null || token.isEmpty || _tokenExpirado(token)) {
      return null;
    }

    return _decodeTokenPayload(token);
  }

  static Future<Map<String, String>> authHeaders({
    bool contentType = false,
  }) async {
    final token = await getToken();
    final headers = <String, String>{'Accept': 'application/json'};

    if (contentType) {
      headers['Content-Type'] = 'application/json';
    }

    if (token != null && token.isNotEmpty && !_tokenExpirado(token)) {
      headers['Authorization'] = 'Bearer $token';
    } else if (token != null && token.isNotEmpty) {
      await logout();
    }

    return headers;
  }

  static Future<void> salvarToken(String token) async {
    final prefs = SharedPreferencesAsync();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = SharedPreferencesAsync();
    return prefs.getString(_tokenKey);
  }

  static Future<void> logout() async {
    final prefs = SharedPreferencesAsync();
    await prefs.remove(_tokenKey);
  }

  static Future<bool> possuiTokenValido() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return false;
    }

    if (_tokenExpirado(token)) {
      await logout();
      return false;
    }

    return true;
  }

  static Future<bool> checkAuth() async {
    if (!await possuiTokenValido()) {
      return false;
    }

    try {
      final response = await _get(
        Uri.parse('$baseUrl/auth/checkauth'),
        headers: await authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = _decodeResponse(response.body);
        return data['sucesso'] == true;
      }

      if (response.statusCode == 401) {
        await logout();
      }
    } catch (e) {
      return false;
    }

    return false;
  }

  static Future<String?> tipoUsuario() async {
    final payload = await payloadToken();
    final tipoPayload = _normalizarTipoUsuario(
      payload?['tipo_usuario'] ?? payload?['tipo'] ?? payload?['role'],
    );

    if (tipoPayload != null) {
      return tipoPayload;
    }

    try {
      final usuario = await usuarioLogado();
      return _normalizarTipoUsuario(
        usuario['tipo_usuario'] ?? usuario['tipo'] ?? usuario['role'],
      );
    } catch (e) {
      return null;
    }
  }

  static Future<bool> possuiAcessoProprietario() async {
    final tipo = await tipoUsuario();
    return tipo == 'PROPRIETARIO' || tipo == 'ADMINISTRADOR';
  }

  static Future<http.Response> _get(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    try {
      return await http.get(uri, headers: headers).timeout(_requestTimeout);
    } on TimeoutException catch (_) {
      throw Exception(_mensagemErroConexao());
    } on http.ClientException catch (e) {
      throw Exception(_mensagemErroConexao(e));
    }
  }

  static Future<http.Response> _post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      return await http
          .post(uri, headers: headers, body: body)
          .timeout(_requestTimeout);
    } on TimeoutException catch (_) {
      throw Exception(_mensagemErroConexao());
    } on http.ClientException catch (e) {
      throw Exception(_mensagemErroConexao(e));
    }
  }

  static Future<http.Response> _put(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      return await http
          .put(uri, headers: headers, body: body)
          .timeout(_requestTimeout);
    } on TimeoutException catch (_) {
      throw Exception(_mensagemErroConexao());
    } on http.ClientException catch (e) {
      throw Exception(_mensagemErroConexao(e));
    }
  }

  static String _mensagemErroConexao([Object? error]) {
    final detalhe = error?.toString() ?? '';

    if (error != null ||
        detalhe.contains('Failed host lookup') ||
        detalhe.contains('SocketException') ||
        detalhe.contains('SocketFailed') ||
        detalhe.contains('Connection refused') ||
        detalhe.contains('XMLHttpRequest error') ||
        detalhe.contains('Failed to fetch')) {
      return 'NÃ£o foi possÃ­vel conectar Ã API. Verifique sua conexÃ£o com a internet e tente novamente.';
    }

    return 'A API demorou para responder. Tente novamente em instantes.';
  }

  static Map<String, dynamic> _decodeResponse(String body) {
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

  static bool _isSuccess(int statusCode, Map<String, dynamic> data) {
    return (statusCode == 200 || statusCode == 201) && data['sucesso'] != false;
  }

  static String _mensagemErro(Map<String, dynamic> data, String fallback) {
    final erros = data['erros'];

    if (erros is List && erros.isNotEmpty) {
      final primeiroErro = erros.first;

      if (primeiroErro is Map && primeiroErro['msg'] != null) {
        return primeiroErro['msg'].toString();
      }
    }

    if (data['msg'] != null) {
      return data['msg'].toString();
    }

    if (data['message'] != null) {
      return data['message'].toString();
    }

    return fallback;
  }

  static bool _tokenExpirado(String token) {
    try {
      final payload = _decodeTokenPayload(token);

      if (payload == null || payload['exp'] == null) {
        return true;
      }

      final exp = int.tryParse(payload['exp'].toString());

      if (exp == null) {
        return true;
      }

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return now >= exp;
    } catch (e) {
      return true;
    }
  }

  static Map<String, dynamic>? _decodeTokenPayload(String token) {
    try {
      final parts = token.split('.');

      if (parts.length != 3) {
        return null;
      }

      final normalized = base64Url.normalize(parts[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));

      if (payload is Map<String, dynamic>) {
        return payload;
      }

      if (payload is Map) {
        return Map<String, dynamic>.from(payload);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static String? _normalizarTipoUsuario(dynamic tipo) {
    final normalizado = tipo?.toString().trim().toUpperCase();

    if (normalizado == null || normalizado.isEmpty) {
      return null;
    }

    return normalizado;
  }

  static bool _hostLocal(String host) {
    return host == 'localhost' || host == '127.0.0.1' || host == '::1';
  }
}
