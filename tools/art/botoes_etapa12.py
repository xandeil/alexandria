"""Etapa 12 (v0.53): a Lata de Botões e os botões (ícones 16×16).

Todo botão tem a mesma forma (redondo, 4 furos) e a sua cor; alguns ganham um
detalhe (o ursinho do pijama, o elo da corrente, a escama). A lata é de
biscoito, azul, com a tampa amassada.
Rode:  python3 tools/art/botoes_etapa12.py
"""
from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from pixel import canvas, from_grid, paste  # noqa: E402
import palette as P  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
ITEMS = os.path.join(ROOT, "assets", "items")

BUTTON = [
    "..oooo..",
    ".oAAAAo.",
    "oAAaAaAo",
    "oAAAAAAo",
    "oAAaAaAo",
    ".oAAAAo.",
    "..oooo..",
]
COLORS = {
    "botao_pijama": ((170, 200, 240), (110, 140, 190)),
    "botao_jaleco": ((240, 240, 236), (180, 180, 176)),
    "botao_farda": ((110, 120, 80), (70, 80, 50)),
    "botao_corneteiro": ((230, 190, 80), (170, 130, 40)),
    "botao_bombeiro": ((60, 56, 52), (30, 28, 26)),
    "botao_musgo": ((110, 150, 80), (70, 100, 50)),
    "botao_sino": ((200, 170, 90), (150, 120, 60)),
    "botao_tunica_azul": ((70, 100, 190), (40, 64, 140)),
    "botao_romeira": ((150, 150, 160), (100, 100, 110)),
    "botao_bronze": ((190, 130, 70), (130, 84, 44)),
    "botao_engrenagem": ((170, 170, 180), (110, 110, 120)),
    "botao_avental": ((230, 220, 180), (170, 150, 110)),
    "botao_cerzido": ((160, 110, 90), (110, 70, 56)),
    "botao_escama": ((200, 90, 50), (140, 50, 30)),
    "botao_corrente": ((130, 130, 140), (80, 80, 90)),
    "botao_vidro": ((200, 235, 245), (140, 190, 210)),
    "botao_giz": ((250, 250, 250), (210, 210, 210)),
    "botao_vestido": ((200, 40, 50), (140, 24, 34)),
}
TIN = [
    ".bbbbbbbbbb.",
    "bBBBBBBBBBBb",
    "bWWWWWWWWWWb",
    "bBBBBBBBBBBb",
    "bBByBByBByBb",
    "bBBBBBBBBBBb",
    "bBBBBBBBBBBb",
    ".bbbbbbbbbb.",
]


def main() -> None:
    for name, (light, dark) in COLORS.items():
        art = from_grid(BUTTON, {"A": light, "a": (30, 26, 30), "o": dark}, outline=P.OUTLINE)
        icon = canvas(16, 16)
        paste(icon, art, (16 - art.width) // 2, (16 - art.height) // 2)
        icon.save(os.path.join(ITEMS, f"{name}.png"))
    art = from_grid(TIN, {"B": (70, 110, 170), "b": (40, 70, 120), "W": (200, 210, 230), "y": (230, 200, 90)}, outline=P.OUTLINE)
    icon = canvas(16, 16)
    paste(icon, art, (16 - art.width) // 2, (16 - art.height) // 2)
    icon.save(os.path.join(ITEMS, "lata_de_botoes.png"))


if __name__ == "__main__":
    main()
