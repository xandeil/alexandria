#!/usr/bin/env bash
# Compila o APK de depuração do Alexandria (Linux/macOS).
# Uso:  GODOT=/caminho/do/godot bash build_apk.sh [--install]
# Antes, siga o BUILD.md uma vez (Godot, modelos, Java 17, Android SDK).
set -euo pipefail
cd "$(dirname "$0")"

GODOT="${GODOT:-godot}"
: "${JAVA_HOME:?Defina JAVA_HOME (JDK 17). Veja o BUILD.md}"
: "${ANDROID_HOME:?Defina ANDROID_HOME (Android SDK). Veja o BUILD.md}"

command -v "$GODOT" >/dev/null 2>&1 || [ -x "$GODOT" ] || { echo "ERRO: Godot não encontrado ($GODOT)"; exit 1; }
[ -x "$JAVA_HOME/bin/java" ] || { echo "ERRO: JAVA_HOME inválido: $JAVA_HOME"; exit 1; }
[ -e "$ANDROID_HOME/platform-tools/adb" ] || { echo "ERRO: falta platform-tools em $ANDROID_HOME"; exit 1; }

# Chave de depuração DO PROJETO (keystore/debug.keystore): todo APK de teste sai
# assinado com a MESMA chave — o seu, o meu, o de qualquer máquina. Assim um
# instala por cima do outro sem desinstalar (e sem perder o save).
if [ -f keystore/debug.keystore ] && [ -z "${GODOT_ANDROID_KEYSTORE_DEBUG_PATH:-}" ]; then
  export GODOT_ANDROID_KEYSTORE_DEBUG_PATH="$PWD/keystore/debug.keystore"
  export GODOT_ANDROID_KEYSTORE_DEBUG_USER="androiddebugkey"
  export GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD="android"
fi

echo "1/3 Importando o projeto..."
"$GODOT" --headless --path . --import
mkdir -p build
rm -f build/alexandria.apk

echo "2/3 Exportando o APK..."
"$GODOT" --headless --path . --export-debug "Android" build/alexandria.apk
[ -f build/alexandria.apk ] || { echo "ERRO: o APK não foi gerado (veja as mensagens acima)"; exit 1; }
echo "3/3 Pronto: build/alexandria.apk ($(du -h build/alexandria.apk | cut -f1))"

if [ "${1:-}" = "--install" ]; then
  "$ANDROID_HOME/platform-tools/adb" install -r build/alexandria.apk
fi
