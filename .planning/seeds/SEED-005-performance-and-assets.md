---
id: SEED-005
status: dormant
planted: 2026-04-06
planted_during: v1.0 milestone complete
trigger_when: performance optimization or site speed is a priority
scope: Small
---

# SEED-005: Optimize assets and add Lighthouse CI

## Why This Matters

Quick wins that improve load time and catch regressions:

1. **logo.svg is 242KB** — excessively large for an SVG. Should be <10KB after optimization (svgo). This loads on every single page.
2. **android-chrome-512x512.png is 368KB** — heavy for a mobile icon that rarely renders at full size.
3. **No Lighthouse CI** — the GitHub Actions pipeline builds but never checks performance scores. A Lighthouse audit in `pr-checks.yml` would catch performance regressions before merge.
4. **No font preloading** — Roboto and Open Sans load from Google Fonts without `<link rel="preconnect">` hints.
5. **Unused Mapbox GL JS** configured in config.toml but never used on any page — dead weight.
6. **Static images bypass Hugo's image processing** — images in `static/` don't get resized, converted to WebP, or lazy-loaded.

## When to Surface

**Trigger:** When performance, page speed, or Core Web Vitals is a goal.

This seed should be presented during `/gsd:new-milestone` when the milestone scope matches any of these conditions:
- Performance, speed, or optimization mentioned
- Lighthouse scores or Core Web Vitals
- Mobile experience improvement
- CI/CD pipeline enhancement

## Scope Estimate

**Small** — Most items are config changes or asset replacements. Lighthouse CI is a workflow addition. A few hours total.

## Breadcrumbs

- `static/images/logo.svg` — 242KB SVG (should be <10KB)
- `static/images/android-chrome-512x512.png` — 368KB icon
- `assets/css/_override.scss` — Google Fonts @import (no preconnect)
- `config.toml:248-252` — Mapbox GL JS config (unused)
- `.github/workflows/pr-checks.yml` — No Lighthouse step
- `layouts/partials/init.html` — Custom init partial (preconnect hints would go here)

## Notes

The LoveIt theme loads Font Awesome via CDN (jsDelivr). Combined with Google Fonts, that's 3 external origins without preconnect hints. Adding `<link rel="preconnect" href="https://fonts.googleapis.com">` and similar to the init partial would improve First Contentful Paint.
