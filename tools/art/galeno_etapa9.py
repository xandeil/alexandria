"""Etapa 9 (v0.48): Galeno, O Escudo Que Chegou Tarde.

  • assets/sprites/galeno_chefe.png (+ _frames.tres) — com o escudo (fase 1);
  • assets/sprites/galeno_sem_escudo.png (+ _frames.tres) — fase 2: "Não tem
    mais nada atrás de mim." (o escudo vira um objeto no chão);
  • assets/props/escudo_jogado.png — o escudo largado na arena;
  • assets/items/escudo_sem_dono.png — a recompensa.

Usa o desenho do Galeno de aliados_etapa7.py. Rode:  python3 tools/art/galeno_etapa9.py
"""
from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from pixel import canvas, from_grid, paste  # noqa: E402
import palette as P  # noqa: E402
import aliados_etapa7 as A  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
SPRITES = os.path.join(ROOT, "assets", "sprites")
PROPS = os.path.join(ROOT, "assets", "props")
ITEMS = os.path.join(ROOT, "assets", "items")

# Sem o escudo: some a parte do escudo (colunas 13+) e o braço fica livre.
SEM_ESCUDO = [r[:13].ljust(16, ".") if 7 <= i <= 12 else r for i, r in enumerate(A.GALENO)]
SEM_ESCUDO = [r.replace("Y", "A") for r in SEM_ESCUDO]

ESCUDO_KEY = {"A": (150, 150, 160), "a": (100, 100, 112), "Y": (226, 222, 210), "K": (36, 30, 34)}
ESCUDO = [
    ".aaaaaaaa.",
    "aAAAAAAAAa",
    "aAYYYYYYAa",
    "aAYKYYKYAa",
    "aAYYYYYYAa",
    "aAYKKKKYAa",
    "aAYYYYYYAa",
    "aAAAAAAAAa",
    ".aAAAAAAa.",
    "..aaaaaa..",
]


def frames_tres(name: str, w: int, h: int) -> str:
    subs = "".join(f'[sub_resource type="AtlasTexture" id="AtlasTexture_{i}"]\natlas = ExtResource("1_tex")\n'
                   f"region = Rect2({i * w}, 0, {w}, {h})\n\n" for i in range(4))
    anim = ('[{"frames": [{"duration": 1.0, "texture": SubResource("AtlasTexture_0")}], "loop": true, "name": &"idle", "speed": 5.0}, '
            '{"frames": [{"duration": 1.0, "texture": SubResource("AtlasTexture_0")}, {"duration": 1.0, "texture": SubResource("AtlasTexture_1")}], "loop": true, "name": &"walk", "speed": 7.0}, '
            '{"frames": [{"duration": 1.0, "texture": SubResource("AtlasTexture_2")}], "loop": true, "name": &"golpe", "speed": 5.0}, '
            '{"frames": [{"duration": 1.0, "texture": SubResource("AtlasTexture_3")}], "loop": false, "name": &"caido", "speed": 5.0}]')
    return (f'[gd_resource type="SpriteFrames" load_steps=6 format=3]\n\n'
            f'[ext_resource type="Texture2D" path="res://assets/sprites/{name}.png" id="1_tex"]\n\n'
            f"{subs}[resource]\nanimations = {anim}\n")


def main() -> None:
    for name, rows in [("galeno_chefe", A.GALENO), ("galeno_sem_escudo", SEM_ESCUDO)]:
        fight, _npc = A.strip(rows, A.GALENO_KEY)
        fight.save(os.path.join(SPRITES, f"{name}.png"))
        w = fight.width // 4
        open(os.path.join(SPRITES, f"{name}_frames.tres"), "w", encoding="utf-8").write(frames_tres(name, w, fight.height))
    shield = from_grid(ESCUDO, ESCUDO_KEY, outline=P.OUTLINE)
    shield.save(os.path.join(PROPS, "escudo_jogado.png"))
    icon = canvas(16, 16)
    paste(icon, shield, 2, 2)
    icon.save(os.path.join(ITEMS, "escudo_sem_dono.png"))


if __name__ == "__main__":
    main()
