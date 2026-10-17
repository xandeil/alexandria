"""Aliados: o Guarda Sem Posto (o marido de Helena, sem memoria).

Biblia: "Ele morreu na invasao, mas em Alexandria ninguem fica morto: voltou sem
memoria, de cabelo branco e um pouco mais jovem." Uniforme do governo gasto, sem
elmo (o elmo e o que ele deixa no posto, no fim). Olha para a DIREITA.
"""
from __future__ import annotations

import palette as P
from pixel import canvas, from_grid, paste, put, rect, hline, vline, ellipse, add_outline
from characters import SOLDIER_LEGS

O = P.OUTLINE

GUARD_KEY = {
    "w": (232, 232, 236), "W": (196, 196, 206), "s": P.SKIN, "z": P.SKIN_SHADOW, "e": (40, 36, 44),
    "u": P.UNIFORM, "d": P.UNIFORM_DARK, "a": P.PATCH_A, "D": P.LEATHER, "q": P.UNIFORM_DARK, "B": P.BOOTS,
    "r": (226, 196, 120),
}
GUARD_BODY = [
    "....wwwww.....",
    "...wwWwwww....",
    "..wwwwwwwWw...",
    "..wWssssswW...",
    "..wsssesses...",
    "..wssssssss...",
    "...zssssssz...",
    "....ssssss....",
    "...uuuuuuuuu..",
    "..uaauuuuuuuu.",
    "..suuuuuuuuus.",
    "..ruuuuuuuuus.",
    "...uDDDDDDDu..",
    "...uuuuuuuuu..",
]


def guard_frames():
    """O Guarda (24x24): [parado, passo, parado, passo 2, golpe, caido]"""
    frames = []
    for i, legs in enumerate(SOLDIER_LEGS):
        frame = canvas(24, 24)
        paste(frame, from_grid(GUARD_BODY + legs, GUARD_KEY, outline=O), 4, 4)
        vline(frame, 19, 9, 20, (170, 170, 176))  # espada baixa
        put(frame, 19, 21, P.LEATHER)
        frames.append(add_outline(frame, O))
    # golpe: espada a frente
    frame = canvas(24, 24)
    paste(frame, from_grid(GUARD_BODY + SOLDIER_LEGS[1], GUARD_KEY, outline=O), 3, 4)
    hline(frame, 15, 23, 14, (190, 190, 198))
    hline(frame, 15, 23, 15, (150, 150, 160))
    frames.append(add_outline(frame, O))
    # caido de joelhos
    frame = canvas(24, 24)
    paste(frame, from_grid(GUARD_BODY + ["....qqqqqq....", "...BBB..BBB..."], GUARD_KEY, outline=O), 4, 7)
    frames.append(add_outline(frame, O))
    return frames


def empty_post():
    """O posto vazio: o elmo amassado no chao e a espada cravada. 22x18."""
    img = canvas(22, 18)
    vline(img, 15, 1, 15, (180, 180, 188))
    vline(img, 16, 1, 15, (140, 140, 150))
    hline(img, 12, 19, 4, P.LEATHER)
    ellipse(img, 7, 13, 5.5, 3.5, P.HELMET)
    ellipse(img, 6, 12, 4, 2.5, P.HELMET_LIGHT)
    hline(img, 3, 11, 15, P.UNIFORM_DARK)
    return add_outline(img, O)


def ring_icon():
    """O anel do Guarda (item). 16x16."""
    img = canvas(16, 16)
    ellipse(img, 8, 9, 5, 5, (226, 196, 120))
    ellipse(img, 8, 9, 3, 3, (0, 0, 0, 0))
    for x in range(16):
        for y in range(16):
            if (x - 8) ** 2 + (y - 9) ** 2 <= 8:
                put(img, x, y, (0, 0, 0, 0))
    ellipse(img, 8, 4, 2, 1.5, (200, 230, 255))  # a pedra
    put(img, 7, 3, (255, 255, 255))
    return add_outline(img, O)
