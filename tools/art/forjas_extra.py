"""Forjas expandidas (v0.35, Etapa 6): a estátua SEM ROSTO (a 1ª Câmara fica
atrás dela), a Dançarina de Engrenagem e a Caixa de Música de Bronze.

Rode:  python3 tools/art/forjas_extra.py
"""
from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from pixel import from_grid, hstrip, flip_h, canvas, paste  # noqa: E402
from PIL import Image  # noqa: E402
import palette as P  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
PROPS = os.path.join(ROOT, "assets", "props")
SPRITES = os.path.join(ROOT, "assets", "sprites")
ITEMS = os.path.join(ROOT, "assets", "items")

BRONZE = {"B": (201, 142, 76), "b": (160, 106, 54), "d": (110, 70, 36), "G": (230, 190, 110),
          "M": (120, 120, 132), "m": (80, 80, 92), "R": (170, 40, 52), "W": (236, 228, 212), "K": (30, 24, 28)}

DANCER_IDLE = [
    "........GG........",
    ".......GBBG.......",
    ".......BBBB.......",
    "..b.....BB.....b..",
    "...bb..BBBB..bb...",
    ".....bbBBBBbb.....",
    ".......BBBB.......",
    ".......bBBb.......",
    "......bBBBBb......",
    ".....bBBBBBBb.....",
    "....GbbbbbbbbG....",
    ".......B..B.......",
    ".......B..B.......",
    ".......b..B.......",
    "..........B.......",
    ".........bB.......",
    "......MMMMMM......",
    ".....MmMmMmMm.....",
    "......MMMMMM......",
]
DANCER_SPIN = [
    "........GG........",
    ".......GBBG.......",
    ".......BBBB.......",
    "........BB........",
    ".......BBBB.......",
    "...bbbbBBBBbbbb...",
    ".......BBBB.......",
    ".......bBBb.......",
    "......bBBBBb......",
    "...GbbBBBBBBbbG...",
    ".....bbbbbbbb.....",
    "........BB........",
    "........BB........",
    "........bB........",
    "........BB........",
    "........BB........",
    "......MMMMMM......",
    ".....mMmMmMmM.....",
    "......MMMMMM......",
]
DANCER_DART = [
    "..................",
    "...........GG.....",
    "..........GBBG....",
    "..........BBBB....",
    "...........BB.....",
    "........BBBBbbbbb.",
    "......bbBBBB......",
    ".....b..BBBb......",
    "........bBBBb.....",
    ".......bBBBBBb....",
    "......GbbbbbbbG...",
    ".........B..B.....",
    "........B....B....",
    ".......b......B...",
    "..................",
    "..................",
    "......MMMMMM......",
    ".....MmMmMmMm.....",
    "......MMMMMM......",
]
MUSIC_BOX = [
    "..GGGGGGGGGG..",
    ".GBBBBBBBBBBG.",
    ".GbbbbbbbbbbG.",
    "..dddddddddd..",
    ".BBBBBBBBBBBB.",
    ".BbbWWWWWWbbB.",
    ".BbbWKKKKWbbB.",
    ".BbbWWWWWWbbB.",
    ".BBBBBBBBBBBB.",
    ".bbbbbbbbbbbb.",
    "..d........d..",
]


def faceless_statue() -> None:
    """A estátua de bronze com o rosto alisado (olhos e boca somem)."""
    statue = Image.open(os.path.join(PROPS, "bronze_statue.png")).convert("RGBA")
    px = statue.load()
    for y in range(9, 17):
        for x in range(6, 16):
            r, g, b, a = px[x, y]
            if a and (r, g, b) in [(122, 78, 40), (148, 97, 49)]:
                px[x, y] = (201, 142, 76, 255) if y < 13 else (160, 106, 54, 255)
    statue.save(os.path.join(PROPS, "estatua_sem_rosto.png"))


def main() -> None:
    faceless_statue()
    frames = [from_grid(g, BRONZE, outline=P.OUTLINE) for g in (DANCER_IDLE, DANCER_SPIN, DANCER_DART)]
    hstrip(frames).save(os.path.join(SPRITES, "dancarina.png"))
    icon = canvas(16, 16)
    paste(icon, from_grid(MUSIC_BOX, BRONZE, outline=P.OUTLINE), 0, 2)
    icon.save(os.path.join(ITEMS, "caixa_musica_bronze.png"))


if __name__ == "__main__":
    main()
