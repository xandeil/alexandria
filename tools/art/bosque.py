"""Bosque do Sono Eterno (Preguica — Nyssa): tiles, cenario, inimigos e mini-chefes.

Biblia: "Floresta verde demais, lagos parados, cachoeiras que caem em camera
lenta. Tudo dorme; quase nada ataca se o jogador nao fizer barulho."
"No bosque, soldados dormem em pe e animais estao parados no meio do salto."
Todos os personagens olham para a DIREITA (o jogo espelha).
"""
from __future__ import annotations

import math
import random

import palette as P
from pixel import canvas, from_grid, paste, put, rect, hline, vline, ellipse, shade, mix

O = P.OUTLINE
T = 16


def _noise(img, x0, y0, base, alts, chance, rng, w=T, h=T):
    for y in range(y0, y0 + h):
        for x in range(x0, x0 + w):
            put(img, x, y, rng.choice(alts) if rng.random() < chance else base)


def _frames(body, legs_list, key, size=(24, 24)):
    frames = []
    for legs in legs_list:
        sprite = from_grid(body + legs, key, outline=O)
        frame = canvas(*size)
        paste(frame, sprite, (size[0] - sprite.width) // 2, size[1] - 1 - sprite.height)
        frames.append(frame)
    return frames


# =============================================================================
# Tiles (atlas 8x3) — o layout e espelhado em THEMES["bosque"] (level.gd)
# =============================================================================

def grass_tile(img, ox, oy, seed, flowers=False, pollen=False, dark=False):
    rng = random.Random(seed)
    base = P.FOREST_SHADE if dark else P.FOREST_GRASS
    alts = [P.FOREST_GRASS_DARK, P.FOREST_GRASS_LIGHT] if not dark else [P.FOREST_GRASS_DARK, P.CANOPY_DARK]
    _noise(img, ox, oy, base, alts, 0.3, rng)
    for _ in range(5):  # tufos
        x, y = ox + rng.randint(1, 14), oy + rng.randint(2, 14)
        put(img, x, y, P.FOREST_GRASS_LIGHT if not dark else P.FOREST_GRASS)
        put(img, x, y - 1, P.FOREST_GRASS_LIGHT if not dark else P.FOREST_GRASS)
    if flowers:
        for _ in range(4):
            x, y = ox + rng.randint(1, 14), oy + rng.randint(1, 14)
            c = rng.choice([P.PETAL_LIGHT, P.POLLEN_LIGHT, (230, 230, 240)])
            put(img, x, y, c)
            put(img, x + 1, y, shade(c, 0.85))
    if pollen:
        for _ in range(14):
            put(img, ox + rng.randint(0, 15), oy + rng.randint(0, 15), rng.choice([P.POLLEN, P.POLLEN_LIGHT]))


def path_tile(img, ox, oy, seed):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.FOREST_PATH, [P.FOREST_PATH_DARK, shade(P.FOREST_PATH, 1.1)], 0.3, rng)
    for _ in range(3):
        x, y = ox + rng.randint(1, 13), oy + rng.randint(1, 13)
        put(img, x, y, P.MOSS_STONE)
        put(img, x + 1, y, shade(P.MOSS_STONE, 0.8))


def moss_tile(img, ox, oy, seed):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.MOSS, [P.MOSS_LIGHT, P.MOSS_STONE, P.FOREST_GRASS_DARK], 0.35, rng)


def bridge_tile(img, ox, oy, seed):
    rng = random.Random(seed)
    for y in range(oy, oy + T):
        plank = (y - oy) // 4
        c = P.BARK_LIGHT if plank % 2 == 0 else P.BARK
        hline(img, ox, ox + T, y, c if rng.random() > 0.08 else P.BARK_DARK)
    for k in range(4):
        hline(img, ox, ox + T, oy + k * 4 + 3, P.BARK_DARK)
    for y in (oy + 1, oy + 9):
        put(img, ox + 2, y, P.IRON)
        put(img, ox + 13, y, P.IRON)


def slab_tile(img, ox, oy, seed):
    """Laje de ruina coberta de musgo (as ruinas de pedra do mapa)."""
    rng = random.Random(seed)
    _noise(img, ox, oy, P.MOSS_STONE, [shade(P.MOSS_STONE, 0.88), P.MOSS], 0.25, rng)
    hline(img, ox, ox + T, oy, shade(P.MOSS_STONE, 0.65))
    vline(img, ox, oy, oy + T, shade(P.MOSS_STONE, 0.65))
    for _ in range(6):
        put(img, ox + rng.randint(1, 14), oy + rng.randint(1, 14), P.MOSS_LIGHT)


def canopy_tile(img, ox, oy, seed):
    """Topo da mata fechada: copas vistas de cima."""
    rng = random.Random(seed)
    _noise(img, ox, oy, P.CANOPY, [P.CANOPY_DARK], 0.3, rng)
    for _ in range(4):
        cx, cy = ox + rng.randint(2, 13), oy + rng.randint(2, 13)
        for dy in range(-2, 3):
            for dx in range(-3, 4):
                if dx * dx / 9 + dy * dy / 4 <= 1:
                    put(img, cx + dx, cy + dy, P.CANOPY_LIGHT if dy < 0 else P.CANOPY)


def trunks_tile(img, ox, oy, seed, gap=False):
    """Face da mata: troncos escuros entre as folhas."""
    rng = random.Random(seed)
    _noise(img, ox, oy, P.CANOPY_DARK, [shade(P.CANOPY_DARK, 0.8)], 0.3, rng)
    hline(img, ox, ox + T, oy, P.CANOPY)
    hline(img, ox, ox + T, oy + 1, P.CANOPY_LIGHT)
    xs = [ox + 2 + (seed % 3), ox + 9 + (seed % 2)]
    for x in xs:
        if gap and x > ox + 6:
            continue
        rect(img, x, oy + 3, x + 4, oy + T, P.BARK)
        vline(img, x, oy + 3, oy + T, P.BARK_DARK)
        vline(img, x + 3, oy + 3, oy + T, P.BARK_LIGHT)
    hline(img, ox, ox + T, oy + T - 1, P.WALL_SHADOW)
    if gap:
        rect(img, ox + 8, oy + 5, ox + 15, oy + T, (14, 24, 18))


def cliff_tile(img, ox, oy, seed, lower=False):
    rng = random.Random(seed)
    if not lower:
        _noise(img, ox, oy, P.ROCK, [P.ROCK_DARK, P.MOSS_STONE], 0.3, rng)
        hline(img, ox, ox + T, oy, P.FOREST_GRASS)
        hline(img, ox, ox + T, oy + 1, P.FOREST_GRASS_LIGHT)
        for x in range(ox, ox + T):
            if rng.random() < 0.6:
                put(img, x, oy + 2, P.FOREST_GRASS)
            if rng.random() < 0.25:
                vline(img, x, oy + 3, oy + rng.randint(5, 9), P.MOSS)
    else:
        for y in range(oy, oy + T):
            for x in range(ox, ox + T):
                depth = (y - oy) / T
                if rng.random() < depth * 0.9 and (x * 7 + y * 3 + seed) % 5 < 3:
                    continue
                put(img, x, y, rng.choice([P.ROCK_DARK, P.ROCK_DEEP, P.ROCK_DEEP]))
    for _ in range(3):  # raizes e cipos pendurados
        x = ox + rng.randint(1, 14)
        for y in range(oy + (3 if not lower else 0), oy + rng.randint(8, 15)):
            put(img, x, y, P.ROOT if rng.random() < 0.5 else P.MOSS)


def water_tile(img, ox, oy, seed, lilies=False, shore=False):
    """Lago parado: quase sem reflexo — a agua tambem dorme."""
    rng = random.Random(seed)
    _noise(img, ox, oy, P.WATER, [P.WATER_DARK], 0.18, rng)
    for _ in range(2):
        x, y = ox + rng.randint(1, 10), oy + rng.randint(3, 13)
        hline(img, x, x + rng.randint(2, 4), y, P.WATER_LIGHT)
    if lilies:
        for _ in range(2):
            cx, cy = ox + rng.randint(3, 12), oy + rng.randint(3, 12)
            for dy in range(-1, 2):
                for dx in range(-2, 3):
                    if abs(dx) + abs(dy) < 3:
                        put(img, cx + dx, cy + dy, P.FOREST_GRASS)
            put(img, cx, cy, P.PETAL_LIGHT)
    if shore:
        for x in range(ox, ox + T):
            h = 3 + (1 if rng.random() < 0.4 else 0)
            vline(img, x, oy, oy + h, P.FOREST_GRASS)
            put(img, x, oy + h, P.FOREST_GRASS_DARK)
            put(img, x, oy + h + 1, P.WATER_DARK)


def forest_atlas():
    """Atlas 8x3 do Bosque."""
    img = canvas(8 * T, 3 * T)
    grass_tile(img, 0 * T, 0, 81)
    grass_tile(img, 1 * T, 0, 82)
    grass_tile(img, 2 * T, 0, 83, flowers=True)
    path_tile(img, 3 * T, 0, 84)
    moss_tile(img, 4 * T, 0, 85)
    grass_tile(img, 5 * T, 0, 86, dark=True)
    bridge_tile(img, 6 * T, 0, 87)
    grass_tile(img, 7 * T, 0, 88, pollen=True)
    canopy_tile(img, 0 * T, T, 91)
    trunks_tile(img, 1 * T, T, 92)
    trunks_tile(img, 2 * T, T, 93)
    trunks_tile(img, 3 * T, T, 94, gap=True)
    cliff_tile(img, 4 * T, T, 95)
    cliff_tile(img, 5 * T, T, 96, lower=True)
    # (6,1) = barreira invisivel
    water_tile(img, 7 * T, T, 98)
    water_tile(img, 0 * T, 2 * T, 101, lilies=True)
    water_tile(img, 1 * T, 2 * T, 102, shore=True)
    slab_tile(img, 2 * T, 2 * T, 103)
    path_tile(img, 3 * T, 2 * T, 104)
    return img


# =============================================================================
# Cenario
# =============================================================================

def tree():
    """Arvore grande (32x48): copa redonda e tronco; colisao so no pe."""
    rng = random.Random(7)
    img = canvas(32, 48)
    rect(img, 13, 26, 19, 46, P.BARK)
    vline(img, 13, 26, 46, P.BARK_DARK)
    vline(img, 18, 26, 46, P.BARK_LIGHT)
    for x, y in ((11, 45), (20, 45), (10, 46), (21, 46)):
        put(img, x, y, P.BARK_DARK)
    ellipse(img, 16, 18, 15, 14, P.CANOPY_DARK)
    ellipse(img, 15, 16, 13, 12, P.CANOPY)
    for _ in range(9):
        cx, cy = rng.randint(6, 25), rng.randint(6, 22)
        ellipse(img, cx, cy, 4, 3, P.CANOPY_LIGHT if cy < 15 else P.CANOPY)
    for _ in range(14):
        put(img, rng.randint(4, 27), rng.randint(4, 26), P.FOREST_GRASS_LIGHT)
    return _outline(img)


def bush():
    rng = random.Random(11)
    img = canvas(16, 14)
    ellipse(img, 8, 8, 7, 5, P.CANOPY)
    ellipse(img, 7, 7, 5, 4, P.CANOPY_LIGHT)
    for _ in range(4):
        put(img, rng.randint(3, 12), rng.randint(4, 11), P.PETAL_LIGHT)
    return _outline(img)


def log():
    img = canvas(32, 14)
    rect(img, 2, 4, 30, 12, P.BARK)
    hline(img, 2, 30, 4, P.BARK_LIGHT)
    hline(img, 2, 30, 11, P.BARK_DARK)
    ellipse(img, 28, 8, 3, 4, P.BARK_LIGHT)
    ellipse(img, 28, 8, 1.5, 2, P.BARK_DARK)
    for x in range(4, 24, 3):
        put(img, x, 3, P.MOSS_LIGHT)
        put(img, x + 1, 4, P.MOSS)
    return _outline(img)


def sleeping_soldier():
    """'Soldados dormem em pe': um Soldado Remendado parado, cabeca caida, musgo."""
    key = {"g": P.HELMET, "G": P.MOSS, "s": P.DEAD_SKIN, "z": P.DEAD_SKIN_SHADOW, "c": P.DEAD_SKIN_SHADOW,
           "u": P.UNIFORM, "d": P.UNIFORM_DARK, "m": P.MOSS_LIGHT, "B": P.BOOTS, "S": P.SHIELD_DARK}
    grid = [
        "....GGGG......",
        "..gGgggGgg....",
        ".gggggggggg...",
        "gggggggggggg..",
        ".dsssssssss...",
        ".dssccsscc....",
        "..dzsssssz....",
        "..uuumuuuuu...",
        ".uuuuuuuuuuuS.",
        ".suumuuuuuusS.",
        ".s.uuuuuum.SS.",
        "...uuuuuuuu...",
        "...dduuuudd...",
        "....dd.dd.....",
        "....dm.dd.....",
        "....BB.BB.....",
    ]
    frame = canvas(24, 24)
    sprite = from_grid(grid, key, outline=O)
    paste(frame, sprite, (24 - sprite.width) // 2, 23 - sprite.height)
    return frame


def waterfall_frames():
    """Cachoeira que cai da borda da ilha 'em camera lenta' (16x48, 3 quadros)."""
    frames = []
    for f in range(3):
        img = canvas(16, 48)
        for y in range(48):
            for x in range(0, 16):  # largura inteira: cachoeiras lado a lado viram uma so
                band = (y + f * 2 + (x % 3)) % 6
                c = P.WATER_LIGHT if band < 2 else (P.FOAM if band == 2 else P.WATER)
                fade = y / 48
                if fade > 0.75 and (x * 5 + y + f) % 4 == 0:
                    continue
                put(img, x, y, c)
        for x in range(0, 16):  # espuma na borda de cima
            put(img, x, 0, P.FOAM)
            if x % 2 == f % 2:
                put(img, x, 1, P.FOAM)
        frames.append(img)
    return frames


def pollen_cloud():
    """Nuvem de polen (32x32, suave): o sono de Nyssa espalhado pelo chao."""
    img = canvas(32, 32)
    rng = random.Random(5)
    for y in range(32):
        for x in range(32):
            d = math.hypot(x - 15.5, y - 15.5) / 15.5
            if d > 1:
                continue
            a = int(150 * (1 - d) ** 1.4)
            if rng.random() < 0.1:
                a = min(255, a + 70)
            c = P.POLLEN_LIGHT if rng.random() < 0.5 else P.POLLEN
            img.putpixel((x, y), (*c, a))
    return img


def zzz():
    grid = ["wwww", "..w.", ".w..", "wwww"]
    return from_grid(grid, {"w": (230, 226, 250)}, outline=O)


def _outline(img):
    from pixel import add_outline
    return add_outline(img, O)


# =============================================================================
# Inimigos
# =============================================================================

# --- Sonambulo: "pessoas que Nyssa nunca deixou acordar" (olhos SEMPRE fechados)
SLEEPER_KEY = {"h": P.CIVIL_HAIR, "s": P.SLEEPER_SKIN, "z": P.SLEEPER_SKIN_DARK, "c": P.SLEEPER_SKIN_DARK,
               "w": P.SLEEPER_GOWN, "W": P.SLEEPER_GOWN_DARK, "p": P.SLEEPER_SKIN_DARK}
SLEEPER_BODY = [
    "...hhhh.......",
    "..hhhhhhh.....",
    ".hhhhhsssss...",
    ".hhhhsssssss..",
    ".hhhsscccscc..",
    "..hhsssssss...",
    "...hzsssssz...",
    "...wwwwwwww...",
    "..swwwwwwwws..",
    "..swwwwwwwws..",
    "..swwwwwwwws..",
    "..zwwwwwwwwz..",
    "...WwwwwwwW...",
    "...WWwwwwWW...",
]
SLEEPER_LEGS = [
    ["....pp.pp.....", "....pp.pp.....", "....zz.zz....."],
    ["....pp..pp....", "...pp....pp...", "...zz....zz..."],
    ["....pp.pp.....", "....pp.pp.....", "....zz.zz....."],
    [".....pppp.....", ".....pppp.....", ".....zzzz....."],
]


def sleeper_frames():
    """[dormindo, passo, dormindo, passo 2, BRACOS ESTICADOS (ataque)]"""
    frames = _frames(SLEEPER_BODY, SLEEPER_LEGS, SLEEPER_KEY)
    reach = list(SLEEPER_BODY)
    reach[8] = "..wwwwwwwwwsss"
    reach[9] = "..wwwwwwwwwwss"
    reach[10] = "..wwwwwwwww..."
    frames += _frames(reach, [SLEEPER_LEGS[1]], SLEEPER_KEY)
    return frames


# --- Flor de Polen (24x24): bulbo de petalas com o miolo cheio de polen
def flower_frames():
    """[aberta, inchada (vai soltar), fechada (acabou de soltar)]"""
    frames = []
    for state in range(3):
        img = canvas(24, 24)
        rect(img, 11, 13, 13, 23, P.FOREST_GRASS_DARK)
        ellipse(img, 7, 19, 3, 1.5, P.FOREST_GRASS)
        ellipse(img, 17, 18, 3, 1.5, P.FOREST_GRASS)
        r = (6 if state == 0 else 8 if state == 1 else 4)
        cy = 10
        for k in range(6):
            a = k * math.pi / 3 + (0.3 if state == 2 else 0)
            px, py = 12 + math.cos(a) * r * 0.75, cy + math.sin(a) * r * 0.6
            ellipse(img, px, py, r * 0.45, r * 0.35, P.PETAL if k % 2 else P.PETAL_DARK)
        ellipse(img, 12, cy, r * 0.42 + 1, r * 0.35 + 1, P.POLLEN if state != 2 else P.PETAL_DARK)
        if state != 2:
            put(img, 11, cy - 1, P.POLLEN_LIGHT)
            put(img, 13, cy, P.POLLEN_LIGHT)
        frames.append(_outline(img))
    return frames


# --- Cervo de Musgo (32x32): "animais parados no meio do salto"
DEER_KEY = {"d": P.DEER, "D": P.DEER_DARK, "l": P.DEER_LIGHT, "a": P.ANTLER, "m": P.MOSS, "M": P.MOSS_LIGHT,
            "e": (30, 28, 24), "k": P.DEER_DARK}
DEER_BODY = [
    "..........a..a.....",
    "..........aa.a.a...",
    "...........aaaa....",
    "............mdd....",
    "...........mddde...",
    "...........ddddkk..",
    "..mmMm.....dddl....",
    ".mdddmmmmmmddd.....",
    ".dddddddMdddddd....",
    "..dddddddddddDd....",
    "..ldddddddddDD.....",
    "...DDDDDDDDDD......",
]
DEER_LEGS = [
    ["...dd......dd.....", "...dd......dd.....", "...kk......kk....."],
    ["..dd........dd....", ".dd..........dd...", ".kk..........kk..."],
    ["...dd......dd.....", "...dd......dd.....", "...kk......kk....."],
    ["....dd....dd......", "....dd....dd......", "....kk....kk......"],
]


def deer_frames():
    """[parado, passo, parado, passo 2, INVESTIDA (cabeca baixa), SALTO CONGELADO]"""
    frames = _frames(DEER_BODY, DEER_LEGS, DEER_KEY, size=(32, 32))
    charge = ["..................."] * 3 + [
        "...................",
        "...................",
        "..mmMm.....mddaa...",
        ".mdddmmmmmmdddea.a.",
        ".dddddddMddddddkkaa",
        "..dddddddddddDd..a.",
        "..ldddddddddDD.....",
        "...DDDDDDDDDD......",
        "...................",
    ]
    frames += _frames(charge, [DEER_LEGS[1]], DEER_KEY, size=(32, 32))
    leap_legs = ["..dd.........dd...", ".dd...........dd..", "kk.............kk."]
    frames += _frames(DEER_BODY, [leap_legs], DEER_KEY, size=(32, 32))
    return frames


# --- Fada Murcha (16x16): "fadas que tambem desistiram"
def wither_frames():
    frames = []
    key = {"w": P.WITHER_WING, "W": P.WITHER, "k": P.WITHER_DARK, "s": P.SLEEPER_SKIN, "h": P.WITHER_DARK,
           "g": P.DREAM}
    for wing in range(2):
        up = wing == 0
        grid = [
            ("ww.....ww" if up else "........."),
            ("wwww.wwww" if up else "........."),
            ".wwwhwww." if up else "ww..h..ww",
            "...hsh...",
            "...sss...",
            "..kWWWk.." if up else "wwkWWWkww",
            "...WWW..." if up else ".wwWWWww.",
            "...k.k...",
            "...g.g...",
        ]
        frame = canvas(16, 16)
        sprite = from_grid(grid, key, outline=O)
        paste(frame, sprite, (16 - sprite.width) // 2, 15 - sprite.height)
        frames.append(frame)
    return frames


# =============================================================================
# Mini-chefes
# =============================================================================

def guardian_frames():
    """O Vigia que Dormiu (48x48): pedra, musgo e um elmo caido sobre o rosto.
    [dormindo (cabeca baixa, musgo), parado, passo, passo 2, golpe (bracos acima)]"""
    frames = []
    for state in range(5):
        rng = random.Random(31)
        img = canvas(48, 48)
        sway = 1 if state in (2, 3) else 0
        head_y = 10 if state == 0 else 6
        # pernas
        lx = 15 - (2 if state == 2 else 0)
        rx = 27 + (2 if state == 3 else 0)
        rect(img, lx, 34, lx + 7, 46, P.GUARD_STONE_DARK)
        rect(img, rx, 34, rx + 7, 46, P.GUARD_STONE_DARK)
        hline(img, lx, lx + 7, 45, P.ROCK_DEEP)
        hline(img, rx, rx + 7, 45, P.ROCK_DEEP)
        # tronco
        rect(img, 11, 16, 37, 36, P.GUARD_STONE)
        rect(img, 11, 16, 14, 36, P.GUARD_STONE_DARK)
        rect(img, 33, 16, 37, 36, P.GUARD_STONE_LIGHT)
        hline(img, 11, 37, 26, P.GUARD_STONE_DARK)
        rect(img, 21, 20, 27, 24, P.DREAM_DARK)  # runa apagada no peito
        put(img, 24, 22, P.DREAM if state != 0 else P.DREAM_DARK)
        # bracos
        if state == 4:
            rect(img, 6, 4, 11, 22, P.GUARD_STONE_DARK)
            rect(img, 37, 4, 42, 22, P.GUARD_STONE_LIGHT)
        else:
            rect(img, 5, 18 + sway, 11, 36 + sway, P.GUARD_STONE_DARK)
            rect(img, 37, 18 - sway, 43, 36 - sway, P.GUARD_STONE_LIGHT)
        # cabeca / elmo
        rect(img, 17, head_y, 31, head_y + 10, P.GUARD_STONE)
        hline(img, 17, 31, head_y + 5, P.ROCK_DEEP)
        if state == 0:
            hline(img, 20, 22, head_y + 6, P.GUARD_STONE_DARK)  # olhos fechados
            hline(img, 26, 28, head_y + 6, P.GUARD_STONE_DARK)
        else:
            put(img, 21, head_y + 6, P.DREAM)
            put(img, 27, head_y + 6, P.DREAM)
        # musgo (muito mais quando dorme)
        for _ in range(60 if state == 0 else 22):
            x, y = rng.randint(8, 40), rng.randint(head_y, 40)
            if img.getpixel((x, y))[3] > 0:
                put(img, x, y, rng.choice([P.MOSS, P.MOSS_LIGHT]))
        frames.append(_outline(img))
    return frames


def guardian_club():
    """Tronco-clava do Vigia (empunhadura em x=2)."""
    img = canvas(30, 10)
    rect(img, 0, 3, 18, 7, P.BARK)
    hline(img, 0, 18, 3, P.BARK_LIGHT)
    ellipse(img, 23, 5, 6, 5, P.BARK_DARK)
    ellipse(img, 22, 4, 4, 3, P.BARK)
    for x in range(4, 26, 4):
        put(img, x, 2, P.MOSS_LIGHT)
    return _outline(img)


def spore_mother_frames():
    """A Mae dos Esporos (48x48): bulbo enorme cercado de petalas.
    [respirando, inchada (vai explodir), aberta (soltou)]"""
    frames = []
    for state in range(3):
        rng = random.Random(41)
        img = canvas(48, 48)
        for k in range(7):  # raizes
            a = math.pi * (0.9 + k * 0.2 / 6 * 6)
            x0 = 24 + math.cos(k * 0.9) * 14
            vline(img, int(x0), 38, 47, P.ROOT)
        ellipse(img, 24, 40, 20, 6, P.FOREST_GRASS_DARK)
        r = 15 if state == 0 else 18 if state == 1 else 13
        for k in range(8):
            a = k * math.pi / 4 + (0.4 if state == 2 else 0)
            px, py = 24 + math.cos(a) * r, 26 + math.sin(a) * r * 0.7
            ellipse(img, px, py, 8, 6, P.PETAL_DARK if k % 2 else P.PETAL)
        ellipse(img, 24, 26, r * 0.7, r * 0.6, P.PETAL_LIGHT if state != 2 else P.PETAL_DARK)
        ellipse(img, 24, 26, r * 0.45, r * 0.38, P.POLLEN)
        if state == 2:
            ellipse(img, 24, 26, r * 0.3, r * 0.25, (40, 20, 30))  # a "boca" aberta
        for _ in range(16 if state == 1 else 6):
            put(img, rng.randint(14, 34), rng.randint(16, 34), P.POLLEN_LIGHT)
        frames.append(_outline(img))
    return frames


# =============================================================================
# Nyssa Lumevel, A Que Nao Desperta (chefe)
# =============================================================================
# Irma da Fada do Teatro: o mesmo "molde" de fada, mas lilas, cabelo comprido
# que escorre, e DEITADA no ar (fase 1). Na fase 2 ela senta e abre os olhos.
NYSSA_KEY = {"h": P.DREAM, "H": P.DREAM_DARK, "s": P.SLEEPER_SKIN, "z": P.SLEEPER_SKIN_DARK, "e": (60, 40, 90),
             "c": P.DREAM_DARK, "d": (226, 220, 240), "D": (186, 178, 214), "w": (216, 206, 244), "W": (176, 160, 226)}


def nyssa_frames():
    """[deitada, deitada respirando, sentada (olhos abertos), sentada 2, conjurando] — 32x32."""
    lying = [
        "......wwww..........wwww..",
        ".....wWwwww........wwwwWw.",
        "......wwww..........wwww..",
        "hhhhh.....................",
        "hhHhhhss..ddddddddddd.....",
        "hHhhhsscczddddDdddddddss..",
        ".hhhhhssz.dddddddDdddd.zss",
        "..hhhh....DDDDDDDDDDDD....",
        "....hh....................",
    ]
    lying2 = list(lying)
    lying2[0] = ".....wwww............wwww."
    lying2[2] = ".......wwww........wwww...."[:26]
    sitting = [
        "ww........ww",
        "wWw..hh..wWw",
        "wwwwhhhhwwww",
        ".wwhhsshhww.",
        "..hhseeshh..",
        "..hhsszsHh..",
        "..hh.ss.hh..",
        "..hddddddh..",
        ".sdddddddds.",
        ".s.ddDddd.s.",
        "...ddDdddd..",
        "...DDDDDDD..",
        "....s...s...",
    ]
    sitting2 = list(sitting)
    sitting2[0] = "............"
    sitting2[1] = "w....hh....w"
    sitting2[2] = "wwwwhhhhwwww"
    cast = list(sitting)
    cast[7] = "s.hddddddh.s"
    cast[8] = "s.dddddddd.s"
    cast[9] = "..ddDddd...."
    frames = []
    for grid in (lying, lying2, sitting, sitting2, cast):
        sprite = from_grid(grid, NYSSA_KEY, outline=O)
        frame = canvas(32, 32)
        paste(frame, sprite, (32 - sprite.width) // 2, 30 - sprite.height)
        frames.append(frame)
    return frames


def dream_bubble():
    img = canvas(12, 12)
    ellipse(img, 5.5, 5.5, 5, 5, (*P.DREAM, 150))
    ellipse(img, 5.5, 5.5, 3.5, 3.5, (*P.DREAM_DARK, 110))
    put(img, 3, 3, (255, 255, 255, 230))
    put(img, 4, 3, (255, 255, 255, 180))
    put(img, 3, 4, (255, 255, 255, 180))
    return img


def dream_shadow():
    """Aviso: o chao escurece (36x22). 'Areas escuras do chao somem.'"""
    img = canvas(36, 22)
    rng = random.Random(9)
    for y in range(22):
        for x in range(36):
            d = ((x - 17.5) / 18) ** 2 + ((y - 10.5) / 11) ** 2
            if d <= 1 and rng.random() < 0.92 - d * 0.5:
                img.putpixel((x, y), (*P.DREAM_DARK, int(170 * (1 - d * 0.6))))
    return img


def dream_hole():
    """O chao que sumiu: um vazio lilas-escuro com 'estrelas' do sonho (36x22)."""
    img = canvas(36, 22)
    rng = random.Random(10)
    for y in range(22):
        for x in range(36):
            d = ((x - 17.5) / 18) ** 2 + ((y - 10.5) / 11) ** 2
            if d <= 1:
                c = mix((14, 10, 26), P.DREAM_DARK, max(0.0, d - 0.55) * 2)
                img.putpixel((x, y), (*c[:3], 255))
    for _ in range(10):
        x, y = rng.randint(6, 29), rng.randint(4, 17)
        if ((x - 17.5) / 18) ** 2 + ((y - 10.5) / 11) ** 2 < 0.6:
            img.putpixel((x, y), (*P.DREAM, 255))
    return img


def flower_bed():
    """Onde Nyssa dormia: uma cama de flores lilases (memorial depois da luta)."""
    img = canvas(32, 16)
    rng = random.Random(12)
    ellipse(img, 16, 9, 14, 6, P.FOREST_GRASS_DARK)
    ellipse(img, 16, 8, 12, 5, P.MOSS)
    for _ in range(18):
        x, y = rng.randint(5, 26), rng.randint(4, 12)
        put(img, x, y, rng.choice([P.DREAM, P.PETAL_LIGHT, (236, 230, 250)]))
    return _outline(img)
