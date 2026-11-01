"""Raízes expandidas (v0.35, Etapa 6): Socorro, a Enfermeira da Estufa, e o
Funil de Socorro (a recompensa).

Rode:  python3 tools/art/raizes_extra.py
"""
from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from pixel import from_grid, hstrip, canvas, paste  # noqa: E402
import palette as P  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
SPRITES = os.path.join(ROOT, "assets", "sprites")
ITEMS = os.path.join(ROOT, "assets", "items")

KEY = {"W": (226, 222, 210), "w": (180, 174, 162), "S": (214, 170, 140), "s": (170, 124, 100),
       "R": (150, 30, 40), "r": (100, 20, 28), "K": (40, 30, 34), "H": (70, 52, 44), "M": (150, 150, 160), "m": (96, 98, 110)}

IDLE = [
    "......WWWW......",
    ".....WWRWWW.....",
    ".....HHHHHH.....",
    ".....HSSSSH.....",
    ".....HSKSKH.....",
    "......SSSS......",
    ".......ss.......",
    ".....WWWWWW.....",
    "....WWWWRWWW....",
    "...SWWWWWWWWS...",
    "...SWWRWWWWWSmM.",
    "....WWWWWWRW..mM",
    "....wWWWWWWw....",
    "....wWWRWWWw....",
    "...wWWWWWWWWw...",
    "...wwwwwwwwww...",
    ".....ss..ss.....",
    ".....KK..KK.....",
]


def walk() -> list[str]:
    rows = IDLE[:-2] + [".....ss...ss....", ".....KK...KK...."]
    return rows


def spin() -> list[str]:
    rows = IDLE[:9] + [
        "SSSWWWWWWWWWSSS.",
        "...SWWRWWWWWS...",
        "....WWWWWWRW....",
        "...wwWWWWWWww...",
        "..wwWWRWWWWWww..",
        ".wwWWWWWWWWWWww.",
        "..wwwwwwwwwwww..",
        ".....ss..ss.....",
        ".....KK..KK.....",
    ]
    return rows


FUNNEL = [
    "MMMMMMMMMMMM",
    ".MmmmmmmmmM.",
    "..MmmRRmmM..",
    "...MmRRmM...",
    "....MRRM....",
    ".....MM.....",
    ".....MM.....",
    ".....MM.....",
    ".....RM.....",
    "......R.....",
]


def main() -> None:
    frames = [from_grid(g, KEY, outline=P.OUTLINE) for g in (IDLE, walk(), spin())]
    hstrip(frames).save(os.path.join(SPRITES, "socorro.png"))
    icon = canvas(16, 16)
    paste(icon, from_grid(FUNNEL, KEY, outline=P.OUTLINE), 1, 2)
    icon.save(os.path.join(ITEMS, "funil_socorro.png"))


if __name__ == "__main__":
    main()
