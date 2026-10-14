"""Forjas Ocas (Inveja — Durgan Vell): tiles, cenario, inimigos e chefes.

Biblia: "Ruinas de pedra por cima, fabrica subterranea por baixo. Placas
metalicas no chao, correntes enormes descendo ate as Ancoras da ilha."
Mapa do mundo, ilha 5: ruinas de pedra com torres e musgo.
Todos os personagens olham para a DIREITA (o jogo espelha).
"""
from __future__ import annotations

import math
import random

import characters as C
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


def _ramp(lum, dark, mid, light):
    """Luminancia 0..1 → cor numa rampa de 3 tons (para 'fundir' sprites em bronze)."""
    if lum < 0.5:
        return mix(dark, mid, lum * 2)
    return mix(mid, light, (lum - 0.5) * 2)


def recolor(img, dark, mid, light, special=None, gaps=0.0, seed=1):
    """Pinta um sprite inteiro numa rampa (bronze, espelho...). special: cores originais
    que viram outra cor fixa (ex.: os olhos viram brasa). gaps: furos de 'inacabado'."""
    rng = random.Random(seed)
    special = special or {}
    out = img.copy()
    px = out.load()
    for y in range(out.height):
        for x in range(out.width):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            if (r, g, b) == O[:3]:
                continue
            if (r, g, b) in special:
                px[x, y] = (*special[(r, g, b)][:3], 255)
                continue
            lum = (r * 0.3 + g * 0.59 + b * 0.11) / 255
            c = _ramp(min(1.0, lum * 1.15), dark, mid, light)
            if gaps and rng.random() < gaps and lum > 0.25:
                c = (34, 28, 24, 255)
            px[x, y] = (c[0], c[1], c[2], 255)
    return out


# =============================================================================
# Tiles (atlas 8x3) — o layout e espelhado em THEMES["forjas"] (level.gd)
# =============================================================================

def stone_floor(img, ox, oy, seed, cracked=False, ash=False):
    rng = random.Random(seed)
    base = P.FORGE_STONE if not ash else shade(P.FORGE_STONE_DARK, 0.9)
    _noise(img, ox, oy, base, [P.FORGE_STONE_DARK, P.FORGE_STONE_LIGHT], 0.22, rng)
    # lajes grandes (8x8 desencontradas)
    off = 4 if (seed % 2) else 0
    hline(img, ox, ox + T, oy + 7, P.FORGE_STONE_DARK)
    vline(img, ox + off + 3, oy, oy + 7, P.FORGE_STONE_DARK)
    vline(img, ox + (off + 11) % T, oy + 8, oy + T, P.FORGE_STONE_DARK)
    if cracked:
        x, y = ox + 4, oy + 1
        for _ in range(14):
            put(img, x, y, P.FORGE_WALL_DARK)
            x += rng.choice((0, 1))
            y += 1
            if y >= oy + T:
                break
    if ash:
        for _ in range(10):
            put(img, ox + rng.randint(0, 15), oy + rng.randint(0, 15), (70, 66, 62))
    for _ in range(2):
        put(img, ox + rng.randint(1, 14), oy + rng.randint(1, 14), P.MOSS)


def plate_tile(img, ox, oy, seed, worn=False):
    """Placa metalica que conduz o raio: chapa com rebites e marcas de queimado."""
    rng = random.Random(seed)
    rect(img, ox, oy, ox + T, oy + T, P.PLATE)
    for y in range(oy, oy + T):
        for x in range(ox, ox + T):
            if rng.random() < 0.15:
                put(img, x, y, shade(P.PLATE, rng.choice((0.9, 1.08))))
    hline(img, ox, ox + T, oy, P.PLATE_LIGHT)
    vline(img, ox, oy, oy + T, P.PLATE_LIGHT)
    hline(img, ox, ox + T, oy + T - 1, P.PLATE_DARK)
    vline(img, ox + T - 1, oy, oy + T, P.PLATE_DARK)
    for cx, cy in ((2, 2), (13, 2), (2, 13), (13, 13)):
        put(img, ox + cx, oy + cy, P.PLATE_LIGHT)
        put(img, ox + cx + 1, oy + cy + 1, P.PLATE_DARK)
    # trilha de cobre no meio (por onde o raio corre)
    hline(img, ox + 4, ox + 12, oy + 8, P.BRONZE_DARK)
    vline(img, ox + 8, oy + 4, oy + 12, P.BRONZE_DARK)
    put(img, ox + 8, oy + 8, P.BRONZE)
    if worn:
        for _ in range(3):
            cx, cy = ox + rng.randint(3, 12), oy + rng.randint(3, 12)
            put(img, cx, cy, (40, 40, 44))
            put(img, cx + 1, cy, (52, 52, 56))


def grate_tile(img, ox, oy, seed, glow=False):
    """Grade da fabrica: por baixo, o brilho da forja."""
    rng = random.Random(seed)
    rect(img, ox, oy, ox + T, oy + T, (28, 24, 22) if not glow else (70, 30, 16))
    for k in range(0, T, 4):
        hline(img, ox, ox + T, oy + k, P.GRATE)
        vline(img, ox + k, oy, oy + T, P.GRATE)
        hline(img, ox, ox + T, oy + k + 1, shade(P.GRATE, 0.7))
    if glow:
        for _ in range(5):
            put(img, ox + rng.randint(1, 14), oy + rng.randint(1, 14), P.MOLTEN)


def rubble_tile(img, ox, oy, seed):
    rng = random.Random(seed)
    stone_floor(img, ox, oy, seed + 300)
    for _ in range(6):
        cx, cy = ox + rng.randint(2, 13), oy + rng.randint(2, 13)
        ellipse(img, cx, cy, rng.uniform(1.0, 2.2), rng.uniform(0.8, 1.6), P.FORGE_STONE_DARK)
        put(img, int(cx) - 1, int(cy) - 1, P.FORGE_STONE_LIGHT)


def wall_top(img, ox, oy, seed):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.FORGE_WALL_TOP, [shade(P.FORGE_WALL_TOP, 1.2)], 0.25, rng)
    for k in range(0, T, 8):
        hline(img, ox, ox + T, oy + k, shade(P.FORGE_WALL_TOP, 0.8))


def stone_wall(img, ox, oy, seed):
    """Face da ruina: tijolos grandes de pedra com musgo."""
    rng = random.Random(seed)
    rect(img, ox, oy, ox + T, oy + T, P.FORGE_WALL)
    for row in range(4):
        y = oy + row * 4
        hline(img, ox, ox + T, y, P.FORGE_WALL_DARK)
        off = 0 if row % 2 == 0 else 4
        for x in range(ox + off, ox + T, 8):
            vline(img, x, y, y + 4, P.FORGE_WALL_DARK)
        for x in range(ox, ox + T):
            if rng.random() < 0.12:
                put(img, x, y + 1, shade(P.FORGE_WALL, 1.15))
    hline(img, ox, ox + T, oy, P.FORGE_STONE_LIGHT)
    hline(img, ox, ox + T, oy + T - 1, P.WALL_SHADOW)
    for _ in range(3):
        put(img, ox + rng.randint(0, 15), oy + rng.randint(1, 4), P.MOSS)


def factory_wall(img, ox, oy, seed):
    """Face da fabrica: chapas, cano e uma luz de aviso."""
    rng = random.Random(seed)
    rect(img, ox, oy, ox + T, oy + T, P.PLATE_DARK)
    vline(img, ox + 7, oy, oy + T, shade(P.PLATE_DARK, 0.7))
    hline(img, ox, ox + T, oy + 1, P.PLATE)
    for cx in (2, 12):
        for cy in (3, 12):
            put(img, ox + cx, oy + cy, P.PLATE_LIGHT)
    rect(img, ox + 10, oy, ox + 13, oy + T, P.RUST)  # cano
    vline(img, ox + 10, oy, oy + T, shade(P.RUST, 1.3))
    hline(img, ox + 9, ox + 14, oy + 6, P.BRONZE_DARK)
    if seed % 2 == 0:
        ellipse(img, ox + 4, oy + 7, 1.5, 1.5, P.MOLTEN)
    hline(img, ox, ox + T, oy + T - 1, P.WALL_SHADOW)
    for _ in range(4):
        put(img, ox + rng.randint(0, 15), oy + rng.randint(0, 15), P.RUST)


def arch_tile(img, ox, oy, seed):
    stone_wall(img, ox, oy, seed)
    ellipse(img, ox + 8, oy + 15, 5, 9, (22, 18, 18))
    hline(img, ox + 3, ox + 13, oy + 6, P.FORGE_STONE_LIGHT)


def cliff_tile(img, ox, oy, seed, lower=False):
    rng = random.Random(seed)
    if not lower:
        _noise(img, ox, oy, P.FORGE_WALL, [P.FORGE_WALL_DARK, P.ROCK_DARK], 0.3, rng)
        hline(img, ox, ox + T, oy, P.FORGE_STONE)
        hline(img, ox, ox + T, oy + 1, P.FORGE_STONE_LIGHT)
    else:
        for y in range(oy, oy + T):
            for x in range(ox, ox + T):
                depth = (y - oy) / T
                if rng.random() < depth * 0.9 and (x * 7 + y * 3 + seed) % 5 < 3:
                    continue
                put(img, x, y, rng.choice([P.ROCK_DARK, P.ROCK_DEEP, P.ROCK_DEEP]))
    for _ in range(2):  # correntes e canos pendurados sob a ilha
        x = ox + rng.randint(2, 13)
        for y in range(oy + (2 if not lower else 0), oy + rng.randint(9, 16)):
            put(img, x, y, P.IRON if (y % 3) else P.IRON_LIGHT)


def molten_tile(img, ox, oy, seed, bubbles=False, shore=False):
    """Canal de metal derretido (solido): o calor da forja."""
    rng = random.Random(seed)
    _noise(img, ox, oy, P.MOLTEN, [P.MOLTEN_DARK, P.MOLTEN_LIGHT], 0.25, rng)
    for _ in range(2):
        x, y = ox + rng.randint(1, 10), oy + rng.randint(3, 13)
        hline(img, x, x + rng.randint(2, 4), y, P.MOLTEN_LIGHT)
    if bubbles:
        for _ in range(3):
            cx, cy = ox + rng.randint(3, 12), oy + rng.randint(3, 12)
            ellipse(img, cx, cy, 1.5, 1.5, P.MOLTEN_LIGHT)
            put(img, cx, cy, P.MOLTEN_DARK)
    if shore:
        for x in range(ox, ox + T):
            h = 3 + (1 if rng.random() < 0.4 else 0)
            vline(img, x, oy, oy + h, P.FORGE_STONE_DARK)
            put(img, x, oy + h, P.ROCK_DARK)
            put(img, x, oy + h + 1, P.MOLTEN_DARK)


def forge_atlas():
    """Atlas 8x3 das Forjas Ocas."""
    img = canvas(8 * T, 3 * T)
    stone_floor(img, 0 * T, 0, 301)
    stone_floor(img, 1 * T, 0, 302)
    stone_floor(img, 2 * T, 0, 303, cracked=True)
    plate_tile(img, 3 * T, 0, 304)
    grate_tile(img, 4 * T, 0, 305)
    rubble_tile(img, 5 * T, 0, 306)
    plate_tile(img, 6 * T, 0, 307, worn=True)
    stone_floor(img, 7 * T, 0, 308, ash=True)
    wall_top(img, 0 * T, T, 311)
    stone_wall(img, 1 * T, T, 312)
    factory_wall(img, 2 * T, T, 314)
    arch_tile(img, 3 * T, T, 315)
    cliff_tile(img, 4 * T, T, 316)
    cliff_tile(img, 5 * T, T, 317, lower=True)
    # (6,1) = barreira invisivel
    molten_tile(img, 7 * T, T, 318)
    molten_tile(img, 0 * T, 2 * T, 321, bubbles=True)
    molten_tile(img, 1 * T, 2 * T, 322, shore=True)
    stone_floor(img, 2 * T, 2 * T, 323)
    grate_tile(img, 3 * T, 2 * T, 324, glow=True)
    return img


# =============================================================================
# Cenario
# =============================================================================

def chain_post():
    """Corrente enorme descendo do alto ate uma argola cravada no chao (16x48)."""
    img = canvas(16, 48)
    for i, y in enumerate(range(0, 40, 5)):
        if i % 2 == 0:
            ellipse(img, 8, y + 2.5, 3.5, 2.6, P.IRON)
            ellipse(img, 8, y + 2.5, 1.8, 1.2, (0, 0, 0, 0))
            put(img, 6, y + 1, P.IRON_LIGHT)
        else:
            rect(img, 7, y, 10, y + 5, P.IRON)
            vline(img, 7, y, y + 5, P.IRON_LIGHT)
    ellipse(img, 8, 43, 7, 3, P.IRON)
    ellipse(img, 8, 43, 4, 1.5, (30, 30, 34))
    rect(img, 3, 44, 13, 47, P.FORGE_STONE_DARK)
    return _outline(img)


def gear_pile():
    rng = random.Random(5)
    img = canvas(18, 12)
    for cx, cy, r in ((6, 7, 4.5), (12, 8, 3.5), (9, 4, 3)):
        ellipse(img, cx, cy, r, r * 0.8, P.BRONZE_DARK)
        ellipse(img, cx, cy, r - 1, r * 0.8 - 1, P.BRONZE)
        ellipse(img, cx, cy, 1.2, 1.0, P.BRONZE_DARK)
        for k in range(6):
            a = k * math.pi / 3
            put(img, int(cx + math.cos(a) * (r + 0.6)), int(cy + math.sin(a) * (r * 0.8 + 0.6)), P.BRONZE_DARK)
    put(img, 5, 5, P.BRONZE_LIGHT)
    return _outline(img)


def press():
    """Prensa / bigorna grande da fabrica (32x24, 2 celulas)."""
    img = canvas(32, 24)
    rect(img, 3, 14, 29, 23, P.IRON)
    hline(img, 3, 29, 14, P.IRON_LIGHT)
    rect(img, 6, 2, 26, 10, P.PLATE_DARK)
    hline(img, 6, 26, 2, P.PLATE)
    rect(img, 9, 10, 23, 14, P.BRONZE_DARK)
    vline(img, 5, 4, 23, P.RUST)
    vline(img, 27, 4, 23, P.RUST)
    ellipse(img, 16, 18, 3, 2, P.MOLTEN)
    return _outline(img)


def bronze_statue():
    """Estatua de bronze com o rosto do Ferreiro do Teatro (as copias de Durgan). 16x32."""
    frames = C.dwarf_frames()
    face = recolor(frames[1], P.BRONZE_DARK, P.BRONZE, P.BRONZE_LIGHT, {(30, 24, 20): P.BRONZE_DARK})
    img = canvas(24, 32)
    paste(img, face, 0, 0)
    rect(img, 4, 26, 20, 32, P.FORGE_STONE_DARK)
    hline(img, 4, 20, 26, P.FORGE_STONE_LIGHT)
    return _outline(img)


def wrench_hammer():
    """A chave-martelo eletrica de Durgan (32x12, empunhadura em x=2)."""
    img = canvas(32, 12)
    rect(img, 0, 5, 20, 8, P.BRONZE_DARK)
    hline(img, 0, 20, 5, P.BRONZE)
    rect(img, 20, 1, 27, 11, P.IRON)
    rect(img, 27, 1, 31, 4, P.IRON)   # a boca da chave
    rect(img, 27, 8, 31, 11, P.IRON)
    vline(img, 20, 1, 11, P.IRON_LIGHT)
    for k in range(4):  # raio preso no metal
        put(img, 22 + k, 4 + (k % 2) * 3, P.ELECTRIC)
    return _outline(img)


# =============================================================================
# Inimigos
# =============================================================================

def automaton_frames():
    """Autômato de Bronze (24x24): o Ferreiro, fundido em bronze.
    [martelo baixo (parado/andar), martelo erguido (golpe)]"""
    frames = C.dwarf_frames()
    eyes = {(30, 24, 20): P.MOLTEN_LIGHT}  # os olhos do Ferreiro viram brasa
    hammer_up = recolor(frames[0], P.BRONZE_DARK, P.BRONZE, P.BRONZE_LIGHT, eyes)
    hammer_down = recolor(frames[1], P.BRONZE_DARK, P.BRONZE, P.BRONZE_LIGHT, eyes)
    return [hammer_down, hammer_up]


def turret_frames():
    """Torreta de Faisca (16x24): tripe, bobina e a ponta que carrega. [parada, carregando]"""
    frames = []
    for state in range(2):
        img = canvas(16, 24)
        for x0, x1 in ((3, 7), (13, 9)):  # pernas do tripe
            for k in range(8):
                put(img, int(x0 + (x1 - x0) * k / 8), 23 - k, P.IRON)
        rect(img, 5, 10, 11, 17, P.PLATE_DARK)
        for y in range(10, 17, 2):
            hline(img, 5, 11, y, P.BRONZE)  # bobina de cobre
        rect(img, 7, 4, 9, 10, P.IRON)
        r = 2.5 if state == 0 else 3.5
        ellipse(img, 8, 4, r, r, P.ELECTRIC if state else P.PLATE_LIGHT)
        if state:
            put(img, 8, 4, (255, 255, 255))
            for k in range(4):
                a = k * math.pi / 2 + 0.4
                put(img, int(8 + math.cos(a) * 5), int(4 + math.sin(a) * 5), P.SPARK)
        frames.append(_outline(img))
    return frames


MINER_KEY = {"s": P.MINER_SKIN, "z": P.MINER_SKIN_DARK, "h": P.HAZARD, "H": shade(P.HAZARD, 0.7),
             "l": P.SPARK, "e": (24, 22, 22), "b": P.CIVIL_HAIR, "c": P.FORGE_WALL, "C": P.FORGE_WALL_DARK,
             "B": P.BOOTS}
MINER_BODY = [
    "...hhhhhh....",
    "..hhhlhhhh...",
    "..HHHHHHHH...",
    "..ssssssss...",
    "..sseesses...",
    "..zbbbbbbz...",
    ".ssbbbbbbss..",
    "sscccccccccs.",
    "s.cccCcccc.s.",
    "..cccccccc...",
    "..CccccccC...",
]
MINER_LEGS = [
    ["...cc..cc....", "...BB..BB...."],
    ["..cc....cc...", "..BB....BB..."],
    ["...cc..cc....", "...BB..BB...."],
    ["....cccc.....", "....BBBB....."],
]


def _pick(img, pose):
    """Picareta desenhada por cima: 'down' (baixa), 'up' (erguida), 'high' (bem alto), 'hit' (cravada)."""
    handle = P.WOOD
    head = P.IRON_LIGHT
    if pose == "down":
        for k in range(9):
            put(img, 17 + k // 3, 12 + k, handle)
        hline(img, 16, 23, 20, head)
    elif pose == "up":
        for k in range(9):
            put(img, 17 + k // 4, 13 - k, handle)
        hline(img, 15, 22, 4, head)
        put(img, 15, 5, head)
    elif pose == "high":
        for k in range(10):
            put(img, 14 - k // 3, 11 - k, handle)
        hline(img, 7, 16, 1, head)
        put(img, 7, 2, head)
        put(img, 16, 2, head)
    else:  # hit
        for k in range(9):
            put(img, 17 + k, 13 + k // 3, handle)
        vline(img, 23, 15, 23, head)
        put(img, 22, 22, head)


def miner_frames():
    """Minerador Oco (24x24): [parado, passo, parado, passo 2, ERGUE, ERGUE ALTO, GOLPE]."""
    frames = []
    for i, legs in enumerate(MINER_LEGS):
        frame = canvas(24, 24)
        paste(frame, from_grid(MINER_BODY + legs, MINER_KEY, outline=O), 4, 9)
        _pick(frame, "down")
        frames.append(_outline(frame))
    for pose in ("up", "high", "hit"):
        frame = canvas(24, 24)
        paste(frame, from_grid(MINER_BODY + MINER_LEGS[0], MINER_KEY, outline=O), 4, 9)
        _pick(frame, pose)
        frames.append(_outline(frame))
    return frames


def imitator_frames():
    """Imitador: o seu corpo, em bronze escuro e sem rosto (olhos de brasa)."""
    out = []
    for f in C.player_frames():
        r = recolor(f, (40, 30, 26), (98, 66, 40), (170, 116, 62))
        px = r.load()
        for y in range(r.height):
            for x in range(r.width):
                if px[x, y][3] and 7 <= y <= 9 and abs(x - 12) <= 3 and (x + y) % 3 == 0:
                    px[x, y] = (*P.MOLTEN_LIGHT, 255)
        out.append(r)
    return out


def imitator_sword():
    from pixel import add_outline as _ao
    sword = C.player_sword()
    return recolor(sword, (70, 50, 36), (140, 100, 60), (210, 160, 100))


def imitator_shield():
    import itens as IT
    return recolor(IT.escudo_sprite(), (60, 44, 32), (120, 84, 50), (190, 140, 84))


# =============================================================================
# Mini-chefes
# =============================================================================

def prototype_frames():
    """O Protótipo: o corpo do heroi em bronze, INACABADO (furos, engrenagens a mostra).
    [parado, passo, parado, passo 2, golpe] — 24x24 (o jogo amplia)."""
    out = []
    base = C.player_frames()
    for i, f in enumerate(base + [base[1]]):
        r = recolor(f, P.BRONZE_DARK, P.BRONZE, P.BRONZE_LIGHT, gaps=0.08, seed=3)
        px = r.load()
        for x, y in ((10, 8), (14, 8)):
            if px[x, y][3]:
                px[x, y] = (*P.ELECTRIC, 255)
        if i == 4:  # golpe: o braco esticado vira uma lamina de bronze
            for k in range(6):
                put(r, 16 + k, 13, P.BRONZE_LIGHT)
                put(r, 16 + k, 14, P.BRONZE_DARK)
        out.append(r)
    return out


def guardian_frames():
    """O Guardiao da Ancora (64x64): maquina presa a uma corrente que sobe ate o ceu.
    [parado, prepara (braco erguido), golpe (braco no chao), vapor (grades abertas)]"""
    frames = []
    for state in range(4):
        rng = random.Random(61)
        img = canvas(64, 64)
        # corrente subindo
        for i, y in enumerate(range(0, 20, 5)):
            if i % 2 == 0:
                ellipse(img, 32, y + 2.5, 3.5, 2.6, P.IRON)
                ellipse(img, 32, y + 2.5, 1.8, 1.2, (0, 0, 0, 0))
            else:
                rect(img, 31, y, 34, y + 5, P.IRON)
        # pernas/base
        rect(img, 14, 50, 24, 63, P.PLATE_DARK)
        rect(img, 40, 50, 50, 63, P.PLATE_DARK)
        hline(img, 12, 26, 62, P.IRON)
        hline(img, 38, 52, 62, P.IRON)
        # corpo
        rect(img, 12, 20, 52, 52, P.PLATE)
        rect(img, 12, 20, 16, 52, P.PLATE_DARK)
        rect(img, 48, 20, 52, 52, P.PLATE_LIGHT)
        hline(img, 12, 52, 20, P.PLATE_LIGHT)
        for cx in (18, 46):
            for cy in (24, 48):
                put(img, cx, cy, P.PLATE_LIGHT)
        # o nucleo (grades)
        core_open = state == 3
        rect(img, 24, 28, 40, 44, (30, 26, 26))
        if core_open:
            ellipse(img, 32, 36, 6, 6, P.MOLTEN)
            ellipse(img, 32, 36, 3, 3, P.MOLTEN_LIGHT)
            for _ in range(12):  # vapor
                put(img, rng.randint(18, 46), rng.randint(10, 26), (220, 220, 226))
        else:
            for y in range(29, 44, 3):
                hline(img, 24, 40, y, P.IRON_LIGHT)
            ellipse(img, 32, 36, 2, 2, P.MOLTEN_DARK)
        # olho/sensor
        ellipse(img, 32, 24, 3, 2, P.MOLTEN_LIGHT if state in (1, 2) else P.MOLTEN_DARK)
        # braco (pilao)
        if state == 1:
            rect(img, 52, 2, 60, 30, P.IRON)
            rect(img, 50, 0, 62, 6, P.BRONZE_DARK)
        elif state == 2:
            rect(img, 52, 30, 60, 58, P.IRON)
            rect(img, 50, 56, 63, 63, P.BRONZE_DARK)
        else:
            rect(img, 52, 24, 60, 46, P.IRON)
            rect(img, 50, 44, 62, 50, P.BRONZE_DARK)
        rect(img, 4, 26, 12, 46, P.IRON)
        for _ in range(16):  # ferrugem
            x, y = rng.randint(12, 52), rng.randint(20, 52)
            if img.getpixel((x, y))[3] > 0:
                put(img, x, y, P.RUST)
        frames.append(_outline(img))
    return frames


# =============================================================================
# Durgan Vell, O Eco de Bronze (chefe)
# =============================================================================

DURGAN_KEY = {"h": (72, 52, 42), "g": P.BRONZE, "l": P.ELECTRIC, "s": P.DWARF_SKIN, "z": P.DWARF_SKIN_DARK,
              "e": (30, 24, 20), "P": P.BRONZE, "Q": P.BRONZE_DARK, "b": P.DURGAN_BEARD, "B": P.DURGAN_BEARD_DARK,
              "a": P.APRON, "A": shade(P.APRON, 0.8), "r": P.RUST, "p": (60, 56, 52), "k": P.BOOTS}
DURGAN_BODY = [
    ".....hhhhhhh......",
    "....hhhhhhhhh.....",
    "...hgllghhgllgh...",
    "...hssssssssssh...",
    "...ssessssssess...",
    "...zsssszzsssssz..",
    "..PPbbbbbbbbbbPP..",
    ".PPQbbbbBbbbbbQPP.",
    ".PQsbbbbbbbBbbsQP.",
    ".sssbbBbbbbbbbsss.",
    ".ss.aabbbbbbaa.ss.",
    ".ss.aaabbBbaaa.ss.",
    ".zz.aaaabbaaaa.zz.",
    "....rrrrrrrrrr....",
    "....aaaaaaaaaa....",
    "....aAaaaaaaAa....",
]
DURGAN_LEGS = [
    [".....pp....pp.....", ".....pp....pp.....", "....kkk....kkk...."],
    ["....pp......pp....", "...pp........pp...", "...kkk.......kkk.."],
    [".....pp....pp.....", ".....pp....pp.....", "....kkk....kkk...."],
    ["......pp..pp......", "......pp..pp......", ".....kkk..kkk....."],
]
HEAD_ROWS = 6  # o espelho cobre o corpo; o rosto (e a cobica) continuam dele


def _durgan_frame(legs, mirror=False, pose=None):
    body = list(DURGAN_BODY)
    if pose == "bebe":
        body[9] = ".sssbbBbbbbbbbssl."
        body[8] = ".PQsbbbbbbbBbbsQl."
    sprite = from_grid(body + legs, DURGAN_KEY, outline=O)
    frame = canvas(32, 32)
    ox, oy = (32 - sprite.width) // 2, 31 - sprite.height
    paste(frame, sprite, ox, oy)
    if mirror:
        px = frame.load()
        for y in range(oy + 1 + HEAD_ROWS, frame.height):
            for x in range(frame.width):
                r, g, b, a = px[x, y]
                if a == 0 or (r, g, b) == O[:3]:
                    continue
                lum = (r * 0.3 + g * 0.59 + b * 0.11) / 255
                px[x, y] = (*_ramp(min(1.0, 0.25 + lum), P.MIRROR_DARK, P.MIRROR, P.MIRROR_LIGHT)[:3], 255)
        for k in range(4):  # reflexo diagonal no peito
            put(frame, ox + 6 + k, oy + 9 + k, P.MIRROR_LIGHT)
            put(frame, ox + 7 + k, oy + 9 + k, P.MIRROR_LIGHT)
    if pose == "guarda":
        rect(frame, 22, 10, 30, 26, P.MIRROR)
        vline(frame, 22, 10, 26, P.MIRROR_LIGHT)
        vline(frame, 29, 10, 26, P.MIRROR_DARK)
        for k in range(4):
            put(frame, 24 + k, 12 + k * 2, P.MIRROR_LIGHT)
    return add_outline(frame, O)


def durgan_frames():
    """[parado, passo, parado, passo 2, ESPELHO parado, passo, parado, passo 2, BEBE, GUARDA]"""
    frames = [_durgan_frame(l) for l in DURGAN_LEGS]
    frames += [_durgan_frame(l, mirror=True) for l in DURGAN_LEGS]
    frames.append(_durgan_frame(DURGAN_LEGS[0], mirror=True, pose="bebe"))
    frames.append(_durgan_frame(DURGAN_LEGS[0], mirror=True, pose="guarda"))
    return frames
