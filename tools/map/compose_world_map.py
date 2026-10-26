"""Monta o MAPA-MÚNDI de Alexandria a partir das fotos de cada região.

1) godot --path . res://tools/map/render_map.tscn -- --out=PASTA   (fotografa as regiões)
2) python3 tools/map/compose_world_map.py PASTA saida.png           (monta o mapa)

As regiões ficam "flutuando" no céu (é uma ilha que subiu), com o Teatro no
centro — ele é o hub. As linhas douradas são as saídas de verdade de cada fase
(exit_scene, exit2_scene... nos .tscn). Arenas de chefe ficam menores, com o
nome do Pecado embaixo.
"""
from __future__ import annotations

import math
import os
import random
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
FONTS = os.path.join(ROOT, "assets", "fonts")
W, H = 3600, 2900

# região → (centro no mapa, escala, nome, subtítulo)
REGIONS = {
    "prologo": ((560, 470), 0.42, "Complexo das Cápsulas", "Prólogo: onde você acorda"),
    "nucleo": ((1800, 330), 0.42, "O Núcleo", "as sete memórias abrem a escada"),
    "coracao": ((2560, 300), 0.36, "O Coração", "o Cavaleiro Desolado"),
    "teatro": ((1800, 1060), 0.62, "Teatro Alexandria", "a sua Câmara · Fada · Ferreiro · Vendedor · Orbe"),
    "raizes": ((560, 1150), 0.42, "Raízes da Fome", ""),
    "arena_mabel": ((560, 1640), 0.36, "A Mesa de Mabel", "Gula"),
    "bosque": ((3000, 1060), 0.4, "Bosque do Sono Eterno", ""),
    "arena_nyssa": ((3000, 560), 0.36, "Clareira de Nyssa", "Preguiça"),
    "forjas": ((3000, 1560), 0.36, "Forjas Ocas", ""),
    "arena_durgan": ((3000, 2000), 0.36, "A Forja do Eco", "Inveja"),
    "cidade": ((1800, 1750), 0.5, "Cidade Estilhaçada", "Helena Altiva espera no Teatro (Luxúria)"),
    "arena_aldir": ((1100, 2100), 0.36, "Praça do Detentor", "Ira"),
    "montanha": ((1800, 2330), 0.36, "Montanha Carbonizada", ""),
    "arena_rachel": ((1060, 2620), 0.32, "O Ninho", "Orgulho"),
    "dominio": ((2620, 2560), 0.34, "Domínio Congelado", ""),
    "arena_cassian": ((3240, 2560), 0.3, "A Sala do Arconte", "Ganância"),
}

# As saídas reais das fases (e a queda do Prólogo / o portão do Aldir).
LINKS = [
    ("prologo", "teatro"), ("teatro", "nucleo"), ("nucleo", "coracao"),
    ("teatro", "raizes"), ("raizes", "arena_mabel"),
    ("teatro", "bosque"), ("bosque", "arena_nyssa"), ("bosque", "forjas"), ("forjas", "arena_durgan"),
    ("teatro", "cidade"), ("cidade", "arena_aldir"), ("cidade", "montanha"),
    ("montanha", "arena_rachel"), ("montanha", "dominio"), ("dominio", "arena_cassian"),
]

GOLD = (214, 178, 106)
INK = (236, 230, 216)
DIM = (160, 152, 140)


def font(name: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(os.path.join(FONTS, name), size)


def sky() -> Image.Image:
    """Céu da noite: degradê, estrelas e nuvens baixas (a ilha flutua)."""
    img = Image.new("RGB", (W, H))
    draw = ImageDraw.Draw(img)
    top, bottom = (10, 12, 24), (34, 38, 58)
    for y in range(H):
        t = y / H
        draw.line([(0, y), (W, y)], fill=tuple(int(a + (b - a) * t) for a, b in zip(top, bottom)))
    rng = random.Random(7)
    for _ in range(900):
        x, y = rng.randrange(W), rng.randrange(H)
        c = rng.randrange(120, 230)
        draw.point((x, y), fill=(c, c, min(255, c + 20)))
    clouds = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    cd = ImageDraw.Draw(clouds)
    for _ in range(60):
        x, y = rng.randrange(-200, W), rng.randrange(200, H)
        w, h = rng.randrange(300, 800), rng.randrange(60, 140)
        cd.ellipse((x, y, x + w, y + h), fill=(150, 160, 190, 26))
    clouds = clouds.filter(ImageFilter.GaussianBlur(30))
    return Image.alpha_composite(img.convert("RGBA"), clouds)


def dashed(draw: ImageDraw.ImageDraw, a, b, color, width=6, dash=26, gap=16) -> None:
    length = math.dist(a, b)
    if length == 0:
        return
    ux, uy = (b[0] - a[0]) / length, (b[1] - a[1]) / length
    pos = 0.0
    while pos < length:
        end = min(pos + dash, length)
        draw.line([(a[0] + ux * pos, a[1] + uy * pos), (a[0] + ux * end, a[1] + uy * end)], fill=color, width=width)
        pos += dash + gap


def island(shot: Image.Image, scale: float) -> Image.Image:
    """A foto da região, reduzida, com moldura dourada e uma "base de rocha"
    embaixo (a ilha flutuante)."""
    w, h = int(shot.width * scale), int(shot.height * scale)
    small = shot.resize((w, h), Image.LANCZOS)
    pad = 10
    card = Image.new("RGBA", (w + pad * 2, h + pad * 2 + 26), (0, 0, 0, 0))
    draw = ImageDraw.Draw(card)
    # Rocha embaixo (triângulo escuro) — a ilha que subiu.
    draw.polygon([(pad + 10, h + pad), (w + pad - 10, h + pad), ((w + pad * 2) // 2, h + pad * 2 + 26)], fill=(40, 34, 38, 255))
    draw.rectangle((0, 0, w + pad * 2 - 1, h + pad * 2 - 1), fill=(12, 11, 14, 255), outline=GOLD, width=3)
    card.paste(small, (pad, pad))
    return card


def main(shots: str, out: str) -> None:
    canvas = sky()
    lines = ImageDraw.Draw(canvas)
    centers = {k: v[0] for k, v in REGIONS.items()}
    for a, b in LINKS:  # as linhas ficam ATRÁS das ilhas
        dashed(lines, centers[a], centers[b], GOLD + (200,))
    title_font, name_font, sub_font = font("Cinzel-Bold.woff2", 34), font("Cinzel-Bold.woff2", 30), font("PixelifySans-Regular.woff2", 22)
    for region, (center, scale, name, subtitle) in REGIONS.items():
        path = os.path.join(shots, f"{region}.png")
        if not os.path.exists(path):
            print("faltou a foto de", region)
            continue
        card = island(Image.open(path).convert("RGBA"), scale)
        x, y = center[0] - card.width // 2, center[1] - card.height // 2
        canvas.alpha_composite(card, (x, y))
        label_y = y + card.height + 6
        draw = ImageDraw.Draw(canvas)
        is_arena = region.startswith("arena_") or region == "coracao"
        draw.text((center[0], label_y), name, font=name_font, fill=GOLD if is_arena else INK, anchor="mt",
                  stroke_width=3, stroke_fill=(0, 0, 0))
        if subtitle:
            draw.text((center[0], label_y + 36), subtitle, font=sub_font, fill=DIM, anchor="mt",
                      stroke_width=2, stroke_fill=(0, 0, 0))
    draw = ImageDraw.Draw(canvas)
    big = font("Cinzel-Bold.woff2", 92)
    draw.text((150, 2780), "ALEXANDRIA", font=big, fill=INK, anchor="ls", stroke_width=4, stroke_fill=(0, 0, 0))
    draw.text((156, 2830), "A Ilha Que Não Cai — mapa do mundo", font=title_font, fill=DIM, anchor="ls")
    legend = ["Linha dourada: caminho entre as áreas", "Nome dourado: arena de chefe (o Pecado embaixo)",
              "Cada área principal tem uma Câmara de descanso", "(dá para viajar entre elas pelo menu da cápsula)"]
    for i, text in enumerate(legend):  # canto de cima à direita: lá não há nenhuma ilha
        draw.text((W - 90, 90 + i * 34), text, font=sub_font, fill=DIM, anchor="rs")
    canvas.convert("RGB").save(out, optimize=True)
    print("mapa-múndi:", out, canvas.size)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
