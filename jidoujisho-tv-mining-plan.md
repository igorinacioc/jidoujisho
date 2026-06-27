# Plano de Implementação: Jellyfin + TV Cast + Modo Mineração

## Visão Geral

**Objetivo**: Assistir vídeos do Jellyfin na TV (Chromecast) com legendas normais, enquanto o celular exibe as mesmas legendas de forma interativa para mineração (tap → dicionário → flashcards).

**Arquitetura**: O celular atua como "controle remoto inteligente" — o Jellyfin faz o streaming para a TV, e o app sincroniza as legendas localmente consultando a API de sessão do Jellyfin.

```
┌──────────────────────────────────────────┐
│  Servidor Jellyfin (PC/NAS)              │
│  - Biblioteca de mídia                   │
│  - Legendas indexadas                    │
│  - API REST completa                     │
│  - Suporte nativo a Chromecast           │
└──────────┬──────────┬───────────────────┘
           │ Stream   │ API REST
           ▼          ▼
┌──────────────┐  ┌─────────────────────────┐
│  TV          │  │  Celular (jidoujisho)   │
│  Chromecast  │  │                         │
│  - Vídeo     │  │  🔴 Modo Mineração      │
│  - Legendas  │  │  - Legenda atual grande │
│  - Áudio     │  │  - Tap → Dicionário     │
│              │  │  - Botão → Flashcard    │
│              │  │  - Timeline legendas    │
│              │  │  - Controles remotos    │
└──────────────┘  └─────────────────────────┘
```

---

## Estado Atual do Código

### ✅ O que já existe (reaproveitável)

| Funcionalidade | Arquivo | Estado |
|----------------|---------|--------|
| Parser SRT/ASS | `chisa/lib/util/subtitle_utils.dart` | ✅ Completo |
| SubtitleController | `chisa/lib/util/subtitle_utils.dart` | ✅ Completo |
| Transcript panel (diálogo) | `chisa/lib/util/transcript_dialog.dart` | ✅ Completo |
| Tap-to-lookup (dicionário) | `chisa/lib/pages/player_page.dart` (drag-select) | ✅ Completo |
| Criação de flashcards | `chisa/lib/util/anki_creator.dart` | ✅ Completo |
| Export para Anki (áudio+imagem) | `chisa/lib/pages/player_page.dart` (exportMultipleSubtitles) | ✅ Completo |
| Player VLC | `flutter_vlc_player` 6.0.5 | ✅ Completo |
| HTTP client | `http` package já importado | ✅ Disponível |
| Arquitetura MediaSource | `chisa/lib/media/media_source.dart` | ✅ Extensível |
| PlayerMediaSource abstrato | `chisa/lib/media/media_sources/player_media_source.dart` | ✅ Extensível |
| Gerenciamento de sources | `chisa/lib/models/app_model.dart` | ✅ Registro simples |

### ❌ O que NÃO existe (precisa ser criado)

| Funcionalidade | Complexidade |
|----------------|--------------|
| Integração com Jellyfin (API client) | 🔴 Alta |
| PlayerJellyfinSource | 🔴 Alta |
| Gestão de sessão Jellyfin (cast/playback) | 🟡 Média |
| Descoberta de dispositivos Chromecast (via Jellyfin) | 🟢 Baixa |
| Modo Mineração UI (tela dedicada) | 🟡 Média |
| Sincronização posição TV ↔ legendas | 🟡 Média |
| Controles remotos (play/pause/seek) | 🟢 Baixa |

---

## Fase 1: Cliente da API do Jellyfin

**Novo arquivo**: `chisa/lib/jellyfin/jellyfin_client.dart`

### Endpoints necessários

```
Autenticação:
  POST /Users/Authenticate
    Body: { "Username": "...", "Pw": "..." }
    Response: { "AccessToken": "...", "User": { "Id": "..." } }

Biblioteca:
  GET /Users/{userId}/Views
  GET /Users/{userId}/Items?ParentId={id}&SortBy=SortName&Recursive=true
    &IncludeItemTypes=Movie,Episode&Fields=MediaSources,MediaStreams
  GET /Users/{userId}/Items/{itemId}
    Response inclui: MediaSources, MediaStreams (legendas)

Stream URL:
  GET /Videos/{itemId}/stream?Static=true&MediaSourceId={sourceId}
    &DeviceId={deviceId}&ApiKey={token}
  → URL direta do arquivo de vídeo

Legendas:
  GET /Videos/{itemId}/{mediaSourceId}/Subtitles/{index}/Stream
  → Retorna o arquivo .srt/.ass

Sessão / Playback:
  POST /Sessions/Playing
    Body: {
      "ItemId": "...",
      "PlayMethod": "Transcode",
      "CanSeek": true,
      "MediaSourceId": "..."
    }
    Headers: X-Emby-Authorization com DeviceId do Chromecast

  GET /Sessions?DeviceId={chromecastDeviceId}
    Response: posição atual (PositionTicks), estado (IsPaused)

  POST /Sessions/{sessionId}/Playing/{command}
    Commands: PlayPause, Stop, Seek (com SeekPositionTicks)

Dispositivos:
  GET /Devices
    Response: lista de dispositivos (inclui Chromecasts)
```

### Estrutura da classe

```dart
class JellyfinClient {
  final String serverUrl;
  String? _accessToken;
  String? _userId;

  // Auth
  Future<bool> authenticate(String username, String password);
  
  // Biblioteca
  Future<List<JellyfinItem>> getViews();
  Future<List<JellyfinItem>> getItems(String parentId);
  Future<JellyfinItem> getItem(String itemId);
  
  // Stream
  String getStreamUrl(String itemId, String mediaSourceId, String deviceId);
  
  // Legendas
  Future<String> getSubtitleContent(String itemId, String mediaSourceId, int index);
  
  // Sessão / Playback
  Future<String> startPlayback(String itemId, String mediaSourceId, String deviceId);
  Future<JellyfinSession?> getSession(String deviceId);
  Future<void> sendCommand(String sessionId, String command, {int? seekTicks});
  
  // Dispositivos
  Future<List<JellyfinDevice>> getDevices();
}
```

### Dependências novas
- Nenhuma — `http` package já existe no `pubspec.yaml`

---

## Fase 2: PlayerJellyfinSource

**Novo arquivo**: `chisa/lib/media/media_sources/player_jellyfin_source.dart`

### O que estende
- `PlayerMediaSource` (abstrata, mesmo padrão de YouTube e Local)

### Métodos a implementar

```dart
class PlayerJellyfinSource extends PlayerMediaSource {
  JellyfinClient? _client;
  
  // Conexão com servidor (UI de login)
  Future<void> connectToServer(String url, String username, String password);
  
  // Browse da biblioteca (UI de navegação)
  Future<List<JellyfinItem>> browseLibrary(String parentId);
  
  // Implementações obrigatórias de PlayerMediaSource:
  
  @override
  PlayerLaunchParams getLaunchParams(AppModel appModel, MediaHistoryItem item) {
    // item.key = itemId do Jellyfin
    // item.extra["mediaSourceId"] = mediaSourceId
    // item.extra["serverUrl"] = serverUrl
    return PlayerLaunchParams.network(
      networkPath: item.key,
      mediaSource: this,
      mediaHistoryItem: item,
      saveHistoryItem: true,
      appModel: appModel,
    );
  }
  
  @override
  Future<String> getNetworkStreamUrl(PlayerLaunchParams params) async {
    // Constrói a URL de stream do Jellyfin
    final itemId = params.mediaHistoryItem.key;
    final sourceId = params.mediaHistoryItem.extra["mediaSourceId"];
    return _client!.getStreamUrl(itemId, sourceId, "phone-device-id");
  }
  
  @override
  Future<List<SubtitleItem>> provideSubtitles(PlayerLaunchParams params) async {
    // Busca legendas do Jellyfin (pode ter várias faixas)
    // Retorna lista de SubtitleItem com SubtitleController
  }
  
  @override
  Widget? buildSourceButton(BuildContext context, PlayerPageState page) {
    // Botão "Cast para TV" (só aparece quando logado no Jellyfin)
  }
  
  // NOVO: Métodos específicos para Cast/Mining
  
  /// Lista dispositivos Chromecast disponíveis na rede
  Future<List<JellyfinDevice>> discoverCastDevices();
  
  /// Inicia playback na TV via Jellyfin
  /// Retorna o sessionId
  Future<String> castToDevice(JellyfinDevice device, JellyfinItem item);
  
  /// Obtém a posição atual da sessão na TV
  Future<Duration?> getRemotePosition(String sessionId);
  
  /// Envia comando de controle para a TV
  Future<void> sendRemoteCommand(String sessionId, String command, {Duration? seekTo});
}
```

### Registro no AppModel

```dart
// Em chisa/lib/models/app_model.dart
// Adicionar na lista de playerSources:
PlayerJellyfinSource(),
```

---

## Fase 3: Gerenciador de Sessão Cast/Mining

**Novo arquivo**: `chisa/lib/jellyfin/cast_session_manager.dart`

### Responsabilidades
- Manter estado da sessão de cast ativa
- Polling de posição (a cada ~500ms)
- Sincronização com offset ajustável
- Reconexão em caso de queda

```dart
class CastSessionManager extends ChangeNotifier {
  JellyfinClient? client;
  String? sessionId;
  String? deviceId;
  
  Duration? _remotePosition;
  bool _isPlaying = false;
  Duration _syncOffset = Duration.zero; // ajuste fino do usuário
  
  Timer? _pollTimer;
  
  // Inicia polling de posição
  void startPolling() {
    _pollTimer = Timer.periodic(Duration(milliseconds: 500), (_) async {
      final session = await client!.getSession(deviceId!);
      if (session != null) {
        _remotePosition = Duration(microseconds: session.positionTicks ~/ 10);
        _isPlaying = !session.isPaused;
        notifyListeners();
      }
    });
  }
  
  void stopPolling() {
    _pollTimer?.cancel();
  }
  
  Duration get syncedPosition => 
      (_remotePosition ?? Duration.zero) + _syncOffset;
  
  Future<void> playPause() async => 
      client!.sendCommand(sessionId!, 'PlayPause');
  
  Future<void> seek(Duration position) async => 
      client!.sendCommand(sessionId!, 'Seek', 
          seekTicks: position.inMicroseconds * 10);
  
  Future<void> stop() async {
    stopPolling();
    await client!.sendCommand(sessionId!, 'Stop');
  }
}
```

---

## Fase 4: UI do Modo Mineração

**Novo arquivo**: `chisa/lib/pages/mining/mining_mode_page.dart`

### Layout da Tela

```
┌─────────────────────────────────────┐
│ ⬆️ Legenda anterior (esmaecida)     │  ← swipe pra ver histórico
│                                     │
│ ┌─────────────────────────────────┐ │
│ │                                 │ │
│ │  『今日はいい天気ですね』         │ │  ← LEGENDA ATUAL (grande)
│ │                                 │ │     fundo preto
│ │                                 │ │     texto branco grande
│ └─────────────────────────────────┘ │
│                                     │
│ ⬇️ Próxima legenda (esmaecida)     │
│                                     │
├─────────────────────────────────────┤
│  [Play/Pause] [⏪10s] [⏩10s] [📋]  │  ← controles
│                                     │
├─────────────────────────────────────┤
│ ⬜ Flashcards criados nesta sessão  │  ← mini-histórico
│ ⬜ (última) palavraX → card criado │
│                                     │
├─────────────────────────────────────┤
│ ┌──────┬───────┬──────┬──────────┐ │
│ │ Dict │ Card  │ Loop │ Config   │ │  ← ações
│ └──────┴───────┴──────┴──────────┘ │
└─────────────────────────────────────┘
```

### Funcionalidades da UI

| Interação | Ação |
|-----------|------|
| **Tap na palavra** | Abre popup do dicionário (reaproveitar `DictionaryDialog`) |
| **Long press na palavra** | Cria flashcard com contexto (reaproveitar `CardCreator`) |
| **Swipe esquerda** | Avança 10s na TV |
| **Swipe direita** | Volta 10s na TV |
| **Swipe para cima** | Abre lista de legendas anteriores (reaproveitar `TranscriptDialog`) |
| **Botão Play/Pause** | Pausa/continua a TV |
| **Botão Loop** | Ativa/desativa repetição da legenda atual (shadowing) |
| **Botão Config** | Ajusta offset de sincronia, tamanho da fonte |

### Estados do Widget

```dart
class MiningModePage extends StatefulWidget {
  final PlayerLaunchParams params;
  final CastSessionManager castSession;
  final List<SubtitleItem> subtitles;
}

class _MiningModePageState extends State<MiningModePage> {
  Subtitle? _currentSubtitle;
  int _currentIndex = -1;
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.castSession, // reage a mudanças de posição
      builder: (context, _) {
        _updateCurrentSubtitle();
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                // Legenda anterior (esmaecida)
                _buildPreviousSubtitle(),
                // Legenda atual (grande, interativa)
                Expanded(child: _buildCurrentSubtitle()),
                // Próxima legenda (esmaecida)
                _buildNextSubtitle(),
                // Controles
                _buildRemoteControls(),
                // Mini status bar
                _buildSessionStatus(),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _updateCurrentSubtitle() {
    final pos = widget.castSession.syncedPosition;
    final newIndex = subtitles.controller!.subtitles.indexWhere(
      (s) => s.start <= pos && s.end >= pos
    );
    if (newIndex != _currentIndex && newIndex != -1) {
      _currentIndex = newIndex;
      _currentSubtitle = subtitles.controller!.subtitles[newIndex];
    }
  }
}
```

---

## Fase 5: Integração com o PlayerPage Existente

### Modificações em `player_page.dart`

1. **Adicionar suporte a dois modos**: `PlaybackMode.phone` e `PlaybackMode.tvMining`
2. **Detectar fonte Jellyfin**: Se `params.mediaSource` é `PlayerJellyfinSource`, mostrar opção "Assistir na TV + Minerar"
3. **Build condicional**: Se `tvMiningMode == true`, construir `MiningModePage` em vez do player normal
4. **Inicialização do CastSessionManager** no `initState` quando em modo TV

### Fluxo de UI

```
PlayerHomePage (histórico)
  │
  ├─ Tap em item Jellyfin
  │   │
  │   └─ Diálogo: "Assistir no Celular" ou "Assistir na TV + Minerar"
  │       │
  │       ├─ "Celular" → PlayerPage normal (comportamento atual)
  │       │
  │       └─ "TV + Minerar" → Diálogo de seleção de dispositivo
  │           │
  │           ├─ Lista dispositivos Chromecast (via Jellyfin API)
  │           ├─ Usuário seleciona a TV
  │           ├─ Jellyfin inicia stream na TV
  │           └─ Abre PlayerPage em modo Mining
  │               │
  │               ├─ Tela preta com legendas interativas
  │               ├─ Polling de posição do Jellyfin (500ms)
  │               └─ Controles remotos na barra inferior
  │
  └─ Tap em item Local/YouTube → PlayerPage normal (sem opção TV)
```

---

## Fase 6: Ajustes de Sincronia

### Offset de legenda

O Jellyfin reporta `PositionTicks` (1 tick = 100ns). O polling via rede introduz latência de ~50-200ms.

Solução:
```dart
// No CastSessionManager
Duration get syncedPosition {
  // Compensa latência de rede + offset configurado pelo usuário
  final rawPosition = Duration(microseconds: _rawPositionTicks ~/ 10);
  final networkLatency = Duration(milliseconds: _estimatedLatency);
  return rawPosition + _syncOffset - networkLatency;
}
```

O usuário pode ajustar o offset via:
- Botões +100ms / -100ms na tela de configuração
- Swipe horizontal fino (modo calibração)

---

## Estrutura de Arquivos (Resumo)

### Novos arquivos
```
chisa/lib/jellyfin/
├── jellyfin_client.dart           # Cliente REST da API Jellyfin
├── jellyfin_models.dart           # Modelos: JellyfinItem, JellyfinDevice, etc.
├── cast_session_manager.dart      # Gerenciador de sessão cast/mining
└── jellyfin_login_dialog.dart     # Diálogo de login (server URL + credenciais)

chisa/lib/media/media_sources/
└── player_jellyfin_source.dart    # Nova MediaSource para Jellyfin

chisa/lib/pages/mining/
├── mining_mode_page.dart          # Tela principal de mineração
├── mining_controls.dart           # Barra de controles remotos
├── mining_subtitle_display.dart   # Widget de exibição de legenda
└── device_picker_dialog.dart      # Diálogo de seleção de dispositivo
```

### Arquivos modificados
```
chisa/lib/models/app_model.dart    # Adicionar PlayerJellyfinSource
chisa/lib/pages/player_page.dart   # Suporte a modo TV/mineração
chisa/lib/pages/player_home_page.dart  # Opção "Cast" nos itens Jellyfin
chisa/pubspec.yaml                 # (provavelmente nada novo)
```

---

## Cronograma Estimado

| Fase | Descrição | Esforço |
|------|-----------|---------|
| **1** | Cliente API Jellyfin (auth + browse + stream) | 1 semana |
| **2** | PlayerJellyfinSource (integrar ao player existente) | 1 semana |
| **3** | CastSessionManager (polling + comandos) | 1 semana |
| **4** | Mining Mode UI (tela de legendas + interações) | 1-2 semanas |
| **5** | Integração PlayerPage (dois modos + fluxo de UI) | 1 semana |
| **6** | Sincronia fina + testes multi-dispositivo | 1 semana |
| **Total** | | **6-8 semanas** |

---

## Riscos e Mitigações

| Risco | Impacto | Mitigação |
|-------|---------|-----------|
| Latência de sync inaceitável | Legendas dessincronizadas | Polling agressivo (200ms) + offset ajustável + opção de usar WebSocket do Jellyfin |
| Jellyfin API muda | Quebra integração | Usar apenas endpoints estáveis documentados |
| Dispositivos Chromecast diferentes | Compatibilidade | Testar com Chromecast gen 2/3/Ultra, Android TV, Google TV |
| VLC conflita com streaming externo | Crash | Isolar VLC do modo mining (não iniciar player local) |
| Bateria do celular | Drena rápido | Modo escuro + polling reduzido quando em background |

---

## MVP (Produto Mínimo Viável) — 3 semanas

Se o objetivo é testar o conceito rapidamente:

1. **JellyfinClient** com auth + getStreamUrl + getSubtitles (sem browse gráfico — usuário cola URL/itemId)
2. **Mining Mode** mínimo: tela preta com legenda atual + tap-to-lookup + controles play/pause
3. **Cast manual**: usuário inicia o cast pelo app do Jellyfin, o jidoujisho só monitora a sessão

Isso pula as fases de browse de biblioteca, device picker, e controles avançados — mas já entrega o core da experiência.

---

## Referências

- [Jellyfin API Docs](https://api.jellyfin.org/)
- [Jellyfin Client Development Guide](https://jellyfin.org/docs/general/clients/client-development)
- [Google Cast SDK (Android)](https://developers.google.com/cast/docs/android_sender)
- [flutter_vlc_player](https://pub.dev/packages/flutter_vlc_player)
- Código base: `chisa/lib/media/media_sources/player_youtube_source.dart` (referência de MediaSource de rede)
- Código base: `chisa/lib/pages/player_page.dart` (referência do player atual)
- Código base: `chisa/lib/util/transcript_dialog.dart` (referência do painel de transcrição)

---

## Próximos Passos

1. [ ] Criar branch `feature/jellyfin-cast-mining`
2. [ ] Implementar `JellyfinClient` (Fase 1)
3. [ ] Testar autenticação e listagem de biblioteca contra um servidor Jellyfin real
4. [ ] Implementar `PlayerJellyfinSource` e integrar ao app (Fase 2)
5. [ ] Testar playback local via Jellyfin (sem cast) — valida que o stream funciona
6. [ ] Implementar `CastSessionManager` (Fase 3)
7. [ ] Implementar `MiningModePage` (Fase 4)
8. [ ] Integrar fluxo completo (Fase 5)
9. [ ] Testar com TV real e ajustar sincronia (Fase 6)

---

> **Documento gerado em**: 2026-06-18
> **Baseado na análise do código**: branch `main`, commit mais recente (82 releases, 1081 commits)
> **Licença do projeto**: GPL-3.0 (contribuições bem-vindas)
