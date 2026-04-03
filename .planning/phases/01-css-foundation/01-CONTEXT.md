# Phase 1: CSS Foundation - Context

**Gathered:** 2026-04-03
**Status:** Ready for planning

<domain>
## Phase Boundary

Fix broken dark mode CSS, extract inline styles from both language markdown files into SCSS, and verify the site builds and deploys correctly. No layout changes, no new features — purely fixing what's broken and establishing a correct CSS foundation for Phase 2 and 3.

</domain>

<decisions>
## Implementation Decisions

### CSS Variable Strategy
- **D-01:** Replace all broken `var()` references with LoveIt's actual SCSS variables. LoveIt uses compiled SCSS, not CSS custom properties — the current `var(--header-title-color)` etc. resolve to nothing. Map each broken reference to the closest LoveIt SCSS variable or hardcode theme-aware values with `[theme=dark]` overrides.
- **D-02:** Do not define new CSS custom properties. Use LoveIt's existing SCSS variable system to stay consistent with the theme.

### Style File Organization
- **D-03:** Create a dedicated `assets/css/_reading-list.scss` partial for all reading list styles. Import it from `_custom.scss`. This keeps reading list styles isolated from the existing logo/home styles in `_custom.scss`.
- **D-04:** Remove all `<style>` blocks from both `index.en.md` and `index.pt-br.md` completely. Zero inline styles should remain.

### Dark Mode Approach
- **D-05:** Follow the `[theme=dark] &` SCSS pattern already established in `_custom.scss` for logo handling. This is the LoveIt-standard approach.
- **D-06:** Also handle `[theme=auto]` with `@media (prefers-color-scheme: dark)` — same pattern as the existing logo dark mode code in `_custom.scss`.

### Claude's Discretion
- Exact color values for light/dark mode (map to closest LoveIt equivalents)
- Whether to use SCSS nesting or flat selectors
- How to handle the `<style>` extraction (one commit or incremental)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Current reading list styles (broken)
- `content/my-reading-list/index.en.md` — Contains ~130 lines of inline `<style>` with 13 broken `var()` references
- `content/my-reading-list/index.pt-br.md` — Duplicate `<style>` block, same broken references

### Existing SCSS structure
- `assets/css/_custom.scss` — Existing custom styles with working `[theme=dark]` pattern for logo
- `assets/css/_override.scss` — Font imports and SCSS variable overrides

### Theme reference
- `themes/LoveIt/assets/css/_variables.scss` — LoveIt's SCSS variables (source of truth for available variables)
- `themes/LoveIt/assets/css/_core/` — Core theme styles to understand the variable system

### Research
- `.planning/research/PITFALLS.md` — Documents the broken CSS variables and prevention strategies

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `_custom.scss`: Already has the `[theme=dark]` and `[theme=auto]` dark mode pattern — reuse this exact approach
- `_override.scss`: Shows how to override LoveIt SCSS variables

### Established Patterns
- Dark mode: `[theme=dark] .selector { ... }` + `@media (prefers-color-scheme: dark) { [theme=auto] .selector { ... } }`
- SCSS partials: Underscore-prefixed files in `assets/css/`
- Font loading: Google Fonts via `@import url()` in `_override.scss`

### Integration Points
- New `_reading-list.scss` needs to be imported in `_custom.scss`
- Hugo's SCSS pipeline will pick up the new partial automatically
- CI/CD: Two GitHub Actions workflows need Hugo Extended for SCSS compilation

</code_context>

<specifics>
## Specific Ideas

No specific requirements — user deferred all decisions to Claude's judgment for this infrastructure phase. The reference design (Pragmatic Engineer's reading list) informs Phase 2/3 but not this CSS cleanup phase.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 01-css-foundation*
*Context gathered: 2026-04-03*
