import 'dart:io';

const _targetOrigin = 'https://agm.ruzieljr.com.br';
const _defaultPort = 53124;

Future<void> main() async {
  final port =
      int.tryParse(Platform.environment['AGMPARK_PROXY_PORT'] ?? '') ??
      _defaultPort;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);

  stdout.writeln(
    'AGM Park API proxy: http://127.0.0.1:$port -> $_targetOrigin',
  );

  await for (final request in server) {
    _handleRequest(request);
  }
}

Future<void> _handleRequest(HttpRequest request) async {
  final response = request.response;
  final origin = request.headers.value('origin');

  _addCorsHeaders(response, origin);

  if (request.method == 'OPTIONS') {
    response.statusCode = HttpStatus.noContent;
    await response.close();
    return;
  }

  final client = HttpClient();

  try {
    final targetUri = Uri.parse('$_targetOrigin${request.uri}');
    final upstreamRequest = await client.openUrl(request.method, targetUri);

    request.headers.forEach((name, values) {
      if (_hopByHopHeaders.contains(name.toLowerCase())) {
        return;
      }

      upstreamRequest.headers.set(name, values);
    });

    await upstreamRequest.addStream(request);

    final upstreamResponse = await upstreamRequest.close();
    response.statusCode = upstreamResponse.statusCode;

    upstreamResponse.headers.forEach((name, values) {
      final normalized = name.toLowerCase();

      if (_hopByHopHeaders.contains(normalized) ||
          normalized.startsWith('access-control-')) {
        return;
      }

      response.headers.set(name, values);
    });

    _addCorsHeaders(response, origin);
    await response.addStream(upstreamResponse);
  } catch (e) {
    response.statusCode = HttpStatus.badGateway;
    response.headers.contentType = ContentType.json;
    response.write('{"sucesso":false,"msg":"Erro no proxy local da API"}');
  } finally {
    client.close(force: true);
    await response.close();
  }
}

void _addCorsHeaders(HttpResponse response, String? origin) {
  response.headers.set(
    HttpHeaders.accessControlAllowOriginHeader,
    origin == null || origin.isEmpty ? '*' : origin,
  );
  response.headers.set(
    HttpHeaders.accessControlAllowMethodsHeader,
    'GET, POST, PUT, PATCH, DELETE, OPTIONS',
  );
  response.headers.set(
    HttpHeaders.accessControlAllowHeadersHeader,
    'Authorization, Content-Type, Accept',
  );
  response.headers.set(
    HttpHeaders.accessControlExposeHeadersHeader,
    'Content-Type, Content-Length',
  );
  response.headers.set(HttpHeaders.varyHeader, 'Origin');
  response.headers.set(HttpHeaders.accessControlMaxAgeHeader, '86400');
}

const _hopByHopHeaders = {
  'connection',
  'keep-alive',
  'proxy-authenticate',
  'proxy-authorization',
  'te',
  'trailer',
  'transfer-encoding',
  'upgrade',
  'host',
  'content-length',
};
