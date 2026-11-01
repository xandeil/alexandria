"""Aliados da Etapa 7 (v0.42): Lúcia, Galeno, Tião e Bastião (e o Heitor, Etapa 8).

Cada um sai em dois arquivos:
  • <id>_aliado.png — tira de 4 quadros 18×24 (idle, walk, golpe, caido), usada
    pelo SpriteFrames do aliado em luta (Ally);
  • <id>_npc.png    — tira de 2 quadros (parado, respirando), usada pelo NPC.

Silhuetas que se leem de longe:
  Lúcia   — capuz e uma faixa de pano sobre os olhos; meio pingente no peito.
  Galeno  — enorme, barbudo, escudo gigante (por dentro, um desenho a giz).
  Tião    — baixinho e redondo, panela na cabeça, colher de pau enorme.
  Bastião — alto e magro, tampa de bueiro como escudo, vassoura com faca.

Rode:  python3 tools/art/aliados_etapa7.py
"""
from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from pixel import from_grid, hstrip  # noqa: E402
import palette as P  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
SPRITES = os.path.join(ROOT, "assets", "sprites")

W, H = 18, 24

COMMON = {"S": (214, 170, 140), "s": (170, 124, 100), "K": (36, 30, 34), "W": (232, 228, 220)}


def pad(rows: list[str]) -> list[str]:
    """Centraliza cada desenho numa caixa W×H (pés no chão)."""
    rows = [r.ljust(max(len(x) for x in rows), ".") for r in rows]
    width = len(rows[0])
    left = (W - width) // 2
    out = ["." * left + r + "." * (W - width - left) for r in rows]
    return ["." * W] * (H - len(out)) + out


def shift_legs(rows: list[str], legs_from: int) -> list[str]:
    """Quadro de caminhada: as pernas abrem um pixel."""
    out = rows[:]
    for i in range(legs_from, len(rows)):
        r = rows[i]
        mid = len(r) // 2
        out[i] = r[1:mid] + "." + "." + r[mid:-1]
    return out


def fallen(rows: list[str]) -> list[str]:
    """De joelhos: o corpo desce e encolhe (as 4 últimas linhas somem)."""
    body = rows[:-4]
    return ["." * W] * 4 + body


# --- Lúcia ---------------------------------------------------------------------------
LUCIA_KEY = {**COMMON, "H": (92, 84, 108), "h": (64, 58, 78), "B": (210, 206, 196), "C": (120, 110, 132),
             "c": (84, 76, 96), "G": (196, 168, 90), "M": (170, 170, 180)}
LUCIA = [
    "....hhhhhh....",
    "...hHHHHHHh...",
    "..hHHHHHHHHh..",
    "..hHBBBBBBHh..",
    "..hHSSSSSSHh..",
    "...hSSssSSh...",
    "....hSSSSh....",
    "...cCCCCCCc...",
    "..cCCCGCCCCcM.",
    "..cCCCCCCCCcM.",
    "..sCCCCCCCCsM.",
    "...CCCCCCCC.M.",
    "...cCCCCCCc.M.",
    "...cCCCCCCc...",
    "...cCC..CCc...",
    "....CC..CC....",
    "....KK..KK....",
]
LUCIA_HIT = [r[:-2] + "MM" if 7 <= i <= 9 else r for i, r in enumerate(LUCIA)]

# --- Galeno --------------------------------------------------------------------------
GALENO_KEY = {**COMMON, "A": (150, 150, 160), "a": (100, 100, 112), "D": (110, 70, 40), "d": (80, 50, 28),
              "R": (130, 96, 70), "r": (96, 70, 50), "Y": (226, 222, 210), "M": (170, 170, 180)}
GALENO = [
    "....rrrrrr......",
    "...rRRRRRRr.....",
    "...RSSSSSSR.....",
    "...SKSSSSKS.....",
    "...SSSSSSSS.....",
    "...DDDDDDDD.....",
    "..dDDDDDDDDd....",
    ".AAAAAAAAAAAAaa.",
    "aAAAAAAAAAAAaYYa",
    "aAAAAAAAAAAAaYYa",
    "aAAaAAAAAAaAaYYa",
    "aAAAAAAAAAAAaYYa",
    ".AAAAAAAAAAAAaa.",
    "..aAAAAAAAAa....",
    "..aAAA..AAAa....",
    "..AAA....AAA....",
    "..KKK....KKK....",
]

# --- Tião ----------------------------------------------------------------------------
TIAO_KEY = {**COMMON, "P": (150, 150, 160), "p": (100, 100, 112), "O": (196, 120, 60), "o": (150, 86, 40),
            "L": (176, 132, 82), "l": (130, 94, 56)}
TIAO = [
    "....pppppp.....",
    "...pPPPPPPp.pp.",
    "...pPPPPPPppp..",
    "....SSSSSS.....",
    "...SKSSSSKS..L.",
    "...SSSssSSS.LL.",
    "..oOOOOOOOOolL.",
    ".oOOOOOOOOOOlo.",
    ".OOOOOOOOOOOO..",
    ".OOOOOOOOOOOO..",
    ".oOOOOOOOOOOo..",
    "..oOOOOOOOOo...",
    "...OOO..OOO....",
    "...KKK..KKK....",
]

# --- Bastião -------------------------------------------------------------------------
BASTIAO_KEY = {**COMMON, "N": (90, 96, 108), "n": (60, 66, 76), "V": (110, 120, 90), "v": (78, 86, 62),
               "B": (176, 150, 100), "M": (190, 190, 200)}
BASTIAO = [
    "......SSSS........",
    ".....SSSSSS.......",
    ".....SKSSKS....M..",
    ".....SSssSS....M..",
    "......SSSS.....B..",
    ".....vVVVVv....B..",
    "..nn.VVVVVV....B..",
    ".nNNnVVVVVVs...B..",
    ".NNNNVVVVVV....B..",
    ".NNNNVVVVVV....B..",
    ".nNNnVVVVVV...BBB.",
    "..nn.vVVVVv...BBB.",
    "......VV.VV.......",
    "......VV.VV.......",
    "......VV.VV.......",
    "......VV.VV.......",
    "......KK.KK.......",
]


# --- Heitor (Etapa 8) ------------------------------------------------------------------
HEITOR_KEY = {**COMMON, "A": (140, 150, 168), "a": (96, 104, 122), "w": (240, 240, 236), "R": (214, 176, 72),
              "B": (90, 70, 56), "M": (190, 190, 200)}
HEITOR = [
    "....wwwwww.....",
    "...wwwwwwww....",
    "...wSSSSSSw....",
    "...SKSSSSKS....",
    "...SSSssSSS....",
    "..aAAAAAAAAa...",
    ".aAAAAAAAAAAa..",
    "aAAAAAAAAAAAAaM",
    "aAAAaAAAAaAAAaM",
    "SAAAAAAAAAAAASM",
    "RAAAAAAAAAAAA.M",
    ".aAAAAAAAAAAa..",
    "..aAAA..AAAa...",
    "..AAA....AAA...",
    "..BBB....BBB...",
]


def strip(rows: list[str], key: dict, hit_rows: list[str] | None = None) -> tuple:
    idle = pad(rows)
    walk = shift_legs(idle, H - 4)
    hit = pad(hit_rows) if hit_rows else [r[2:] + ".." for r in idle]
    down = fallen(idle)
    frames = [from_grid(g, key, outline=P.OUTLINE) for g in (idle, walk, hit, down)]
    npc = [from_grid(g, key, outline=P.OUTLINE) for g in (idle, ["." * W] + idle[:-1])]
    return hstrip(frames), hstrip(npc)


def main() -> None:
    specs = {
        "lucia": (LUCIA, LUCIA_KEY, LUCIA_HIT),
        "galeno": (GALENO, GALENO_KEY, None),
        "tiao": (TIAO, TIAO_KEY, None),
        "bastiao": (BASTIAO, BASTIAO_KEY, None),
        "heitor": (HEITOR, HEITOR_KEY, None),
    }
    for name, (rows, key, hit) in specs.items():
        fight, npc = strip(rows, key, hit)
        fight.save(os.path.join(SPRITES, f"{name}_aliado.png"))
        npc.save(os.path.join(SPRITES, f"{name}_npc.png"))


if __name__ == "__main__":
    main()
