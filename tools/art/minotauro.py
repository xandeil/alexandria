"""O farm da Montanha (v0.26): o Bezerro Dourado e o pai dele, o Minotauro.

Todos olham para a DIREITA (o jogo espelha).
Uso: python3 tools/art/minotauro.py  (escreve em assets/sprites/)
"""
from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(__file__))

from pixel import add_outline, canvas, ellipse, hline, hstrip, put, rect, vline  # noqa: E402

import palette as P  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
O = P.OUTLINE

GOLD = (236, 190, 72)
GOLD_LIGHT = (255, 232, 140)
GOLD_DARK = (176, 120, 40)
HOOF = (70, 48, 40)
HORN = (240, 228, 200)
EYE = (40, 24, 20)

FUR = (110, 64, 44)
FUR_DARK = (70, 38, 30)
FUR_LIGHT = (150, 98, 66)
SKIN = (176, 120, 90)
RING = (232, 196, 90)
RED_EYE = (255, 80, 50)
STEEL = (170, 176, 186)
STEEL_DARK = (96, 102, 114)
HANDLE = (92, 60, 40)
CLOTH = (120, 36, 36)


def calf_frames():
    """Bezerro Dourado (24x24): [parado, passo A, passo B, CORRENDO (esticado)]."""
    frames = []
    for state in range(4):
        img = canvas(24, 24)
        run = state == 3
        stretch = 2 if run else 0
        # pernas (4) — o passo alterna os pares
        a = {0: 0, 1: 1, 2: -1, 3: 2}[state]
        for lx, off in ((7 - stretch, a), (10 - stretch, -a), (14 + stretch, -a), (17 + stretch, a)):
            vline(img, lx + off, 16, 21, GOLD_DARK)
            put(img, lx + off, 22, HOOF)
        # corpo
        ellipse(img, 12, 14, 7 + stretch, 4, GOLD)
        hline(img, 7 - stretch, 16 + stretch, 11, GOLD_LIGHT)
        ellipse(img, 12, 16, 5, 1.5, GOLD_LIGHT)
        # rabinho
        put(img, 4 - stretch, 12 if not run else 11, GOLD_DARK)
        put(img, 3 - stretch, 11 if not run else 10, GOLD_DARK)
        # cabeça (baixa quando corre)
        hx, hy = (19 + stretch, 10 + (2 if run else 0))
        ellipse(img, hx, hy, 3.5, 3, GOLD)
        rect(img, hx + 2, hy, hx + 4, hy + 2, GOLD_LIGHT)  # focinho
        put(img, hx + 1, hy - 1, EYE)
        put(img, hx - 1, hy - 4, HORN)  # chifrinhos
        put(img, hx + 1, hy - 4, HORN)
        put(img, hx - 3, hy - 1, GOLD_DARK)  # orelha
        # brilho
        put(img, 10, 12, (255, 255, 230))
        frames.append(add_outline(img, O))
    return frames


def _minotaur(state):
    """64x64. 0 parado, 1 passo A, 2 passo B, 3 AGACHADO (vai pular), 4 NO AR,
    5 machado ERGUIDO, 6 machado BAIXO (golpe)."""
    img = canvas(64, 64)
    crouch = 6 if state == 3 else 0
    air = state == 4
    base_y = 60 - crouch
    # pernas (dobradas no ar)
    step = {1: 3, 2: -3}.get(state, 0)
    for lx, off in ((22, step), (34, -step)):
        if air:
            rect(img, lx, 42, lx + 7, 50, FUR_DARK)
            rect(img, lx + 4, 48, lx + 9, 52, HOOF)
        else:
            rect(img, lx + off // 2, 44 - crouch // 2, lx + 7 + off // 2, base_y - 3, FUR_DARK)
            rect(img, lx - 1 + off, base_y - 3, lx + 8 + off, base_y, HOOF)
    # tanga
    rect(img, 20, 40 - crouch // 2, 43, 46 - crouch // 2, CLOTH)
    # tronco
    top = 18 + crouch
    ellipse(img, 32, top + 12, 14, 13, FUR)
    ellipse(img, 34, top + 12, 9, 9, SKIN)  # peito
    hline(img, 29, 39, top + 12, FUR_LIGHT)
    hline(img, 30, 38, top + 16, FUR_LIGHT)
    # braço de trás
    rect(img, 18, top + 4, 22, top + 18, FUR_DARK)
    # cabeça de touro
    hx, hy = 38, top - 4
    ellipse(img, hx, hy, 8, 7, FUR)
    rect(img, hx + 4, hy, hx + 11, hy + 5, SKIN)  # focinho
    put(img, hx + 10, hy + 2, FUR_DARK)
    put(img, hx + 8, hy + 6, RING)  # argola
    put(img, hx + 9, hy + 6, RING)
    put(img, hx + 3, hy - 2, RED_EYE)
    put(img, hx + 4, hy - 2, RED_EYE)
    ellipse(img, hx, hy - 1, 9, 8, FUR)  # cabeça grande (é um touro)
    rect(img, hx + 4, hy, hx + 12, hy + 6, SKIN)
    put(img, hx + 9, hy + 7, RING)
    put(img, hx + 10, hy + 7, RING)
    put(img, hx + 3, hy - 3, RED_EYE)
    put(img, hx + 4, hy - 3, RED_EYE)
    for k in range(11):  # dois chifres grossos, curvados para cima
        lx, ly = hx - 6 - k, hy - 5 - int(k * 0.9) + (k * k) // 14
        put(img, lx, ly, HORN)
        put(img, lx, ly + 1, HORN)
        rx, ry = hx + 4 + k // 2, hy - 7 - int(k * 0.9) + (k * k) // 16
        put(img, rx, ry, HORN)
        put(img, rx + 1, ry, HORN)
    # braço da frente com o machado
    if state == 5:  # erguido acima da cabeça
        rect(img, 40, top - 8, 44, top + 6, FUR_DARK)
        vline(img, 42, 2, top - 6, HANDLE)
        vline(img, 43, 2, top - 6, HANDLE)
        ellipse(img, 48, 7, 6, 6, STEEL)
        ellipse(img, 49, 7, 3, 4, STEEL_DARK)
    elif state == 6:  # baixado na frente
        rect(img, 42, top + 6, 52, top + 10, FUR_DARK)
        hline(img, 50, 62, top + 12, HANDLE)
        hline(img, 50, 62, top + 13, HANDLE)
        ellipse(img, 59, top + 18, 5, 6, STEEL)
        ellipse(img, 59, top + 19, 2, 3, STEEL_DARK)
    else:
        rect(img, 42, top + 4, 46, top + 18, FUR_DARK)
        vline(img, 47, top + 2, top + 30, HANDLE)
        vline(img, 48, top + 2, top + 30, HANDLE)
        ellipse(img, 52, top + 6, 5, 6, STEEL)
        ellipse(img, 53, top + 6, 2, 3, STEEL_DARK)
    return add_outline(img, O)


def minotaur_frames():
    return [_minotaur(s) for s in range(7)]


def main() -> None:
    out = os.path.join(ROOT, "assets", "sprites")
    hstrip(calf_frames()).save(os.path.join(out, "bezerro_dourado.png"))
    hstrip(minotaur_frames()).save(os.path.join(out, "minotauro.png"))
    print("bezerro + minotauro ok")


if __name__ == "__main__":
    main()
