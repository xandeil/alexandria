# Como gerar o APK do Alexandria

Versão usada e testada: **Godot 4.7.2** (Standard, não a versão .NET). O APK
deste projeto foi gerado exatamente com estes passos, pela linha de comando.

Você vai instalar 4 coisas (só na primeira vez):

| O quê | Para quê | Tamanho |
|---|---|---|
| Godot 4.7.2 | o motor e o editor | ~80 MB |
| Modelos de exportação 4.7.2 | o "esqueleto" do APK para Android | ~1,3 GB |
| OpenJDK 17 | assinar o APK (keytool/apksigner) | ~190 MB |
| Android SDK (linha de comando) | `adb` e `apksigner` | ~400 MB |

> **Regra de ouro:** defina `JAVA_HOME` e `ANDROID_HOME` **antes** de abrir o
> Godot pela primeira vez. Assim ele acha o Java e o SDK sozinho.

> **Chave de depuração do projeto:** os scripts `build_apk.ps1`/`build_apk.sh`
> assinam com `keystore/debug.keystore`, que vem dentro do projeto. Todo APK de
> teste — o meu e o seu — sai com a mesma assinatura e instala **por cima** do
> anterior, sem desinstalar e sem perder o save. Por que isso é seguro (e por
> que a chave de *publicação* nunca entra no projeto): `keystore/LEIA-ME.md`.

---

## Windows (PowerShell)

Abra o **PowerShell** (não precisa ser administrador) e rode bloco por bloco.

### 1) Pasta de ferramentas + Godot 4.7.2

```powershell
New-Item -ItemType Directory -Force C:\gamedev | Out-Null
Set-Location C:\gamedev
curl.exe -L -o godot.zip https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_win64.exe.zip
Expand-Archive godot.zip -DestinationPath C:\gamedev\godot -Force
```

O executável para terminal é `C:\gamedev\godot\Godot_v4.7.2-stable_win64_console.exe`
(o `_console` mostra as mensagens no PowerShell; o outro abre o editor).

### 2) Modelos de exportação (Android)

```powershell
curl.exe -L -o templates.tpz https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz
tar -xf templates.tpz
$TPL = "$env:APPDATA\Godot\export_templates\4.7.2.stable"
New-Item -ItemType Directory -Force $TPL | Out-Null
Move-Item templates\* $TPL -Force
```

(O `.tpz` é um `.zip` com outro nome; o `tar` do Windows 10/11 abre direto.
Alternativa sem terminal: abrir o editor → *Editor → Gerenciar Modelos de
Exportação → Baixar e Instalar*.)

### 3) Java 17

```powershell
winget install --id EclipseAdoptium.Temurin.17.JDK -e
```

**Feche e abra o PowerShell** e grave o `JAVA_HOME`:

```powershell
$env:JAVA_HOME = (Get-ChildItem "C:\Program Files\Eclipse Adoptium" -Directory | Where-Object Name -like "jdk-17*" | Select-Object -First 1).FullName
[Environment]::SetEnvironmentVariable("JAVA_HOME", $env:JAVA_HOME, "User")
& "$env:JAVA_HOME\bin\java.exe" -version
```

### 4) Android SDK (só as ferramentas de linha de comando)

```powershell
$SDK = "$env:LOCALAPPDATA\Android\Sdk"
curl.exe -L -o cmdtools.zip https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip
Expand-Archive cmdtools.zip -DestinationPath "$SDK\tmp" -Force
New-Item -ItemType Directory -Force "$SDK\cmdline-tools" | Out-Null
Move-Item "$SDK\tmp\cmdline-tools" "$SDK\cmdline-tools\latest" -Force
$env:ANDROID_HOME = $SDK
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $SDK, "User")
& "$SDK\cmdline-tools\latest\bin\sdkmanager.bat" --licenses
& "$SDK\cmdline-tools\latest\bin\sdkmanager.bat" "platform-tools" "build-tools;35.0.1" "platforms;android-35"
```

No `--licenses`, responda `y` em cada licença. (Se o link do `cmdtools.zip`
mudar, baixe o mais novo em developer.android.com/studio → seção
*Command line tools only*; o resto é igual.)

### 5) Compilar o APK

Descompacte o projeto (ex.: `C:\gamedev\alexandria`) e rode:

```powershell
Set-Location C:\gamedev\alexandria
$GODOT = "C:\gamedev\godot\Godot_v4.7.2-stable_win64_console.exe"
& $GODOT --headless --path . --import
New-Item -ItemType Directory -Force build | Out-Null
& $GODOT --headless --path . --export-debug "Android" build\alexandria.apk
```

Pronto: `build\alexandria.apk`. Nas próximas vezes basta:

```powershell
powershell -ExecutionPolicy Bypass -File .\build_apk.ps1
```

---

## Linux (Ubuntu/Debian)

```bash
mkdir -p ~/gamedev && cd ~/gamedev
# Godot
curl -L -o godot.zip https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip
unzip -o godot.zip && chmod +x Godot_v4.7.2-stable_linux.x86_64
# Modelos de exportação (só os de Android)
curl -L -o templates.tpz https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz
mkdir -p ~/.local/share/godot/export_templates/4.7.2.stable
unzip -o -j templates.tpz "templates/android_*" "templates/version.txt" -d ~/.local/share/godot/export_templates/4.7.2.stable
# Java 17
sudo apt install -y openjdk-17-jdk-headless unzip
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
# Android SDK (NÃO use o android-sdk do apt: é antigo)
export ANDROID_HOME=~/Android/Sdk
curl -L -o cmdtools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
mkdir -p $ANDROID_HOME/cmdline-tools && unzip -o cmdtools.zip -d $ANDROID_HOME/cmdline-tools
mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest
yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platform-tools" "build-tools;35.0.1" "platforms;android-35"
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
echo 'export ANDROID_HOME=~/Android/Sdk' >> ~/.bashrc
# Compilar
cd ~/gamedev/alexandria
GODOT=~/gamedev/Godot_v4.7.2-stable_linux.x86_64 bash build_apk.sh
```

## macOS

```bash
mkdir -p ~/gamedev && cd ~/gamedev
curl -L -o godot.zip https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_macos.universal.zip
unzip -o godot.zip    # gera Godot.app
curl -L -o templates.tpz https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz
mkdir -p ~/Library/Application\ Support/Godot/export_templates/4.7.2.stable
unzip -o -j templates.tpz "templates/android_*" "templates/version.txt" -d ~/Library/Application\ Support/Godot/export_templates/4.7.2.stable
brew install --cask temurin@17
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export ANDROID_HOME=~/Library/Android/sdk
curl -L -o cmdtools.zip https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip
mkdir -p $ANDROID_HOME/cmdline-tools && unzip -o cmdtools.zip -d $ANDROID_HOME/cmdline-tools
mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest
yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platform-tools" "build-tools;35.0.1" "platforms;android-35"
cd ~/gamedev/alexandria
GODOT=~/gamedev/Godot.app/Contents/MacOS/Godot bash build_apk.sh
```

---

## Instalar no celular

**Sem cabo:** mande o `alexandria.apk` para o celular (Drive, WhatsApp "para
mim", cabo USB como pendrive), toque nele e permita *Instalar apps
desconhecidos* quando o Android pedir.

**Com cabo (mais rápido para testar):** no celular, *Configurações → Sobre o
telefone →* toque 7 vezes em *Número da versão*; depois ative *Opções do
desenvolvedor → Depuração USB*. Então:

```powershell
& "$env:ANDROID_HOME\platform-tools\adb.exe" install -r build\alexandria.apk
```

(No Linux/macOS: `$ANDROID_HOME/platform-tools/adb install -r build/alexandria.apk`.)

---

## Problemas comuns

| Mensagem | Solução |
|---|---|
| `A valid Java SDK path is required` / `Android SDK path` | O Godot já tinha sido aberto antes de você criar as variáveis. Abra o editor → *Editor → Configurações do Editor → Exportar → Android* e preencha **Java SDK Path** (`JAVA_HOME`) e **Android SDK Path** (`ANDROID_HOME`). |
| `Could not find debug keystore` | Use os scripts de build (eles apontam para `keystore/debug.keystore`). Exportando pelo editor: *Editor → Configurações do Editor → Exportar → Android → Debug Keystore* = esse arquivo, usuário `androiddebugkey`, senha `android`. |
| `Target folder does not exist` | Crie a pasta `build` antes de exportar (`New-Item -ItemType Directory build`). |
| `No export template found` | Os modelos têm que estar em `...\export_templates\4.7.2.stable\` (com `android_debug.apk` dentro) — confira o nome da pasta. |
| "App não instalado" no celular | Já existe um Alexandria assinado com OUTRA chave. A partir da 0.5.0 todos os APKs de teste usam a chave do projeto; a 0.4.0 e anteriores usavam outra — desinstale a antiga uma vez (o save vai junto) e instale de novo. |
| Celular muito antigo (32 bits) | O preset já exporta `armeabi-v7a` e `arm64-v8a`. Para um APK menor só para celulares novos, desmarque `armeabi-v7a` em `export_presets.cfg`. |
| Jogo lento ou esquentando no celular | Troque o modo de esticar a tela para `viewport` (veja "Desempenho em celular fraco" no README): o jogo passa a ser desenhado em 480×270 e só ampliado. |

## Versão para navegador (itch.io)

O jogo também roda no navegador (Chrome, Edge, Firefox), sem instalar nada.

1. Instale os modelos de exportação **Web** da mesma versão do Godot (4.7.2):
   no editor, *Editor → Gerenciar modelos de exportação → Baixar*. (São os
   mesmos do Android; se já baixou para o APK, já estão lá.)
2. Gere a versão:
   - Linux/macOS: `bash build_web.sh` (ou `bash build_web.sh --testar` para
     jogar em http://localhost:8060 antes de publicar);
   - no editor: *Projeto → Exportar → Web → Exportar projeto* para `build/web/index.html`.
3. O arquivo para o itch.io é `build/alexandria-web.zip` (o `index.html` fica
   na raiz do zip — o itch.io exige assim).

Detalhes técnicos (por que está configurado assim):
- **Sem threads** (`variant/thread_support=false`): roda em qualquer site,
  sem precisar dos cabeçalhos especiais (COOP/COEP) que a versão com threads
  exige. O jogo não usa threads, então não perde nada.
- **Som em modo "Stream"** (`audio/general/default_playback_type.web=0` no
  `project.godot`): por padrão o Godot toca os efeitos na Web em modo
  "Sample" (direto pelo navegador), e nesse modo os barramentos que o jogo
  cria por código ("Efeitos" e "Ambiente") ficavam mudos — só o vídeo, que
  já passa pelo mixer, tinha som (bug da v0.30.1). Em "Stream" tudo passa
  pelo mixer do Godot, igual ao celular e ao PC.
- **Gráficos "Leve" por padrão no navegador** (Opções → Gráficos): o jogo
  desenha na resolução dele (480x270) e só amplia a imagem pronta. No modo
  "Nítido" ele pinta cada pixel da tela (Full HD = 16x mais pixels); medido
  aqui, o Leve deixou o quadro ~4x mais barato. Era o "lag absurdo" fora do
  Teatro (a Cidade tem mais luzes, inimigos e efeitos).
- O **save** fica guardado no próprio navegador (IndexedDB). Limpar os dados
  do site apaga o save.
- Abrir o `index.html` direto do disco (duplo clique) **não funciona**: o
  navegador bloqueia. Precisa de um servidor (o `--testar` faz isso) ou do itch.io.

## Versão "release" (para publicar)

O APK de depuração serve para testar. Para a Play Store você precisa de uma
**chave de publicação sua** — e ela tem regras:

- **Fica FORA da pasta do projeto.** Nunca no Git, nunca no zip do projeto. (O
  teste `test_release_secrets_stay_out` falha se aparecer qualquer chave que não seja
  `keystore/debug.keystore` dentro do projeto.)
- **A senha não fica escrita em lugar nenhum** — nem no comando, nem em arquivo.
  Os scripts perguntam na hora e apagam do ambiente ao terminar.
- **Sem ela você não publica atualizações.** Faça 2 cópias de segurança (pendrive +
  nuvem pessoal criptografada) e guarde a senha num gerenciador de senhas.

### 1) Criar a chave (uma vez na vida do app)

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\criar_chave_release.ps1
# cria em %USERPROFILE%\chaves-android\alexandria-release.keystore (o script recusa dentro do projeto)
```
Linux/macOS: `bash tools/criar_chave_release.sh`

### 2) Compilar o APK e o AAB de publicação

```powershell
powershell -ExecutionPolicy Bypass -File .\build_release.ps1 -Chave "$env:USERPROFILE\chaves-android\alexandria-release.keystore" -Aab
```
Linux/macOS: `CHAVE=~/chaves-android/alexandria-release.keystore bash build_release.sh --aab`

- `build/alexandria-release.apk`: instale no celular e jogue antes de enviar.
- `build/alexandria.aab`: é o que vai para a Play Console.
- O AAB usa o **Gradle build** do Godot. Na primeira vez o script instala o modelo
  de build Android na pasta `android/` (fica fora do Git) — isso exige o Android SDK
  completo (com `build-tools` e `platforms`) e baixa o Gradle, então leva alguns
  minutos. Se der erro de SDK, abra o projeto no editor do Godot uma vez
  (Projeto → Instalar modelo de build Android) e rode de novo.

### 3) Loja

Textos, ícone 512, imagem de destaque, capturas, classificação indicativa e a
política de privacidade estão em `docs/loja/` (leia o `LEIA-ME.md` de lá — tem um
checklist final).

> **Play App Signing:** na primeira publicação, a Play Console oferece guardar a
> chave de assinatura final no Google. Aceite: a sua chave vira a "chave de upload"
> e, se um dia você a perder, dá para pedir uma nova ao suporte.
