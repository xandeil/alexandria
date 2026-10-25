"""As 8 armas de chefe (forjadas pelo Ferreiro com a Lembranca de cada Pecado).

Cada arma tem dois desenhos:
  * mao   — o sprite que o heroi segura (deitado, apontando para a DIREITA,
            cabo na esquerda; o jogo gira e espelha, igual a espada inicial);
  * icone — 16x16 para o inventario (a mesma arma, na diagonal).

A arma nao e uma copia do que o chefe usa: e a "alma" dele virando ferramenta
(a mesma ideia das armas de chefe dos soulslike). Por isso as cores vem da
paleta de cada chefe/regiao.
"""
from __future__ import annotations

from PIL import Image

import palette as P
from pixel import canvas, from_grid, paste

O = P.OUTLINE

# id -> (grade da mao, chave de cores)
WEAPONS = {
    # Luxuria (Helena): sabre fino, aco claro com fio carmesim.
    "lamina_desolada": ([
        "..g.............",
        "ffgLLLLLLLLLLLl.",
        "ffgrrrrrrrrrrrrr",
        "..g.............",
    ], {"f": P.GRIP, "g": P.GOLD, "L": P.BLADE, "r": P.SARGE_RED}),
    # Ira (Aldir): martelo de cabo longo e cabeca rachada.
    "pilar_estilhacada": ([
        "...........HHHHH",
        "...........HhhhH",
        "fffhhhhhhhhHhchH",
        "...........HhhhH",
        "...........HHHHH",
    ], {"f": P.GRIP, "h": P.ALDIR_HANDLE, "H": P.HAMMER_HEAD, "c": P.EMBER}),
    # Orgulho (Rachel): espada larga de escama, fio em brasa.
    "presa_caelis": ([
        "...g..............",
        "ffgSSSSSSSSSSSSs..",
        "ffgSsssssssssssSSe",
        "ffgeeeeeeeeeeeeee.",
        "...g..............",
    ], {"f": P.GRIP, "g": P.GOLD_DARK, "S": P.RACHEL_LIGHT, "s": P.RACHEL, "e": P.EMBER}),
    # Ganancia (Cassian): lanca dourada com ponta de cristal de gelo.
    "fuso_arconte": ([
        "..................cc..",
        "fffttttttttttttttCccc.",
        "..................cc..",
    ], {"f": P.GRIP, "t": P.FROST_GOLD, "C": P.CRYSTAL_DARK, "c": P.CRYSTAL_LIGHT}),
    # Inveja (Durgan): besta de bronze com bobina eletrica.
    "replicador_bronze": ([
        "......bb.......",
        ".....bBb.......",
        "ffffBBBBBBBBBe.",
        "..f..bBb.......",
        "......bb.......",
    ], {"f": P.WOOD_DARK, "B": P.BRONZE, "b": P.BRONZE_DARK, "e": P.ELECTRIC}),
    # Gula (Mabel): adaga curva, lamina cor de carne.
    "presas_voragem": ([
        "..g.......",
        "ffgFFFFFa.",
        "ffgaaaaaaF",
        "..g.......",
    ], {"f": P.GRIP, "g": P.MABEL_SCARF, "F": P.FLESH_LIGHT, "a": P.FLESH}),
    # Preguica (Nyssa): arco de galho com flores (a corda e o tracinho claro).
    "arco_sono": ([
        "w.....",
        ".wp...",
        "..w...",
        "..wp..",
        "s.fw..",
        "s.fw..",
        "..wp..",
        "..w...",
        ".wp...",
        "w.....",
    ], {"w": P.BARK_LIGHT, "p": P.PETAL, "f": P.GRIP, "s": P.POLLEN_LIGHT}),
    # Nucleo (Cavaleiro): machado pesado de lamina negra com brilho do Nucleo.
    "ancora_gravidade": ([
        "...........kKKK..",
        "..........kKKkKK.",
        "fffhhhhhhhhhKgKhh",
        "..........kKKkKK.",
        "...........kKKK..",
    ], {"f": P.GRIP, "h": P.KNIGHT_ARMOR_DARK, "K": P.KNIGHT_ARMOR, "k": P.KNIGHT_ARMOR_DARK, "g": P.CORE_GLOW}),
}

def hand(weapon_id: str):
    grid, key = WEAPONS[weapon_id]
    return from_grid(grid, key, outline=O)


def icon(weapon_id: str):
    """A arma na diagonal (45 graus), cabendo em 16x16.

    Girar pixel art com interpolacao borraria tudo; com NEAREST e numa grade
    ampliada 4x (depois reduzida) os degraus ficam limpos.
    """
    sprite = hand(weapon_id)
    if weapon_id == "arco_sono":  # o arco ja e "em pe": so centraliza
        img = canvas(16, 16)
        paste(img, sprite, (16 - sprite.width) // 2, (16 - sprite.height) // 2)
        return img
    big = sprite.resize((sprite.width * 4, sprite.height * 4), Image.NEAREST)
    big = big.rotate(45, resample=Image.NEAREST, expand=True)
    box = big.getbbox()
    big = big.crop(box)
    scale = min(64 / big.width, 64 / big.height, 1.0)
    w, h = max(1, int(big.width * scale / 4)), max(1, int(big.height * scale / 4))
    small = big.resize((w, h), Image.NEAREST)
    img = canvas(16, 16)
    paste(img, small, (16 - w) // 2, (16 - h) // 2)
    return img
