---
phase: 05-content-and-publishing
plan: 01
subsystem: content
tags: [hugo, talks, shortcodes, multilingual, voice, content-rewrite]

requires:
  - phase: 04-shortcode-and-layout
    provides: "talk shortcode with title/event/date/type/video_url/slides_url parameters"

provides:
  - "English talks page with authentic intro paragraph and 7 rewritten descriptions"
  - "Portuguese talks page fully migrated to talk shortcode format with translated content"

affects: [05-02-speaking-page-rename, future-content-phases]

tech-stack:
  added: []
  patterns:
    - "Talk shortcodes used in both EN and PT-BR files (consistent parameter parity)"
    - "Intro paragraph before first section heading to set page tone"
    - "Portuguese section headings: Palestras, Participacoes em Podcasts"

key-files:
  created: []
  modified:
    - content/talks/index.en.md
    - content/talks/index.pt-br.md

key-decisions:
  - "Talk titles remain in English in both language versions (talks were given in English)"
  - "Portuguese section headings translated: Palestras / Participacoes em Podcasts / The Critical Channel (brand name kept EN)"
  - "Voice pattern: descriptions written in first person with personal context (why the talk, what pain it came from)"

patterns-established:
  - "No em dashes in any content (use periods or parentheses instead)"
  - "Descriptions 2-4 sentences, personal and experience-driven, not conference-abstract style"
  - "Intro paragraph 2-4 sentences before first section heading"

requirements-completed: [CONT-05, CONT-06, PUB-02]

duration: 2min
completed: 2026-04-03
---

# Phase 5 Plan 01: Talks Content Rewrite Summary

**Rewrote all 7 talk descriptions in authentic first-person voice and fully migrated the Portuguese talks page from old markdown list format to talk shortcodes**

## Performance

- **Duration:** 2 min
- **Started:** 2026-04-03T20:06:38Z
- **Completed:** 2026-04-03T20:08:53Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Added intro paragraphs to both EN and PT-BR talks pages setting personal context for why Italo speaks
- Rewrote all 7 talk descriptions with personal anecdotes and opinions (from conference-abstract style to first-person voice)
- Migrated PT-BR talks page from old manual markdown list format to talk shortcode structure matching EN version
- Translated all content into natural informal Brazilian Portuguese

## Task Commits

1. **Task 1: Rewrite English talks page in authentic voice** - `9b478ad` (feat)
2. **Task 2: Create Portuguese talks page with shortcodes** - `92f4d29` (feat)

**Plan metadata:** (included in final docs commit)

## Files Created/Modified

- `content/talks/index.en.md` - Added intro paragraph, rewrote all 7 talk descriptions in authentic voice; no em dashes
- `content/talks/index.pt-br.md` - Fully migrated from manual markdown list to talk shortcodes; translated intro and all 7 descriptions

## Decisions Made

- Talk titles remain in English in both language versions (talks were delivered in English; changing them would be confusing)
- Portuguese heading for podcast section: "Participacoes em Podcasts" (natural Brazilian Portuguese)
- "The Critical Channel" section heading kept in English as it is a brand name

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Both EN and PT-BR talks pages ready for Phase 5 Plan 02 (page rename from "Talks and Podcasts" to "Speaking" at /speaking/)
- Shortcode parameters identical between EN and PT-BR files, enabling clean diff checks in future plans

---
*Phase: 05-content-and-publishing*
*Completed: 2026-04-03*
