#!/usr/bin/env python3
"""Stamp the site favicon onto the bottom-right corner of hero images.

Usage:
  python3 scripts/stamp_hero_favicon.py <image_path> [--size 64] [--margin 20]

Applies the favicon as a semi-transparent overlay in the bottom-right
corner, covering any existing watermark/badge. By default uses the
largest frame from the ICO file (256x256), resized to --size.

Requires: Pillow (pip install Pillow)
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from PIL import Image


def find_favicon() -> Path | None:
    candidates = [
        Path(__file__).resolve().parents[2] / "docs" / "favicon.ico",
        Path(__file__).resolve().parents[2] / "docs" / "_site" / "favicon.ico",
    ]
    for c in candidates:
        if c.exists():
            return c
    return None


def load_favicon(path: Path, size: int) -> Image.Image:
    ico = Image.open(path)
    # Seek to the largest frame (usually last)
    n_frames = getattr(ico, "n_frames", 1)
    ico.seek(n_frames - 1)
    fav = ico.convert("RGBA")
    return fav.resize((size, size), Image.LANCZOS)


def stamp_favicon(hero_path: str, favicon_size: int = 64, margin: int = 20, opacity: float = 1.0) -> None:
    hero = Image.open(hero_path).convert("RGBA")
    w, h = hero.size

    favicon_path = find_favicon()
    if favicon_path is None:
        print("Error: favicon.ico not found in docs/ or docs/_site/", file=sys.stderr)
        sys.exit(1)

    fav = load_favicon(favicon_path, favicon_size)

    if opacity < 1.0:
        r = Image.new("RGBA", fav.size, (0, 0, 0, 0))
        for x in range(fav.width):
            for y in range(fav.height):
                pr, pg, pb, pa = fav.getpixel((x, y))
                r.putpixel((x, y), (pr, pg, pb, int(pa * opacity)))
        fav = r

    # Position: bottom-right with margin
    paste_x = w - margin - fav.width
    paste_y = h - margin - fav.height

    hero.paste(fav, (paste_x, paste_y), fav)
    hero.save(hero_path, "PNG")
    print(f"Stamped favicon onto {hero_path} ({favicon_size}px, opacity={opacity})")


def main() -> int:
    parser = argparse.ArgumentParser(description="Stamp favicon onto hero image corner")
    parser.add_argument("image", help="Path to hero image PNG")
    parser.add_argument("--size", type=int, default=64, help="Favicon size in pixels (default: 64)")
    parser.add_argument("--margin", type=int, default=20, help="Margin from edges (default: 20)")
    parser.add_argument("--opacity", type=float, default=1.0, help="Opacity 0-1 (default: 1.0)")
    args = parser.parse_args()

    stamp_favicon(args.image, args.size, args.margin, args.opacity)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
