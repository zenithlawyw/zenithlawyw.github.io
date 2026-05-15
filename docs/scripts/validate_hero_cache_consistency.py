#!/usr/bin/env python3
"""Validate hero image cache-busting consistency across templates.

Checks:
1. Post-card preview images use image_version query parameter logic.
2. Article hero image helper uses hero.image_version fallback to image_version.
3. Article hero helper appends version query parameter (?v= or &v=).
"""

from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
THEME = ROOT / "zyw-theme"

POST_CARD = THEME / "_includes" / "views" / "post-card.html"
GET_HERO = THEME / "_includes" / "functions" / "get_hero.html"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def main() -> int:
    failures: list[str] = []

    if not POST_CARD.exists():
        failures.append(f"Missing required template: {POST_CARD}")
    if not GET_HERO.exists():
        failures.append(f"Missing required template: {GET_HERO}")

    if failures:
        print("Hero cache consistency validation failed:")
        for failure in failures:
            print(f"- {failure}")
        return 1

    post_card = _read(POST_CARD)
    get_hero = _read(GET_HERO)

    # Preview thumbnail cache-busting checks.
    if "include.post.image_version" not in post_card:
        failures.append("Post-card template missing include.post.image_version usage")
    if "?v=" not in post_card and "append: '?v='" not in post_card:
        failures.append("Post-card template missing version query parameter append logic")

    # Article hero cache-busting checks.
    if "hero.image_version" not in get_hero:
        failures.append("Hero helper missing hero.image_version lookup")
    if "image_version" not in get_hero:
        failures.append("Hero helper missing image_version fallback lookup")
    if "?v=" not in get_hero and "&v=" not in get_hero:
        failures.append("Hero helper missing version query parameter append logic")

    if failures:
        print("Hero cache consistency validation failed:")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("Hero cache consistency validation passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
