# Phase 3: Features and Publishing - Context

**Gathered:** 2026-04-04
**Status:** Ready for planning

<domain>
## Phase Boundary

Add star ratings to every book/resource entry, implement working anchor navigation, rename/rebrand the page, and ensure both language versions build and deploy cleanly via GitHub Actions. This is the final phase before v1 ships.

</domain>

<decisions>
## Implementation Decisions

### Star Ratings
- **D-01:** Add a `rating` parameter to the existing `{{< book >}}` shortcode. Numeric 1-5 value (e.g., `rating="5"`). The shortcode template renders that many filled Font Awesome stars (`fas fa-star`).
- **D-02:** Show only filled stars — no empty star outlines. If rating is 4, show 4 filled stars. Clean and minimal.
- **D-03:** Stars appear inline after the title, on the same line. e.g., "Clean Code ★★★★★". They should be visually distinct but not dominate — accent color, slightly smaller than the title text.
- **D-04:** Stars must be properly colored in both light and dark mode. Use the accent color from the UI-SPEC (`$single-link-color` / `$single-link-color-dark`).
- **D-05:** Every book entry in both language files must get a rating value added. Ratings should align with tier placement: Must Read entries get 5 stars, Recommended get 4, Worth Your Time get 3. Newsletters and podcasts can use 4-5 based on the description tone.

### Rating-to-Tier Relationship
- **D-06:** Ratings and tier labels are independent — tiers stay as manual markdown headings, ratings are per-entry shortcode parameters. No auto-derivation. This keeps it simple and lets Italo override if needed.

### Anchor Navigation
- **D-07:** Anchor nav style is Claude's discretion — pick what best fits the clean editorial typography-driven design. Add "Currently Reading" as the first navigation item.
- **D-08:** Anchor nav is static (not sticky). No JavaScript, no position:sticky. Stays at the top of the page content.
- **D-09:** All anchor links must scroll to the correct category section. Verify each link resolves to an existing `id` attribute.

### Page Rename/Rebrand
- **D-10:** Page title changes to **"What I'm Reading"** in both the frontmatter `title` field and the menu configuration in `config.toml`.
- **D-11:** URL slug changes from `/my-reading-list/` to `/recommended-reading/`. Update the `slug` field in frontmatter for both language files.
- **D-12:** Add a redirect from the old URL (`/my-reading-list/`) to the new URL (`/recommended-reading/`) so existing links don't break. Use Hugo's `aliases` frontmatter feature.
- **D-13:** Portuguese version: title and slug should be localized appropriately (e.g., "O que estou lendo" / `/leituras-recomendadas/`). Add redirect from old Portuguese URL too.

### Publishing Readiness
- **D-14:** Publishing checks are Claude's discretion — determine what's needed for a clean deploy. At minimum: Hugo build passes, GitHub Actions workflow runs, both language versions render correctly.

### Claude's Discretion
- Anchor nav visual style (pills, text links, separators)
- Star icon size and exact styling
- Whether to update social meta tags / Open Graph image
- Any additional publishing checks needed
- Portuguese page title and slug localization

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Shortcode (Phase 2 output — to be extended)
- `layouts/shortcodes/book.html` — Current shortcode with rating slot comment. Add `$rating` parameter and star rendering here.

### SCSS (Phase 1+2 output — to be extended)
- `assets/css/_reading-list.scss` — All reading list styles. Add star rating styles here.

### Content files (to be updated with ratings + new slug/title)
- `content/my-reading-list/index.en.md` — English reading list (will be renamed)
- `content/my-reading-list/index.pt-br.md` — Portuguese version (will be renamed)

### Theme reference
- `themes/LoveIt/assets/css/_variables.scss` — SCSS variables for star colors
- `config.toml` — Menu configuration (needs title update), Font Awesome enabled

### CI/CD
- `.github/workflows/pages.yml` — Production deployment workflow
- `.github/workflows/pr-checks.yml` — PR validation workflow

### Prior phase context
- `.planning/phases/01-css-foundation/01-CONTEXT.md` — Dark mode pattern (D-05, D-06)
- `.planning/phases/02-layout-and-content/02-CONTEXT.md` — Shortcode design (D-01 through D-03), tier labels (D-08)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `book.html` shortcode: Already has the Phase 3 rating slot comment — just need to add `$rating` parameter and star HTML
- `_reading-list.scss`: Dark/auto theme patterns established — add `.book-entry__rating` styles following same pattern
- Font Awesome: Already enabled in `config.toml` (`fontawesome = true`). LoveIt loads it via CDN. `fas fa-star` is available.
- Hugo `aliases` frontmatter: Built-in redirect support, no custom code needed

### Established Patterns
- Dark mode: `[theme=dark] .selector { ... }` + `@media (prefers-color-scheme: dark) { [theme=auto] .selector { ... } }`
- SCSS variables: `$single-link-color` / `$single-link-color-dark` for accent (star) colors
- BEM naming: `.book-entry__rating` follows existing `.book-entry__title`, `.book-entry__author` pattern
- Shortcode params: `.Get "param"` pattern established in book.html

### Integration Points
- Shortcode: Add `$rating` variable, loop to render N stars
- SCSS: Add `.book-entry__rating` block in light/dark/auto/mobile sections
- Content: Add `rating="N"` to every `{{< book >}}` invocation in both files
- Config: Update menu item title for both languages
- Frontmatter: Update `title`, `slug`, add `aliases` in both content files

</code_context>

<specifics>
## Specific Ideas

- Star ratings should feel like a natural part of the typography — not a bolt-on widget. Inline with the title, accent-colored, slightly smaller.
- Page rename to "What I'm Reading" gives it a personal, casual voice matching Italo's writing style throughout the descriptions.
- This is the final phase — everything must be deployable when done.

</specifics>

<deferred>
## Deferred Ideas

- Content consolidation from CTO Reading List blog posts — v2 scope (CEXP-01)
- "Last updated" timestamp near top of page — v2 scope (CEXP-03)
- "Back to top" links after each section — v2 scope (CEXP-04)

</deferred>

---

*Phase: 03-features-and-publishing*
*Context gathered: 2026-04-04*
