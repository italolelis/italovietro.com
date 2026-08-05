# ADR-0001: Amber accent colour

## Status

Accepted — 2026-08-05

## Context

The site ran the LoveIt theme's stock palette with no accent of its own. Two things were wrong with that, one aesthetic and one not.

The aesthetic problem: the site was visually indistinguishable from every other site on the same theme.

The problem that actually mattered: the theme's content-link colour `#2d96bd` measures **3.38:1 against the white page background**, below the 4.5:1 WCAG AA threshold for body text. Light-theme links were genuinely hard to read. This had been shipping. It was found by measuring against the theme's real background values while evaluating replacements, not reported as a bug.

A second failure surfaced during the same measurement pass. The speaking page's event and date text read the theme's `$global-font-secondary-color`, which measures **2.33:1 in light** and **2.18:1 in dark** — worse than the link colour, on smaller text.

## Decision

Adopt an amber/terracotta accent, defined once in the site's variable-override layer:

| Role | Light | Ratio | Dark | Ratio |
| --- | --- | --- | --- | --- |
| Link | `#b45309` | 5.02:1 | `#f59e0b` | 6.68:1 |
| Link hover | `#92400e` | 7.09:1 | `#fbbf24` | 8.60:1 |
| Muted text | `#57534e` | 7.63:1 | `#a8a29e` | 5.69:1 |

All six clear WCAG AA for body text. Ratios are against `#fff` in light and `#292a2d` in dark — the theme's actual background values.

Muted text is deliberately **not** pointed at the theme's secondary colour, since reusing a 2.33:1 value would have propagated the second failure rather than fixing it. The theme variable is left untouched for components that treat it as decoration rather than as text.

## Why amber over the alternatives

Four candidates were measured. Teal (`#0f766e` / `#2dd4bf`), indigo (`#4338ca` / `#a5b4fc`) and warm red-orange (`#c2410c` / `#fb923c`) all passed AA too, so contrast did not decide it.

Amber won because it **absorbs a colour already in use**. The speaking page typed its entries talk / podcast / host, with host rendered in a hardcoded `#e67e22` orange. Amber lets host resolve to the accent, so the palette shrank by one value instead of growing by one. None of the other three candidates could do that.

Two supporting reasons: amber picks up the warm end of the prism in the site's avatar photograph and contrasts the navy in it; and it reads distinctly against a theme whose default blue is shared with every other site using it. Red-orange was rejected as too close to a warning colour, indigo as the most generic of the four.

## Consequences

- The accent has one definition. Changing it later is one edit, not a search across four stylesheets.
- Three theme variables — not one — default to the superseded blue: the content-link colour, the global link *hover* colour, and the pagination link colour. All three must be overridden together. Overriding only the first left content links amber while global hovers, tag clouds, archive items and pagination stayed blue. A post-build assertion now fails if the old value reappears in the compiled stylesheet, which is how that gap was caught.
- The global link *rest* colour is intentionally left alone. It is a near-black used for body links and reads correctly as text rather than as an accent.
- Entry-type colours other than host still need a distinct hue. Podcast keeps a purple, as an icon colour held to the 3:1 non-text threshold rather than 4.5:1.
