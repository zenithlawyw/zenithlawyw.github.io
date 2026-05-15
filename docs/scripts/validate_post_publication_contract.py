#!/usr/bin/env python3
"""Validate required publication contract fields for a post.

Usage:
  python3 docs/scripts/validate_post_publication_contract.py docs/_posts/<file>.md
  python3 docs/scripts/validate_post_publication_contract.py _posts/<file>.md
"""

from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
DOCS = ROOT / "docs"


def _parse_frontmatter(lines: list[str]) -> tuple[dict[str, str], list[str], list[str]]:
    if not lines or lines[0].strip() != "---":
        return {}, [], lines

    fm: dict[str, str] = {}
    refs: list[str] = []
    idx = 1
    in_refs = False
    in_hero = False

    while idx < len(lines):
        line = lines[idx]
        stripped = line.strip()

        if stripped == "---":
            return fm, refs, lines[idx + 1 :]

        if stripped.startswith("references:"):
            in_refs = True
            in_hero = False
            idx += 1
            continue

        if stripped.startswith("hero:"):
            in_hero = True
            in_refs = False
            idx += 1
            continue

        if in_refs:
            if stripped.startswith("-"):
                refs.append(stripped[1:].strip().strip('"').strip("'"))
                idx += 1
                continue
            if stripped == "" or line.startswith(" "):
                idx += 1
                continue
            in_refs = False

        if in_hero:
            if line.startswith("  ") and stripped.startswith("image:"):
                fm["hero.image"] = stripped.split(":", 1)[1].strip().strip('"').strip("'")
                idx += 1
                continue
            if stripped == "" or line.startswith(" "):
                idx += 1
                continue
            in_hero = False

        if ":" in stripped:
            key, raw = stripped.split(":", 1)
            key = key.strip()
            val = raw.strip().strip('"').strip("'")
            if key in {
                "image",
                "image_version",
                "references_enabled",
                "references_style",
                "references_data_file",
            }:
                fm[key] = val

        idx += 1

    return fm, refs, []


def _resolve_post_path(arg: str) -> Path:
    p = Path(arg)
    if p.is_absolute():
        return p
    if arg.startswith("_posts/"):
        return DOCS / arg
    return ROOT / arg


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python3 docs/scripts/validate_post_publication_contract.py docs/_posts/<file>.md")
        return 2

    post_path = _resolve_post_path(sys.argv[1])
    if not post_path.exists():
        print(f"ERROR: post file not found: {post_path}")
        return 2

    lines = post_path.read_text(encoding="utf-8").splitlines()
    fm, refs, body_lines = _parse_frontmatter(lines)
    body = "\n".join(body_lines)

    failures: list[str] = []

    image = fm.get("image", "")
    hero_image = fm.get("hero.image", "")
    image_version = fm.get("image_version", "")

    if not image:
        failures.append("Missing frontmatter field: image")
    if not image_version:
        failures.append("Missing frontmatter field: image_version")
    if not hero_image:
        failures.append("Missing frontmatter field: hero.image")
    if image and hero_image and image != hero_image:
        failures.append(f"Frontmatter mismatch: image ({image}) != hero.image ({hero_image})")

    if fm.get("references_enabled", "").lower() != "true":
        failures.append("Missing or invalid frontmatter field: references_enabled must be true")
    if fm.get("references_style", "").lower() != "ieee":
        failures.append("Missing or invalid frontmatter field: references_style must be ieee")
    if fm.get("references_data_file", "") != "references":
        failures.append("Missing or invalid frontmatter field: references_data_file must be references")
    if not refs:
        failures.append("Frontmatter references list is missing or empty")

    if "{% include references/cite.html" not in body:
        failures.append("Body missing inline citation include: {% include references/cite.html key=\"...\" %}")
    if "{% include references/list.html %}" in body:
        failures.append("Body must not include {% include references/list.html %}; post layout renders references automatically")

    if "<details" not in body or "<summary>" not in body or "</details>" not in body:
        failures.append("Body missing default-collapsed technical appendix details block")

    if not re.search(r"<details\s+markdown=['\"]1['\"]>", body):
        failures.append("Technical appendix details must use markdown-enabled rendering: <details markdown=\"1\">")

    appendix_heading = "## Technical Appendix"
    appendix_idx = body.find(appendix_heading)
    if appendix_idx == -1:
        failures.append("Body missing section heading: ## Technical Appendix")
    else:
        appendix_only_headings = [
            "## Citability Snapshot and Decision Metrics",
            "## Implementation Citability Snapshot",
            "## Authoritative Baselines for Implementation",
            "## Control Comparison Matrix for Early Production",
            "## E-E-A-T and Author Traceability",
            "## Technical Term Definitions",
        ]
        for heading in appendix_only_headings:
            heading_idx = body.find(heading)
            if heading_idx != -1 and heading_idx < appendix_idx:
                failures.append(f"Machine-focused section must be moved into Technical Appendix: {heading}")

    if "not legal advice" not in body.lower():
        failures.append("Body missing legal caveat phrase: not legal advice")

    if failures:
        print("Post publication contract validation failed:")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print(f"Post publication contract validation passed: {post_path.name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())