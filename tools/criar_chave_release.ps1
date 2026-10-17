<#
  Cria a CHAVE DE PUBLICACAO (release) do Alexandria — uma vez na vida do app.

  Uso:
    powershell -ExecutionPolicy Bypass -File .\tools\criar_chave_release.ps1
    powershell -ExecutionPolicy Bypass -File .\tools\criar_chave_release.ps1 -Destino "D:\cofre\alexandria-release.keystore"

  REGRAS (leia):
  - A chave fica FORA da pasta do projeto (o script se recusa a criar dentro dela).
    Assim ela nunca vai parar no Git, num zip do projeto ou num print de tela.
  - O keytool pergunta a senha na hora: ela nao aparece no comando nem no historico.
  - Sem esta chave voce NAO consegue publicar atualizacoes do app. Faca 2 copias de
    seguranca (pendrive + nuvem pessoal criptografada) e anote a senha num lugar seguro.
#>
param(
    [string]$Destino = (Join-Path $env:USERPROFILE "chaves-android\alexandria-release.keystore"),
    [string]$Alias = "alexandria"
)
$ErrorActionPreference = "Stop"
$projeto = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$destinoCompleto = [System.IO.Path]::GetFullPath($Destino)

if ($destinoCompleto.StartsWith($projeto, [System.StringComparison]::OrdinalIgnoreCase)) {
    Write-Host "ERRO: a chave de publicacao NAO pode ficar dentro do projeto ($projeto)." -ForegroundColor Red
    Write-Host "      Escolha outra pasta com -Destino." -ForegroundColor Red
    exit 1
}
if (Test-Path $destinoCompleto) {
    Write-Host "ERRO: ja existe uma chave em $destinoCompleto. Nao sobrescrevo chave nenhuma." -ForegroundColor Red
    exit 1
}
if (-not $env:JAVA_HOME) { $env:JAVA_HOME = [Environment]::GetEnvironmentVariable("JAVA_HOME", "User") }
$keytool = Join-Path $env:JAVA_HOME "bin\keytool.exe"
if (-not (Test-Path $keytool)) { Write-Host "ERRO: keytool nao encontrado (JAVA_HOME = '$env:JAVA_HOME'). Veja o BUILD.md." -ForegroundColor Red; exit 1 }

New-Item -ItemType Directory -Force -Path (Split-Path $destinoCompleto) | Out-Null
Write-Host "Criando a chave em: $destinoCompleto (alias '$Alias')"
Write-Host "O keytool vai pedir uma SENHA (minimo 6 caracteres) e alguns dados (nome, cidade...)."
& $keytool -genkeypair -v -keystore $destinoCompleto -alias $Alias -keyalg RSA -keysize 2048 -validity 10000
if ($LASTEXITCODE -ne 0) { Write-Host "ERRO: o keytool falhou." -ForegroundColor Red; exit 1 }

Write-Host ""
Write-Host "Pronto. Impressao digital (SHA-256) — a Play Console pode pedir:" -ForegroundColor Green
& $keytool -list -v -keystore $destinoCompleto -alias $Alias | Select-String "SHA256"
Write-Host ""
Write-Host "AGORA: faca 2 copias de seguranca deste arquivo e guarde a senha." -ForegroundColor Yellow
Write-Host "Para compilar: .\build_release.ps1 -Chave `"$destinoCompleto`" -Alias $Alias"
