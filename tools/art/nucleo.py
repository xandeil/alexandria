"""O Nucleo (final): o jardim com ruinas, o Cavaleiro Desolado e a mulher ligada ao nucleo.

Biblia: "A ilha mais alta, jardim com ruinas." / "A mulher atras dele respirava
lentamente, ligada a propria estrutura da ilha."
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
# Tiles (atlas 8x3) — o layout e espelhado em THEMES["nucleo"] (level.gd)
# =============================================================================

def marble(img, ox, oy, seed, cracked=False):
    """Laje de marmore antigo com rejunte escuro (le como chao)."""
    rng = random.Random(seed)
    _noise(img, ox, oy, P.RUIN_MARBLE, [P.RUIN_MARBLE_LIGHT, P.RUIN_MARBLE_DARK], 0.15, rng)
    joint = mix(P.RUIN_MARBLE_DARK, P.RUIN_MOSS, 0.35)
    hline(img, ox, ox + T, oy + T - 1, joint)
    vline(img, ox + T - 1, oy, oy + T, joint)
    if cracked:
        x, y = ox + 2, oy + 3
        for _ in range(10):
            put(img, x, y, P.RUIN_MARBLE_DARK)
            x += 1
            y += rng.choice((0, 1))
        for _ in range(3):
            put(img, ox + rng.randint(1, 13), oy + rng.randint(1, 13), P.RUIN_MOSS)


def grass(img, ox, oy, seed):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.GARDEN_GRASS, [P.GARDEN_GRASS_DARK, P.GARDEN_GRASS_LIGHT], 0.3, rng)


def flowers(img, ox, oy, seed):
    grass(img, ox, oy, seed)
    rng = random.Random(seed + 3)
    for _ in range(6):
        x, y = ox + rng.randint(1, 14), oy + rng.randint(1, 14)
        c = rng.choice([P.GARDEN_FLOWER, P.GARDEN_FLOWER, P.GARDEN_FLOWER_PINK])
        put(img, x, y, c)
        put(img, x, y + 1, P.GARDEN_GRASS_DARK)


def mossy(img, ox, oy, seed):
    marble(img, ox, oy, seed)
    rng = random.Random(seed + 5)
    for _ in range(18):
        put(img, ox + rng.randint(0, 15), oy + rng.randint(0, 15), rng.choice([P.RUIN_MOSS, P.GARDEN_GRASS]))


def golden_vein(img, ox, oy, seed):
    """Marmore com fios dourados: a luz do nucleo correndo pelo chao."""
    marble(img, ox, oy, seed)
    rng = random.Random(seed + 9)
    x, y = ox + rng.randint(0, 4), oy
    for _ in range(18):
        put(img, x, y, P.CORE_GOLD)
        x += rng.choice((0, 1, 1))
        y += 1
        if y >= oy + T or x >= ox + T:
            break


def light_path(img, ox, oy, seed):
    """O caminho de luz ate o coracao."""
    rng = random.Random(seed)
    _noise(img, ox, oy, P.CORE_GLOW, [P.CORE_GOLD, P.RUIN_MARBLE_LIGHT], 0.2, rng)
    hline(img, ox, ox + T, oy + T - 1, P.CORE_GOLD)


def ruin_top(img, ox, oy, seed):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.RUIN_MARBLE_DARK, [P.RUIN_MOSS, P.GARDEN_GRASS_DARK], 0.35, rng)


def ruin_wall(img, ox, oy, seed, ivy=False):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.RUIN_MARBLE_DARK, [P.RUIN_MARBLE, (140, 132, 120)], 0.2, rng)
    hline(img, ox, ox + T, oy, P.RUIN_MARBLE_LIGHT)
    hline(img, ox, ox + T, oy + 7, (140, 132, 120))
    vline(img, ox + (5 if seed % 2 else 11), oy + 1, oy + 7, (140, 132, 120))
    hline(img, ox, ox + T, oy + T - 1, P.WALL_SHADOW)
    if ivy:
        x = ox + rng.randint(2, 6)
        for y in range(oy, oy + rng.randint(9, 14)):
            put(img, x, y, P.GARDEN_GRASS_DARK)
            if rng.random() < 0.4:
                put(img, x + 1, y, P.GARDEN_GRASS)
            x += rng.choice((-1, 0, 0, 1))


def ruin_arch(img, ox, oy, seed):
    ruin_wall(img, ox, oy, seed)
    ellipse(img, ox + 8, oy + 15, 5.5, 9, (30, 28, 36))


def ruin_cliff(img, ox, oy, seed, lower=False):
    rng = random.Random(seed)
    if not lower:
        _noise(img, ox, oy, P.RUIN_MARBLE_DARK, [(140, 132, 120), P.RUIN_MOSS], 0.25, rng)
        hline(img, ox, ox + T, oy, P.GARDEN_GRASS)
        hline(img, ox, ox + T, oy + 1, P.GARDEN_GRASS_DARK)
    else:
        for y in range(oy, oy + T):
            for x in range(ox, ox + T):
                depth = (y - oy) / T
                if rng.random() < depth * 0.9 and (x * 7 + y * 3 + seed) % 5 < 3:
                    continue
                put(img, x, y, rng.choice([P.RUIN_MARBLE_DARK, (120, 112, 104)]))


def sky_pool(img, ox, oy, seed, shore=False):
    """Espelho d'agua que reflete o ceu (solido)."""
    rng = random.Random(seed)
    _noise(img, ox, oy, P.CORE_POOL, [P.CORE_POOL_LIGHT], 0.1, rng)
    for _ in range(2):
        x, y = ox + rng.randint(2, 11), oy + rng.randint(3, 12)
        hline(img, x, x + 3, y, P.CORE_POOL_LIGHT)
    if shore:
        for x in range(ox, ox + T):
            h = 3 + int(1.5 * math.sin(x * 0.8 + seed))
            vline(img, x, oy, oy + h, P.RUIN_MARBLE)
            put(img, x, oy + h, P.RUIN_MARBLE_DARK)


def core_atlas():
    img = canvas(8 * T, 3 * T)
    marble(img, 0 * T, 0, 601)
    marble(img, 1 * T, 0, 602)
    marble(img, 2 * T, 0, 603, cracked=True)
    grass(img, 3 * T, 0, 604)
    flowers(img, 4 * T, 0, 605)
    mossy(img, 5 * T, 0, 606)
    golden_vein(img, 6 * T, 0, 607)
    light_path(img, 7 * T, 0, 608)
    ruin_top(img, 0 * T, T, 611)
    ruin_wall(img, 1 * T, T, 612)
    ruin_wall(img, 2 * T, T, 613, ivy=True)
    ruin_arch(img, 3 * T, T, 614)
    ruin_cliff(img, 4 * T, T, 615)
    ruin_cliff(img, 5 * T, T, 616, lower=True)
    # (6,1) = barreira invisivel
    sky_pool(img, 7 * T, T, 618)
    sky_pool(img, 0 * T, 2 * T, 621)
    sky_pool(img, 1 * T, 2 * T, 622, shore=True)
    marble(img, 2 * T, 2 * T, 623)
    grass(img, 3 * T, 2 * T, 624)
    return img


# =============================================================================
# Cenario
# =============================================================================

def ruin_column():
    """Coluna partida coberta de hera. 14x30."""
    img = canvas(14, 30)
    rng = random.Random(71)
    rect(img, 3, 8, 11, 28, P.RUIN_MARBLE)
    vline(img, 4, 8, 28, P.RUIN_MARBLE_LIGHT)
    vline(img, 10, 8, 28, P.RUIN_MARBLE_DARK)
    for x in range(3, 11):  # topo quebrado
        put(img, x, 8 - (x * 3 % 4), P.RUIN_MARBLE)
    rect(img, 1, 27, 13, 30, P.RUIN_MARBLE_DARK)
    x = 5
    for y in range(12, 28):
        put(img, x, y, P.GARDEN_GRASS_DARK)
        x = max(3, min(10, x + rng.choice((-1, 0, 1))))
    return _outline(img)


def flower_bush():
    """Arbusto com flores brancas. 16x14."""
    img = canvas(16, 14)
    rng = random.Random(72)
    ellipse(img, 8, 8, 7, 5, P.GARDEN_GRASS_DARK)
    ellipse(img, 7, 7, 6, 4, P.GARDEN_GRASS)
    for _ in range(7):
        put(img, rng.randint(3, 12), rng.randint(4, 10), rng.choice([P.GARDEN_FLOWER, P.GARDEN_FLOWER_PINK]))
    return _outline(img)


def broken_arch():
    """Um arco de marmore partido (2 celulas). 32x30."""
    img = canvas(32, 30)
    rect(img, 2, 10, 8, 29, P.RUIN_MARBLE)
    rect(img, 24, 16, 30, 29, P.RUIN_MARBLE)
    for x in range(2, 20):  # o arco, partido no meio
        y = int(10 - 7 * math.sin(math.pi * (x - 2) / 28))
        rect(img, x, y, x + 1, y + 3, P.RUIN_MARBLE_LIGHT)
    vline(img, 8, 10, 29, P.RUIN_MARBLE_DARK)
    vline(img, 30, 16, 29, P.RUIN_MARBLE_DARK)
    return _outline(img)


def sin_statue():
    """Estatua encapuzada de um dos Sete (sem rosto: a memoria e que lhe da rosto). 18x32."""
    img = canvas(18, 32)
    rect(img, 2, 26, 16, 32, P.RUIN_MARBLE_DARK)
    hline(img, 2, 16, 26, P.RUIN_MARBLE_LIGHT)
    for y in range(4, 26):  # manto
        w = 3 + (y - 4) * 0.25
        hline(img, int(9 - w), int(9 + w) + 1, y, P.RUIN_MARBLE)
        put(img, int(9 - w), y, P.RUIN_MARBLE_LIGHT)
        put(img, int(9 + w), y, P.RUIN_MARBLE_DARK)
    ellipse(img, 9, 6, 4, 4, P.RUIN_MARBLE)  # capuz
    ellipse(img, 9, 7, 2.5, 2.5, P.RUIN_MARBLE_DARK)
    put(img, 9, 18, P.CORE_GOLD)  # uma pequena luz no peito
    return _outline(img)


# =============================================================================
# O Cavaleiro Desolado e a mulher do nucleo
# =============================================================================

KNIGHT_GRID = [
    ".....aaaa.......",
    "....aAAAAa......",
    "....aAkkAa......",
    "....aAAAAa......",
    ".....aaaa.......",
    "...aaAAAAaa.....",
    "..aAAAccAAAa....",
    "..aAAcccAAAa....",
    "..aa.AccA.aa....",
    "..aa.aAAa.aa....",
    "..AA.aaaa.AA....",
    ".....cccc.......",
    "....cccccc......",
    "....aa..aa......",
    "....aa..aa......",
]
KNIGHT_LEGS = [
    ["....AA..AA......", "...aaa..aaa....."],
    ["...AA....AA.....", "..aaa....aaa...."],
    ["....AA..AA......", "...aaa..aaa....."],
]


def knight_frames():
    """O Cavaleiro Desolado (40x40): armadura gasta, capa vermelha rasgada, espadao.
    [idle, passo, passo, ergue, corte, guarda, atrai (mao estendida), ajoelha]"""
    key = {"a": P.KNIGHT_ARMOR_DARK, "A": P.KNIGHT_ARMOR, "k": (20, 20, 26), "c": P.KNIGHT_CLOTH}
    frames = []
    for state in range(8):
        img = canvas(40, 40)
        if state == 7:  # ajoelhado: mais baixo, espada cravada a frente
            body = from_grid(KNIGHT_GRID[:13] + ["...aaaaaaa......"], key, outline=O)
            big = body.resize((body.width * 3 // 2, body.height * 3 // 2))
            paste(img, big, 6, 40 - big.height)
            vline(img, 30, 14, 39, P.KNIGHT_ARMOR_LIGHT)
            hline(img, 27, 33, 16, P.CORE_GOLD)
            frames.append(_outline(img))
            continue
        legs = KNIGHT_LEGS[(0, 1, 2, 0, 0, 0, 0)[state]]
        body = from_grid(KNIGHT_GRID + legs, key, outline=O)
        big = body.resize((body.width * 3 // 2, body.height * 3 // 2))
        paste(img, big, 6, 40 - big.height)
        rect(img, 7, 16, 10, 34, P.KNIGHT_CLOTH)  # capa rasgada atras
        put(img, 8, 35, P.KNIGHT_CLOTH)
        if state == 3:  # ergue o espadao
            vline(img, 26, 0, 16, P.KNIGHT_ARMOR_LIGHT)
            vline(img, 27, 1, 16, P.KNIGHT_ARMOR)
            hline(img, 23, 30, 16, P.CORE_GOLD)
        elif state == 4:  # corte (espadao a frente, baixo)
            hline(img, 24, 39, 26, P.KNIGHT_ARMOR_LIGHT)
            hline(img, 24, 39, 27, P.KNIGHT_ARMOR)
            vline(img, 24, 23, 30, P.CORE_GOLD)
        elif state == 5:  # guarda: espadao na vertical a frente do corpo
            vline(img, 28, 8, 34, P.KNIGHT_ARMOR_LIGHT)
            vline(img, 29, 8, 34, P.KNIGHT_ARMOR)
            hline(img, 25, 32, 22, P.CORE_GOLD)
        elif state == 6:  # atrai: mao estendida, luz na palma
            hline(img, 22, 31, 20, P.KNIGHT_ARMOR)
            ellipse(img, 33, 20, 2.5, 2.5, P.CORE_GLOW)
            vline(img, 12, 14, 34, P.KNIGHT_ARMOR_LIGHT)  # espadao nas costas
        else:  # espadao apoiado no chao
            vline(img, 27, 14, 39, P.KNIGHT_ARMOR_LIGHT)
            vline(img, 28, 14, 39, P.KNIGHT_ARMOR)
            hline(img, 24, 31, 15, P.CORE_GOLD)
        frames.append(_outline(img))
    return frames


def woman_frames():
    """A mulher do nucleo (32x48): suspensa, cabelos brancos, presa por fios de luz.
    [respira 1, respira 2]"""
    frames = []
    for state in range(2):
        img = canvas(32, 48)
        lift = state
        # fios de luz descendo ate o chao (a estrutura da ilha)
        for x, top in ((6, 16), (26, 16), (11, 30), (21, 30)):
            for y in range(top, 48):
                if (y + state) % 3:
                    put(img, x, y, (*P.CORE_GLOW, 200))
        # vestido longo
        for y in range(14 - lift, 40 - lift):
            w = 3 + (y - 14) * 0.22
            hline(img, int(16 - w), int(16 + w) + 1, y, P.WOMAN_DRESS)
            put(img, int(16 - w), y, (200, 200, 214))
        # cabelos longos e rosto de olhos fechados
        rect(img, 12, 3 - lift, 21, 22 - lift, P.WOMAN_HAIR)
        ellipse(img, 16, 8 - lift, 3.5, 4, P.SKIN)
        hline(img, 14, 15, 8 - lift, (150, 140, 150))
        hline(img, 17, 18, 8 - lift, (150, 140, 150))
        # uma luz no peito (o nucleo)
        ellipse(img, 16, 20 - lift, 2, 2, P.CORE_GLOW)
        put(img, 16, 20 - lift, (255, 255, 255))
        frames.append(_outline(img))
    return frames


def falling_stone():
    """Pedaco de marmore que cai do alto (a gravidade do Cavaleiro). 12x11."""
    img = canvas(12, 11)
    ellipse(img, 6, 6, 5, 4.5, P.RUIN_MARBLE_DARK)
    ellipse(img, 5, 5, 4, 3.5, P.RUIN_MARBLE)
    put(img, 4, 3, P.RUIN_MARBLE_LIGHT)
    put(img, 8, 7, P.RUIN_MOSS)
    return _outline(img)
