#!/usr/bin/env python3
"""Generate a branded hero image for a blog post.

Usage:
  python3 generate_hero_image.py \\
    --title "Feature Attribution" \\
    --subtitle "Theoretical Foundations" \\
    --subtitle2 "and the Limits of Verifiability" \\
    --date "June 10, 2026" \\
    --gradient "#1a3a5c-#0d2137" \\
    --accent "#a0c4e8" \\
    --output docs/assets/images/feature-attribution-foundations-limits-verifiability.png

Requires: Pillow (pip install Pillow)
"""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


def parse_gradient(s: str) -> tuple[str, str]:
    parts = s.split("-")
    if len(parts) != 2:
        raise ValueError(f"Gradient must be in format '#hex1-#hex2', got {s!r}")
    return parts[0].strip(), parts[1].strip()


def hex_to_rgb(hex_color: str) -> tuple[int, int, int]:
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i : i + 2], 16) for i in (0, 2, 4))


def interpolate(c1: tuple[int, int, int], c2: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return tuple(int(a + (b - a) * t) for a, b in zip(c1, c2))


def find_font(preferred: str, size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    paths = [
        preferred,
        "/System/Library/Fonts/Helvetica.ttc",
        "/System/Library/Fonts/Helvetica.ttf",
        "/System/Library/Fonts/Arial.ttf",
        "/Library/Fonts/Arial.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
    ]
    for p in paths:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except Exception:
                continue
    return ImageFont.load_default()


def wrap_text(text: str, font: ImageFont.FreeTypeFont | ImageFont.ImageFont, max_width: int, draw: ImageDraw) -> list[str]:
    words = text.split()
    if not words:
        return [text]
    lines = []
    current = words[0]
    for word in words[1:]:
        test = current + " " + word
        bbox = draw.textbbox((0, 0), test, font=font)
        if bbox[2] - bbox[0] <= max_width:
            current = test
        else:
            lines.append(current)
            current = word
    lines.append(current)
    return lines


def create_hero_image(
    title: str,
    subtitle: str,
    subtitle2: str,
    date_label: str,
    gradient: str,
    accent_color: str,
    output: str,
    width: int = 1600,
    height: int = 900,
) -> None:
    c1_hex, c2_hex = parse_gradient(gradient)
    c1 = hex_to_rgb(c1_hex)
    c2 = hex_to_rgb(c2_hex)
    accent = hex_to_rgb(accent_color)

    img = Image.new("RGB", (width, height))
    draw = ImageDraw.Draw(img)

    # Draw gradient background
    for y in range(height):
        t = y / (height - 1) if height > 1 else 0
        color = interpolate(c1, c2, t)
        draw.line([(0, y), (width, y)], fill=color)

    # Draw a subtle geometric accent line
    line_y = height // 2 + 30
    draw.rectangle([(0, line_y), (width, line_y + 2)], fill=accent + (80,))

    # Fonts
    title_font = find_font("/System/Library/Fonts/Helvetica.ttc", 52)
    subtitle_font = find_font("/System/Library/Fonts/Helvetica.ttc", 32)
    date_font = find_font("/System/Library/Fonts/Helvetica.ttc", 18)

    # Title - centered
    title_bbox = draw.textbbox((0, 0), title, font=title_font)
    title_w = title_bbox[2] - title_bbox[0]
    title_x = (width - title_w) // 2
    title_y = height // 2 - 120
    draw.text((title_x, title_y), title, fill="white", font=title_font)

    # Subtitle
    if subtitle:
        sub_bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
        sub_w = sub_bbox[2] - sub_bbox[0]
        sub_x = (width - sub_w) // 2
        sub_y = title_y + 70
        draw.text((sub_x, sub_y), subtitle, fill=accent_color, font=subtitle_font)

    # Subtitle2
    if subtitle2:
        sub2_font = find_font("/System/Library/Fonts/Helvetica.ttc", 24)
        sub2_bbox = draw.textbbox((0, 0), subtitle2, font=sub2_font)
        sub2_w = sub2_bbox[2] - sub2_bbox[0]
        sub2_x = (width - sub2_w) // 2
        sub2_y = title_y + 110
        draw.text((sub2_x, sub2_y), subtitle2, fill=accent_color, font=sub2_font)

    # Date - bottom left
    date_bbox = draw.textbbox((0, 0), date_label, font=date_font)
    draw.text((40, height - 50), date_label, fill="#7899b8", font=date_font)

    # Brand badge - bottom right
    script_dir = Path(__file__).resolve().parent
    repo_root = script_dir.parents[1]
    badge_path = repo_root / "docs" / "assets" / "images" / "badge-overlay.png"
    if badge_path.exists():
        badge = Image.open(badge_path).convert("RGBA")
        badge_x = width - 20 - badge.width
        badge_y = height - 20 - badge.height
        img.paste(badge, (badge_x, badge_y), badge)
    else:
        # Fallback: draw a bright circle as badge placeholder
        circle_center = (width - 50, height - 50)
        draw.ellipse(
            [circle_center[0] - 30, circle_center[1] - 30, circle_center[0] + 30, circle_center[1] + 30],
            fill="white",
        )

    output_path = Path(output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    img.save(output_path, "PNG")
    print(f"Hero image saved: {output_path}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate a branded hero image")
    parser.add_argument("--title", required=True, help="Main title text")
    parser.add_argument("--subtitle", default="", help="Subtitle line 1")
    parser.add_argument("--subtitle2", default="", help="Subtitle line 2")
    parser.add_argument("--date", default="", help="Date label (e.g. 'June 10, 2026')")
    parser.add_argument("--gradient", default="#1a3a5c-#0d2137", help="Gradient colors '#top-#bottom'")
    parser.add_argument("--accent", default="#a0c4e8", help="Accent color for subtitle text")
    parser.add_argument("--output", required=True, help="Output PNG path")

    args = parser.parse_args()
    create_hero_image(
        title=args.title,
        subtitle=args.subtitle,
        subtitle2=args.subtitle2,
        date_label=args.date,
        gradient=args.gradient,
        accent_color=args.accent,
        output=args.output,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
