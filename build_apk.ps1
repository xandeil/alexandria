<#
  Compila o APK de depuracao do Alexandria (Windows).

  Uso:
    powershell -ExecutionPolicy Bypass -File .\build_apk.ps1
    powershell -ExecutionPolicy Bypass -File .\build_apk.ps1 -Install
    powershell -ExecutionPolicy Bypass -File .\build_apk.ps1 -Godot "D:\Godot\Godot_v4.7.2-stable_win64_console.exe"

  Antes, siga o BUILD.md uma vez (Godot, modelos, Java 17, Android SDK).
#>
param(
    [string]$Godot = "C:\gamedev\godot\Godot_v4.7.2-stable_win64_console.exe",
    [switch]$Install
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Fail([string]$message) {
    Write-Host "ERRO: $message" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $Godot)) { Fail "Godot nao encontrado em '$Godot'. Use -Godot <caminho do _console.exe>." }

# Variaveis gravadas no usuario (setx/SetEnvironmentVariable) valem para terminais NOVOS;
# lemos daqui tambem para funcionar no mesmo terminal.
if (-not $env:JAVA_HOME) { $env:JAVA_HOME = [Environment]::GetEnvironmentVariable("JAVA_HOME", "User") }
if (-not $env:ANDROID_HOME) { $env:ANDROID_HOME = [Environment]::GetEnvironmentVariable("ANDROID_HOME", "User") }
if (-not $env:ANDROID_HOME) { $env:ANDROID_HOME = Join-Path $env:LOCALAPPDATA "Android\Sdk" }

if (-not $env:JAVA_HOME -or -not (Test-Path (Join-Path $env:JAVA_HOME "bin\java.exe"))) {
    Fail "JAVA_HOME invalido ('$env:JAVA_HOME'). Instale o JDK 17 (passo 3 do BUILD.md)."
}
if (-not (Test-Path (Join-Path $env:ANDROID_HOME "platform-tools\adb.exe"))) {
    Fail "Android SDK sem platform-tools em '$env:ANDROID_HOME' (passo 4 do BUILD.md)."
}
$template = Join-Path $env:APPDATA "Godot\export_templates\4.7.2.stable\android_debug.apk"
if (-not (Test-Path $template)) { Fail "Modelos de exportacao 4.7.2 nao instalados (esperado: $template)." }

# Chave de depuracao DO PROJETO (keystore\debug.keystore): todo APK de teste sai
# assinado com a MESMA chave - o seu, o meu, o de qualquer maquina. Assim um
# instala por cima do outro sem desinstalar (e sem perder o save).
$projectKey = Join-Path $PSScriptRoot "keystore\debug.keystore"
if ((Test-Path $projectKey) -and -not $env:GODOT_ANDROID_KEYSTORE_DEBUG_PATH) {
    $env:GODOT_ANDROID_KEYSTORE_DEBUG_PATH = $projectKey
    $env:GODOT_ANDROID_KEYSTORE_DEBUG_USER = "androiddebugkey"
    $env:GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD = "android"
}

Write-Host "1/3 Importando o projeto (a primeira vez demora um pouco)..." -ForegroundColor Cyan
& $Godot --headless --path . --import
New-Item -ItemType Directory -Force "build" | Out-Null
if (Test-Path "build\alexandria.apk") { Remove-Item "build\alexandria.apk" -Force }

Write-Host "2/3 Exportando o APK..." -ForegroundColor Cyan
& $Godot --headless --path . --export-debug "Android" "build\alexandria.apk"
if (-not (Test-Path "build\alexandria.apk")) { Fail "O APK nao foi gerado. Leia as mensagens acima (e a tabela de problemas do BUILD.md)." }

$size = [math]::Round((Get-Item "build\alexandria.apk").Length / 1MB, 1)
Write-Host "3/3 Pronto: build\alexandria.apk ($size MB)" -ForegroundColor Green

if ($Install) {
    Write-Host "Instalando no celular conectado (Depuracao USB ligada)..." -ForegroundColor Cyan
    & (Join-Path $env:ANDROID_HOME "platform-tools\adb.exe") install -r "build\alexandria.apk"
}
