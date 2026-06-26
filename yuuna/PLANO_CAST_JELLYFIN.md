# Plano: Corrigir Cast e Browse do Jellyfin

## Contexto

O usuário reportou dois problemas:
1. **Cast**: device picker mostra vários "Cast Device" genéricos que não funcionam
2. **Jellyfin Browse**: pastas "TV Show" e "Movies" não mostram conteúdo

Além disso, investigação revelou **22 bugs** em 7 arquivos, incluindo bugs críticos de lógica.

## Descobertas da Investigação

### Browse quebrado (3 causas)
- `getItems()` hardcoded `Recursive: true` → achata hierarquia TV Shows (Series/Seasons/Episodes misturados)
- `Fields: 'MediaSources,MediaStreams'` enviado para itens-pasta que não têm mídia
- **Todos** os erros são silenciosamente engolidos (`catch (_)` sem log nenhum)

### Cast quebrado (4 causas)
- `isCastDevice` catch-all retorna `true` pra qualquer app Jellyfin não-excluído (até o próprio Yuuna!)
- SSDP fallback classifica qualquer dispositivo como "Smart TV / Cast Device"
- Sem implementação do protocolo Chromecast V2 — só DIAL discovery + UPnP (que Chromecast não usa)
- Matching SSDP↔Jellyfin por substring solto gera falsos positivos

### Bugs críticos (4)
- `DlnaSessionManager` shadowa TODOS os campos privados do pai → `seekForward/Backward` sempre buscam a partir de zero
- `late JellyfinItem` pode ficar não-inicializada → crash
- `getSession()` ignora filtro `DeviceId` e pega `sessions.first`
- `playOnDlnaDevice()` não checa resposta do comando Play SOAP

## Abordagem

**Sem novas dependências.** Consertar o que existe antes de adicionar complexidade. O `dart_cast` (Chromecast V2 puro Dart) fica como follow-up.

## Fases de Implementação

### Fase 1: Browse do Jellyfin (~3 arquivos)
**Arquivos:** `jellyfin_client.dart`, `player_jellyfin_source.dart`, `jellyfin_media_search_bar.dart`

1. **`jellyfin_client.dart:128`** — Mudar `recursive` default de `true` → `false`
2. **`jellyfin_client.dart:140`** — `Fields` condicional: `recursive=true` inclui MediaSources/MediaStreams; `recursive=false` inclui só Overview
3. **`jellyfin_media_search_bar.dart`** — Substituir `catch (_)` por `catch (e, stack)` + `debugPrint`; distinguir "sem itens" vs "erro" com UI de retry

### Fase 2: Descoberta de Dispositivos Cast (~3 arquivos)
**Arquivos:** `jellyfin_models.dart`, `ssdp_discovery.dart`, `device_picker_dialog.dart`

4. **`jellyfin_models.dart:248-253`** — REMOVER catch-all que classifica qualquer app como cast
5. **`jellyfin_models.dart:220-227`** — Adicionar `windows, mac, linux, macos` à lista de exclusão
6. **`ssdp_discovery.dart:115-118`** — Fallback `return null` em vez de "Smart TV / Cast Device"
7. **`device_picker_dialog.dart:134-136`** — Matching por palavras (word-level intersection ≥2 ou palavra >4 chars)
8. **`device_picker_dialog.dart`** — Dedup final por label.toLowerCase()

### Fase 3: Logging de Erros (~5 arquivos)
**Arquivos:** todos os 5 arquivos jellyfin/*.dart + player_jellyfin_source.dart

9. Substituir **todos** os `catch (_)` por `catch (e)` + `debugPrint('[Jellyfin] ...: $e')`
10. Adicionar logs em pontos de falha silenciosa (~25 locais)

### Fase 4: Bugs Críticos (~3 arquivos)
**Arquivos:** `dlna_session_manager.dart`, `player_jellyfin_source.dart`, `jellyfin_client.dart`

11. **`dlna_session_manager.dart`** — Adicionar `@override` em `seekForward`, `seekBackward`, `adjustSyncOffset`, `setSyncOffset`, `resetSyncOffset`
12. **`player_jellyfin_source.dart:449`** — Trocar `late JellyfinItem` por nullable + null-check
13. **`jellyfin_client.dart:300-312`** — Filtrar `getSession()` pelo `DeviceId` correto (case-sensitive: `deviceId`)
14. **`jellyfin_client.dart:276-297`** — Corrigir payload `startPlayback` (`ItemIds` array, `PlayCommand`)
15. **`ssdp_discovery.dart:227-238`** — Checar resposta do Play SOAP

## Ordem de Execução

Fase 4A (DLNA field shadowing) → Fase 4B (late var) → Fase 1 (browse) → Fase 3 (logging) → Fase 2 (discovery) → Fase 4C/D/E (fixes restantes)

## Verificação

- **Browse:** Conectar ao Jellyfin → abrir search → TV Shows mostra Series (não episódios flat)
- **Cast:** Abrir device picker → só aparecem dispositivos reais (nada de "Cast Device" genérico)
- **DLNA:** Seek forward/backward mantém posição relativa correta
- **Erro:** Desconectar rede → mensagem de erro visível (não "No items found" silencioso)
- **Analyzer:** `flutter analyze` passa limpo (zero warnings)

## Follow-up (não incluso neste plano)

- Integrar `dart_cast` v0.6.0 para Chromecast V2 nativo (substitui dependência do Jellyfin server para cast)
- Adicionar testes unitários para `CastSessionManager`, `DlnaSessionManager`, `JellyfinClient`
