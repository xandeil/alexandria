"""O Sino de Despertar (v0.35, Etapa 6 — Bosque): máquina do Projeto, coberta
de musgo, feita para acordar as cobaias. Dois quadros: parado e tocando.

Rode:  python3 tools/art/sino.py
"""
from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from pixel import from_grid, hstrip  # noqa: E402
import palette as P  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
SPRITES = os.path.join(ROOT, "assets", "sprites")

KEY = {"M": (128, 134, 140), "m": (84, 90, 98), "d": (52, 56, 64),
       "G": (92, 140, 70), "g": (58, 96, 50), "B": (206, 168, 72), "b": (150, 112, 42),
       "L": (180, 240, 190), "R": (190, 60, 50)}

FRAME_STILL = [
    "......mmmmmmmmmmmm......",
    ".....mMMMMMMMMMMMMm.....",
    ".....mMgGMMMMMMGgMm.....",
    "......mmmmmdmmmmmm......",
    "...........d............",
    ".........bBBBb..........",
    "........bBBBBBb.........",
    "........BBBBBBB.........",
    ".......bBBBBBBBb........",
    ".......BBBBBBBBB........",
    "......bBBBBBBBBBb.......",
    "......bbbbbbbbbbb.......",
    "...........b............",
    "....mmmmmmmmmmmmmmmm....",
    "...mMMMMMMLMMMMMMMMMm...",
    "...mMGGMMMMMMMMMRMMMm...",
    "...mMgGGMMMMMMMMMMGGm...",
    "...mMMMMMMMMMMMMMMGgm...",
    "...mMMmmmmmmmmmmmMMMm...",
    "...mMMmddddddddmmMMMm...",
    "...mGGmdLdddLddmmGGMm...",
    "...mgGmddddddddmmGgMm...",
    "...mGGGmmmmmmmmmGGGGm...",
    "...mmmmmmmmmmmmmmmmmm...",
    "..ggGGgg.......ggGGgg...",
]


def ringing() -> list[str]:
    """O sino balança para o lado e as luzes acendem em vermelho."""
    rows = []
    for i, row in enumerate(FRAME_STILL):
        if 5 <= i <= 12:
            row = ".." + row[:-2]
        rows.append(row.replace("L", "R"))
    return rows


def main() -> None:
    frames = [from_grid(FRAME_STILL, KEY, outline=P.OUTLINE), from_grid(ringing(), KEY, outline=P.OUTLINE)]
    hstrip(frames).save(os.path.join(SPRITES, "sino_despertar.png"))


if __name__ == "__main__":
    main()
