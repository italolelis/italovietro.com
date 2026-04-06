---
phase: 04-shortcode-and-layout
plan: 01
subsystem: speaking
tags: [shortcode, scss, speaking, dark-mode, responsive]
dependency_graph:
  requires: []
  provides: [talk-shortcode, speaking-scss]
  affects: [layouts/talks/single.html, assets/css/_custom.scss]
tech_stack:
  added: []
  patterns: [hugo-shortcode-bem, scss-dark-mode-auto-mobile]
key_files:
  created:
    - layouts/shortcodes/talk.html
    - assets/css/_speaking.scss
  modified:
    - assets/css/_custom.scss
    - layouts/talks/single.html
decisions:
  - "Font Awesome icons used for type differentiation: fa-microphone (talk), fa-podcast (podcast), fa-headphones (host)"
  - "Inline styles extracted from layouts/talks/single.html to _speaking.scss (D-07)"
metrics:
  duration: "~2 minutes"
  completed_date: "2026-04-03"
  tasks_completed: 2
  files_changed: 4
---

# Phase 4 Plan 1: Talk Shortcode and Speaking SCSS Summary

**One-liner:** Hugo `{{< talk >}}` shortcode with BEM structure and `_speaking.scss` partial covering light/dark/auto/mobile styles for the speaking page.

## What Was Built

Created the `{{< talk >}}` shortcode following the exact `book.html` pattern, and a dedicated `_speaking.scss` SCSS partial following the `_reading-list.scss` structure.

### Task 1: Talk shortcode template (`layouts/shortcodes/talk.html`)

- Six parameters: `title`, `event`, `date`, `type` (default: "talk"), `video_url`, `slides_url`
- Body content via `trim .Inner "\n" | .Page.RenderString`
- BEM class names: `.talk-entry`, `.talk-entry--{{ $type }}`, `.talk-entry__header`, `.talk-entry__title`, `.talk-entry__meta`, `.talk-entry__event`, `.talk-entry__date`, `.talk-entry__links`, `.talk-entry__description`
- Type-based Font Awesome icons: `fa-microphone` (talk), `fa-podcast` (podcast), `fa-headphones` (host) inside `.talk-entry__type-icon` span
- Video/slides rendered as inline "Watch" / "Slides" links with `&middot;` separator

### Task 2: Speaking SCSS partial and import (`assets/css/_speaking.scss`, `assets/css/_custom.scss`)

- `.talk-entry` base styles matching `book-entry` typography scale
- Type-based icon colors: `$single-link-color` (talk), `#9b59b6` purple (podcast), `#e67e22` orange (host)
- `.featured-image` and `.featured-image img` styles extracted from `single.html` inline styles
- Dark mode block via `[theme=dark]` selectors
- Auto theme block via `@media (prefers-color-scheme: dark) { [theme=auto] }` 
- Mobile breakpoint at 680px (title font-size, featured image height)
- `@import "speaking"` added to `_custom.scss` after existing `@import "reading-list"`

## Verification

Hugo build completed successfully with no SCSS compilation errors (315-345ms, 73 pages).

## Deviations from Plan

### Auto-applied Improvements

**1. [Rule 2 - Missing functionality] Extracted inline styles from layouts/talks/single.html**
- **Found during:** Task 2
- **Issue:** Plan (D-07) explicitly required extracting inline styles from `layouts/talks/single.html`. The `.featured-image` styles were added to SCSS but the original HTML still had redundant inline `style=""` attributes.
- **Fix:** Removed inline `style` attributes from the `<div class="featured-image">` and `<img>` in `layouts/talks/single.html`, letting the new SCSS rules take over.
- **Files modified:** `layouts/talks/single.html`
- **Commit:** 66712b2

## Known Stubs

None — the shortcode is fully functional and ready for content migration in Phase 5.

## Self-Check

Files created:

- FOUND: layouts/shortcodes/talk.html
- FOUND: assets/css/_speaking.scss
- FOUND: assets/css/_custom.scss

Commits:
- FOUND: 6dbfd87 (feat(04-01): create talk shortcode template)
- FOUND: 66712b2 (feat(04-01): create speaking SCSS partial and wire import)

## Self-Check: PASSED
