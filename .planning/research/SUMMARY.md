# Project Research Summary

**Project:** italovietro.com — Reading List Redesign
**Domain:** Hugo static site page redesign (LoveIt theme customization)
**Researched:** 2026-04-03
**Confidence:** HIGH

## Executive Summary

This project is a focused redesign of a single Hugo page — the personal reading list — within an existing site that already uses Hugo v0.153.2+extended and the LoveIt theme. The redesign goal is to replace a card-based layout with an editorially clean, typography-driven list that references The Pragmatic Engineer's reading list as a benchmark. No new dependencies are needed: all required capabilities are already present in the stack. The implementation path is entirely additive: a custom layout override, a new SCSS partial, and a data migration from inline markdown to frontmatter YAML.

The recommended approach builds in three sequential phases: first establish a correct CSS foundation (eliminating the current broken dark mode styles and inline `<style>` blocks), then restructure the content and implement differentiating features (star ratings, "Currently Reading" section, consolidated book picks), and finally polish and prepare for publishing (Portuguese translation sync, redirect handling, and final UX verification). This order is driven by a critical finding: the current page uses CSS custom properties (`var(--header-title-color)` etc.) that do not exist in LoveIt's compiled output, meaning dark mode is silently broken today. Any new styling built on top of the current approach inherits this bug. The foundation must be fixed first.

The key risk is scope creep in the content curation phase. Migrating books from inline markdown to structured frontmatter YAML, consolidating book picks from three CTO Reading List blog posts, and assigning star ratings to every entry are all content decisions — not engineering tasks — and each one requires a judgment call. The mitigation is to treat content decisions as first-class deliverables in Phase 2, not afterthoughts that can be done "later." The Portuguese translation is a hard dependency for any deployment, not an optional step.

---

## Key Findings

### Recommended Stack

No new packages or tooling are required. The entire redesign is executable with Hugo v0.153.2+extended (already running locally), the LoveIt theme (already installed as a submodule), SCSS via Hugo Pipes (already compiling through `assets/css/_custom.scss`), and optionally Font Awesome icons (already loaded by LoveIt). Unicode stars are recommended for initial implementation due to zero additional asset requests; Font Awesome is a clean upgrade path if half-star precision is later required.

**Core technologies:**
- Hugo v0.153.2+extended: static site generator — already in use; Extended build required for SCSS compilation
- LoveIt theme: base theme — override via `layouts/` and `assets/css/` is the correct, submodule-safe integration path
- SCSS via Hugo Pipes: page-scoped styles — `assets/css/_custom.scss` already feeds into the SCSS pipeline; add a clearly delimited reading-list section
- Hugo frontmatter YAML: structured book data — keeps data with the page, avoids a separate `data/` directory, supports per-language translation
- Unicode stars (★/☆): star ratings — zero dependencies, accessible with `aria-label`, upgradeable to Font Awesome if half-stars are needed

### Expected Features

**Must have (table stakes):**
- Anchor-based category navigation — long pages without jump links frustrate readers; currently partially present
- Category sections with clear headings — visitors self-select by role; an unorganized list feels like a dump
- Per-entry description (1-3 sentences) — title alone is insufficient; "why should I read this?" drives clicks
- External link per entry — the call-to-action is "find the book"; a list without links is a dead end
- Page-level intro paragraph — sets curator authority and reading philosophy; already present and strong
- Mobile-responsive layout — handled by LoveIt theme; new layout must not break it
- Light/dark mode compatibility — the site already supports both; hardcoded colors would look broken

**Should have (differentiators):**
- Star ratings (5-star, Unicode) — single highest-signal differentiator; makes top picks scannable instantly
- "Currently Reading" section at top — makes the page feel live; increases return visits
- Consolidated book picks from CTO blog posts — three blog editions contain buried book picks; surfaces a single shareable URL
- "Last updated" timestamp — signals the page is maintained; increases trust in curated lists
- Page rename/rebrand title — signals audience ("Recommended Reading for Engineering Leaders") in shared links
- Personal voice per entry — already a differentiator in existing content; apply same standard to new entries

**Defer (v2+):**
- "Back to top" links — nice to have, low cost, add only if time allows
- Per-section tier labels refinement — already present as bold text; polish can wait
- Auto-generated reading stats — requires data model and JS; no reader value in this milestone
- Interactive filtering/sorting — list is too small to need it; adds maintenance surface

### Architecture Approach

The architecture follows Hugo's established content-type layout override pattern, already demonstrated in this project by `layouts/talks/single.html`. A new `layouts/my-reading-list/single.html` takes priority over the theme's default single layout for this page only, with no risk of theme-update breakage since all customizations live in `layouts/` and `assets/css/`. Book data migrates from inline markdown lists to frontmatter YAML, iterated by the custom layout template. A new `assets/css/_reading-list.scss` is imported by `_custom.scss` and handles all page-scoped styles with proper `[theme=dark]` SCSS selectors.

**Major components:**
1. `layouts/my-reading-list/single.html` — custom layout template; iterates over frontmatter book data, renders star ratings via a partial, scopes the `reading-list` CSS class
2. `layouts/partials/star-rating.html` — reusable partial; converts numeric `rating` field to semantic HTML `<span>` elements with `aria-label`
3. `assets/css/_reading-list.scss` — all page-scoped styles; uses `[theme=dark] &` SCSS pattern for correct dark mode; imported by `_custom.scss`
4. `content/my-reading-list/index.en.md` + `index.pt-br.md` — content files migrated to frontmatter YAML for books; inline `<style>` blocks removed entirely
5. `assets/css/_custom.scss` (extended) — defines scoped CSS custom properties (Option A) for reading list colors in both `:root` and `[theme=dark]` blocks

### Critical Pitfalls

1. **Non-existent CSS custom properties** — the current page uses `var(--header-title-color)`, `var(--single-link-color)`, `var(--global-border-color)` which do not exist in LoveIt. Dark mode is silently broken today. Fix before adding any new styles: declare scoped custom properties in `_custom.scss` with both light and dark values, or use `[theme=dark] &` SCSS selectors.

2. **Inline `<style>` blocks duplicated across language files** — any CSS change must be applied to both `index.en.md` and `index.pt-br.md`. During a redesign that touches typography, spacing, and section structure, this guarantees drift. Resolution: move all styles to `assets/css/_reading-list.scss` immediately, before adding new rules.

3. **Heading text controls anchor IDs — changes break links** — Goldmark auto-generates anchor IDs from heading text. If headings are renamed as part of the redesign, all anchor navigation links break silently. Resolution: finalize heading text before building the navigation list; optionally use explicit `{#anchor-id}` Goldmark attributes.

4. **Hugo Extended required for SCSS; CI/CD version mismatch** — two GitHub Actions workflows use different Hugo versions (`pages.yml` = 0.153.2, `pr-checks.yml` = 0.139.4). If the Extended flag is dropped from either, SCSS customizations silently disappear in production using the stale `resources/` cache. Resolution: verify both workflows use `extended: true` before adding new SCSS; do not commit the `resources/` folder.

5. **Star ratings not dark-mode aware without explicit CSS** — Unicode stars inherit text color (which works) but filled and empty stars look identical if not given separate color treatment. Emoji stars (`⭐`) are OS-rendered color glyphs and cannot be styled with CSS. Resolution: use CSS classes on star spans with explicit `[theme=dark]` color rules in `_reading-list.scss`.

---

## Implications for Roadmap

Based on research, the dependency chain is clear and dictates phase ordering:

```
CSS foundation (fix broken dark mode, extract inline styles)
    ↓
Content restructure (frontmatter YAML, book consolidation, heading lock)
    ↓
Feature implementation (star ratings, Currently Reading section, anchor nav)
    ↓
Polish and publishing (Portuguese sync, redirect, final verification)
```

### Phase 1: CSS Foundation and Layout Scaffold

**Rationale:** The current inline `<style>` blocks use CSS custom properties that do not exist in LoveIt. Building any new feature on top of the current broken foundation guarantees dark-mode defects. This must be fixed first, in isolation, so it can be verified before anything else is built on top.

**Delivers:** A custom layout override at `layouts/my-reading-list/single.html`, SCSS custom property declarations in `_custom.scss`, `_reading-list.scss` with correct `[theme=dark]` support, and removal of all inline `<style>` blocks from both language content files. CI/CD workflows verified to use Hugo Extended.

**Addresses:** Mobile-responsive layout, light/dark mode compatibility (table stakes).

**Avoids:** Undefined CSS custom properties, inline style duplication across language files, Hugo Extended CI/CD mismatch.

---

### Phase 2: Content Restructure and Data Migration

**Rationale:** Before implementing star ratings or anchor navigation, book data must be in frontmatter YAML and headings must be finalized. Star ratings require a numeric `rating` field per entry. Anchor navigation requires stable heading text. Both depend on this phase completing first.

**Delivers:** Book metadata migrated from markdown lists to frontmatter YAML in `index.en.md` (and stubbed for `index.pt-br.md`). Final heading text locked. "Software Engineering at Google" and any other missing books from the three CTO Reading List posts added. Content decision: which books from blog posts get consolidated.

**Addresses:** Consolidated content from CTO blog posts, per-entry descriptions, external links (table stakes and differentiator).

**Avoids:** Anchor IDs broken by heading rename (lock headings in this phase before building nav in Phase 3).

---

### Phase 3: Feature Implementation

**Rationale:** With layout scaffold and structured data in place, all differentiating features can be implemented in one phase. Star ratings, "Currently Reading," anchor navigation, and the page rename are all independent of each other but all depend on Phases 1 and 2.

**Delivers:** Star ratings rendered via `layouts/partials/star-rating.html` with proper `aria-label` and dark mode support. "Currently Reading" section at the top of the page (1-3 entries). Anchor navigation ToC with verified heading IDs. "Last updated" timestamp. Page title update to audience-signaling copy. A star rating legend near the top of the page.

**Addresses:** Star ratings, "Currently Reading" section, anchor navigation, last updated timestamp, page rename (all differentiators).

**Avoids:** Star ratings not dark-mode aware (test both modes before finalizing), anchor navigation links pointing to wrong IDs.

---

### Phase 4: Polish and Publishing

**Rationale:** Portuguese translation sync and redirect handling are hard dependencies for deployment. Both require revisiting content decisions from Phase 2, so they cannot be parallelized with it — only after English is finalized can Portuguese be updated accurately.

**Delivers:** `index.pt-br.md` updated with all content and structural changes from `index.en.md`. Page slug decision finalized: if slug changes, a redirect mechanism is in place at the old URL. Full "Looks Done But Isn't" checklist verified (dark mode, star rendering in Chrome/Firefox, anchor clicks, DevTools `var()` resolution, above-the-fold Currently Reading on both 1280px and 375px viewports).

**Addresses:** Multi-language content sync, page rename/slug stability, UX verification.

**Avoids:** Portuguese version drifting from English, old slug breaking bookmarked links.

---

### Phase Ordering Rationale

- **Foundation before features:** The CSS is broken today. New features built on a broken foundation inherit the breakage. Fix first, verify, then build.
- **Data before rendering:** Star ratings and the custom template both require structured frontmatter data. Migrating content before building the renderer avoids rework.
- **Lock headings before building nav:** Anchor IDs are derived from heading text. The navigation list is built from those anchors. If the order is reversed, any heading rename forces updating the nav links.
- **English before Portuguese:** Content decisions (which books to add, what star ratings to assign, what "Currently Reading" entries to include) should be made once, in the primary language, before being translated. This avoids making the same judgment call twice under time pressure.

### Research Flags

Phases with standard patterns (skip research-phase):
- **Phase 1:** Hugo layout override and SCSS pipeline are well-documented with a working example already in the project (`layouts/talks/single.html`). No additional research needed.
- **Phase 3:** Hugo partial rendering and frontmatter YAML iteration are standard Hugo patterns. Star rating partial is a solved problem (researched and documented in ARCHITECTURE.md with a complete example).

Phases that may need a focused spike before execution:
- **Phase 2:** No technical research needed, but this phase involves content curation decisions (which books from the three CTO Reading List blog posts to consolidate). These are editorial decisions, not engineering tasks. Treat them as explicit work items, not background tasks.
- **Phase 4:** The redirect mechanism for GitHub Pages needs a one-time check. GitHub Pages does not natively support Netlify `_redirects` files; the correct approach for a slug change is a `<meta http-equiv="refresh">` page at the old path or keeping the slug stable. Verify the deployment setup before finalizing the page rename decision.

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All findings from direct codebase inspection + official Hugo docs. No third-party dependencies being introduced. |
| Features | HIGH | Reference design (Pragmatic Engineer) directly inspected. NNGroup usability research cited. Existing site content read directly. |
| Architecture | HIGH | All patterns verified against LoveIt theme source files and existing project override patterns. Critical CSS custom property bug confirmed by inspecting compiled output. |
| Pitfalls | HIGH | Each pitfall confirmed by direct inspection of the actual broken code in `index.en.md` and LoveIt's compiled CSS. Not theoretical. |

**Overall confidence: HIGH**

### Gaps to Address

- **Star rating visual approach:** The research recommends Unicode stars with CSS color control, but does not specify the exact light/dark color values for filled vs. empty stars. During Phase 3, pick values from LoveIt's `_variables.scss` (e.g., `$single-link-color` hex value for filled stars) and verify in both modes before committing.

- **Page slug decision:** Keeping `my-reading-list` as the slug is recommended for URL stability. If the title changes to "Recommended Reading for Engineering Leaders," the slug does not need to change. Confirm this decision before Phase 4, as it determines whether a redirect is needed.

- **Portuguese translation scope:** The pt-br content file currently mirrors the English structure but may have diverged in personal commentary. During Phase 2 English content curation, note which entries are new or changed so Phase 4 pt-br sync has a clear diff to work from.

---

## Sources

### Primary (HIGH confidence)
- Hugo documentation — layout lookup order: https://gohugo.io/templates/lookup-order/
- Hugo documentation — shortcode templates: https://gohugo.io/templates/shortcode-templates/
- Hugo documentation — configure markup (Goldmark): https://gohugo.io/configuration/markup/
- LoveIt theme source: `themes/LoveIt/assets/css/_variables.scss`, `_core/_variables.scss` — direct inspection confirming no color custom properties in `:root`
- LoveIt compiled CSS: `themes/LoveIt/resources/_gen/assets/css/style.scss_*.content` — confirmed `--global-background-color` etc. absent from `:root`
- Existing project layout: `layouts/talks/single.html` — confirmed override pattern already in use
- Existing content: `content/my-reading-list/index.en.md`, `index.pt-br.md` — confirmed broken `var()` references and inline style duplication
- Existing CI/CD: `.github/workflows/pages.yml`, `pr-checks.yml` — confirmed Hugo version mismatch
- NNGroup — Table of Contents: https://www.nngroup.com/articles/table-of-contents/
- NNGroup — In-Page Links: https://www.nngroup.com/articles/in-page-links-content-navigation/

### Secondary (MEDIUM confidence)
- The Pragmatic Engineer — My Reading & Listening List: https://blog.pragmaticengineer.com/my-reading-list/ — reference design directly inspected
- Lethain.com — Best Books: https://lethain.com/best-books/ — alternative pattern without star ratings
- Hugo Discourse — Overriding Theme SCSS: https://discourse.gohugo.io/t/overriding-theme-scss/29379
- Hugo Discourse — Star Rating for Hugo Sites: https://discourse.gohugo.io/t/star-rating-for-hugo-sites/18633
- LoveIt Official Docs: https://hugoloveit.com/theme-documentation-basics/
- Case study — Hugo CSS Override Failure (stale resources/ cache): https://sammart.in/hugo-css-override-failure/

---
*Research completed: 2026-04-03*
*Ready for roadmap: yes*
