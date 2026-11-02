"""Etapa 8 (v0.45): os objetos do Heitor.

  • assets/props/poco.png            — o poço da Avenida (ele cai lá dentro);
  • assets/props/heitor_no_gelo.png  — a armadura redonda presa num bloco de gelo;
  • assets/items/flor_de_pedra.png   — a pedra que ele chamava de flor;
  • assets/items/licor_da_vigilia.png — a garrafa que os dois dividiam.

(O Heitor em si sai de aliados_etapa7.py, com os outros aliados.)
Rode:  python3 tools/art/heitor_etapa8.py
"""
from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from pixel import canvas, from_grid, paste  # noqa: E402
import palette as P  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
PROPS = os.path.join(ROOT, "assets", "props")
ITEMS = os.path.join(ROOT, "assets", "items")

KEY = {"G": (150, 150, 160), "g": (110, 110, 120), "P": (226, 120, 140), "p": (170, 80, 100),
       "L": (110, 60, 40), "l": (170, 110, 60), "W": (240, 220, 180), "K": (28, 26, 34),
       "D": (70, 74, 84), "B": (120, 92, 64), "I": (186, 222, 240), "i": (140, 186, 214),
       "A": (140, 150, 168), "w": (240, 240, 236), "S": (214, 170, 140)}

POCO = [
    "..B..............B..",
    "..B..............B..",
    "..BBBBBBBBBBBBBBBB..",
    "..B......l.......B..",
    "..B......l.......B..",
    ".GGGGGGGGGGGGGGGGGG.",
    "GgKKKKKKKKKKKKKKKKgG",
    "GgKKKKKKKKKKKKKKKKgG",
    "GGGGGGGGGGGGGGGGGGGG",
    "GgGGgGGGgGGGGgGGGgGG",
    "GGGgGGGGGGgGGGGGgGGG",
    "gGGGGgGGGGGGgGGGGGGg",
    ".gggggggggggggggggg.",
]

GELO = [
    "...iiiiiiiiiii...",
    "..iIIIIIIIIIIIi..",
    ".iIIIwwwwwwIIIIi.",
    ".iIIwwwwwwwwIIIi.",
    ".iIIwSSSSSSwIIIi.",
    ".iIIISKSSKSIIIIi.",
    ".iIIAAAAAAAAIIIi.",
    ".iIAAAAAAAAAAIIi.",
    ".iIAAAAAAAAAAIIi.",
    ".iIAAAAAAAAAAIIi.",
    ".iIIAAAAAAAAIIIi.",
    ".iIIAAA..AAAIIIi.",
    ".iIIAAA..AAAIIIi.",
    ".iIIIIIIIIIIIIIi.",
    "..iiiiiiiiiiiii..",
]

FLOR = ["...PPP....", "..PPpPP...", ".PPgGgPP..", "..PGGGP...", "...PPP....",
        "....l.....", "...ll.....", "....l.....", "...ggg....", "..gGGGg..."]
LICOR = ["...gg...", "...LL...", "..LllL..", ".LlWWlL.", ".LlWWlL.", ".LllllL.", ".LllllL.", "..LLLL.."]


def icon(rows: list[str], x: int, y: int, name: str) -> None:
    image = canvas(16, 16)
    paste(image, from_grid(rows, KEY, outline=P.OUTLINE), x, y)
    image.save(os.path.join(ITEMS, name))


def main() -> None:
    from_grid(POCO, KEY, outline=P.OUTLINE).save(os.path.join(PROPS, "poco.png"))
    from_grid(GELO, KEY, outline=P.OUTLINE).save(os.path.join(PROPS, "heitor_no_gelo.png"))
    icon(FLOR, 3, 2, "flor_de_pedra.png")
    icon(LICOR, 4, 3, "licor_da_vigilia.png")


if __name__ == "__main__":
    main()
