"""Etapa 11 (v0.52): Amaro Bonfim e o Pitoco.

  • assets/sprites/amaro_npc.png       — bonachão, careca, bigode, colete limpo, luvas;
  • assets/sprites/pitoco.png (+ _frames.tres) — o "cachorro" de tentáculos com uma
    boca enorme: idle, walk (os tentáculos abanam), golpe (boca aberta), caido;
  • assets/props/buraco_gritos.png     — o buraco da Varanda (gritos lá de baixo);
  • assets/items/botao_arrancado.png   — o presente do Amaro nas Forjas.

Rode:  python3 tools/art/amaro_pitoco_etapa11.py
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

KEY = {**A.COMMON, "V": (120, 40, 50), "v": (86, 28, 36), "C": (236, 232, 224), "B": (60, 44, 34),
       "G": (40, 40, 44), "Y": (214, 176, 72), "N": (70, 60, 80), "n": (50, 42, 58),
       "T": (150, 90, 120), "t": (110, 60, 90), "M": (60, 20, 30), "R": (220, 120, 130), "W": (240, 236, 220),
       "K2": (0, 0, 0), "H": (20, 16, 18), "h": (44, 36, 40), "o": (120, 100, 70)}

AMARO = [
    "....SSSSSS.......",
    "...SSSSSSSS......",
    "...SKSSSSKS......",
    "...SSSssSSS......",
    "...SBBBBBBS......",
    "....SSSSSS.......",
    "..CVVVVVVVVC.....",
    ".CCVVYVVYVVCC....",
    ".CCVVVVVVVVCC....",
    ".GCVVYVVYVVCG....",
    "..CVVVVVVVVC.....",
    "...NNNNNNNN......",
    "...NNN..NNN......",
    "...NNN..NNN......",
    "...GGG..GGG......",
]

PITOCO = [
    "......T....T......T....T......",
    ".....tT...tT.....tT...tT......",
    "....tTTTTTTTTTTTTTTTTTTTt.....",
    "...tTTTTTTTTTTTTTTTTTTTTTt....",
    "..tTTTTKTTTTTTTTTTTTKTTTTTt...",
    "..TTTTTTTTTTTTTTTTTTTTTTTTT...",
    ".tTTTMMMMMMMMMMMMMMMMMMTTTTt..",
    ".TTTMWMWMWMWMWMWMWMWMWMMTTT...",
    ".TTTMMMMMMMMMMMMMMMMMMMMTTT...",
    ".TTTMRRRRRRRRRRRRRRRRRRMTTT...",
    ".tTTMMWMWMWMWMWMWMWMWMMMTTt...",
    "..TTTTMMMMMMMMMMMMMMMMTTTT....",
    "..tTTTTTTTTTTTTTTTTTTTTTTt....",
    "...TtT.tTt.tTt..tTt.tTt.Tt....",
    "...Tt..tT..tT...tT..tT..Tt....",
    "..tT..tT..tT...tT..tT..tT.....",
]
# Boca aberta (o "buscar" e a lambida): a fileira de dentes de cima sobe.
PITOCO_OPEN = PITOCO[:6] + [
    ".tTTMWMWMWMWMWMWMWMWMWMMTTTt..",
    ".TTTMMMMMMMMMMMMMMMMMMMMTTT...",
    ".TTTMMMMMMMMMMMMMMMMMMMMTTT...",
    ".TTTMRRRRRRRRRRRRRRRRRRMTTT...",
    ".TTTMRRRRRRRRRRRRRRRRRRMTTT...",
] + PITOCO[10:]

BURACO = [
    "....hhhhhhhhhhhh....",
    "..hhHHHHHHHHHHHHhh..",
    ".hHHHHHHHHHHHHHHHHh.",
    "hHHHHHHHHHHHHHHHHHHh",
    "hHHHHHHHHHHHHHHHHHHh",
    ".hHHHHHHHHHHHHHHHHh.",
    "..hhHHHHHHHHHHHHhh..",
    "....hhhhhhhhhhhh....",
]

BOTAO = ["..oooo..", ".oYYYYo.", "oYKYYKYo", "oYYYYYYo", "oYKYYKYo", ".oYYYYo.", "..oooo..", "...o...."]

FW, FH = 34, 22


def frame(rows: list[str]) -> object:
    image = canvas(FW, FH)
    art = from_grid(rows, KEY, outline=P.OUTLINE)
    paste(image, art, (FW - art.width) // 2, FH - art.height)
    return image


def wag(rows: list[str]) -> list[str]:
    """As pernas/tentáculos de baixo trocam de lado (andar abanando)."""
    return rows[:-3] + [r[1:] + "." for r in rows[-3:]]


def main() -> None:
    idle = A.pad(AMARO)
    hstrip([from_grid(g, KEY, outline=P.OUTLINE) for g in (idle, ["." * A.W] + idle[:-1])]).save(
        os.path.join(SPRITES, "amaro_npc.png"))
    down = ["." * len(PITOCO[0])] * 4 + PITOCO[:-4]
    strip = hstrip([frame(PITOCO), frame(wag(PITOCO)), frame(PITOCO_OPEN), frame(down)])
    strip.save(os.path.join(SPRITES, "pitoco.png"))
    subs = "".join(f'[sub_resource type="AtlasTexture" id="AtlasTexture_{i}"]\natlas = ExtResource("1_tex")\n'
                   f"region = Rect2({i * FW}, 0, {FW}, {FH})\n\n" for i in range(4))
    anim = ('[{"frames": [{"duration": 1.0, "texture": SubResource("AtlasTexture_0")}, {"duration": 1.0, "texture": SubResource("AtlasTexture_1")}], "loop": true, "name": &"idle", "speed": 4.0}, '
            '{"frames": [{"duration": 1.0, "texture": SubResource("AtlasTexture_0")}, {"duration": 1.0, "texture": SubResource("AtlasTexture_1")}], "loop": true, "name": &"walk", "speed": 9.0}, '
            '{"frames": [{"duration": 1.0, "texture": SubResource("AtlasTexture_2")}], "loop": true, "name": &"golpe", "speed": 5.0}, '
            '{"frames": [{"duration": 1.0, "texture": SubResource("AtlasTexture_3")}], "loop": false, "name": &"caido", "speed": 5.0}]')
    open(os.path.join(SPRITES, "pitoco_frames.tres"), "w", encoding="utf-8").write(
        f'[gd_resource type="SpriteFrames" load_steps=6 format=3]\n\n'
        f'[ext_resource type="Texture2D" path="res://assets/sprites/pitoco.png" id="1_tex"]\n\n'
        f"{subs}[resource]\nanimations = {anim}\n")
    from_grid(BURACO, KEY, outline=None).save(os.path.join(PROPS, "buraco_gritos.png"))
    icon = canvas(16, 16)
    paste(icon, from_grid(BOTAO, KEY, outline=P.OUTLINE), 3, 3)
    icon.save(os.path.join(ITEMS, "botao_arrancado.png"))


if __name__ == "__main__":
    main()
