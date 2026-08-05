# ADR-0003: Logo redrawn as real vector, carrying its own accent

## Status

Accepted — 2026-08-05

## Context

`logo.svg` was **247KB** for a mark displayed at 40px.

It contained a traced bitmap wearing an SVG costume: sixteen `<path>` elements stepping one coordinate at a time, with values like `313.99686274509804` and `484.99686274509804`. That is the signature of an auto-traced raster image, not a drawn vector. Only the outer hexagon was genuine — a hand-authored `<polygon>`. The traced group also carried a second, ragged hexagon outline overlapping the clean one, which is why the border looked lumpy at large sizes.

The mark was also monochrome `currentColor`, and because it renders through an `<img>` — the theme's image partial emits one — the host document's colour never cascades into it. It therefore always painted black. Four CSS rules and an animated `filter` transition existed purely to `invert(1) brightness(1.2)` it for the dark theme and for `prefers-color-scheme: dark`.

Once the site adopted the amber accent (ADR-0001), the logo was the only element left with no relationship to the palette.

## Decision

Redraw the mark by hand as clean vector primitives, preserving what it depicts: a hexagon containing a coffee cup, three steam wisps, and a `>` shell prompt.

**704 bytes.** A 99.7% reduction.

Give the mark its own colour, `#c2680a`, rather than relying on inheritance:

| Background | Ratio | Threshold |
| --- | --- | --- |
| `#fff` (light) | 3.98:1 | 3:1 non-text |
| `#292a2d` (dark) | 3.61:1 | 3:1 non-text |

One value clears the non-text threshold on both, so a single file serves both themes. `#d97706` also qualified (3.19:1 / 4.50:1) but with less headroom on white; the accent's own `#b45309` and `#f59e0b` each fail on one background, which is why the logo takes a third amber rather than reusing a link colour.

## Consequences

- The four per-theme inversion rules and the `filter` transition are deleted. The logo needs no CSS to be correct in either theme.
- `currentColor` is **not** available here and should not be reintroduced. Anything rendered through `<img>` is an isolated document; colour has to be baked in. Inlining the SVG in the template would restore inheritance, at the cost of losing browser caching of the asset.
- The logo is a third amber, so the palette now holds three: two link colours from ADR-0001 plus this one. This is deliberate — the constraint that produced it (must work on both backgrounds simultaneously, because the header is one file across both themes) does not apply to anything else.
- **Two copies of this file exist**, in `assets/images/` and `static/images/`. Hugo publishes the `assets/` copy; the `static/` one is shadowed and was never served. Both were updated so neither can be mistaken for live. Consolidating to one is unresolved and left as separate work.
- A post-build assertion fails if the deployed mark loses the accent or exceeds 4KB, so a traced export cannot silently replace it.
- The redraw is an interpretation of the traced outline, not a recovery of an original design file. If a real source exists, it should supersede this.
