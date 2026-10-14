"""Personagens em pixel art (todos olhando para a DIREITA; o jogo espelha).

Estilo chibi (cabeca grande), como as criancas da imagem do prologo e como
Soul Knight (uma das referencias da Biblia). Cada personagem e montado em
camadas: corpo (sem pernas) + variacao de pernas para o ciclo de caminhada.
O balanco (bob) e a respiracao sao feitos no Godot, por codigo — assim as
pecas de armadura da Helena ficam sempre alinhadas ao corpo.
"""
from __future__ import annotations

import palette as P
from pixel import canvas, from_grid, paste, ellipse, put, hline, vline, rect

O = P.OUTLINE

# ---------------------------------------------------------------------------
# Protagonista — 24x24
# ---------------------------------------------------------------------------
PLAYER_KEY = {
    "h": P.HAIR, "j": P.HAIR_LIGHT, "s": P.SKIN, "z": P.SKIN_SHADOW, "e": P.EYE,
    "w": P.TUNIC, "v": P.TUNIC_SHADOW, "c": P.SCARF, "n": P.SCARF_LIGHT,
    "b": P.LEATHER, "l": P.WRAPS,
}
PLAYER_BODY = [
    "...hhhhhh.....",
    "..hhjjjjhhh...",
    ".hhjjjhhhhhh..",
    ".hhhhhhhhhhhh.",
    "hhhhhhhhhhhhhh",
    "hhhhhhhhssshhh",
    "hhhhhhhsssssss",
    "hhhhhhssessses",
    "hhhhhhssessses",
    ".hhhhhssssssss",
    "..hhhhzsssssz.",
    "....cccccccc..",
    "...cnnccccccs.",
    "...swwwwwwwwz.",
    "...swwwwwwwv..",
    "....vbbbbbv...",
    "....wwwwwwv...",
]
LEGS_STAND = [
    ".....ll.ll....",
    ".....ll.ll....",
    ".....bb.bb....",
]
LEGS_STRIDE = [
    ".....ll..ll...",
    "....ll....ll..",
    "....bb....bb..",
]
LEGS_PASS = [
    "......llll....",
    "......llll....",
    "......bbbb....",
]


def _char_frame(size: tuple[int, int], body: list[str], legs: list[str], key: dict, offset: tuple[int, int]) -> object:
    frame = canvas(*size)
    sprite = from_grid(body + legs, key, outline=O)
    paste(frame, sprite, offset[0], offset[1])
    return frame


def player_frames() -> list:
    """[parado, passada, parado, cruzando] — 24x24, pes na linha 22."""
    legs = [LEGS_STAND, LEGS_STRIDE, LEGS_STAND, LEGS_PASS]
    return [_char_frame((24, 24), PLAYER_BODY, l, PLAYER_KEY, (4, 1)) for l in legs]


# ---------------------------------------------------------------------------
# Soldado Remendado — 24x24 (o escudo e o bastao sao sprites separados)
# ---------------------------------------------------------------------------
SOLDIER_KEY = {
    "g": P.HELMET, "G": P.HELMET_LIGHT, "d": P.UNIFORM_DARK, "s": P.DEAD_SKIN, "z": P.DEAD_SKIN_SHADOW,
    "e": P.GLOW_EYE, "u": P.UNIFORM, "a": P.PATCH_A, "p": P.PATCH_B, "c": P.PATCH_C,
    "D": P.LEATHER, "q": P.UNIFORM_DARK, "B": P.BOOTS,
}
SOLDIER_BODY = [
    "...gggggg.....",
    "..gGGGGggg....",
    ".gGGgggggggg..",
    ".gggggggggggg.",
    "gggggggggggggg",
    ".ddssssssssss.",
    ".ddsssesssess.",
    ".ddsssssssss..",
    "..dzssssssz...",
    "...uuuuuuuuu..",
    "..uaauuuuuuuu.",
    "..suuuuuppuus.",
    "..suucuuuuuus.",
    "...uDDDDDDDu..",
    "...uuuuuuuuu..",
]
SOLDIER_LEGS = [
    [".....qq.qq....", ".....qq.qq....", ".....BB.BB...."],
    [".....qq..qq...", "....qq....qq..", "....BB....BB.."],
    [".....qq.qq....", ".....qq.qq....", ".....BB.BB...."],
    ["......qqqq....", "......qqqq....", "......BBBB...."],
]


def soldier_frames() -> list:
    return [_char_frame((24, 24), SOLDIER_BODY, l, SOLDIER_KEY, (4, 3)) for l in SOLDIER_LEGS]


SHIELD_GRID = [
    ".LLLLLLL.",
    "LSSSSSSSL",
    "LSSSSSSSd",
    "LSvvvvvSd",
    "LSSSSSSSd",
    "LSSaSSSSd",
    "LSSSSSSSd",
    "LSSSSSpSd",
    "LSSSSSSSd",
    "LSSSSSSSd",
    ".dSSSSSd.",
    "..ddddd..",
]
SHIELD_KEY = {"L": P.SHIELD_LIGHT, "S": P.SHIELD, "d": P.SHIELD_DARK, "v": P.VISOR, "a": P.PATCH_A, "p": P.PATCH_C}


def soldier_shield() -> object:
    return from_grid(SHIELD_GRID, SHIELD_KEY, outline=O)


def soldier_baton() -> object:
    grid = [
        "gbbbbbbbbm",
        "gbbbbbbbbm",
    ]
    return from_grid(grid, {"g": P.LEATHER, "b": (52, 48, 46), "m": P.IRON_LIGHT}, outline=O)


# ---------------------------------------------------------------------------
# Helena Altiva — 32x32. Corpo base = "A Mulher Sem Armadura" (fase 3).
# Armadura em camadas separadas que CAEM ao longo da luta.
# ---------------------------------------------------------------------------
HELENA_KEY = {
    "r": P.HELENA_HAIR, "R": P.HELENA_HAIR_LIGHT, "x": P.HELENA_HAIR_DARK,
    "s": P.HELENA_SKIN, "z": P.HELENA_SKIN_SHADOW, "e": P.HELENA_EYE,
    "u": P.UNDERSHIRT, "U": P.UNDERSHIRT_SHADOW, "p": P.PANTS, "P": P.PANTS_DARK, "f": P.LEATHER,
}
HELENA_BODY = [
    "......rrrrrr......",
    "....rrRRRRrrrr....",
    "...rRRRrrrrrrrr...",
    "..rrRrrrrrrrrrrr..",
    "..rrrrrrrrrrssrr..",
    ".rrrrrrrrrsssssr..",
    ".rrrrrrrrsssssss..",
    ".rrrrrrrrsessses..",
    ".rrrrrrrrsessses..",
    ".xrrrrrrrssssss...",
    ".xrrrrrrrzsssz....",
    "xxrrrrrrr.zss.....",
    "xrrrrrruuuuuuu....",
    "xrrrrruuuuuuuus...",
    "xrrrrsuuuuuuuuus..",
    "xxrrrsuuuuuuuuus..",
    ".xrrrsuuuuuuuuzs..",
    ".xxrr.uuuuuuuuu...",
    "..xr..UUUUUUUUU...",
    "......ppppppppp...",
]
HELENA_LEGS = [
    ["......pppp.pppp..", "......ppp..ppp...", "......PPP..PPP...", "......fff..fff..."],
    ["......pppp..ppp..", ".....ppp....ppp..", ".....PPP....PPP..", ".....fff....fff.."],
    ["......pppp.pppp..", "......ppp..ppp...", "......PPP..PPP...", "......fff..fff..."],
    [".......ppppppp...", ".......pppppp....", ".......PPPPPP....", ".......ffffff...."],
]
HELENA_OFFSET = (6, 5)  # onde a grade do corpo entra no quadro 32x32


def helena_frames() -> list:
    return [_char_frame((32, 32), HELENA_BODY, l, HELENA_KEY, HELENA_OFFSET) for l in HELENA_LEGS]


def _overlay(grid: list[str], key: dict, dx: int, dy: int) -> object:
    """Peca de armadura no MESMO sistema de coordenadas do corpo (quadro 32x32)."""
    frame = canvas(32, 32)
    piece = from_grid(grid, key, outline=O)
    # +HELENA_OFFSET porque a grade do corpo comeca ali; -1 por causa da margem do contorno.
    paste(frame, piece, HELENA_OFFSET[0] + dx, HELENA_OFFSET[1] + dy)
    return frame


ARMOR_KEY = {"a": P.STEEL, "d": P.STEEL_DARK, "l": P.STEEL_LIGHT, "k": P.STEEL_DEEP,
             "c": P.CAPE, "C": P.CAPE_DARK, "L": P.CAPE_LIGHT, "g": P.GOLD, "v": P.STEEL_DEEP}


def helena_helmet() -> object:
    grid = [
        "......LLL.......",
        ".....LcccL......",
        ".....ccCcc......",
        "....dllllld.....",
        "...dlllaaaald...",
        "..dlaaaaaaaaad..",
        ".dlaaaaaaaaaaad.",
        ".daaaaaaaaaaaad.",
        "daaaaaaaaakkkkkd",
        "daaaaaaaaakvvvkd",
        "daaaaaaaaakkkkkd",
        ".daaaaaaaaaaaad.",
        ".ddaaaaaaaaaaad.",
        "..ddaaaaaaaaad..",
        "....dddaaaadd...",
    ]
    return _overlay(grid, ARMOR_KEY, 0, -4)


def helena_pauldron_back() -> object:
    grid = [
        ".llll.",
        "laaaad",
        "daaadd",
        ".ddd..",
    ]
    return _overlay(grid, ARMOR_KEY, 3, 12)


def helena_pauldron_front() -> object:
    grid = [
        ".lllll.",
        "laaaaad",
        "laaaaad",
        "daaaadd",
        ".dddd..",
    ]
    return _overlay(grid, ARMOR_KEY, 12, 12)


def helena_breastplate() -> object:
    grid = [
        ".lllllll.",
        "laaaaaaal",
        "aaagaaaad",
        "aaaaaaaad",
        "daaaaaadd",
        ".dccccdd.",
        ".ccLcccc.",
    ]
    return _overlay(grid, ARMOR_KEY, 6, 13)


def helena_cape() -> object:
    """Capa carmesim (fica ATRAS do corpo; z_index menor no Godot)."""
    grid = [
        "....cccc..",
        "...ccccc..",
        "..ccLccc..",
        "..cLcccc..",
        ".ccLcccC..",
        ".cLccccC..",
        ".cLcccCC..",
        "ccccccCC..",
        "cLcccCCC..",
        "cccccCCC..",
        "ccCcCCC...",
        "CC.CCC....",
    ]
    return _overlay(grid, ARMOR_KEY, -2, 11)


def helena_sword() -> object:
    """Espada longa apontando para a DIREITA; empunhadura em x=2."""
    grid = [
        "...g.................",
        "fffgBBBBBBBBBBBBBBBb.",
        "fffgbbbbbbbbbbbbbbbbb",
        "...g.................",
    ]
    return from_grid(grid, {"f": P.GRIP, "g": P.GOLD, "B": P.BLADE, "b": P.BLADE_DARK}, outline=O)


def player_sword() -> object:
    grid = [
        "..g..........",
        "ffgBBBBBBBBb.",
        "ffgbbbbbbbbbb",
        "..g..........",
    ]
    return from_grid(grid, {"f": P.GRIP, "g": P.GOLD_DARK, "B": P.BLADE, "b": P.BLADE_DARK}, outline=O)


def helena_seated() -> object:
    """Helena sentada na plateia, vista de costas (como na imagem do Teatro)."""
    grid = [
        "....xrrrrx....",
        "...xrRRRrrx...",
        "..xrRRrrrrrx..",
        "..xrrrrrrrrx..",
        ".dlxrrrrrrxld.",
        "dlaxrrrrrrxaad",
        "daaxrrrrrrxaad",
        ".ddxrrrrrrxdd.",
        "SSSSxrrrrxSSSS",
        "SLLLLxrrxLLLLS",
        "SLLLLLxxLLLLLS",
        "SLLLLLLLLLLLLS",
        "SLLLLLLLLLLLLS",
        "SSSSSSSSSSSSSS",
        "w.w........w.w",
        "w.w........w.w",
    ]
    key = dict(HELENA_KEY)
    key.update({"d": P.STEEL_DARK, "l": P.STEEL_LIGHT, "a": P.STEEL,
                "S": P.SEAT_DARK, "L": P.SEAT, "w": P.WOOD_DARK})
    frame = canvas(24, 24)
    paste(frame, from_grid(grid, key, outline=O), 4, 5)
    return frame


# ---------------------------------------------------------------------------
# NPCs do Teatro
# ---------------------------------------------------------------------------
def dwarf_frames() -> list:
    """Ferreiro Anao: forte, baixinho, sem camisa, martelando sem parar."""
    key = {"s": P.DWARF_SKIN, "z": P.DWARF_SKIN_DARK, "b": P.DWARF_BEARD, "B": P.DWARF_BEARD_DARK,
           "e": (30, 24, 20), "a": P.APRON, "p": (60, 56, 52), "i": P.IRON, "I": P.IRON_LIGHT, "w": P.WOOD}
    body = [
        "....ssss......",
        "...ssssss.....",
        "..ssssssss....",
        "..sssessess...",
        "..zsbbbbbbs...",
        ".ssbbbbbbbbs..",
        "sszbbbbbbbbzs.",
        "sszzbbBbbbbzs.",
        "sss.abbbbba.ss",
        "ss..aabbbaa.ss",
        "....aaaaaaa...",
        "....aaaaaaa...",
        "....pp...pp...",
        "....pp...pp...",
        "...ppp...ppp..",
    ]
    hammer_up = [
        "...II.",
        "..IiiI",
        "..IiiI",
        "...w..",
        "...w..",
        "...w..",
    ]
    hammer_down = [
        "w.....",
        ".ww...",
        "...wII",
        "...Iii",
        "...Iii",
        "....I.",
    ]
    frames = []
    for hammer, pos in ((hammer_up, (15, 2)), (hammer_down, (16, 10))):
        frame = canvas(24, 24)
        paste(frame, from_grid(body, key, outline=O), 3, 7)
        paste(frame, from_grid(hammer, key, outline=O), pos[0], pos[1])
        frames.append(frame)
    return frames


def dragonoid_frames() -> list:
    """Vendedor Dragonoide (roxo, com chifres), atras do balcao."""
    key = {"d": P.DRAGON, "D": P.DRAGON_DARK, "l": P.DRAGON_LIGHT, "y": P.DRAGON_BELLY, "h": P.HORN,
           "e": P.DRAGON_EYE, "r": P.ROBE, "R": P.ROBE_LIGHT, "g": P.GOLD, "k": (30, 20, 30)}
    body = [
        "..h.....h.....",
        "..hh...hh.....",
        "...hdddh......",
        "..dlllldd.....",
        ".dllllllddd...",
        ".dlllekllldd..",
        ".ddllllllllll.",
        "..dddllyyyyyy.",
        "...DddyykkyD..",
        "..rrRRRRRrr...",
        ".rrrRgRRRrrr..",
        "dd.rrgrrrr.dd.",
        "dd.rrgrrrr.dd.",
        "...rrrrrrr....",
        "...rrrrrrr....",
        "...RRRRRRR....",
    ]
    frames = []
    for blink in (False, True):
        grid = list(body)
        if blink:
            grid[5] = ".dllllDDllldd.."[:14]
        frame = canvas(24, 24)
        paste(frame, from_grid(grid, key, outline=O), 4, 4)
        frames.append(frame)
    return frames


def fairy_frames() -> list:
    """A Fada do Teatro: brilho suave, a unica ainda disposta a ajudar."""
    key = {"f": P.FAIRY, "w": P.FAIRY_WING + (170,), "h": P.FAIRY_HAIR, "e": (90, 120, 150)}
    up = [
        "ww....ww",
        "www..www",
        "wwwhhwww",
        ".wwhhww.",
        "..hfeh..",
        "...ff...",
        "..ffff..",
        "...ff...",
        "...f.f..",
    ]
    down = [
        "........",
        "...hh...",
        "..hhhh..",
        "..hfeh..",
        "wwwffwww",
        "wwffffww",
        ".w.ff.w.",
        "...f.f..",
        "........",
    ]
    frames = []
    for grid in (up, down):
        frame = canvas(16, 16)
        paste(frame, from_grid(grid, key), 4, 3)
        frames.append(frame)
    return frames


def orb_frames() -> list:
    """Orbe Branco: purifica fragmentos e frascos. (Nome ainda nao definido.)"""
    frames = []
    for r in (4.6, 5.2):
        frame = canvas(14, 14)
        ellipse(frame, 7, 7, r + 1.2, r + 1.2, P.ORB_MID + (90,))
        ellipse(frame, 7, 7, r, r, P.ORB_MID)
        ellipse(frame, 6.4, 6.4, r - 1.5, r - 1.5, P.ORB)
        put(frame, 5, 5, (255, 255, 255))
        frames.append(frame)
    return frames


def training_dummy() -> object:
    key = {"s": P.STRAW, "S": P.STRAW_DARK, "b": P.BURLAP, "m": P.MARK_RED, "w": P.WOOD, "W": P.WOOD_DARK, "r": P.LEATHER}
    grid = [
        "....bbbbb.....",
        "...bbbbbbb....",
        "...bmbbbmb....",
        "...bbmbmbb....",
        "...bbbmbbb....",
        "...bbmbmbb....",
        "....bbbbb.....",
        ".....rrr......",
        "wwwwwwwwwwwww.",
        "WWWWsSsssWWWW.",
        "...sssSsss....",
        "...ssSssss....",
        "...rrrrrrr....",
        "...sssssSs....",
        "....sssss.....",
        "......w.......",
        "......w.......",
        "......W.......",
        "....WWWWW.....",
    ]
    frame = canvas(24, 24)
    paste(frame, from_grid(grid, key, outline=O), 5, 2)
    return frame
