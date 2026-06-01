# agmpark

A new Flutter project.

## Rodar no Flutter web local

A API publica ainda nao responde ao preflight CORS usado pelo navegador. Para
testar login e demais chamadas no Flutter web local, rode o proxy de
desenvolvimento em um terminal:

```bash
dart run tool/dev_api_proxy.dart
```

Em outro terminal, rode o app web:

```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 53123
```

No Android/iOS o app continua usando a API direta. Em uma hospedagem web real,
o ideal e habilitar CORS no backend ou publicar o app no mesmo dominio da API.
