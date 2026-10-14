"""Inimigos da Cidade Estilhacada (alem do Soldado Remendado).

Biblia:
  - Cao de Guerra Mecanico: rapido, morde e recua. "Equipamento militar que ainda obedece."
  - Atirador de Telhado: tiro lento e telegrafado de longe. "Mantem posicao ha decadas."
  - Civil Cinzento: passivo; so ataca se for atacado ou se o jogador passar correndo.
    "Moradores que Aldir nao conseguiu salvar."
Todos olham para a DIREITA (o jogo espelha), quadros de 24x24 com os pes na linha 22.
"""
from __future__ import annotations

import palette as P
from pixel import canvas, from_grid, paste

O = P.OUTLINE


def _frames(body, legs_list, key, size=(24, 24)):
    frames = []
    for legs in legs_list:
        sprite = from_grid(body + legs, key, outline=O)
        frame = canvas(*size)
        paste(frame, sprite, (size[0] - sprite.width) // 2, size[1] - 1 - sprite.height)
        frames.append(frame)
    return frames


# --- Cao de Guerra Mecanico -------------------------------------------------------
DOG_KEY = {"m": P.DOG_METAL, "M": P.DOG_METAL_LIGHT, "d": P.DOG_METAL_DARK, "r": P.DOG_EYE,
           "p": P.PATCH_A, "k": (30, 28, 30), "w": P.IRON_LIGHT}
DOG_BODY = [
    "..............MM...",
    ".............Mmmm..",
    "..d.........Mmrmmmw",
    "...d.MMMMMMMmmmmkkw",
    "....MmmmmmmpmmmmkM.",
    "...Mmmmmmmmmmmmdd..",
    "...dmmmmmmmmmmmd...",
    "....dddddddddddd...",
]
DOG_LEGS = [
    ["....dd......dd.....", "....kk......kk....."],
    ["...dd........dd....", "..kk..........kk..."],
    ["....dd......dd.....", "....kk......kk....."],
    [".....dd....dd......", ".....kk....kk......"],
]


def dog_frames():
    """[parado, corrida, parado, corrida 2, MORDIDA (boca aberta)]"""
    frames = _frames(DOG_BODY, DOG_LEGS, DOG_KEY)
    bite = list(DOG_BODY)
    bite[3] = "...d.MMMMMMMmmmmk.."
    bite[4] = "....Mmmmmmmpmmmmkkw"
    bite[5] = "...Mmmmmmmmmmmmdd.w"
    frames += _frames(bite, [DOG_LEGS[1]], DOG_KEY)
    return frames


# --- Atirador de Telhado ----------------------------------------------------------
SNIPER_KEY = {"g": P.HELMET, "G": P.HELMET_LIGHT, "s": P.DEAD_SKIN, "z": P.DEAD_SKIN_SHADOW,
              "e": P.GLOW_EYE, "u": P.UNIFORM, "d": P.UNIFORM_DARK, "c": P.SNIPER_COAT,
              "C": P.SNIPER_COAT_DARK, "a": P.PATCH_A, "B": P.BOOTS, "q": P.UNIFORM_DARK, "v": P.VISOR}
SNIPER_BODY = [
    "....gggg......",
    "..gGGGGgg.....",
    ".gggggggggg...",
    "ggggggggggggg.",
    ".dsssvvvvvs...",
    ".dssssssssss..",
    "..dzsssssssz..",
    "..cccccccccc..",
    ".ccaccccccccc.",
    ".cccccccccccs.",
    ".cCccccccccc..",
    "..cCcccccccc..",
    "..cCCccccccC..",
]
SNIPER_LEGS = [
    ["....qq.qq.....", "....qq.qq.....", "....BB.BB....."],
    ["....qq..qq....", "...qq....qq...", "...BB....BB..."],
    ["....qq.qq.....", "....qq.qq.....", "....BB.BB....."],
    [".....qqqq.....", ".....qqqq.....", ".....BBBB....."],
]


def sniper_frames():
    return _frames(SNIPER_BODY, SNIPER_LEGS, SNIPER_KEY)


def rifle():
    """Fuzil comprido apontando para a DIREITA (empunhadura em x=2)."""
    grid = [
        "...........k.......",
        "wwwwkkkkkkkkkkkkkkk",
        "ww.k...............",
    ]
    return from_grid(grid, {"w": P.WOOD_DARK, "k": (48, 48, 52)}, outline=O)


def bullet():
    img = canvas(6, 6)
    for (x, y, c) in ((2, 2, P.FLAME_CORE), (3, 2, P.FLAME_CORE), (2, 3, P.FLAME_CORE), (3, 3, P.FLAME),
                      (1, 2, P.FLAME), (4, 3, P.FLAME_HOT), (2, 1, P.FLAME_HOT), (3, 4, P.FLAME_HOT)):
        img.putpixel((x, y), (*c[:3], 255))
    return img


# --- Civil Cinzento -----------------------------------------------------------------
CIVIL_KEY = {"h": P.CIVIL_HAIR, "s": P.CIVIL_SKIN, "z": P.CIVIL_SKIN_DARK, "e": P.CIVIL_EYE,
             "c": P.CIVIL_CLOTH, "C": P.CIVIL_CLOTH_DARK, "a": P.CIVIL_ASH, "p": P.CIVIL_CLOTH_DARK}
CIVIL_BODY = [
    "...hhhh.......",
    "..hhhhhhh.....",
    ".hhhhhhhhh....",
    ".hhhhhsssss...",
    ".hhhhseesss...",
    "..hhhszzsss...",
    "...hhzsssz....",
    "...ccccccc....",
    "..cccacccccs..",
    "..ccccccccas..",
    "..sccccccaCs..",
    "...cCcccaCC...",
    "...cCccccCC...",
    "...CCCCCCCC...",
]
CIVIL_LEGS = [
    ["....pp.pp.....", "....pp.pp.....", "....zz.zz....."],
    ["....pp..pp....", "...pp....pp...", "...zz....zz..."],
    ["....pp.pp.....", "....pp.pp.....", "....zz.zz....."],
    [".....pppp.....", ".....pppp.....", ".....zzzz....."],
]


def civil_frames():
    """[parado, passo, parado, passo 2, ATACANDO (bracos para frente)]"""
    frames = _frames(CIVIL_BODY, CIVIL_LEGS, CIVIL_KEY)
    grab = list(CIVIL_BODY)
    grab[8] = "..cccaccccccss"
    grab[9] = "..ccccccccacss"
    grab[10] = "...ccccccaC..."
    frames += _frames(grab, [CIVIL_LEGS[1]], CIVIL_KEY)
    return frames


# --- Mini-chefe: o Sargento Sem Pelotao ------------------------------------------------
SARGE_KEY = {"g": P.HELMET, "G": P.HELMET_LIGHT, "d": P.UNIFORM_DARK, "s": P.DEAD_SKIN, "z": P.DEAD_SKIN_SHADOW,
             "e": P.GLOW_EYE, "u": P.UNIFORM, "r": P.SARGE_RED, "R": P.SARGE_RED_DARK, "o": P.GOLD,
             "D": P.LEATHER, "q": P.UNIFORM_DARK, "B": P.BOOTS, "w": P.IRON_LIGHT, "m": (40, 30, 26)}
SARGE_BODY = [
    "...rrrrrr......",
    "..rRRRRRRrr....",
    ".ddddddddddd...",
    "ddddddddddddd..",
    ".ddssssssssss..",
    ".ddsssesssess..",
    ".ddsssssmmmss..",
    "..dzsssssssz...",
    "..uuuuuuuuuuu..",
    ".uuouuuuuuuuuw.",
    ".suuuuuuuuuuus.",
    ".suuuuuurrruus.",
    "..uDDDDDDDDDu..",
    "..uuuuuuuuuuu..",
    "..uuuuuuuuuuu..",
]
SARGE_LEGS = [
    [".....qq.qq.....", ".....qq.qq.....", ".....BB.BB....."],
    [".....qq..qq....", "....qq....qq...", "....BB....BB..."],
    [".....qq.qq.....", ".....qq.qq.....", ".....BB.BB....."],
    ["......qqqq.....", "......qqqq.....", "......BBBB....."],
]


def sargento_frames():
    """[parado, passo, parado, passo 2, APITANDO (apito na boca)]"""
    frames = _frames(SARGE_BODY, SARGE_LEGS, SARGE_KEY)
    whistle = list(SARGE_BODY)
    whistle[6] = ".ddssssssswww."
    whistle[7] = "..dzsssssssww."
    frames += _frames(whistle, [SARGE_LEGS[0]], SARGE_KEY)
    return frames


def sabre():
    grid = [
        "..o.........",
        "ddoBBBBBBBBb",
        "..o.........",
    ]
    return from_grid(grid, {"d": P.LEATHER, "o": P.GOLD, "B": P.BLADE, "b": P.BLADE_DARK}, outline=O)


# --- Mini-chefe: a Couraca Andante (32x32) ------------------------------------------------
# Olhando para a DIREITA: a frente e toda de chapa; as COSTAS (lado esquerdo)
# tem uma fresta aberta com o uniforme remendado aparecendo: o ponto fraco.
ARMOR_KEY2 = {"a": P.COURACA, "l": P.COURACA_LIGHT, "d": P.COURACA_DARK, "k": P.STEEL_DEEP,
              "e": P.DOG_EYE, "u": P.UNIFORM, "p": P.PATCH_C, "c": P.PATCH_A, "b": P.BOOTS, "r": P.RUBBLE_DARK}
ARMOR_BODY = [
    "........llllll......",
    "......llaaaaaall....",
    ".....laaaaaaaaaad...",
    ".....laaaaakkkkkd...",
    ".....laaaaakeeekd...",
    ".....daaaaakkkkkd...",
    "...lllaaaaaaaaaadd..",
    "..laaaaaaaaaaaaaaad.",
    ".laaaaaaaaaaaaaaaaad",
    ".upcuaaaaaaaaaaaaaad",
    ".ucpuaaaaaaaaaaaaaad",
    ".upuuaaaaaaaaaaaaaad",
    ".ucpuaaaaaaaaaaaadd.",
    "..dddaaaaaaaaaaaad..",
    "...daaaaaaaaaaaad...",
    "...daaaaaaaaaaaad...",
    "...ddddddddddddd....",
]
ARMOR_LEGS = [
    ["....aaad...aaad....", "....aaad...aaad....", "...bbbb....bbbb...."],
    ["...aaad.....aaad...", "..aaad.......aaad..", "..bbbb.......bbbb.."],
    ["....aaad...aaad....", "....aaad...aaad....", "...bbbb....bbbb...."],
    [".....aaadaaad......", ".....aaadaaad......", ".....bbbbbbbb......"],
]


def couraca_frames():
    return _frames(ARMOR_BODY, ARMOR_LEGS, ARMOR_KEY2, size=(32, 32))


def couraca_mace():
    """A clava de ferro (empunhadura em x=2)."""
    grid = [
        "...........kkk.",
        "ddddddddddkaaak",
        "ddddddddddkaaak",
        "...........kkk.",
    ]
    return from_grid(grid, {"d": P.LEATHER, "k": P.STEEL_DEEP, "a": P.IRON}, outline=O)
