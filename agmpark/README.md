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

Para testar no emulador Android usando o mesmo proxy local, use o endereco
especial `10.0.2.2`, que aponta para o computador host:

```bash
flutter run -d emulator-5554 --dart-define=AGMPARK_API_BASE_URL=http://10.0.2.2:53124/AGMPark/TG_AGM-Park/public
```

No Android/iOS o app continua usando a API direta. Em uma hospedagem web real,
o ideal e habilitar CORS no backend ou publicar o app no mesmo dominio da API.

## Build web de producao

Para publicar uma versao mais leve, gere o build em modo release:

```bash
flutter build web --release --pwa-strategy=none
```

Depois envie todo o conteudo de `build/web` para a hospedagem, incluindo os
arquivos `main.dart.js_*.part.js`, que sao carregados sob demanda. Se a
hospedagem permitir, habilite gzip ou brotli para arquivos `.js`, `.wasm`,
`.json` e `.otf`.

No Flutter 3.41 essa opcao de PWA ainda funciona, mas mostra aviso de
depreciacao. Se ela for removida na sua versao, use `flutter build web
--release` e controle cache/preload na propria hospedagem.
