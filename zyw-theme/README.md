# zyw-theme Reference and Citation Guide

This guide explains how to add, render, and maintain references in posts using a synthesized approach that is:

- GitHub Pages compatible (no custom plugins required)
- Customizable per post
- Extensible for centralized reference data

## Why this approach

This implementation combines practical ideas from:

- Jekyll Scholar workflows (structured citations and bibliography rendering)
- Data-driven Jekyll references (centralized metadata + per-post reference lists)

but keeps the runtime 100% Liquid/include based, so it works in constrained builds where custom plugins are unavailable.

## What is included in the theme

The theme now provides:

- `_includes/references/list.html`
  - Renders a full references section
  - Reads from page front matter and optionally from `site.data`
- `_includes/references/item.html`
  - Renders one reference entry
  - Supports either plain text or structured fields (`authors`, `year`, `title`, `doi`, etc.)
- `_includes/references/cite.html`
  - Renders inline citations linked to the references section
  - Supports parenthetical or textual citation style
- `_layouts/post.html`
  - Automatically includes `references/list.html` after article body content

## Quick start

### 1) Add references to a post front matter

Use either simple string entries or object entries.

```yaml
---
layout: post
title: "My article"
references:
  - ref1
  - ref2
---
```

or:

```yaml
---
layout: post
title: "My article"
references:
  - id: ref1
  - id: ref2
---
```

If `ref1`/`ref2` exist in `_data/references.yml`, the theme resolves and formats them automatically.

### 2) Add centralized reference data

Create `_data/references.yml`:

```yaml
ref1:
  authors: "Matsumoto, Y."
  year: "2008"
  title: "The Ruby Programming Language"
  publisher: "O'Reilly Media"

ref2:
  authors: "Myung, I. J."
  year: "2003"
  title: "Tutorial on maximum likelihood estimation"
  journal: "Journal of Mathematical Psychology"
  volume: "47"
  issue: "1"
  pages: "90-100"
  doi: "10.1016/S0022-2496(02)00028-7"
```

### 3) Use inline citations in markdown

Inside post content:

```liquid
{% include references/cite.html key="ref2" %}
```

Textual form:

```liquid
{% include references/cite.html key="ref2" mode="textual" %}
```

Harvard style for a single citation:

```liquid
{% include references/cite.html key="ref2" style="harvard" %}
```

APA style for a single citation:

```liquid
{% include references/cite.html key="ref2" style="apa" %}
```

Custom label:

```liquid
{% include references/cite.html key="ref2" label="[2]" %}
```

All generated citation links point to the matching reference anchor in the references section.

## Supported per-post settings

You can tune behavior with front matter:

```yaml
---
references_enabled: true
references_title: "References"
references_heading_id: "references"
references_data_file: "references"
references_style: "ieee"
references:
  - ref1
  - id: ref2
---
```

### Field notes

- `references_enabled`
  - `true` (default): render references section
  - `false`: suppress section for this post
- `references_title`
  - Heading text for bibliography section
- `references_heading_id`
  - HTML id used by heading anchors (for custom links)
- `references_data_file`
  - Selects `site.data[references_data_file]`
  - Default is `references`, so `_data/references.yml`
- `references_style`
  - Default is `ieee`
  - Supported values: `ieee`, `apa`, `harvard`
  - Controls both inline citation formatting and generated reference list style

### Site-wide style default

Set a global default in your site config:

```yaml
references_style: ieee
```

or:

```yaml
references:
  style: ieee
```

## Reference entry formats

`references/item.html` supports two models:

### A) Structured reference object

Use fields like:

- `authors`
- `year`
- `title`
- `journal`
- `book`
- `volume`
- `issue`
- `pages` or `first_page` + `last_page`
- `publisher`
- `doi`
- `url`
- `arXiv` or `arxiv`
- `note`

Optional style-specific preformatted fields:

- `ieee`
- `apa`
- `harvard`

If present, the selected style-specific field takes priority over generated formatting.

### B) Plain text reference

If you provide `text`, the include renders it directly (Markdown supported):

```yaml
ref3:
  text: "OpenSSF. Supply-chain security framework. https://example.org/report"
```

## Integrating with existing manual references

If a post currently uses manual footnote-style anchors (for example `[#ref1]` with explicit `<a id="ref1">` blocks), migrate gradually:

1. Move each reference item into `_data/references.yml`.
2. Replace manual inline links with `references/cite.html` includes.
3. Keep existing `## References` text temporarily if needed.
4. Remove manual reference section once generated references match expected output.

## Optional customizations

### Change style/classes globally

Update classes in:

- `_includes/references/list.html`
- `_includes/references/item.html`
- `_includes/references/cite.html`

### Use multiple reference datasets

You can keep different files, such as:

- `_data/references.yml`
- `_data/security_refs.yml`
- `_data/research_refs.yml`

Then in a post:

```yaml
references_data_file: security_refs
```

### Use per-post inline objects (no `_data` dependency)

```yaml
---
references:
  - authors: "Team, A."
    year: "2026"
    title: "Incident report"
    url: "https://example.org/report"
---
```

## Author workflow recommendation

1. Add source URLs in your draft while researching.
2. Normalize reference keys in `_data/references.yml`.
3. Use `references/cite.html` for inline citations.
4. Keep `page.references` list minimal and post-specific.
5. Let `post` layout render the final references section automatically.

## Notes on GitHub Pages compatibility

This approach intentionally avoids custom Jekyll plugins.

If your deployment path uses `github-pages` gem restrictions, includes + Liquid + `_data` remain the safest reference system foundation.
