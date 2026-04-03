# Architecture Research

**Domain:** Hugo SSG page redesign (reading list) with LoveIt theme
**Researched:** 2026-04-03
**Confidence:** HIGH — all findings based on direct inspection of the existing codebase

## Standard Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Hugo Build Pipeline                      │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────────┐  │
│  │ Content     │  │ Data Files   │  │ Layout Templates   │  │
│  │ (Markdown)  │  │ (YAML/TOML)  │  │ (HTML + Go tmpl)   │  │
│  └──────┬──────┘  └──────┬───────┘  └─────────┬──────────┘  │
│         │                │                    │              │
│         └────────────────┴────────────────────┘              │
│                          │                                   │
│                    Hugo Renderer                             │
│                          │                                   │
├──────────────────────────┼───────────────────────────────────┤
│  ┌────────────────────────▼───────────────────────────────┐  │
│  │               assets/css/_custom.scss                  │  │
│  │          (compiled with LoveIt theme SCSS)             │  │
│  └────────────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                    Static Output (public/)                   │
└─────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Current State |
|-----------|----------------|---------------|
| `content/my-reading-list/index.en.md` | Book/resource data + page prose | Markdown list items with inline `<style>` block |
| `content/my-reading-list/index.pt-br.md` | Portuguese translation | Mirrors English structure, contains duplicate CSS |
| `layouts/_default/single.html` (theme) | Wraps all page content | Used by reading list; renders `.Content` into `.content` div |
| `layouts/talks/single.html` | Custom single layout override | Demonstrates the override pattern already in use |
| `assets/css/_custom.scss` | Site-wide custom styles | Logo theming only; not used for reading list |
| `assets/css/_override.scss` | SCSS variable overrides | Font family only |

## Recommended Project Structure

```
layouts/
└── my-reading-list/
    └── single.html              # Custom layout for reading list only

assets/css/
├── _custom.scss                 # Existing (logo styles)
└── _reading-list.scss           # New: reading list styles (imported by _custom.scss)

content/my-reading-list/
├── index.en.md                  # Frontmatter: books as structured data OR prose
└── index.pt-br.md               # Portuguese version
```

No `data/` directory is needed. See the Data Model section for rationale.

### Structure Rationale

- **`layouts/my-reading-list/single.html`:** Hugo resolves templates by content type. A file at this path automatically applies to `content/my-reading-list/` without requiring any frontmatter override. Mirrors the existing `layouts/talks/single.html` pattern already in the project.
- **`assets/css/_reading-list.scss`:** Compiled by Hugo Pipes alongside `_custom.scss`. Keeps styles separate from content. LoveIt theme includes `_custom.scss` via Hugo Pipes — adding an import there is the correct hook point.
- **No `data/` directory:** The reading list is authored prose with personal commentary. Structured data files (YAML) would decouple the author's voice from the book entries, making edits harder. Frontmatter lists in the content file are the right trade-off.

## Architectural Patterns

### Pattern 1: Custom Layout Override Per Content Type

**What:** Create `layouts/[content-type]/single.html` to override the theme's default single layout for one content section only.
**When to use:** When one page needs structural HTML that differs from the rest of the site (e.g., no sidebar, custom header structure, star rating HTML).
**Trade-offs:** Clean separation; survives theme updates since it lives in `layouts/` not `themes/`; requires duplicating any theme partials you want to preserve (comment, breadcrumbs).

**Example — minimal custom layout:**
```html
{{- define "title" }}{{ .Title }} - {{ .Site.Title }}{{ end -}}

{{- define "content" -}}
<div class="page single special reading-list">
    <h1 class="single-title">{{- .Title -}}</h1>
    <div class="content reading-list-content" id="content">
        {{- .Content | safeHTML -}}
    </div>
</div>
{{- end -}}
```

The `reading-list` class on the wrapper scopes all custom CSS to this page without risk of colliding with other `.content` page styles.

### Pattern 2: SCSS in `_custom.scss` for Theme-Aware Styles

**What:** Add styles to `assets/css/_custom.scss` (or a file imported by it) using LoveIt's `[theme=dark]` attribute selector pattern.
**When to use:** Any styles that must respond to LoveIt's light/dark toggle. LoveIt sets `theme="dark"` on `<body>` via JavaScript — `[theme=dark]` selectors in SCSS pick this up.
**Trade-offs:** Styles are compiled at build time into the single site CSS bundle; no runtime cost. Requires knowing both light and dark values explicitly — no CSS custom property shortcut.

**Example — correct dark mode pattern:**
```scss
// assets/css/_custom.scss or _reading-list.scss

.reading-list-content {
    // Light mode (default)
    .book-rating {
        color: #2d96bd;              // $single-link-color value
    }
    .book-title {
        color: #161209;              // $header-title-color value
    }
    .reading-list-section {
        border-bottom: 2px solid #f0f0f0;  // $global-border-color value
    }

    // Dark mode — mirrors LoveIt's own pattern
    [theme=dark] & {
        .book-rating {
            color: #55bde2;          // $single-link-color-dark value
        }
        .book-title {
            color: #a9a9b3;          // $header-title-color-dark value
        }
        .reading-list-section {
            border-bottom-color: #363636;  // $global-border-color-dark value
        }
    }
}
```

### Pattern 3: Structured Book Data in Frontmatter

**What:** Store book metadata (title, author, URL, rating, status, tags) as YAML lists in the page's frontmatter. The custom layout template iterates over them with `range`.
**When to use:** When the page needs structured rendering (e.g., star ratings rendered as HTML) that pure Markdown cannot express cleanly, but the content is tightly coupled to a single page.
**Trade-offs:** Keeps data with the page; easy to edit in one file per language. Cannot be queried across pages. No separate data/ directory to manage.

**Example — frontmatter data model:**
```yaml
---
title: "Recommended Reading"
slug: recommended-reading
books:
  currently_reading:
    - title: "The Engineering Executive's Primer"
      author: "Will Larson"
      url: "https://amzn.eu/d/2ET5UiD"
      rating: 0          # 0 = not yet rated (currently reading)
      note: "Solid foundation for VP+ roles."
  engineering:
    - title: "Clean Code"
      author: "Robert C. Martin"
      url: "https://amzn.to/3f4tfO8"
      rating: 5
      tier: "Essential"
      note: "Changed everything about readability and maintenance."
    - title: "Domain-Driven Design"
      author: "Eric Evans"
      url: "https://amzn.to/32NQx63"
      rating: 5
      tier: "Essential"
      note: "Ubiquitous language and bounded contexts are how you survive complex domains."
  management:
    - title: "The Manager's Path"
      author: "Camille Fournier"
      url: "https://amzn.to/3f0FnzM"
      rating: 5
      tier: "Essential"
      note: "Roadmap from tech lead to CTO."
---
```

**Template iteration:**
```html
{{ range .Params.books.engineering }}
<div class="book-entry">
    <span class="book-rating">{{ partial "star-rating.html" .rating }}</span>
    <a href="{{ .url }}" class="book-title">{{ .title }}</a>
    <span class="book-author">{{ .author }}</span>
    <p class="book-note">{{ .note }}</p>
</div>
{{ end }}
```

## Data Flow

### Build-Time Rendering Flow

```
content/my-reading-list/index.en.md
    │ (frontmatter parsed as page params)
    ↓
layouts/my-reading-list/single.html
    │ ({{ range .Params.books.engineering }})
    ↓
Hugo renders HTML with book data injected
    │
    ↓ (baseof.html wraps everything)
themes/LoveIt/layouts/_default/baseof.html
    │
    ↓
public/my-reading-list/index.html  (static output)
```

### Theme Switching Flow (Runtime)

```
User clicks theme toggle
    ↓
LoveIt JS: document.body.setAttribute('theme', 'dark')
    ↓
CSS selector [theme=dark] .reading-list-content activates
    ↓
Dark color values apply (hardcoded in _custom.scss at build time)
```

### Multi-Language Flow

```
content/my-reading-list/index.en.md    → /my-reading-list/
content/my-reading-list/index.pt-br.md → /pt-br/my-reading-list/
    │
    ↓ (same template: layouts/my-reading-list/single.html)
    ↓
Each language file has its own frontmatter books data + translated notes
```

## Critical Architectural Finding: CSS Variables Bug

**The current inline `<style>` blocks in both `index.en.md` and `index.pt-br.md` are broken for dark mode.**

LoveIt's theming system uses SCSS `$variables` compiled to static hex values at build time — not CSS custom properties. The theme does NOT expose `var(--global-border-color)`, `var(--global-background-color)`, `var(--header-title-color)`, or `var(--single-link-color)` as CSS custom properties. The generated CSS confirms only layout/font metrics are exposed as `--` custom properties.

**Consequence:** The current inline CSS `var(--global-border-color)` calls resolve to `undefined` (browser default: empty/initial). The cards appear to render because the fallback values happen to be acceptable, but the page does not correctly adapt to dark mode today.

**Fix:** Replace all `var(--*)` references with `[theme=dark]` SCSS rules using hardcoded hex values (see Pattern 2 above), or define the missing custom properties yourself in `_custom.scss` using `:root` and `[theme=dark]` blocks.

**Option A — Define missing CSS vars (simpler for inline CSS compatibility):**
```scss
// assets/css/_custom.scss
:root {
    --reading-border-color: #f0f0f0;
    --reading-link-color: #2d96bd;
    --reading-title-color: #161209;
    --reading-bg-color: #fff;
}
[theme=dark] {
    --reading-border-color: #363636;
    --reading-link-color: #55bde2;
    --reading-title-color: #a9a9b3;
    --reading-bg-color: #292a2d;
}
```

Then reference `var(--reading-border-color)` etc. in the layout SCSS. This approach is maintainable and avoids duplicating color blocks.

**Option B — Pure SCSS with `[theme=dark]` selectors (more consistent with LoveIt internals, no custom CSS vars needed).**

**Recommendation: Option A.** Defining scoped CSS custom properties in `_custom.scss` is cleaner, allows the template's SCSS to stay concise, and aligns with modern CSS practice. It also works if any inline markdown snippets need to reference theme colors.

## Anti-Patterns

### Anti-Pattern 1: Inline `<style>` Blocks in Markdown

**What people do:** Paste `<style>...</style>` at the top of a Markdown content file.
**Why it's wrong:** CSS is duplicated across every language variant (`index.en.md`, `index.pt-br.md`). Changes require editing multiple files. CSS cannot use SCSS features (nesting, variables, `[theme=dark]` patterns). The styles bypass Hugo's asset pipeline — no fingerprinting, no minification.
**Do this instead:** Move all styles to `assets/css/_reading-list.scss`, import it from `_custom.scss`. One file, one source of truth, full SCSS capabilities, built into the fingerprinted CSS bundle.

### Anti-Pattern 2: Using a Hugo `data/` File for Reading List Books

**What people do:** Create `data/books.yaml` and reference it via `$.Site.Data.books` in templates.
**Why it's wrong:** The reading list is personal commentary — each entry has an author's note that is part of the editorial voice. Splitting this into a data file creates two places to edit for every book change. Data files are best for truly structured, reusable data queried by multiple pages.
**Do this instead:** Store book metadata in the page's own frontmatter. The data stays with its page, both language files are self-contained, and the custom layout iterates over `.Params.books`.

### Anti-Pattern 3: Star Ratings as Unicode Text in Markdown

**What people do:** Write `★★★★☆` as literal Unicode in the Markdown list items.
**Why it's wrong:** Unicode star characters are not accessible (screen readers read "black star, black star..."), cannot be styled independently light/dark, and are hard to search/maintain.
**Do this instead:** Render star ratings from the numeric `rating` field in frontmatter using a Hugo partial or shortcode that outputs semantic HTML with `aria-label`.

**Example partial (`layouts/partials/star-rating.html`):**
```html
{{- $rating := . -}}
<span class="star-rating" aria-label="{{ $rating }} out of 5 stars">
    {{- range seq 5 -}}
        <span class="star {{ if le . $rating }}star--filled{{ else }}star--empty{{ end }}" aria-hidden="true">★</span>
    {{- end -}}
</span>
```

### Anti-Pattern 4: Forking the LoveIt Theme Files

**What people do:** Edit files inside `themes/LoveIt/` directly.
**Why it's wrong:** The theme is a git submodule. Any direct edits are wiped on `git submodule update`. The project already demonstrates the correct pattern: override in `layouts/`, extend in `assets/css/`.
**Do this instead:** All customizations in `layouts/` (templates) and `assets/css/` (styles). Never touch `themes/LoveIt/`.

## Integration Points

### LoveIt Theme Integration

| Integration Point | Mechanism | Notes |
|-------------------|-----------|-------|
| Layout override | `layouts/my-reading-list/single.html` | Hugo resolves project layouts before theme layouts |
| CSS extension | `assets/css/_custom.scss` `@import` | LoveIt includes `_custom.scss` via Hugo Pipes |
| Dark mode | `[theme=dark]` attribute selector in SCSS | LoveIt JS sets `body[theme=dark]` on toggle |
| Multi-language | File naming convention (`index.en.md`, `index.pt-br.md`) | No code change needed; Hugo routes by language code |
| TOC | `[params.page.toc] enable = true` in config | Already enabled globally; custom layout can include/exclude the TOC partial |

### Build Order Implications

1. No build order concerns — this is a static site. All assets compile in a single `hugo` invocation.
2. SCSS changes in `assets/css/` take effect immediately on `hugo server --disableFastRender` rebuild.
3. Frontmatter data changes in `index.en.md` are picked up on any content rebuild.
4. The custom layout at `layouts/my-reading-list/single.html` is consulted by Hugo before `themes/LoveIt/layouts/_default/single.html` — this lookup order is guaranteed by Hugo's overlay filesystem.

## Recommended Implementation Order

1. Create `layouts/my-reading-list/single.html` (custom template scaffold)
2. Define CSS custom properties for reading list colors in `assets/css/_custom.scss`
3. Create `assets/css/_reading-list.scss` with typography-driven styles; import it
4. Migrate book data from Markdown lists to frontmatter YAML in both language files
5. Implement `layouts/partials/star-rating.html`
6. Wire up the template to render frontmatter data with star ratings
7. Verify dark mode with `[theme=dark]` toggle in browser
8. Update pt-br frontmatter with translated notes

## Sources

- Direct inspection: `themes/LoveIt/assets/css/_variables.scss` — SCSS variable values for light/dark
- Direct inspection: `themes/LoveIt/assets/css/_core/_variables.scss` — which vars are actually exposed as CSS custom properties (layout/font only; no color vars)
- Direct inspection: `themes/LoveIt/resources/_gen/assets/css/style.scss_*.content` — compiled CSS confirms no `--global-background-color` etc. in `:root`
- Direct inspection: `layouts/talks/single.html` — existing override pattern in the project
- Hugo documentation pattern: layout lookup order (project `layouts/` takes priority over `themes/`)

---
*Architecture research for: Hugo/LoveIt reading list page redesign*
*Researched: 2026-04-03*
