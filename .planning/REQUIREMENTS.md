# Requirements: italovietro.com

**Defined:** 2026-04-03
**Core Value:** A clean, personal website that reflects how Italo actually thinks and works.

## v1.1 Requirements (Speaking Page Redesign)

### Shortcode

- [ ] **TALK-01**: A `{{< talk >}}` shortcode renders each entry with title, event, date, and optional video/slides links
- [ ] **TALK-02**: The shortcode accepts a `type` parameter (talk/podcast/host) that controls visual treatment
- [ ] **TALK-03**: Description/personal note is passed as shortcode body content

### Layout

- [ ] **LAYOUT-05**: Conference talks, podcast appearances, and The Critical Channel are rendered as separate sections with clear headings
- [ ] **LAYOUT-06**: Page styling follows the reading list's typography-driven approach with dark mode and mobile responsive support

### Content

- [ ] **CONT-05**: Talk descriptions are rewritten in Italo's authentic voice (not conference-abstract style)
- [ ] **CONT-06**: Page intro paragraph sets the tone for the speaking page

### Publishing

- [ ] **PUB-01**: Page renamed to "Speaking" at `/speaking/` with redirect from `/talks/`
- [ ] **PUB-02**: Both EN and PT-BR versions updated with matching structure
- [ ] **PUB-03**: Config.toml menu entries updated for both languages

## v1.0 Requirements (Complete)

All 16 requirements from v1.0 Reading List Redesign are complete. See MILESTONES.md.

### Foundation (Complete)
- [x] **FOUND-01**: Broken CSS custom property references fixed to use actual LoveIt theme variables
- [x] **FOUND-02**: Inline `<style>` blocks extracted from both language markdown files into SCSS
- [x] **FOUND-03**: Dark mode works correctly with `[theme=dark]` SCSS selectors

### Layout (Complete)
- [x] **LAYOUT-01**: Card-based design replaced with clean typography-driven layout
- [x] **LAYOUT-02**: Category sections have clear, consistent headings
- [x] **LAYOUT-03**: Anchor-based category navigation at the top of the page
- [x] **LAYOUT-04**: Layout is mobile-responsive and works with LoveIt theme breakpoints

### Ratings (Complete)
- [x] **RATE-01**: Each book/resource displays a 5-star rating using Font Awesome icons
- [x] **RATE-02**: Star ratings are visible and properly colored in both light and dark mode
- [x] **RATE-03**: Consistent tier labels align with star ratings

### Content (Complete)
- [x] **CONT-01**: "Currently Reading" section displayed prominently at the top
- [x] **CONT-02**: Each "Currently Reading" entry has title, author, and a personal note
- [x] **CONT-03**: Page-level intro paragraph preserved
- [x] **CONT-04**: Per-entry descriptions preserved and consistent

### Multi-language (Complete)
- [x] **LANG-01**: English version fully updated
- [x] **LANG-02**: Portuguese version updated to match English layout structure

## Future Requirements

Deferred. Tracked but not in current roadmap.

- **CEXP-01**: Consolidated book picks from CTO Reading List blog posts
- **CEXP-03**: "Last updated" timestamp near top of page
- **CEXP-04**: "Back to top" links after each section

## Out of Scope

| Feature | Reason |
|---------|--------|
| JSON-LD SpeakingEvent schema | Deferred to SEO milestone (SEED-002) |
| Talk filtering/search | Unnecessary for <10 entries |
| Upcoming talks section | Not needed now, can add later |
| Slides/video embed inline | Links to external resources sufficient |
| Per-talk dedicated pages | Over-engineering for this content volume |
| Book cover images | Keeps design clean and fast-loading |
| Interactive filtering/sorting | Unnecessary for list sizes, requires JavaScript |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| FOUND-01 | Phase 1 | Complete |
| FOUND-02 | Phase 1 | Complete |
| FOUND-03 | Phase 1 | Complete |
| LAYOUT-04 | Phase 1 | Complete |
| LAYOUT-01 | Phase 2 | Complete |
| LAYOUT-02 | Phase 2 | Complete |
| CONT-01 | Phase 2 | Complete |
| CONT-02 | Phase 2 | Complete |
| CONT-03 | Phase 2 | Complete |
| CONT-04 | Phase 2 | Complete |
| RATE-01 | Phase 3 | Complete |
| RATE-02 | Phase 3 | Complete |
| RATE-03 | Phase 3 | Complete |
| LAYOUT-03 | Phase 3 | Complete |
| LANG-01 | Phase 3 | Complete |
| LANG-02 | Phase 3 | Complete |
| TALK-01 | TBD | Pending |
| TALK-02 | TBD | Pending |
| TALK-03 | TBD | Pending |
| LAYOUT-05 | TBD | Pending |
| LAYOUT-06 | TBD | Pending |
| CONT-05 | TBD | Pending |
| CONT-06 | TBD | Pending |
| PUB-01 | TBD | Pending |
| PUB-02 | TBD | Pending |
| PUB-03 | TBD | Pending |

**Coverage:**
- v1.1 requirements: 10 total
- Mapped to phases: 0 (roadmap pending)
- Unmapped: 10

---
*Requirements defined: 2026-04-03*
*Last updated: 2026-04-06 — v1.1 requirements added*
