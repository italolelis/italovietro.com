# italovietro.com — Reading List Redesign

## What This Is

A personal website and blog built with Hugo (LoveIt theme), serving as Italo Vietro's professional presence. The site features blog posts, talks, and a reading list page. This project focuses on redesigning the reading list into a snappier, more appealing page that Italo can confidently share with colleagues and teammates.

## Core Value

A clean, scannable reading list page with star ratings that makes it immediately obvious which books matter most and what Italo is currently reading.

## Current Milestone: v1.0 Reading List Redesign

**Goal:** Transform the existing reading list page from a plain card-based layout into a clean, editorial-style page inspired by Pragmatic Engineer's reading list — with star ratings, a "currently reading" section, and consolidated content from the CTO reading list blog posts.

**Target features:**
- Star ratings (5-star scale) for each book
- "Currently Reading" section prominently at the top
- Consolidated single page merging reading list + CTO blog post recommendations
- Clean, scannable typography-driven layout (no cards, no cover images)
- Anchor-based category navigation
- Renamed/rebranded page title for better reception

## Requirements

### Validated

- ✓ Reading list page exists — existing (`content/my-reading-list/index.en.md`)
- ✓ Hugo + LoveIt theme architecture — existing
- ✓ Multi-language support (en/pt-br) — existing
- ✓ CSS variable theming (light/dark mode) — existing
- ✓ Broken CSS var() references fixed — Validated in Phase 1: CSS Foundation
- ✓ Inline styles extracted to SCSS partial — Validated in Phase 1: CSS Foundation
- ✓ Dark mode support via [theme=dark] selectors — Validated in Phase 1: CSS Foundation
- ✓ Mobile-responsive layout with LoveIt breakpoints — Validated in Phase 1: CSS Foundation
- ✓ Clean typography-driven layout replacing card-based design — Validated in Phase 2: Layout and Content
- ✓ "Currently Reading" section at the top — Validated in Phase 2: Layout and Content
- ✓ Hugo book shortcode with structured entry format — Validated in Phase 2: Layout and Content
- ✓ Consistent tier labels (Must Read / Recommended / Worth Your Time) — Validated in Phase 2: Layout and Content

- ✓ Star ratings for each book/resource — Validated in Phase 3: Features and Publishing
- ✓ Anchor-based category navigation — Validated in Phase 3: Features and Publishing
- ✓ Page rename/rebrand for shareability — Validated in Phase 3: Features and Publishing ("What I'm Reading" at /recommended-reading/)

### Active

- [ ] Consolidated content from CTO reading list blog posts (deferred to v2)

### Out of Scope

- Book cover images — keeps the design clean and fast-loading, matches reference style
- Interactive filtering/sorting — unnecessary for the size of this list
- Separate blog post reading lists — consolidating into one page
- Podcast/newsletter removal — keeping these sections, just redesigning

## Context

- The current reading list page uses inline CSS with card-based hover effects
- Three CTO reading list blog posts exist with article + book recommendations
- Reference design: Pragmatic Engineer's reading list (clean text, star ratings, categories)
- The page is shared with colleagues/teammates — shareability and first impression matter
- Hugo static site with LoveIt theme, custom layout overrides in `layouts/`
- Inline `<style>` blocks in markdown work but a dedicated layout template would be cleaner

## Constraints

- **Tech stack**: Hugo + LoveIt theme, no JavaScript frameworks
- **Theme**: Must work with existing LoveIt theme CSS variables (light/dark mode)
- **Content format**: Markdown with Hugo frontmatter
- **Deployment**: GitHub Pages via GitHub Actions
- **Multi-language**: Changes need to work for both en and pt-br versions

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Typography-driven, no book covers | Matches reference style, faster loading, cleaner | — Pending |
| Consolidate into one page | User wants single shareable URL | — Pending |
| Keep inline CSS vs custom template | Dedicated `_reading-list.scss` partial imported by `_custom.scss` | Phase 1 complete |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd:transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-04-06 after Phase 3: Features and Publishing completion — v1 milestone complete*
