"""Etapa 10 (v0.50): os ícones das magias (16×16).

Uma forma por tipo e uma cor por escola:
  feitiço (Dalva) azul · piromancia (Cícero) brasa · milagre (Benedita) ouro.
Rode:  python3 tools/art/magias_etapa10.py
"""
from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from pixel import canvas, from_grid, paste  # noqa: E402
import palette as P  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
ITEMS = os.path.join(ROOT, "assets", "items")

COLORS = {
    "feitico": {"A": (120, 170, 255), "a": (70, 110, 200), "W": (230, 240, 255)},
    "gelo": {"A": (170, 220, 245), "a": (110, 170, 210), "W": (245, 252, 255)},
    "piromancia": {"A": (255, 150, 60), "a": (200, 80, 40), "W": (255, 235, 160)},
    "milagre": {"A": (240, 205, 90), "a": (180, 140, 50), "W": (255, 250, 220)},
}
SHAPES = {
    "orbe": ["...aaa...", "..aAAAa..", ".aAWWAAa.", ".aAWAAAa.", ".aAAAAAa.", "..aAAAa..", "...aaa..."],
    "lamina": [".......aW", "......aWa", ".....aWa.", "....aWa..", "...aWa...", "..aAa....", ".aAa.....", "aAa......"],
    "escudo": ["aaaaaaa", "aAAWAAa", "aAWWWAa", "aAAWAAa", ".aAAAa.", "..aAa..", "...a..."],
    "chama": ["....a....", "...aA....", "..aAAa...", "..aAWAa..", ".aAWWAa..", ".aAWWAAa.", "..aAAAa..", "...aaa..."],
    "chicote": ["aa.......", ".aA......", "..aA..aa.", "...aAaAWa", "....aAa.a", ".........", "........."],
    "explosao": ["a...a...a", ".a..A..a.", "..aAWAa..", "aAAWWWAAa", "..aAWAa..", ".a..A..a.", "a...a...a"],
    "cruz": ["...aa...", "...AW...", "aaaAWaaa", "AWWWWWWA", "aaaAWaaa", "...AW...", "...AW...", "...aa..."],
    "raio": ["....aAa", "...aAa.", "..aAWa.", ".aAWWWa", "...aWa.", "..aAa..", ".aAa...", ".aa...."],
    "tempestade": [".aaaaaa.", "aAAAAAAa", "aAWWAAAa", ".aaaaaa.", "..aA.aA.", ".aA.aA..", "aA.aA...", "a..a...."],
}
ICONS = {
    "projetil_arcano": ("orbe", "feitico"), "lamina_magica": ("lamina", "feitico"),
    "escudo_de_geada": ("escudo", "gelo"), "feitico_dalva": ("orbe", "gelo"),
    "bola_de_fogo": ("chama", "piromancia"), "chicote_de_chamas": ("chicote", "piromancia"),
    "explosao_curta": ("explosao", "piromancia"), "rua_em_chamas": ("explosao", "piromancia"),
    "milagre_cura": ("cruz", "milagre"), "cura_em_area": ("cruz", "milagre"),
    "milagre_barreira": ("escudo", "milagre"), "lanca_de_raio": ("raio", "milagre"),
    "tempestade": ("tempestade", "milagre"),
}


def main() -> None:
    for name, (shape, school) in ICONS.items():
        art = from_grid(SHAPES[shape], COLORS[school], outline=P.OUTLINE)
        icon = canvas(16, 16)
        paste(icon, art, (16 - art.width) // 2, (16 - art.height) // 2)
        icon.save(os.path.join(ITEMS, f"{name}.png"))


if __name__ == "__main__":
    main()
