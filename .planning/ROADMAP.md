# Roadmap: italovietro.com

## Milestones

- ✅ **v1.0 Reading List Redesign** - Phases 1-3 (shipped 2026-04-06)
- 🚧 **v1.1 Speaking Page Redesign** - Phases 4-5 (in progress)

## Phases

<details>
<summary>✅ v1.0 Reading List Redesign (Phases 1-3) - SHIPPED 2026-04-06</summary>

### Phase 1: CSS Foundation
**Goal**: The reading list page renders correctly in both light and dark mode, with no inline styles and no broken CSS custom property references
**Depends on**: Nothing (first phase)
**Requirements**: FOUND-01, FOUND-02, FOUND-03, LAYOUT-04
**Success Criteria** (what must be TRUE):
  1. The page renders identically in light and dark mode with no unstyled or broken elements
  2. DevTools shows no `var()` resolution failures — all CSS custom properties resolve to actual values
  3. No `<style>` blocks exist in either `index.en.md` or `index.pt-br.md`
  4. The site builds and deploys successfully via GitHub Actions with Hugo Extended enabled in both workflows
**Plans:** 1/1 plans complete

Plans:
- [x] 01-01-PLAN.md — Extract inline styles to SCSS partial, fix broken var() references, add dark mode support

**UI hint**: yes

### Phase 2: Layout and Content
**Goal**: The reading list displays as a clean, scannable typography-driven list with structured content sections including a "Currently Reading" section at the top
**Depends on**: Phase 1
**Requirements**: LAYOUT-01, LAYOUT-02, CONT-01, CONT-02, CONT-03, CONT-04
**Success Criteria** (what must be TRUE):
  1. The page shows no card borders, no hover effects — books are rendered as clean text list entries
  2. A "Currently Reading" section appears at the top of the page with 1-3 entries, each showing title, author, and a personal note
  3. Category sections have consistent headings and each book entry includes a description
  4. The page-level intro paragraph is present and the overall reading experience is scannable on desktop and mobile
**Plans:** 2/2 plans complete

Plans:
- [x] 02-01-PLAN.md — Create book shortcode template and replace Phase 1 card SCSS with typography-driven shortcode styles
- [x] 02-02-PLAN.md — Migrate English and Portuguese content files to shortcode format with Currently Reading section

**UI hint**: yes

### Phase 3: Features and Publishing
**Goal**: Star ratings are visible and styled for both light and dark mode, anchor navigation works, and both language versions are deployable
**Depends on**: Phase 2
**Requirements**: RATE-01, RATE-02, RATE-03, LAYOUT-03, LANG-01, LANG-02
**Success Criteria** (what must be TRUE):
  1. Every book entry displays a star rating (1-5 stars) that is visually distinct in both light and dark mode
  2. Clicking an anchor navigation link at the top of the page scrolls to the correct category section
  3. The English version passes a full visual check: dark mode, star rendering in Chrome/Firefox, anchor clicks, "Currently Reading" visible above the fold on desktop and mobile
  4. The Portuguese version mirrors the English layout and content structure and the site deploys without build errors
**Plans:** 2/2 plans complete

Plans:
- [x] 03-01-PLAN.md — Extend book shortcode with star rating parameter and restyle anchor nav from pills to plain text links
- [x] 03-02-PLAN.md — Add rating values to all entries in both languages, rename page, set up redirects, update config

**UI hint**: yes

</details>

### v1.1 Speaking Page Redesign (In Progress)

**Milestone Goal:** Transform the talks page from a monolithic markdown file into a structured, shortcode-driven speaking page with typed entries and consistent design matching the reading list.

#### Phase 4: Shortcode and Layout
**Goal**: A `{{< talk >}}` shortcode exists and the speaking page renders all entries in typed sections with typography-driven styling matching the reading list
**Depends on**: Phase 3
**Requirements**: TALK-01, TALK-02, TALK-03, LAYOUT-05, LAYOUT-06
**Success Criteria** (what must be TRUE):
  1. The `{{< talk >}}` shortcode renders an entry with title, event, date, and optional video/slides links visible on the page
  2. Entries with `type="talk"`, `type="podcast"`, and `type="host"` each receive visually distinct treatment — the difference is observable without inspecting HTML
  3. The page displays three separate sections (Conference Talks, Podcast Appearances, The Critical Channel) with clear headings
  4. The page passes a dark mode visual check and is readable on mobile — no broken layouts or invisible text
**Plans:** 2/2 plans complete

Plans:
- [x] 04-01-PLAN.md — Create talk shortcode template and speaking page SCSS partial with dark mode and mobile support
- [x] 04-02-PLAN.md — Fix layout template inline styles, create three-section test content, visual verification

**UI hint**: yes

#### Phase 5: Content and Publishing
**Goal**: The speaking page is live at `/speaking/` with authentic content in both languages and menu navigation updated
**Depends on**: Phase 4
**Requirements**: CONT-05, CONT-06, PUB-01, PUB-02, PUB-03
**Success Criteria** (what must be TRUE):
  1. The page intro paragraph reads in Italo's voice — not conference-abstract language
  2. Talk descriptions are rewritten as personal notes, not PR copy
  3. Visiting `/speaking/` serves the page; visiting `/talks/` redirects there without a 404
  4. Both the English and Portuguese versions are structurally identical and the site builds without errors
  5. The nav menu in both languages links to `/speaking/` with updated display text
**Plans:** 1/2 plans executed

Plans:
- [x] 05-01-PLAN.md — Rewrite intro paragraph and all 7 talk descriptions in authentic voice for EN and PT-BR
- [ ] 05-02-PLAN.md — Rename content directory to speaking/, add redirect aliases, update config.toml menu entries

**UI hint**: yes

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 1. CSS Foundation | v1.0 | 1/1 | Complete | 2026-04-03 |
| 2. Layout and Content | v1.0 | 2/2 | Complete | 2026-04-03 |
| 3. Features and Publishing | v1.0 | 2/2 | Complete | 2026-04-06 |
| 4. Shortcode and Layout | v1.1 | 2/2 | Complete |  |
| 5. Content and Publishing | v1.1 | 1/2 | In Progress|  |
