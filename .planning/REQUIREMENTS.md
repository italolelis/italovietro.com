# Requirements: Reading List Redesign

**Defined:** 2026-04-03
**Core Value:** A clean, scannable reading list page with star ratings that makes it immediately obvious which books matter most and what Italo is currently reading.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Foundation

- [ ] **FOUND-01**: Broken CSS custom property references (`var(--header-title-color)` etc.) are fixed to use actual LoveIt theme variables
- [ ] **FOUND-02**: Inline `<style>` blocks extracted from both language markdown files into `_custom.scss`
- [ ] **FOUND-03**: Dark mode works correctly with `[theme=dark] &` SCSS selectors for all new styles

### Layout

- [ ] **LAYOUT-01**: Card-based design replaced with clean typography-driven layout (no borders, no hover effects)
- [ ] **LAYOUT-02**: Category sections have clear, consistent headings
- [ ] **LAYOUT-03**: Anchor-based category navigation at the top of the page
- [ ] **LAYOUT-04**: Layout is mobile-responsive and works with LoveIt theme breakpoints

### Ratings

- [ ] **RATE-01**: Each book/resource displays a 5-star rating using Font Awesome icons
- [ ] **RATE-02**: Star ratings are visible and properly colored in both light and dark mode
- [ ] **RATE-03**: Consistent tier labels (Essential / Highly Recommended / Worth Reading) align with star ratings

### Content

- [ ] **CONT-01**: "Currently Reading" section displayed prominently at the top with 1-3 entries
- [ ] **CONT-02**: Each "Currently Reading" entry has title, author, and a personal note
- [ ] **CONT-03**: Page-level intro paragraph preserved
- [ ] **CONT-04**: Per-entry descriptions preserved and consistent across all entries

### Multi-language

- [ ] **LANG-01**: English version fully updated with new layout and features
- [ ] **LANG-02**: Portuguese version updated to match English layout structure

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Content Expansion

- **CEXP-01**: Consolidated book picks from CTO Reading List blog posts merged into main page
- **CEXP-02**: Page rename/rebrand for shareable-first title (e.g., "Recommended Reading for Engineering Leaders")
- **CEXP-03**: "Last updated" timestamp near top of page
- **CEXP-04**: "Back to top" links after each section

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Book cover images | Keeps design clean and fast-loading, matches reference style |
| Interactive filtering/sorting | Unnecessary for list size (<30 items), requires JavaScript |
| Goodreads integration | External dependency, poor API reliability |
| Reading progress bars | Gimmicky for professional recommendation page |
| Comment section / reactions | Content management overhead; DM CTA is sufficient |
| Separate pages per book | Over-engineering for ~30 entries |
| Pagination | Single long page with anchor nav is better for this size |
| Auto-generated reading stats | Requires data model and JS, no reader value |
| Podcast episode lists | Unsustainable curation; show-level entries sufficient |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| FOUND-01 | TBD | Pending |
| FOUND-02 | TBD | Pending |
| FOUND-03 | TBD | Pending |
| LAYOUT-01 | TBD | Pending |
| LAYOUT-02 | TBD | Pending |
| LAYOUT-03 | TBD | Pending |
| LAYOUT-04 | TBD | Pending |
| RATE-01 | TBD | Pending |
| RATE-02 | TBD | Pending |
| RATE-03 | TBD | Pending |
| CONT-01 | TBD | Pending |
| CONT-02 | TBD | Pending |
| CONT-03 | TBD | Pending |
| CONT-04 | TBD | Pending |
| LANG-01 | TBD | Pending |
| LANG-02 | TBD | Pending |

**Coverage:**
- v1 requirements: 16 total
- Mapped to phases: 0
- Unmapped: 16

---
*Requirements defined: 2026-04-03*
*Last updated: 2026-04-03 after initial definition*
