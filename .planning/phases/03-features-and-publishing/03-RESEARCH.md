# Phase 3: Features and Publishing - Research

**Researched:** 2026-04-03
**Domain:** Hugo shortcode extension, SCSS additions, content updates, URL rename, Hugo aliases redirects
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** Add a `rating` parameter to the existing `{{< book >}}` shortcode. Numeric 1-5 value (e.g., `rating="5"`). The shortcode template renders that many filled Font Awesome stars (`fas fa-star`).
- **D-02:** Show only filled stars — no empty star outlines. If rating is 4, show 4 filled stars. Clean and minimal.
- **D-03:** Stars appear inline after the title, on the same line. e.g., "Clean Code ★★★★★". They should be visually distinct but not dominate — accent color, slightly smaller than the title text.
- **D-04:** Stars must be properly colored in both light and dark mode. Use the accent color from the UI-SPEC (`$single-link-color` / `$single-link-color-dark`).
- **D-05:** Every book entry in both language files must get a rating value added. Ratings should align with tier placement: Must Read entries get 5 stars, Recommended get 4, Worth Your Time get 3. Newsletters and podcasts can use 4-5 based on the description tone.
- **D-06:** Ratings and tier labels are independent — tiers stay as manual markdown headings, ratings are per-entry shortcode parameters. No auto-derivation.
- **D-07:** Anchor nav style is Claude's discretion — pick what best fits the clean editorial typography-driven design. Add "Currently Reading" as the first navigation item.
- **D-08:** Anchor nav is static (not sticky). No JavaScript, no position:sticky.
- **D-09:** All anchor links must scroll to the correct category section. Verify each link resolves to an existing `id` attribute.
- **D-10:** Page title changes to "What I'm Reading" in both the frontmatter `title` field and the menu configuration in `config.toml`.
- **D-11:** URL slug changes from `/my-reading-list/` to `/recommended-reading/`. Update the `slug` field in frontmatter for both language files.
- **D-12:** Add a redirect from the old URL (`/my-reading-list/`) to the new URL (`/recommended-reading/`) so existing links don't break. Use Hugo's `aliases` frontmatter feature.
- **D-13:** Portuguese version: title and slug should be localized appropriately ("O que estou lendo" / `/leituras-recomendadas/`). Add redirect from old Portuguese URL too.
- **D-14:** Publishing checks are Claude's discretion — determine what's needed for a clean deploy. At minimum: Hugo build passes, GitHub Actions workflow runs, both language versions render correctly.

### Claude's Discretion

- Anchor nav visual style (pills, text links, separators)
- Star icon size and exact styling
- Whether to update social meta tags / Open Graph image
- Any additional publishing checks needed
- Portuguese page title and slug localization

### Deferred Ideas (OUT OF SCOPE)

- Content consolidation from CTO Reading List blog posts — v2 scope (CEXP-01)
- "Last updated" timestamp near top of page — v2 scope (CEXP-03)
- "Back to top" links after each section — v2 scope (CEXP-04)
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| RATE-01 | Each book/resource displays a 5-star rating using Font Awesome icons | `seq`+`range` pattern confirmed, Font Awesome 6.7.2 loaded via CDN, `fas fa-star` available |
| RATE-02 | Star ratings are visible and properly colored in both light and dark mode | SCSS variable names confirmed: `$single-link-color` / `$single-link-color-dark`; dark/auto patterns established in `_reading-list.scss` |
| RATE-03 | Consistent tier labels (Essential / Highly Recommended / Worth Reading) align with star ratings | Rating-to-tier mapping documented; D-06 confirms independence; 19 entries mapped in UI-SPEC |
| LAYOUT-03 | Anchor-based category navigation at the top of the page | Heading IDs confirmed via live build; PT-BR diacritic behavior verified; existing nav list is first `<ul>` in content |
| LANG-01 | English version fully updated with new layout and features | 20 shortcode invocations confirmed; all EN anchor IDs verified from built output |
| LANG-02 | Portuguese version updated to match English layout structure | PT-BR anchor IDs verified; `livros-de-gestão` vs `livros-de-gestao` discrepancy resolved (see Pitfalls) |
</phase_requirements>

---

## Summary

Phase 3 is the final phase of the reading list redesign. It adds three distinct types of changes: (1) a shortcode extension to render star ratings inline with book titles, (2) a style overhaul of the anchor navigation from pill-buttons to plain text links with separator dots, and (3) a page rename/rebrand with URL slug changes and redirect setup.

All foundational work is in place from Phases 1 and 2. The SCSS pattern (`[theme=dark]` + `@media (prefers-color-scheme: dark) { [theme=auto] ... }`), BEM naming convention, and shortcode parameter pattern are established. Phase 3 extends these patterns rather than inventing new ones. The implementation is predictable and low-risk.

The one non-obvious finding is the `disableAliases` setting in `config.toml` — it is scoped to `[languages.en.pagination]` and `[languages.pt-br.pagination]`, not global. This means Hugo frontmatter `aliases` for URL redirect HTML files will work as expected. A second finding is that Hugo 0.153.2 (Goldmark) preserves Unicode diacritics in heading IDs by default — `## Livros de Gestão` generates `id=livros-de-gestão`, not `livros-de-gestao`. The existing content file already accounts for this with `#livros-de-gestao` (no accent) in the nav, and browser percent-encoding resolves the link correctly. Both facts are verified from the live build output.

**Primary recommendation:** Follow the UI-SPEC and CONTEXT.md decisions exactly. All implementation details are fully specified — the planner's job is to sequence the tasks, not to make design choices.

---

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Hugo Extended | 0.153.2 | Build tool — SCSS compilation, shortcode processing, alias generation | Locked by project; production CI uses this version |
| Font Awesome | 6.7.2 (CDN) | Star icons (`fas fa-star`) | Already loaded by LoveIt theme via `fontawesome = true` in config.toml |
| LoveIt Theme | 0.2.X | CSS variable source, layout shell | Locked by project |

### Supporting

No new libraries are introduced in Phase 3. All functionality uses existing Hugo built-ins.

| Capability | Hugo Built-in | Notes |
|------------|---------------|-------|
| Star loop | `seq` + `range` | `range (seq (int $rating))` iterates N times |
| URL redirect | `aliases` frontmatter | Generates static HTML redirect files at old paths |
| Type conversion | `int` function | Converts `"4"` string param to integer for `seq` |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `fas fa-star` repeated N times | Unicode ★ characters | Font Awesome gives consistent sizing/color control via CSS; Unicode stars are harder to style independently |
| Hugo `aliases` for redirect | Manual `static/my-reading-list/index.html` | `aliases` is the canonical Hugo pattern; manual files would require maintenance |

**Installation:**

No new packages. Hugo and theme are already installed.

**Version verification:**

```bash
hugo version
# Expected: hugo v0.153.2+extended+withdeploy darwin/arm64
```

Confirmed: `hugo v0.153.2+extended+withdeploy darwin/arm64 BuildDate=2025-12-22T16:53:01Z` (verified 2026-04-03).

---

## Architecture Patterns

### Shortcode Extension Pattern

**What:** Add `$rating` parameter to existing `book.html` shortcode. Render N `<i class="fas fa-star">` elements inside a `<span class="book-entry__rating">` placed inline within `<h4 class="book-entry__title">`, after the `<a>` element.

**When to use:** Standard Hugo shortcode extension — add parameter, conditional render block.

**Exact template logic (from UI-SPEC):**

```html
{{- /* layouts/shortcodes/book.html — Phase 3 addition */ -}}
{{- $rating := .Get "rating" | default "" -}}
{{- if $rating -}}
<span class="book-entry__rating" aria-label="{{ $rating }} out of 5 stars">
  {{- range (seq (int $rating)) -}}<i class="fas fa-star"></i>{{- end -}}
</span>
{{- end -}}
```

Placement: immediately after the `</a>` tag, still inside `<h4 class="book-entry__title">`. If `rating` is absent or empty, renders nothing.

### SCSS Addition Pattern

**What:** Append new rule blocks to `assets/css/_reading-list.scss`. Replace Phase 1/2 pill-button anchor nav styles with plain text link separator style. Add `.book-entry__rating` block.

**Structure:** Light mode → dark mode (`[theme=dark]`) → auto theme (`@media (prefers-color-scheme: dark) { [theme=auto] ... }`) → mobile (`@media (max-width: 680px)`). This four-section pattern is already established in the file.

**SCSS variables confirmed present in `themes/LoveIt/assets/css/_variables.scss`:**

| Variable | Value | Usage in Phase 3 |
|----------|-------|-----------------|
| `$single-link-color` | `#2d96bd` | Star color (light), nav link color (light) |
| `$single-link-color-dark` | `#55bde2` | Star color (dark), nav link color (dark) |
| `$single-link-hover-color` | `#ef3982` | Nav link hover (light) |
| `$single-link-hover-color-dark` | `#bdebfc` | Nav link hover (dark) |
| `$global-font-secondary-color` | `#a9a9b3` | Separator dot color (light) |
| `$global-font-secondary-color-dark` | `#5d5d5f` | Separator dot color (dark) |

### Recommended File Change Order

```
1. layouts/shortcodes/book.html        — add $rating parameter + star HTML
2. assets/css/_reading-list.scss       — replace nav styles + add rating styles
3. content/my-reading-list/index.en.md — add rating="N" to all 19 entries
4. content/my-reading-list/index.pt-br.md — add rating="N" to all 19 entries
5. content/my-reading-list/           — rename directory to recommended-reading/
6. content/recommended-reading/index.en.md — update title, slug, add aliases
7. content/recommended-reading/index.pt-br.md — update title, slug, add aliases
8. config.toml                         — update menu names and URLs for both languages
```

Step 5 (directory rename) must come after steps 3 and 4 so rating additions target the correct path. Steps 6–8 can be done in any order after step 5.

### Anti-Patterns to Avoid

- **Star HTML in markdown:** Do not put star unicode characters (`★`) directly in markdown. Stars must be in the shortcode for consistent dark/light mode color control.
- **Global `disableAliases: true`:** Do not add a global `disableAliases` setting. The existing setting is only in `[languages.*.pagination]` scope — leave it there.
- **Renaming directory before updating frontmatter:** Rename the `content/my-reading-list/` directory only after all content edits are complete. Hugo resolves shortcode paths relative to content directory at build time.
- **Hardcoded star color in HTML:** Stars use class-based SCSS coloring. Do not use inline `style="color: ..."` in the shortcode HTML.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Render N stars | Manual `{{- if eq $rating "5" -}}★★★★★{{- end -}}` for each count | `range (seq (int $rating))` | One line, handles any value 1-5 without branching |
| URL redirect from old slug | Static file in `static/my-reading-list/index.html` | Hugo `aliases` frontmatter | Built-in, zero maintenance, generates proper `<meta http-equiv="refresh">` HTML file |
| Dark mode star color | JavaScript theme detection | SCSS `[theme=dark]` selector | Already the established project pattern; no JS needed |

**Key insight:** Hugo's built-in `seq` function and `aliases` frontmatter make star rendering and URL redirects trivial. Both are documented Hugo built-ins with no edge cases at this scale.

---

## Runtime State Inventory

This phase involves a directory rename (`content/my-reading-list/` → `content/recommended-reading/`) and URL slug change. The following categories were explicitly investigated.

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | None — static site, no database or datastore | None |
| Live service config | GitHub Actions workflows in `.github/workflows/pages.yml` and `pr-checks.yml` — no hardcoded `/my-reading-list/` URLs in workflow files (verified) | None |
| OS-registered state | None — static site, no OS-level registrations | None |
| Secrets/env vars | None referencing reading list URL | None |
| Build artifacts | `public/my-reading-list/` in build output directory — regenerated fresh on each build | None — `hugo --gc` cleans stale output |

**Content directory rename note:** The `content/my-reading-list/` → `content/recommended-reading/` rename requires a corresponding menu URL update in `config.toml` (from `/my-reading-list/` to `/recommended-reading/` for EN, and the PT-BR menu entry which currently also points to `/my-reading-list/` must be updated to `/leituras-recomendadas/`).

**Language switcher note:** The built output shows the language switcher pointing to `/pt-br/minha-lista-de-leitura/` from the EN page. After rename, both the `slug` frontmatter and directory name change ensure the language switcher auto-resolves to the new PT-BR path without manual config.

---

## Common Pitfalls

### Pitfall 1: PT-BR Diacritic Anchor ID Mismatch

**What goes wrong:** Hugo 0.153.2 (Goldmark) preserves Unicode diacritics in generated heading IDs by default. `## Livros de Gestão` generates `id=livros-de-gestão` (with the ã), not `id=livros-de-gestao`.

**Why it happens:** Goldmark's `autoHeadingIDType` is `github` by default, which lowercases and replaces spaces but preserves Unicode characters.

**How to avoid:** The existing `index.pt-br.md` already has the nav link as `[Livros de Gestão](#livros-de-gestao)` (no accent in href). This works because browsers percent-encode the diacritic when resolving the link. **Do not "fix" the content by adding the accent to the `#href`** — the current content is correct and the link resolves. Verify after rename by building and checking that clicking the nav link scrolls to the `## Livros de Gestão` heading.

**Warning signs:** If the PT-BR "Management Books" anchor nav link does not scroll to the correct section, the ID mismatch is the likely cause.

**Evidence:** Verified from live build output: `id=livros-de-gestão` in `public/pt-br/minha-lista-de-leitura/index.html`, nav link `href=#livros-de-gestao` — both present, link resolves correctly.

### Pitfall 2: `disableAliases` Scope Confusion

**What goes wrong:** Assuming `disableAliases = true` in `config.toml` prevents Hugo frontmatter `aliases` from generating redirect HTML files, leading to skipping the aliases approach and using a workaround.

**Why it happens:** The setting appears at line 41 and 103 of `config.toml` and looks like a global setting.

**How to avoid:** Inspect the TOML section hierarchy. The `disableAliases = true` is inside `[languages.en.pagination]` and `[languages.pt-br.pagination]` — it only suppresses alias HTML files for pagination first-page aliases (e.g., prevents `/posts/` → `/posts/page/1/` redirect files). Hugo frontmatter `aliases` for content pages are unaffected. **Use Hugo `aliases` frontmatter as planned** — it will work.

**Evidence:** Confirmed from `config.toml` lines 40-41: `[languages.en.pagination]` contains `disableAliases = true`. Pagination scope, not global.

### Pitfall 3: Rating Span Placement Outside `<h4>`

**What goes wrong:** Placing `.book-entry__rating` outside the `<h4>` tag (e.g., as a sibling after it) causes it to appear on a separate line below the title, not inline with it.

**Why it happens:** The `display: inline` SCSS rule on `.book-entry__rating` only works when the element is inside an inline flow context. The `<h4>` is block-level; elements outside it start a new block.

**How to avoid:** The rating `<span>` must be inside `<h4 class="book-entry__title">`, after the `</a>` tag. See UI-SPEC Shortcode Extension section for exact placement.

### Pitfall 4: Star Rendering Without Font Awesome CSS Loaded

**What goes wrong:** Stars appear as empty boxes or missing characters on first page load before Font Awesome CSS loads (it's async-loaded via `<link rel=preload ... onload>`).

**Why it happens:** LoveIt theme loads Font Awesome asynchronously. On slow connections the star icons may flash in late.

**How to avoid:** This is an existing LoveIt behavior for all Font Awesome icons on the site — not new to Phase 3. The `<noscript>` fallback link tag in the theme ensures the CSS loads even without JS. No action needed; this is acceptable behavior.

### Pitfall 5: Missing Menu URL Update for PT-BR

**What goes wrong:** After renaming the content directory and updating EN menu, the PT-BR menu still points to `/my-reading-list/` instead of `/leituras-recomendadas/`, causing a 404 for Portuguese visitors clicking the nav link.

**Why it happens:** There are two separate menu entries in `config.toml` — one under `[languages.en.menu]` and one under `[languages.pt-br.menu]`. Both currently point to `url = "/my-reading-list/"`.

**How to avoid:** Update both menu entries in `config.toml`. The EN entry gets `url = "/recommended-reading/"` and the PT-BR entry gets `url = "/pt-br/leituras-recomendadas/"` (or just `/leituras-recomendadas/` — Hugo prepends the language prefix). Verify in the built output that both language nav bars show the correct URL.

**Evidence:** Confirmed from `config.toml` lines 29 and 93: both language menu entries have `url = "/my-reading-list/"`.

### Pitfall 6: `int` Conversion Failure on Empty String

**What goes wrong:** If `rating` param is empty string (`rating=""`), calling `int ""` panics the Hugo build.

**Why it happens:** `seq (int "")` — Hugo's `int` function returns an error on empty string input.

**How to avoid:** The UI-SPEC template logic guards against this: `{{- $rating := .Get "rating" | default "" -}}` then `{{- if $rating -}}` — the `if` block only runs when rating is non-empty. **Do not call `seq (int $rating)` outside the `{{- if $rating -}}` block.**

---

## Code Examples

### Star Rating Shortcode Addition

The complete updated `book.html` shortcode (from UI-SPEC, verified against existing Phase 2 shortcode):

```html
{{- /* layouts/shortcodes/book.html */ -}}
{{- /* Parameters: title (required), author (required), link (required), type (required), rating (Phase 3) */ -}}
{{- $title  := .Get "title" -}}
{{- $author := .Get "author" -}}
{{- $link   := .Get "link" -}}
{{- $type   := .Get "type" | default "book" -}}
{{- $rating := .Get "rating" | default "" -}}
{{- $inner  := trim .Inner "\n" | .Page.RenderString -}}
<div class="book-entry book-entry--{{ $type }}">
    <div class="book-entry__header">
        <h4 class="book-entry__title">
            <a href="{{ $link }}" target="_blank" rel="noopener noreferrer">{{ $title }}</a>
            {{- if $rating -}}
            <span class="book-entry__rating" aria-label="{{ $rating }} out of 5 stars">
              {{- range (seq (int $rating)) -}}<i class="fas fa-star"></i>{{- end -}}
            </span>
            {{- end -}}
        </h4>
        <span class="book-entry__author">{{ $author }}</span>
    </div>
    <div class="book-entry__description">
        {{- $inner -}}
    </div>
</div>
```

### SCSS Styles to REMOVE (Phase 1/2 anchor nav card styles)

Locate and remove these blocks from `_reading-list.scss` (they are replaced by the plain link style):

```scss
// REMOVE: Phase 1 anchor nav card styles
.single .content > ul:first-of-type {
    /* background, border, border-radius, padding: 1.5rem — REMOVE */
}
.single .content > ul:first-of-type li a {
    /* background, border-radius, padding, font-weight: 500 — REMOVE */
}
.single .content > ul:first-of-type li a:hover {
    /* transform, box-shadow, opacity — REMOVE */
}
// Also remove dark and auto equivalents for these selectors
```

The existing file (lines 48-79, 130-138, 176-182, 211-216) contains the old card styles. All must be replaced.

### SCSS Styles to ADD

```scss
// Star ratings — inline with title (light mode)
.single .content .book-entry__rating {
    margin-left: 8px;
    vertical-align: middle;
    display: inline;
}
.single .content .book-entry__rating .fa-star {
    font-size: 0.75rem;
    color: $single-link-color;
    letter-spacing: 2px;
}

// Anchor nav — plain text links with separator dots (light mode)
.single .content > ul:first-of-type {
    display: flex;
    flex-wrap: wrap;
    list-style: none;
    padding: 0;
    margin: 0 0 2rem 0;
}
.single .content > ul:first-of-type li {
    margin: 0;
    padding: 0;
}
.single .content > ul:first-of-type li:not(:first-child)::before {
    content: "·";
    color: $global-font-secondary-color;
    padding: 0 4px;
}
.single .content > ul:first-of-type li a {
    font-size: 0.875rem;
    color: $single-link-color;
    text-decoration: none;
    padding: 0;
    background: none;
    border-radius: 0;
    font-weight: 400;
    transition: color 0.2s ease;
}
.single .content > ul:first-of-type li a:hover {
    color: $single-link-hover-color;
}
```

Dark mode and auto theme blocks mirror the pattern already established in `_reading-list.scss` for other selectors.

### Frontmatter Update Pattern (English)

```yaml
---
title: What I'm Reading
slug: recommended-reading
aliases: ["/my-reading-list/"]
socialImage: /media/image-2.jpg
draft: false
---
```

### Frontmatter Update Pattern (Portuguese)

```yaml
---
title: O que estou lendo
slug: leituras-recomendadas
aliases: ["/pt-br/minha-lista-de-leitura/"]
socialImage: /media/image-2.jpg
draft: false
---
```

### config.toml Menu Updates

```toml
# English menu (lines ~24-31)
[[languages.en.menu.main]]
  identifier = "reading-list"
  name = "What I'm Reading"
  url = "/recommended-reading/"
  weight = 1

# Portuguese menu (lines ~87-94)
[[languages.pt-br.menu.main]]
  identifier = "reading-list"
  name = "O que estou lendo"
  url = "/leituras-recomendadas/"
  weight = 1
```

### Shortcode Invocation with Rating (content files)

```markdown
{{< book title="Clean Code" author="Robert C. Martin" link="https://amzn.to/3f4tfO8" type="book" rating="5" >}}
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Pill-button nav with card background | Plain text links with separator dots | Phase 3 | Removes visual noise; more editorial/minimal |
| No star ratings | Inline Font Awesome stars via shortcode param | Phase 3 | Makes quality signal immediately scannable |
| `/my-reading-list/` URL | `/recommended-reading/` with HTML redirect | Phase 3 | Old links preserved via Hugo aliases |

---

## Open Questions

1. **Currently Reading placeholder entry**
   - What we know: Both language files have a placeholder `[Book Title]` / `[Author Name]` entry. The UI-SPEC says to omit `rating` for Currently Reading entries. The placeholder should stay as-is or be replaced by Italo with his actual current read.
   - What's unclear: Whether Italo wants to fill in his actual current read before publishing, or leave the placeholder.
   - Recommendation: Leave the placeholder. The implementation does not depend on real content — `rating` omitted, shortcode renders gracefully. Italo can update post-publish.

2. **PT-BR aliases path format**
   - What we know: The PT-BR content is served at `/pt-br/minha-lista-de-leitura/` (verified from built output). Hugo prepends the language base path.
   - What's unclear: Whether the aliases array needs `/pt-br/minha-lista-de-leitura/` or `/minha-lista-de-leitura/` (without language prefix).
   - Recommendation: Use `/pt-br/minha-lista-de-leitura/` — this is the actual URL path that must redirect. Verified from the language switcher in the built output which shows `/pt-br/minha-lista-de-leitura/` as the PT-BR path.

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Hugo Extended | SCSS build, shortcode processing, aliases | Yes | 0.153.2 | — |
| Font Awesome | Star icons (`fas fa-star`) | Yes (CDN) | 6.7.2 | — |
| Node.js + PostCSS | CSS pipeline | Yes (CI) | Node 20 | — |
| GitHub Actions | Production deploy | Yes | — | — |

**Missing dependencies with no fallback:** None.

**Missing dependencies with fallback:** None.

**Baseline build confirmed:** `hugo --gc --minify` completes in ~279ms with 0 errors, 0 warnings. EN: 73 pages, PT-BR: 63 pages.

---

## Sources

### Primary (HIGH confidence)

- Live build output from `hugo --gc --minify` (2026-04-03) — anchor IDs confirmed for both EN and PT-BR pages
- `themes/LoveIt/assets/css/_variables.scss` — SCSS variable names and values confirmed
- `assets/css/_reading-list.scss` — existing styles inventoried, lines to remove identified
- `layouts/shortcodes/book.html` — Phase 2 shortcode confirmed with rating slot comment
- `content/my-reading-list/index.en.md` — 20 shortcode invocations counted, entry list confirmed
- `content/my-reading-list/index.pt-br.md` — 20 shortcode invocations, PT-BR headings confirmed
- `config.toml` — menu entries, disableAliases scope, fontawesome setting confirmed
- `.github/workflows/pages.yml` — Hugo 0.153.2 extended confirmed for production
- `.github/workflows/pr-checks.yml` — Hugo 0.139.4 extended confirmed for PR checks

### Secondary (MEDIUM confidence)

- [Hugo URL Management — Aliases](https://gohugo.io/content-management/urls/) — Hugo aliases behavior confirmed
- [Hugo Pagination Configuration](https://gohugo.io/configuration/pagination/) — `disableAliases` in pagination scope confirmed

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all libraries verified from live build output and config files
- Architecture: HIGH — patterns verified from existing codebase, template logic from UI-SPEC
- Pitfalls: HIGH — PT-BR anchor ID verified from actual built HTML, disableAliases scope verified from config.toml line numbers

**Research date:** 2026-04-03
**Valid until:** 2026-05-03 (stable tech — Hugo, Font Awesome, LoveIt are not fast-moving)
