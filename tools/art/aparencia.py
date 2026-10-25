"""Criacao de personagem: todas as aparencias da protagonista/do protagonista.

Cada aparencia = sexo x corpo x rosto x cabelo, montada em CAMADAS de grade
(caractere por caractere) e so depois contornada. Por que montar a grade e
nao as imagens? Porque o contorno (outline) precisa ser calculado sobre a
silhueta FINAL — colar imagens ja contornadas deixaria linhas pretas no meio
do rosto, onde o cabelo encosta na pele.

O resultado e um atlas: uma LINHA por combinacao, 4 quadros por linha
(parado, passada, parado, cruzando — o mesmo ciclo do player.png).

Regra importante: o cabelo e os olhos usam EXATAMENTE as cores-chave
P.HAIR, P.HAIR_LIGHT e P.EYE. O shader sprite_fx troca essas cores para o
branco quando o jogador perde a sanidade — se a arte nova usasse outro tom,
o efeito de "cabelo embranquecendo" pararia de funcionar.
"""
from __future__ import annotations

import palette as P
from pixel import canvas, from_grid, paste

O = P.OUTLINE
W = 16  # largura da grade (cabe o corpo do Forte e o do Gordo)

SEXES = ["homem", "mulher"]
BODIES = ["magro", "forte", "gordo"]
FACES_PER_SEX = 3
HAIRS_PER_SEX = 5

KEY = {
    "h": P.HAIR, "j": P.HAIR_LIGHT, "s": P.SKIN, "z": P.SKIN_SHADOW, "e": P.EYE,
    "w": P.TUNIC, "v": P.TUNIC_SHADOW, "c": P.SCARF, "n": P.SCARF_LIGHT,
    "b": P.LEATHER, "l": P.WRAPS, "r": P.LIP, "W": P.WHITE_EYE,
}


def _pad(rows: list[str], left: int = 1) -> list[str]:
    """Centraliza uma grade de 14 colunas na grade de 16 (cabeca e cabelo)."""
    return [("." * left + r).ljust(W, ".") for r in rows]


# ---------------------------------------------------------------------------
# Cabeca: o cranio (pele) e igual para todos; o rosto e desenhado por cima.
# ---------------------------------------------------------------------------
SKULL = [
    "...ssssss.....",
    "..sssssssss...",
    ".sssssssssss..",
    ".ssssssssssss.",
    "ssssssssssssss",
    "zsssssssssssss",
    "zsssssssssssss",
    "zsssssssssssss",
    "zsssssssssssss",
    ".zssssssssssss",
    "..zzzssssssss.",
]

# Rostos: so a regiao da frente (linhas 5..10, colunas 6..13). "." = mantem a pele.
FACES = {
    "homem": [
        # Sereno — o olhar original do jogo
        ["........", "........", "..e...e.", "..e...e.", "........", "z.....z."],
        # Barbudo — olhos menores, barba (na cor do cabelo: embranquece junto!)
        ["..h...h.", "..e...e.", "........", "........", ".jhhhhhh", "..hhhhh."],
        # Marcado — sobrancelha grossa, olhar estreito e uma cicatriz
        ["..hh..hh", "........", "..e..ze.", "......z.", "........", "z......."],
    ],
    "mulher": [
        # Serena — cilios e boca pequena
        ["...h...h", "..e...e.", "..e...e.", "........", "......r.", "z......."],
        # Olhar vivo — olhos grandes com brilho
        ["...h...h", "..We..We", "..ee..ee", "........", ".....rr.", "z......."],
        # Pintas — olhos calmos, sardas
        ["........", "..hh..hh", "..e...e.", ".z.z..z.", "......r.", "z......."],
    ],
}

# ---------------------------------------------------------------------------
# Cabelos: grade de 17 linhas x 14 colunas (cabeca + ombros). "." = transparente.
# Podem descer sobre as costas (coluna da esquerda: o personagem olha p/ direita).
# ---------------------------------------------------------------------------
HAIRS = {
    "homem": [
        # 1 Curto (o corte original)
        ["...hhhhhh.....", "..hhjjjjhhh...", ".hhjjjhhhhhh..", ".hhhhhhhhhhhh.",
         "hhhhhhhhhhhhhh", "hhhhhhhhh.....", "hhhhhhh.......", "hhhhhh........",
         "hhhhhh........", ".hhhhh........", "..hhhh........"] + [""] * 6,
        # 2 Raspado — cabelo bem rente, sem franja
        ["...hhhhhh.....", "..hjjjjjjhh...", ".hjjjjjjjjjh..", ".hhhhhhhhhhhh.",
         "hhhhhhhhhh....", "hhhhhh........", "hhhhh.........", "hhhh..........",
         "hhhh..........", ".hh...........", ""] + [""] * 6,
        # 3 Desgrenhado — mechas espetadas e franja na testa
        [".h.hhhhh.h....", "hhhhjjjjhhhh..", ".hhjjjhhhjhhh.", "hhhhhhhhhhhhhh",
         "hhhhhhhhhhhhhh", "hhhhhhhhhh.h.h", "hhhhhhhh......", "hhhhhh........",
         "hhhhhhh.......", ".hhhhh........", "..hhh.........", ] + [""] * 6,
        # 4 Rabo preso — curto na frente, rabinho na nuca
        ["...hhhhhh.....", "..hhjjjjhhh...", ".hhjjjhhhhhh..", ".hhhhhhhhhhhh.",
         "hhhhhhhhhhhhhh", "hhhhhhhhhh....", "hhhhhhh.......", "jhhhhh........",
         "hhhhhh........", "hhhhhh........", "hh.hhh........", "hh............",
         "h.............", "", "", "", ""],
        # 5 Comprido solto — cai ate os ombros
        ["...hhhhhh.....", "..hhjjjjhhh...", ".hhjjjhhhhhh..", "hhhhhhhhhhhhh.",
         "hhhhhhhhhhhhhh", "hhhhhhhhhhh...", "hhhhhhhh......", "hhhhhhh.......",
         "hhhhhhh.......", "hhhhhhh.......", "hhhhhh........", "hhhhh.........",
         ".hhh..........", "", "", "", ""],
    ],
    "mulher": [
        # 1 Chanel — reto na altura do queixo
        ["...hhhhhh.....", "..hhjjjjhhh...", ".hhjjjhhhhhh..", "hhhhhhhhhhhhh.",
         "hhhhhhhhhhhhhh", "hhhhhhhhhh.h..", "hhhhhhhh......", "hhhhhhh.......",
         "hhhhhhh.......", "hhhhhhh.......", "hhhhhhh.......", "hhhhhh........",
         "", "", "", "", ""],
        # 2 Rabo de cavalo — preso alto, balanca atras
        ["...hhhhhh.....", "..hhjjjjhhh...", "hhhjjjhhhhhh..", "hhhhhhhhhhhhh.",
         "hhhhhhhhhhhhhh", "hhhhhhhhhh.h..", "hhhhhhh.......", "hhhhhh........",
         ".hhhhh........", "hhhhhh........", "hh.hh.........", "hh............",
         "hh............", "h.............", "", "", ""],
        # 3 Longo — desce pelas costas
        ["...hhhhhh.....", "..hhjjjjhhh...", ".hhjjjhhhhhh..", "hhhhhhhhhhhhh.",
         "hhhhhhhhhhhhhh", "hhhhhhhhhhh...", "hhhhhhhhh.....", "hhhhhhhh......",
         "hhhhhhhh......", "hhhhhhhh......", "hhhhhhh.......", "hhhhh.........",
         "hhhh..........", "jhhh..........", "hhh...........", "hh............", ""],
        # 4 Coque — preso no alto da cabeca
        [".hhh..........", "hjjhhhhhhh....", "hhhhjjjjhhhh..", ".hhjjjhhhhhhh.",
         "hhhhhhhhhhhhhh", "hhhhhhhhhh.h..", "hhhhhhh.......", "hhhhhh........",
         "hhhhhh........", ".hhhhh........", "..hhh.........", "", "", "", "", "", ""],
        # 5 Curtinho (pixie) — franja de lado
        ["...hhhhhh.....", "..hhjjjjhhhh..", ".hhjjjhhhhhhh.", ".hhhhhhhhhhhhh",
         "hhhhhhhhhhhhhh", "hhhhhhhhh.hhh.", "hhhhhhh.......", "hhhhhh........",
         "hhhhh.........", ".hhhh.........", "", "", "", "", "", "", ""],
    ],
}

# ---------------------------------------------------------------------------
# Corpos: tronco (linhas 11..16) + pernas (3 linhas, 3 poses), grade de 16.
# ---------------------------------------------------------------------------
TORSOS = {
    ("homem", "magro"): [
        "......cccccc....",
        ".....cnnccccs...",
        ".....swwwwwwz...",
        ".....swwwwwv....",
        "......vbbbbv....",
        "......wwwwwv....",
    ],
    ("homem", "forte"): [
        "...cccccccccc...",
        "..scnncccccccs..",
        "..sswwwwwwwwwss.",
        "..zswwwwwwwwvsz.",
        "....vbbbbbbv....",
        "....wwwwwwwv....",
    ],
    ("homem", "gordo"): [
        "....cccccccc....",
        "...cnnccccccccs.",
        "...swwwwwwwwwwz.",
        "..sswwwwwwwwwwwv",
        "...svwwwwwwwwwv.",
        "....vbbbbbbbbv..",
    ],
    ("mulher", "magro"): [
        "......cccccc....",
        ".....cnnccccs...",
        ".....swwwwwwz...",
        "......swwwwv....",
        "......vbbbbv....",
        ".....wwwwwwwv...",
    ],
    ("mulher", "forte"): [
        "....cccccccccc..",
        "...scnncccccccs.",
        "...sswwwwwwwwss.",
        "...zswwwwwwwvsz.",
        ".....vbbbbbbv...",
        "....wwwwwwwwwv..",
    ],
    ("mulher", "gordo"): [
        "....cccccccc....",
        "...cnnccccccccs.",
        "...swwwwwwwwwwz.",
        "..sswwwwwwwwwwwv",
        "...svbbbbbbbbbv.",
        "...wwwwwwwwwwwv.",
    ],
}

# Pernas por estrutura: [parado, passada, cruzando].
LEGS = {
    "magro": [
        ["......l..l......", "......l..l......", "......b..b......"],
        ["......l...l.....", ".....l.....l....", ".....b.....b...."],
        [".......ll.......", ".......ll.......", ".......bb......."],
    ],
    "forte": [
        [".....ll..ll.....", ".....ll..ll.....", ".....bb..bb....."],
        [".....ll...ll....", "....ll.....ll...", "....bb.....bb..."],
        ["......llll......", "......llll......", "......bbbb......"],
    ],
    "gordo": [
        [".....lll.lll....", ".....lll.lll....", ".....bbb.bbb...."],
        [".....lll..lll...", "....lll....lll..", "....bbb....bbb.."],
        ["......lllll.....", "......lllll.....", "......bbbbb....."],
    ],
}
LEG_CYCLE = [0, 1, 0, 2]  # parado, passada, parado, cruzando (igual ao player.png)


def _overlay(base: list[str], top: list[str], x: int = 0, y: int = 0) -> list[str]:
    """Desenha a grade `top` sobre `base` (o "." de cima e transparente)."""
    rows = [list(r) for r in base]
    for dy, row in enumerate(top):
        for dx, ch in enumerate(row):
            if ch != "." and 0 <= y + dy < len(rows) and 0 <= x + dx < len(rows[y + dy]):
                rows[y + dy][x + dx] = ch
    return ["".join(r) for r in rows]


def _grid(sex: str, body: str, face: int, hair: int, leg_pose: int) -> list[str]:
    head = _overlay(SKULL, FACES[sex][face], 6, 5)
    grid = _pad(head) + TORSOS[(sex, body)] + LEGS[body][leg_pose]
    hair_rows = [r.ljust(14, ".") for r in HAIRS[sex][hair]]
    return _overlay(grid, _pad(hair_rows))


def index_of(sex: int, body: int, face: int, hair: int) -> int:
    """Mesma formula de Appearance.row() no Godot — os testes conferem as duas."""
    return ((sex * len(BODIES) + body) * FACES_PER_SEX + face) * HAIRS_PER_SEX + hair


def frames(sex: str, body: str, face: int, hair: int) -> list:
    out = []
    for pose in LEG_CYCLE:
        frame = canvas(24, 24)
        paste(frame, from_grid(_grid(sex, body, face, hair, pose), KEY, outline=O), 3, 1)
        out.append(frame)
    return out


def atlas():
    """Todas as combinacoes, uma por linha (96 x 24*N)."""
    total = len(SEXES) * len(BODIES) * FACES_PER_SEX * HAIRS_PER_SEX
    sheet = canvas(96, 24 * total)
    for si, sex in enumerate(SEXES):
        for bi, body in enumerate(BODIES):
            for fi in range(FACES_PER_SEX):
                for hi in range(HAIRS_PER_SEX):
                    row = index_of(si, bi, fi, hi)
                    for k, frame in enumerate(frames(sex, body, fi, hi)):
                        paste(sheet, frame, k * 24, row * 24)
    return sheet
