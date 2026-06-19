#!/usr/bin/env python3
"""Validate hero image governance for posts.

Checks:
1. No duplicate hero image path usage across posts.
2. Referenced hero image files exist.
3. For posts on/after enforcement date, favicon badge is present in at least one corner.
   Compatible with process-hero-images.py (24px configurable-position favicon stamp).
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date
from pathlib import Path
import warnings

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
DOCS = ROOT / "docs"
POSTS = DOCS / "_posts"
IMAGES = DOCS / "assets" / "images"

BRAND_BADGE_ENFORCEMENT_START = date(2026, 4, 28)

# Detection window: favicon is 24x24 with 12px margin (offset 36 from edges).
# 50x50 captures the 24px favicon fully (331/2500≈13% bright pixels) and catches
# enough of the old 64px stamp (offset 84, overlap 30x30≈900px → ~20% of window).
FAVICON_CROP_SIZE = 50
FAVICON_BRIGHT_THRESHOLD = 200
FAVICON_BRIGHT_RATIO = 0.08  # well below real favicon (13-20%); above natural noise (~2-3%)


def _parse_frontmatter(post_path: Path) -> dict[str, str]:
    lines = post_path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0].strip() != "---":
        return {}

    values: dict[str, str] = {}
    in_fm = True
    for line in lines[1:]:
        if in_fm and line.strip() == "---":
            break
        if ":" not in line:
            continue
        key, raw = line.split(":", 1)
        key = key.strip()
        val = raw.strip().strip('"').strip("'")
        if key in {"image", "date"}:
            values[key] = val
    return values


def _post_date_from_filename(path: Path) -> date | None:
    name = path.stem
    try:
        y, m, d = name.split("-", 3)[:3]
        return date(int(y), int(m), int(d))
    except Exception:
        return None


def _corner_bright_ratio(image: Image.Image, corner: str, crop: int) -> float:
    """Return fraction of bright pixels in a *crop*x*crop* corner region."""
    w, h = image.size
    cw = min(crop, w)
    ch = min(crop, h)

    if corner == "top-left":
        left, top = 0, 0
    elif corner == "top-right":
        left, top = w - cw, 0
    elif corner == "bottom-left":
        left, top = 0, h - ch
    elif corner == "bottom-right":
        left, top = w - cw, h - ch
    else:
        return 0.0

    region = image.crop((left, top, left + cw, top + ch))
    with warnings.catch_warnings():
        warnings.filterwarnings("ignore", category=DeprecationWarning, message=".*getdata.*")
        pixels = list(region.getdata())

    if not pixels:
        return 0.0

    bright = sum(1 for r, g, b in pixels if (r + g + b) / 3 >= FAVICON_BRIGHT_THRESHOLD)
    return bright / len(pixels)


def _has_favicon_signal(image_path: Path) -> bool:
    """Check for favicon bright-pixel signal in any corner.

    Compatible with process-hero-images.py which stamps a 24x24 favicon at
    any configurable position (top-left, top-right, bottom-left, bottom-right).
    """
    image = Image.open(image_path).convert("RGB")

    for corner in ("top-left", "top-right", "bottom-left", "bottom-right"):
        ratio = _corner_bright_ratio(image, corner, FAVICON_CROP_SIZE)
        if ratio >= FAVICON_BRIGHT_RATIO:
            return True

    return False


@dataclass
class PostImageRecord:
    post: Path
    image_rel: str
    image_path: Path
    published_on: date | None


def main() -> int:
    records: list[PostImageRecord] = []
    failures: list[str] = []

    for post in sorted(POSTS.glob("*.md")):
        fm = _parse_frontmatter(post)
        image_rel = fm.get("image", "").strip()
        if not image_rel.startswith("/assets/images/"):
            continue

        image_path = DOCS / image_rel.lstrip("/")
        published_on = _post_date_from_filename(post)
        records.append(PostImageRecord(post=post, image_rel=image_rel, image_path=image_path, published_on=published_on))

    # Duplicate check
    seen: dict[str, list[Path]] = {}
    for rec in records:
        seen.setdefault(rec.image_rel, []).append(rec.post)

    for image_rel, posts in sorted(seen.items()):
        if len(posts) > 1:
            failures.append(f"Duplicate hero image path {image_rel} used by: {', '.join(str(p.name) for p in posts)}")

    # Existence + badge checks
    for rec in records:
        if not rec.image_path.exists():
            failures.append(f"Missing hero image file for {rec.post.name}: {rec.image_path}")
            continue

        if rec.published_on and rec.published_on >= BRAND_BADGE_ENFORCEMENT_START:
            if not _has_favicon_signal(rec.image_path):
                failures.append(
                    f"Missing favicon badge signal (no corner passes bright-pixel check) for {rec.post.name} ({rec.image_rel})"
                )

    if failures:
        print("Hero image validation failed:")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print(f"Hero image validation passed: {len(records)} posts checked")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
