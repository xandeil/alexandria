"""Miniaturas das Câmaras (menu de descanso): uma por região.

Cada miniatura é montada com os PRÓPRIOS tiles da região (parede em cima,
piso embaixo) e a cápsula no meio — assim, se o tileset mudar, a miniatura
acompanha ao rodar o gerador de novo. Nada é desenhado à mão aqui.
"""
from __future__ import annotations

import os

from PIL import Image, ImageDraw

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
TILE = 16
W, H = 64, 40

# cena → (tileset, tile da parede (x, y) no atlas, tile do piso)
REGIONS = {
    "teatro": ("teatro", (5, 1), (0, 0)),
    "cidade": ("cidade", (1, 1), (0, 0)),
    "bosque": ("bosque", (1, 1), (0, 0)),
    "raizes": ("raizes", (1, 1), (0, 0)),
    "forjas": ("forjas", (1, 1), (0, 0)),
    "montanha": ("montanha", (1, 1), (0, 0)),
    "dominio": ("gelo", (1, 1), (0, 0)),
    "nucleo": ("nucleo", (1, 1), (0, 0)),
}


def _tile(atlas: Image.Image, cell: tuple[int, int]) -> Image.Image:
    x, y = cell
    return atlas.crop((x * TILE, y * TILE, (x + 1) * TILE, (y + 1) * TILE))


def thumbnail(scene: str) -> Image.Image:
    tileset, wall_cell, floor_cell = REGIONS[scene]
    atlas = Image.open(os.path.join(ROOT, "assets/tiles", f"{tileset}_tiles.png")).convert("RGBA")
    capsule = Image.open(os.path.join(ROOT, "assets/props/capsule.png")).convert("RGBA")
    img = Image.new("RGBA", (W, H), (0, 0, 0, 255))
    wall, floor = _tile(atlas, wall_cell), _tile(atlas, floor_cell)
    for x in range(0, W, TILE):
        img.paste(wall, (x, -2))
        for y in range(14, H, TILE):
            img.paste(floor, (x, y))
    # Luz verde da cápsula no chão + a cápsula.
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse((12, 22, 52, 40), fill=(90, 220, 140, 60))
    img = Image.alpha_composite(img, glow)
    img.alpha_composite(capsule, ((W - capsule.width) // 2, 12))
    # Vinheta: escurece as bordas (a miniatura parece uma lembrança).
    shade = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(shade)
    for i in range(6):
        draw.rectangle((i, i, W - 1 - i, H - 1 - i), outline=(0, 0, 0, 120 - i * 20))
    return Image.alpha_composite(img, shade)
