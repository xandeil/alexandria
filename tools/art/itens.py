"""Itens do inventario: icones 16x16 (menu e chao) e o escudo do heroi.

Biblia: "Sistemas a programar: 7. Inventario"; o Ferreiro "melhora armas";
o Orbe Branco "purifica fragmentos e aumenta os frascos de vida"; combate com
"mao direita e esquerda".
"""
from __future__ import annotations

import palette as P
from pixel import canvas, from_grid, paste
from props import _icon
from characters import SHIELD_GRID

O = P.OUTLINE


def icon_sucata():
    """Sucata Temperada: lascas de aco tortas, com um rebite e ferrugem."""
    grid = [
        ".......kk...",
        "......kIIk..",
        ".....kIiIk..",
        "....kIiiIk..",
        "..kkIiiIk...",
        ".kIIiiIkr...",
        "kIiiiIkrr...",
        "kIIiIkrr.kk.",
        ".kIIkr..kIIk",
        "..kkr..kIiIk",
        ".......kIIk.",
        "........kk..",
    ]
    return _icon(grid, {"k": P.STEEL_DEEP, "I": P.IRON_LIGHT, "i": P.IRON, "r": P.EMBER_DARK})


def icon_fragmento():
    """Fragmento Turvo: caco de frasco opaco, com fumaca de lembrancas dentro."""
    grid = [
        "......g.....",
        ".....gwg....",
        "....gwmwg...",
        "....gmmdg...",
        "...gwmddmg..",
        "...gmddmwg..",
        "..gwmdmmmg..",
        "..gmmmdwmg..",
        ".gwmdmmmg...",
        ".gmmmwmg....",
        "..gggggg....",
    ]
    return _icon(grid, {"g": (200, 214, 222), "w": (240, 244, 248), "m": (150, 150, 160), "d": (92, 88, 102)})


def escudo_sprite():
    """O Escudo Remendado na mao do heroi (mesmo molde do escudo dos soldados,
    mas com o brasao RASPADO: so ficou a marca do arranhao)."""
    grid = [row.replace("v", "x") for row in SHIELD_GRID]
    key = {"L": P.SHIELD_LIGHT, "S": P.SHIELD, "d": P.SHIELD_DARK, "x": P.STEEL_DARK,
           "a": P.PATCH_B, "p": P.PATCH_C}
    return from_grid(grid, key, outline=O)


def icon_escudo():
    img = canvas(16, 16)
    sprite = escudo_sprite()
    paste(img, sprite, (16 - sprite.width) // 2, (16 - sprite.height) // 2)
    return img


def icon_block():
    """Botao de toque da defesa: silhueta branca do escudo."""
    grid = [
        ".wwwwwww.",
        "wwwwwwwww",
        "wwwwwwwww",
        "wwwbbbwww",
        "wwwbbbwww",
        "wwwwwwwww",
        "wwwwwwwww",
        ".wwwwwww.",
        "..wwwww..",
        "...www...",
    ]
    return _icon(grid, {"w": (230, 236, 244), "b": (160, 170, 186)})


def icon_espada():
    grid = [
        "...........ll",
        "..........lbl",
        ".........lbl.",
        "........lbl..",
        ".......lbl...",
        "......lbl....",
        ".g...lbl.....",
        "..g.lbl......",
        "...gbl.......",
        "...ggg.......",
        "..f.gg.......",
        ".f...g.......",
        "f............",
    ]
    return _icon(grid, {"l": P.BLADE, "b": P.BLADE_DARK, "g": P.GOLD_DARK, "f": P.GRIP})


def icon_apito():
    """O apito do Sargento, preso num cordao vermelho."""
    grid = [
        "..rr........",
        ".r..r.......",
        "r....r......",
        "r.....r.....",
        ".r.....r....",
        "..r....kGGGk",
        "...r..kGgggG",
        "....rkGggkgG",
        ".....kGgggGk",
        "......kGGGk.",
    ]
    return _icon(grid, {"r": P.SARGE_RED, "k": P.GOLD_DARK, "G": P.GOLD, "g": (250, 226, 150)})


def icon_lembranca(core, edge):
    """Lembranca de um Pecado: a gota de memoria tingida pela cor do chefe."""
    grid = [
        "....l....",
        "...lwl...",
        "..lwccl..",
        ".lwccccl.",
        "lwccccbbl",
        ".lcccbbl.",
        "..lccbl..",
        "...lbl...",
        "....l....",
    ]
    return _icon(grid, {"l": edge, "w": (255, 255, 255), "c": core, "b": edge})
