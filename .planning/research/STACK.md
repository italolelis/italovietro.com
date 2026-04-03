# Technology Stack

**Project:** italovietro.com — Reading List Redesign
**Researched:** 2026-04-03
**Hugo Version:** v0.153.2+extended (confirmed via `hugo version`)

---

## Recommended Stack

No new dependencies. All features are achievable with the tools already in the project.

### Core Framework

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Hugo | v0.153.2+extended | Static site generator | Already in use; `+extended` build enables SCSS compilation |
| LoveIt theme | current | Base theme | Already in use; override mechanism is the right integration path |

### Styling

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| SCSS (via Hugo Pipes) | Hugo built-in | Page-scoped styles for reading list | `assets/css/_custom.scss` already feeds into Hugo's SCSS pipeline. One file, no new tooling. |
| CSS custom properties | n/a | Light/dark theming | LoveIt exposes `--global-font-color`, `--global-font-secondary-color`, `--global-border-color`, `--single-link-color`, `--global-background-color` etc. Use these — do not hardcode colors. |

### Hugo Features Required

| Feature | Mechanism | Purpose | Notes |
|---------|-----------|---------|-------|
| Custom page layout | `layouts/my-reading-list/single.html` | Override the default single.html for this page only | Hugo lookup order: content-type-specific layouts take priority over `_default`. The directory name must match the content directory name (`my-reading-list`). |
| Hugo shortcodes | `layouts/shortcodes/book.html` | Render a single book entry (title, author, stars, note) | Shortcode accepts named params; keeps content human-editable while separating rendering concerns. |
| Hugo data files (optional) | `data/books.yaml` | Store book list as structured data | Use only if auto-generating the list from frontmatter — skip for this milestone; markdown is simpler to edit. |
| HTML anchors | Native markdown heading IDs | Category navigation | Hugo auto-generates `id` attributes from headings. `## Engineering Books` becomes `#engineering-books`. No extra work needed. |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Font Awesome | Already loaded by LoveIt | Star icons (`fa-star`, `fa-star-half-alt`, `far fa-star`) | LoveIt already loads FA via its CDN config. Use `<i class="fas fa-star">` in shortcodes — free, accessible, supports half-stars. |

---

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Star ratings | Unicode stars (`★`) or Font Awesome icons | SVG custom icons | FA is already loaded by LoveIt; unicode is zero-dependency. FA wins on accessibility (`aria-label`) and half-star support. Unicode wins on simplicity. Either works — see decision note below. |
| Layout override | `layouts/my-reading-list/single.html` | Inline `<style>` in markdown (current approach) | Inline style blocks work but pollute content files, can't be shared across en/pt-br without duplication, and are harder to maintain. A layout file is the Hugo-idiomatic solution. |
| Book data | Markdown content with shortcodes | `data/books.yaml` + template loop | Data files add a layer of indirection. For ~20-30 books, shortcodes in markdown are easier to read, edit, and review. Data files make sense if the list grows to 100+ entries or needs programmatic sorting. |
| CSS in `_custom.scss` | Yes | Separate per-page CSS file | `_custom.scss` already exists, already compiles, already has the right scope. Adding a clearly-delimited section (`// ===== Reading List =====`) is sufficient. No new file needed. |

---

## Architecture Decision: Unicode vs Font Awesome Stars

**Recommendation: Unicode stars (`★☆`) for initial implementation.**

- Zero additional asset requests — FA is loaded by LoveIt but only when the theme decides to include it; adding an explicit dependency on FA icons from custom code is coupling to LoveIt internals.
- Unicode `★` (U+2605, filled) and `☆` (U+2606, empty) render reliably in all browsers.
- Accessible with a single `aria-label="4 out of 5 stars"` on the container.
- If half-stars are needed later, switch to FA or use `½` (U+00BD) combined with `★`.

**Half-star support:** If half-star precision is required (e.g., 4.5 stars), Font Awesome's `fa-star-half-alt` is the cleanest option. Decide based on whether ratings use `.5` increments.

---

## Key Integration Points with LoveIt

### Layout Override Pattern

Hugo resolves layouts in this order for `content/my-reading-list/index.en.md`:

```
layouts/my-reading-list/single.html    ← project override (USE THIS)
layouts/_default/single.html           ← theme fallback
themes/LoveIt/layouts/_default/single.html
```

Create `layouts/my-reading-list/single.html` as a copy/extension of the theme's `single.html`. The theme's single.html wraps content in `<div class="content" id="content">` — preserve that wrapper so existing CSS variables apply.

### CSS Variables in Scope

These LoveIt CSS variables are guaranteed to be in scope and respect light/dark mode. Use them exclusively — do not hardcode hex values:

```
--global-font-color          → body text
--global-font-secondary-color → metadata, secondary text (author, year)
--global-border-color         → section dividers
--single-link-color           → book title links
--global-background-color     → page/section backgrounds
--header-title-color          → section headings (h2/h3)
```

The theme toggles these via `[theme=dark]` attribute on `<html>`. Any element that references these variables gets dark mode for free.

### SCSS Addition Pattern

Add reading-list styles to `assets/css/_custom.scss` under a clearly marked section:

```scss
// ===== Reading List =====
.reading-list { ... }
.book-entry { ... }
.star-rating { ... }
// ===== /Reading List =====
```

This file is already imported by Hugo's SCSS pipeline. No configuration change needed.

### Multi-language Support

The content directory `my-reading-list/` contains `index.en.md` and `index.pt-br.md`. Both files render using the same layout template (`layouts/my-reading-list/single.html`). CSS changes apply to both languages automatically. Content (book titles, descriptions) must be updated in both files independently — there is no automatic translation mechanism in this stack.

If a shortcode is added (`layouts/shortcodes/book.html`), it applies to both languages. Use `i18n` strings in shortcodes only if the shortcode contains UI text (e.g., "Currently Reading" label) — otherwise plain HTML is fine.

---

## What NOT to Use

| Approach | Why Not |
|----------|---------|
| JavaScript for star ratings | No interactivity needed. Pure CSS/HTML stars are sufficient and load faster. Zero JS is the goal. |
| External CSS framework (Tailwind, Bootstrap) | Would conflict with LoveIt's CSS cascade and introduce a build dependency. All needed styles fit in ~50 lines of custom SCSS. |
| Hugo data files for books | Adds authoring friction. Markdown with shortcodes is simpler for a 20-30 book list. |
| Book cover images | Explicitly out of scope per PROJECT.md. Clean typography-driven design requires no images. |
| Card-based layout with hover transforms | Current approach being replaced. Box shadows and card transforms add visual noise; the reference design (Pragmatic Engineer) uses flat text lists. |
| Separate CSS file per page | Hugo's `_custom.scss` pipeline handles all custom CSS. Adding per-page CSS requires either inline `<style>` tags (current problem) or a Hugo Pipes setup more complex than needed. |

---

## Installation

No new packages to install. All required capabilities are already present:

```bash
# Nothing to install — stack is complete
# Verify build works:
hugo server -D
```

---

## Sources

- Hugo documentation on layout lookup order: https://gohugo.io/templates/lookup-order/ (HIGH confidence — official docs)
- Hugo shortcode documentation: https://gohugo.io/templates/shortcode-templates/ (HIGH confidence — official docs)
- LoveIt theme CSS variables: inspected from `themes/LoveIt/assets/css/_variables.scss` and `_core/_variables.scss` in this repository (HIGH confidence — source inspection)
- Font Awesome star icons: https://fontawesome.com/icons/star (HIGH confidence — confirmed FA is loaded by LoveIt theme)
- Hugo v0.153.2 release: confirmed via `hugo version` on local machine (HIGH confidence)
