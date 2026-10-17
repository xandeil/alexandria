<#
  Compila a versao de PUBLICACAO do Alexandria: APK assinado e, com -Aab, o AAB da Play Store.

  Uso:
    powershell -ExecutionPolicy Bypass -File .\build_release.ps1 -Chave "C:\Users\voce\chaves-android\alexandria-release.keystore"
    powershell -ExecutionPolicy Bypass -File .\build_release.ps1 -Chave "..." -Aab

  A senha e perguntada na hora (nao fica em arquivo nenhum). Crie a chave antes:
    powershell -ExecutionPolicy Bypass -File .\tools\criar_chave_release.ps1
#>
param(
    [Parameter(Mandatory = $true)][string]$Chave,
    [string]$Alias = "alexandria",
    [string]$Godot = "C:\gamedev\godot\Godot_v4.7.2-stable_win64_console.exe",
    [switch]$Aab
)
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
function Fail([string]$message) { Write-Host "ERRO: $message" -ForegroundColor Red; exit 1 }

if (-not (Test-Path $Godot)) { Fail "Godot nao encontrado em '$Godot'. Use -Godot <caminho do _console.exe>." }
if (-not (Test-Path $Chave)) { Fail "Chave nao encontrada: $Chave" }
$chaveCompleta = (Resolve-Path $Chave).Path
if ($chaveCompleta.StartsWith($PSScriptRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    Fail "A chave de publicacao esta DENTRO do projeto. Mova para fora (ex.: $env:USERPROFILE\chaves-android)."
}
if (-not $env:JAVA_HOME) { $env:JAVA_HOME = [Environment]::GetEnvironmentVariable("JAVA_HOME", "User") }
if (-not $env:ANDROID_HOME) { $env:ANDROID_HOME = [Environment]::GetEnvironmentVariable("ANDROID_HOME", "User") }
if (-not $env:ANDROID_HOME) { $env:ANDROID_HOME = Join-Path $env:LOCALAPPDATA "Android\Sdk" }

$segura = Read-Host "Senha da chave '$Alias'" -AsSecureString
$senha = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($segura))
$env:GODOT_ANDROID_KEYSTORE_RELEASE_PATH = $chaveCompleta
$env:GODOT_ANDROID_KEYSTORE_RELEASE_USER = $Alias
$env:GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD = $senha
try {
    New-Item -ItemType Directory -Force -Path build | Out-Null
    & $Godot --headless --path . --import
    Write-Host "Exportando o APK de publicacao..."
    & $Godot --headless --path . --export-release "Android" build\alexandria-release.apk
    if (-not (Test-Path build\alexandria-release.apk)) { Fail "o APK nao foi gerado (veja as mensagens acima)." }
    Write-Host "Pronto: build\alexandria-release.apk" -ForegroundColor Green
    if ($Aab) {
        # O AAB precisa do "Gradle build": o modelo de build Android fica em android\ (fora do Git).
        if (-not (Test-Path android\build)) { & $Godot --headless --path . --install-android-build-template }
        Write-Host "Exportando o AAB (Play Store)..."
        & $Godot --headless --path . --export-release "Android AAB" build\alexandria.aab
        if (-not (Test-Path build\alexandria.aab)) { Fail "o AAB nao foi gerado (veja as mensagens acima)." }
        Write-Host "Pronto: build\alexandria.aab" -ForegroundColor Green
    }
}
finally {
    # A senha some do ambiente ao terminar, deu certo ou nao.
    Remove-Item Env:\GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD -ErrorAction SilentlyContinue
    $senha = $null
}
