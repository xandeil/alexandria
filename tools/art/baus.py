"""Baús, mímicos, placas das cápsulas e itens da Etapa 3 (v0.33).

O MÍMICO É O BAÚ ESPELHADO: o baú comum tem detalhes assimétricos fáceis de
notar — fechadura deslocada para a DIREITA, correia só do lado ESQUERDO,
arranhão no canto direito da tampa. O mímico usa a mesma imagem virada
(flip_h): tudo do lado contrário. Quem presta atenção percebe.

Rode:  python3 tools/art/baus.py
"""
from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from pixel import from_grid  # noqa: E402
from PIL import Image  # noqa: E402
import palette as P  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
PROPS = os.path.join(ROOT, "assets", "props")
ITEMS = os.path.join(ROOT, "assets", "items")

WOOD = {"W": (120, 80, 46), "w": (92, 60, 34), "d": (66, 42, 24), "M": (150, 150, 160), "m": (96, 98, 110),
        "L": (214, 176, 72), "l": (150, 116, 40), "S": (60, 40, 24), "x": (180, 140, 100),
        "T": (236, 228, 212), "R": (170, 40, 52), "r": (110, 22, 34), "K": (30, 14, 18)}

CHEST_CLOSED = [
    "MWWWWWWWWWWWWWM",
    "MWWWWWWWWWWWxWM",
    "MwwwwwwwwwwwwxM",
    "MMMMMMMMMMMMMMM",
    "MSWWWWWWWWLLWWM",
    "MSWWWWWWWWLlWWM",
    "MSwwwwwwwwwwwwM",
    "MSWWWWWWWWWWWWM",
    "MSwwwwwwwwwwwwM",
    "MMMMMMMMMMMMMMM",
]
CHEST_OPEN = [
    "MdddddddddddddM",
    "MdddddddddddddM",
    "MMMMMMMMMMMMMMM",
    "M.............M",
    "MMMMMMMMMMMMMMM",
    "MSWWWWWWWWWWWWM",
    "MSwwwwwwwwwwwwM",
    "MSWWWWWWWWWWWWM",
    "MSwwwwwwwwwwwwM",
    "MMMMMMMMMMMMMMM",
]
CHEST_BROKEN = [
    "...............",
    "...............",
    "..W....w.......",
    "M..MMM.....MM.M",
    "MSW..WWW.LWWW.M",
    "MSWW.WW...WWWWM",
    "MSwwww.wwww.wwM",
    "MS.WWWWW.WWWW.M",
    "MSwwwwwwwwwwwwM",
    "MMMMMMMMMMMMMMM",
]
# O mímico acordado: a tampa vira boca, com dentes e língua.
MIMIC_OPEN = [
    "MWWWWWWWWWWWWWM",
    "MwwwwwwwwwwwwwM",
    "MTKTKTKTKTKTKTM",
    "MKKKKRRRRRKKKKM",
    "MKKRRRrrrRRRKKM",
    "MTKTKTKTKTKTKTM",
    "MSWWWWWWWWWWWWM",
    "MSwwwwwwwwwwwwM",
    "MSWWWWWWWWWWWWM",
    "MMMMMMMMMMMMMMM",
]

PLAQUE = [
    "mmmmmmmm",
    "mMMMMMMm",
    "mMmMmMMm",
    "mMMMMMMm",
    "mmmmmmmm",
    "...ll...",
    "...ll...",
]

ICONS = {
    "algo_quebrado": (["..WW.....", ".WwW..ww.", "WwwW.Ww..", ".WW..W...", "...ww..W.", "..Ww..ww.", ".ww.W...."],
                      {"W": (140, 120, 104), "w": (98, 84, 72)}),
    "fita_desbotada": ([".RR...RR.", "RrrR.RrrR", ".RRRRRRR.", "...RRR...", "..R...R..", ".R.....R."],
                       {"R": (200, 150, 160), "r": (160, 110, 120)}),
    "dente_de_leite": (["..TTTT..", ".TTTTTT.", ".TTTTTT.", "..TTTT..", "..T..T..", "..T..T.."],
                       {"T": (236, 230, 214)}),
    "bilhete_dobrado": (["PPPPPPP.", "PpppppPP", "PPPPPPPp", "PpppppPP", "PPPPPPP."],
                        {"P": (228, 220, 196), "p": (120, 110, 100)}),
    "botao_de_casaco": (["..BBBB..", ".BbbbbB.", "BbB..BbB", "Bbb..bbB", ".BbbbbB.", "..BBBB.."],
                        {"B": (120, 84, 56), "b": (160, 116, 78)}),
    "bolinha_de_gude": (["..GGG..", ".GgGGG.", "GgGGGGG", "GGGGgGG", ".GGGGG.", "..GGG.."],
                        {"G": (80, 150, 200), "g": (220, 240, 255)}),
    "oculos_rachados": (["OOOO.OOOO", "OggO.OgxO", "OggOOOxgO", "OOOO.OOOO"],
                        {"O": (60, 60, 70), "g": (170, 200, 220), "x": (240, 250, 255)}),
}


def main() -> None:
    os.makedirs(PROPS, exist_ok=True)
    for name, grid in [("bau_fechado", CHEST_CLOSED), ("bau_aberto", CHEST_OPEN), ("bau_quebrado", CHEST_BROKEN),
                       ("mimico_aberto", MIMIC_OPEN)]:
        from_grid(grid, WOOD, outline=P.OUTLINE).save(os.path.join(PROPS, name + ".png"))
    from_grid(PLAQUE, WOOD, outline=P.OUTLINE).save(os.path.join(PROPS, "placa_capsula.png"))
    for name, (grid, key) in ICONS.items():
        image = from_grid(grid, key, outline=P.OUTLINE)
        canvas = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
        canvas.paste(image, ((16 - image.width) // 2, (16 - image.height) // 2))
        canvas.save(os.path.join(ITEMS, name + ".png"))
    print("baús, mímico, placa e itens gerados")


if __name__ == "__main__":
    main()
