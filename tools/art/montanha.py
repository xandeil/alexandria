"""Montanha Carbonizada (Orgulho — Rachel Azheryon Caelis): tiles, cenario, inimigos e chefes.

Biblia: "Florestas queimadas, ossos de dragoes, cavernas fundas e cinza no ar.
E o paraiso dos piromantes." Mapa do mundo, ilha 3: o vulcao com lava escorrendo.
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


# =============================================================================
# Tiles (atlas 8x3) — o layout e espelhado em THEMES["montanha"] (level.gd)
# =============================================================================

def ash_tile(img, ox, oy, seed, embers=False):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.ASH, [P.ASH_DARK, P.ASH_LIGHT], 0.3, rng)
    for _ in range(3):
        x, y = ox + rng.randint(1, 13), oy + rng.randint(1, 13)
        put(img, x, y, P.CHAR)
        put(img, x + 1, y, P.ASH_DARK)
    if embers:
        for _ in range(4):
            put(img, ox + rng.randint(0, 15), oy + rng.randint(0, 15), rng.choice([P.EMBER, P.EMBER_DARK]))


def burnt_grass(img, ox, oy, seed):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.ASH_DARK, [P.CHAR, P.ASH], 0.3, rng)
    for _ in range(7):  # tocos de mato queimado
        x, y = ox + rng.randint(1, 14), oy + rng.randint(3, 14)
        vline(img, x, y - rng.randint(1, 3), y + 1, P.CHAR)
        if rng.random() < 0.3:
            put(img, x, y - 3, P.EMBER_DARK)


def basalt_tile(img, ox, oy, seed):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.BASALT, [P.BASALT_DARK, P.BASALT_LIGHT], 0.2, rng)
    # colunas hexagonais vistas de cima (contorno escuro)
    for cx, cy in ((4, 4), (12, 4), (8, 11), (0, 11), (16, 11)):
        for k in range(6):
            a0 = k * math.pi / 3
            a1 = (k + 1) * math.pi / 3
            for s in range(5):
                t = s / 4
                x = cx + math.cos(a0 + (a1 - a0) * t) * 4
                y = cy + math.sin(a0 + (a1 - a0) * t) * 3.5
                put(img, ox + int(x), oy + int(y), P.BASALT_DARK)


def rubble_tile(img, ox, oy, seed):
    rng = random.Random(seed)
    ash_tile(img, ox, oy, seed + 500)
    for _ in range(6):
        cx, cy = ox + rng.randint(2, 13), oy + rng.randint(2, 13)
        ellipse(img, cx, cy, rng.uniform(1.0, 2.3), rng.uniform(0.8, 1.7), P.BASALT)
        put(img, int(cx) - 1, int(cy) - 1, P.BASALT_LIGHT)


def lava_crack_tile(img, ox, oy, seed):
    """Chao rachado com brasa por baixo (perto do vulcao)."""
    rng = random.Random(seed)
    basalt_tile(img, ox, oy, seed + 600)
    x, y = ox + rng.randint(0, 5), oy + rng.randint(2, 6)
    for _ in range(20):
        put(img, x, y, P.EMBER)
        put(img, x, y + 1, P.EMBER_DARK)
        x += 1
        y += rng.choice((-1, 0, 1))
        if not (ox <= x < ox + T and oy <= y < oy + T - 1):
            break


def bones_tile(img, ox, oy, seed):
    rng = random.Random(seed)
    ash_tile(img, ox, oy, seed + 700)
    for _ in range(3):
        x, y = ox + rng.randint(1, 10), oy + rng.randint(2, 13)
        length = rng.randint(3, 5)
        hline(img, x, x + length, y, P.BONE)
        put(img, x - 1, y - 1, P.BONE)
        put(img, x - 1, y + 1, P.BONE)
        put(img, x + length, y - 1, P.BONE_DARK)
        put(img, x + length, y + 1, P.BONE_DARK)


def wall_top(img, ox, oy, seed):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.BASALT_DARK, [P.CHAR, P.BASALT], 0.3, rng)


def rock_wall(img, ox, oy, seed, veins=False):
    """Face de rocha escura; a versao com veias tem brasa correndo pela pedra."""
    rng = random.Random(seed)
    _noise(img, ox, oy, P.BASALT, [P.BASALT_DARK, P.BASALT_LIGHT], 0.25, rng)
    for k in range(2):  # fendas (tortas, de tamanhos diferentes: rocha, não grade)
        x, y = ox + 3 + k * 7 + rng.randint(0, 3), oy + rng.randint(1, 6)
        for _ in range(rng.randint(4, 8)):
            put(img, x, y, P.BASALT_DARK)
            y += 1
            x += rng.choice((-1, 0, 0, 1))
            x = max(ox, min(ox + T - 1, x))
    hline(img, ox, ox + T, oy, P.BASALT_LIGHT)
    hline(img, ox, ox + T, oy + T - 1, P.WALL_SHADOW)
    if veins:
        x, y = ox + rng.randint(2, 6), oy + 1
        for _ in range(9):
            put(img, x, y, P.EMBER_DARK if y % 2 else P.EMBER)
            y += 1
            x += rng.choice((-1, 0, 0, 1))
            if y >= oy + T - 1:
                break


def arch_tile(img, ox, oy, seed):
    rock_wall(img, ox, oy, seed)
    ellipse(img, ox + 8, oy + 15, 5.5, 9, (20, 14, 14))


def cliff_tile(img, ox, oy, seed, lower=False):
    rng = random.Random(seed)
    if not lower:
        _noise(img, ox, oy, P.BASALT, [P.BASALT_DARK, P.CHAR], 0.3, rng)
        hline(img, ox, ox + T, oy, P.ASH)
        hline(img, ox, ox + T, oy + 1, P.ASH_LIGHT)
    else:
        for y in range(oy, oy + T):
            for x in range(ox, ox + T):
                depth = (y - oy) / T
                if rng.random() < depth * 0.9 and (x * 7 + y * 3 + seed) % 5 < 3:
                    continue
                put(img, x, y, rng.choice([P.BASALT_DARK, P.CHAR, P.CHAR]))
    if not lower:  # um fio curto de brasa (o tile se repete: um detalhe só, apagado)
        x = ox + 5 + rng.randint(0, 6)
        for y in range(oy + 3, oy + 3 + rng.randint(3, 6)):
            put(img, x, y, P.EMBER_DARK)
            x += rng.choice((0, 0, 1))


def lava_tile(img, ox, oy, seed, bubbles=False, shore=False):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.MOLTEN, [P.MOLTEN_DARK, P.MOLTEN_LIGHT], 0.3, rng)
    for _ in range(2):  # crosta escura boiando
        cx, cy = ox + rng.randint(2, 13), oy + rng.randint(2, 13)
        ellipse(img, cx, cy, rng.uniform(1.5, 2.8), rng.uniform(1.0, 1.8), P.MOLTEN_DARK)
    if bubbles:
        for _ in range(3):
            cx, cy = ox + rng.randint(3, 12), oy + rng.randint(3, 12)
            ellipse(img, cx, cy, 1.5, 1.5, P.MOLTEN_LIGHT)
    if shore:
        for x in range(ox, ox + T):
            h = 3 + (1 if rng.random() < 0.4 else 0)
            vline(img, x, oy, oy + h, P.BASALT)
            put(img, x, oy + h, P.CHAR)
            put(img, x, oy + h + 1, P.MOLTEN_DARK)


def mountain_atlas():
    img = canvas(8 * T, 3 * T)
    ash_tile(img, 0 * T, 0, 401)
    ash_tile(img, 1 * T, 0, 402)
    ash_tile(img, 2 * T, 0, 403, embers=True)
    basalt_tile(img, 3 * T, 0, 404)
    burnt_grass(img, 4 * T, 0, 405)
    rubble_tile(img, 5 * T, 0, 406)
    lava_crack_tile(img, 6 * T, 0, 407)
    bones_tile(img, 7 * T, 0, 408)
    wall_top(img, 0 * T, T, 411)
    rock_wall(img, 1 * T, T, 412)
    rock_wall(img, 2 * T, T, 413, veins=True)
    arch_tile(img, 3 * T, T, 414)
    cliff_tile(img, 4 * T, T, 415)
    cliff_tile(img, 5 * T, T, 416, lower=True)
    # (6,1) = barreira invisivel
    lava_tile(img, 7 * T, T, 418)
    lava_tile(img, 0 * T, 2 * T, 421, bubbles=True)
    lava_tile(img, 1 * T, 2 * T, 422, shore=True)
    basalt_tile(img, 2 * T, 2 * T, 423)
    burnt_grass(img, 3 * T, 2 * T, 424)
    return img


# =============================================================================
# Cenario
# =============================================================================

def burnt_tree():
    rng = random.Random(9)
    img = canvas(28, 40)
    rect(img, 12, 16, 16, 39, P.CHAR)
    vline(img, 15, 16, 39, P.ASH_DARK)
    for (x0, y0, x1, y1) in ((14, 20, 4, 8), (14, 24, 24, 10), (14, 16, 10, 2), (14, 18, 20, 4), (14, 28, 22, 22)):
        steps = 12
        for i in range(steps + 1):
            t = i / steps
            put(img, int(x0 + (x1 - x0) * t), int(y0 + (y1 - y0) * t), P.CHAR)
            put(img, int(x0 + (x1 - x0) * t) + 1, int(y0 + (y1 - y0) * t), P.CHAR)
    for _ in range(5):
        x, y = rng.randint(4, 24), rng.randint(4, 36)
        if img.getpixel((x, y))[3] > 0:
            put(img, x, y, P.EMBER_DARK)
    return _outline(img)


def ribcage():
    img = canvas(28, 18)
    hline(img, 2, 26, 12, P.BONE)  # espinha
    hline(img, 2, 26, 13, P.BONE_DARK)
    for k in range(5):
        x = 5 + k * 5
        for i in range(9):
            a = math.pi * (0.1 + i / 10.0)
            put(img, int(x + math.cos(a) * 3), int(12 - math.sin(a) * (8 - k * 0.6)), P.BONE)
    return _outline(img)


def dragon_skull():
    """Cranio de dragao enorme (32x22, ocupa 2 celulas)."""
    img = canvas(32, 22)
    ellipse(img, 12, 12, 10, 8, P.BONE)
    rect(img, 18, 10, 31, 17, P.BONE)
    hline(img, 18, 31, 17, P.BONE_DARK)
    for x in range(20, 31, 3):  # dentes
        vline(img, x, 17, 20, P.BONE)
    ellipse(img, 10, 10, 3, 2.5, P.CHAR)  # orbita
    ellipse(img, 26, 12, 1.5, 1, P.CHAR)  # narina
    for k in range(6):  # chifre
        put(img, 4 - k // 2, 6 - k, P.BONE_DARK)
        put(img, 5 - k // 2, 6 - k, P.BONE)
    return _outline(img)


def obsidian_spike():
    """Espeto de obsidiana com brasa no pe (16x26)."""
    img = canvas(16, 26)
    for y in range(2, 24):
        w = (y - 2) / 22 * 5 + 0.5
        hline(img, int(8 - w), int(8 + w) + 1, y, P.BASALT_DARK)
        put(img, int(8 - w) + 1, y, P.BASALT_LIGHT)
    ellipse(img, 8, 23, 6, 2, P.EMBER_DARK)
    hline(img, 4, 12, 23, P.EMBER)
    return _outline(img)


def rock_cover_frames():
    """Pilar de rocha (cobertura): segura o fogo de Rachel ate o rugido derrubar. 28x24 x3."""
    frames = []
    for state in range(3):
        rng = random.Random(77)
        img = canvas(28, 24)
        if state < 2:
            ellipse(img, 14, 14, 11, 9, P.BASALT_DARK)
            ellipse(img, 13, 12, 10, 8, P.BASALT)
            ellipse(img, 11, 9, 5, 3, P.BASALT_LIGHT)
            if state == 1:
                x, y = 9, 4
                for _ in range(16):
                    put(img, x, y, P.CHAR)
                    x += rng.choice((0, 1))
                    y += 1
        else:
            for _ in range(8):
                cx, cy = rng.randint(4, 24), rng.randint(15, 21)
                ellipse(img, cx, cy, rng.uniform(1.5, 3.0), rng.uniform(1.0, 2.0), P.BASALT)
                put(img, cx - 1, cy - 1, P.BASALT_LIGHT)
        frames.append(_outline(img))
    out = canvas(28 * 3, 24)
    for i, f in enumerate(frames):
        paste(out, f, i * 28, 0)
    return out


def scale_memorial():
    """A escama de Rachel que fica no ninho (memorial). 20x16."""
    img = canvas(20, 16)
    for y in range(2, 15):
        w = 8 * math.sin(math.pi * (y - 1) / 14)
        hline(img, int(10 - w), int(10 + w) + 1, y, P.RACHEL)
    ellipse(img, 8, 6, 3, 2, P.RACHEL_LIGHT)
    vline(img, 10, 3, 14, P.RACHEL_DARK)
    return _outline(img)


def fireball():
    img = canvas(10, 10)
    ellipse(img, 5, 5, 4, 4, P.EMBER_DARK)
    ellipse(img, 4.5, 4.5, 3, 3, P.EMBER)
    ellipse(img, 4, 4, 1.5, 1.5, P.MOLTEN_LIGHT)
    return img


# =============================================================================
# Inimigos
# =============================================================================

SERVANT_KEY = {"d": P.SERVANT, "D": P.SERVANT_DARK, "l": P.SERVANT_LIGHT, "y": P.DRAGON_BELLY, "h": P.HORN,
               "e": P.DRAGON_EYE, "k": (30, 20, 30), "a": P.SCALE_ARMOR, "A": P.SCALE_ARMOR_LIGHT, "B": P.BOOTS}
SERVANT_BODY = [
    "..h....h......",
    "..hh..hh......",
    "...hddh.......",
    "..dllldd......",
    ".dllllllddd...",
    ".dllekllldd...",
    ".ddllllllll...",
    "..ddllyyyy....",
    "..aaAAAAaa....",
    ".aaaAAAAaaa...",
    "dd.aaaaaa.dd..",
    "dd.aaaaaa.dd..",
    "...aaaaaa.....",
]
SERVANT_LEGS = [
    ["...dd..dd.....", "...BB..BB....."],
    ["..dd....dd....", "..BB....BB...."],
    ["...dd..dd.....", "...BB..BB....."],
    ["....dddd......", "....BBBB......"],
]


def servant_frames():
    """Dragonoide Atirador (24x24) com o mosquete de fogo."""
    frames = []
    for legs in SERVANT_LEGS:
        frame = canvas(24, 24)
        paste(frame, from_grid(SERVANT_BODY + legs, SERVANT_KEY, outline=O), 4, 6)
        # mosquete de bronze
        hline(frame, 12, 23, 15, P.BRONZE_DARK)
        hline(frame, 12, 22, 14, P.BRONZE)
        put(frame, 23, 14, P.EMBER)
        frames.append(_outline(frame))
    return frames


def beast_frames():
    """Dragao Bestial (32x24): quadrupede tipo dinossauro. [parado, passo, parado, passo 2, INVESTIDA, MORDE]"""
    frames = []
    for state in range(6):
        img = canvas(32, 24)
        lean = 3 if state == 4 else 0
        # rabo
        for k in range(10):
            put(img, 2 + k, 12 - k // 3, P.BEAST_DARK)
            put(img, 2 + k, 13 - k // 3, P.BEAST)
        # corpo
        ellipse(img, 15, 13, 8, 5, P.BEAST)
        ellipse(img, 15, 15, 6, 2.5, P.BEAST_LIGHT)
        for x in range(10, 21, 3):  # placas nas costas
            put(img, x, 7, P.SERVANT_DARK)
            put(img, x, 8, P.SERVANT)
        # pernas
        step = (1 if state in (1,) else -1 if state == 3 else 0)
        for lx, off in ((10, step), (19, -step)):
            rect(img, lx, 16, lx + 3, 22, P.BEAST_DARK)
            hline(img, lx - 1 + off, lx + 4 + off, 22, P.CHAR)
        # pescoco e cabeca
        hx = 24 + lean
        hy = 10 + (2 if state == 4 else 0)
        rect(img, 20, hy - 1, hx, hy + 3, P.BEAST)
        ellipse(img, hx + 2, hy, 4, 3, P.BEAST)
        put(img, hx + 2, hy - 2, P.EMBER)  # olho
        if state == 5:  # boca aberta
            rect(img, hx + 2, hy + 1, hx + 7, hy + 3, P.CHAR)
            for k in range(0, 5, 2):
                put(img, hx + 2 + k, hy + 1, P.BONE)
        else:
            hline(img, hx + 1, hx + 6, hy + 2, P.BEAST_DARK)
        frames.append(_outline(img))
    return frames


def wyvern_frames():
    """Dragao Alado Menor (32x24): [voa (asa alta), voa (asa baixa) ... mergulho, no chao]"""
    frames = []
    for state in range(4):
        img = canvas(32, 24)
        # corpo
        ellipse(img, 16, 13, 6, 3.5, P.RACHEL_DARK)
        ellipse(img, 16, 14, 4, 2, P.RACHEL_BELLY)
        # cabeca e rabo
        ellipse(img, 24, 11, 3, 2.2, P.RACHEL_DARK)
        put(img, 25, 10, P.EMBER)
        for k in range(8):
            put(img, 9 - k, 14 + k // 3, P.RACHEL_DARK)
        # asas
        if state == 0:
            for k in range(9):
                hline(img, 12 - k // 2, 20 + k // 3, 10 - k, P.RACHEL_WING)
        elif state == 1:
            for k in range(6):
                hline(img, 10 + k // 2, 22 - k // 2, 14 + k, P.RACHEL_WING)
        elif state == 2:  # mergulho: asas recolhidas
            for k in range(4):
                hline(img, 13, 19, 10 + k, P.RACHEL_WING)
        else:  # no chao: asas dobradas, de pe
            for k in range(5):
                hline(img, 12, 18, 9 + k, P.RACHEL_WING)
            vline(img, 14, 16, 22, P.RACHEL_DARK)
            vline(img, 18, 16, 22, P.RACHEL_DARK)
        frames.append(_outline(img))
    return frames


def ember_frames():
    """Brasa Viva (16x16): uma chama com olhos. 3 quadros."""
    frames = []
    for state in range(3):
        img = canvas(16, 16)
        sway = (-1, 0, 1)[state]
        for y in range(3, 15):
            w = (y - 3) / 11 * 4.5 + 0.5
            cx = 8 + sway * (14 - y) / 11
            hline(img, int(cx - w), int(cx + w) + 1, y, P.EMBER_DARK if y > 11 else P.EMBER)
        ellipse(img, 8, 11, 2.5, 2.5, P.MOLTEN_LIGHT)
        put(img, 7, 10, P.CHAR)
        put(img, 9, 10, P.CHAR)
        frames.append(_outline(img))
    return frames


# =============================================================================
# Mini-chefes
# =============================================================================

def captain_frames():
    """O Capitao Dragonoide (32x32): armadura de escamas, escudo grande OU lanca-chamas.
    [escudo, escudo anda 1, escudo anda 2, troca, chamas]"""
    frames = []
    for state in range(5):
        img = canvas(32, 32)
        body = from_grid(SERVANT_BODY + SERVANT_LEGS[0 if state != 2 else 1], SERVANT_KEY, outline=O)
        big = body.resize((body.width * 3 // 2, body.height * 3 // 2))
        paste(img, big, 3, 31 - big.height)
        # capa vermelha de oficial
        rect(img, 4, 14, 8, 28, P.SARGE_RED)
        if state in (0, 1, 2):  # escudo de escamas a frente
            ellipse(img, 24, 18, 6, 10, P.SCALE_ARMOR)
            ellipse(img, 24, 18, 4.5, 8, P.SCALE_ARMOR_LIGHT)
            for y in range(10, 27, 3):
                hline(img, 21, 28, y, P.SCALE_ARMOR)
            put(img, 24, 18, P.GOLD)
        elif state == 3:  # trocando (exposto)
            rect(img, 18, 18, 26, 21, P.BRONZE_DARK)
        else:  # lanca-chamas
            rect(img, 18, 16, 30, 20, P.IRON)
            hline(img, 18, 30, 16, P.IRON_LIGHT)
            rect(img, 14, 12, 19, 22, P.BRONZE_DARK)  # tanque
            put(img, 30, 17, P.EMBER)
            put(img, 31, 18, P.MOLTEN_LIGHT)
        frames.append(_outline(img))
    return frames


def matriarch_frames():
    """A Matriarca Bestial (64x48): o maior Dragao Bestial. [parada, passo, ERGUIDA (pisoteio), INVESTIDA, MORDE]"""
    base = beast_frames()
    pick = [0, 1, 0, 4, 5]
    out = []
    for i, idx in enumerate(pick):
        f = base[idx].resize((64, 48))
        frame = canvas(64, 48)
        if i == 2:  # erguida nas patas de tras
            f = f.rotate(18, center=(20, 44))
        paste(frame, f, 0, 0)
        out.append(frame)
    return out


# =============================================================================
# Rachel Azheryon Caelis, O Orgulho do Ceu (chefe)
# =============================================================================

def _rachel(state):
    """96x72, de lado (olhando para a direita).
    0 dorme (enrolada), 1 parada, 2 passo, 3 prepara o fogo (cabeca para tras),
    4 fogo (boca aberta), 5 cauda (girando), 6 ruge (cabeca para cima, asas abertas), 7 garra."""
    rng = random.Random(101)
    img = canvas(96, 72)
    if state == 0:
        ellipse(img, 48, 52, 34, 14, P.RACHEL_DARK)
        ellipse(img, 46, 48, 30, 12, P.RACHEL)
        for k in range(20):  # rabo enrolado em volta
            a = math.pi * (0.2 + k / 14.0)
            ellipse(img, 48 + math.cos(a) * 34, 54 + math.sin(a) * 12, 4, 3, P.RACHEL_DARK)
        ellipse(img, 70, 46, 9, 6, P.RACHEL)  # cabeca deitada
        hline(img, 66, 72, 46, P.RACHEL_DARK)  # olho fechado
        for k in range(6):
            put(img, 64 - k, 40 - k, P.RACHEL_HORN)
        for x in range(26, 64, 5):  # espinhos nas costas
            put(img, x, 36, P.RACHEL_HORN)
            put(img, x, 37, P.RACHEL_HORN)
        return _outline(img)
    # asas
    if state == 6:
        for k in range(26):
            hline(img, 30 - k // 2, 46 + k // 3, 34 - k, P.RACHEL_WING)
        for k in range(26):
            hline(img, 44, 64 + k // 2, 34 - k, shade(P.RACHEL_WING, 0.8))
    else:
        for k in range(14):
            hline(img, 26 + k, 52 - k // 3, 30 - k // 2 + 8, P.RACHEL_WING)
    # rabo
    tail_up = state == 5
    for k in range(26):
        x = 22 - k
        y = 46 + (int(math.sin(k * 0.3) * 4) if not tail_up else -k // 2)
        ellipse(img, x, y, 3.5 - k * 0.1, 3 - k * 0.08, P.RACHEL_DARK)
    # corpo
    ellipse(img, 40, 46, 22, 13, P.RACHEL_DARK)
    ellipse(img, 40, 44, 20, 11, P.RACHEL)
    ellipse(img, 42, 52, 15, 5, P.RACHEL_BELLY)
    for x in range(24, 56, 5):
        put(img, x, 33, P.RACHEL_HORN)
        put(img, x, 34, P.RACHEL_HORN)
    # pernas
    step = 2 if state == 2 else 0
    for lx, off in ((28, step), (48, -step)):
        rect(img, lx, 54, lx + 7, 69, P.RACHEL_DARK)
        hline(img, lx - 2 + off, lx + 9 + off, 69, P.RACHEL_HORN)
    if state == 7:  # garra erguida
        rect(img, 56, 40, 62, 52, P.RACHEL_DARK)
        for k in range(3):
            vline(img, 58 + k * 2, 36, 41, P.RACHEL_HORN)
    # pescoco e cabeca
    head = {1: (70, 30), 2: (70, 30), 3: (62, 22), 4: (74, 32), 5: (66, 32), 6: (66, 14), 7: (72, 30)}[state]
    hx, hy = head
    for k in range(12):
        t = k / 11
        ellipse(img, 54 + (hx - 54) * t, 40 + (hy - 40) * t, 5.5 - t, 5 - t, P.RACHEL)
    ellipse(img, hx + 4, hy, 9, 6, P.RACHEL)
    ellipse(img, hx + 6, hy + 2, 6, 3, P.RACHEL_LIGHT)
    for k in range(7):  # chifres
        put(img, hx - 2 - k, hy - 4 - k // 2, P.RACHEL_HORN)
        put(img, hx - 2 - k, hy - 3 - k // 2, P.RACHEL_HORN)
    put(img, hx + 5, hy - 2, P.DRAGON_EYE)
    put(img, hx + 6, hy - 2, P.DRAGON_EYE)
    if state in (4, 6):  # boca aberta
        rect(img, hx + 6, hy + 2, hx + 14, hy + 6, P.CHAR)
        for k in range(0, 8, 2):
            put(img, hx + 6 + k, hy + 2, P.BONE)
        if state == 4:
            ellipse(img, hx + 12, hy + 4, 3, 2, P.MOLTEN_LIGHT)
    else:
        hline(img, hx + 6, hx + 13, hy + 4, P.RACHEL_DARK)
    for _ in range(30):  # escamas
        x, y = rng.randint(22, 60), rng.randint(36, 54)
        if img.getpixel((x, y))[3] > 0:
            put(img, x, y, P.RACHEL_LIGHT)
    return _outline(img)


def rachel_frames():
    return [_rachel(s) for s in range(8)]
