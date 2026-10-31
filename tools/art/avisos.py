"""Avisos sem texto na entrada das áreas difíceis (v0.31, Etapa 2 — mapa livre).

- Raízes: um cadáver sentado diante de um prato cheio (morreu comendo, ou de fome à mesa).
- Montanha: um soldado queimado, de pé, ainda segurando o escudo.

Rode:  python3 tools/art/avisos.py   (gera em assets/props/)
"""
from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from pixel import from_grid  # noqa: E402
import palette as P  # noqa: E402

OUT = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "props")


def cadaver_mesa():
    rows = [
        "......BBBB..........",
        ".....BBBBBB.........",
        ".....BbBBbB.........",
        ".....BBBBBB.........",
        "......BBBB..........",
        ".....CCCCCC.........",
        "....CCCCCCCC........",
        "....CCcCCcCC.WWWWW..",
        "....CCCCCCCCWWrrrWW.",
        "....CCCCCCCCWrrRrrW.",
        "TTTTTTTTTTTTTTTTTTTT",
        "TtttttttttttttttttTT",
        "T.......LL.........T",
        "T.......LL.........T",
        "T.......LL.........T",
        "........LL..........",
    ]
    key = {"B": (196, 188, 170), "b": (60, 54, 52), "C": (92, 70, 60), "c": (70, 52, 44),
           "W": (220, 214, 200), "r": (150, 52, 48), "R": (196, 84, 64),
           "T": (110, 72, 44), "t": (84, 54, 34), "L": (84, 54, 34)}
    return from_grid(rows, key, outline=P.OUTLINE)


def soldado_queimado():
    rows = [
        "....KKKK....",
        "...KKKKKK...",
        "...KkKKkK...",
        "...KKKKKK...",
        "....KKKK....",
        "..AAAAAAA...",
        ".SSAAAAAAA..",
        "SSSSAAAAAA..",
        "SsSSAAAAAA..",
        "SSsSAAAAAA..",
        "SSSSAAAAA...",
        "SsSS.AA.AA..",
        ".SS..AA.AA..",
        ".....AA.AA..",
        "....AAA.AAA.",
    ]
    key = {"K": (46, 40, 38), "k": (240, 140, 60), "A": (58, 52, 50),
           "S": (96, 92, 88), "s": (150, 120, 90)}
    return from_grid(rows, key, outline=P.OUTLINE)


def main() -> None:
    os.makedirs(OUT, exist_ok=True)
    cadaver_mesa().save(os.path.join(OUT, "aviso_cadaver_mesa.png"))
    soldado_queimado().save(os.path.join(OUT, "aviso_soldado_queimado.png"))
    print("avisos gerados")


if __name__ == "__main__":
    main()
