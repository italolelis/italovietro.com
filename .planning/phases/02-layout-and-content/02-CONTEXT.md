# Phase 2: Layout and Content - Context

**Gathered:** 2026-04-03
**Status:** Ready for planning

<domain>
## Phase Boundary

Transform the reading list from a plain markdown bullet list into a clean, scannable typography-driven page with structured content sections. Introduces a Hugo shortcode for book/resource entries, a "Currently Reading" section at the top, and consistent category/tier presentation. No star ratings (Phase 3), no anchor nav changes (Phase 3), no content consolidation from blog posts (v2).

</domain>

<decisions>
## Implementation Decisions

### Book Entry Format
- **D-01:** Create a Hugo shortcode `{{< book >}}` for each entry with parameters: `title`, `author`, `link` (URL), `type` (book/newsletter/podcast). The description/personal note is passed as the shortcode body content.
- **D-02:** The shortcode renders a clean typography-driven entry — no cards, no borders, no hover effects. Title as a linked heading-style element, author on a secondary line, description below.
- **D-03:** The shortcode must be extensible for Phase 3 — a `rating` parameter will be added later for star ratings. Do not add it now, but design the HTML structure so it can be inserted without breaking layout.

### Currently Reading Section
- **D-04:** A manually curated `## Currently Reading` section at the top of the page, before all category sections. The user moves entries in/out of this section as they finish books.
- **D-05:** "Currently Reading" entries use the same `{{< book >}}` shortcode with the same fields. The personal note (body content) serves as "why I'm reading this."
- **D-06:** No "started date" field — keep it simple. 1-3 entries at any time.

### Category Presentation
- **D-07:** Category visual separation is Claude's discretion — pick what best fits a clean, editorial, typography-driven design. The goal is scannable sections, not decorative styling.
- **D-08:** Standardize to 3 consistent tiers across ALL categories: **Must Read**, **Recommended**, **Worth Your Time**. Replace current inconsistent labels (Essential, Highly Recommended).
- **D-09:** Tier labels are rendered as styled sub-headings within each category section. They should be visually distinct but not heavy — subtle typographic treatment.

### Content Structure
- **D-10:** All content remains in markdown files (`index.en.md`, `index.pt-br.md`). No Hugo data files (YAML/JSON). The shortcode approach keeps content editable in markdown while enabling structured rendering.
- **D-11:** Existing content (intro paragraph, all entries with descriptions) must be preserved and migrated to the shortcode format. No entries should be lost in the conversion.

### Claude's Discretion
- Category visual separation approach (headings, dividers, spacing)
- Exact HTML structure of the book shortcode (semantic elements, CSS classes)
- Whether to use a single shortcode template or type-specific variants
- How tier labels are styled (bold text, small caps, colored accent, etc.)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Current reading list content
- `content/my-reading-list/index.en.md` — English reading list with all current entries (source of truth for content migration)
- `content/my-reading-list/index.pt-br.md` — Portuguese version (must be updated in parallel)

### CSS foundation (Phase 1 output)
- `assets/css/_reading-list.scss` — All reading list styles; new shortcode styles go here
- `assets/css/_custom.scss` — Imports `_reading-list.scss` (line 51)

### Theme reference
- `themes/LoveIt/assets/css/_variables.scss` — LoveIt SCSS variables for theming
- `themes/LoveIt/layouts/_default/single.html` — Default single page template (reading list currently uses this)

### Existing shortcodes and layouts
- `layouts/shortcodes/` — Directory for custom shortcodes (currently empty, book shortcode goes here)
- `layouts/talks/single.html` — Example of a custom layout override in this project

### Phase 1 context
- `.planning/phases/01-css-foundation/01-CONTEXT.md` — Dark mode pattern decisions (D-05, D-06) that apply to all new styles

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `_reading-list.scss`: Phase 1 created this with dark/auto theme support — all new styles for the shortcode should be added here
- `layouts/talks/single.html`: Shows the pattern for custom Hugo layout overrides in this project
- LoveIt's `single.html`: Current template used by reading list — may need a custom override if shortcode alone isn't sufficient

### Established Patterns
- Dark mode: `[theme=dark] .selector { ... }` + `@media (prefers-color-scheme: dark) { [theme=auto] .selector { ... } }` (from Phase 1)
- SCSS variables: Use `$global-font-color`, `$global-border-color`, etc. from LoveIt (never raw hex or `var()`)
- Mobile breakpoint: 680px (LoveIt-aligned, from Phase 1)

### Integration Points
- New shortcode template: `layouts/shortcodes/book.html`
- Styles: Append to `assets/css/_reading-list.scss`
- Content: Rewrite both `index.en.md` and `index.pt-br.md` to use shortcode syntax
- No layout override needed if the shortcode handles all rendering within the existing single.html

</code_context>

<specifics>
## Specific Ideas

- Reference design: Pragmatic Engineer's reading list — clean text, no cards, scannable
- Tier vocabulary: "Must Read" / "Recommended" / "Worth Your Time" (warm, personal tone matching Italo's writing style)
- The page is shared with colleagues/teammates — first impression and scannability matter

</specifics>

<deferred>
## Deferred Ideas

- Content consolidation from CTO Reading List blog posts — v2 scope (CEXP-01)
- Page rename/rebrand — v2 scope (CEXP-02)
- Star ratings display — Phase 3 (RATE-01, RATE-02, RATE-03)
- Anchor-based category navigation — Phase 3 (LAYOUT-03)

</deferred>

---

*Phase: 02-layout-and-content*
*Context gathered: 2026-04-03*
