# Pitfalls Research

**Domain:** Hugo static site reading list redesign (LoveIt theme customization)
**Researched:** 2026-04-03
**Confidence:** HIGH — findings backed by direct codebase inspection and verified against LoveIt source

---

## Critical Pitfalls

### Pitfall 1: Using Non-Existent CSS Custom Properties

**What goes wrong:**
The current reading list markdown (`content/my-reading-list/index.en.md`) uses `var(--header-title-color)`, `var(--single-link-color)`, and `var(--global-border-color)` in its inline `<style>` block. None of these CSS custom properties are declared anywhere in LoveIt. The theme uses SCSS variables (`$single-link-color`, `$global-border-color`, etc.) that compile to hardcoded hex values — they are never exposed as CSS custom properties on `:root`. The inline styles therefore silently fall back to the browser default, and the page renders incorrectly in both light and dark mode without any build error.

**Why it happens:**
Developers assume SCSS variables like `$single-link-color` automatically become `var(--single-link-color)` CSS custom properties. They don't. LoveIt only exposes a small set of CSS custom properties — font families, font sizes, and a few sizing tokens — not color values. Color theming is done through SCSS compilation with `[theme=dark] &` selectors, not runtime CSS variables.

**How to avoid:**
Only use CSS custom properties that are actually declared in `:root` within LoveIt's compiled CSS. Verified LoveIt custom properties as of LoveIt 0.2.X:
- `--global-font-family`, `--global-font-size`, `--global-font-weight`, `--global-line-height`
- `--header-height`, `--header-title-font-family`, `--header-title-font-size`
- `--toc-title-font-size`, `--toc-content-font-size`
- `--code-font-family`, `--code-font-size`

For colors, either: (a) use the hardcoded hex values from `_variables.scss` directly, (b) declare your own custom properties in `_custom.scss` with both light and dark values, or (c) use `[theme=dark] &` SCSS selectors in `_custom.scss`.

**Warning signs:**
- Color styling looks wrong but no build errors appear
- Light/dark mode has no effect on inline-styled elements
- Browser DevTools shows `var(--single-link-color)` computing to an empty string

**Phase to address:**
Phase 1 (CSS foundation) — audit all `var(--...)` usages in the inline `<style>` block and replace with correct values before adding new styles.

---

### Pitfall 2: Inline `<style>` in Markdown Duplicated Across Language Versions

**What goes wrong:**
The current `index.en.md` and `index.pt-br.md` both contain a full copy of the `<style>` block. Any CSS change must be applied twice. During a redesign that changes typography, spacing, star ratings, and section structure, this doubles the maintenance surface and guarantees drift — the two versions will eventually diverge.

**Why it happens:**
Hugo's multi-language content model requires separate files per language. There is no built-in mechanism to share inline styles between language variants of the same page.

**How to avoid:**
Move all page-specific CSS to `assets/css/_custom.scss`. This file is compiled once and applies to all pages in all languages. The markdown files become style-free — only content. If a custom layout template is created for the reading list (e.g. `layouts/my-reading-list/single.html`), styles can also be scoped there.

**Warning signs:**
- Editing the `<style>` block in one language file and having to remember to update the other
- CSS diffs showing different rules in `.en.md` vs `.pt-br.md`

**Phase to address:**
Phase 1 (CSS foundation) — extract all inline styles to `_custom.scss` before adding any new rules.

---

### Pitfall 3: Heading Text Controls Anchor IDs — Changes Break Existing Links

**What goes wrong:**
Hugo's Goldmark renderer auto-generates anchor IDs from heading text. The planned "anchor-based category navigation" links (e.g. `#engineering-books`) depend on these IDs remaining stable. If heading text changes as part of the redesign (e.g. renaming "Engineering Books" to "Engineering"), the anchor changes and any external links or bookmark links break silently. With a page rename/rebrand also planned, the slug change itself breaks inbound links.

**Why it happens:**
Goldmark lowercases the heading text, replaces spaces and non-alphanumeric characters with hyphens, and deduplicates collisions. The ID is not independently configured — it is derived purely from the visible heading text.

**How to avoid:**
Two strategies:
1. Decide on final heading text before building the navigation links. Don't build the anchor nav first and then rename headings.
2. Use explicit heading IDs via Goldmark's attribute syntax: `## Engineering Books {#engineering-books}` — this requires `[markup.goldmark.parser.attribute] block = true` to be set in `config.toml`. Check the existing config before using this syntax; it may already be enabled (the site has Goldmark extensions configured).

For the page rename/rebrand: add a redirect from the old slug to the new one in `static/_redirects` (GitHub Pages supports Netlify-style redirects via a `_redirects` file, but GitHub Pages itself does not natively — the correct approach is a `<meta http-equiv="refresh">` page or a 301 via a custom 404 page).

**Warning signs:**
- Navigation anchor links return 404 or don't scroll to the right section
- Heading text was edited after navigation was built

**Phase to address:**
Phase 2 (content restructure) — finalize heading text and page slug before building navigation. Lock headings before wiring up anchor links.

---

### Pitfall 4: Hugo Extended Required for SCSS — CI/CD Version Mismatch Silently Degrades Styles

**What goes wrong:**
Custom styles in `_custom.scss` and `_override.scss` require Hugo Extended to compile SCSS. If the CI/CD environment runs standard Hugo (without Extended), the build succeeds but serves stale cached CSS from the `resources/` folder — specifically the theme's default styles, not the customizations. This is a documented failure mode: Hugo finds cached compiled CSS and uses it without recompiling.

**Why it happens:**
The project already has a version mismatch: `pages.yml` uses Hugo 0.153.2 (Extended) but `pr-checks.yml` uses Hugo 0.139.4. If the Extended flag is accidentally dropped from either workflow, or if the `resources/` cache becomes stale, custom styles disappear in production without a build failure.

**How to avoid:**
- Verify both GitHub Actions workflows explicitly use Hugo Extended (the `-extended` suffix or `extended: true` parameter)
- Do not commit the `resources/` folder — let the CI/CD regenerate it each build
- After any CSS change, verify the deployed site visually, not just check for a green build

**Warning signs:**
- Styles look correct locally but wrong in production/PR preview
- `resources/` folder is committed to git
- Build log shows CSS being loaded from cache rather than recompiled

**Phase to address:**
Phase 1 (CSS foundation) — verify CI/CD Extended flag before adding any new SCSS.

---

### Pitfall 5: Star Ratings via Unicode/Emoji Are Not Dark-Mode Aware

**What goes wrong:**
Star ratings implemented with Unicode characters (★ filled, ☆ empty) or emoji (⭐) have fixed color in light mode and may look identical or invisible in dark mode because LoveIt's dark mode uses `[theme=dark] &` CSS selectors. Unicode characters inherit text color, which changes in dark mode, but emoji are rendered by the OS as color glyphs and are unaffected by CSS `color` property. Mixed star approaches (e.g. ★★★☆☆ mixing filled and empty Unicode) work across modes but cannot be styled differently between filled/empty states without CSS.

**Why it happens:**
Unicode star characters appear to work in light mode and look fine in development. Dark mode testing is often skipped.

**How to avoid:**
Choose one approach and test both modes explicitly:
- Unicode characters (★ / ☆): simple, works in dark mode via inherited text color, but filled/empty look the same color. Add a CSS class like `.stars { color: #f5a623; }` scoped in `_custom.scss` with a dark-mode variant.
- Font Awesome stars (`fas fa-star`, `fas fa-star-half-alt`, `far fa-star`): the LoveIt theme already loads Font Awesome 5, so this is available without additional dependencies. Icons respond to CSS color, making dark-mode theming straightforward.
- Emoji (⭐): visually rich but cannot be CSS-colored; renders inconsistently across OS/browser. Avoid for a professional list.

The Font Awesome approach is the best fit for this site because the dependency is already present.

**Warning signs:**
- Star ratings look fine in light mode but disappear or look wrong in dark mode
- Inconsistent star appearance across macOS/Windows/iOS

**Phase to address:**
Phase 2 (feature implementation) — test star rendering in both light and dark mode before finalizing the approach.

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Inline `<style>` in markdown | Fast iteration, no new files needed | Duplicated across language files, invisible to SCSS tooling, not reusable | Never — for a planned redesign, use `_custom.scss` from the start |
| Hardcoded hex colors in custom CSS | Simple, works immediately | Breaks dark mode, diverges from theme color tokens | Only for one-off decoration that intentionally ignores theme |
| Direct HTML in markdown (unsafe mode) | Enables complex HTML structures | Goldmark `unsafe: true` is already enabled in this project — but it makes content harder to maintain and port | Acceptable for structural HTML that shortcodes cannot express; keep minimal |
| Skipping pt-br translation update | Faster delivery | English and Portuguese pages drift in content and layout | Never on a page being actively shared with colleagues |
| Building anchor nav before finalizing headings | See the navigation working early | Rework required every time heading text changes | Never — finalize headings first |

---

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| LoveIt dark mode | Using `var(--color)` CSS custom properties that don't exist in LoveIt | Use SCSS `[theme=dark] &` selectors in `_custom.scss`, or declare your own custom properties in `_custom.scss` |
| Hugo Goldmark attribute syntax | Expecting `{.class #id}` to work on headings without enabling it | Add `[markup.goldmark.parser.attribute] block = true` to `config.toml` |
| Font Awesome in markdown | Writing `<i class="fas fa-star"></i>` raw HTML | Use Hugo's FontAwesome shorthand `:fas fa-star:` syntax (LoveIt's `fontawesome` parameter must be enabled) |
| GitHub Actions Hugo Extended | Assuming `hugo-setup` action defaults to Extended | Explicitly set `extended: true` or use the `-extended` variant tag |
| Multi-language content sync | Updating only the English file | Always update `index.en.md` and `index.pt-br.md` together; use `hugo server --printI18nWarnings` to catch missing translations |

---

## Performance Traps

This is a static page redesign — scale is not a concern. The following traps are relevant within Hugo's build pipeline:

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Stale `resources/` cache in git | CSS customizations not appearing in CI builds | Do not commit `resources/` folder | Every CI build that hits the cache |
| Google Fonts in `_override.scss` | Additional render-blocking network request per page load | Already present in the project; acceptable for the site's current scale | Not a build problem, a perceived performance issue for readers |

---

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Anchor links with spaces or special chars in heading | `#Management-Books` vs `#management-books` — capitalization inconsistency breaks links shared externally | Verify generated IDs by inspecting rendered HTML; use lowercase heading text or explicit `{#anchor-id}` attributes |
| "Currently Reading" placed at bottom | The key differentiator of the redesign is invisible on first load | Place "Currently Reading" as the first section above the fold, before category navigation |
| Category navigation that lists too many categories | Nav becomes overwhelming; readers don't use it | Keep to 4-6 top-level categories maximum |
| Star rating without a legend | Readers don't know what 3 stars vs 5 stars means | Add a one-line key near the top: "★★★★★ Essential · ★★★★ Highly Recommended · ★★★ Good" |
| Page rename without redirect | Colleagues who bookmarked the old URL get a 404 | Add a `<meta http-equiv="refresh">` at the old slug, or keep the old slug with a `redirect_to` frontmatter param |

---

## "Looks Done But Isn't" Checklist

- [ ] **Dark mode:** Verify every new CSS rule in dark mode (`[theme=dark]` set in browser). LoveIt dark mode is JS-toggled, not `prefers-color-scheme` — must test manually with the toggle.
- [ ] **Star ratings:** Verify star glyphs render correctly in both Chrome and Firefox on both macOS and a light/dark toggle. Emoji and Unicode render differently across browsers.
- [ ] **Anchor navigation:** Click every anchor link to verify it scrolls to the correct heading. Check that heading IDs match exactly what Goldmark generates (lowercase, hyphens).
- [ ] **Portuguese version:** Confirm `index.pt-br.md` reflects all content changes from `index.en.md`. The current file has the full CSS block duplicated — confirm it is also updated or replaced.
- [ ] **Currently Reading section:** Verify it renders above the fold on a 1280px viewport and a mobile viewport (375px).
- [ ] **CSS custom properties resolved:** Open DevTools and confirm no `var(--header-title-color)` or `var(--single-link-color)` references are present in the final output (they should be replaced with actual values or removed).

---

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Undefined CSS custom properties silently ignored | LOW | Audit inline styles, replace `var(--non-existent)` with SCSS-backed values in `_custom.scss` |
| Inline styles duplicated across language files | LOW-MEDIUM | Extract to `_custom.scss`, remove inline blocks from both `.md` files |
| Anchor IDs broken by heading rename | LOW | Update anchor links in the navigation list to match new Goldmark-generated IDs |
| CI/CD serving stale cached CSS | LOW | Remove `resources/` from git, force a clean CI rebuild |
| Star ratings invisible in dark mode | LOW | Wrap star spans in a CSS class; add `[theme=dark] &` color rule in `_custom.scss` |
| Old page slug referenced externally | MEDIUM | Add a meta-refresh page at the old path, or keep the old slug active with a note redirecting readers |

---

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Undefined CSS custom properties (`var(--header-title-color)` etc.) | Phase 1: CSS foundation | DevTools shows no unresolved `var()` calls; light and dark mode colors match design intent |
| Inline style duplication across language files | Phase 1: CSS foundation | Both `.md` files contain no `<style>` blocks; all styles are in `_custom.scss` |
| Anchor IDs broken by heading rename | Phase 2: Content restructure | Final heading text locked; navigation links verified by clicking each anchor |
| Hugo Extended CI/CD mismatch | Phase 1: CSS foundation | Both `pages.yml` and `pr-checks.yml` confirmed to use `extended: true` |
| Star ratings dark mode failure | Phase 2: Feature implementation | Star display tested in LoveIt dark mode toggle manually |
| Page rename breaks existing links | Phase 3: Polish and publishing | Old slug verified — either redirect in place or slug kept stable |

---

## Sources

- Direct inspection: `themes/LoveIt/assets/css/_core/_variables.scss` — confirms only font/size tokens are exposed as CSS custom properties, not colors
- Direct inspection: `content/my-reading-list/index.en.md` — confirms use of `var(--header-title-color)`, `var(--single-link-color)`, `var(--global-border-color)` which do not exist in LoveIt
- Hugo Discourse: [Overriding Theme SCSS](https://discourse.gohugo.io/t/overriding-theme-scss/29379)
- Hugo Discourse: [Star Rating for Hugo Sites](https://discourse.gohugo.io/t/star-rating-for-hugo-sites/18633)
- LoveIt Official Docs: [Theme Documentation - Basics](https://hugoloveit.com/theme-documentation-basics/) — SCSS customization via `_override.scss` and `_custom.scss`
- Case study: [Hugo CSS Override Failure](https://sammart.in/hugo-css-override-failure/) — stale `resources/` cache causing CI to silently serve default styles
- Hugo Docs: [Configure Markup](https://gohugo.io/configuration/markup/) — Goldmark attribute syntax, heading ID generation
- Hugo Discourse: [Difference in auto-generated heading anchor names](https://discourse.gohugo.io/t/difference-in-auto-generated-heading-anchor-names-between-previous-versions-and-v0-60-0-or-higher/22076)

---
*Pitfalls research for: Hugo/LoveIt reading list redesign*
*Researched: 2026-04-03*
