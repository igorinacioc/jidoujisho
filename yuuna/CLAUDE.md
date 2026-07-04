# Yuuna

> A full-featured immersion language learning suite for mobile — Flutter · GPL 3.0 · v2.9.0+120

## Visão Geral

App Flutter multiplataforma (Android, iOS, Windows, Web) focado em aprendizado de idiomas por imersão, com ênfase em japonês. Permite criar flashcards (Anki), ler e-books com dicionário integrado, assistir vídeos com legendas, extrair vocabulário e muito mais.

### Stack principal
- **State management:** Riverpod (`flutter_riverpod ^2.3.6`) + `ChangeNotifier`
- **Banco local:** Isar ^3.1.0 (estrutural, schemas com `@collection`) + Hive ^2.0.6 (chave-valor)
- **Geração de código:** `build_runner` + `dart_mappable` + `json_serializable` + `isar_generator` + `copy_with_extension`
- **Lint:** `flutter_lints/flutter.yaml` + **57 regras extras** (ver `analysis_options.yaml`)
- **Rede:** Dio ^5.1.1, WebSocket, YouTube Explode (fork)
- **i18n:** `slang` ^3.13.0 (~430 chaves, apenas inglês atualmente)
- **Áudio/Vídeo:** flutter_vlc_player (fork), just_audio, flutter_ffmpeg
- **Linguística JP:** mecab_dart, kana_kit, lemmatizerx, flutter_charset_detector
- **UI:** google_fonts, flutter_html, carousel_slider, infinite_scroll_pagination

### ⚠️ Gerenciador de versão — CRÍTICO

O projeto usa **FVM** (Flutter Version Management) travado em Flutter **3.13.5** (ver `.fvmrc`).

**NUNCA compile com outra versão do Flutter.** O projeto NÃO é compatível com Flutter 3.44+:
- A API do Android Gradle Plugin (AGP 7.1.2 / Gradle 7.2) é incompatível com Flutter 3.44+ (que exige AGP 8.x / Gradle 8.4+ e plugins declarativos).
- `DecoderCallback` e outras APIs do framework mudaram em versões mais novas.
- As dependências Git forkadas (`arianneorpilla/*`) têm refs fixos testados apenas contra 3.13.5.

**Setup local:**
```bash
# O FVM está instalado em C:/Users/Family/fvm/ com o cache em versions/3.13.5/
# Use o binário diretamente:
export PATH="/c/Users/Family/fvm/versions/3.13.5/bin:$PATH"
flutter --version  # Deve mostrar Flutter 3.13.5

# Ou com o comando fvm (se disponível no PATH):
fvm flutter run
```

**Versões travadas do toolchain Android:**
| Componente | Versão | Local |
|-----------|--------|-------|
| Flutter | 3.13.5 | `.fvmrc` |
| AGP | 7.1.2 | `android/build.gradle` |
| Gradle | 7.2 | `android/gradle/wrapper/gradle-wrapper.properties` |
| Kotlin | 1.8.22 | `android/build.gradle` |
| NDK | 21.4.7075529 | `android/app/build.gradle` |

**Se tentar build com Flutter do sistema (3.44+):** Vai falhar com erros de `app_plugin_loader`, `flutter.gradle` imperativo, `DecoderCallback`, `KotlinPluginWrapper` e `ConfigurableFilePermissions`. Todos são falsos positivos — o código está correto para a versão alvo.

### ⚠️ Bitrot de plugins pub.dev — build limpo quebra

Plugins Flutter antigos (mecab_dart, async_zip, etc.) têm `android/build.gradle` congelado há 5+ anos com:
- **AGP 3.5~4.x** — incompatível com Gradle 7.2 (não registra extensão `android {}`)
- **jcenter()** — offline desde 2022 (artefatos não resolvem)
- **Kotlin < 1.5** — incompatível com AGP 7.x

O build "funcionava" porque o cache local do Gradle (`~/.gradle/caches/`) retinha os artefatos baixados antes do jcenter morrer. Um `flutter clean` + limpeza de cache Gradle quebra o build.

**Solução para build limpo** — patch nos plugins do pub cache:

```bash
# mecab_dart: atualizar AGP, Kotlin e remover jcenter
sed -i \
  -e "s/jcenter()/mavenCentral()/g" \
  -e "s/com.android.tools.build:gradle:3.5.0/com.android.tools.build:gradle:7.1.2/" \
  -e "s/kotlin_version = '1.3.50'/kotlin_version = '1.8.22'/" \
  "$HOME/AppData/Local/Pub/Cache/hosted/pub.dev/mecab_dart-0.1.3/android/build.gradle"

# async_zip: mesmo tratamento (versão pode variar)
find "$HOME/AppData/Local/Pub/Cache/hosted/pub.dev/async_zip-"* -name build.gradle -path "*/android/*" -exec \
  sed -i \
    -e "s/jcenter()/mavenCentral()/g" \
    -e "s/com.android.tools.build:gradle:4.1.3/com.android.tools.build:gradle:7.1.2/" \
  {} \;

# Atenção: NÃO adicionar mirrors Aliyun nos buildscripts dos plugins.
# Os mirrors retornam 502 e o Gradle NÃO faz fallback para google()/mavenCentral(),
# quebrando a resolução de dependências transitórias do AGP (aaptcompiler, builder, gson, grpc).
```

**Se `No signature of method: android()` persistir:** significa que o classpath do plugin não carregou AGP. Causas:
1. Artefato não baixado (rede) → verificar conectividade com `google()` e `mavenCentral()`
2. Kotlin incompatível com AGP → garantir `kotlin_version = '1.8.22'` no plugin
3. Cache Gradle corrompido → `rm -rf ~/.gradle/caches/` e rebuild

### Estrutura do projeto
```
lib/
├── main.dart              # Entry point + JidoujishoApp widget
├── models.dart            # Barrel: AppModel, CreatorModel
├── pages.dart             # Barrel: ~70 implementações de UI
├── utils.dart             # Barrel: componentes, conversores, player, misc
├── media.dart             # Barrel: tipos de mídia e fontes
├── creator.dart           # Barrel: criador de flashcards
├── dictionary.dart        # Barrel: dicionários e formatos
├── language.dart          # Barrel: implementações de idioma
├── i18n/                  # strings.i18n.json (~430 chaves, inglês)
└── src/
    ├── creator/           # Criador de flashcards Anki
    │   ├── actions/       #   6 ações rápidas (share, copy, stash, export...)
    │   ├── enhancements/  #  15 melhorias (camera, Forvo, Bing Images, ChatGPT...)
    │   └── fields/        #  18 campos (term, meaning, furigana, pitch, cloze...)
    ├── dictionary/        # Motor de dicionários
    │   └── formats/       #   Yomichan, ABBYY Lingvo, Migaku
    ├── language/          # Suporte a idiomas
    │   └── implementations/  # JapaneseLanguage, EnglishLanguage
    ├── media/             # Sistema de mídia (Player, Reader, Viewer)
    │   ├── sources/       #   YouTube, local, browser, ChatGPT, lyrics...
    │   └── types/         #   Enum de tipos por modo (dictionary, player, reader, viewer)
    ├── models/            # AppModel (estado global) + CreatorModel
    ├── pages/             # BasePage → BaseHistoryPage → BaseTabPage etc.
    │   └── implementations/  # ~65 páginas concretas
    └── utils/             # Componentes reutilizáveis, conversores, player
```

### Padrão de páginas
Todas as páginas herdam de uma cadeia base: `BasePage` → `BasePageState`, com variantes como `BaseHistoryPage`, `BaseTabPage`, `BaseSourcePage`. Isso fornece shortcuts, gestão de estado comum e comportamento consistente entre telas.

### Assets notáveis
| Caminho | Conteúdo |
|---------|----------|
| `assets/language/japanese/ipadic/` | Dicionário MeCab IPADIC (.dic, .bin, .def) para parsing morfológico |
| `assets/ttu-ebook-reader/` | Web app SvelteKit completo embarcado como leitor de e-books |
| `assets/fonts/` | NotoSansJP (Regular + Bold) |
| `assets/meta/` | Ícones do launcher |
| `assets/licenses/` | Licenças de componentes de terceiros |

### Geração de código
Arquivos `*.g.dart`, `*.mapper.dart` e `*.freezed.dart` são gerados. **Nunca edite-os manualmente.**
Rode `dart run build_runner build --delete-conflicting-outputs` (ou `watch`) após alterar modelos anotados.
O analyzer exclui esses arquivos (`analysis_options.yaml` linha 13-16).

### Dependências Git customizadas (~12 forks)
Várias dependências usam forks pessoais (`arianneorpilla/*`) com patches específicos para o jidoujisho.
Ver `pubspec.yaml` para refs exatos. **Não atualize sem verificar breaking changes no fork.**
Principais forks: `flutter_vlc_player`, `flutter_inappwebview`, `wakelock`, `youtube_explode_dart`, `spaces`, `subtitle`, `ruby_text`, `material_floating_search_bar`, `blurrycontainer`, `filesystem_picker`, `nowplaying`, `receive_intent`, `ve_dart`.

### Licença
GPL 3.0 — todo código derivado deve manter a mesma licença. Dependências novas precisam ser compatíveis.

---

## Diretrizes para Contribuições com IA

> Baseado nas melhores práticas discutidas em:
> [AkitaOnRails — Controvérsia IA Contribuições Projetos Código Aberto](https://akitaonrails.com/2026/06/05/controversia-ia-contribuicoes-projetos-codigo-aberto-minha-opiniao/)

### 1. IA é ferramenta de triagem, não de decisão
- Use IA para **investigar**: resumir diffs, detectar code smells, identificar impactos em schema.
- A **decisão final** de aprovar/rejeitar PR é sempre humana.
- Um PR "feito com IA" significa **comece a auditoria**, não autorização automática.
- "Quase nenhum PR chega imediatamente mergeável" — espere iterar.

### 2. Trate a descrição do PR como hipótese, o diff como evidência
- Não confie cegamente na descrição do PR (seja ela escrita por humano ou IA).
- Audite o código inteiro — o que o código *faz* vs. o que a descrição *diz que faz*.
- Commits devem ser atômicos e revisáveis individualmente.

### 3. Nunca quebre compatibilidade sem migração limpa
- Este projeto já está em uso por pessoas reais (Google Play e sideload).
- Mudanças de schema Isar (`@collection`) ou estrutura Hive **precisam de migração no upgrade**.
- Estrutura de arquivos de dicionário ou assets não pode mudar sem path de fallback.
- Se precisar quebrar algo, documente em changelog e versione com semver.

### 4. Padrão de qualidade do código (já elevado — manter)
- 57 regras de lint ativas além do `flutter_lints/flutter.yaml`. Siga todas.
- `flutter analyze` deve passar **limpo**. Zero warnings, zero infos.
- `public_member_api_docs: true` — toda API pública precisa de doc comment.
- `avoid_dynamic_calls: true` — não use `dynamic` sem necessidade extrema.
- `only_throw_errors: true` — exceções devem ser objetos `Error`, não strings.
- `package_api_docs: true` — barrel exports precisam de documentação.

### 5. Use o app diariamente (dogfooding)
- Teste real pega o que análise estática e CI não cobrem.
- Antes de mergir PR, valide o fluxo real no dispositivo/emulador.
- Comportamento estranho em uso real é sinal de bug, mesmo com `flutter analyze` limpo.
- Exemplo do artigo: bug de pareamento de spreads em leitor de mangá só foi pego no uso real.

### 6. CI multiplataforma
- O projeto roda em Android, iOS, Windows, Web.
- PRs devem ser testados em pelo menos Android (plataforma principal).
- Issues de usuários em iOS/Web/Windows são valiosos — ambientes que o mantenedor não testa diariamente.
- Considere adicionar GitHub Actions com `flutter analyze` + build multiplataforma.

### 7. Deploy real pós-merge como filtro final
- Após mergir, rode build de release e teste funcionalidade online.
- "Não garante nada. Mas evita quebrar o óbvio."

### 8. IA amplifica o padrão do mantenedor
- "Se você é engenheiro de verdade, ela amplifica sua engenharia."
- Instruções frouxas → IA acelera a entropia.
- Instruções rigorosas → IA acelera a qualidade.
- Para cada PR: verifique regressão, qualidade de código, cobertura de features, migração de dados.

### 9. Combata volume com automação, não com proibição
- Banir IA é "adiar uma briga impossível de ganhar."
- Use IA na primeira triagem para filtrar, resumir e destacar problemas.
- A decisão final é humana, mas o trabalho braçal de investigação é delegável.
- Cuidado especial com "relatórios de vulnerabilidade alucinados" (caso curl) — triagem automática é defesa crítica.

### 10. Auditoria agregada pós-merge
- Após dias com múltiplos PRs, faça auditoria completa no diff acumulado.
- Busque: regressão, duplicação, código morto, magic values, interações indesejadas entre PRs.
- PRs individuais podem estar corretos mas causarem problemas quando combinados.

### 11. Código humano também tem bugs — a diferença é escala
- Rust tem bugs, Zig tem bugs, Linux tem bugs. Atribuir toda regressão a IA é viés.
- A diferença real: IA produz "mais lixo por minuto" mas também "mais correção por minuto se você montar o processo direito."
- A causa raiz mais comum de regressão são **testes insuficientes**, não origem do código.

---

## Fluxo de Revisão de PR (checklist)

```
[ ] flutter analyze passa limpo (zero warnings)
[ ] dart run dependency_validator sem problemas
[ ] Descrição do PR confere com o diff real
[ ] Nenhuma quebra de schema Isar (@collection) sem migração
[ ] Nenhuma quebra de estrutura Hive sem fallback
[ ] public_member_api_docs nos novos membros públicos
[ ] package_api_docs nos novos barrel exports
[ ] Testado em dispositivo/emulador real (Android mínimo)
[ ] Sem regressão visível em funcionalidades próximas
[ ] Dependências novas justificadas e compatíveis com GPL 3.0
[ ] Se adicionou modelo anotado: *.g.dart foi gerado e commitado
```

---

## Comandos Úteis

```bash
# FVM: usar a versão correta do Flutter
fvm flutter run                    # Rodar app
fvm flutter analyze                # Análise estática

# Sem FVM (se Flutter global = 3.13.5)
flutter analyze

# Gerar código após mudanças em modelos
dart run build_runner build --delete-conflicting-outputs

# Build Android release
flutter build apk --release

# Build Windows release
flutter build windows --release

# Verificar dependências problemáticas
dart run dependency_validator

# Gerar traduções (após editar strings.i18n.json)
dart run slang
```

## Build limpo: checklist de recuperação (VALIDADO 2026-06-24)

Após `flutter clean` + `rm -rf ~/.gradle/caches`, plugins pub.dev antigos quebram.
Procedimento validado em 2026-06-24 com build debug funcional:

### 1. mecab_dart (fork local com `dependency_overrides`)
O plugin original usa AGP 3.5.0/jcenter/Kotlin 1.3.50, tudo morto.
**Solução:** fork em `local_fixes/mecab_dart/` com override no `pubspec.yaml`.

**build.gradle mínimo do fork:**
```groovy
group 'com.example.mecab_dart'
version '1.0-SNAPSHOT'

apply plugin: 'com.android.library'
apply plugin: 'kotlin-android'

// ⚠️ Usar project.android {}, NÃO android {} diretamente!
// O buildscript do subprojeto não herda a extensão AGP do raiz
// via methodMissing. Chamar no project explicitamente resolve.
project.android {
    namespace 'com.example.mecab_dart'
    compileSdkVersion 34
    sourceSets { main.java.srcDirs += 'src/main/kotlin' }
    defaultConfig {
        minSdkVersion 16
        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }
    lintOptions { disable 'InvalidPackage' }
    externalNativeBuild {
        cmake { path "CMakeLists.txt" }
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.8.22"
}
```

**Por que `project.android {}` e não `android {}`?**
- O `buildscript {}` do raiz carrega AGP 7.1.2 no classpath
- `apply plugin: 'com.android.library'` registra a extensão no objeto `project`
- Mas o methodMissing do buildscript do subprojeto NÃO delega para `project.android`
- `project.android {}` chama a extensão diretamente → funciona
- **Descoberto em:** 2026-06-23, após 20+ tentativas frustradas de build

### 2. async_zip (patch no pub cache)
Mesmo problema: AGP 4.1.3/jcenter. Resolvido com patch:
```bash
sed -i \
  -e "s/jcenter()/mavenCentral()/g" \
  -e "s/com.android.tools.build:gradle:4.1.3/com.android.tools.build:gradle:7.1.2/" \
  "$HOME/AppData/Local/Pub/Cache/hosted/pub.dev/async_zip-0.1.0/android/build.gradle"
```

### 3. flutter_ffmpeg + mobile-ffmpeg-min-gpl ✅ RESOLVIDO (2026-06-24)

**Problema original:** `flutter_ffmpeg ^0.4.2` dependia de `com.arthenica:mobile-ffmpeg-full-gpl:4.4.LTS` (212 MB).
Este artefato foi removido de todos os repositórios Maven públicos e o .aar de 212 MB sofria
corrupção no transform cache do Gradle.

**Solução aplicada:** Usar `mobile-ffmpeg-min-gpl:4.4.LTS` (40.5 MB, 5x menor) com os codecs essenciais.
O `min-gpl` cobre h264, aac, mp4 — suficiente para YouTube e processamento de mídia do app.

**Setup:**
1. `.aar` instalado em `~/.m2/repository/com/arthenica/mobile-ffmpeg-min-gpl/4.4.LTS/` com `.pom`
2. `android/build.gradle` → `flutterFFmpegPackage = "min-gpl-lts"`
3. `flutter_ffmpeg` build.gradle patchado: `jcenter()` → `mavenCentral()`, AGP `4.1.3` → `7.1.2`
4. `mavenLocal()` no `allprojects` do raiz garante resolução local
5. `.aar` também em `android/app/libs/` como fallback (`flatDir` no `app/build.gradle`)

**Pré-build:**
```bash
rm -rf ~/.gradle/caches/transforms-*
rm -rf android/.gradle android/build android/app/build
```

### 4. Sempre usar FVM Flutter 3.13.5
```bash
export PATH="/c/Users/Family/fvm/versions/3.13.5/bin:$PATH"
flutter build apk --debug
```

### 4. NÃO usar mirrors Aliyun nos buildscripts dos plugins
Retornam 502 e o Gradle NÃO faz fallback para google()/mavenCentral().

### 5. Ferramentas instaladas
- **ai-memory v1.1.3** — servidor MCP em `127.0.0.1:49374` (HTTP), hooks Claude Code ativos
  - Binário: `%LOCALAPPDATA%\ai-memory\ai-memory.exe`
  - Data dir: `~/.local/share/ai-memory`
  - Iniciar: `ai-memory.exe --data-dir ~/.local/share/ai-memory serve --transport http --enable-web`
  - Bootstrap (precisa LLM provider): `ai-memory bootstrap --repo-path . --dry-run`

## Gaps Conhecidos (oportunidades de melhoria)

| Gap | Impacto | Ação sugerida |
|-----|---------|---------------|
| Zero testes automatizados | Risco de regressão em refactors | Adicionar `test/` com testes unitários para modelos e serviços |
| Sem CI/CD | Sem verificação automática de qualidade | Configurar GitHub Actions com `flutter analyze` |
| Sem README.md | Onboarding difícil para contribuidores | Criar README com propósito, setup e como contribuir |
| i18n só em inglês | Exclui usuários não-anglófonos | Adicionar traduções (JP, PT-BR, etc.) |
| ~12 forks Git pessoais | Risco se repositórios ficarem offline | Documentar forks; considerar upstream ou mirror |
| ✅ Build limpo resolvido | — | ffmpeg: min-gpl; mecab_dart: fork local; async_zip: patch | |

---

## 🧪 Infraestrutura de Teste com Emulador (2026-06-26)

### ⚠️ Paths do Android SDK — NUNCA usar `cmd.exe /c`

**`cmd.exe /c` NÃO funciona** — o processo morre silenciosamente ou não produz output.
Use **sempre paths diretos do bash** com barras `/`.

| Variável | Valor expandido |
|----------|-----------------|
| `%LOCALAPPDATA%` | `C:\Users\Family\AppData\Local` |
| `%APPDATA%` | `C:\Users\Family\AppData\Roaming` |
| adb | `C:/Users/Family/AppData/Local/Android/Sdk/platform-tools/adb.exe` |
| emulator | `C:/Users/Family/AppData/Local/Android/Sdk/emulator/emulator` |

### Emulador Android leve (`yuuna_test`)
Emulador API 30 x86_64 sem Google APIs, 2GB RAM, 1 core, GPU SwiftShader.

```bash
# Iniciar (com janela visivel) — bash direto com & no final:
"C:/Users/Family/AppData/Local/Android/Sdk/emulator/emulator" \
  -avd yuuna_test \
  -gpu auto \
  -no-boot-anim \
  -netdelay none \
  -netspeed full &

# Aguardar boot (~20s) e verificar:
sleep 20
C:/Users/Family/AppData/Local/Android/Sdk/platform-tools/adb.exe devices
# Deve mostrar: emulator-5554  device
```

### Instalar e iniciar o app
```bash
# Build (sempre usar FVM):
export PATH="/c/Users/Family/fvm/versions/3.13.5/bin:$PATH"
flutter build apk --debug

# Instalar (bash direto):
C:/Users/Family/AppData/Local/Android/Sdk/platform-tools/adb.exe install -r build/app/outputs/flutter-apk/app-debug.apk

# Iniciar (ATENCAO: sem LAUNCHER no manifest, usar explicit intent):
C:/Users/Family/AppData/Local/Android/Sdk/platform-tools/adb.exe shell am start -n app.arianneorpilla.yuuna/.MainActivity
```

### agent-device (testes automatizados)
```bash
# Instalado em: C:/Users/Family/AppData/Roaming/npm/agent-device.cmd
# ⚠️ agent-device é Node.js, NÃO funciona no Git Bash (npm/node fora do PATH).
# Usar PowerShell:
powershell -Command "& 'C:\Users\Family\AppData\Roaming\npm\agent-device.cmd' snapshot -i"

# Ou cmd.exe (única exceção que funciona com cmd.exe /c):
cmd.exe /c "C:\Users\Family\AppData\Roaming\npm\agent-device.cmd snapshot -i"

# Comandos uteis:
#   snapshot -i     → arvore de acessibilidade (elementos interativos)
#   screenshot <p>  → captura de tela
#   tap @e5         → tocar elemento
#   fill @e3 "txt"  → preencher campo
#   open app.arianneorpilla.yuuna --platform android
```

### Teste do Jellyfin (servidor real)
```bash
cd packages/server_jellyfin
# Configurar antes de rodar:
export JELLYFIN_URL="http://192.168.0.73:8096"
export JELLYFIN_USERNAME="igor"
export JELLYFIN_PASSWORD="2803"
dart run test/jellyfin_live_test.dart
```

### Problemas conhecidos
- **Emulador sem janela**: NUNCA usar `-no-window` — usuario precisa ver a tela
- **Package name**: `app.arianneorpilla.yuuna` (nao `app.lrorpilla.jidoujisho`)
- **Sem LAUNCHER**: AndroidManifest nao tem `category.LAUNCHER` — necessario iniciar com `am start -n`
- **APK 388MB**: inclui todas as ABIs (media_kit). Debug somente.
- **media_kit precisa SDK 36**: warning no build, mas funciona
- **npm/node nao no PATH do Git Bash**: usar `cmd.exe /c` ou PowerShell
- **Adicionar novo MediaType causa crash no startup**: Ver [#Bugfix: Novo MediaType sem entry em mediaSources](#bugfix-novo-mediatype-sem-entry-em-mediasources)
- **Emulador pode precisar de `-gpu swiftshader_indirect` se der crash grafico**

### Bugfix: Novo MediaType sem entry em mediaSources (2026-06-26)

**Sintoma:** App crasha no startup com `Null check operator used on a null value` em
`AppModel.initialise` linha `mediaSources[type]!.values`.

**Causa:** `populateMediaSources()` (app_model.dart:765) tem um mapa `availableMediaSources`
com entradas para cada `MediaType`. Quando um novo `MediaType` é adicionado em
`populateMediaTypes()` (ex: `JellyfinMediaType`) mas NÃO em `populateMediaSources()`,
o loop de inicialização quebra porque `mediaSources[type]` retorna `null`.

**Solução:**
1. Adicionar entrada no `availableMediaSources` em `populateMediaSources()`:
   ```dart
   JellyfinMediaType.instance: [],
   ```
2. Tornar o loop de inicialização null-safe (app_model.dart:~1215):
   ```dart
   for (MediaType type in mediaTypes.values) {
     final sources = mediaSources[type];
     if (sources == null) continue;  // ← seguro para tipos sem sources
     for (MediaSource source in sources.values) {
       await source.initialise();
     }
   }
   ```

### Estado atual Jellyfin (branch `ffmpeg-kit-migration`)
- ✅ Aba Jellyfin dedicada (`JellyfinMediaType`) na barra inferior
- ✅ Jellyfin removido do seletor de sources da aba Player (só na própria)
- ✅ Player migrado para media_kit via `UniversalPlayerController`
- ✅ Track selector Moonfin-style (`TrackSelectorDialog`)
- ✅ Botao Cast TV no player (mDNS + CastV2 protocol + CORS proxy)
- ✅ Legendas WebVTT (fix Jellyfin 10.11)
- ✅ Posters com CachedNetworkImage + fallback azul com nome
- ✅ Navegacao de series (getSeasons/getEpisodes)
- ✅ App inicia sem crash
- ✅ Login Jellyfin funcional (port forwarding para emulador)
- ✅ Emulador yuuna_test funcionando com `-gpu swiftshader_indirect`
- ❌ Player: ícone central (replay) preso no meio da tela — `_isEnded` pode estar vindo true
- ❌ Player: barra de progresso no fim (tempo cheio) — mesma causa do ícone
- ❌ Player: legendas não aparecem — `durationSearch` não acha subtitle com posição zerada
- ❌ Series: temporada não mostra episódios — possível `getEpisodes` retornando vazio ou type mismatch

### ⚠️ Emulador NAT vs Jellyfin — Port Forwarding (2026-06-26)

**Problema:** O emulador Android usa NAT (`10.0.2.0/24`) e NÃO consegue alcançar
dispositivos na rede LAN como o servidor Jellyfin (`192.168.0.73:8096`). O gateway
`10.0.2.2` (host) não faz forwarding para a rede `192.168.0.0/24`.

**Solução: Cadeia de port forwarding com 2 pontas:**

```
Emulador ──▶ 127.0.0.1:8096 ──▶ Host (PC) ──▶ 192.168.0.73:8096
              ↑                      ↑
         adb reverse           netsh portproxy
```

#### Passo 1: Windows portproxy (REQUER ADMIN — executar no PowerShell como Admin)

```powershell
# Criar o túnel (só precisa rodar UMA vez, sobrevive a reboots):
netsh interface portproxy add v4tov4 `
    listenport=8096 `
    listenaddress=127.0.0.1 `
    connectport=8096 `
    connectaddress=192.168.0.73

# Verificar que existe:
netsh interface portproxy show all

# Remover quando não precisar mais:
netsh interface portproxy delete v4tov4 listenport=8096 listenaddress=127.0.0.1
```

⚠️ **Zero impacto na rede normal:** escuta exclusivamente em `127.0.0.1` (loopback).
Nenhum tráfego externo é afetado. Regra é de 1 porta, 1 IP origem, 1 IP destino.

#### Passo 2: adb reverse (NÃO precisa de admin)

```bash
# Criar túnel do emulador para o host:
C:/Users/Family/AppData/Local/Android/Sdk/platform-tools/adb.exe reverse tcp:8096 tcp:8096

# Verificar túneis ativos:
C:/Users/Family/AppData/Local/Android/Sdk/platform-tools/adb.exe reverse --list

# ⚠️ Este comando reverte TODOS os reverses (limpeza ao fim da sessão):
C:/Users/Family/AppData/Local/Android/Sdk/platform-tools/adb.exe reverse --remove-all
```

**IMPORTANTE: `adb reverse` NÃO sobrevive a reboot do emulador.** Precisa re-executar
após cada reinício do emulador ou do host.

**Sessão atual (2026-06-26):** `adb reverse tcp:8096` já configurado. Ao encerrar,
executar `adb reverse --remove-all` para limpar.

#### Passo 3: Usar `127.0.0.1` no app

No diálogo Jellyfin Settings do app, usar:
```
Server URL: http://127.0.0.1:8096
Username:   igor
Password:   2803
```

**NÃO usar `192.168.0.73`** — o emulador não alcança esse IP diretamente.

#### Checklist de teste Jellyfin via emulador

```
[ ] Passo 1: netsh portproxy add (PowerShell Admin, uma vez)
[ ] Passo 2: adb reverse tcp:8096 tcp:8096 (após cada reboot do emulador)
[ ] Passo 3: App → aba Jellyfin → Jellyfin Settings → URL: 127.0.0.1:8096
[ ] Connect deve funcionar → mostrar bibliotecas Jellyfin
[ ] Navegar bibliotecas, dar play em filme/episódio
[ ] Testar track selector, legendas WebVTT
[ ] Ao encerrar sessão: adb reverse --remove-all
```

#### Teste direto (sem UI) — Jellyfin package

```bash
cd packages/server_jellyfin
export JELLYFIN_URL="http://192.168.0.73:8096"
export JELLYFIN_USERNAME="igor"
export JELLYFIN_PASSWORD="2803"
dart run test/jellyfin_live_test.dart
```

### ⚠️ Player media_kit — Guard contra `completed` prematuro (2026-06-26)

**Problema:** No emulador, `player.stream.completed` do media_kit dispara imediatamente
ao abrir um stream (codec não suportado em S/W rendering). Isso setava `_isEnded = true`,
causando: ícone replay no centro, barra de progresso no fim, legendas não carregam.

**Solução:** `UniversalPlayerController.mediaKit()` usa flag `engineConfirmed`:
- Só aceita `_isEnded = true` se `engineConfirmed == true` (posição > 0 ou duração > 0)
- Só aceita `_isPlaying = false` se `engineConfirmed || playing == true`
- Inicializa `_isPlaying = true` (não lê `player.state.playing` que pode estar false)

### Google Cast TV — mDNS + CastV2 + CORS Proxy (2026-06-26)

**Problema:** `DeviceDiscovery` só usava SSDP (porta 1900), que apenas Chromecast gen 1
responde. Chromecast gen 2/3/Ultra/Google TV usam mDNS (`_googlecast._tcp.local`, porta 5353).

**Solução implementada (in-house, zero dependências externas):**

```
lib/cast/
├── chromecast_discovery.dart   # mDNS PTR query → parse TXT/SRV records
├── castv2_protocol.dart        # TLS:8009 → protobuf CastMessage → LAUNCH/LOAD/PLAY/SEEK
├── cast_cors_proxy.dart        # HTTP proxy local → injeta Access-Control-Allow-Origin: *
├── chromecast_controller.dart  # implements CastSession → MiningModePage compat
├── device_discovery.dart       # atualizado: mDNS + SSDP + Jellyfin (3 métodos)
├── cast_models.dart            # DiscoveredDevice ganhou isChromecast + port
└── device_picker.dart          # badge "Chromecast" no UI
```

**Fluxo:** Discover (mDNS `_googlecast._tcp.local`) → CORS Proxy (stream Jellyfin) →
CastV2 connect (TLS:8009) → LAUNCH CC1AD845 → LOAD media → Polling position →
MiningModePage sincroniza legendas.

**Dependências:** Nenhuma. Tudo implementado com `dart:io` (`RawDatagramSocket`,
`SecureSocket`, `HttpServer`). `dart_cast` removido do pubspec (não resolvia).

### MCP Server adb-mcp (tools/adb-mcp/server.py)
MCP server Python que expõe ferramentas adb + agent-device via stdio.
Registrado em `.mcp.json`. Precisa aprovar na primeira execução.

**Tools disponíveis:**
| Tool | Descrição |
|------|-----------|
| `screenshot` | Screenshot base64 PNG |
| `ui_tree` | Hierarquia UI (XML) |
| `snapshot` | Elementos interativos via agent-device (IDs como @e5) |
| `tap` | Toque por coordenadas (x, y) |
| `tap_element` | Toque por ID do agent-device (@e5) |
| `fill_field` | Preencher campo por ID |
| `swipe` | Deslizar na tela |
| `input_text` | Digitar texto |
| `key_event` | Evento de tecla (BACK=4, ENTER=66, etc.) |
| `logcat` | Logs filtrados |
| `shell` | Comando shell arbitrário |
| `list_devices` | Listar dispositivos |
| `launch_app` | Iniciar app |
| `open_app` | Abrir app via agent-device |
| `force_stop` | Forçar parada |
