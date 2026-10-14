"""Mini-biblioteca de pixel art para o Alexandria.

Sprites sao desenhados como "grades" de texto: cada caractere e um pixel e a
legenda (key) traduz caractere -> cor. O contorno escuro e gerado sozinho
(add_outline), entao a grade so precisa das cores internas.
"""
from __future__ import annotations

import random
from typing import Iterable

from PIL import Image

RGBA = tuple[int, int, int, int]


def rgba(color: tuple, alpha: int = 255) -> RGBA:
    if len(color) == 4:
        return tuple(color)  # type: ignore[return-value]
    return (color[0], color[1], color[2], alpha)


def hexc(value: str, alpha: int = 255) -> RGBA:
    value = value.lstrip("#")
    return (int(value[0:2], 16), int(value[2:4], 16), int(value[4:6], 16), alpha)


def from_grid(rows: Iterable[str], key: dict[str, tuple], outline: tuple | None = None) -> Image.Image:
    rows = list(rows)
    width = max(len(r) for r in rows)
    height = len(rows)
    margin = 1 if outline else 0
    image = Image.new("RGBA", (width + margin * 2, height + margin * 2), (0, 0, 0, 0))
    pixels = image.load()
    for y, row in enumerate(rows):
        for x, char in enumerate(row):
            color = key.get(char)
            if color is not None:
                pixels[x + margin, y + margin] = rgba(color)
    if outline:
        image = add_outline(image, outline)
    return image


def add_outline(image: Image.Image, color: tuple, diagonal: bool = False) -> Image.Image:
    src = image.load()
    out = image.copy()
    dst = out.load()
    w, h = image.size
    neighbors = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    if diagonal:
        neighbors += [(1, 1), (-1, -1), (1, -1), (-1, 1)]
    for y in range(h):
        for x in range(w):
            if src[x, y][3] > 0:
                continue
            for dx, dy in neighbors:
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h and src[nx, ny][3] > 200:
                    dst[x, y] = rgba(color)
                    break
    return out


def canvas(w: int, h: int, color: tuple = (0, 0, 0, 0)) -> Image.Image:
    return Image.new("RGBA", (w, h), rgba(color) if len(color) >= 3 else color)


def paste(dst: Image.Image, src: Image.Image, x: int, y: int) -> None:
    dst.alpha_composite(src, (x, y))


def hstrip(frames: list[Image.Image]) -> Image.Image:
    w = sum(f.width for f in frames)
    h = max(f.height for f in frames)
    sheet = canvas(w, h)
    x = 0
    for frame in frames:
        paste(sheet, frame, x, 0)
        x += frame.width
    return sheet


def grid_sheet(frames: list[Image.Image], columns: int) -> Image.Image:
    fw, fh = frames[0].size
    rows = (len(frames) + columns - 1) // columns
    sheet = canvas(fw * columns, fh * rows)
    for i, frame in enumerate(frames):
        paste(sheet, frame, (i % columns) * fw, (i // columns) * fh)
    return sheet


def flip_h(image: Image.Image) -> Image.Image:
    return image.transpose(Image.Transpose.FLIP_LEFT_RIGHT)


def upscale(image: Image.Image, factor: int) -> Image.Image:
    return image.resize((image.width * factor, image.height * factor), Image.Resampling.NEAREST)


def shade(color: tuple, factor: float) -> RGBA:
    c = rgba(color)
    return (
        max(0, min(255, int(c[0] * factor))),
        max(0, min(255, int(c[1] * factor))),
        max(0, min(255, int(c[2] * factor))),
        c[3],
    )


def mix(a: tuple, b: tuple, t: float) -> RGBA:
    a, b = rgba(a), rgba(b)
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(4))  # type: ignore[return-value]


def noise_fill(image: Image.Image, rect: tuple[int, int, int, int], colors: list[tuple], weights: list[float], seed: int) -> None:
    rng = random.Random(seed)
    px = image.load()
    x0, y0, x1, y1 = rect
    for y in range(y0, y1):
        for x in range(x0, x1):
            px[x, y] = rgba(rng.choices(colors, weights)[0])


def rect(image: Image.Image, x0: int, y0: int, x1: int, y1: int, color: tuple) -> None:
    """Retangulo preenchido, x1/y1 EXCLUSIVOS."""
    px = image.load()
    c = rgba(color)
    for y in range(max(0, y0), min(image.height, y1)):
        for x in range(max(0, x0), min(image.width, x1)):
            px[x, y] = c


def put(image: Image.Image, x: int, y: int, color: tuple) -> None:
    if 0 <= x < image.width and 0 <= y < image.height:
        image.load()[x, y] = rgba(color)


def hline(image: Image.Image, x0: int, x1: int, y: int, color: tuple) -> None:
    for x in range(x0, x1):
        put(image, x, y, color)


def vline(image: Image.Image, x: int, y0: int, y1: int, color: tuple) -> None:
    for y in range(y0, y1):
        put(image, x, y, color)


def ellipse(image: Image.Image, cx: float, cy: float, rx: float, ry: float, color: tuple) -> None:
    for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
            dx = (x + 0.5 - cx) / rx
            dy = (y + 0.5 - cy) / ry
            if dx * dx + dy * dy <= 1.0:
                put(image, x, y, color)
