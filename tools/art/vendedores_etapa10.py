"""Etapa 10 (v0.49): o Damião, o Sucateiro, e o que é dele.

  • assets/sprites/damiao_npc.png   — 2 quadros: mochila enorme de tralha, sino de
    lata, lanterna na testa, cachecol remendado e um SACO DE PAPEL PARDO na
    cabeça com furos tortos (esconde os olhos ficando brancos, como a irmã);
  • assets/props/mochila_damiao.png — a mochila largada onde ele morreu;
  • assets/items/meio_pingente.png  — a outra metade do pingente da Lúcia;
  • assets/items/fragmento_de_loja.png — o sino de lata da mochila dele.

Rode:  python3 tools/art/vendedores_etapa10.py
"""
from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from pixel import canvas, from_grid, hstrip, paste  # noqa: E402
import palette as P  # noqa: E402
import aliados_etapa7 as A  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
SPRITES = os.path.join(ROOT, "assets", "sprites")
PROPS = os.path.join(ROOT, "assets", "props")
ITEMS = os.path.join(ROOT, "assets", "items")

KEY = {**A.COMMON, "P": (176, 140, 96), "p": (138, 106, 70), "L": (250, 230, 140), "B": (110, 84, 60),
       "b": (80, 60, 44), "C": (150, 60, 56), "c": (110, 44, 40), "G": (150, 150, 160), "g": (110, 110, 120),
       "Y": (214, 176, 72), "y": (150, 116, 44), "J": (90, 96, 108)}

DAMIAO = [
    ".....PPPPP.......",
    "....PPLLPPP..G...",
    "....PPPPPPP.gBg..",
    "....PKPPPKP.BBBB.",
    "....PPPKKPP.BbBb.",
    "....PpPPPpP.BBBB.",
    "...cCCCCCCc.BgBB.",
    "..JJCcCCcCJJBBBB.",
    "..JJJJJJJJJJBbBB.",
    "..SJJJJJJJJSBBBB.",
    "...JJJJJJJJ.BBBY.",
    "...JJJJJJJJ..bby.",
    "...JJJ..JJJ......",
    "...JJJ..JJJ......",
    "...KKK..KKK......",
]

MOCHILA = [
    "....G.......",
    "...gYg......",
    ".BBBBBBBBB..",
    "BBbBBBBBbBB.",
    "BBBBGBBBBBBB",
    "BbBBBBBbBBBB",
    "BBBBBBBBBBB.",
    ".bbbbbbbbb..",
]

PINGENTE = ["...gg...", "..g..g..", "...YY...", "..YYyY..", ".YYyYY..", ".YyYY...", "..YY....", "...Y...."]
SINO = ["...g....", "..gGg...", ".gGGGg..", ".GGGGG..", "gGGGGGg.", "ggggggg.", "...K...."]


def main() -> None:
    idle = A.pad(DAMIAO)
    frames = [from_grid(g, KEY, outline=P.OUTLINE) for g in (idle, ["." * A.W] + idle[:-1])]
    hstrip(frames).save(os.path.join(SPRITES, "damiao_npc.png"))
    from_grid(MOCHILA, KEY, outline=P.OUTLINE).save(os.path.join(PROPS, "mochila_damiao.png"))
    for name, rows, x, y in [("meio_pingente", PINGENTE, 4, 4), ("fragmento_de_loja", SINO, 4, 4)]:
        icon = canvas(16, 16)
        paste(icon, from_grid(rows, KEY, outline=P.OUTLINE), x, y)
        icon.save(os.path.join(ITEMS, f"{name}.png"))


if __name__ == "__main__":
    main()


# --- v0.51: Dalva, Cícero, Benedita e os conjuntos deles ---------------------------------
KEY2 = {**A.COMMON, "U": (70, 100, 180), "u": (46, 70, 140), "H": (200, 200, 210), "h": (150, 150, 160),
        "X": (180, 160, 130), "x": (140, 120, 96), "R": (170, 60, 40), "r": (120, 40, 30), "Y": (214, 176, 72),
        "y": (150, 116, 44), "L": (255, 220, 120), "G": (150, 150, 160), "g": (110, 110, 120), "V": (120, 110, 90),
        "v": (86, 78, 64), "B": (60, 56, 52)}
DALVA = [
    ".....hhhh........",
    "....hHHHHh.......",
    "....HSSSSH.......",
    "....SKSSKS.......",
    "....SSssSS..H....",
    ".....SSSS..HhH...",
    "...uUUUUUUu......",
    "..uUUUUUUUUu.....",
    "..SUUUUUUUUS.....",
    "...UUUUUUUU......",
    "...UUUUUUUU......",
    "...uUUUUUUu......",
    "....UU..UU.......",
    "....KK..KK.......",
]
# dalva_vazia: sem túnica, só um xale.
DALVA_XALE = [r.replace("U", "X").replace("u", "x") for r in DALVA]
CICERO = [
    "....RRRRRR.......",
    "...RRrRRRRR......",
    "...RSSSSSSR......",
    "....SKSSKS.......",
    "....SSssSS....g..",
    "...yYYYYYYy..gLg.",
    "..yYYBYYYBYy..g..",
    "..YYYYYYYYYYGGG..",
    "..SYYYYYYYYS.....",
    "...YYYYYYYY......",
    "...yYYYYYYy......",
    "...BBB..BBB......",
    "...BBB..BBB......",
    "...KKK..KKK......",
]
BENEDITA = [
    "...vvvvvv....Y...",
    "..vVVVVVVv...g...",
    "..vVSSSSVv...g...",
    "..vVKSSKVv...g...",
    "...VSssSV....g...",
    "..vVVVVVVv...g...",
    ".vVVVVVVVVv.SgS..",
    ".VVVgVVgVVVV.g...",
    ".VVVVgVVVVV..g...",
    ".VVVVVVVVVV..g...",
    ".vVVVVVVVVv..g...",
    "..VVVVVVVV...g...",
    "..KK....KK.......",
]
# Conjuntos: as peças do Traje da Vigília, repintadas.
SET_TINTS = {
    "aprendiz": (70, 100, 190),   # túnica azul de aprendiz (Dalva)
    "bombeiro": (200, 80, 40),    # casaco chamuscado (Cícero)
    "romeira": (140, 125, 95),    # vestes de romeira (Benedita)
}


def npc_strip(rows: list[str]) -> object:
    idle = A.pad(rows)
    return hstrip([from_grid(g, KEY2, outline=P.OUTLINE) for g in (idle, ["." * A.W] + idle[:-1])])


def tint(image, color: tuple) -> object:
    from PIL import Image  # noqa: PLC0415
    out = image.convert("RGBA").copy()
    pixels = out.load()
    for y in range(out.height):
        for x in range(out.width):
            r, g, b, a = pixels[x, y]
            if a == 0 or max(r, g, b) < 40:
                continue
            light = (r + g + b) / 3 / 255
            pixels[x, y] = (int(color[0] * (0.4 + light)), int(color[1] * (0.4 + light)), int(color[2] * (0.4 + light)), a)
    return out


def main_v051() -> None:
    from PIL import Image  # noqa: PLC0415
    for name, rows in [("dalva_npc", DALVA), ("dalva_xale_npc", DALVA_XALE), ("cicero_npc", CICERO), ("benedita_npc", BENEDITA)]:
        npc_strip(rows).save(os.path.join(SPRITES, f"{name}.png"))
    for set_id, color in SET_TINTS.items():
        for slot in ["capacete", "peitoral", "luvas", "calca", "botas"]:
            base = Image.open(os.path.join(ITEMS, f"armadura_vigilia_{slot}.png"))
            tint(base, color).save(os.path.join(ITEMS, f"armadura_{set_id}_{slot}.png"))


if __name__ == "__main__":
    main_v051()
