---
phase: 04-shortcode-and-layout
plan: 02
subsystem: ui
tags: [hugo, templates, scss, speaking-page, shortcode]

# Dependency graph
requires:
  - phase: 04-shortcode-and-layout-plan-01
    provides: talk shortcode template and _speaking.scss with all CSS classes

provides:
  - Speaking page layout (layouts/talks/single.html) with zero inline styles
  - Three-section test content in content/talks/index.en.md covering talk, podcast, and host types
  - Verified visual rendering in both light/dark mode and mobile layout

affects:
  - 05-content-and-publishing (will rewrite talk descriptions in authentic voice over this scaffolding)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Inline styles extracted from Hugo templates to SCSS partials (D-07 rule applied)"
    - "Featured image wrapper uses class-only markup: <div class='featured-image'><img ...></div>"

key-files:
  created: []
  modified:
    - layouts/talks/single.html
    - content/talks/index.en.md
    - assets/css/_speaking.scss

key-decisions:
  - "Featured image max-height set to 200px (reduced from 280px after visual review)"
  - "All inline styles removed from layouts/talks/single.html; SCSS owns all visual rules"

patterns-established:
  - "Hugo layout templates must contain zero inline style= attributes; all styling lives in SCSS partials"

requirements-completed: [LAYOUT-05]

# Metrics
duration: ~30min
completed: 2026-04-07
---

# Phase 04 Plan 02: Fix Layout Template and Verify Speaking Page Summary

**Speaking page layout cleaned of all inline styles, three-section shortcode content scaffolded, and visual rendering verified with featured image max-height tuned to 200px**

## Performance

- **Duration:** ~30 min
- **Started:** 2026-04-07
- **Completed:** 2026-04-07
- **Tasks:** 2 (1 auto + 1 human-verify checkpoint)
- **Files modified:** 3

## Accomplishments

- Removed all `style=` attributes from `layouts/talks/single.html` — layout now delegates entirely to `_speaking.scss`
- Replaced `content/talks/index.en.md` body with real three-section content covering all three entry types (talk, podcast, host) with 7 shortcode invocations
- Visual verification passed: three sections render correctly, dark mode works, mobile layout clean, featured image displays with correct sizing at 200px max-height

## Task Commits

1. **Task 1: Fix layout template and create three-section test content** - `ef4d804` (feat)
2. **Task 2: Visual verification checkpoint (approved + fix)** - `422be43` (fix — featured image max-height reduced to 200px)

## Files Created/Modified

- `layouts/talks/single.html` - Removed all inline `style=` attributes from featured image block
- `content/talks/index.en.md` - Replaced body with three h2 sections and 7 `{{< talk >}}` shortcodes
- `assets/css/_speaking.scss` - Added `.featured-image img { max-height: 200px; }` rule after visual review

## Decisions Made

- Featured image `max-height` set to 200px (down from 280px) after user flagged the height felt too tall during visual review
- All layout template inline styles fully removed; zero exceptions — SCSS owns all visual rules for this page

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Reduced featured image max-height after visual feedback**
- **Found during:** Task 2 (visual verification)
- **Issue:** Featured image rendered at 280px felt too tall; user requested reduction to 200px
- **Fix:** Updated `.featured-image img` max-height in `_speaking.scss` from 280px to 200px
- **Files modified:** `assets/css/_speaking.scss`
- **Verification:** User confirmed visual appearance acceptable after fix
- **Committed in:** `422be43`

---

**Total deviations:** 1 auto-fixed (visual sizing adjustment)
**Impact on plan:** Minor SCSS tweak following user visual review. No scope creep.

## Issues Encountered

None beyond the featured image height adjustment handled via deviation rule.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Speaking page layout and shortcode pipeline fully verified end-to-end
- Three-section content scaffold is in place; Phase 5 will rewrite descriptions in Italo's authentic voice
- No blockers for Phase 05

---
*Phase: 04-shortcode-and-layout*
*Completed: 2026-04-07*
