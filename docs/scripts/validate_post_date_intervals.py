#!/usr/bin/env python3
"""Validate post publication date spacing and same-day collisions.

Rules are intentionally scoped to an enforcement window so older historical posts
are not retroactively blocked.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
DOCS = ROOT / "docs"
POSTS = DOCS / "_posts"

ENFORCEMENT_START = date(2026, 5, 7)
MIN_GAP_DAYS = 2


@dataclass
class PostRecord:
    path: Path
    published_on: date


def _extract_date_from_filename(path: Path) -> date | None:
    # Expected format: YYYY-MM-DD-slug.md
    parts = path.stem.split("-", 3)
    if len(parts) < 4:
        return None

    try:
        year = int(parts[0])
        month = int(parts[1])
        day = int(parts[2])
        return date(year, month, day)
    except ValueError:
        return None


def _collect_records() -> list[PostRecord]:
    records: list[PostRecord] = []
    for post in sorted(POSTS.glob("*.md")):
        published_on = _extract_date_from_filename(post)
        if not published_on:
            continue
        records.append(PostRecord(path=post, published_on=published_on))
    return sorted(records, key=lambda r: (r.published_on, r.path.name))


def main() -> int:
    records = _collect_records()
    failures: list[str] = []

    enforced = [r for r in records if r.published_on >= ENFORCEMENT_START]
    if not enforced:
        print("Publication date interval validation passed: no enforced-period posts found")
        return 0

    # No same-day duplicates in enforced window.
    by_day: dict[date, list[PostRecord]] = {}
    for rec in enforced:
        by_day.setdefault(rec.published_on, []).append(rec)

    for published_on, same_day_records in sorted(by_day.items()):
        if len(same_day_records) > 1:
            names = ", ".join(r.path.name for r in same_day_records)
            failures.append(
                f"Same-day publication collision on {published_on.isoformat()}: {names}"
            )

    # Minimum day interval between adjacent enforced posts.
    for idx in range(1, len(enforced)):
        prev = enforced[idx - 1]
        curr = enforced[idx]
        day_gap = (curr.published_on - prev.published_on).days
        if day_gap < MIN_GAP_DAYS:
            failures.append(
                "Insufficient publication gap between "
                f"{prev.path.name} ({prev.published_on.isoformat()}) and "
                f"{curr.path.name} ({curr.published_on.isoformat()}): "
                f"{day_gap} day(s), require >= {MIN_GAP_DAYS}"
            )

    if failures:
        print("Publication date interval validation failed:")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print(
        "Publication date interval validation passed: "
        f"{len(enforced)} enforced-period posts checked"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
