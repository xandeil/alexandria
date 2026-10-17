#!/usr/bin/env bash
# Cria a CHAVE DE PUBLICAÇÃO (release) do Alexandria — uma vez na vida do app.
# Uso:  bash tools/criar_chave_release.sh [destino.keystore] [alias]
#
# REGRAS: a chave fica FORA do projeto (o script recusa criar dentro dele); o
# keytool pergunta a senha na hora (ela não fica no comando nem no histórico);
# sem esta chave você NÃO publica atualizações — faça 2 cópias de segurança.
set -euo pipefail
PROJETO="$(cd "$(dirname "$0")/.." && pwd)"
DESTINO="${1:-$HOME/chaves-android/alexandria-release.keystore}"
ALIAS="${2:-alexandria}"
mkdir -p "$(dirname "$DESTINO")"
DESTINO="$(cd "$(dirname "$DESTINO")" && pwd)/$(basename "$DESTINO")"

case "$DESTINO" in
  "$PROJETO"/*) echo "ERRO: a chave de publicação NÃO pode ficar dentro do projeto ($PROJETO)."; exit 1 ;;
esac
[ -e "$DESTINO" ] && { echo "ERRO: já existe uma chave em $DESTINO. Não sobrescrevo chave nenhuma."; exit 1; }
KEYTOOL="${JAVA_HOME:+$JAVA_HOME/bin/}keytool"
command -v "$KEYTOOL" >/dev/null 2>&1 || { echo "ERRO: keytool não encontrado (defina JAVA_HOME). Veja o BUILD.md."; exit 1; }

echo "Criando a chave em: $DESTINO (alias '$ALIAS')"
echo "O keytool vai pedir uma SENHA (mínimo 6 caracteres) e alguns dados."
"$KEYTOOL" -genkeypair -v -keystore "$DESTINO" -alias "$ALIAS" -keyalg RSA -keysize 2048 -validity 10000
echo
echo "Pronto. SHA-256 (a Play Console pode pedir):"
"$KEYTOOL" -list -v -keystore "$DESTINO" -alias "$ALIAS" | grep -i "SHA256" || true
echo
echo "AGORA: faça 2 cópias de segurança deste arquivo e guarde a senha."
echo "Para compilar: CHAVE=\"$DESTINO\" ALIAS=$ALIAS bash build_release.sh"
