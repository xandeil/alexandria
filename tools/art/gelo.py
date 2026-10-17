"""Dominio Congelado (Ganancia — Cassian Virel): tiles, cenario, inimigos e chefes.

Biblia: "Cidade de cristais de gelo, bibliotecas congeladas, pessoas presas no gelo
em pose de leitura. O chao e escorregadio."
Todos os personagens olham para a DIREITA (o jogo espelha).
"""
from __future__ import annotations

import math
import random

import palette as P
from pixel import canvas, from_grid, paste, put, rect, hline, vline, ellipse, mix, add_outline

O = P.OUTLINE
T = 16


def _noise(img, x0, y0, base, alts, chance, rng, w=T, h=T):
    for y in range(y0, y0 + h):
        for x in range(x0, x0 + w):
            put(img, x, y, rng.choice(alts) if rng.random() < chance else base)


def _outline(img):
    return add_outline(img, O)


def _strip(frames, w, h):
    out = canvas(w * len(frames), h)
    for i, f in enumerate(frames):
        paste(out, f, i * w, 0)
    return out


# =============================================================================
# Tiles (atlas 8x3) — o layout e espelhado em THEMES["gelo"] (level.gd)
# =============================================================================

def snow_stone(img, ox, oy, seed, cracked=False):
    """Laje de pedra com neve nos rejuntes."""
    rng = random.Random(seed)
    # Pedra clara com rejunte ESCURO e fino: lê como calçamento (rejunte claro
    # sobre pedra média parecia uma parede de tijolos — confundia com as paredes).
    _noise(img, ox, oy, P.SNOW, [P.SNOW_LIGHT, P.SNOW_DARK], 0.2, rng)
    joint = mix(P.SNOW_DARK, P.FROST_STONE_LIGHT, 0.5)
    hline(img, ox, ox + T, oy + 7 + (seed % 2), joint)
    vline(img, ox + (3 if seed % 2 else 10), oy, oy + 7, joint)
    vline(img, ox + (12 if seed % 2 else 6), oy + 8, oy + T, joint)
    if cracked:
        x, y = ox + 3, oy + 2
        for _ in range(9):
            put(img, x, y, P.FROST_STONE)
            x += 1
            y += rng.choice((0, 1, 1))


def parquet(img, ox, oy, seed):
    """Taco da biblioteca, com geada nas pontas."""
    rng = random.Random(seed)
    for y in range(T):
        for x in range(T):
            board = ((x // 4) + (y // 8)) % 2
            base = P.PARQUET if board else P.PARQUET_DARK
            put(img, ox + x, oy + y, base if rng.random() > 0.12 else mix(base, P.SNOW, 0.35))
    for _ in range(3):
        put(img, ox + rng.randint(0, 15), oy + rng.randint(0, 15), P.SNOW_LIGHT)


def ice_floor(img, ox, oy, seed):
    """GELO: o chao que escorrega. Azul liso, com riscos de brilho (tem de ler 'liso')."""
    rng = random.Random(seed)
    _noise(img, ox, oy, P.ICE_FLOOR, [P.ICE_FLOOR_DARK], 0.08, rng)
    for k in range(2):  # brilho em diagonal
        x0 = ox + 2 + k * 8 + rng.randint(0, 2)
        for i in range(5):
            put(img, x0 + i, oy + 10 - i - k * 3, P.ICE_FLOOR_SHINE)
    hline(img, ox, ox + T, oy + T - 1, P.ICE_FLOOR_DARK)


def snow_rubble(img, ox, oy, seed):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.SNOW, [P.SNOW_DARK, P.SNOW_LIGHT], 0.3, rng)
    for _ in range(4):
        cx, cy = ox + rng.randint(2, 13), oy + rng.randint(2, 13)
        ellipse(img, cx, cy, 1.5, 1.0, P.FROST_STONE)
        put(img, cx - 1, cy - 1, P.FROST_STONE_LIGHT)


def crystal_vein(img, ox, oy, seed):
    snow_stone(img, ox, oy, seed)
    rng = random.Random(seed + 1)
    x, y = ox + rng.randint(1, 5), oy + 1
    for _ in range(14):
        put(img, x, y, P.CRYSTAL)
        if rng.random() < 0.3:
            put(img, x + 1, y, P.CRYSTAL_LIGHT)
        x += rng.choice((0, 1, 1))
        y += 1
        if y >= oy + T - 1 or x >= ox + T - 1:
            break


def pages_floor(img, ox, oy, seed):
    """Paginas soltas e congeladas no chao."""
    parquet(img, ox, oy, seed)
    rng = random.Random(seed + 7)
    for _ in range(3):
        x, y = ox + rng.randint(1, 10), oy + rng.randint(1, 11)
        rect(img, x, y, x + 4, y + 3, P.BOOK_PAGE)
        hline(img, x + 1, x + 3, y + 1, P.SNOW_DARK)


def snow_field(img, ox, oy, seed):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.SNOW, [P.SNOW_LIGHT, P.SNOW_DARK], 0.2, rng)


def frost_wall_top(img, ox, oy, seed):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.FROST_STONE_DARK, [P.FROST_STONE, P.SNOW_DARK], 0.25, rng)
    hline(img, ox, ox + T, oy, P.SNOW_LIGHT)


def frost_wall(img, ox, oy, seed, shelf=False):
    """Face da parede: pedra com gelo escorrendo; ou uma estante congelada embutida."""
    rng = random.Random(seed)
    _noise(img, ox, oy, P.FROST_STONE, [P.FROST_STONE_DARK, P.FROST_STONE_LIGHT], 0.2, rng)
    hline(img, ox, ox + T, oy, P.SNOW_LIGHT)
    hline(img, ox, ox + T, oy + 1, P.SNOW)
    hline(img, ox, ox + T, oy + T - 1, P.WALL_SHADOW)
    if shelf:
        rect(img, ox + 1, oy + 3, ox + 15, oy + 14, P.SHELF_WOOD_DARK)
        for row in (4, 9):
            x = ox + 2
            while x < ox + 14:
                c = rng.choice([P.BOOK_RED, P.BOOK_BLUE, P.BOOK_GREEN, P.BOOK_PAGE])
                vline(img, x, oy + row, oy + row + 4, c)
                x += 1 if rng.random() < 0.8 else 2
            hline(img, ox + 1, ox + 15, oy + row + 4, P.SHELF_WOOD)
        for _ in range(4):  # geada por cima dos livros
            put(img, ox + rng.randint(2, 13), oy + rng.randint(4, 12), P.CRYSTAL_LIGHT)
    else:
        for _ in range(2):  # pingentes de gelo
            x = ox + rng.randint(2, 13)
            vline(img, x, oy + 2, oy + 2 + rng.randint(2, 5), P.CRYSTAL_LIGHT)


def frost_arch(img, ox, oy, seed):
    frost_wall(img, ox, oy, seed)
    ellipse(img, ox + 8, oy + 15, 5.5, 9, (18, 22, 34))


def frost_cliff(img, ox, oy, seed, lower=False):
    rng = random.Random(seed)
    if not lower:
        _noise(img, ox, oy, P.FROST_STONE_DARK, [P.FROST_STONE, P.CRYSTAL_DARK], 0.2, rng)
        hline(img, ox, ox + T, oy, P.SNOW_LIGHT)
        hline(img, ox, ox + T, oy + 1, P.SNOW)
        x = ox + 4 + rng.randint(0, 7)
        vline(img, x, oy + 2, oy + 2 + rng.randint(3, 6), P.CRYSTAL_LIGHT)  # um pingente so
    else:
        for y in range(oy, oy + T):
            for x in range(ox, ox + T):
                depth = (y - oy) / T
                if rng.random() < depth * 0.9 and (x * 7 + y * 3 + seed) % 5 < 3:
                    continue
                put(img, x, y, rng.choice([P.FROST_STONE_DARK, P.CRYSTAL_DARK, P.FROST_STONE_DARK]))


def frozen_water(img, ox, oy, seed, shore=False):
    """Agua escura sob o gelo partido (solida: buraco no lago)."""
    rng = random.Random(seed)
    _noise(img, ox, oy, P.FROZEN_WATER, [P.FROZEN_WATER_LIGHT], 0.12, rng)
    for _ in range(2):
        x, y = ox + rng.randint(2, 11), oy + rng.randint(3, 12)
        hline(img, x, x + 3, y, P.FROZEN_WATER_LIGHT)
    if shore:
        for x in range(ox, ox + T):
            h = 3 + int(1.5 * math.sin(x * 0.9 + seed))
            vline(img, x, oy, oy + h, P.ICE_FLOOR)
            put(img, x, oy + h, P.ICE_FLOOR_SHINE)


def frost_atlas():
    img = canvas(8 * T, 3 * T)
    snow_stone(img, 0 * T, 0, 501)
    snow_stone(img, 1 * T, 0, 502)
    snow_stone(img, 2 * T, 0, 503, cracked=True)
    parquet(img, 3 * T, 0, 504)
    ice_floor(img, 4 * T, 0, 505)
    snow_rubble(img, 5 * T, 0, 506)
    crystal_vein(img, 6 * T, 0, 507)
    pages_floor(img, 7 * T, 0, 508)
    frost_wall_top(img, 0 * T, T, 511)
    frost_wall(img, 1 * T, T, 512)
    frost_wall(img, 2 * T, T, 513, shelf=True)
    frost_arch(img, 3 * T, T, 514)
    frost_cliff(img, 4 * T, T, 515)
    frost_cliff(img, 5 * T, T, 516, lower=True)
    # (6,1) = barreira invisivel
    frozen_water(img, 7 * T, T, 518)
    frozen_water(img, 0 * T, 2 * T, 521)
    frozen_water(img, 1 * T, 2 * T, 522, shore=True)
    ice_floor(img, 2 * T, 2 * T, 523)
    snow_field(img, 3 * T, 2 * T, 524)
    return img


# =============================================================================
# Cenario
# =============================================================================

def crystal_cluster():
    """Aglomerado de cristais de gelo. 16x24."""
    img = canvas(16, 24)
    for cx, h, w in ((5, 14, 2.5), (10, 18, 3.0), (13, 9, 2.0), (3, 8, 1.8)):
        for y in range(23 - h, 23):
            t = (y - (23 - h)) / h
            half = w * min(1.0, t * 2.2)
            hline(img, int(cx - half), int(cx + half) + 1, y, P.CRYSTAL)
            put(img, int(cx - half), y, P.CRYSTAL_LIGHT)
            put(img, int(cx + half), y, P.CRYSTAL_DARK)
    return _outline(img)


ROBE_GRID = [
    "....hhhh......",
    "...hhhhhh.....",
    "...hsssshh....",
    "...ssekss.....",
    "....ssss......",
    "...rrttrr.....",
    "..rrrttrrr....",
    ".rrRrttrRrr...",
    ".rr.rttr.rr...",
    ".ss.rttr.ss...",
    "....rttr......",
    "...rrrrrr.....",
    "...rRrrRr.....",
    "..rrRrrRrr....",
]
ROBE_HEMS = [
    ["..RRrrrrRR....", "...kk..kk....."],
    [".RRrrrrrRR....", "..kk....kk...."],
    ["..RRrrrrRR....", "...kk..kk....."],
    ["...RRrrRR.....", "....kkkk......"],
]


def _robed(key, hem=0, grid=None):
    return from_grid((grid or ROBE_GRID) + ROBE_HEMS[hem], key, outline=O)


def frozen_reader():
    """Uma pessoa presa no gelo em pose de leitura (decoracao; Biblia). 22x30."""
    img = canvas(22, 30)
    key = {"h": (96, 74, 56), "s": P.SKIN, "e": (40, 40, 60),
           "k": (40, 40, 60), "r": P.BOOK_BLUE, "R": P.LIBRARIAN_ROBE_DARK, "t": P.BOOK_PAGE}
    body = _robed(key)
    paste(img, body, 4, 9)
    rect(img, 10, 16, 15, 19, P.BOOK_RED)  # o livro aberto nas maos
    hline(img, 10, 15, 16, P.BOOK_PAGE)
    # o bloco de gelo em volta (translucido: mistura com a cor de baixo)
    px = img.load()
    for y in range(2, 30):
        for x in range(1, 21):
            r, g, b, a = px[x, y]
            if a == 0:
                px[x, y] = (*P.CRYSTAL_LIGHT, 110)
            else:
                m = mix((r, g, b), P.CRYSTAL_LIGHT, 0.45)
                px[x, y] = (m[0], m[1], m[2], 255)
    for y in range(3, 29, 5):
        put(img, 2 + (y % 3), y, (255, 255, 255, 200))
    hline(img, 1, 21, 2, (*P.CRYSTAL, 220))
    return img


def frozen_bookshelf():
    """Estante congelada (2 celulas). 32x30."""
    img = canvas(32, 30)
    rng = random.Random(61)
    rect(img, 1, 2, 31, 30, P.SHELF_WOOD_DARK)
    rect(img, 1, 2, 31, 4, P.SHELF_WOOD)
    for row in (5, 13, 21):
        x = 3
        while x < 29:
            c = rng.choice([P.BOOK_RED, P.BOOK_BLUE, P.BOOK_GREEN, P.BOOK_PAGE, P.BOOK_BLUE])
            h = rng.randint(5, 7)
            rect(img, x, row + 7 - h, x + 2, row + 7, c)
            x += 2 if rng.random() < 0.85 else 3
        hline(img, 2, 31, row + 7, P.SHELF_WOOD)
    for _ in range(14):  # geada
        put(img, rng.randint(3, 29), rng.randint(3, 28), P.CRYSTAL_LIGHT)
    hline(img, 1, 31, 2, P.SNOW_LIGHT)
    return _outline(img)


def display_case():
    """Vitrine de vidro com uma peca congelada dentro. 18x26."""
    img = canvas(18, 26)
    rect(img, 1, 18, 17, 26, P.SHELF_WOOD)
    hline(img, 1, 17, 18, P.FROST_GOLD)
    rect(img, 2, 2, 16, 18, (*P.CRYSTAL_LIGHT, 120))
    ellipse(img, 9, 11, 3, 4, P.FROST_GOLD)  # o objeto guardado
    put(img, 8, 9, (255, 250, 220))
    for y in range(3, 17, 3):
        put(img, 3, y, (255, 255, 255, 220))
    vline(img, 2, 2, 18, P.FROST_STONE_LIGHT)
    vline(img, 16, 2, 18, P.FROST_STONE_LIGHT)
    hline(img, 2, 16, 2, P.FROST_STONE_LIGHT)
    return _outline(img)


def ice_pillar_frames():
    """Pilar de gelo do Cassian (cobertura que derrete). 28x24 x3."""
    frames = []
    for state in range(3):
        rng = random.Random(91)
        img = canvas(28, 24)
        if state < 2:
            for y in range(2, 22):
                w = 8 if y > 5 else 8 - (5 - y)
                hline(img, 14 - w, 14 + w, y, P.CRYSTAL)
                put(img, 14 - w, y, P.CRYSTAL_LIGHT)
                put(img, 14 + w, y, P.CRYSTAL_DARK)
            vline(img, 10, 4, 19, P.CRYSTAL_LIGHT)
            vline(img, 11, 6, 12, (255, 255, 255))
            if state == 1:
                x, y = 15, 3
                for _ in range(15):
                    put(img, x, y, P.CRYSTAL_DARK)
                    x += rng.choice((-1, 0, 1))
                    y += 1
        else:
            for _ in range(8):
                cx, cy = rng.randint(4, 24), rng.randint(15, 21)
                ellipse(img, cx, cy, rng.uniform(1.5, 3.0), rng.uniform(1.0, 2.0), P.CRYSTAL)
                put(img, cx - 1, cy - 1, P.CRYSTAL_LIGHT)
        frames.append(_outline(img))
    return _strip(frames, 28, 24)


def ice_shard():
    """Estilhaco de gelo em voo (olhando para a direita; o jogo gira). 12x6."""
    img = canvas(12, 6)
    for x in range(12):
        h = max(0, 2 - abs(x - 8) // 2) if x > 4 else 1
        vline(img, x, 3 - h, 3 + h, P.CRYSTAL)
    hline(img, 2, 11, 2, P.CRYSTAL_LIGHT)
    put(img, 11, 3, (255, 255, 255))
    return _outline(img)


def flying_book():
    """Livro congelado arremessado. 12x10."""
    img = canvas(12, 10)
    rect(img, 1, 1, 11, 9, P.BOOK_BLUE)
    vline(img, 6, 1, 9, P.BOOK_PAGE)
    hline(img, 1, 11, 1, P.CRYSTAL_LIGHT)
    put(img, 3, 4, P.FROST_GOLD)
    return _outline(img)


def ice_block():
    """O bloco de gelo que prende o heroi (translucido). 26x30."""
    img = canvas(26, 30)
    rect(img, 2, 3, 24, 29, (*P.CRYSTAL_LIGHT, 120))
    rect(img, 2, 3, 24, 5, (*P.SNOW_LIGHT, 200))
    vline(img, 2, 3, 29, (*P.CRYSTAL, 230))
    vline(img, 23, 3, 29, (*P.CRYSTAL_DARK, 230))
    hline(img, 2, 24, 28, (*P.CRYSTAL_DARK, 230))
    for y in range(7, 26, 4):
        put(img, 5, y, (255, 255, 255, 230))
        put(img, 6, y + 1, (255, 255, 255, 160))
    vline(img, 18, 8, 15, (255, 255, 255, 140))
    return img


def lore_book():
    """O livro do Arquivo, aberto no chao (memorial do Golem). 18x12."""
    img = canvas(18, 12)
    rect(img, 1, 3, 17, 11, P.BOOK_RED)
    rect(img, 2, 2, 8, 10, P.BOOK_PAGE)
    rect(img, 10, 2, 16, 10, P.BOOK_PAGE)
    for y in (4, 6, 8):
        hline(img, 3, 7, y, P.SNOW_DARK)
        hline(img, 11, 15, y, P.SNOW_DARK)
    vline(img, 9, 2, 11, P.SHELF_WOOD_DARK)
    put(img, 13, 3, P.FROST_GOLD)
    return _outline(img)


def arconte_staff():
    """O cajado do Arconte, caido (memorial de Cassian). 30x10."""
    img = canvas(30, 10)
    hline(img, 1, 22, 6, P.SHELF_WOOD)
    hline(img, 1, 22, 7, P.SHELF_WOOD_DARK)
    for y in range(1, 10):
        w = 3 - abs(y - 5) * 0.6
        hline(img, int(25 - w), int(25 + w) + 1, y, P.CRYSTAL)
    put(img, 24, 4, (255, 255, 255))
    put(img, 22, 6, P.FROST_GOLD)
    return _outline(img)


# =============================================================================
# Inimigos
# =============================================================================

LIBRARIAN_KEY = {"h": P.LIBRARIAN_ROBE_DARK, "s": P.SKIN_SHADOW, "e": P.CRYSTAL_LIGHT, "k": (30, 34, 52),
                 "r": P.LIBRARIAN_ROBE, "R": P.LIBRARIAN_ROBE_DARK, "t": P.BOOK_PAGE}


def librarian_frames():
    """Bibliotecario de Gelo (24x24): capuz, um livro aberto na mao. [idle, passo x3]"""
    frames = []
    for hem in range(4):
        img = canvas(24, 24)
        paste(img, _robed(LIBRARIAN_KEY, hem), 4, 4)
        rect(img, 14, 12, 19, 15, P.BOOK_BLUE)  # o livro
        hline(img, 14, 19, 12, P.BOOK_PAGE)
        put(img, 19, 11, P.CRYSTAL_LIGHT)  # brilho do feitico
        frames.append(_outline(img))
    return frames


STATUE_KEY = {"h": P.STATUE_MARBLE_DARK, "s": P.STATUE_MARBLE, "e": P.STATUE_MARBLE_DARK, "k": P.STATUE_MARBLE_DARK,
              "r": P.STATUE_MARBLE, "R": P.STATUE_MARBLE_DARK, "t": P.SNOW_LIGHT}


def statue_frames():
    """Estatua Viva (24x26): uma pessoa 'importante' em marmore, lendo. [pedra, passo, passo, golpe]"""
    frames = []
    for state in range(4):
        img = canvas(24, 26)
        hem = (0, 1, 2, 3)[state]
        paste(img, _robed(STATUE_KEY, hem), 4, 6)
        if state < 3:
            rect(img, 13, 14, 18, 17, P.STATUE_MARBLE_DARK)  # o livro de pedra
            hline(img, 13, 18, 14, P.SNOW_LIGHT)
        else:  # golpe: o braco erguido com o livro de pedra
            rect(img, 15, 4, 20, 8, P.STATUE_MARBLE_DARK)
            vline(img, 15, 8, 13, P.STATUE_MARBLE)
        put(img, 9, 9, P.CRYSTAL)  # um olho que brilha quando anda
        if state in (1, 2, 3):
            put(img, 9, 9, (120, 220, 255))
        frames.append(_outline(img))
    return frames


def mite_frames():
    """Acaro de Cristal (12x10): bichinho de cristal com perninhas. 3 quadros."""
    frames = []
    for step in range(3):
        img = canvas(12, 10)
        ellipse(img, 6, 5, 4, 3, P.CRYSTAL)
        ellipse(img, 5, 4, 2, 1.5, P.CRYSTAL_LIGHT)
        put(img, 9, 4, (20, 30, 60))
        for i, x in enumerate((3, 6, 9)):
            dy = 1 if (i + step) % 2 else 0
            vline(img, x, 7, 8 + dy, P.CRYSTAL_DARK)
        put(img, 6, 1, P.CRYSTAL_LIGHT)  # espinho
        put(img, 4, 2, P.CRYSTAL_LIGHT)
        frames.append(_outline(img))
    return frames


APPRENTICE_KEY = {"h": (80, 60, 50), "s": P.SKIN, "e": (40, 30, 50), "k": (30, 24, 40),
                  "r": P.APPRENTICE_ROBE, "R": P.APPRENTICE_ROBE_DARK, "t": P.FROST_GOLD}


def apprentice_frames():
    """Aprendiz Arcano (24x24): toga roxa, varinha de cristal. [idle, passo x3]"""
    frames = []
    for hem in range(4):
        img = canvas(24, 24)
        paste(img, _robed(APPRENTICE_KEY, hem), 4, 4)
        vline(img, 18, 8, 18, P.SHELF_WOOD)  # varinha
        put(img, 18, 7, P.CRYSTAL_LIGHT)
        put(img, 18, 6, P.CRYSTAL)
        frames.append(_outline(img))
    return frames


# =============================================================================
# Mini-chefes e chefe
# =============================================================================

CURATOR_GRID = [
    ".....hhhh.......",
    "....hhhhhh......",
    "....hsssshh.....",
    "....ssekss......",
    ".....ssss.......",
    "....LLttLL......",
    "...ddddddd......",
    "..dddLLLddd.....",
    "..dd.dLLd.dd....",
    "..ss.dddd.ss....",
    ".....dddd.......",
    "....dddddd......",
    "....dDddDd......",
    "...ddDddDdd.....",
    "...dDdddddDd....",
    "..ddDdddddDdd...",
]
CURATOR_HEMS = [
    ["..DDdddddddDD...", ".....kk..kk....."],
    [".DDddddddddDD...", "....kk....kk...."],
    ["..DDdddddddDD...", ".....kk..kk....."],
]


def curator_frames():
    """A Curadora de Vitrines (32x32): vestido longo de museu, coque, bengala-chave.
    [idle, passo, passo, conjura (bracos erguidos), bengala]"""
    key = {"h": (180, 180, 196), "s": P.SKIN, "e": (40, 40, 60), "k": (30, 30, 44),
           "d": P.CURATOR_DRESS, "D": P.CURATOR_DRESS_DARK, "L": P.CURATOR_LACE, "t": P.FROST_GOLD}
    frames = []
    for state in range(5):
        img = canvas(32, 32)
        hem = CURATOR_HEMS[(0, 1, 2, 0, 0)[state]]
        body = from_grid(CURATOR_GRID + hem, key, outline=O)
        paste(img, body, 7, 32 - body.height)
        if state == 3:  # conjura: bracos para o alto, cristal acima
            vline(img, 9, 4, 12, P.SKIN)
            vline(img, 20, 4, 12, P.SKIN)
            ellipse(img, 15, 2, 3, 2, P.CRYSTAL_LIGHT)
        elif state == 4:  # bengala estocando a frente
            hline(img, 18, 31, 17, P.FROST_GOLD)
            put(img, 31, 16, P.CRYSTAL_LIGHT)
        else:  # bengala apoiada
            vline(img, 22, 14, 31, P.FROST_GOLD)
            put(img, 22, 13, P.CRYSTAL_LIGHT)
        frames.append(_outline(img))
    return frames


def golem_frames():
    """O Golem do Arquivo (48x48): feito de estantes congeladas, olhos de cristal.
    [idle, passo, ergue, esmaga, varre]"""
    frames = []
    for state in range(5):
        rng = random.Random(201)
        img = canvas(48, 48)
        bob = (0, 1, 0, 3, 0)[state]
        # pernas: duas estantes baixas
        lx = (0, 2, 0, 0, 0)[state]
        for x0 in (12 + lx, 28 - lx):
            rect(img, x0, 36, x0 + 8, 47, P.SHELF_WOOD_DARK)
            hline(img, x0, x0 + 8, 41, P.SHELF_WOOD)
        # tronco: uma estante grande cheia de livros
        top = 12 + bob
        rect(img, 9, top, 39, 37, P.SHELF_WOOD_DARK)
        rect(img, 9, top, 39, top + 2, P.SHELF_WOOD)
        for row in range(top + 4, 36, 7):
            x = 11
            while x < 37:
                c = rng.choice([P.BOOK_RED, P.BOOK_BLUE, P.BOOK_GREEN, P.BOOK_PAGE])
                rect(img, x, row, x + 2, row + 5, c)
                x += 3
            hline(img, 10, 39, row + 6, P.SHELF_WOOD)
        # cabeca: um bloco de gelo com dois olhos
        rect(img, 17, top - 10, 31, top, P.CRYSTAL)
        hline(img, 17, 31, top - 10, P.CRYSTAL_LIGHT)
        put(img, 21, top - 6, (230, 250, 255))
        put(img, 27, top - 6, (230, 250, 255))
        # bracos
        if state == 2:  # erguidos
            rect(img, 4, top - 14, 9, top + 6, P.SHELF_WOOD)
            rect(img, 39, top - 14, 44, top + 6, P.SHELF_WOOD)
        elif state == 3:  # esmagando no chao
            rect(img, 2, 38, 12, 46, P.SHELF_WOOD)
            rect(img, 36, 38, 46, 46, P.SHELF_WOOD)
        elif state == 4:  # varrendo para a frente
            rect(img, 38, top + 8, 47, top + 13, P.SHELF_WOOD)
            rect(img, 4, top + 2, 9, top + 20, P.SHELF_WOOD)
        else:
            rect(img, 4, top + 2, 9, top + 22, P.SHELF_WOOD)
            rect(img, 39, top + 2, 44, top + 22, P.SHELF_WOOD)
        for _ in range(16):  # geada
            put(img, rng.randint(9, 39), rng.randint(top, 37), P.CRYSTAL_LIGHT)
        frames.append(_outline(img))
    return frames


CASSIAN_GRID = [
    "....HHHHH.......",
    "...HHHHHHH......",
    "...HssssHH......",
    "...ssekssH......",
    "....ssssHH......",
    "....rttrrH......",
    "...rrrttrrr.....",
    "..rrRrttrRrr....",
    "..rr.rttr.rr....",
    "..ss.rttr.ss....",
    ".....rttr.......",
    "....rrrrrr......",
    "....rRrrRr......",
    "...rrRrrRrr.....",
    "...rRrrrrRr.....",
    "..rrRrrrrRrr....",
]
CASSIAN_HEMS = [
    ["..RRrrrrrrRR....", ".....kk.kk......"],
    [".RRrrrrrrrRR....", "....kk...kk....."],
    ["..RRrrrrrrRR....", ".....kk.kk......"],
]


def cassian_frames():
    """Cassian Virel (32x32): arquimago de toga branca, cabelo prateado longo, cajado de cristal.
    [idle, passo, passo, conjura, ergue, cajado, idle2 (fase 2: coroa de gelo)]"""
    key = {"H": P.CASSIAN_HAIR, "s": P.SKIN, "e": P.CASSIAN_TRIM, "k": (40, 46, 70),
           "r": P.CASSIAN_ROBE, "R": P.CASSIAN_ROBE_DARK, "t": P.CASSIAN_TRIM}
    frames = []
    for state in range(7):
        img = canvas(32, 32)
        hem = CASSIAN_HEMS[(0, 1, 2, 0, 0, 0, 0)[state]]
        body = from_grid(CASSIAN_GRID + hem, key, outline=O)
        paste(img, body, 6, 32 - body.height)
        if state == 3:  # conjura: cajado apontado a frente
            hline(img, 17, 28, 15, P.SHELF_WOOD)
            ellipse(img, 29, 15, 2, 3, P.CRYSTAL)
            put(img, 29, 14, (255, 255, 255))
        elif state == 4:  # ergue: cajado para o alto
            vline(img, 21, 1, 18, P.SHELF_WOOD)
            ellipse(img, 21, 2, 3, 2.5, P.CRYSTAL)
            put(img, 20, 1, (255, 255, 255))
        elif state == 5:  # golpe de cajado
            for i in range(10):
                put(img, 18 + i, 10 + i, P.SHELF_WOOD)
            ellipse(img, 29, 21, 2.5, 2.5, P.CRYSTAL)
        else:  # cajado apoiado
            vline(img, 22, 6, 31, P.SHELF_WOOD)
            ellipse(img, 22, 5, 2.5, 3, P.CRYSTAL)
            put(img, 21, 4, (255, 255, 255))
        if state == 6:  # o Colecionador: coroa de cristais
            for x, h in ((10, 3), (12, 5), (14, 3)):
                vline(img, x, 6 - h, 6, P.CRYSTAL_LIGHT)
        frames.append(_outline(img))
    return frames


SCHOLAR_KEY = {"h": (110, 84, 60), "s": P.SKIN, "e": (40, 30, 30), "k": (40, 34, 40),
               "r": (120, 104, 84), "R": (88, 74, 60), "t": P.BOOK_PAGE}


def scholar(frozen=False):
    """O Estudioso (NPC): sentado lendo; congelado (Biblia) ate a Curadora cair. 22x30."""
    img = canvas(22, 30)
    paste(img, _robed(SCHOLAR_KEY, 3), 4, 9)
    rect(img, 11, 17, 16, 20, P.BOOK_GREEN)
    hline(img, 11, 16, 17, P.BOOK_PAGE)
    # oculos
    put(img, 8, 12, P.FROST_GOLD)
    put(img, 10, 12, P.FROST_GOLD)
    img = _outline(img)
    if not frozen:
        return img
    px = img.load()
    for y in range(2, 30):
        for x in range(1, 21):
            r, g, b, a = px[x, y]
            if a == 0:
                px[x, y] = (*P.CRYSTAL_LIGHT, 110)
            else:
                m = mix((r, g, b), P.CRYSTAL_LIGHT, 0.45)
                px[x, y] = (m[0], m[1], m[2], 255)
    hline(img, 1, 21, 2, (*P.CRYSTAL, 220))
    return img
