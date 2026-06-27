# Jellyfin + TV Cast + Modo Mineração

> Projeto: jidoujisho · Data: 2026-06-19 · Branch base: `main`

## Visão geral

Permite assistir vídeos do Jellyfin na TV (Chromecast) enquanto o celular exibe as mesmas legendas de forma interativa. O usuário toca em palavras para ver definições e cria flashcards com um toque longo.

```
┌──────────────────────┐    ┌──────────────────────────┐
│  TV (Chromecast)     │    │  Celular (Mining Mode)   │
│                      │    │                          │
│  🎬 Vídeo + Legendas │    │  Tela preta              │
│  ❌ Não interativo   │    │  Legenda gigante         │
│                      │    │  👆 Tap → Dicionário     │
│                      │    │  📋 Long press → Card    │
└──────────────────────┘    └──────────────────────────┘
         ▲                            │
         │      Jellyfin API          │
         └────────────────────────────┘
```

## Arquivos criados/modificados

### Novos (9 arquivos)

```
chisa/lib/jellyfin/
├── jellyfin_client.dart             # Cliente REST da API Jellyfin
├── jellyfin_models.dart             # Modelos: Item, Device, Session, etc.
├── cast_session_manager.dart        # Polling de posição + controle remoto
└── device_picker_dialog.dart        # Diálogo de seleção de TV/Chromecast

chisa/lib/pages/mining/
├── mining_mode_page.dart            # Tela principal do modo mineração
├── mining_subtitle_display.dart     # Legenda interativa (tap words)
└── mining_controls.dart             # Controles + calibração de sync

chisa/lib/media/media_sources/
└── player_jellyfin_source.dart      # MediaSource Jellyfin integrada
```

### Modificados (2 arquivos)

- `chisa/lib/models/app_model.dart` — +2 linhas (import + registro)
- `yuuna/lib/i18n/strings_pt-BR.i18n.json` — 397 strings traduzidas
- `yuuna/lib/i18n/strings.g.dart` — regenerado (2 locales, 794 strings)
- `yuuna/lib/src/utils/jidoujisho_localisations.dart` — +1 locale pt-BR
- `yuuna/android/gradle/wrapper/gradle-wrapper.properties` — Gradle 7.2 → 8.4
- `yuuna/android/build.gradle` — AGP 7.1.2 → 8.1.4, Kotlin 1.8.22 → 1.9.22
- `yuuna/android/app/build.gradle` — +namespace

## Fluxo de uso

1. Long press em item Jellyfin → **[CAST + MINE]**
2. Escolhe a TV no DevicePickerDialog
3. Jellyfin inicia stream na TV
4. Celular abre MiningModePage (tela preta + legenda)
5. **Tap na palavra** → popup do dicionário
6. **Long press** → menu: Copy / Search All
7. **+100ms/-100ms** → calibra sincronia
8. Loop Mode → repete legenda atual (shadowing)

## API Jellyfin — Endpoints usados

| Método | Endpoint |
|--------|----------|
| POST | `/Users/Authenticate` |
| GET | `/Users/{id}/Views` |
| GET | `/Users/{id}/Items` |
| GET | `/Users/{id}/Items/{itemId}` |
| GET | `/Videos/{id}/stream` |
| GET | `/Videos/{id}/{source}/Subtitles/{index}/Stream` |
| POST | `/Sessions/Playing` |
| GET | `/Sessions` |
| POST | `/Sessions/{id}/Playing/{command}` |
| GET | `/Devices` |

## Dependências

Nenhuma nova — o projeto já tinha `http`, `shared_preferences`, `provider`, `subtitle`.

## Tradução pt-BR

Adicionado suporte a português brasileiro via slang:
- `yuuna/lib/i18n/strings_pt-BR.i18n.json` — 397 strings
- Gerar: `cd yuuna && flutter pub run slang`

## Build APK

```bash
export PATH="$HOME/flutter/bin:$HOME/flutter/bin/cache/dart-sdk/bin:$PATH"
export ANDROID_HOME="$HOME/AppData/Local/Android/Sdk"
cd ~/Documents/Projetos/jidoujisho/yuuna
flutter build apk --debug
# Saída: build/app/outputs/flutter-apk/app-debug.apk
```

### Pré-requisitos build
- Windows Developer Mode ativado
- Java 17+ (Temurin)
- Android SDK + Android Studio

## Próximos passos

- [ ] Testar com servidor Jellyfin real
- [ ] Testar com Chromecast/TV real
- [ ] Ajustar polling interval conforme latência
- [ ] Enviar tradução pt-BR pro Crowdin do projeto oficial

---

**Licença**: GPL-3.0 (mesma do projeto jidoujisho)
