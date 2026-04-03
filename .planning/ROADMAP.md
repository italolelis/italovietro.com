# Roadmap: Reading List Redesign

## Overview

Three sequential phases transform the existing broken-CSS, card-based reading list into a clean, typography-driven page with star ratings and a "Currently Reading" section. The foundation must be fixed before features are added: the current page uses CSS custom properties that do not exist in the compiled LoveIt theme, meaning dark mode is silently broken today. Phase 1 establishes a correct SCSS foundation. Phase 2 replaces the layout and migrates content to structured frontmatter. Phase 3 adds star ratings, anchor navigation, and syncs the Portuguese version for deployment.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: CSS Foundation** - Fix broken dark mode CSS, extract inline styles into SCSS, verify CI/CD pipeline (completed 2026-04-03)
- [ ] **Phase 2: Layout and Content** - Replace card layout with typography-driven design, migrate book data to frontmatter, structure content sections
- [ ] **Phase 3: Features and Publishing** - Add star ratings, anchor navigation, and sync Portuguese version for deployment

## Phase Details

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
**Plans**: TBD
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
**Plans**: TBD
**UI hint**: yes

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. CSS Foundation | 1/1 | Complete   | 2026-04-03 |
| 2. Layout and Content | 0/? | Not started | - |
| 3. Features and Publishing | 0/? | Not started | - |
