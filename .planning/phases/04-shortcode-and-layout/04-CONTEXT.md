# Phase 4: Shortcode and Layout - Context

**Gathered:** 2026-04-06
**Status:** Ready for planning

<domain>
## Phase Boundary

Create the `{{< talk >}}` Hugo shortcode and SCSS styling for the speaking page. Three typed sections (Conference Talks, Podcast Appearances, The Critical Channel) with typography-driven design matching the reading list. No content migration yet (Phase 5).

</domain>

<decisions>
## Implementation Decisions

### Talk Shortcode
- **D-01:** Create a `{{< talk >}}` shortcode following the exact `book.html` pattern. Parameters: `title`, `event`, `date`, `type` (talk/podcast/host), `video_url` (optional), `slides_url` (optional). Description/personal note passed as shortcode body content.
- **D-02:** Use `.Get "param"`, `trim .Inner "\n" | .Page.RenderString`, and BEM class naming (`.talk-entry`, `.talk-entry__header`, etc.) matching the book shortcode conventions.
- **D-03:** Video and slides links render as small inline links after the event/date line (e.g., "Watch" / "Slides"). Not as buttons or icons.

### Type-Based Visual Treatment
- **D-04:** Type-based visual treatment is Claude's discretion. Pick what best fits the typography-driven design. Options considered: Font Awesome icons per type, colored accent labels, or structural difference only. The sections themselves (Conference Talks, Podcast Appearances, The Critical Channel) already provide type context.

### Section Structure
- **D-05:** Three sections in order: Conference Talks, Podcast Appearances, The Critical Channel. Each with an h2 heading.
- **D-06:** Entries ordered newest first within each section. Manual ordering in markdown (user controls position).
- **D-07:** Keep the featured image (speaking.webp) at the top of the page as a hero/banner. Fix the current inline styles on the featured image in `layouts/talks/single.html` and move them to SCSS.

### SCSS
- **D-08:** Create a dedicated `assets/css/_speaking.scss` partial for all speaking page styles. Import it from `_custom.scss`. Same pattern as `_reading-list.scss`.
- **D-09:** Follow the established dark mode pattern: `[theme=dark]`, `@media (prefers-color-scheme: dark) { [theme=auto] }`. Mobile breakpoint at 680px.

### Claude's Discretion
- Exact shortcode HTML structure
- Type-based visual differentiation approach (icons, labels, or none)
- How date is formatted and displayed
- Featured image SCSS styling (border-radius, shadow, sizing)
- Whether talk entry titles link to video_url when available

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Existing shortcode (pattern to follow)
- `layouts/shortcodes/book.html` — The exact shortcode pattern to replicate for talks

### Current talks page
- `content/talks/index.en.md` — Current monolithic talks page (7+ entries to be migrated in Phase 5)
- `content/talks/index.pt-br.md` — Portuguese version

### Layout template
- `layouts/talks/single.html` — Custom layout with inline styles that need extraction to SCSS

### SCSS structure
- `assets/css/_reading-list.scss` — Pattern for the new `_speaking.scss` partial
- `assets/css/_custom.scss` — Import target for new partial

### Theme reference
- `themes/LoveIt/assets/css/_variables.scss` — SCSS variables for theming

### Prior phase context
- `.planning/phases/01-css-foundation/01-CONTEXT.md` — Dark mode SCSS pattern (D-05, D-06)
- `.planning/phases/02-layout-and-content/02-CONTEXT.md` — Shortcode design pattern (D-01 through D-03)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `book.html` shortcode: Exact template to follow for `talk.html`
- `_reading-list.scss`: Pattern for dark/auto/mobile SCSS structure
- `layouts/talks/single.html`: Existing layout with pulse animation and featured image support (has inline styles to fix)
- Font Awesome: Already enabled, can use `fa-microphone`, `fa-podcast`, `fa-headphones` if needed

### Established Patterns
- BEM naming: `.book-entry__title` -> `.talk-entry__title`
- Dark mode: `[theme=dark] .selector { ... }` + auto media query
- SCSS variables from LoveIt `_variables.scss`
- Shortcode params: `.Get "param"`, inner content via `.Page.RenderString`

### Integration Points
- New shortcode: `layouts/shortcodes/talk.html`
- New SCSS partial: `assets/css/_speaking.scss`
- Import in: `assets/css/_custom.scss`
- Featured image inline styles: Move from `layouts/talks/single.html` to `_speaking.scss`

</code_context>

<specifics>
## Specific Ideas

No specific design references given. Follow the reading list's clean, typography-driven approach. The speaking page should feel like a sibling of the reading list, not a different site.

</specifics>

<deferred>
## Deferred Ideas

- JSON-LD SpeakingEvent schema (SEED-002)
- Upcoming talks section
- Per-talk dedicated pages

</deferred>

---

*Phase: 04-shortcode-and-layout*
*Context gathered: 2026-04-06*
