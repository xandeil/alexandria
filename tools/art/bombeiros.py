"""O quartel de bombeiros da Avenida (v0.35, Etapa 6 — Cidade): a fachada que
fica encostada na parede de cima, perto da 1ª Câmara. É do Seu Cícero
(Etapa 10). Portão de garagem amassado, sirene apagada, mangueira sem bico.

Rode:  python3 tools/art/bombeiros.py
"""
from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from pixel import add_outline, canvas, hline, rect, vline, put, noise_fill  # noqa: E402
import palette as P  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
PROPS = os.path.join(ROOT, "assets", "props")

BRICK = (150, 62, 50)
BRICK_D = (112, 44, 38)
MORTAR = (90, 74, 70)
DOOR = (170, 36, 40)
DOOR_D = (110, 22, 28)
SIGN = (226, 220, 206)
STRIPE = (190, 40, 44)
SOOT = (40, 34, 34)
METAL = (150, 150, 160)
HOSE = (196, 168, 90)


def main() -> None:
    w, h = 58, 44
    img = canvas(w, h)
    # Torre da sirene (esquerda) e o corpo do prédio.
    noise_fill(img, (4, 2, 16, h - 1), [BRICK, BRICK_D], [0.7, 0.3], seed=3)
    noise_fill(img, (2, 12, w - 2, h - 1), [BRICK, BRICK_D], [0.75, 0.25], seed=7)
    for y in range(14, h - 1, 4):
        hline(img, 2, w - 3, y, MORTAR)
    rect(img, 6, 4, 13, 8, METAL)            # a sirene
    rect(img, 8, 5, 11, 7, SOOT)
    # Placa (sem letras: uma faixa vermelha, como as de verdade).
    rect(img, 20, 14, w - 6, 19, SIGN)
    rect(img, 20, 16, w - 6, 17, STRIPE)
    # Portão de garagem, amassado de um lado.
    rect(img, 18, 22, w - 8, h - 2, DOOR)
    for y in range(24, h - 2, 3):
        hline(img, 18, w - 8, y, DOOR_D)
    for x, y in [(w - 12, 30), (w - 11, 31), (w - 13, 32), (w - 10, 33)]:
        put(img, x, y, DOOR_D)
    # Fuligem em cima do portão (o fogo da rua chegou aqui também).
    for x in range(18, w - 8):
        if (x * 7) % 5 < 2:
            vline(img, x, 20, 21 + (x % 3), SOOT)
    # A mangueira enrolada, sem bico, na parede da esquerda.
    for x, y in [(6, 24), (7, 23), (8, 23), (9, 24), (9, 25), (8, 26), (7, 26), (6, 25), (7, 28), (7, 30), (7, 32)]:
        put(img, x, y, HOSE)
    add_outline(img, P.OUTLINE).save(os.path.join(PROPS, "quartel_bombeiros.png"))


if __name__ == "__main__":
    main()
