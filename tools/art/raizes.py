"""Raizes da Fome (Gula — Mabel Voragine): tiles, cenario, inimigos e chefes.

Biblia: "Ilha tomada por raizes vermelhas que pulsam como veias. Antigas estufas
e cozinhas do projeto viraram ninhos." Mapa do mundo (ilha 4, a esquerda):
um emaranhado de raizes vermelho-escuras no centro, blocos de ruina em volta,
chao oliva, flores lilases e brasas.
Todos os personagens olham para a DIREITA (o jogo espelha).
"""
from __future__ import annotations

import math
import random

import palette as P
from pixel import canvas, from_grid, paste, put, rect, hline, vline, ellipse, shade, mix, add_outline

O = P.OUTLINE
T = 16


def _noise(img, x0, y0, base, alts, chance, rng, w=T, h=T):
    for y in range(y0, y0 + h):
        for x in range(x0, x0 + w):
            put(img, x, y, rng.choice(alts) if rng.random() < chance else base)


def _outline(img):
    return add_outline(img, O)


def _root_strand(img, rng, x0, y0, x1, y1, width, color, dark, light=None, wobble=2.0):
    """Uma raiz torta de (x0,y0) a (x1,y1): circulos ao longo de uma curva ondulada."""
    steps = int(max(abs(x1 - x0), abs(y1 - y0)) * 1.5) + 2
    phase = rng.uniform(0, math.tau)
    for i in range(steps + 1):
        t = i / steps
        x = x0 + (x1 - x0) * t
        y = y0 + (y1 - y0) * t
        # ondula perpendicular ao caminho
        nx, ny = -(y1 - y0), (x1 - x0)
        length = math.hypot(nx, ny) or 1.0
        off = math.sin(t * math.pi * 2.2 + phase) * wobble
        x += nx / length * off
        y += ny / length * off
        w = max(0.6, width * (1.0 - t * 0.45))
        ellipse(img, x, y, w, w, color)
        put(img, int(x + w * 0.4), int(y + w * 0.4), dark)
        if light is not None and w > 1.2:
            put(img, int(x - w * 0.3), int(y - w * 0.5), light)


# =============================================================================
# Tiles (atlas 8x3) — o layout e espelhado em THEMES["raizes"] (level.gd)
# =============================================================================

def soil_tile(img, ox, oy, seed, veins=False, olive=False):
    rng = random.Random(seed)
    base = P.OLIVE_GROUND if olive else P.SOIL_RED
    alts = [P.OLIVE_DARK, P.SOIL_RED_LIGHT] if olive else [P.SOIL_RED_DARK, P.SOIL_RED_LIGHT]
    _noise(img, ox, oy, base, alts, 0.3, rng)
    for _ in range(3):  # pedrinhas
        x, y = ox + rng.randint(1, 13), oy + rng.randint(1, 13)
        put(img, x, y, P.RUIN_STONE)
        put(img, x + 1, y, P.RUIN_STONE_DARK)
    if veins:
        for _ in range(2):
            x = ox + rng.randint(0, 15)
            y = oy + rng.randint(0, 15)
            for _k in range(10):
                put(img, x, y, P.ROOTS_RED_DARK)
                x += rng.choice((-1, 0, 1))
                y += rng.choice((0, 1))
                if not (ox <= x < ox + T and oy <= y < oy + T):
                    break


def greenhouse_tile(img, ox, oy, seed, cracked=False):
    """Piso da estufa: ladrilhos esverdeados, rejunte com musgo e cacos de vidro."""
    rng = random.Random(seed)
    rect(img, ox, oy, ox + T, oy + T, P.GREENHOUSE_TILE)
    for y in range(oy, oy + T):
        for x in range(ox, ox + T):
            if rng.random() < 0.18:
                put(img, x, y, shade(P.GREENHOUSE_TILE, rng.choice((0.9, 1.08))))
    for k in (0, 8):
        hline(img, ox, ox + T, oy + k, P.GREENHOUSE_TILE_DARK)
        vline(img, ox + k, oy, oy + T, P.GREENHOUSE_TILE_DARK)
    for _ in range(5):
        put(img, ox + rng.randint(0, 15), oy + rng.choice((0, 8)), P.MOSS)
    if cracked:
        x, y = ox + 3, oy + 2
        for _ in range(12):
            put(img, x, y, P.GREENHOUSE_TILE_DARK)
            x += rng.choice((0, 1))
            y += 1
            if y >= oy + T:
                break
    for _ in range(2):  # cacos
        x, y = ox + rng.randint(2, 13), oy + rng.randint(2, 13)
        put(img, x, y, P.GLASS)
        put(img, x + 1, y + 1, P.GLASS_DARK)


def kitchen_tile(img, ox, oy, seed, dirty=False):
    """Cozinha do projeto: xadrez creme e marrom. A versao 'dirty' tem manchas de seiva."""
    rng = random.Random(seed)
    for y in range(oy, oy + T):
        for x in range(ox, ox + T):
            checker = ((x - ox) // 4 + (y - oy) // 4) % 2 == 0
            c = P.KITCHEN_TILE_A if checker else P.KITCHEN_TILE_B
            if rng.random() < 0.12:
                c = shade(c, 0.92)
            put(img, x, y, c)
    if dirty:
        for _ in range(2):
            cx, cy = ox + rng.randint(3, 12), oy + rng.randint(3, 12)
            ellipse(img, cx, cy, rng.uniform(1.5, 2.6), rng.uniform(1.0, 1.8), P.SAP_DARK)
            put(img, int(cx), int(cy), P.SAP)


def vein_floor(img, ox, oy, seed):
    """Chao tomado: terra escura com raizes finas cruzando e um brilho de veia aqui e ali."""
    rng = random.Random(seed)
    _noise(img, ox, oy, P.SOIL_RED, [P.SOIL_RED_DARK, P.SOIL_RED_LIGHT], 0.25, rng)
    for _ in range(2):
        x0, y0 = ox + rng.randint(-2, 6), oy + rng.randint(1, 14)
        x1, y1 = ox + rng.randint(10, 18), oy + rng.randint(1, 14)
        steps = 18
        for i in range(steps + 1):
            t = i / steps
            x = int(x0 + (x1 - x0) * t)
            y = int(y0 + (y1 - y0) * t + math.sin(t * 6 + seed) * 1.2)
            if ox <= x < ox + T and oy <= y < oy + T:
                put(img, x, y, P.ROOTS_RED_DARK if i % 3 else P.ROOTS_RED)
    if seed % 2 == 0:
        put(img, ox + 7, oy + 8, P.VEIN)


def plank_tile(img, ox, oy, seed):
    rng = random.Random(seed)
    for y in range(oy, oy + T):
        plank = (y - oy) // 4
        c = P.BARK_LIGHT if plank % 2 == 0 else P.BARK
        for x in range(ox, ox + T):
            put(img, x, y, c if rng.random() > 0.08 else P.BARK_DARK)
    for k in range(4):
        hline(img, ox, ox + T, oy + k * 4 + 3, P.BARK_DARK)
    for _ in range(3):  # raizes passando por cima das tabuas
        x = ox + rng.randint(0, 15)
        vline(img, x, oy + rng.randint(0, 6), oy + rng.randint(8, 15), P.ROOTS_RED_DARK)


def sap_stain_tile(img, ox, oy, seed):
    rng = random.Random(seed)
    soil_tile(img, ox, oy, seed + 2000)
    for _ in range(4):
        cx, cy = ox + rng.randint(2, 13), oy + rng.randint(2, 13)
        ellipse(img, cx, cy, rng.uniform(1.5, 3.5), rng.uniform(1.0, 2.2), P.SAP_DARK)
        put(img, int(cx) - 1, int(cy) - 1, P.SAP)


def planter_soil(img, ox, oy, seed):
    """Canteiro arado (as estufas): sulcos escuros e brotos mortos."""
    rng = random.Random(seed)
    _noise(img, ox, oy, P.SOIL_RED_DARK, [P.ROCK_DEEP, P.SOIL_RED], 0.25, rng)
    for k in range(4):
        hline(img, ox, ox + T, oy + k * 4 + 1, P.SOIL_RED)
        hline(img, ox, ox + T, oy + k * 4 + 2, P.ROCK_DEEP)
    for _ in range(3):
        x, y = ox + rng.randint(1, 14), oy + rng.randint(1, 13)
        put(img, x, y, P.OLIVE_DARK)
        put(img, x, y - 1, P.WITHER_DARK)


def roots_top_tile(img, ox, oy, seed):
    """Topo da 'parede': o emaranhado de raizes visto de cima."""
    rng = random.Random(seed)
    rect(img, ox, oy, ox + T, oy + T, P.ROOTS_RED_DEEP)
    tile = canvas(T, T)
    for _ in range(6):
        x0, y0 = rng.randint(-4, 19), rng.randint(-4, 19)
        angle = rng.uniform(0, math.tau)
        x1, y1 = x0 + math.cos(angle) * 14, y0 + math.sin(angle) * 14
        _root_strand(tile, rng, x0, y0, x1, y1, rng.uniform(1.4, 2.4), P.ROOTS_RED, P.ROOTS_RED_DARK, P.ROOTS_RED_LIGHT, 1.5)
    paste(img, tile, ox, oy)
    for _ in range(2):
        put(img, ox + rng.randint(1, 14), oy + rng.randint(1, 14), P.VEIN)


def roots_face_tile(img, ox, oy, seed):
    """Face da 'parede': troncos de raiz retorcidos descendo ate o chao, com vaos escuros."""
    rng = random.Random(seed)
    rect(img, ox, oy, ox + T, oy + T, P.ROOTS_RED_DEEP)
    tile = canvas(T, T)
    xs = sorted(rng.sample(range(1, 15), 3))
    for x in xs:
        w = rng.uniform(1.3, 2.3)
        _root_strand(tile, rng, x, -3, x + rng.randint(-2, 2), 18, w, P.ROOTS_RED, P.ROOTS_RED_DARK, P.ROOTS_RED_LIGHT, 0.9)
    # um ramo cruzado (quebra a repeticao)
    y = rng.randint(4, 11)
    _root_strand(tile, rng, -1, y, 16, y + rng.randint(-3, 3), 0.9, P.ROOTS_RED_DARK, P.ROOTS_RED_DEEP, None, 1.0)
    paste(img, tile, ox, oy)
    hline(img, ox, ox + T, oy + T - 1, P.WALL_SHADOW)
    if seed % 2 == 0:
        put(img, ox + xs[1], oy + 7, P.VEIN)
        put(img, ox + xs[1], oy + 8, P.VEIN)


def glass_wall_tile(img, ox, oy, seed):
    """Parede de estufa: base de pedra, vidraca rachada e raiz atravessando."""
    rng = random.Random(seed)
    rect(img, ox, oy, ox + T, oy + T, P.RUIN_STONE_DARK)
    rect(img, ox, oy + 10, ox + T, oy + T, P.RUIN_STONE)
    hline(img, ox, ox + T, oy + 10, P.RUIN_STONE_LIGHT)
    hline(img, ox, ox + T, oy + T - 1, P.WALL_SHADOW)
    rect(img, ox + 1, oy + 1, ox + 7, oy + 9, P.GLASS_DARK)
    rect(img, ox + 9, oy + 1, ox + 15, oy + 9, P.GLASS_DARK)
    for x in range(ox + 1, ox + 7):
        put(img, x, oy + 1 + (x - ox) % 3, P.GLASS)
    for k in range(4):
        put(img, ox + 10 + k, oy + 2 + k, P.GLASS)
    vline(img, ox + 8, oy, oy + 10, P.IRON)
    hline(img, ox, ox + T, oy, P.IRON)
    tile = canvas(T, T)
    _root_strand(tile, rng, 3, 16, 12, 0, 1.6, P.ROOTS_RED, P.ROOTS_RED_DARK, P.ROOTS_RED_LIGHT, 1.0)
    paste(img, tile, ox, oy)


def roots_arch_tile(img, ox, oy, seed):
    rng = random.Random(seed)
    roots_face_tile(img, ox, oy, seed)
    ellipse(img, ox + 8, oy + 15, 5, 9, (24, 10, 14))
    for x in range(ox + 3, ox + 13):
        if rng.random() < 0.5:
            put(img, x, oy + 6 + rng.randint(0, 2), P.ROOTS_RED_DARK)


def cliff_tile(img, ox, oy, seed, lower=False):
    rng = random.Random(seed)
    if not lower:
        _noise(img, ox, oy, P.RUIN_STONE_DARK, [P.ROCK_DARK, P.SOIL_RED_DARK], 0.3, rng)
        hline(img, ox, ox + T, oy, P.SOIL_RED)
        hline(img, ox, ox + T, oy + 1, P.SOIL_RED_LIGHT)
    else:
        for y in range(oy, oy + T):
            for x in range(ox, ox + T):
                depth = (y - oy) / T
                if rng.random() < depth * 0.9 and (x * 7 + y * 3 + seed) % 5 < 3:
                    continue
                put(img, x, y, rng.choice([P.ROCK_DARK, P.ROCK_DEEP, P.ROCK_DEEP]))
    for _ in range(4):  # raizes vermelhas penduradas sob a ilha
        x = ox + rng.randint(1, 14)
        for y in range(oy + (2 if not lower else 0), oy + rng.randint(8, 16)):
            put(img, x, y, P.ROOTS_RED if rng.random() < 0.7 else P.ROOTS_RED_DARK)
            if rng.random() < 0.2:
                x += rng.choice((-1, 1))


def sap_tile(img, ox, oy, seed, bubbles=False, shore=False):
    """Poca de seiva vermelha (solida): quase parada, com brilhos."""
    rng = random.Random(seed)
    _noise(img, ox, oy, P.SAP, [P.SAP_DARK], 0.25, rng)
    for _ in range(2):
        x, y = ox + rng.randint(1, 10), oy + rng.randint(3, 13)
        hline(img, x, x + rng.randint(2, 4), y, P.SAP_LIGHT)
    if bubbles:
        for _ in range(3):
            cx, cy = ox + rng.randint(3, 12), oy + rng.randint(3, 12)
            ellipse(img, cx, cy, 1.5, 1.5, P.SAP_LIGHT)
            put(img, cx, cy, P.SAP_DARK)
    if shore:
        for x in range(ox, ox + T):
            h = 3 + (1 if rng.random() < 0.4 else 0)
            vline(img, x, oy, oy + h, P.SOIL_RED)
            put(img, x, oy + h, P.ROOTS_RED_DARK)
            put(img, x, oy + h + 1, P.SAP_DARK)


def roots_atlas():
    """Atlas 8x3 das Raizes da Fome."""
    img = canvas(8 * T, 3 * T)
    soil_tile(img, 0 * T, 0, 201, olive=True)
    soil_tile(img, 1 * T, 0, 202, olive=True)
    soil_tile(img, 2 * T, 0, 203, veins=True, olive=True)
    greenhouse_tile(img, 3 * T, 0, 204)
    kitchen_tile(img, 4 * T, 0, 205)
    vein_floor(img, 5 * T, 0, 206)
    plank_tile(img, 6 * T, 0, 207)
    sap_stain_tile(img, 7 * T, 0, 208)
    roots_top_tile(img, 0 * T, T, 211)
    roots_face_tile(img, 1 * T, T, 212)
    glass_wall_tile(img, 2 * T, T, 213)
    roots_arch_tile(img, 3 * T, T, 214)
    cliff_tile(img, 4 * T, T, 215)
    cliff_tile(img, 5 * T, T, 216, lower=True)
    # (6,1) = barreira invisivel
    sap_tile(img, 7 * T, T, 218)
    sap_tile(img, 0 * T, 2 * T, 221, bubbles=True)
    sap_tile(img, 1 * T, 2 * T, 222, shore=True)
    greenhouse_tile(img, 2 * T, 2 * T, 223, cracked=True)
    planter_soil(img, 3 * T, 2 * T, 224)
    kitchen_tile(img, 4 * T, 2 * T, 225, dirty=True)
    vein_floor(img, 5 * T, 2 * T, 226)
    return img


# =============================================================================
# Cenario
# =============================================================================

def root_tangle():
    """Emaranhado de raizes (32x40): o 'arvore' desta ilha. Colisao so no pe."""
    rng = random.Random(17)
    img = canvas(32, 40)
    for _ in range(9):
        x0 = rng.randint(8, 24)
        x1 = x0 + rng.randint(-12, 12)
        _root_strand(img, rng, x0, 39, x1, rng.randint(2, 16), rng.uniform(1.6, 2.8), P.ROOTS_RED, P.ROOTS_RED_DARK,
                     P.ROOTS_RED_LIGHT, 2.5)
    for _ in range(4):  # arcos que voltam para o chao
        x0 = rng.randint(4, 28)
        _root_strand(img, rng, x0, rng.randint(10, 20), x0 + rng.choice((-10, 10)), 39, 1.4, P.ROOTS_RED_DARK,
                     P.ROOTS_RED_DEEP, None, 2.0)
    for _ in range(5):
        x, y = rng.randint(6, 26), rng.randint(6, 34)
        if img.getpixel((x, y))[3] > 0:
            put(img, x, y, P.VEIN)
    return _outline(img)


def flesh_pod_frames():
    """Fruto de carne pendurado num talo (16x22, 2 quadros: pulsa devagar)."""
    frames = []
    for f in range(2):
        img = canvas(16, 22)
        vline(img, 7, 6, 21, P.ROOTS_RED_DARK)
        vline(img, 8, 6, 21, P.ROOTS_RED)
        ellipse(img, 4, 19, 3, 1.5, P.ROOTS_RED_DARK)
        ellipse(img, 11, 20, 3, 1.5, P.ROOTS_RED_DARK)
        r = 4.5 if f == 0 else 5.2
        ellipse(img, 8, 8, r, r * 0.95, P.FLESH_DARK)
        ellipse(img, 7.5, 7.5, r - 1, r - 1.2, P.FLESH)
        put(img, 6, 5, P.FLESH_LIGHT)
        put(img, 7, 5, P.FLESH_LIGHT)
        for k in range(3):
            put(img, 6 + k, 9 + (k % 2), P.SAP)
        frames.append(_outline(img))
    return frames


def planter():
    """Canteiro da estufa (32x16, ocupa 2 celulas): madeira, terra, plantas mortas e raizes."""
    rng = random.Random(23)
    img = canvas(32, 16)
    rect(img, 1, 6, 31, 15, P.BARK)
    hline(img, 1, 31, 6, P.BARK_LIGHT)
    hline(img, 1, 31, 14, P.BARK_DARK)
    for x in (2, 15, 29):
        vline(img, x, 6, 15, P.BARK_DARK)
    rect(img, 2, 5, 30, 8, P.SOIL_RED_DARK)
    for x in range(4, 28, 4):
        h = rng.randint(2, 5)
        vline(img, x, 5 - h, 5, P.WITHER_DARK)
        put(img, x + 1, 5 - h, P.WITHER)
    _root_strand(img, rng, 20, 6, 31, 15, 1.2, P.ROOTS_RED, P.ROOTS_RED_DARK, None, 1.0)
    return _outline(img)


def stove():
    """Fogao velho de ferro da cozinha (20x24) com brasa na boca."""
    img = canvas(20, 24)
    rect(img, 2, 6, 18, 23, P.IRON)
    rect(img, 3, 7, 17, 22, shade(P.IRON, 0.8))
    hline(img, 2, 18, 6, shade(P.IRON, 1.3))
    rect(img, 5, 13, 15, 19, (40, 22, 18))
    rect(img, 6, 15, 14, 18, (226, 110, 50))
    put(img, 8, 16, (255, 200, 110))
    put(img, 11, 16, (255, 200, 110))
    rect(img, 13, 0, 16, 6, shade(P.IRON, 0.7))  # chamine
    ellipse(img, 6, 5, 3, 1, P.STEEL_DARK)  # panela
    rect(img, 4, 2, 9, 5, P.STEEL)
    return _outline(img)


def mabel_table():
    """Memorial: a mesa posta para ninguem (48x24) — pratos limpos e uma cadeira enorme."""
    img = canvas(48, 24)
    rect(img, 2, 10, 46, 16, P.BARK)
    hline(img, 2, 46, 10, P.BARK_LIGHT)
    hline(img, 2, 46, 15, P.BARK_DARK)
    for x in (4, 43):
        rect(img, x, 16, x + 2, 23, P.BARK_DARK)
    rect(img, 2, 8, 46, 11, P.MABEL_APRON)  # toalha
    hline(img, 2, 46, 11, P.MABEL_APRON_DARK)
    for cx in (9, 19, 29, 39):
        ellipse(img, cx, 8, 3.5, 1.4, P.PLATE)
        put(img, cx, 8, shade(P.PLATE, 0.85))
    ellipse(img, 24, 5, 2, 3, P.FLESH_DARK)  # um fruto murcho no centro
    return _outline(img)


def sap_splat():
    """Mancha que fica no chao depois de um fruto/Inchado explodir (32x18)."""
    img = canvas(32, 18)
    rng = random.Random(31)
    ellipse(img, 16, 9, 13, 6, (*P.SAP_DARK, 200))
    for _ in range(9):
        a = rng.uniform(0, math.tau)
        d = rng.uniform(8, 14)
        ellipse(img, 16 + math.cos(a) * d, 9 + math.sin(a) * d * 0.5, rng.uniform(1, 2.5), rng.uniform(0.8, 1.6), (*P.SAP, 210))
    ellipse(img, 14, 8, 4, 2, (*P.SAP, 220))
    return img


def flesh_fruit():
    """Fruto de carne arremessado (12x12)."""
    img = canvas(12, 12)
    ellipse(img, 6, 6.5, 4.5, 4.2, P.FLESH_DARK)
    ellipse(img, 5.5, 6, 3.5, 3.2, P.FLESH)
    put(img, 4, 4, P.FLESH_LIGHT)
    put(img, 5, 4, P.FLESH_LIGHT)
    put(img, 7, 7, P.SAP)
    put(img, 6, 8, P.SAP)
    vline(img, 6, 0, 3, P.ROOTS_RED_DARK)
    return _outline(img)


def root_vein_frames():
    """Raiz-Veia (24x32, 2 quadros): ligada a Mabel na fase 2; corta-la para a cura."""
    frames = []
    for f in range(2):
        rng = random.Random(41)
        img = canvas(24, 32)
        for _ in range(4):
            x0 = rng.randint(6, 18)
            _root_strand(img, rng, x0, 31, 12 + rng.randint(-2, 2), 10, 2.2, P.ROOTS_RED, P.ROOTS_RED_DARK, P.ROOTS_RED_LIGHT, 1.5)
        r = 5.0 if f == 0 else 6.0
        ellipse(img, 12, 9, r, r * 0.9, P.ROOTS_RED_DARK)
        ellipse(img, 12, 9, r - 1.5, r - 1.8, P.VEIN if f == 1 else P.ROOTS_RED_LIGHT)
        put(img, 11, 7, (255, 200, 190))
        ellipse(img, 12, 30, 9, 2, P.SOIL_RED_DARK)
        frames.append(_outline(img))
    return frames


# =============================================================================
# Inimigos
# =============================================================================

def boca_frames():
    """Boca de Raiz (24x24): [enterrada, inchando, ABERTA, mastigando, afundando]."""
    frames = []
    for state in range(5):
        rng = random.Random(51)
        img = canvas(24, 24)
        if state in (0, 1, 4):
            ry = 2.5 if state == 0 else (4.5 if state == 1 else 3.5)
            ellipse(img, 12, 21, 9, ry, P.SOIL_RED_DARK)
            ellipse(img, 12, 20.5, 7, ry - 1, P.SOIL_RED)
            for k in range(4):  # pontas de raiz saindo do monte
                x = 6 + k * 4
                h = 2 if state == 0 else 5
                vline(img, x, 20 - h, 21, P.ROOTS_RED)
                put(img, x, 20 - h, P.ROOTS_RED_LIGHT)
            hline(img, 9, 15, 21, P.VEIN if state != 0 else P.ROOTS_RED_DARK)  # a fenda
            if state == 1:
                for _ in range(5):
                    put(img, rng.randint(5, 18), rng.randint(17, 22), P.SOIL_RED_LIGHT)
        else:
            # Talo de raizes subindo do chao e a cabeca-boca no alto.
            ellipse(img, 12, 21, 9, 2.5, P.SOIL_RED_DARK)
            for dx in (-2, 0, 2):
                _root_strand(img, rng, 12 + dx * 1.5, 22, 12 + dx, 11, 1.6, P.ROOTS_RED, P.ROOTS_RED_DARK, P.ROOTS_RED_LIGHT, 1.0)
            if state == 2:
                # duas mandibulas abertas (vista de lado: um V)
                for k in range(8):
                    put(img, 12 + k, 9 - k // 2, P.ROOTS_RED)
                    put(img, 12 + k, 10 - k // 2, P.ROOTS_RED_DARK)
                    put(img, 12 + k, 11 + k // 3, P.ROOTS_RED)
                    put(img, 12 + k, 12 + k // 3, P.ROOTS_RED_DARK)
                ellipse(img, 13, 10.5, 3, 2.5, P.SAP_DARK)
                for k in range(0, 8, 2):  # dentes
                    put(img, 13 + k, 10 - k // 2 + 1, P.LARVA)
                    put(img, 13 + k, 11 + k // 3 - 1, P.LARVA)
                ellipse(img, 10, 10, 3.5, 3.5, P.ROOTS_RED)
                put(img, 9, 8, P.VEIN)
            else:
                ellipse(img, 13, 9, 5, 4, P.ROOTS_RED)
                ellipse(img, 13, 9, 3.5, 2.5, P.ROOTS_RED_DARK)
                hline(img, 10, 18, 9, P.SAP)
                for x in range(10, 18, 2):
                    put(img, x, 10, P.LARVA)
                put(img, 11, 6, P.VEIN)
        frames.append(_outline(img))
    return frames


INCHADO_KEY = {"s": P.FLESH, "z": P.FLESH_DARK, "l": P.FLESH_LIGHT, "v": P.SAP, "e": (60, 30, 30),
               "c": P.CIVIL_CLOTH_DARK, "C": P.CIVIL_CLOTH}
INCHADO_BODY = [
    "....zsss.......",
    "...zssssz......",
    "...ssessse.....",
    "...zssssz......",
    "..zzslllss.....",
    ".zssllllsssz...",
    "zsslllvlssssz..",
    "zssllllvssvsz..",
    "zsssllvlsssssz.",
    "zssssssssvsssz.",
    "zzssvssssssszz.",
    ".zsssssssssszz.",
    "..zzssssssszz..",
    "...ccCCCCcc....",
]
INCHADO_LEGS = [
    ["....zz..zz.....", "....zz..zz....."],
    ["...zz....zz....", "...zz....zz...."],
    ["....zz..zz.....", "....zz..zz....."],
    [".....zzzz......", ".....zzzz......"],
]


def inchado_frames():
    """Inchado (24x24): [parado, passo, parado, passo 2, INCHANDO (vai explodir)]."""
    frames = []
    for legs in INCHADO_LEGS:
        sprite = from_grid(INCHADO_BODY + legs, INCHADO_KEY, outline=O)
        frame = canvas(24, 24)
        paste(frame, sprite, (24 - sprite.width) // 2, 23 - sprite.height)
        frames.append(frame)
    # inchando: a barriga estica e as veias acendem
    img = canvas(24, 24)
    ellipse(img, 12, 14, 9, 8, P.FLESH_DARK)
    ellipse(img, 11.5, 13.5, 8, 7, P.FLESH)
    ellipse(img, 10, 11, 4, 3, P.FLESH_LIGHT)
    rng = random.Random(61)
    for _ in range(6):
        x, y = rng.randint(5, 18), rng.randint(8, 20)
        for k in range(3):
            put(img, x + k, y + (k % 2), P.VEIN)
    ellipse(img, 12, 5, 3, 2.5, P.FLESH)
    put(img, 13, 5, (60, 30, 30))
    vline(img, 9, 21, 23, P.FLESH_DARK)
    vline(img, 15, 21, 23, P.FLESH_DARK)
    frames.append(_outline(img))
    return frames


def colhedor_frames():
    """Colhedor (32x32): antigo trabalhador da estufa, macacao, chapeu de palha, foice.
    [parado, passo, parado, passo 2, PREPARA (foice atras), CEIFA (foice a frente)]"""
    frames = []
    for state in range(6):
        img = canvas(32, 32)
        lx = 12 - (2 if state == 1 else 0)
        rx = 17 + (2 if state == 3 else 0)
        # pernas (macacao) e botas
        rect(img, lx, 23, lx + 3, 30, P.STAMINA_DARK)
        rect(img, rx, 23, rx + 3, 30, P.STAMINA_DARK)
        hline(img, lx, lx + 4, 30, P.BOOTS)
        hline(img, rx, rx + 4, 30, P.BOOTS)
        # tronco magro, macacao verde desbotado
        rect(img, 11, 13, 21, 24, (92, 112, 80))
        rect(img, 11, 13, 13, 24, (70, 86, 62))
        vline(img, 13, 11, 16, (70, 86, 62))  # alcas
        vline(img, 19, 11, 16, (70, 86, 62))
        rect(img, 12, 10, 20, 13, P.CIVIL_SKIN_DARK)
        # raizes saindo das costas (a ilha cresceu nele)
        for k in range(3):
            vline(img, 10 - k, 12 + k * 3, 16 + k * 3, P.ROOTS_RED)
            put(img, 9 - k, 12 + k * 3, P.ROOTS_RED_LIGHT)
        # cabeca e chapeu de palha
        rect(img, 13, 5, 19, 11, P.CIVIL_SKIN)
        put(img, 17, 8, (40, 30, 30))
        hline(img, 13, 19, 10, P.CIVIL_SKIN_DARK)
        hline(img, 9, 23, 5, P.HAZARD)
        rect(img, 12, 2, 20, 5, shade(P.HAZARD, 0.85))
        hline(img, 12, 20, 4, P.ROOTS_RED_DARK)  # fita
        # bracos e foice
        if state in (0, 1, 2, 3):
            # foice em pe, atras do ombro (cabo vertical, lamina no alto)
            vline(img, 22, 4, 28, P.BARK)
            vline(img, 23, 4, 28, P.BARK_DARK)
            for k in range(9):
                put(img, 22 - k, 4 + k // 3, P.STEEL)
                put(img, 22 - k, 5 + k // 3, P.STEEL_DARK)
            rect(img, 20, 14, 23, 19, P.CIVIL_SKIN_DARK)
        elif state == 4:
            # prepara: foice puxada para tras, lamina baixa atras do corpo
            for k in range(18):
                put(img, 22 - k, 10 + k // 2, P.BARK)
                put(img, 22 - k, 11 + k // 2, P.BARK_DARK)
            for k in range(8):
                put(img, 4 + k // 3, 18 + k, P.STEEL)
                put(img, 5 + k // 3, 18 + k, P.STEEL_DARK)
            rect(img, 19, 13, 23, 17, P.CIVIL_SKIN_DARK)
        else:
            # ceifa: cabo a frente, lamina varrendo baixo
            for k in range(14):
                put(img, 18 + k // 2 * 1, 16 + k // 2, P.BARK)
            hline(img, 24, 31, 23, P.STEEL)
            hline(img, 22, 31, 24, P.STEEL_DARK)
            for k in range(4):
                put(img, 31 - k, 22 - k, P.STEEL)
            rect(img, 19, 14, 23, 18, P.CIVIL_SKIN_DARK)
        frames.append(_outline(img))
    return frames


def larva_frames():
    """Larva de Seiva (16x16): [rasteja estica, rasteja encolhe, ERGUIDA (morde)]."""
    frames = []
    for state in range(3):
        img = canvas(16, 16)
        if state < 2:
            n = 5 if state == 0 else 4
            spacing = 2.2 if state == 0 else 1.8
            for k in range(n):
                cx = 3 + k * spacing
                ellipse(img, cx, 12, 1.9, 1.7 + (0.3 if state == 1 else 0), P.LARVA_DARK if k % 2 else P.LARVA)
            hx = 3 + n * spacing
            ellipse(img, hx, 11.5, 2.2, 2.0, P.SAP)
            put(img, int(hx) + 1, 11, P.SAP_DARK)
            put(img, int(hx), 10, P.SAP_LIGHT)
        else:
            for k in range(4):
                ellipse(img, 5 + k * 1.2, 13 - k * 2.2, 2.0, 1.8, P.LARVA_DARK if k % 2 else P.LARVA)
            ellipse(img, 10, 5, 2.6, 2.4, P.SAP)
            ellipse(img, 10.5, 5, 1.2, 1.4, P.SAP_DARK)
            put(img, 12, 4, P.LARVA)
            put(img, 12, 6, P.LARVA)
        frames.append(_outline(img))
    return frames


# =============================================================================
# Mini-chefes
# =============================================================================

def _cook_body(img, state, rng):
    """O Banqueteiro: cozinheiro enorme, touca alta, avental manchado, cutelo."""
    sway = 1 if state in (1, 3) else 0
    lx = 15 - (2 if state == 1 else 0)
    rx = 27 + (2 if state == 3 else 0)
    rect(img, lx, 38, lx + 7, 46, P.UNIFORM_DARK)
    rect(img, rx, 38, rx + 7, 46, P.UNIFORM_DARK)
    hline(img, lx, lx + 7, 46, P.BOOTS)
    hline(img, rx, rx + 7, 46, P.BOOTS)
    # barriga redonda
    ellipse(img, 24, 29, 15, 12, P.COOK_SHADOW)
    ellipse(img, 23, 28, 14, 11, P.COOK_WHITE)
    # avental manchado de seiva
    rect(img, 15, 24, 32, 41, P.MABEL_APRON)
    rect(img, 15, 24, 17, 41, P.MABEL_APRON_DARK)
    for _ in range(7):
        ellipse(img, rng.randint(17, 30), rng.randint(27, 39), rng.uniform(1, 2.2), rng.uniform(0.8, 1.6), P.SAP_DARK)
    # cabeca: bochechas, bigode, olhinhos
    ellipse(img, 24, 14, 7, 6, P.GOV_SKIN)
    ellipse(img, 25, 15, 6, 4.5, P.GOV_SKIN)
    hline(img, 22, 30, 17, P.GOV_HAIR_DARK)  # bigode
    put(img, 27, 13, (40, 30, 30))
    put(img, 23, 13, (40, 30, 30))
    if state == 6:  # comendo: boca aberta
        ellipse(img, 26, 18.5, 3, 2, P.SAP_DARK)
    # touca de chef
    rect(img, 18, 2, 30, 9, P.COOK_WHITE)
    ellipse(img, 20, 3, 3, 2.5, P.COOK_WHITE)
    ellipse(img, 27, 3, 3, 2.5, P.COOK_WHITE)
    hline(img, 18, 30, 8, P.COOK_SHADOW)
    # bracos
    if state == 4:  # cutelo erguido
        rect(img, 34, 4, 39, 22, P.COOK_WHITE)
        rect(img, 33, 0, 44, 6, P.STEEL)
        hline(img, 33, 44, 6, P.STEEL_DARK)
        put(img, 42, 2, (240, 240, 236))
    elif state == 5:  # serve: bandeja com cloche erguida
        rect(img, 33, 18, 40, 23, P.COOK_WHITE)
        hline(img, 30, 46, 17, P.STEEL_DARK)
        ellipse(img, 38, 13, 7, 4, P.STEEL)
        put(img, 38, 8, P.STEEL_DARK)
    elif state == 6:  # segura uma larva perto da boca
        rect(img, 32, 16, 37, 24, P.COOK_WHITE)
        for k in range(4):
            ellipse(img, 33 + k * 1.5, 14, 1.4, 1.3, P.LARVA if k % 2 == 0 else P.LARVA_DARK)
        ellipse(img, 39, 14, 1.6, 1.5, P.SAP)
    else:
        rect(img, 34, 20 + sway, 39, 33 + sway, P.COOK_WHITE)
        rect(img, 37, 31 + sway, 46, 35 + sway, P.STEEL)  # cutelo baixo
        hline(img, 37, 46, 35 + sway, P.STEEL_DARK)
    rect(img, 8, 20 - sway, 13, 33 - sway, P.COOK_SHADOW)


def banqueteiro_frames():
    """O Banqueteiro (48x48): [parado, passo, parado, passo 2, CUTELO, SERVE, COME]."""
    frames = []
    for state in range(7):
        rng = random.Random(71)
        img = canvas(48, 48)
        _cook_body(img, state, rng)
        frames.append(_outline(img))
    return frames


def ninhada_frames():
    """A Ninhada (48x48): um monte de larvas. [pulsa, pulsa 2, ERGUIDA (vai engolir)]."""
    frames = []
    for state in range(3):
        rng = random.Random(81)
        img = canvas(48, 48)
        height = 15 if state == 0 else (17 if state == 1 else 24)
        ellipse(img, 24, 40, 20, 6, P.SAP_DARK)
        for _ in range(70):
            a = rng.uniform(0, math.tau)
            d = rng.uniform(0, 1) ** 0.6
            cx = 24 + math.cos(a) * d * 18
            cy = 40 - (1 - d) * height - abs(math.sin(a)) * 3
            angle = rng.uniform(0, math.tau)
            for k in range(3):
                ellipse(img, cx + math.cos(angle) * k * 1.6, cy + math.sin(angle) * k * 1.1, 1.8, 1.5,
                        P.LARVA if (k + int(cx)) % 2 else P.LARVA_DARK)
            put(img, int(cx + math.cos(angle) * 4.8), int(cy + math.sin(angle) * 3.3), P.SAP)
        if state == 2:
            ellipse(img, 24, 40 - height * 0.55, 6, 4, P.SAP_DARK)  # a boca no meio do monte
            ellipse(img, 24, 40 - height * 0.55, 4, 2.5, (30, 8, 14))
        frames.append(_outline(img))
    return frames


# =============================================================================
# Mabel Voragine, A Fome Que Lembra (chefe)
# =============================================================================

def _mabel(state):
    """64x64. Giganta: lenco na cabeca, rosto redondo, vestido vinho, avental.
    state: 0 parada, 1 passo, 2 parada (respira), 3 passo 2, 4 TAPA (braco no alto),
    5 tapa (braco abaixado a frente), 6 ARREMESSO (fruto atras), 7 AGARRAO (braco esticado),
    8 ENGOLE (boca enorme), 9 fase 2 parada (boca no ventre), 10 fase 2 passo, 11 fase 2 COME."""
    rng = random.Random(91)
    img = canvas(64, 64)
    phase2 = state >= 9
    breathe = 1 if state == 2 else 0
    lx = 20 - (3 if state in (1, 10) else 0)
    rx = 36 + (3 if state in (3,) else 0)
    # pernas (quase escondidas pela saia)
    rect(img, lx, 54, lx + 8, 63, P.MABEL_SKIN_DARK)
    rect(img, rx, 54, rx + 8, 63, P.MABEL_SKIN_DARK)
    hline(img, lx - 1, lx + 9, 63, P.BOOTS)
    hline(img, rx - 1, rx + 9, 63, P.BOOTS)
    # saia/vestido enorme
    ellipse(img, 32, 42 + breathe, 22, 16, P.MABEL_DRESS_DARK)
    ellipse(img, 31, 41 + breathe, 21, 15, P.MABEL_DRESS)
    # avental (rasgado na fase 2)
    rect(img, 20, 30, 42, 56, P.MABEL_APRON)
    rect(img, 20, 30, 23, 56, P.MABEL_APRON_DARK)
    for _ in range(9):
        ellipse(img, rng.randint(22, 40), rng.randint(34, 54), rng.uniform(1, 2.5), rng.uniform(0.8, 1.8), P.SAP_DARK)
    if phase2:
        # rasgo + boca no ventre com dentes
        open_h = 7 if state != 11 else 10
        ellipse(img, 31, 42, 9, open_h, P.SAP_DARK)
        ellipse(img, 31, 42, 7, open_h - 2, (34, 8, 14))
        for k in range(-6, 7, 2):
            put(img, 31 + k, 42 - open_h + 2 + abs(k) // 3, P.LARVA)
            put(img, 31 + k, 42 + open_h - 3 - abs(k) // 3, P.LARVA)
        for k in range(5):  # raizes saindo do corpo
            _root_strand(img, rng, 14 + k * 9, 46, 6 + k * 13, 63, 1.4, P.ROOTS_RED, P.ROOTS_RED_DARK, None, 2.0)
    # tronco e bracos
    ellipse(img, 31, 28, 15, 10, P.MABEL_DRESS)
    ellipse(img, 31, 27, 13, 8, shade(P.MABEL_DRESS, 1.1))
    # braco de tras (esquerdo) — descansando
    ellipse(img, 15, 36, 5, 10, P.MABEL_SKIN_DARK)
    ellipse(img, 14, 46, 5, 4, P.MABEL_SKIN_DARK)
    # cabeca
    head_y = 13 if state != 8 else 11
    ellipse(img, 32, head_y, 10, 9, P.MABEL_SKIN)
    ellipse(img, 34, head_y + 1, 8, 7, shade(P.MABEL_SKIN, 1.05))
    ellipse(img, 27, head_y + 3, 2.5, 2, (224, 130, 120))  # bochechas
    ellipse(img, 39, head_y + 3, 2.5, 2, (224, 130, 120))
    # lenco na cabeca
    ellipse(img, 31, head_y - 6, 11, 5, P.MABEL_SCARF)
    hline(img, 21, 42, head_y - 3, shade(P.MABEL_SCARF, 0.75))
    put(img, 21, head_y - 1, P.MABEL_SCARF)
    put(img, 20, head_y, P.MABEL_SCARF)
    # olhos (fechadinhos de sorriso; abertos e vermelhos na fase 2)
    if phase2:
        rect(img, 29, head_y - 1, 32, head_y + 1, P.VEIN)
        rect(img, 36, head_y - 1, 39, head_y + 1, P.VEIN)
    else:
        hline(img, 29, 32, head_y, (60, 36, 36))
        hline(img, 36, 39, head_y, (60, 36, 36))
    # boca
    if state == 8:
        ellipse(img, 34, head_y + 6, 6, 4.5, (34, 8, 14))
        hline(img, 29, 40, head_y + 2, P.LARVA)
    elif phase2:
        hline(img, 30, 39, head_y + 5, P.SAP_DARK)  # o sorriso foi embora
    elif state in (4, 6, 7):
        ellipse(img, 34, head_y + 5, 3, 1.6, P.SAP_DARK)
    else:
        hline(img, 31, 38, head_y + 5, (120, 50, 50))
        put(img, 30, head_y + 4, (120, 50, 50))
        put(img, 38, head_y + 4, (120, 50, 50))
    # braco da frente (direito): muda com o golpe
    skin, dark = P.MABEL_SKIN, P.MABEL_SKIN_DARK
    if state == 4:  # tapa: mao aberta no alto
        for k in range(14):
            ellipse(img, 44 + k * 0.3, 26 - k, 4, 4, skin)
        ellipse(img, 48, 9, 7, 6, skin)
        for f in range(4):
            vline(img, 43 + f * 3, 1, 6, dark)
    elif state == 5:  # tapa: mao baixa a frente
        for k in range(12):
            ellipse(img, 44 + k, 28 + k * 0.8, 4, 4, skin)
        ellipse(img, 57, 40, 6, 7, skin)
        for f in range(4):
            hline(img, 58, 63, 35 + f * 3, dark)
    elif state == 6:  # arremesso: fruto atras da cabeca
        for k in range(10):
            ellipse(img, 42 - k * 0.6, 26 - k * 1.4, 4, 4, skin)
        ellipse(img, 36, 7, 5, 5, P.FLESH)
        ellipse(img, 35, 6, 3, 3, P.FLESH_LIGHT)
    elif state == 7:  # agarrao: braco esticado reto
        for k in range(16):
            ellipse(img, 42 + k, 28, 4, 3.5, skin)
        ellipse(img, 60, 28, 4, 6, skin)
        for f in range(3):
            put(img, 63, 24 + f * 4, dark)
    elif state == 8:  # engole: mao na barriga
        ellipse(img, 44, 34, 5, 9, skin)
        ellipse(img, 40, 42, 6, 4, skin)
    elif state == 11:  # fase 2 come: os dois bracos levando algo ao ventre
        ellipse(img, 44, 36, 5, 8, skin)
        ellipse(img, 40, 44, 5, 4, skin)
        for k in range(4):
            ellipse(img, 36 + k * 1.6, 44, 1.6, 1.4, P.LARVA if k % 2 == 0 else P.LARVA_DARK)
    else:
        sway = 1 if state in (1, 3, 10) else 0
        ellipse(img, 46, 36 + sway, 5, 10, skin)
        ellipse(img, 47, 47 + sway, 5, 4, skin)
    return _outline(img)


def mabel_frames():
    return [_mabel(s) for s in range(12)]
