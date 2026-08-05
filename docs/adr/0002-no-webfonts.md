# ADR-0002: No webfonts

## Status

Accepted — 2026-08-05

## Context

The site's variable-override layer opened with a Google Fonts import pulling **Roboto 400/700 and Open Sans 400/700** — four font files — and then used them for exactly one thing:

```scss
@import url('https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&family=Open+Sans:wght@400;700&display=swap');
$code-font-family: Roboto, Source Code Pro, Menlo, Consolas, Monaco, monospace;
```

Three problems, in ascending order of severity:

1. **Open Sans was referenced nowhere.** Not in any stylesheet, not in the config, not in a template. Two of the four downloaded files were pure waste.

2. **The import is render-blocking.** A CSS `@import url(...)` survives SCSS compilation as a CSS at-rule, so it sits at the top of the compiled stylesheet and chains an extra round trip to a third-party host before text can paint.

3. **Roboto is proportional, and it was named first for code.** Code blocks were rendering in a variable-width face, so indentation and column alignment did not survive. The webfont was not merely unnecessary — it was actively degrading the one thing it was loaded for.

Body text was never affected. It already resolved to the theme's `system-ui, -apple-system, Segoe UI, Roboto, …` stack, where `system-ui` wins on every target platform.

## Decision

Remove the import entirely. Do not replace it with a self-hosted font.

Code blocks use a system monospace stack:

```
ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, "Liberation Mono", monospace
```

`ui-monospace` resolves to the platform's intended monospace face; the named fallbacks cover macOS, Windows and Linux for older engines.

A self-hosted monospace webfont (JetBrains Mono was the candidate) was considered and rejected. Body text already uses a system stack, so adding a network request and a flash-of-unstyled-text risk purely to restyle code blocks is a poor trade for a personal site.

## Consequences

- Zero webfont requests. Nothing render-blocking remains in the compiled stylesheet, and no third-party font host is contacted — which also means loading the site no longer hands a visitor's IP address to another company.
- Code blocks render in a real monospace face, fixing the alignment defect as a side effect of removing the font rather than as separate work.
- Typography is now entirely at the mercy of the visitor's OS. That is the intended trade: instant text over controlled letterforms.
- `Roboto` still appears in the compiled stylesheet, in the theme's `system-ui, -apple-system, Segoe UI, Roboto, …` body stack. This is a **font name, not a download** — it only resolves on systems that already ship Roboto, chiefly Android. Do not read those occurrences as a leftover webfont reference.
- Post-build assertions fail if `fonts.googleapis.com` or `fonts.gstatic.com` appears anywhere in the generated output, so a future edit cannot quietly reintroduce a webfont.
