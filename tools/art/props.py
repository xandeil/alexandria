"""Objetos de cenario, efeitos, icones de interface e icone do app."""
from __future__ import annotations

import math
import random

import palette as P
from pixel import canvas, from_grid, paste, put, rect, hline, vline, ellipse, shade, mix, rgba, upscale

O = P.OUTLINE


# --- Teatro ------------------------------------------------------------------------
def seat(kind: str = "red", broken: bool = False):
    """Poltrona vista de tras (todas olham para o palco, como na referencia)."""
    if kind == "red":
        key = {"a": P.SEAT, "d": P.SEAT_DARK, "l": P.SEAT_LIGHT}
    else:
        key = {"a": P.SEAT_TAN, "d": P.SEAT_TAN_DARK, "l": P.SEAT_TAN_LIGHT}
    key.update({"w": P.WOOD, "W": P.WOOD_DARK})
    grid = [
        "..llllllll..",
        ".laaaaaaaad.",
        "wlaaaaaaaadw",
        "wlaaaaaaaadw",
        "wlaaaaaaaadw",
        "wdaaaaaaaddw",
        "WddddddddddW",
        "W.W......W.W",
        "W.W......W.W",
    ]
    if broken:
        grid = [
            "............",
            "..l.....d...",
            "wla.l..adddw",
            "wlaala.aaadw",
            "wlaaaaaaaadw",
            "wdaaaaaaaddw",
            "WddddddddddW",
            "W.W......W.W",
            "W.W.........",
        ]
    frame = canvas(16, 16)
    paste(frame, from_grid(grid, key, outline=O), 1, 4)
    return frame


def debris():
    """Lascas de madeira de poltronas quebradas (decoracao no chao)."""
    frame = canvas(16, 16)
    rng = random.Random(5)
    for _ in range(4):
        x, y = rng.randint(1, 11), rng.randint(3, 13)
        for i in range(rng.randint(3, 5)):
            put(frame, x + i, y + (i // 2), P.WOOD_DARK)
            put(frame, x + i, y + (i // 2) - 1, P.WOOD)
    return frame


def torch_frames():
    """Tocha de parede (3 quadros)."""
    frames = []
    flames = [
        ["..c..", ".cfc.", ".fhf.", "fhhhf", ".hdh."],
        ["...c.", "..cf.", ".cfhf", ".fhhf", ".hdh."],
        [".c...", ".fc..", ".fhf.", "fhhf.", ".hdh."],
    ]
    for flame in flames:
        frame = canvas(16, 16)
        paste(frame, from_grid(flame, {"c": P.FLAME_CORE, "f": P.FLAME, "h": P.FLAME_HOT, "d": P.FLAME_DARK}), 5, 0)
        base = ["gggg", ".gg.", ".ww.", ".ww.", "wwww"]
        paste(frame, from_grid(base, {"g": P.GOLD_DARK, "w": P.IRON}, outline=O), 5, 5)
        frames.append(frame)
    return frames


def pillar():
    frame = canvas(16, 32)
    key = {"a": P.BRICK, "l": P.STONE_LIGHT, "d": P.MORTAR, "s": P.WALL_SHADOW}
    grid = ["llllllllllll", "adddddddddda"]
    for _ in range(24):
        grid.append(".alaaaaaads.")
    grid += ["llllllllllll", "dddddddddddd", "ssssssssssss"]
    paste(frame, from_grid(grid, key, outline=O), 1, 0)
    return frame


def capsule():
    """Camara do jogador: capsula diante do palco (ponto de descanso)."""
    frame = canvas(32, 24)
    key = {"a": P.CAPSULE, "d": P.CAPSULE_DARK, "l": P.CAPSULE_LIGHT, "g": P.GLASS, "s": P.GLASS_SHINE,
           "G": P.SCREEN_GREEN, "k": P.STEEL_DEEP}
    grid = [
        "..llllllllllllllllllllll..",
        ".laaaaaaaaaaaaaaaaaaaaaad.",
        "laaggggggggggggggggggggaad",
        "laagsgggggggggggggggggggad",
        "laaggsgggggggggggggggggaad",
        "laagggsggggggggggggggggaad",
        "laaggggsgggggggggggggggaad",
        "laaggggggggggggggggggggaad",
        "laagggggggggggggggggggsaad",
        "laaggggggggggggggggggggaad",
        "laaaaaaaaaaaaaaaaaaaaaaaad",
        "daaaaaaaaaaGGaaaaaaaaaaadd",
        "ddddddddddddddddddddddddd.",
        ".kkkk................kkkk.",
    ]
    paste(frame, from_grid(grid, key, outline=O), 2, 6)
    return frame


def forge_frames():
    frames = []
    for i in range(2):
        frame = canvas(32, 32)
        key = {"a": P.BRICK, "d": P.MORTAR, "l": P.STONE_LIGHT, "k": P.ARCH, "f": P.FLAME, "h": P.FLAME_HOT,
               "c": P.FLAME_CORE, "r": P.FLAME_DARK}
        fire_a = ".f..f..f.."
        fire_b = "..f..f..f."
        grid = [
            "....llllllllll....",
            "...laaaaaaaaaad...",
            "..laaaaaaaaaaaad..",
            "..laakkkkkkkkaad..",
            "..laak" + (fire_a if i == 0 else fire_b)[:8] + "aad.."[:4] + "..",
            "..laakfhfchfhkad..",
            "..laakhcchchckad..",
            "..laakrhrhrhrkad..",
            "..laaaaaaaaaaaad..",
            ".laaaaaaaaaaaaaad.",
            ".dddddddddddddddd.",
        ]
        grid = [row[:18].ljust(18, ".") for row in grid]
        paste(frame, from_grid(grid, key, outline=O), 6, 14)
        frames.append(frame)
    return frames


def anvil():
    frame = canvas(16, 16)
    grid = [
        "lllllllll...",
        "aaaaaaaaaaa.",
        ".daaaaaaad..",
        "...daaad....",
        "...daaad....",
        "..ddddddd...",
    ]
    paste(frame, from_grid(grid, {"l": P.IRON_LIGHT, "a": P.IRON, "d": P.STEEL_DEEP}, outline=O), 1, 7)
    return frame


def counter():
    frame = canvas(40, 20)
    key = {"w": P.WOOD, "W": P.WOOD_DARK, "l": shade(P.WOOD, 1.25), "r": (180, 50, 50), "b": (80, 140, 200),
           "g": (110, 190, 110), "c": P.GLASS_SHINE, "s": P.SANITY}
    grid = [
        "...r.......s....b......g...",
        "..rrr.....sss..bbb....ggg..",
        "..rrr.....sss..bbb....ggg..",
        "lllllllllllllllllllllllllll",
        "wwwwwwwwwwwwwwwwwwwwwwwwwww",
        "wWWWWWWWWWWWWWWWWWWWWWWWWWw",
        "wwwwwwwwwwwwwwwwwwwwwwwwwww",
        "wWwwwwwwwwwwwwwwwwwwwwwwwWw",
        "wWwwwwwwwwwwwwwwwwwwwwwwwWw",
        "WWWWWWWWWWWWWWWWWWWWWWWWWWW",
    ]
    paste(frame, from_grid(grid, key, outline=O), 5, 7)
    return frame


def weapon_rack():
    frame = canvas(16, 24)
    key = {"w": P.WOOD, "W": P.WOOD_DARK, "b": P.BLADE, "d": P.BLADE_DARK, "g": P.GOLD_DARK}
    grid = [
        ".b..b..b..",
        ".b..d..b..",
        ".d..b..d..",
        ".b..d..b..",
        ".d..b..d..",
        "gggggggggg",
        "wwwwwwwwww",
        "W.W....W.W",
        "W.W....W.W",
    ]
    paste(frame, from_grid(grid, key, outline=O), 2, 12)
    return frame


# --- Cidade Estilhacada ---------------------------------------------------------
def barricade():
    frame = canvas(32, 20)
    key = {"s": (120, 108, 84), "S": (92, 82, 64), "m": P.IRON, "M": P.IRON_LIGHT, "r": P.RUBBLE_DARK}
    grid = [
        "...MM..........MM.....",
        "...mm..........mm.....",
        ".sssssSsssssSsssssS...",
        "sssSssssssSsssssSssss.",
        "SsssssSssssssSsssssSs.",
        "sssssssSsssssssSsssss.",
        "SSSSSSSSSSSSSSSSSSSSS.",
        "rr.rrr......rr..rrr...",
    ]
    paste(frame, from_grid(grid, key, outline=O), 4, 9)
    return frame


def rubble_pile():
    frame = canvas(16, 16)
    rng = random.Random(9)
    for _ in range(30):
        x, y = rng.randint(2, 13), rng.randint(7, 14)
        c = rng.choice([P.RUBBLE, P.RUBBLE_DARK, P.CONCRETE, P.CONCRETE_LIGHT])
        put(frame, x, y, c)
        put(frame, x + 1, y, shade(c, 0.85))
    return frame


def fire_frames():
    """Fogo que nunca apaga (4 quadros)."""
    frames = []
    for i in range(4):
        frame = canvas(16, 24)
        rng = random.Random(100 + i)
        # brasas/destrocos na base
        for x in range(2, 14):
            put(frame, x, 21, P.RUBBLE_DARK)
            put(frame, x, 22, P.ROCK_DEEP)
            if rng.random() < 0.5:
                put(frame, x, 20, P.EMBER_DARK)
        for layer, (color, height, width) in enumerate([(P.FLAME_DARK, 15, 6), (P.FLAME_HOT, 12, 5), (P.FLAME, 9, 3.5), (P.FLAME_CORE, 5, 2)]):
            for y in range(20 - height, 21):
                t = (20 - y) / height
                half = width * (1 - t) ** 0.8 + 0.5
                wobble = math.sin(y * 0.9 + i * 1.7 + layer) * (1.2 * t)
                cx = 8 + wobble
                for x in range(int(cx - half), int(cx + half) + 1):
                    if rng.random() < 0.92:
                        put(frame, x, y, color)
        # fagulhas
        for _ in range(2):
            put(frame, rng.randint(4, 12), rng.randint(1, 6), P.FLAME)
        frames.append(frame)
    return frames


def lamp_post():
    frame = canvas(16, 40)
    key = {"m": P.IRON, "M": P.IRON_LIGHT, "d": P.STEEL_DEEP, "g": P.WINDOW_GLOW}
    grid = ["MMMMMM...", "mggggm...", ".mmmm....", "..mm....."] + ["..mM....."] * 28 + ["..mm.....", ".dddd....", "dddddd..."]
    paste(frame, from_grid(grid, key, outline=O), 3, 2)
    return frame


def gate():
    """Portao do Detentor do Caos (lacrado; marcas de martelo do outro lado)."""
    frame = canvas(48, 48)
    rect(frame, 2, 4, 46, 47, O)
    rect(frame, 3, 5, 45, 46, P.STEEL_DEEP)
    for x in range(4, 44, 6):
        rect(frame, x, 6, x + 5, 45, P.IRON)
        vline(frame, x, 6, 45, P.IRON_LIGHT)
    for y in (12, 25, 38):
        hline(frame, 3, 45, y, P.STEEL_DEEP)
        for x in range(5, 44, 6):
            put(frame, x, y + 1, P.IRON_LIGHT)
    # amassados (o martelo de Aldir, do outro lado)
    for cx, cy in ((16, 20), (31, 30), (22, 36)):
        ellipse(frame, cx, cy, 4, 3, P.STEEL_DEEP)
        ellipse(frame, cx - 1, cy - 1, 2, 1.5, P.IRON_LIGHT)
    rect(frame, 21, 22, 27, 30, P.GOLD_DARK)
    rect(frame, 22, 23, 26, 29, P.GOLD)
    rect(frame, 23, 25, 25, 28, O)
    return frame


def crate():
    frame = canvas(16, 16)
    key = {"w": P.WOOD, "W": P.WOOD_DARK, "l": shade(P.WOOD, 1.2)}
    grid = ["llllllllll", "wWwwwwwwWw", "wwWwwwwWww", "wwwWwwWwww", "wwwwWWwwww", "wwwWwwWwww", "wwWwwwwWww", "wWwwwwwwWw", "WWWWWWWWWW"]
    paste(frame, from_grid(grid, key, outline=O), 2, 5)
    return frame


def car_wreck():
    frame = canvas(32, 24)
    key = {"a": (92, 70, 64), "d": (60, 46, 44), "r": P.EMBER_DARK, "g": P.GLASS, "k": P.ROCK_DEEP, "m": P.IRON}
    grid = [
        "......dddddddddd.......",
        ".....dggggdggggad......",
        "....daggggdggggaad.....",
        ".ddddaaaaaaaaaaaaaddd..",
        "daaaaaaarraaaaaaaaaaad.",
        "daaaaaaaaaaaaaaraaaaad.",
        "dmmaaaaaaaaaaaaaaaammd.",
        ".kkk.............kkk...",
    ]
    paste(frame, from_grid(grid, key, outline=O), 4, 11)
    return frame


# --- Ceu, luz e particulas ---------------------------------------------------------
def cloud(seed: int, w: int, h: int):
    rng = random.Random(seed)
    img = canvas(w, h)
    blobs = [(rng.uniform(w * 0.2, w * 0.8), rng.uniform(h * 0.45, h * 0.7), rng.uniform(h * 0.25, h * 0.5)) for _ in range(7)]
    for (cx, cy, r) in blobs:
        ellipse(img, cx, cy + 1.5, r * 1.3, r * 0.8, P.CLOUD_DEEP)
    for (cx, cy, r) in blobs:
        ellipse(img, cx, cy, r * 1.3, r * 0.8, P.CLOUD_SHADOW)
    for (cx, cy, r) in blobs:
        ellipse(img, cx - 1, cy - 1.5, r * 1.1, r * 0.6, P.CLOUD)
    return img


def light_texture(size: int = 128):
    img = canvas(size, size)
    c = size / 2
    for y in range(size):
        for x in range(size):
            d = math.hypot(x + 0.5 - c, y + 0.5 - c) / c
            a = max(0.0, 1.0 - d)
            a = a * a * (3 - 2 * a)  # smoothstep
            put(img, x, y, (255, 255, 255, int(255 * a)))
    return img


def particle_square(size: int, color: tuple):
    img = canvas(size, size)
    rect(img, 0, 0, size, size, color)
    return img


def soft_dot(size: int, color: tuple):
    img = canvas(size, size)
    c = size / 2
    for y in range(size):
        for x in range(size):
            d = math.hypot(x + 0.5 - c, y + 0.5 - c) / c
            if d <= 1:
                put(img, x, y, (*color[:3], int(255 * (1 - d) ** 0.6)))
    return img


def shadow_blob(w: int = 14, h: int = 6):
    img = canvas(w, h)
    ellipse(img, w / 2, h / 2, w / 2, h / 2, (0, 0, 0, 90))
    return img


# --- Icones de interface (16x16, aparecem 2x nos botoes) ------------------------
def icon_attack():
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
    return _icon(grid, {"l": P.BLADE, "b": P.BLADE_DARK, "g": P.GOLD, "f": P.GRIP})


def icon_dash():
    grid = [
        "....ww....ww..",
        ".....ww....ww.",
        "......ww....ww",
        ".......ww....w",
        "......ww....ww",
        ".....ww....ww.",
        "....ww....ww..",
    ]
    return _icon(grid, {"w": (230, 236, 244)}, pad_y=4)


def _flask(liquid, liquid_dark):
    grid = [
        ".....kk.....",
        ".....cc.....",
        "....gccg....",
        "....g..g....",
        "...g....g...",
        "..g.LLLL.g..",
        ".gLLLLLLLLg.",
        ".gLlLLLLLLg.",
        ".gLLLLLLLDg.",
        ".gLLLLLLDDg.",
        "..gDDDDDDg..",
        "...gggggg...",
    ]
    return {"k": P.WOOD_DARK, "c": P.WOOD, "g": (200, 214, 222), "L": liquid, "l": (255, 255, 255), "D": liquid_dark}, grid


def icon_heal():
    key, grid = _flask((196, 52, 56), (130, 26, 34))
    return _icon(grid, key)


def icon_sanity():
    key, grid = _flask(P.SANITY, (170, 180, 196))
    return _icon(grid, key)


def icon_interact():
    grid = [
        "....ll......",
        "...lwwl.....",
        "...lwwl.....",
        "...lwwlll...",
        "...lwwwwwll.",
        ".ll.lwwwwwwl",
        "lwwllwwwwwwl",
        "lwwwwwwwwwwl",
        ".lwwwwwwwwl.",
        "..lwwwwwwl..",
        "...llllll...",
    ]
    return _icon(grid, {"l": (120, 128, 140), "w": (236, 240, 246)})


def icon_memory():
    grid = [
        "....l....",
        "...lwl...",
        "..lwwwl..",
        ".lwwwwbl.",
        "lwwwwwbbl",
        ".lwwwbbl.",
        "..lwwbl..",
        "...lbl...",
        "....l....",
    ]
    return _icon(grid, {"l": (150, 160, 180), "w": P.MEMORY, "b": (180, 190, 210)})


def icon_pause():
    grid = ["ww..ww"] * 8
    return _icon(grid, {"w": (230, 236, 244)}, pad_y=4)


def _icon(grid, key, pad_y=None):
    img = canvas(16, 16)
    sprite = from_grid(grid, key, outline=O)
    x = (16 - sprite.width) // 2
    y = (16 - sprite.height) // 2 if pad_y is None else pad_y - 1
    paste(img, sprite, x, y)
    return img


# --- Icone do aplicativo -------------------------------------------------------------
def app_icon_island(size: int = 32, with_sky: bool = True):
    """Ilha flutuante com o Teatro em ruinas no topo (32x32, ampliado depois).
    with_sky=False: só a ilha, fundo transparente (frente do ícone adaptativo)."""
    img = canvas(size, size)
    if with_sky:
        for y in range(size):
            t = y / size
            hline(img, 0, size, y, mix(P.SKY_TOP, P.SKY_BOTTOM, t))
        ellipse(img, 6, 27, 8, 3, P.CLOUD)
        ellipse(img, 26, 28, 9, 3, P.CLOUD_SHADOW)
    # ilha (rocha invertida)
    for y in range(17, 29):
        half = 12 - (y - 17) * 1.05
        for x in range(int(16 - half), int(16 + half) + 1):
            put(img, x, y, P.ROCK_DARK if (x + y) % 3 else P.ROCK)
    hline(img, 3, 29, 16, P.GRASS)
    hline(img, 4, 28, 17, P.GRASS_LIGHT)
    # teatro (arco de pedra)
    rect(img, 9, 8, 23, 16, P.BRICK)
    rect(img, 13, 10, 19, 16, P.ARCH)
    hline(img, 8, 24, 7, P.STONE_LIGHT)
    rect(img, 9, 5, 11, 8, P.BRICK)
    rect(img, 21, 5, 23, 8, P.BRICK)
    rect(img, 14, 12, 18, 16, P.CURTAIN)
    put(img, 16, 13, P.FLAME_CORE)
    # raizes
    for x in (8, 13, 19, 24):
        vline(img, x, 24, 30, P.ROOT)
    return img
