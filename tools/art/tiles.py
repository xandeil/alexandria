"""Tilesets 16x16 gerados proceduralmente (ruido controlado por semente).

O layout do atlas (coluna, linha) e espelhado em scripts/world/level.gd —
se mudar a ordem aqui, atualize TILE_* la.
"""
from __future__ import annotations

import random

import palette as P
from pixel import canvas, put, rect, hline, vline, mix, shade, rgba

T = 16


def _noise(img, x0, y0, base, alts, chance, rng, w=T, h=T):
    for y in range(y0, y0 + h):
        for x in range(x0, x0 + w):
            c = base
            if rng.random() < chance:
                c = rng.choice(alts)
            put(img, x, y, c)


def stone_tile(img, ox, oy, seed, cracked=False, debris=False):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.STONE, [P.STONE_ALT, P.STONE_ALT, P.STONE_LIGHT], 0.18, rng)
    # Laje com rejunte: borda superior e esquerda escuras, inferior/direita clara.
    hline(img, ox, ox + T, oy, P.STONE_GROUT)
    vline(img, ox, oy, oy + T, P.STONE_GROUT)
    hline(img, ox + 1, ox + T, oy + 1, P.STONE_LIGHT)
    # Uma laje 16x16 vira 2 lajes 16x8 em metade dos casos.
    if seed % 2 == 0:
        hline(img, ox, ox + T, oy + 8, P.STONE_GROUT)
        hline(img, ox + 1, ox + T, oy + 9, P.STONE_LIGHT)
    if cracked:
        x, y = ox + rng.randint(3, 8), oy + rng.randint(2, 5)
        for _ in range(10):
            put(img, x, y, P.STONE_CRACK)
            x += rng.choice((0, 1, 1))
            y += rng.choice((1, 1, 0))
            if x >= ox + T - 1 or y >= oy + T - 1:
                break
    if debris:
        for _ in range(3):
            x, y = ox + rng.randint(2, 12), oy + rng.randint(3, 12)
            length = rng.randint(2, 4)
            for i in range(length):
                put(img, x + i, y + (i // 2), P.WOOD_DARK)
            put(img, x, y - 1, P.WOOD)


def carpet_tile(img, ox, oy, seed, worn=False):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.CARPET, [P.CARPET_ALT, P.CARPET_DARK], 0.25 if not worn else 0.4, rng)
    for y in range(oy, oy + T):
        for x in range(ox, ox + T):
            if (x + y) % 4 == 0 and rng.random() < 0.5:
                put(img, x, y, P.CARPET_ALT)
    if worn:
        for _ in range(4):
            x, y = ox + rng.randint(1, 13), oy + rng.randint(1, 13)
            put(img, x, y, P.STONE)
            put(img, x + 1, y, P.STONE_ALT)


def runner_tile(img, ox, oy, seed, side):
    """Tapete vermelho do corredor central. side = 'L' ou 'R' (borda dourada)."""
    rng = random.Random(seed)
    _noise(img, ox, oy, P.RUNNER, [P.RUNNER_DARK], 0.2, rng)
    edge_x = ox + 1 if side == "L" else ox + T - 2
    vline(img, edge_x, oy, oy + T, P.CARPET_TRIM)
    vline(img, edge_x + (1 if side == "L" else -1), oy, oy + T, P.GOLD_DARK)
    for y in range(oy, oy + T, 4):
        put(img, edge_x + (2 if side == "L" else -2), y + 1, P.GOLD_DARK)


def stage_tile(img, ox, oy, seed, worn=False):
    """Tábuas LONGAS do palco: 4 tábuas de 4px; emendas raras (pareciam tijolos)."""
    rng = random.Random(seed)
    tones = [P.STAGE, shade(P.STAGE, 1.06), shade(P.STAGE, 0.94), P.STAGE]
    for row in range(4):
        y0 = oy + row * 4
        base = tones[(seed + row * 3) % len(tones)]
        for y in range(y0, y0 + 4):
            for x in range(ox, ox + T):
                c = base
                if y == y0:
                    c = P.STAGE_LIGHT  # brilho na borda superior da tábua
                elif y == y0 + 3:
                    c = P.STAGE_GAP  # fresta entre tábuas
                elif rng.random() < 0.06:
                    c = P.STAGE_DARK
                put(img, x, y, c)
        # veio da madeira: um risco escuro comprido
        gy = y0 + 1 + rng.randint(0, 1)
        gx = ox + rng.randint(0, 6)
        for x in range(gx, min(gx + rng.randint(5, 9), ox + T)):
            put(img, x, gy, shade(base, 0.86))
        # emenda só em ~1 de cada 3 tábuas
        if rng.random() < 0.33:
            seam = ox + rng.randint(2, 13)
            vline(img, seam, y0, y0 + 3, P.STAGE_GAP)
            put(img, seam + 1, y0 + 1, P.STAGE_LIGHT)
    if worn:
        for _ in range(4):
            put(img, ox + rng.randint(0, 15), oy + rng.randint(0, 15), P.STAGE_GAP)


def stage_edge_tile(img, ox, oy, seed):
    """Borda do palco com luzes de ribalta (apagadas, exceto algumas)."""
    stage_tile(img, ox, oy, seed)
    rect(img, ox, oy + 8, ox + T, oy + T, P.STAGE_DARK)
    hline(img, ox, ox + T, oy + 8, P.STAGE_LIGHT)
    hline(img, ox, ox + T, oy + T - 1, P.STAGE_GAP)
    for x in (ox + 3, ox + 11):
        lit = (seed + x) % 3 == 0
        put(img, x, oy + 11, P.FLAME if lit else P.IRON)
        put(img, x + 1, oy + 11, P.FLAME_CORE if lit else P.IRON_LIGHT)
        put(img, x, oy + 12, P.GOLD_DARK)
        put(img, x + 1, oy + 12, P.GOLD_DARK)


def wall_top_tile(img, ox, oy, seed):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.WALL_TOP, [P.WALL_SHADOW, P.WALL_TOP_EDGE], 0.12, rng)


def brick_face_tile(img, ox, oy, seed, base=P.BRICK, alt=P.BRICK_ALT, mortar=P.MORTAR, cracked=False):
    rng = random.Random(seed)
    rect(img, ox, oy, ox + T, oy + T, mortar)
    for row in range(4):
        y0 = oy + row * 4
        offset = 0 if row % 2 == 0 else 4
        for bx in range(-1, 3):
            x0 = ox + bx * 8 + offset
            color = base if rng.random() < 0.6 else alt
            for y in range(y0, y0 + 3):
                for x in range(x0, x0 + 7):
                    if ox <= x < ox + T:
                        put(img, x, y, color if rng.random() > 0.08 else shade(color, 0.85))
            if ox <= x0 < ox + T:
                put(img, x0, y0, shade(color, 1.15))
    hline(img, ox, ox + T, oy, P.WALL_TOP_EDGE)
    hline(img, ox, ox + T, oy + T - 1, P.WALL_SHADOW)
    hline(img, ox, ox + T, oy + T - 2, shade(mortar, 0.85))
    if cracked:
        x, y = ox + rng.randint(4, 10), oy + 2
        for _ in range(12):
            put(img, x, y, P.WALL_SHADOW)
            x += rng.choice((-1, 0, 1))
            y += 1
            if y >= oy + T - 1:
                break


def arch_tile(img, ox, oy, seed):
    brick_face_tile(img, ox, oy, seed)
    for y in range(oy + 3, oy + T):
        half = 4 if y > oy + 5 else (3 if y > oy + 4 else 2)
        for x in range(ox + 8 - half, ox + 8 + half):
            put(img, x, y, P.ARCH)
    hline(img, ox + 4, ox + 12, oy + T - 1, P.ARCH)


def curtain_tile(img, ox, oy, seed, variant=0):
    pattern = [P.CURTAIN_DARK, P.CURTAIN, P.CURTAIN_LIGHT, P.CURTAIN, P.CURTAIN, P.CURTAIN_DARK]
    for x in range(T):
        c = pattern[(x + variant * 2) % len(pattern)]
        for y in range(T):
            put(img, ox + x, oy + y, c)
    if variant == 1:  # franja inferior dourada
        hline(img, ox, ox + T, oy + T - 2, P.GOLD_DARK)
        for x in range(ox, ox + T, 2):
            put(img, x, oy + T - 1, P.GOLD)


def threshold_tile(img, ox, oy, seed):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.ARCH, [P.WALL_SHADOW], 0.2, rng)
    hline(img, ox, ox + T, oy + T - 1, P.STONE_GROUT)


def theater_atlas():
    """Atlas 8x3 do Teatro."""
    img = canvas(8 * T, 3 * T)
    stone_tile(img, 0 * T, 0, 11)
    stone_tile(img, 1 * T, 0, 12)
    stone_tile(img, 2 * T, 0, 13, cracked=True)
    stone_tile(img, 3 * T, 0, 14, debris=True)
    carpet_tile(img, 4 * T, 0, 21)
    carpet_tile(img, 5 * T, 0, 22, worn=True)
    runner_tile(img, 6 * T, 0, 23, "L")
    runner_tile(img, 7 * T, 0, 24, "R")
    stage_tile(img, 0 * T, T, 31)
    stage_tile(img, 1 * T, T, 32)
    stage_edge_tile(img, 2 * T, T, 33)
    stage_tile(img, 3 * T, T, 34, worn=True)
    wall_top_tile(img, 4 * T, T, 41)
    brick_face_tile(img, 5 * T, T, 42)
    arch_tile(img, 6 * T, T, 43)
    brick_face_tile(img, 7 * T, T, 44, cracked=True)
    curtain_tile(img, 0 * T, 2 * T, 51, 0)
    curtain_tile(img, 1 * T, 2 * T, 52, 1)
    curtain_tile(img, 2 * T, 2 * T, 53, 2)
    # (3,2) = barreira invisivel (transparente, so colisao)
    threshold_tile(img, 4 * T, 2 * T, 55)
    stone_tile(img, 5 * T, 2 * T, 56)  # piso sob as galerias (escurecido abaixo)
    for y in range(2 * T, 3 * T):
        for x in range(5 * T, 6 * T):
            c = img.getpixel((x, y))
            put(img, x, y, shade(c, 0.7))
    return img


# --- Cidade Estilhacada -------------------------------------------------------------
def asphalt_tile(img, ox, oy, seed, cracked=False, ember=False, paint=False):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.ASPHALT, [P.ASPHALT_ALT, P.ASPHALT_CRACK, P.CONCRETE_ALT], 0.2, rng)
    if paint:
        for x in range(ox + 1, ox + 11):
            put(img, x, oy + 7, P.ROAD_PAINT)
            put(img, x, oy + 8, shade(P.ROAD_PAINT, 0.8))
    if cracked or ember:
        x, y = ox + rng.randint(1, 4), oy + rng.randint(4, 10)
        path = []
        for _ in range(16):
            path.append((x, y))
            x += 1
            y += rng.choice((-1, 0, 0, 1))
            y = max(oy + 1, min(oy + T - 2, y))
            if x >= ox + T:
                break
        for (px_, py_) in path:
            put(img, px_, py_, P.EMBER if ember else P.ASPHALT_CRACK)
            if ember:
                put(img, px_, py_ + 1, P.EMBER_DARK)
            else:
                put(img, px_, py_ + 1, P.ASPHALT_ALT)


def concrete_tile(img, ox, oy, seed, rubble=False):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.CONCRETE, [P.CONCRETE_ALT, P.CONCRETE_LIGHT], 0.2, rng)
    hline(img, ox, ox + T, oy, P.CONCRETE_ALT)
    vline(img, ox, oy, oy + T, P.CONCRETE_ALT)
    hline(img, ox, ox + T, oy + T - 1, shade(P.CONCRETE, 0.8))
    if rubble:
        for _ in range(7):
            x, y = ox + rng.randint(1, 13), oy + rng.randint(1, 13)
            put(img, x, y, P.RUBBLE)
            put(img, x + 1, y, P.RUBBLE_DARK)
            put(img, x, y + 1, P.RUBBLE_DARK)


def ground_tile(img, ox, oy, seed):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.DIRT, [P.GRASS, P.GRASS_LIGHT, shade(P.DIRT, 0.85)], 0.45, rng)


def cwall_top_tile(img, ox, oy, seed):
    """Topo dos prédios em ruínas: laje de concreto rachada (não um buraco preto)."""
    rng = random.Random(seed)
    roof = (58, 61, 66)
    _noise(img, ox, oy, roof, [shade(roof, 0.85), shade(roof, 1.12), P.RUBBLE_DARK], 0.22, rng)
    hline(img, ox, ox + T, oy, shade(roof, 0.7))
    vline(img, ox, oy, oy + T, shade(roof, 0.7))
    if seed % 3 == 0:
        x, y = ox + rng.randint(2, 8), oy + 2
        for _ in range(12):
            put(img, x, y, shade(roof, 0.6))
            x += rng.choice((0, 1))
            y += 1
            if y >= oy + T:
                break
    for _ in range(3):
        put(img, ox + rng.randint(1, 14), oy + rng.randint(1, 14), P.RUBBLE)


def cwall_face_tile(img, ox, oy, seed, broken=False, window=False):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.CWALL, [P.CWALL_ALT], 0.2, rng)
    hline(img, ox, ox + T, oy, shade(P.CWALL, 1.25))
    hline(img, ox, ox + T, oy + 7, P.CMORTAR)
    vline(img, ox + (seed % 2) * 8, oy, oy + 7, P.CMORTAR)
    vline(img, ox + 4 + (seed % 2) * 8, oy + 8, oy + T, P.CMORTAR)
    hline(img, ox, ox + T, oy + T - 1, P.WALL_SHADOW)
    if window:
        rect(img, ox + 4, oy + 3, ox + 12, oy + 11, P.WALL_SHADOW)
        rect(img, ox + 5, oy + 4, ox + 11, oy + 10, P.WINDOW_GLOW)
        rect(img, ox + 5, oy + 7, ox + 11, oy + 10, P.EMBER_DARK)
        vline(img, ox + 8, oy + 4, oy + 10, P.WALL_SHADOW)
    if broken:
        for _ in range(3):
            x = ox + rng.randint(2, 13)
            vline(img, x, oy + rng.randint(4, 8), oy + T - 2, P.IRON)
        for _ in range(10):
            put(img, ox + rng.randint(0, 15), oy + rng.randint(9, 15), P.RUBBLE_DARK)


def cliff_tile(img, ox, oy, seed, lower=False):
    """Face de pedra sob a borda da ilha flutuante (o ceu passa por baixo)."""
    rng = random.Random(seed)
    if not lower:
        _noise(img, ox, oy, P.ROCK, [P.ROCK_DARK, P.DIRT], 0.3, rng)
        hline(img, ox, ox + T, oy, P.GRASS)
        hline(img, ox, ox + T, oy + 1, P.GRASS_LIGHT)
        for x in range(ox, ox + T):
            if rng.random() < 0.5:
                put(img, x, oy + 2, P.GRASS)
    else:
        for y in range(oy, oy + T):
            for x in range(ox, ox + T):
                # Fica mais escuro e "rasgado" para baixo (rocha arrancada da crosta).
                depth = (y - oy) / T
                if rng.random() < depth * 0.9 and (x * 7 + y * 3 + seed) % 5 < 3:
                    continue
                put(img, x, y, rng.choice([P.ROCK_DARK, P.ROCK_DEEP, P.ROCK_DEEP]))
    for _ in range(2):  # raizes penduradas
        x = ox + rng.randint(1, 14)
        for y in range(oy + (3 if not lower else 0), oy + rng.randint(8, 15)):
            put(img, x, y, P.ROOT)


def city_atlas():
    """Atlas 8x2 da Cidade Estilhacada."""
    img = canvas(8 * T, 2 * T)
    asphalt_tile(img, 0 * T, 0, 61)
    asphalt_tile(img, 1 * T, 0, 62)
    asphalt_tile(img, 2 * T, 0, 63, cracked=True)
    asphalt_tile(img, 3 * T, 0, 64, ember=True)
    concrete_tile(img, 4 * T, 0, 65)
    concrete_tile(img, 5 * T, 0, 66)
    concrete_tile(img, 6 * T, 0, 67, rubble=True)
    ground_tile(img, 7 * T, 0, 68)
    cwall_top_tile(img, 0 * T, T, 71)
    cwall_face_tile(img, 1 * T, T, 72)
    cwall_face_tile(img, 2 * T, T, 73, broken=True)
    cwall_face_tile(img, 3 * T, T, 74, window=True)
    cliff_tile(img, 4 * T, T, 75)
    cliff_tile(img, 5 * T, T, 76, lower=True)
    # (6,1) = barreira invisivel
    asphalt_tile(img, 7 * T, T, 78, paint=True)
    return img
