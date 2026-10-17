#!/usr/bin/env bash
# Compila a versão de PUBLICAÇÃO do Alexandria: APK assinado e, com --aab, o AAB da Play Store.
# Uso:  CHAVE=~/chaves-android/alexandria-release.keystore ALIAS=alexandria bash build_release.sh [--aab]
# A senha é perguntada na hora (não fica em arquivo nenhum). Crie a chave antes:
#   bash tools/criar_chave_release.sh
set -euo pipefail
cd "$(dirname "$0")"
GODOT="${GODOT:-godot}"
: "${CHAVE:?Defina CHAVE (caminho da chave de publicação, FORA do projeto)}"
ALIAS="${ALIAS:-alexandria}"
: "${JAVA_HOME:?Defina JAVA_HOME (JDK 17). Veja o BUILD.md}"
: "${ANDROID_HOME:?Defina ANDROID_HOME (Android SDK). Veja o BUILD.md}"
[ -f "$CHAVE" ] || { echo "ERRO: chave não encontrada: $CHAVE"; exit 1; }
case "$(cd "$(dirname "$CHAVE")" && pwd)/" in
  "$PWD"/*) echo "ERRO: a chave de publicação está DENTRO do projeto. Mova para fora."; exit 1 ;;
esac
read -r -s -p "Senha da chave '$ALIAS': " SENHA; echo
export GODOT_ANDROID_KEYSTORE_RELEASE_PATH="$CHAVE"
export GODOT_ANDROID_KEYSTORE_RELEASE_USER="$ALIAS"
export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD="$SENHA"
mkdir -p build
"$GODOT" --headless --path . --import
echo "Exportando o APK de publicação..."
"$GODOT" --headless --path . --export-release "Android" build/alexandria-release.apk
echo "Pronto: build/alexandria-release.apk"
if [ "${1:-}" = "--aab" ]; then
  # O AAB precisa do "Gradle build": o modelo de build Android fica em android/ (fora do Git).
  [ -d android/build ] || "$GODOT" --headless --path . --install-android-build-template
  echo "Exportando o AAB (Play Store)..."
  "$GODOT" --headless --path . --export-release "Android AAB" build/alexandria.aab
  echo "Pronto: build/alexandria.aab"
fi
unset GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD SENHA
