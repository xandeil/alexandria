#!/usr/bin/env bash
# Gera a versão para NAVEGADOR do Alexandria (Linux/macOS) e o .zip para o itch.io.
# Uso:  GODOT=/caminho/do/godot bash build_web.sh [--testar]
# Precisa dos modelos de exportação "Web" do Godot (veja o BUILD.md).
# --testar: abre um servidor em http://localhost:8060 para jogar no navegador.
set -euo pipefail
cd "$(dirname "$0")"

GODOT="${GODOT:-godot}"
command -v "$GODOT" >/dev/null 2>&1 || [ -x "$GODOT" ] || { echo "ERRO: Godot não encontrado ($GODOT)"; exit 1; }

echo "1/3 Importando o projeto..."
"$GODOT" --headless --path . --import
rm -rf build/web build/alexandria-web.zip
mkdir -p build/web

echo "2/3 Exportando para o navegador..."
"$GODOT" --headless --path . --export-release "Web" build/web/index.html

echo "3/3 Empacotando para o itch.io (index.html na raiz do zip)..."
(cd build/web && zip -q -9 -r ../alexandria-web.zip .)
echo "Pronto: build/alexandria-web.zip"

if [ "${1:-}" = "--testar" ]; then
  echo "Abra http://localhost:8060 no navegador (Ctrl+C para parar)."
  cd build/web && python3 -m http.server 8060
fi
