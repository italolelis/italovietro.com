# Coding Conventions

**Analysis Date:** 2026-04-03

## Project Type

This is a **Hugo static site generator project** with minimal custom code. The primary source files are:
- **Markdown** - Content (blog posts, pages)
- **Hugo Templates** (Go templating) - Layout files
- **SCSS** - Styling
- **TOML** - Configuration

There is no TypeScript, JavaScript, or traditional application code.

## Naming Patterns

### Files

**Markdown Content:**
- Blog posts use page bundles: `content/posts/[slug-name]/index.en.md` and `index.pt-br.md`
- Language-specific suffixes: `.en.md` (English), `.pt-br.md` (Portuguese)
- Pattern: kebab-case for directory names (e.g., `building-my-homelab`, `do-job-titles-matter`)

**Hugo Templates:**
- Location: `layouts/` directory
- Naming: `[type]/[context].html` (e.g., `talks/single.html`, `partials/header.html`)
- Custom overrides mirror theme structure
- Pattern: file names are descriptive and lowercase with hyphens

**SCSS Files:**
- Location: `assets/css/`
- Naming: prefix with underscore for partials (e.g., `_custom.scss`, `_override.scss`)
- Pattern: kebab-case with underscore prefix

### Directory Structure

**Content directories (kebab-case):**
```
content/
├── posts/           # Blog post bundles
├── consulting/      # Consulting page
├── talks/           # Talks/speaking engagements
└── my-reading-list/ # Reading recommendations
```

**Layout directories (follow Hugo conventions):**
```
layouts/
├── talks/           # Custom layouts for talk type
├── _default/        # Default layouts
├── partials/        # Reusable template components
└── taxonomy/        # Category/tag layouts
```

**Asset directories (lowercase):**
```
assets/
├── css/             # SCSS stylesheets
├── images/          # PNG, JPG, SVG images
└── music/           # Audio files
```

## Code Style

### Hugo Templates

**Whitespace Control:**
- Use `{{- ` and ` -}}` to control whitespace in templates
- Example: `{{- define "title" }}...{{ end -}}`
- This produces clean HTML without extra line breaks

**Formatting:**
- Consistent indentation (4 spaces typical in template files)
- Comments use Hugo syntax: `{{- /* Comment */ -}}`
- Multiline conditional blocks properly indented

**Variable Handling:**
- Use `.` for current context
- Use `$variable` for assigned variables
- Use `.Site` for global site configuration
- Use `.Params` for frontmatter parameters

**Example from `layouts/partials/header.html`:**
```html
{{- with .Site.Params.header.title -}}
    {{- with .logo -}}
        {{- dict "Src" . "Class" "logo" | partial "plugin/img.html" -}}
    {{- end -}}
{{- end -}}
```

**Safe HTML Rendering:**
- Use `| safeHTML` when outputting user content that contains HTML
- Pattern: `{{ . | safeHTML }}`
- Location: `layouts/partials/header.html` line 11, 21, etc.

### SCSS/CSS

**Formatting:**
- Standard SCSS conventions with proper indentation
- Comments use `// ` for single-line comments
- CSS variables for theming

**Theme Support:**
- Dark theme selector: `[theme=dark] .class-name`
- Light theme selector: `[theme=light] .class-name`
- Auto theme with media query: `@media (prefers-color-scheme: dark)`
- Pattern observed in `assets/css/_custom.scss` for logo styling

**Example from `assets/css/_custom.scss`:**
```scss
/* Default - dark logo on light background */
.header-title .logo {
    filter: none;
}

/* White logo for dark theme */
[theme=dark] .header-title .logo {
    filter: invert(1) brightness(1.2);
}

@media (max-width: 768px) {
    .header-title .logo {
        height: 2em;
    }
}
```

## Content Front Matter Conventions

**Required Frontmatter Fields:**
```toml
title = "Post Title"
date = 2025-12-26T21:30:00.000Z
lastmod = 2025-12-26T21:30:00.000Z
draft = true  # or false for published
author = "Italo Vietro"
authorLink = "https://italovietro.com"
description = "Brief summary for SEO and listings"
```

**Optional Fields:**
```toml
resources:
  - name: "featured-image"
    src: "image-path"

tags:
  - tag1
  - tag2

categories: ["Category"]

lightgallery = true  # Enable image gallery
```

**Bilingual Pattern:**
- Every post must have both `index.en.md` and `index.pt-br.md`
- Both files contain identical frontmatter
- Content is translated between versions

## Configuration Conventions

**config.toml Structure:**
- TOML format with nested section grouping
- Language configurations under `[languages.en]` and `[languages.pt-br]`
- Parameters under `[params]` and nested subsections
- All important settings documented inline

**Key Configuration Patterns:**
- Environment variables: Google Analytics ID configured (G-KYX115R541)
- Theme settings: darkMode auto-detection enabled
- Content rendering: Goldmark parser with extensions (tables, footnotes, strikethrough)
- Menu configuration: Language-specific menus defined per language

## Comments and Documentation

**When to Comment:**
- Template logic that isn't immediately obvious (visible in headers/footers)
- Override reasons in custom layouts
- Complex conditional rendering

**Comment Style in Templates:**
```html
{{- /* Desktop header */ -}}
{{- /* Mobile header */ -}}
{{- /* Title */ -}}
{{- /* Featured image */ -}}
```

**Comment Style in SCSS:**
```scss
// ==============================
// Custom style
// 自定义样式
// ==============================
/* Section comments for major blocks */
/* Default - dark logo on light background */
```

## Module/Partial Organization

**Hugo Partials Pattern:**
- Reusable components in `layouts/partials/`
- Subdirectories by category: `plugin/`, `function/`
- Invoked with: `{{ partial "path/to/partial.html" . }}`
- Can pass context and data through `dict`

**Example from header.html:**
```html
{{- dict "Src" . "Class" "logo" | partial "plugin/img.html" -}}
{{- dict $id (slice $id) | dict "typeitMap" | merge ($.Scratch.Get "this") | $.Scratch.Set "this" -}}
```

## Hugo-Specific Patterns

**Context Preservation:**
- Use `$.` to preserve top-level context in nested ranges
- Pattern: `{{ range .Items }}{{ $.Site.Title }}{{ end }}`

**Conditional Checks:**
- `{{- if condition }}...{{ end -}}`
- `{{- with .Value }}...{{ end -}}` (checks existence and sets context)
- `{{- if eq value "string" }}...{{ end -}}`

**Data Processing:**
- Use pipes to chain Hugo functions: `| relLangURL | safeHTML`
- Example: `{{ .URL | relLangURL }}`

**Scratch for State:**
- Hugo Scratch used for managing state across template execution
- Pattern: `$.Scratch.Set "key" value` and `$.Scratch.Get "key"`

## Linting and Formatting

**Not Detected:**
- No ESLint, Prettier, or formal linting configuration
- No pre-commit hooks for code formatting
- No automated style checking tools

**Manual Standards:**
- Developers expected to follow conventions by observation
- Theme defaults provide consistent styling baseline
- SCSS follows standard SCSS conventions

## Build Configuration

**Hugo Build:**
- Version: 0.139.4+ (specified in CI workflow)
- Extended build required (for SCSS compilation)
- Build flags in CI: `hugo --gc --minify`
- Environment variables: `HUGO_ENVIRONMENT=production`, `HUGO_ENV=production`

**Development:**
- Local: `hugo server -D` (includes drafts)
- Watch mode automatic with dev server
- No separate build/watch configuration needed

---

*Convention analysis: 2026-04-03*
