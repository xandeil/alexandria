"""Arte do Prologo: o Complexo das Capsulas.

Tudo tirado da Biblia (texto e imagem de referencia docs/referencias/prologo_capsulas.jpg):
  - laboratorio verde-acinzentado com faixas de luz verde, capsulas em fileiras
    (ocupadas, quebradas, vazias) e "vegetacao viva demais para um lugar abandonado";
  - criancas e adolescentes de olhos brancos, short branco e espadas de madeira gastas;
  - a Governanta: coque castanho e jaleco branco, sentada a mesa de cabeca baixa.

As criancas usam a MESMA tunica branca do protagonista (palette.TUNIC): a cena
sugere, sem dizer, que voce ja foi uma delas.
"""
from __future__ import annotations

import math
import random

import palette as P
from pixel import canvas, from_grid, paste, put, rect, hline, vline, ellipse, shade, mix, hstrip

O = P.OUTLINE
T = 16


# =============================================================================
# Tileset do laboratorio (atlas 8x3) — coordenadas espelhadas em level.gd (THEMES)
# =============================================================================
def _noise(img, x0, y0, base, alts, chance, rng, w=T, h=T):
    for y in range(y0, y0 + h):
        for x in range(x0, x0 + w):
            put(img, x, y, rng.choice(alts) if rng.random() < chance else base)


def lab_plate(img, ox, oy, seed, base=P.LAB_FLOOR, scuff=False):
    """Placa de metal do piso: rejunte em cima/esquerda, brilho embaixo/direita, rebites."""
    rng = random.Random(seed)
    _noise(img, ox, oy, base, [P.LAB_FLOOR_ALT, shade(base, 1.04)], 0.16, rng)
    hline(img, ox, ox + T, oy, P.LAB_GROUT)
    vline(img, ox, oy, oy + T, P.LAB_GROUT)
    hline(img, ox + 1, ox + T, oy + 1, P.LAB_FLOOR_LIGHT)
    vline(img, ox + 1, oy + 1, oy + T, shade(P.LAB_FLOOR_LIGHT, 0.95))
    hline(img, ox + 1, ox + T, oy + T - 1, shade(base, 0.86))
    for rx, ry in ((3, 3), (T - 3, 3), (3, T - 3), (T - 3, T - 3)):
        put(img, ox + rx, oy + ry, P.LAB_RIVET)
        put(img, ox + rx, oy + ry + 1, shade(base, 0.8))
    if scuff:
        for _ in range(5):
            x, y = ox + rng.randint(4, 11), oy + rng.randint(4, 11)
            put(img, x, y, shade(base, 0.88))
            put(img, x + 1, y, shade(base, 0.92))


def lab_cracked(img, ox, oy, seed):
    lab_plate(img, ox, oy, seed)
    rng = random.Random(seed)
    x, y = ox + rng.randint(3, 6), oy + 2
    for _ in range(16):
        put(img, x, y, P.LAB_GROUT)
        put(img, x + 1, y, shade(P.LAB_FLOOR, 0.75))
        x += rng.choice((0, 1, 1, -1))
        y += 1
        x = max(ox + 1, min(ox + T - 2, x))
        if y >= oy + T - 1:
            break


def lab_moss(img, ox, oy, seed):
    """Musgo e trepadeira saindo pelo rejunte."""
    lab_plate(img, ox, oy, seed)
    rng = random.Random(seed)
    for y in range(oy, oy + T):
        for x in range(ox, ox + T):
            edge = (x - ox) < 2 or (y - oy) < 2
            if (edge and rng.random() < 0.55) or rng.random() < 0.12:
                put(img, x, y, rng.choice([P.VINE, P.VINE_DARK, P.VINE_DARK]))
    for _ in range(4):
        x, y = ox + rng.randint(2, 13), oy + rng.randint(2, 13)
        put(img, x, y, P.VINE_LIGHT)
        put(img, x + 1, y, P.VINE)


def lab_roots(img, ox, oy, seed):
    """Mato furando o piso: tufos verdes e raizes."""
    lab_cracked(img, ox, oy, seed)
    rng = random.Random(seed + 1)
    for _ in range(3):
        cx, cy = ox + rng.randint(3, 12), oy + rng.randint(5, 13)
        for i in range(-2, 3):
            h = 3 - abs(i) + rng.randint(0, 1)
            for k in range(h):
                put(img, cx + i, cy - k, P.VINE_LIGHT if k == h - 1 else P.VINE)
        put(img, cx, cy + 1, P.ROOT)
        put(img, cx + 1, cy + 1, P.ROOT)


def lab_dark(img, ox, oy, seed):
    lab_plate(img, ox, oy, seed, base=P.LAB_DARK)
    hline(img, ox + 1, ox + T, oy + 1, shade(P.LAB_DARK, 1.25))


def chalk_square(img, ox, oy, seed, digit):
    """Amarelinha riscada a giz: "como quem repete uma brincadeira antiga"."""
    lab_plate(img, ox, oy, seed, scuff=True)
    rng = random.Random(seed)
    for i in range(2, 14):
        if rng.random() < 0.9:
            put(img, ox + i, oy + 2, P.CHALK)
            put(img, ox + i, oy + 13, P.CHALK_DIM)
        if rng.random() < 0.9:
            put(img, ox + 2, oy + i, P.CHALK)
            put(img, ox + 13, oy + i, P.CHALK_DIM)
    glyphs = {
        1: ["..x", ".xx", "..x", "..x", ".xxx"],
        2: ["xx.", "..x", ".x.", "x..", "xxx"],
        3: ["xx.", "..x", ".x.", "..x", "xx."],
        4: ["x.x", "x.x", "xxx", "..x", "..x"],
    }
    for gy, row in enumerate(glyphs[digit]):
        for gx, ch in enumerate(row):
            if ch == "x":
                put(img, ox + 6 + gx, oy + 5 + gy, P.CHALK)


def worn_rug(img, ox, oy, seed):
    """Tapete puido do dormitorio (azul desbotado com faixa)."""
    rng = random.Random(seed)
    base = (82, 90, 112)
    _noise(img, ox, oy, base, [shade(base, 0.88), shade(base, 1.1)], 0.28, rng)
    hline(img, ox, ox + T, oy + 3, P.CRAYON_YELLOW)
    hline(img, ox, ox + T, oy + 12, P.CRAYON_YELLOW)
    for _ in range(6):
        put(img, ox + rng.randint(0, 15), oy + rng.randint(0, 15), P.LAB_FLOOR)


def threshold(img, ox, oy, seed):
    """Soleira de porta com faixa de perigo apagada."""
    lab_dark(img, ox, oy, seed)
    for x in range(T):
        for y in range(5, 11):
            if ((x + y) // 3) % 2 == 0:
                put(img, ox + x, oy + y, mix(P.HAZARD, P.LAB_DARK, 0.45))
            else:
                put(img, ox + x, oy + y, shade(P.LAB_DARK, 0.85))


def stained_plate(img, ox, oy, seed):
    """Placa manchada (umidade): mancha irregular, discreta."""
    lab_plate(img, ox, oy, seed)
    rng = random.Random(seed)
    for _ in range(40):
        x = int(rng.gauss(ox + 8, 2.6))
        y = int(rng.gauss(oy + 9, 1.8))
        if ox + 2 <= x < ox + T - 2 and oy + 2 <= y < oy + T - 2:
            put(img, x, y, shade(P.LAB_FLOOR, rng.choice((0.86, 0.9, 0.93))))


def lab_wall_top(img, ox, oy, seed):
    rng = random.Random(seed)
    _noise(img, ox, oy, P.LAB_WALL_TOP, [P.LAB_WALL_TOP_EDGE, shade(P.LAB_WALL_TOP, 0.85)], 0.12, rng)


def lab_wall_face(img, ox, oy, seed, kind="plain"):
    """Painel de parede: chapa verde com junta, borda clara em cima e sombra embaixo."""
    rng = random.Random(seed)
    _noise(img, ox, oy, P.LAB_WALL, [shade(P.LAB_WALL, 0.95), shade(P.LAB_WALL, 1.05)], 0.12, rng)
    hline(img, ox, ox + T, oy, P.LAB_WALL_LIGHT)
    hline(img, ox, ox + T, oy + 1, shade(P.LAB_WALL_LIGHT, 0.9))
    hline(img, ox, ox + T, oy + T - 2, P.LAB_WALL_DARK)
    hline(img, ox, ox + T, oy + T - 1, P.WALL_SHADOW)
    seam = ox + (0 if seed % 2 == 0 else 8)
    vline(img, seam, oy + 2, oy + T - 2, P.LAB_WALL_DARK)
    vline(img, seam + 1, oy + 2, oy + T - 2, shade(P.LAB_WALL_LIGHT, 0.85))
    if kind == "bolts":
        for x in (ox + 3, ox + 12):
            put(img, x, oy + 4, P.LAB_RIVET)
            put(img, x, oy + 11, P.LAB_RIVET)
    elif kind == "pipe":
        hline(img, ox, ox + T, oy + 6, P.DOOR_METAL_DARK)
        hline(img, ox, ox + T, oy + 7, P.DOOR_METAL)
        hline(img, ox, ox + T, oy + 8, P.DOOR_METAL_LIGHT)
        hline(img, ox, ox + T, oy + 9, P.DOOR_METAL_DARK)
        put(img, ox + 10, oy + 6, P.DOOR_METAL_LIGHT)
        put(img, ox + 10, oy + 9, P.DOOR_METAL_LIGHT)
    elif kind == "damaged":
        x, y = ox + rng.randint(4, 10), oy + 2
        for _ in range(12):
            put(img, x, y, P.WALL_SHADOW)
            x += rng.choice((-1, 0, 1))
            y += 1
            if y >= oy + T - 2:
                break
        for _ in range(6):
            put(img, ox + rng.randint(1, 14), oy + rng.randint(9, 13), P.VINE_DARK)
    elif kind == "vent":
        rect(img, ox + 4, oy + 5, ox + 12, oy + 11, P.LAB_WALL_DARK)
        for y in range(oy + 6, oy + 11, 2):
            hline(img, ox + 5, ox + 11, y, P.WALL_SHADOW)


def lab_doorway(img, ox, oy, seed):
    """Vao de passagem ("arco" do tema): moldura de metal e escuro la dentro."""
    lab_wall_face(img, ox, oy, seed)
    rect(img, ox + 2, oy + 3, ox + 14, oy + T, P.DOOR_METAL_DARK)
    rect(img, ox + 3, oy + 4, ox + 13, oy + T, (14, 18, 18))
    hline(img, ox + 2, ox + 14, oy + 3, P.DOOR_METAL_LIGHT)


def lab_atlas():
    """Atlas 8x3 do laboratorio."""
    img = canvas(8 * T, 3 * T)
    lab_plate(img, 0 * T, 0, 81)
    lab_plate(img, 1 * T, 0, 82, scuff=True)
    lab_cracked(img, 2 * T, 0, 83)
    lab_moss(img, 3 * T, 0, 84)
    lab_roots(img, 4 * T, 0, 85)
    lab_dark(img, 5 * T, 0, 86)
    chalk_square(img, 6 * T, 0, 87, 1)
    chalk_square(img, 7 * T, 0, 88, 3)
    lab_wall_top(img, 0 * T, T, 91)
    lab_wall_face(img, 1 * T, T, 92)
    lab_wall_face(img, 2 * T, T, 93, "bolts")
    lab_wall_face(img, 3 * T, T, 94, "pipe")
    lab_wall_face(img, 4 * T, T, 95, "damaged")
    lab_doorway(img, 5 * T, T, 96)
    # (6,1) = barreira invisivel (transparente, so colisao)
    lab_wall_face(img, 7 * T, T, 98, "vent")
    worn_rug(img, 0 * T, 2 * T, 101)
    threshold(img, 1 * T, 2 * T, 102)
    stained_plate(img, 2 * T, 2 * T, 103)
    chalk_square(img, 3 * T, 2 * T, 104, 2)
    chalk_square(img, 4 * T, 2 * T, 105, 4)
    return img


# =============================================================================
# Detalhes de parede (16x16, desenhados por cima da face da parede)
# =============================================================================
def wall_tally():
    """Riscos de giz em grupos de cinco. Milhares."""
    img = canvas(16, 16)
    for y0, x0 in ((2, 1), (9, 4)):
        for i in range(4):
            vline(img, x0 + i * 2, y0, y0 + 5, P.CHALK if i % 2 == 0 else P.CHALK_DIM)
        for i in range(9):  # o quinto risco atravessa os quatro
            put(img, x0 - 1 + i, y0 + 4 - i // 2, P.CHALK)
        if x0 + 10 < 15:
            vline(img, x0 + 10, y0, y0 + 5, P.CHALK_DIM)
            vline(img, x0 + 12, y0, y0 + 5, P.CHALK)
    return img


def wall_drawing():
    """Desenho infantil colado na parede: a mulher de jaleco e as criancas de maos dadas.
    Os olhos das criancas estao pintados de branco. Os da mulher, nao."""
    img = canvas(16, 16)
    rect(img, 1, 2, 15, 14, P.PAPER)
    put(img, 1, 2, P.CHALK_DIM)
    put(img, 14, 2, P.CHALK_DIM)
    # a mulher (cabelo castanho, jaleco branco)
    rect(img, 3, 4, 6, 6, P.GOV_HAIR)
    put(img, 4, 5, P.GOV_EYE)
    rect(img, 3, 6, 6, 11, P.CHALK)
    vline(img, 2, 7, 10, P.CHALK_DIM)
    # criancas de maos dadas
    for i, color in enumerate((P.CRAYON_RED, P.CRAYON_BLUE, P.CRAYON_YELLOW)):
        x = 7 + i * 3
        put(img, x, 7, P.CHILD_HAIR)
        put(img, x + 1, 7, P.CHILD_HAIR)
        put(img, x, 8, P.WHITE_EYE)
        put(img, x + 1, 8, P.WHITE_EYE)
        vline(img, x, 9, 12, color)
        vline(img, x + 1, 9, 12, color)
        put(img, x + 2, 9, P.CHILD_SKIN_SHADOW)  # maos dadas
    put(img, 6, 9, P.CHILD_SKIN_SHADOW)
    hline(img, 2, 14, 12, P.VINE)  # chao de giz verde
    return img


def wall_lamp():
    """Faixa de luz verde da parede (como na referencia)."""
    img = canvas(16, 16)
    rect(img, 1, 4, 15, 9, P.LAB_WALL_DARK)
    rect(img, 2, 5, 14, 8, P.SCREEN_GREEN)
    hline(img, 3, 13, 5, mix(P.SCREEN_GREEN, (255, 255, 255), 0.5))
    return img


def wall_vines():
    """Trepadeira descendo pela parede."""
    img = canvas(16, 16)
    rng = random.Random(11)
    for x0 in (3, 9, 13):
        x = x0
        length = rng.randint(9, 15)
        for y in range(0, length):
            put(img, x, y, P.VINE_DARK)
            if rng.random() < 0.35:
                side = rng.choice((-1, 1))
                put(img, x + side, y, P.VINE)
                put(img, x + side * 2, y - 1, P.VINE_LIGHT)
            if rng.random() < 0.25:
                x += rng.choice((-1, 1))
    return img


# =============================================================================
# Objetos do laboratorio
# =============================================================================
CAPSULE_KEY = {"a": P.CAPSULE, "d": P.CAPSULE_DARK, "l": P.CAPSULE_LIGHT, "g": P.GLASS, "s": P.GLASS_SHINE,
               "G": P.SCREEN_GREEN, "k": P.STEEL_DEEP, "R": P.PANEL_RED, "c": P.CAPSULE_DARK}
CAPSULE_BASE = [
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


def _capsule_frame(grid):
    frame = canvas(32, 24)
    paste(frame, from_grid(grid, CAPSULE_KEY, outline=O), 2, 6)
    return frame


def capsule_occupied():
    """Capsula fechada com alguem dentro: um vulto palido atras do vidro escuro."""
    frame = _capsule_frame(CAPSULE_BASE)
    figure = mix(P.GLASS, P.CHILD_SKIN, 0.45)
    cloth = mix(P.GLASS, P.TUNIC, 0.35)
    ellipse(frame, 9.5, 13.5, 2.6, 2.2, figure)  # cabeca
    put(frame, 10, 13, mix(P.GLASS, P.WHITE_EYE, 0.7))
    rect(frame, 12, 12, 24, 16, cloth)  # corpo deitado
    rect(frame, 24, 13, 26, 15, mix(P.GLASS, P.CHILD_SKIN, 0.3))
    for x in (6, 7, 8):  # brilho do vidro por cima
        put(frame, x + 2, x + 3, P.GLASS_SHINE)
    return frame


def capsule_empty():
    """Capsula vazia, tampa de vidro erguida: o colchao gasto a mostra."""
    grid = [row for row in CAPSULE_BASE]
    frame = canvas(32, 24)
    body = [r.replace("g", "c").replace("s", "c") for r in grid]
    paste(frame, from_grid(body, CAPSULE_KEY, outline=O), 2, 6)
    rect(frame, 7, 10, 25, 16, P.SHEET_SHADOW)  # colchao
    ellipse(frame, 8.5, 12.5, 2, 1.6, P.SHEET)  # travesseiro
    lid = [
        ".ssssssssssssssssssss.",
        "sggggggggggggggggggggs",
        "sggsggggggggggggggggs.",
    ]
    lid_img = from_grid(lid, {"s": P.GLASS_SHINE, "g": P.GLASS}, outline=O)
    paste(frame, lid_img, 4, 1)
    return frame


def capsule_body():
    """A Câmara em PEÇAS (v0.28, animação de entrar/sair): o corpo aberto,
    com o colchão à mostra e SEM a tampa. A tampa é outro sprite por cima
    (capsule_lid), assim ela sobe e desce e o herói aparece deitado entre os dois."""
    frame = canvas(32, 24)
    body = [r.replace("g", "c").replace("s", "c") for r in CAPSULE_BASE]
    paste(frame, from_grid(body, CAPSULE_KEY, outline=O), 2, 6)
    rect(frame, 7, 10, 25, 16, P.SHEET_SHADOW)  # colchão
    ellipse(frame, 8.5, 12.5, 2, 1.6, P.SHEET)  # travesseiro
    return frame


def capsule_lid():
    """A tampa de vidro (mesmo quadro 32x24 do corpo: fechada, encaixa no lugar).
    Vidro escuro meio transparente (dá para ver quem dorme), aro claro e o brilho."""
    frame = canvas(32, 24)
    glass = (26, 37, 43, 175)  # o vidro escuro da Câmara (P.GLASS aqui no Prólogo é o claro)
    for y in range(9, 17):
        for x in range(6, 26):
            frame.putpixel((x, y), glass)
    for x in range(5, 27):  # aro de cima e de baixo
        frame.putpixel((x, 8), (*P.CAPSULE_LIGHT[:3], 255))
        frame.putpixel((x, 17), (*P.CAPSULE_DARK[:3], 255))
    for y in range(9, 17):
        frame.putpixel((5, y), (*P.CAPSULE_LIGHT[:3], 255))
        frame.putpixel((26, y), (*P.CAPSULE_DARK[:3], 255))
    for k in range(4):  # brilho na diagonal
        frame.putpixel((8 + k, 10 + k), (120, 150, 160, 230))
    frame.putpixel((24, 15), (120, 150, 160, 230))
    return frame


def capsule_broken():
    """Capsula quebrada: vidro estilhacado, buracos e cacos no chao."""
    frame = _capsule_frame(CAPSULE_BASE)
    rng = random.Random(21)
    # buracos no vidro (veem-se o colchao)
    for cx, cy, rx, ry in ((12, 12, 3.5, 2.5), (20, 14, 2.6, 2)):
        ellipse(frame, cx, cy, rx, ry, P.SHEET_SHADOW)
    # rachaduras irradiando
    for cx, cy in ((12, 12), (20, 14)):
        for a in range(6):
            ang = a / 6 * 6.283 + rng.uniform(-0.3, 0.3)
            x, y = float(cx), float(cy)
            for _ in range(rng.randint(4, 7)):
                x += math.cos(ang)
                y += math.sin(ang) * 0.6
                if 5 <= x <= 26 and 9 <= y <= 16:
                    put(frame, int(x), int(y), P.GLASS_SHINE)
    for _ in range(9):  # cacos no chao
        put(frame, rng.randint(2, 29), rng.randint(20, 23), P.GLASS_SHINE)
    return frame


def terminal():
    """Terminal com a tela verde: uma lista de nomes e um numero de tentativas."""
    frame = canvas(16, 24)
    key = {"m": P.DOOR_METAL, "M": P.DOOR_METAL_LIGHT, "d": P.DOOR_METAL_DARK, "g": P.SCREEN_GREEN,
           "G": P.LAB_LIGHT_DIM, "k": (16, 24, 22)}
    grid = [
        "MMMMMMMMMMMM",
        "mkkkkkkkkkkd",
        "mkggGggGgkkd",
        "mkGkggGkkkkd",
        "mkggkGgkgkkd",
        "mkGggkkgGkkd",
        "mkkkkkkkkkkd",
        "ddddddddddd.",
        "....mmmm....",
        "..MMMMMMMM..",
        ".mmmmmmmmmmd",
        ".dmMmMmMmMdd",
        ".dddddddddd.",
    ]
    paste(frame, from_grid(grid, key, outline=O), 1, 8)
    return frame


def cot():
    """Caminha de crianca (vista de cima): lencol dobrado com cuidado."""
    frame = canvas(16, 24)
    key = {"f": P.DOOR_METAL_DARK, "F": P.DOOR_METAL, "w": P.SHEET, "v": P.SHEET_SHADOW, "p": P.PLATE,
           "b": (96, 104, 128), "B": (74, 80, 102)}
    grid = [
        "FFFFFFFFFF",
        "fppppppppf",
        "fppppppppf",
        "fwwwwwwwwf",
        "fwwwwwwwvf",
        "fbbbbbbbbf",
        "fBbbbbbbBf",
        "fbbbbbbbbf",
        "fbbbbbbbbf",
        "fBbbbbbbBf",
        "fbbbbbbbbf",
        "fbbbbbbbbf",
        "ffffffffff",
        "f........f",
    ]
    paste(frame, from_grid(grid, key, outline=O), 2, 7)
    return frame


def toys():
    """Espadas de madeira gastas, uma bola e blocos."""
    frame = canvas(16, 16)
    for i in range(7):
        put(frame, 3 + i, 12 - i, P.WOOD_SWORD)
        put(frame, 4 + i, 12 - i, P.WOOD_SWORD_DARK)
        put(frame, 12 - i, 12 - i, P.WOOD_SWORD)
        put(frame, 13 - i, 12 - i, P.WOOD_SWORD_DARK)
    ellipse(frame, 4, 13, 2, 2, P.CRAYON_RED)
    put(frame, 3, 12, (240, 160, 150))
    rect(frame, 11, 12, 14, 15, P.CRAYON_BLUE)
    rect(frame, 12, 10, 15, 12, P.CRAYON_YELLOW)
    return frame


def plant():
    """Planta viva demais, furando o piso."""
    frame = canvas(16, 16)
    rng = random.Random(17)
    for _ in range(26):
        a = rng.uniform(-2.6, -0.5)
        r = rng.uniform(2, 7)
        x = 8 + math.cos(a) * r
        y = 13 + math.sin(a) * r * 1.1
        put(frame, int(x), int(y), rng.choice([P.VINE, P.VINE_LIGHT, P.VINE_DARK]))
        put(frame, int(x) + 1, int(y), P.VINE_DARK)
    for x in range(5, 12):
        put(frame, x, 14, P.ROOT)
    put(frame, 8, 6, P.CRAYON_YELLOW)  # uma flor
    return frame


def cables():
    """Cabos grossos pelo chao (sem colisao)."""
    frame = canvas(16, 16)
    for i, (y0, amp) in enumerate(((5, 2.0), (10, 1.5))):
        for x in range(16):
            y = int(y0 + math.sin(x * 0.5 + i) * amp)
            put(frame, x, y, (34, 36, 40))
            put(frame, x, y + 1, (20, 22, 26))
    rect(frame, 6, 8, 10, 12, P.DOOR_METAL_DARK)
    put(frame, 7, 9, P.SCREEN_GREEN)
    return frame


def long_table():
    """Mesa comprida do refeitorio, vista de cima: a cadeira da Governanta na
    cabeceira (em cima), cadeirinhas dos lados e pratos postos. Nenhum foi usado."""
    w, h = 40, 92
    frame = canvas(w, h)
    # cadeira da cabeceira (adulta)
    rect(frame, 13, 2, 27, 6, P.WOOD_DARK)
    rect(frame, 14, 3, 26, 5, P.WOOD)
    rect(frame, 14, 6, 26, 13, P.WOOD)
    hline(frame, 14, 26, 12, P.WOOD_DARK)
    # tampo
    rect(frame, 8, 12, 32, 84, P.TABLE_DARK)
    rect(frame, 9, 12, 31, 82, P.TABLE_TOP)
    hline(frame, 9, 31, 12, P.TABLE_LIGHT)
    vline(frame, 9, 12, 82, P.TABLE_LIGHT)
    rect(frame, 8, 82, 32, 86, P.TABLE_DARK)  # espessura (vista 3/4)
    hline(frame, 8, 32, 86, P.WALL_SHADOW)
    for x in (9, 30):  # pes
        rect(frame, x, 86, x + 2, 90, P.TABLE_DARK)
    # cadeirinhas (3 de cada lado) e pratos
    for i in range(3):
        y = 22 + i * 22
        for side in (-1, 1):
            cx = 20 + side * 17
            rect(frame, cx - 3, y - 3, cx + 4, y + 4, P.WOOD)
            if side < 0:
                vline(frame, cx - 3, y - 4, y + 5, P.WOOD_DARK)
            else:
                vline(frame, cx + 3, y - 4, y + 5, P.WOOD_DARK)
            hline(frame, cx - 3, cx + 4, y + 4, P.WOOD_DARK)
            px = 20 + side * 6
            ellipse(frame, px, y, 3, 2.2, P.PLATE)
            ellipse(frame, px, y, 1.6, 1.1, shade(P.PLATE, 0.88))
            put(frame, px + side * 4, y - 2, P.DOOR_METAL_LIGHT)  # copo
    # prato da cabeceira
    ellipse(frame, 20, 17, 3.5, 2.4, P.PLATE)
    return _outlined(frame)


def _outlined(img):
    from pixel import add_outline
    return add_outline(img, O)


def lab_door_frames():
    """Porta de saida (2 celulas): [fechada/verde, trancada/vermelha, aberta]."""
    frames = []
    for state in ("closed", "locked", "open"):
        f = canvas(32, 24)
        rect(f, 0, 2, 32, 24, P.DOOR_METAL_DARK)  # moldura
        rect(f, 1, 3, 31, 24, P.DOOR_METAL_LIGHT)
        rect(f, 3, 5, 29, 24, (14, 18, 18))
        hline(f, 0, 32, 2, O)
        if state != "open":
            for x0, x1 in ((3, 16), (16, 29)):
                rect(f, x0, 5, x1, 24, P.DOOR_METAL)
                vline(f, x0, 5, 24, P.DOOR_METAL_LIGHT)
                vline(f, x1 - 1, 5, 24, P.DOOR_METAL_DARK)
                hline(f, x0, x1, 11, P.DOOR_METAL_DARK)
                hline(f, x0, x1, 18, P.DOOR_METAL_DARK)
            vline(f, 15, 5, 24, O)
            vline(f, 16, 5, 24, P.DOOR_METAL_DARK)
        else:
            for x0, x1 in ((3, 6), (26, 29)):  # folhas recolhidas nas laterais
                rect(f, x0, 5, x1, 24, P.DOOR_METAL)
            rect(f, 6, 5, 26, 24, (20, 26, 26))
            hline(f, 6, 26, 23, P.LAB_DARK)
        light = P.PANEL_RED if state == "locked" else P.SCREEN_GREEN
        rect(f, 26, 0, 31, 4, P.DOOR_METAL_DARK)
        rect(f, 27, 1, 30, 3, light)
        frames.append(f)
    return frames


def lab_cracks(w: int = 40, h: int = 26):
    """O chao de metal rachando (aviso antes de sumir)."""
    img = canvas(w, h)
    rng = random.Random(29)
    cx, cy = w / 2, h / 2
    rx, ry = w / 2 - 3, h / 2 - 3
    for i in range(64):
        a = i / 64 * 6.283
        if i % 5 == 4:
            continue
        put(img, int(cx + math.cos(a) * rx), int(cy + math.sin(a) * ry), P.CHALK if i % 2 else P.LAB_GROUT)
    for i in range(7):
        a = i / 7 * 6.283 + rng.uniform(-0.3, 0.3)
        x, y = cx, cy
        for s in range(int(rx * rng.uniform(0.6, 0.95))):
            x += math.cos(a)
            y += math.sin(a) * (ry / rx)
            a += rng.uniform(-0.35, 0.35)
            put(img, int(x), int(y), (14, 18, 18) if s % 3 else P.CHALK)
    return img


def lab_hole(w: int = 40, h: int = 26):
    """O chao que some: placas partidas na borda e escuro sem fundo."""
    img = canvas(w, h)
    rng = random.Random(31)
    cx, cy = w / 2, h / 2
    rx, ry = w / 2 - 2, h / 2 - 2
    for y in range(h):
        for x in range(w):
            dx, dy = (x + 0.5 - cx) / (rx + 2), (y + 0.5 - cy) / (ry + 2)
            d = dx * dx + dy * dy
            if 0.76 < d <= 1.0 + rng.uniform(-0.06, 0.06):
                put(img, x, y, rng.choice([P.LAB_FLOOR, P.LAB_GROUT, P.LAB_FLOOR_ALT, P.DOOR_METAL_DARK]))
    for y in range(h):
        for x in range(w):
            dx, dy = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry
            d = dx * dx + dy * dy
            if d > 0.78:
                continue
            t = (y - (cy - ry)) / (2 * ry)
            depth = 1.0 - d
            color = mix((24, 30, 30), (2, 2, 4), min(1.0, depth * 1.6 + t * 0.3))
            put(img, x, y, color)
    for _ in range(5):  # fiapos brancos la no fundo
        put(img, int(cx + rng.uniform(-6, 6)), int(cy + rng.uniform(-2, 4)), (200, 210, 220))
    return img


# =============================================================================
# As criancas (24x24, olhando para a DIREITA; o jogo espelha)
# =============================================================================
CHILD_BODY = [
    "...hhhhh....",
    ".hhhjjjhh...",
    "hhhjjhhhhhh.",
    "hhhhhhhhhhhh",
    "hhhhhhhhhshh",
    "hhhhhhssssss",
    "hhhhhseesees",
    "hhhhhseesees",
    ".hhhhsssssss",
    "..hhhzsssssz",
    "....wwwwww..",
    "...swwwwwws.",
    "...swwwwwvs.",
    "....vvvvvv..",
    "....wwwwwv..",
]
CHILD_B_BODY = [
    "..h.hh.hh...",
    ".hhhhhhhhh..",
    "hhhjjjhhhhh.",
    "hhjjhhhhhhhh",
    "hhhhhhhhhhhh",
    "hhhhhhshssss",
    "hhhhhseesees",
    "hhhhhseesees",
    ".hhhhsssssss",
    "..hhhzsssssz",
    "....wwwwww..",
    "...swwwwwws.",
    "...swwwwwvs.",
    "....vvvvvv..",
    "....wwwwwv..",
]
CHILD_LEGS = [
    ["....ss.ss...", "....ss.ss...", "....zz.zz..."],
    ["....ss..ss..", "...ss....ss.", "...zz....zz."],
    ["....ss.ss...", "....ss.ss...", "....zz.zz..."],
    [".....ssss...", ".....ssss...", ".....zzzz..."],
]
TEEN_BODY = [
    "...hhhhhh....",
    "..hhjjjjhh...",
    ".hhjjhhhhhhh.",
    ".hhhhhhhhhhhh",
    "hhhhhhhhhhshh",
    "hhhhhhhssssss",
    "hhhhhhseesees",
    "hhhhhhseesees",
    ".hhhhhsssssss",
    "..hhhhzsssssz",
    ".....wwwwwww.",
    "....swwwwwwws",
    "....swwwwwwvs",
    "....swwwwwwv.",
    ".....vvvvvv..",
    ".....wwwwwv..",
    ".....wwwwwv..",
]
TEEN_LEGS = [
    [".....ss.ss...", ".....ss.ss...", ".....ss.ss...", ".....zz.zz..."],
    [".....ss..ss..", "....ss....ss.", "....ss....ss.", "....zz....zz."],
    [".....ss.ss...", ".....ss.ss...", ".....ss.ss...", ".....zz.zz..."],
    ["......ssss...", "......ssss...", "......ssss...", "......zzzz..."],
]


def _child_key(hair, hair_light):
    return {"h": hair, "j": hair_light, "s": P.CHILD_SKIN, "z": P.CHILD_SKIN_SHADOW, "e": P.WHITE_EYE,
            "w": P.TUNIC, "v": P.TUNIC_SHADOW}


def _frames(body, legs_list, key, size=(24, 24)):
    frames = []
    for legs in legs_list:
        sprite = from_grid(body + legs, key, outline=O)
        frame = canvas(*size)
        # pes na linha 22 (igual ao heroi e ao soldado)
        paste(frame, sprite, (size[0] - sprite.width) // 2, size[1] - 1 - sprite.height)
        frames.append(frame)
    return frames


def child_frames(variant: str):
    """[parado, passada, parado, cruzando] — crianca pequena (a/b) ou adolescente."""
    if variant == "a":
        return _frames(CHILD_BODY, CHILD_LEGS, _child_key(P.CHILD_HAIR, P.CHILD_HAIR_LIGHT))
    if variant == "b":
        return _frames(CHILD_B_BODY, CHILD_LEGS, _child_key(P.CHILD_HAIR_B, P.CHILD_HAIR_B_LIGHT))
    return _frames(TEEN_BODY, TEEN_LEGS, _child_key(P.TEEN_HAIR, P.TEEN_HAIR_LIGHT))


def wooden_sword():
    """Espada de madeira gasta (empunhadura em x=1)."""
    grid = [
        ".g.......",
        "fgBBBBBBb",
        ".g.......",
    ]
    return from_grid(grid, {"f": P.WOOD_DARK, "g": P.WOOD, "B": P.WOOD_SWORD, "b": P.WOOD_SWORD_DARK}, outline=O)


def spared_child_frames():
    """A Crianca Poupada, sentada no chao do Teatro, desenhando a giz (2 quadros)."""
    key = _child_key(P.CHILD_HAIR, P.CHILD_HAIR_LIGHT)
    key.update({"c": P.CHALK})
    head = CHILD_BODY[:10]
    seated = [
        "....wwwwww..",
        "...swwwwwws.",
        "...wwwwwwvw.",
        "..sswwwwwwss",
        "..zzzsssszz.",
    ]
    frames = []
    for hand in (0, 1):
        frame = canvas(24, 24)
        sprite = from_grid(head + seated, key, outline=O)
        paste(frame, sprite, 4, 22 - sprite.height + 1)
        # o giz na mao e os riscos no chao
        hx = 18 + hand * 2
        put(frame, hx, 19, P.CHILD_SKIN)
        put(frame, hx + 1, 19, P.CHALK)
        for x in range(15, 23):
            if (x + hand) % 3:
                put(frame, x, 22, P.CHALK)
        put(frame, 21, 21, P.CHALK)
        frames.append(frame)
    return frames


# =============================================================================
# A Governanta
# =============================================================================
GOV_KEY = {"h": P.GOV_HAIR, "j": P.GOV_HAIR_LIGHT, "x": P.GOV_HAIR_DARK, "s": P.GOV_SKIN, "z": P.GOV_SKIN_SHADOW,
           "e": P.GOV_EYE, "w": P.GOV_COAT, "v": P.GOV_COAT_SHADOW, "d": P.GOV_DRESS, "D": P.GOV_DRESS_DARK,
           "b": P.BOOTS, "m": (120, 70, 70), "k": (24, 18, 20)}


def governess_seated(head_up: bool):
    """Sentada na cabeceira, de frente para quem chega. Cabeca baixa sobre os
    bracos (como na referencia) ou erguida, olhando — sem dizer nada."""
    if not head_up:
        grid = [
            "......jjjj......",
            ".....jhhhhj.....",
            ".....hhxxhh.....",
            "......hhhh......",
            "....hhhhhhhh....",
            "...hhjjjjjjhh...",
            "..hhjhhhhhhhhh..",
            "..hhhhhhhhhhhh..",
            ".vwwhhhhhhhhwwv.",
            "vwwwwhhhhhhwwwwv",
            "vwwwwwhhhhwwwwwv",
            "wwwwwwwwwwwwwwww",
            "wwwwwwwwwwwwwwww",
            "wwvvwwwwwwwwvvww",
            ".zsswwwwwwwwssz.",
        ]
    else:
        grid = [
            "......jjjj......",
            ".....jhhhhj.....",
            ".....hhxxhh.....",
            "....hhhhhhhh....",
            "...hhjjjjjjhh...",
            "..hhjsssssshhh..",
            "..hhsssssssshh..",
            "..hhskesskeshh..",
            "..hhszzsszzshh..",
            "..hhssssssssh...",
            "...hzssmmsszh...",
            ".vwwwzsssszwwwv.",
            "vwwwwwwwwwwwwwwv",
            "wwwwwwwwwwwwwwww",
            "wwvvwwwwwwwwvvww",
            ".zssw......wssz.",
        ]
    frame = canvas(32, 32)
    sprite = from_grid(grid, GOV_KEY, outline=O)
    paste(frame, sprite, (32 - sprite.width) // 2, 31 - sprite.height)
    return frame


GOV_BODY = [
    ".....xxxx.......",
    "....xhhhhx......",
    "....xhhhhx......",
    ".....hhhhhhh....",
    "...hhjjjjjhhh...",
    "..hhjjhhhhhhhh..",
    "..hhhhhhhhsssh..",
    "..hhhhhhhsssss..",
    "..hhhhhhssessz..",
    "..hhhhhhszzssz..",
    "...hhhhhsssmss..",
    "....hhhzssssz...",
    "......vwwwwv....",
    ".....vwwwwwwwv..",
    "....vwwwwwwwwwv.",
    "....wwwwwwwwwws.",
    "....wwwwwwwwwws.",
    "....vwwwdwwwwvs.",
    "....vwwwdwwwwv..",
    "....wwwwdwwwwv..",
    "....wwwwdwwwwv..",
    "....vwwwdwwwwv..",
    "....vwwddwwwvv..",
    "....vwwdddwwvv..",
    "....wwwdddwwwv..",
    ".....dddddddd...",
    ".....DdddddDD...",
]
GOV_LOOSE_HEAD = [
    "......xxx.......",
    "....xhhhhhx.....",
    "...xhhhhhhhx....",
    "..xhhjjjjjhhh...",
    "..hhjjhhhhhhhh..",
    ".xhhhhhhhhhhhh..",
    ".hhhhhhhhhhssh..",
    "xhhhhhhhhsssss..",
    "xhhhhhhhssessz..",
    "xhhhhhhhszzssz..",
    "xhhhhhhhsssmss..",
    "xxhhhhhzssssz...",
]
GOV_LEGS = [
    [".....dd..dd.....", ".....DD..DD.....", ".....bb..bbb...."],
    [".....dd...dd....", "....DD.....DD...", "....bb.....bbb.."],
    [".....dd..dd.....", ".....DD..DD.....", ".....bb..bbb...."],
    ["......dddd......", "......DDDD......", "......bbbbb....."],
]


GOV_WIDTH = 20  # todas as grades com a mesma largura: nada "pula" entre quadros


def _gov_body(loose: bool):
    body = list(GOV_BODY)
    if loose:
        body = GOV_LOOSE_HEAD + body[12:]
    return [row.ljust(GOV_WIDTH, ".") for row in body]


def _gov_special(body, kind, loose):
    rows = list(body)
    if kind == "hug":  # bracos abertos para a frente: o abraco que prende
        rows[13] = ".....vwwwwwwwvwww..."
        rows[14] = "....vwwwwwwwwwwwwss."
        rows[15] = "....wwwwwwwwwwwwwss."
    elif kind == "scream":  # olhos fechados, boca aberta
        if loose:
            rows[7] = "xhhhhhhhhsszzs.."
            rows[8] = "xhhhhhhhssssss.."
            rows[9] = "xhhhhhhhsskkss.."
            rows[10] = "xhhhhhhhsskkss.."
        else:
            rows[7] = "..hhhhhhhsszzs.."
            rows[8] = "..hhhhhhssssss.."
            rows[9] = "..hhhhhhsskkss.."
            rows[10] = "...hhhhhsskkss.."
        rows = [row.ljust(GOV_WIDTH, ".") for row in rows]
    return rows


def _gov_frame(grid):
    sprite = from_grid(grid, GOV_KEY, outline=O)
    frame = canvas(32, 40)
    paste(frame, sprite, (32 - sprite.width) // 2 + 2, 39 - sprite.height)
    return frame


def governess_frames(loose: bool):
    """[parado, passada, parado, cruzando, abraco, grito] — 32x40, olhando para a direita."""
    body = _gov_body(loose)
    legs_list = [[row.ljust(GOV_WIDTH, ".") for row in legs] for legs in GOV_LEGS]
    frames = [_gov_frame(body + legs) for legs in legs_list]
    for kind in ("hug", "scream"):
        frames.append(_gov_frame(_gov_special(body, kind, loose) + legs_list[0]))
    return frames


def governess_keys():
    """Molho de chaves numa corrente curta (empunhadura em x=1)."""
    grid = [
        "........kk....",
        "cc.cc.ckkkk...",
        ".cc.cc.kk.kK..",
        "........kKkkK.",
        ".........k..K.",
    ]
    return from_grid(grid, {"c": P.DOOR_METAL_LIGHT, "k": P.KEYS, "K": P.KEYS_DARK}, outline=O)


# =============================================================================
# Folhas (helpers para o gen_art)
# =============================================================================
def child_sheet(variant):
    return hstrip(child_frames(variant))


def governess_sheet(loose):
    return hstrip(governess_frames(loose))
