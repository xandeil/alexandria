"""Ícones das armaduras (v0.25): 5 moldes (capacete, peitoral, luvas, calça,
botas) x 7 paletas (uma por conjunto) = 35 ícones 16x16.

Por que molde + paleta e não 35 desenhos? É o mesmo princípio do código:
a FORMA da peça é uma coisa, a COR do conjunto é outra. Separando as duas,
um conjunto novo é só mais uma linha de paleta.

Uso: python3 tools/art/armaduras.py   (escreve em assets/items/armadura_*.png)
"""
from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(__file__))

from props import _icon  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

# l = luz, m = cor principal, d = sombra, a = detalhe (o "brasão" do conjunto)
SHAPES = {
    "capacete": [
        "...dddddd...",
        "..dmmmmmmd..",
        ".dmllmmmmmd.",
        ".dmlmmmmmmd.",
        "dmmmmaammmmd",
        "dmmddddddmmd",
        "dmd.a..a.dmd",
        "dmd......dmd",
        "dmmd....dmmd",
        ".dd......dd.",
    ],
    "peitoral": [
        "..dd....dd..",
        ".dmmd..dmmd.",
        "dmlmmddmmmmd",
        "dmlmmmmmmmmd",
        "dmlmmaammmmd",
        ".dmmaaaammd.",
        ".dmmmaammmd.",
        ".dmmmmmmmmd.",
        "..dmmmmmmd..",
        "..ddddddddd.",
    ],
    "luvas": [
        ".dd....dd...",
        "dmld..dmmd..",
        "dmld.dmlmd..",
        "dmmd.dmlmd..",
        "dmmmddmmmd..",
        "dmmmmdmmmdd.",
        "dmammdmmmmd.",
        "dmmmmdmamd..",
        ".dddd.dddd..",
        ".daad.daad..",
        ".dddd.dddd..",
    ],
    "calca": [
        ".dddddddddd.",
        ".daaaaaaaad.",
        ".dmlmmmmmmd.",
        ".dmlmmdmmmd.",
        ".dmlmd.dmmd.",
        ".dmmd..dmmd.",
        ".dmmd..dmmd.",
        ".dmmd..dmmd.",
        ".dmmd..dmmd.",
        ".dddd..dddd.",
    ],
    "botas": [
        "..ddd..ddd..",
        "..dld..dmd..",
        "..dld..dmd..",
        "..dmd..dmd..",
        "..dad..dad..",
        "..dmd..dmd..",
        ".dmmd.dmmd..",
        "dmmmddmmmmd.",
        "ddddddddddd.",
    ],
}

# conjunto -> (luz, principal, sombra, detalhe)
PALETTES = {
    "vigilia": ((232, 226, 210), (178, 168, 150), (112, 104, 94), (120, 220, 200)),   # linho claro, brilho de cápsula
    "detentor": ((206, 210, 218), (142, 150, 162), (84, 90, 102), (196, 70, 52)),     # aço da guarda, faixa vermelha
    "sono": ((196, 236, 196), (120, 180, 130), (64, 110, 78), (236, 170, 210)),       # verde do bosque, flor
    "banquete": ((234, 196, 170), (176, 112, 92), (110, 60, 52), (232, 214, 150)),    # avental manchado, migalha dourada
    "eco": ((232, 186, 120), (176, 120, 70), (108, 70, 44), (255, 150, 50)),          # bronze de forja, brasa
    "caelis": ((246, 150, 120), (196, 72, 60), (118, 36, 40), (255, 210, 110)),       # escama de dragoa, ouro
    "arconte": ((214, 232, 250), (130, 160, 210), (72, 88, 140), (240, 210, 130)),    # gelo e vitrine, fio dourado
}


def piece_icon(slot: str, set_id: str):
    light, main, dark, accent = PALETTES[set_id]
    return _icon(SHAPES[slot], {"l": light, "m": main, "d": dark, "a": accent})


def main() -> None:
    out_dir = os.path.join(ROOT, "assets", "items")
    for set_id in PALETTES:
        for slot in SHAPES:
            piece_icon(slot, set_id).save(os.path.join(out_dir, f"armadura_{set_id}_{slot}.png"))
    print("armaduras:", len(PALETTES) * len(SHAPES), "ícones")


if __name__ == "__main__":
    main()
