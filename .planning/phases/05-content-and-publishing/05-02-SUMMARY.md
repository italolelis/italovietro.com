---
phase: 05-content-and-publishing
plan: "02"
subsystem: ui
tags: [hugo, content, speaking, redirects, navigation, multi-language]

# Dependency graph
requires:
  - phase: 05-01
    provides: Speaking page content rewritten in authentic voice with shortcodes

provides:
  - Speaking page accessible at /speaking/ (EN) and /palestras/ (PT-BR)
  - Hugo aliases redirecting /talks/ and /pt-br/talks/ to new URLs
  - Updated nav menus for both English and Portuguese
  - Renamed layouts directory from layouts/talks/ to layouts/speaking/
  - Talk list corrected (removed non-existent talks, added missing ones)

affects: [deployment, navigation, speaking-page, multi-language]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Hugo aliases for clean URL redirects without server config"
    - "Content directory rename mirrors URL slug change"
    - "Layout directory renamed to match content directory"

key-files:
  created:
    - layouts/speaking/single.html
  modified:
    - content/speaking/index.en.md
    - content/speaking/index.pt-br.md
    - config.toml

key-decisions:
  - "Layout renamed from layouts/talks/ to layouts/speaking/ to match content directory"
  - "Three non-existent talks removed, three missing talks added (DevTalks Romania, CTO Craft Con Berlin, Yeka interview)"
  - "Critical Channel description corrected to reflect 4 co-hosts, not solo"
  - "Intro paragraph removed from speaking page; featured image opens the page directly"

patterns-established:
  - "URL rename pattern: rename content dir + add alias for old URL in frontmatter + update config.toml menu"

requirements-completed: [PUB-01, PUB-02, PUB-03]

# Metrics
duration: 40min
completed: 2026-04-06
---

# Phase 05 Plan 02: Speaking Page Rename Summary

**Talking page renamed from /talks/ to /speaking/ with Hugo alias redirects, corrected talk list (3 removed, 3 added), and updated nav menus in both EN and PT-BR.**

## Performance

- **Duration:** ~40 min
- **Started:** 2026-04-06T22:30:00Z
- **Completed:** 2026-04-06T23:10:00Z
- **Tasks:** 2 (1 auto + 1 human-verify)
- **Files modified:** 5

## Accomplishments

- Speaking page now lives at /speaking/ (EN) and /palestras/ (PT-BR) with working redirects from old /talks/ URLs
- Talk list audited and corrected: removed 3 non-existent talks, added DevTalks Romania 2025, CTO Craft Con Berlin 2024, and Yeka interview
- Layout directory moved from layouts/talks/ to layouts/speaking/ to align with new URL structure
- Nav menus updated in config.toml for both languages, pointing to new canonical URLs
- Featured image opens the page directly without an introductory paragraph

## Task Commits

Each task was committed atomically:

1. **Task 1: Rename content directory, update frontmatter, update config.toml** - `584e9d4` (feat)
2. **Task 2 (human-verify fixes): Rewrite speaking page content, add missing talks** - `0a4d788` (feat)
3. **Task 2 (cleanup): Remove old layouts/talks/ directory** - `70d8def` (chore)

## Files Created/Modified

- `content/speaking/index.en.md` - Renamed from talks/, frontmatter updated with alias and slug, content corrected
- `content/speaking/index.pt-br.md` - Renamed from talks/, frontmatter updated with alias and slug, content corrected
- `config.toml` - EN menu updated to Speaking//speaking/; PT-BR menu URL updated to /palestras/
- `layouts/speaking/single.html` - Created (moved from layouts/talks/single.html)
- `layouts/talks/single.html` - Deleted (superseded by layouts/speaking/)

## Decisions Made

- Layout directory renamed from `layouts/talks/` to `layouts/speaking/` to match the new content directory and URL structure, discovered during visual verification.
- Three talks removed that did not exist in reality (tech lead, service meshes, hexagonal architecture).
- Three talks added that were missing: DevTalks Romania 2025, CTO Craft Con Berlin 2024, Yeka interview.
- Critical Channel description corrected: 4 co-hosts, not a solo podcast.
- Intro paragraph removed; the featured image now opens the speaking page directly for cleaner visual flow.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Layout directory not renamed during content rename**
- **Found during:** Task 2 (visual verification)
- **Issue:** `layouts/talks/single.html` still referenced old path after content was renamed; Hugo was not picking up the new layout correctly
- **Fix:** Created `layouts/speaking/single.html` with identical content, then removed `layouts/talks/single.html`
- **Files modified:** layouts/speaking/single.html (created), layouts/talks/single.html (deleted)
- **Verification:** Hugo build passed; speaking page rendered correctly
- **Committed in:** 0a4d788 and 70d8def (part of visual verification fixes)

**2. [Rule 1 - Bug] Talk list had 3 non-existent entries and 3 missing real talks**
- **Found during:** Task 2 (content review during visual verification)
- **Issue:** Content included talks that were never given; three actual talks from 2024-2025 were missing
- **Fix:** Removed non-existent talks; added DevTalks Romania 2025, CTO Craft Con Berlin 2024, Yeka interview; fixed Critical Channel description
- **Files modified:** content/speaking/index.en.md, content/speaking/index.pt-br.md
- **Verification:** User approved corrected content list
- **Committed in:** 0a4d788

---

**Total deviations:** 2 auto-fixed (2 bugs found during visual verification)
**Impact on plan:** Both fixes were necessary for correctness. Layout rename required for Hugo routing; talk list corrections required for content accuracy. No scope creep.

## Issues Encountered

None beyond the two bugs documented above. Both were caught during the human-verify checkpoint and resolved before user approval.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Phase 05 is now complete. All publishing requirements fulfilled:
- Reading list at /recommended-reading/ with redirects from old URLs (Phase 05-01)
- Speaking page at /speaking/ with redirects from /talks/ (this plan)
- All nav menus updated in both EN and PT-BR
- Site builds and deploys cleanly

No blockers for the next milestone.

---
*Phase: 05-content-and-publishing*
*Completed: 2026-04-06*
