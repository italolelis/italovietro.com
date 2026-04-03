# Architecture

**Analysis Date:** 2026-04-03

## Pattern Overview

**Overall:** Static Site Generator (SSG) Pattern with Theme Customization

**Key Characteristics:**
- Hugo-based static site generation (v0.153.2 for deployment, v0.139.4 for PR checks)
- Markdown-driven content with TOML frontmatter
- Multi-language support (English and Portuguese)
- Theme-based layout inheritance with custom overrides
- Automated CI/CD deployment to GitHub Pages
- PostCSS/SCSS asset pipeline for styling

## Layers

**Content Layer:**
- Purpose: Markdown files containing blog posts, talks, and reading lists
- Location: `content/`
- Contains: Markdown files with YAML/TOML frontmatter defining metadata
- Depends on: Front matter specifications (title, date, tags, categories)
- Used by: Rendering layer to generate pages

**Rendering/Template Layer:**
- Purpose: Hugo templates that define page layouts and structure
- Location: `layouts/`, `themes/LoveIt/`
- Contains: HTML templates using Go's text/template syntax
- Depends on: Content metadata, theme configuration, Hugo built-ins
- Used by: Hugo build process to render HTML

**Theme Layer:**
- Purpose: Base design and component library (LoveIt theme as submodule)
- Location: `themes/LoveIt/`
- Contains: Default layouts, styles, JavaScript, and theme configuration
- Depends on: Hugo configuration
- Used by: Custom layouts for inheritance and component reuse

**Asset Layer:**
- Purpose: Custom stylesheets and images
- Location: `assets/css/`, `assets/images/`, `static/`
- Contains: SCSS overrides (`_custom.scss`, `_override.scss`), static images, favicons
- Depends on: Theme asset pipeline, Hugo resource processing
- Used by: Template rendering and page styling

**Build/Deployment Layer:**
- Purpose: CI/CD automation and static file generation
- Location: `.github/workflows/`
- Contains: GitHub Actions workflows for building and deploying
- Depends on: Hugo CLI, Node.js (for PostCSS), git submodules
- Used by: GitHub Pages hosting

**Configuration Layer:**
- Purpose: Site-wide settings and behavior
- Location: `config.toml`, `.devcontainer/devcontainer.json`
- Contains: Hugo parameters, menu definitions, language settings
- Depends on: Theme parameter specifications
- Used by: Hugo rendering engine, all templates

## Data Flow

**Build-Time Flow:**

1. Git checkout with submodule recursion retrieves theme and all content
2. Hugo discovers content in `content/` directory
3. For each markdown file, Hugo:
   - Parses frontmatter (YAML/TOML)
   - Processes markdown to HTML
   - Looks up matching layout template (applies inheritance chain)
4. Template rendering uses:
   - Site configuration from `config.toml`
   - Page-specific data from frontmatter
   - Partial templates from `layouts/partials/`
   - Theme templates from `themes/LoveIt/`
5. Asset processing:
   - PostCSS processes Node.js dependencies
   - SCSS compiled via theme pipeline
   - Resources cached and fingerprinted (SHA256)
6. Output static HTML files written to `public/` directory
7. GitHub Pages deployment occurs on master branch push

**Multi-Language Support:**

- Language variants determined by file naming: `index.en.md`, `index.pt-br.md`
- Config defines language weights and parameters per language
- Menu navigation differs per language (e.g., "My reading list" vs "Minha lista de livros")
- Same content structure replicated across language variants

**State Management:**
- Hugo Scratch API used in templates to store computed values and configuration
- `init.html` partial initializes scratch variables for CDN, analytics, fingerprinting
- Page-level params merged with site-level params for cascading overrides

## Key Abstractions

**Content Entity:**
- Purpose: Represents a publishable item (post, talk, reading list)
- Examples: `content/posts/building-my-homelab/index.en.md`, `content/talks/index.pt-br.md`
- Pattern: Front matter metadata (title, date, tags, categories, draft status) + markdown body
- Properties: title, date, lastmod, draft, author, description, tags, categories, featured image

**Page Templates:**
- Purpose: Layout definitions for different content types
- Examples:
  - `layouts/talks/single.html` - talk detail page with featured image
  - `layouts/taxonomy/term.html` - tag/category list with pagination
  - `layouts/_default/` - default layout inherited by theme
- Pattern: Go template with partial composition, conditional rendering, front matter access

**Partial Templates:**
- Purpose: Reusable template components
- Examples: `layouts/partials/header.html` (nav and search), `layouts/partials/plugin/img.html` (image rendering)
- Pattern: Modular chunks called via `{{ partial "name.html" . }}`
- Responsibility: Render self-contained UI sections with responsive desktop/mobile variants

**Configuration Sections:**
- Purpose: Hierarchical settings organized by concern
- Examples:
  - `[languages]` - per-language settings and menu definitions
  - `[params]` - global site parameters
  - `[params.analytics]` - Google Analytics configuration
  - `[params.page]` - page-level feature toggles (TOC, code copy, math, sharing)
  - `[markup]` - markdown processing settings (syntax highlighting, taskLists)

## Entry Points

**Homepage:**
- Location: `content/_index.pt-br.md`, `content/_index.en.md`
- Triggers: HTTP request to `/` (language-specific variant served)
- Responsibilities: Display hero profile, recent posts (disabled via config), social links

**Blog Posts Section:**
- Location: `content/posts/[slug]/index.[lang].md`
- Triggers: HTTP request to `/[slug]` or browse `/posts` (section page)
- Responsibilities: Display single post with metadata, syntax highlighting, sharing options, ToC

**Talks Page:**
- Location: `content/talks/index.[lang].md`, template `layouts/talks/single.html`
- Triggers: HTTP request to `/talks/`
- Responsibilities: Custom talk-specific layout with featured image support

**Taxonomies (Tags/Categories):**
- Location: Auto-generated based on frontmatter tags/categories in posts
- Triggers: HTTP request to `/tags/[tag]` or `/categories/[cat]`
- Responsibilities: List posts tagged with term, display term-level metadata via `layouts/taxonomy/term.html`

**Static Files:**
- Location: `static/` directory (favicon, manifest, redirects)
- Triggers: Direct HTTP requests to static paths
- Responsibilities: Serve static assets, redirect rules, web manifest

## Error Handling

**Strategy:** Build-time validation with warnings

**Patterns:**
- Hugo emits warnings for missing includes, broken internal links (when `enableMissingTranslationChecks` enabled)
- Build log captured in CI/CD workflow (`.github/workflows/pr-checks.yml`)
- Draft posts excluded from production builds via Hugo `-D` flag control
- Markdown parsing errors prevent build completion
- CSS/JS build failures (PostCSS) surface in GitHub Actions workflow logs

## Cross-Cutting Concerns

**Logging:** None (static site, no runtime logging). Build output captured in GitHub Actions logs.

**Validation:** Front matter validation via schema enforced by content organization; missing required fields cause template errors.

**Localization:**
- Language-specific content files (`index.en.md`, `index.pt-br.md`)
- Menu translations in `config.toml` under `[languages.[lang].menu.main]`
- Template translation strings via `{{ T "key" }}` function (LoveIt theme)
- Google Analytics ID: `G-KYX115R541`

**Analytics:**
- Google Analytics integration via theme partial
- Environment-aware: disabled in development (`hugo.Environment != "production"`)
- Privacy settings: DNT enabled, YouTube enhanced privacy

**SEO:**
- Open Graph image: `/images/logo.svg`
- Sitemap generation enabled (`enableRobotsTXT = true`)
- Markdown output format supported (`[outputFormats.MarkDown]`)
- Favicon/Apple Touch Icon configuration via params
- Social sharing buttons configurable per post

**Performance:**
- Hugo minification and garbage collection flags in production builds
- Resource fingerprinting (SHA256) for cache-busting
- CDN data loading from `data/cdn/jsdelivr.yml` (not committed, downloaded at build)
- Resources cached in GitHub Actions between builds

---

*Architecture analysis: 2026-04-03*
