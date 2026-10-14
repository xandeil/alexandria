"""Aldir Cornelios, O Detentor do Caos, e a arena dele (Cidade Estilhacada).

Biblia: soldado de alto escalao aposentado, martelo de guerra gigante. A cidade
foi destruida por Rachel; o que sobrou foi destruido por Aldir.
Visual: casaco de oficial do exercito do governo (o mesmo verde dos Soldados
Remendados), dragonas douradas, peitoral de aco riscado, faixa vermelha (Ira),
cabelo e barba grisalhos, cicatriz no olho. Olhando para a DIREITA (o jogo espelha).
"""
from __future__ import annotations

import random

import palette as P
from pixel import canvas, from_grid, paste, ellipse, put, hline, vline, rect, shade, mix

O = P.OUTLINE

ALDIR_KEY = {
    "h": P.ALDIR_HAIR, "H": P.ALDIR_HAIR_LIGHT, "s": P.ALDIR_SKIN, "z": P.ALDIR_SKIN_SHADOW,
    "e": P.ALDIR_EYE, "x": P.ALDIR_SCAR, "b": P.ALDIR_BEARD,
    "G": P.GOLD, "g": P.GOLD_DARK, "c": P.ALDIR_COAT, "C": P.ALDIR_COAT_DARK, "k": P.ALDIR_COAT_LIGHT,
    "P": P.STEEL_DARK, "L": P.STEEL, "d": P.STEEL_DEEP, "D": (42, 46, 54), "m": P.GOLD,
    "R": P.ALDIR_SASH, "r": P.ALDIR_SASH_DARK, "B": P.BOOTS, "q": P.ALDIR_COAT_DARK,
}

# Corpo sem pernas (24 de largura). Cabeca grande (chibi), ombros largos.
ALDIR_BODY = [
    "........hhhhhhh.........",
    "......hhHHHHHHhhh.......",
    ".....hHHhhhhhhhhhh......",
    "....hhhhhhhhhhhhhhh.....",
    "....hhhhhhhhhhhhhhhh....",
    "....hhhhhhhhhhssssshh...",
    "....hhhhhhhhhsssssssss..",
    "....hhhhhhhhzzzzsszzzs..",
    "....hhhhhhhhsexsssssess.",
    "...shhhhhhhhssxssssssss.",
    "...szhhhhhhhssssssssss..",
    "....zhhhhhhbsssssbbbss..",
    ".....zzzzzbbbbsbbbbbbz..",
    "......zzzbbbbbbbbbbbb...",
    "...GGgccczbbbbbbzcccGG..",
    "..GGgcccccccczzcccccgGG.",
    ".kccccccPPPPPPPPPcccccc.",
    "kcccccPPLLPPPPPPPdcccccc",
    "kccccPPLPPPPmPPPPdcccccc",
    "cccccPPPPPPPPPPPPdcccccs",
    "sscCcPPPPPPPPPPPdDccccss",
    "ssCCcdPPPPPPPPPddDCCccss",
    ".sCCcddPPPPPPPddDCCCcs..",
    "..CcRRRRRRRRRRRRRRRRcC..",
    "..CccRrrRRRRRRRRRrRccC..",
    "...ccccccccccccccccccc..",
    "...CCCCcccccccccCCCCC...",
]
ALDIR_LEGS = [
    ["......qqqq...qqqq......", "......qqqq...qqqq......", "......qqqq...qqqq......", ".....BBBBB..BBBBB......", ".....BBBBB..BBBBB......"],
    ["......qqqq....qqqq.....", ".....qqqq......qqqq....", ".....qqqq......qqqq....", "....BBBBB......BBBBB...", "....BBBBB......BBBBB..."],
    ["......qqqq...qqqq......", "......qqqq...qqqq......", "......qqqq...qqqq......", ".....BBBBB..BBBBB......", ".....BBBBB..BBBBB......"],
    [".......qqqqqqqqq.......", ".......qqqqqqqqq.......", ".......qqqqqqqq........", "......BBBBBBBBBB.......", "......BBBBBBBBBB......."],
]
FRAME = 40
OFFSET = (7, 6)  # onde a grade entra no quadro 40x40 (pes na linha ~38)


def _frame(body: list[str], legs: list[str], dy: int = 0) -> object:
    frame = canvas(FRAME, FRAME)
    paste(frame, from_grid(body + legs, ALDIR_KEY, outline=O), OFFSET[0], OFFSET[1] + dy)
    return frame


def aldir_frames() -> list:
    """[parado, passada, parado, cruzando] — 40x40."""
    return [_frame(ALDIR_BODY, legs) for legs in ALDIR_LEGS]


def aldir_kneel() -> object:
    """Ajoelhado diante do martelo cravado no chao (antes da luta)."""
    legs = [
        "....qqqqqqqqqq.qqqq.....",
        "....qqqqqqqqqq..qqq.....",
        "....BBBB.......BBBBB....",
    ]
    body = list(ALDIR_BODY)
    return _frame(body, legs, dy=2)


def aldir_eyes() -> object:
    """So os olhos, em brasa (fase 2: "a razao some"). Mesmo sistema do corpo."""
    frame = canvas(FRAME, FRAME)
    # olhos na linha 8 da grade (colunas 13 e 20) — +1 da margem do contorno
    for col in (13, 20):
        put(frame, OFFSET[0] + 1 + col, OFFSET[1] + 1 + 8, P.EMBER)
        put(frame, OFFSET[0] + 1 + col, OFFSET[1] + 1 + 7, P.FLAME + (150,))
    return frame


def aldir_hammer() -> object:
    """Martelo de guerra apontando para a DIREITA; empunhadura em x=2..5.
    A cabeca e um bloco de ferro com rachaduras em brasa (ele quebra o chao)."""
    key = {"f": P.ALDIR_HANDLE, "F": shade(P.ALDIR_HANDLE, 1.3), "w": P.IRON_LIGHT,
           "H": P.HAMMER_HEAD, "L": P.HAMMER_HEAD_LIGHT, "d": P.HAMMER_HEAD_DARK, "e": P.EMBER, "k": P.STEEL_DEEP}
    grid = [
        "....................kHHHHHHHk.",
        "....................HLLLLLLLHd",
        "....................HLHHHHHHHd",
        "....................HHHHeHHHHd",
        "FFFFFFFFFFFFFFFFFFFwHHHeeHHHHd",
        "fffffffffffffffffffwHHHHHeHHHd",
        "....................HHHeHHHHHd",
        "....................HHHHHHHHHd",
        "....................dHHHHHHHdd",
        "....................kddddddddk",
    ]
    return from_grid(grid, key, outline=O)


# ---------------------------------------------------------------------------
# Arena: coberturas destrutiveis, buracos no chao, rachaduras, estilhacos
# ---------------------------------------------------------------------------
def cover_frames() -> list:
    """Barreira de concreto (cobertura) em 3 estados: inteira, rachada, quebrada.
    Ela segura a Onda de Choque do Aldir — ate ele resolver quebrar."""
    key = {"c": P.CONCRETE, "C": P.CONCRETE_ALT, "l": P.CONCRETE_LIGHT, "d": P.RUBBLE_DARK,
           "y": P.ROAD_PAINT, "Y": shade(P.ROAD_PAINT, 0.75), "k": P.ASPHALT_CRACK, "m": P.IRON_LIGHT, "r": P.RUBBLE}
    intact = [
        "....llllllllllllll....",
        "...lcccccccccccccCl...",
        "...ccccccccccccccC....",
        "..lccccccccccccccCC...",
        "..ccyyyyccyyyyccyyC...",
        "..ccYYYYccYYYYccYYC...",
        ".lccccccccccccccccCC..",
        ".cccccccccccccccccCC..",
        "lcccccccccccccccccCCC.",
        "cccccccccccccccccccCC.",
        "CCCCCCCCCCCCCCCCCCCCC.",
        ".dd.ddd......ddd.dd...",
    ]
    cracked = [
        "....lllllll.llllll....",
        "...lcccccck.cccccCl...",
        "...cccccckcckccccC....",
        "..lccccckccccckccCC...",
        "..ccyyykccyyyycyyyC...",
        "..ccYYkcccYYYYccYYC...",
        ".lccckcccccckcccccCC..",
        ".ccckccccccccckcccCC..",
        "lccckccccccccccckcCCC.",
        "ccckcccccccccccccccCC.",
        "CCCkCCCCCCCCCCCkCCCCC.",
        ".dd.ddd.rr...ddd.dd.r.",
    ]
    broken = [
        "......................",
        "......................",
        "......................",
        "......m......m........",
        "......m......m........",
        ".....lm.lll..m.ll.....",
        "...llcmcccclcmcccl....",
        "..lcccccckccccccccl...",
        ".lcccyyYcccckccYYcC...",
        "lccccccckccccccccccC..",
        "CCCCCCCCkCCCCCCCCCCCr.",
        ".rr.ddd.rr.r.ddd.dd.r.",
    ]
    frames = []
    for grid in (intact, cracked, broken):
        frame = canvas(28, 24)
        paste(frame, from_grid(grid, key, outline=O), 2, 9)
        frames.append(frame)
    return frames


def pit_hole(w: int = 40, h: int = 26) -> object:
    """Buraco aberto pelo martelo: pelo rombo aparece o CEU embaixo da ilha.
    Vista 3/4: a parede de rocha do fundo aparece no alto do buraco."""
    img = canvas(w, h)
    cx, cy = w / 2, h / 2
    rx, ry = w / 2 - 2, h / 2 - 2
    rng = random.Random(41)
    # 1) borda irregular de entulho
    for y in range(h):
        for x in range(w):
            dx, dy = (x + 0.5 - cx) / (rx + 2), (y + 0.5 - cy) / (ry + 2)
            d = dx * dx + dy * dy
            if 0.78 < d <= 1.0 + rng.uniform(-0.06, 0.06):
                put(img, x, y, rng.choice([P.RUBBLE, P.RUBBLE_DARK, P.CONCRETE, P.ROCK_DARK]))
    # 2) o rombo: ceu em degrade, com a parede de rocha no alto
    for y in range(h):
        for x in range(w):
            dx, dy = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry
            d = dx * dx + dy * dy
            if d > 0.8:
                continue
            t = (y - (cy - ry)) / (2 * ry)
            if t < 0.38:  # parede do fundo (estratos de rocha)
                band = int((y + x * 0.15) / 2) % 3
                color = [P.ROCK_DEEP, P.ROCK_DARK, P.ROCK][band]
                color = mix(color, (0, 0, 0), 0.35 * (1 - t / 0.38))
            else:
                color = mix(P.SKY_TOP, P.SKY_BOTTOM, (t - 0.38) / 0.62)
            put(img, x, y, color)
    # 3) uma nuvem passando la embaixo
    for x in range(int(cx - 6), int(cx + 7)):
        put(img, x, int(cy + ry * 0.45), P.CLOUD)
        if abs(x - cx) < 4:
            put(img, x, int(cy + ry * 0.45) - 1, P.CLOUD)
    # 4) brasas na borda
    for _ in range(6):
        a = rng.uniform(0, 6.283)
        import math
        put(img, int(cx + math.cos(a) * rx), int(cy + math.sin(a) * ry), P.EMBER)
    return img


def pit_cracks(w: int = 40, h: int = 26) -> object:
    """Chao rachando (aviso de ~0,8 s antes do buraco abrir): rachaduras em brasa."""
    import math
    img = canvas(w, h)
    rng = random.Random(7)
    cx, cy = w / 2, h / 2
    # contorno do buraco que VAI abrir: uma elipse tracejada de rachaduras
    rx, ry = w / 2 - 3, h / 2 - 3
    for i in range(64):
        a = i / 64 * 6.283
        if i % 5 == 4:
            continue
        put(img, int(cx + math.cos(a) * rx), int(cy + math.sin(a) * ry), P.EMBER_DARK if i % 2 else P.EMBER)
    for i in range(7):
        a = i / 7 * 6.283 + rng.uniform(-0.3, 0.3)
        x, y = cx, cy
        for s in range(int(rx * rng.uniform(0.6, 0.95))):
            x += math.cos(a) * 1.0
            y += math.sin(a) * (ry / rx)
            a += rng.uniform(-0.35, 0.35)
            put(img, int(x), int(y), P.ASPHALT_CRACK if s < 2 else (P.EMBER if s % 4 else P.FLAME))
    ellipse(img, cx, cy, 2.5, 1.7, P.ASPHALT_CRACK)
    return img


def pit_rubble(w: int = 40, h: int = 26) -> object:
    """Buraco entupido de entulho (chao seguro de novo)."""
    img = canvas(w, h)
    rng = random.Random(13)
    cx, cy = w / 2, h / 2
    ellipse(img, cx, cy + 1, w / 2 - 4, h / 2 - 4, P.RUBBLE_DARK)
    ellipse(img, cx, cy, w / 2 - 6, h / 2 - 6, P.RUBBLE)
    for _ in range(90):  # pedacos de concreto e asfalto
        x = rng.gauss(cx, w * 0.17)
        y = rng.gauss(cy, h * 0.17)
        c = rng.choice([P.CONCRETE, P.CONCRETE_LIGHT, P.ROCK_DARK, P.ASPHALT, P.RUBBLE_DARK])
        put(img, int(x), int(y), c)
        put(img, int(x) + 1, int(y), shade(c, 0.8))
        put(img, int(x), int(y) + 1, shade(c, 0.6))
    return img


def crack_decal() -> object:
    """Marca do martelo no chao (fase 1: rachadura, sem buraco)."""
    import math
    img = canvas(28, 18)
    rng = random.Random(23)
    cx, cy = 14, 9
    for i in range(6):
        a = i / 6 * 6.283 + rng.uniform(-0.4, 0.4)
        x, y = cx, cy
        for s in range(rng.randint(6, 11)):
            x += math.cos(a) * 1.1
            y += math.sin(a) * 0.65
            a += rng.uniform(-0.4, 0.4)
            put(img, int(x), int(y), P.ASPHALT_CRACK)
            if s < 3:
                put(img, int(x), int(y) + 1, P.EMBER_DARK)
    ellipse(img, cx, cy, 2.5, 1.6, P.ASPHALT_CRACK)
    return img


def shock_rock() -> object:
    """Estilhaco que brota do chao na Onda de Choque."""
    key = {"r": P.ROCK, "R": P.ROCK_DARK, "l": P.CONCRETE_LIGHT, "e": P.EMBER, "f": P.FLAME}
    grid = [
        "....l.....",
        "...lr..l..",
        "...rR.lr..",
        ".l.rRlrR..",
        "lr.rRrRR.l",
        "rReRRRRefr",
        ".eRRRRRRe.",
    ]
    frame = canvas(14, 12)
    paste(frame, from_grid(grid, key, outline=O), 1, 3)
    return frame
