"""Etapa 10 (v0.49): o Damião, o Sucateiro, e o que é dele.

  • assets/sprites/damiao_npc.png   — 2 quadros: mochila enorme de tralha, sino de
    lata, lanterna na testa, cachecol remendado e um SACO DE PAPEL PARDO na
    cabeça com furos tortos (esconde os olhos ficando brancos, como a irmã);
  • assets/props/mochila_damiao.png — a mochila largada onde ele morreu;
  • assets/items/meio_pingente.png  — a outra metade do pingente da Lúcia;
  • assets/items/fragmento_de_loja.png — o sino de lata da mochila dele.

Rode:  python3 tools/art/vendedores_etapa10.py
"""
from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from pixel import canvas, from_grid, hstrip, paste  # noqa: E402
import palette as P  # noqa: E402
import aliados_etapa7 as A  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
SPRITES = os.path.join(ROOT, "assets", "sprites")
PROPS = os.path.join(ROOT, "assets", "props")
ITEMS = os.path.join(ROOT, "assets", "items")

KEY = {**A.COMMON, "P": (176, 140, 96), "p": (138, 106, 70), "L": (250, 230, 140), "B": (110, 84, 60),
       "b": (80, 60, 44), "C": (150, 60, 56), "c": (110, 44, 40), "G": (150, 150, 160), "g": (110, 110, 120),
       "Y": (214, 176, 72), "y": (150, 116, 44), "J": (90, 96, 108)}

DAMIAO = [
    ".....PPPPP.......",
    "....PPLLPPP..G...",
    "....PPPPPPP.gBg..",
    "....PKPPPKP.BBBB.",
    "....PPPKKPP.BbBb.",
    "....PpPPPpP.BBBB.",
    "...cCCCCCCc.BgBB.",
    "..JJCcCCcCJJBBBB.",
    "..JJJJJJJJJJBbBB.",
    "..SJJJJJJJJSBBBB.",
    "...JJJJJJJJ.BBBY.",
    "...JJJJJJJJ..bby.",
    "...JJJ..JJJ......",
    "...JJJ..JJJ......",
    "...KKK..KKK......",
]

MOCHILA = [
    "....G.......",
    "...gYg......",
    ".BBBBBBBBB..",
    "BBbBBBBBbBB.",
    "BBBBGBBBBBBB",
    "BbBBBBBbBBBB",
    "BBBBBBBBBBB.",
    ".bbbbbbbbb..",
]

PINGENTE = ["...gg...", "..g..g..", "...YY...", "..YYyY..", ".YYyYY..", ".YyYY...", "..YY....", "...Y...."]
SINO = ["...g....", "..gGg...", ".gGGGg..", ".GGGGG..", "gGGGGGg.", "ggggggg.", "...K...."]


def main() -> None:
    idle = A.pad(DAMIAO)
    frames = [from_grid(g, KEY, outline=P.OUTLINE) for g in (idle, ["." * A.W] + idle[:-1])]
    hstrip(frames).save(os.path.join(SPRITES, "damiao_npc.png"))
    from_grid(MOCHILA, KEY, outline=P.OUTLINE).save(os.path.join(PROPS, "mochila_damiao.png"))
    for name, rows, x, y in [("meio_pingente", PINGENTE, 4, 4), ("fragmento_de_loja", SINO, 4, 4)]:
        icon = canvas(16, 16)
        paste(icon, from_grid(rows, KEY, outline=P.OUTLINE), x, y)
        icon.save(os.path.join(ITEMS, f"{name}.png"))


if __name__ == "__main__":
    main()
