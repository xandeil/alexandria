"""Etapa 8 (v0.46): o Teatro em ruínas e o que sobrou do Heitor.

  • assets/props/lustre_caido.png   — o lustre no chão, torto, velas apagadas;
  • assets/props/camarote_caido.png — um camarote pendurado, meio caído (a Fada mora nele);
  • assets/props/cortina_rasgada.png — um pedaço da cortina no chão (a criança desenha nele);
  • assets/props/heitor_memorial.png — o elmo branco e a garrafa de Licor quebrada;
  • assets/props/elmo_heitor.png     — só o elmo (cai da cabeça dele na luta).

Rode:  python3 tools/art/ruinas_etapa8.py
"""
from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from pixel import from_grid  # noqa: E402
import palette as P  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
PROPS = os.path.join(ROOT, "assets", "props")

KEY = {"Y": (214, 176, 72), "y": (150, 116, 44), "C": (236, 228, 200), "c": (170, 160, 140),
       "G": (190, 226, 240), "R": (150, 36, 44), "r": (104, 24, 32), "W": (110, 74, 48), "w": (80, 52, 34),
       "A": (240, 240, 236), "a": (176, 180, 190), "K": (28, 26, 34), "L": (110, 60, 40), "l": (170, 110, 60),
       "B": (240, 220, 180), "D": (70, 74, 84), "g": (150, 150, 160), "P": (226, 120, 140)}

LUSTRE = [
    "..........C.........C......",
    "..........c.........c......",
    "...C......Y.........Y....C.",
    "...c...YYYYYYYYYYYYYYYYY.c.",
    "...YYYyGyyGyyyGyyyGyyyGyYY.",
    "..YyyYYYYYYYYYYYYYYYYYYYyyY",
    ".YyG.YyyyGyyyyyGyyyyGyyY.Gy",
    "Yy...G..Y....G.....Y..G..yY",
    ".y.......G..........G....y.",
    "..YY...........G.......YY..",
    "....YYYYYYYYYYYYYYYYYYYY...",
]

CAMAROTE = [
    "..K.................K.",
    "..K.................K.",
    "..K.................K.",
    "WWWWWWWWWWWWWWWWWWWW..",
    "WwRRRRRRRRRRRRRRRRwWW.",
    "WwRrRRRRrRRRRRrRRRwwWW",
    "WwRRRRRRRRRRRRRRRRw.wW",
    "WWWWWWWWWWWWWWWWWWW..W",
    ".wYYYYYYYYYYYYYYYYw...",
    "..w..............w....",
    "...w............w.....",
]

CORTINA = [
    "RRRRrRRRRRRrRRRRRRRRrRR..",
    "RrRRRRRRrRRRRRRRrRRRRRRR.",
    "RRRRRRRRRRRRBRRRRRRRRrRRR",
    ".RRRrRRRRRRBRBRRRRrRRRRRR",
    "RRRRRRRRRRRRBRRRRRRRRRRR.",
    "RRrRRRRRRRRRRRRRRRrRRRR..",
    "..RRRRRrRRRRRRRRRRRRRR...",
    "....RRRRRRR..RRRRRRR.....",
]

ELMO = [
    "..AAAAAA..",
    ".AAAAAAAA.",
    "AAaAAAAaAA",
    "AAKKKKKKAA",
    "AAAAKKAAAA",
    ".aAAAAAAa.",
    "..aaaaaa..",
]

MEMORIAL = [
    "....AAAAAA..........",
    "...AAAAAAAA.........",
    "..AAaAAAAaAA........",
    "..AAKKKKKKAA....l...",
    "..AAAAKKAAAA...lL...",
    "...aAAAAAAa...LL.lL.",
    "....aaaaaa...lLLLLl.",
    "...................L",
]


def main() -> None:
    for name, rows in [("lustre_caido", LUSTRE), ("camarote_caido", CAMAROTE), ("cortina_rasgada", CORTINA),
                       ("elmo_heitor", ELMO), ("heitor_memorial", MEMORIAL)]:
        from_grid(rows, KEY, outline=P.OUTLINE).save(os.path.join(PROPS, f"{name}.png"))


if __name__ == "__main__":
    main()
