"""Compõe os mapas iniciais em texto (levels/*.txt).

Depois de gerados, edite os .txt À MÃO — este script só existe para criar a
primeira versão com geometria simétrica. Rodar de novo SOBRESCREVE os mapas.
Uso: python3 tools/compose_levels.py
"""
from __future__ import annotations

import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


class Grid:
    def __init__(self, w: int, h: int, fill: str = " ") -> None:
        self.w, self.h = w, h
        self.rows = [[fill] * w for _ in range(h)]

    def rect(self, x0: int, y0: int, x1: int, y1: int, c: str) -> None:
        """Retângulo preenchido, coordenadas INCLUSIVAS."""
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.set(x, y, c)

    def set(self, x: int, y: int, c: str) -> None:
        if 0 <= x < self.w and 0 <= y < self.h:
            self.rows[y][x] = c

    def text(self) -> str:
        return "\n".join("".join(r).rstrip() for r in self.rows) + "\n"


def teatro() -> str:
    g = Grid(36, 34, "#")
    # Palco com cortinas laterais
    g.rect(1, 2, 3, 8, "|")
    g.rect(32, 2, 34, 8, "|")
    g.rect(4, 2, 31, 8, "=")
    g.rect(1, 9, 34, 9, ".")
    g.rect(4, 9, 31, 9, "-")
    # Fosso da orquestra (arena) e a névoa que separa palco e plateia
    g.rect(1, 10, 34, 14, ".")
    g.rect(1, 15, 34, 15, "M")
    # Plateia
    g.rect(1, 16, 34, 26, ".")
    g.rect(4, 16, 31, 26, ",")
    for row in (17, 18, 19, 22, 23, 24):
        for col in list(range(6, 16)) + list(range(20, 30)):
            g.set(col, row, "r")
    # Variedade: poltronas bege nas pontas e algumas quebradas (referência do Teatro)
    for (x, y) in [(6, 17), (15, 17), (20, 17), (29, 17), (6, 22), (29, 22)]:
        g.set(x, y, "t")
    for (x, y) in [(8, 18), (11, 17), (13, 19), (21, 18), (24, 19), (27, 17), (9, 22), (12, 24), (22, 23), (26, 24), (28, 23)]:
        g.set(x, y, "R")
    g.set(15, 23, "H")  # Helena, sentada na plateia
    # Corredor central com tapete vermelho até a saída
    for y in range(16, 32):
        g.set(17, y, "{")
        g.set(18, y, "}")
    # Pilares nas laterais
    for (x, y) in [(2, 18), (2, 23), (33, 18), (33, 23)]:
        g.set(x, y, "I")
    # Saguão
    g.rect(1, 27, 34, 31, ".")
    for y in range(27, 32):
        g.set(17, y, "{")
        g.set(18, y, "}")
    g.set(5, 29, "A")   # Ferreiro (forja à esquerda, bigorna à direita)
    g.set(9, 29, "B")   # boneco de treino
    g.set(30, 29, "V")  # Vendedor Dragonoide atrás do balcão
    g.set(27, 28, "W")  # armas à venda
    g.set(12, 30, "k")
    g.set(23, 30, "k")
    # Palco: Fada perto do palco, Orbe sob o palco, Câmara diante do palco
    g.set(5, 11, "F")
    g.set(17, 9, "O")
    g.set(17, 11, "C")
    g.set(17, 5, "Y")   # onde a Helena aterrissa
    # Tochas na parede do fundo
    for x in (8, 27):
        g.set(x, 1, "T")
    # Saída
    g.set(17, 32, "D")
    g.set(18, 32, "D")
    return g.text()


def cidade() -> str:
    g = Grid(48, 36, " ")
    # Chão da ilha (o resto é céu)
    g.rect(1, 2, 45, 29, ".")
    # Fachada traseira do Teatro (topo à esquerda) com a porta
    g.rect(0, 0, 16, 1, "#")
    g.set(3, 1, "n")
    g.set(12, 1, "n")
    g.set(7, 1, "D")
    g.set(5, 1, "T")
    g.set(10, 1, "T")
    # Praça diante do teatro (calçada)
    g.rect(1, 2, 15, 8, ",")
    g.set(7, 2, "_")
    for (x, y) in [(3, 4), (12, 4), (3, 8), (12, 8)]:
        g.set(x, y, "L")
    g.set(5, 6, "x")
    g.set(13, 7, "x")
    g.set(1, 5, "e")  # mirante: a borda da ilha logo na chegada
    # Prédio em ruínas (bloco central-superior)
    g.rect(17, 0, 30, 6, "#")
    g.rect(31, 0, 47, 1, "#")
    # Avenida partida
    g.rect(1, 9, 45, 21, ".")
    g.rect(1, 15, 45, 15, "=")
    for (x, y) in [(6, 12), (14, 18), (22, 11), (30, 19), (38, 13), (26, 16)]:
        g.set(x, y, "~")
    for (x, y) in [(8, 17), (33, 11)]:
        g.set(x, y, "K")
    for (x, y) in [(19, 13), (25, 13), (36, 17)]:
        g.set(x, y, "X")
    for (x, y) in [(12, 11), (28, 18), (40, 19), (21, 20)]:
        g.set(x, y, "f")
    for (x, y) in [(16, 10), (17, 19), (31, 10), (43, 10)]:
        g.set(x, y, "x")
    for (x, y) in [(6, 12), (10, 13), (20, 16), (24, 17), (22, 18)]:
        g.set(x, y, "S")
    # Bloco de prédios da direita e a aproximação do portão de Aldir
    g.rect(32, 2, 45, 8, ",")
    g.rect(32, 2, 36, 4, "#")
    g.set(41, 2, "G")
    g.rect(38, 1, 45, 1, "#")
    for (x, y) in [(38, 6), (43, 7)]:
        g.set(x, y, "S")
    g.set(34, 7, "c")
    g.set(35, 7, "c")
    g.set(45, 4, "f")
    # Ruína baixa no meio-sul
    g.rect(26, 23, 33, 26, "#")
    g.rect(1, 22, 45, 29, ".")
    g.rect(26, 23, 33, 26, "#")
    # Borda da ilha: grama perto do abismo (sudoeste) e mirante
    g.rect(1, 24, 22, 29, "g")
    g.rect(1, 22, 12, 23, "g")
    g.set(10, 28, "e")
    g.set(4, 27, "x")
    g.set(18, 25, "c")
    # Recortes irregulares da borda (o céu entra na ilha)
    for (x, y) in [(1, 29), (2, 29), (3, 29), (22, 29), (23, 29), (44, 29), (45, 29), (45, 28), (45, 27), (45, 22), (45, 21), (44, 21)]:
        g.set(x, y, " ")
    for (x, y) in [(37, 26), (41, 24)]:
        g.set(x, y, "S")
    g.set(38, 24, "f")
    return g.text()


def main() -> None:
    os.makedirs(os.path.join(ROOT, "levels"), exist_ok=True)
    for name, text in (("teatro", teatro()), ("cidade", cidade())):
        path = os.path.join(ROOT, "levels", name + ".txt")
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
        print(f"   levels/{name}.txt")
        print(text)


if __name__ == "__main__":
    main()
