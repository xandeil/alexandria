"""Etapa 9 (v0.47): o Tito, filho do Galeno.

Mesma criança do prólogo (crianca_a.png), com UM olho ainda castanho: ele
morreu menos vezes que as outras. Em cada quadro, os pixels brancos do olho
da esquerda viram castanho.

  • assets/sprites/tito.png (+ tito_frames.tres, gerado pelo mesmo .tres da criança)

Rode:  python3 tools/art/tito_etapa9.py
"""
from __future__ import annotations

import os

from PIL import Image

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
SPRITES = os.path.join(ROOT, "assets", "sprites")
BROWN = (120, 72, 40, 255)
FRAME = 24


def main() -> None:
    sheet = Image.open(os.path.join(SPRITES, "crianca_a.png")).convert("RGBA")
    pixels = sheet.load()
    for frame in range(sheet.width // FRAME):
        whites = [(x, y) for x in range(frame * FRAME, frame * FRAME + FRAME) for y in range(FRAME)
                  if pixels[x, y][3] > 0 and sum(pixels[x, y][:3]) > 660]
        if not whites:
            continue
        xs = sorted({x for x, _ in whites})
        # Os dois olhos são blocos separados por uma coluna sem branco: o 1º bloco é o da esquerda.
        left = [xs[0]]
        for x in xs[1:]:
            if x == left[-1] + 1:
                left.append(x)
            else:
                break
        for x, y in whites:
            if x in left:
                pixels[x, y] = BROWN
    sheet.save(os.path.join(SPRITES, "tito.png"))
    frames = open(os.path.join(SPRITES, "crianca_a_frames.tres"), encoding="utf-8").read()
    open(os.path.join(SPRITES, "tito_frames.tres"), "w", encoding="utf-8").write(
        frames.replace("res://assets/sprites/crianca_a.png", "res://assets/sprites/tito.png"))


if __name__ == "__main__":
    main()
