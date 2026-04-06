<!-- GSD:project-start source:PROJECT.md -->
## Project

**italovietro.com — Reading List Redesign**

A personal website and blog built with Hugo (LoveIt theme), serving as Italo Vietro's professional presence. The site features blog posts, talks, and a reading list page. This project focuses on redesigning the reading list into a snappier, more appealing page that Italo can confidently share with colleagues and teammates.

**Core Value:** A clean, scannable reading list page with star ratings that makes it immediately obvious which books matter most and what Italo is currently reading.

### Constraints

- **Tech stack**: Hugo + LoveIt theme, no JavaScript frameworks
- **Theme**: Must work with existing LoveIt theme CSS variables (light/dark mode)
- **Content format**: Markdown with Hugo frontmatter
- **Deployment**: GitHub Pages via GitHub Actions
- **Multi-language**: Changes need to work for both en and pt-br versions
<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->
## Technology Stack

## Languages
- Go 1.18+ - Hugo static site generator core and theme dependencies
- HTML/Templating - Hugo's Go templating language (`.html` template files)
- SCSS/CSS - Styling with custom CSS and theme defaults
- JavaScript/Node.js - Theme build tooling and frontend interactivity
- TOML - Configuration files (`config.toml`)
## Runtime
- Hugo 0.153.2 (extended version required) - Primary build tool for site generation
- Node.js 20 - Used in CI/CD for PostCSS and build tooling
- Go runtime - Available in DevContainer for Hugo extended features
- npm - JavaScript dependency management for theme build tooling
- Lockfile: `package-lock.json` (in theme directory: `themes/LoveIt/package-lock.json`)
## Frameworks
- Hugo 0.153.2 (extended) - Static site generator with Goldmark markdown processor
- LoveIt Theme 0.2.X - Hugo theme for site layout and styling
- TypeIt - Text animation library for dynamic title/subtitle effects
- Font Awesome 5+ - Icon library (FontAwesome extended syntax in markdown)
- Mapbox GL JS - Interactive map rendering (when enabled)
- Google Fonts - Roboto and Open Sans font loading
- Babel 7.26.9 - JavaScript transpiler for theme scripts
- Browserify 17.0.1 - Module bundler for browser-compatible JavaScript
- PostCSS - CSS processing (used in CI/CD pipeline)
- Husky 9.1.7 - Git hooks management for theme development
- Not configured in main site (theme has htmlproofer for link validation)
## Key Dependencies
- Hugo Extended (0.153.2 in production, 0.139.4 in PR checks) - Required for theme SCSS processing
- Node.js 20 - PostCSS required for CSS pipeline during build
- @babel/cli 7.26.4 - JS transpilation
- @babel/core 7.26.9 - Babel core library
- @babel/preset-env 7.26.9 - Modern JavaScript transpilation
- core-js 3.40.0 - Polyfills for legacy browser compatibility
- babelify 10.0.0 - Browserify transform for Babel
- segmentit 2.0.3 - Chinese text segmentation for search
- husky 9.1.7 - Pre-commit hooks
- LoveIt theme (via Git submodule) - Complete theme framework
## Configuration
- Base configuration: `config.toml` - Main Hugo site configuration
- Theme configuration: Merged from theme defaults and `config.toml` overrides
- Environment variables for PostCSS used in GitHub Actions
- `config.toml` - Primary Hugo configuration file (436 lines)
- Theme configuration in `themes/LoveIt/theme.toml`
- Hugo uses Goldmark markdown processor with extensions:
- Git info enabled - Uses git history for last modified dates
- Robot TXT generation - SEO support
- Emoji support - Emoji rendering in markdown
- Google Analytics 4 - ID `G-KYX115R541`
- Cookie consent enabled
- Multiple language support (English, Portuguese-BR)
- Syntax highlighting with line numbers
- Table of contents auto-generation
- Image optimization with SRI hashing (SHA256)
## Platform Requirements
- Hugo 0.139.4+ (extended version)
- Node.js 20
- Go 1.20+ (for DevContainer)
- git (for submodule support)
- Docker (optional, for DevContainer setup)
- Deployment target: GitHub Pages
- Triggered on push to `master` branch
- Static HTML output only (no server-side runtime required)
## Deployment Pipeline
- GitHub Actions workflows in `.github/workflows/`
- `pages.yml` - Production deployment workflow
- `pr-checks.yml` - Pull request validation (uses Hugo 0.139.4)
- Dependabot enabled for dependency monitoring
## Development Tools
- golang.Go - Go language support
- bungcip.better-toml - TOML syntax highlighting
- davidanson.vscode-markdownlint - Markdown linting
- DevContainer configuration at `.devcontainer/Dockerfile`
- Base: Go 1.20-bullseye with Hugo extended
- Port forwarding: 1313 (Hugo server default)
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

## Project Type
- **Markdown** - Content (blog posts, pages)
- **Hugo Templates** (Go templating) - Layout files
- **SCSS** - Styling
- **TOML** - Configuration
## Naming Patterns
### Files
- Blog posts use page bundles: `content/posts/[slug-name]/index.en.md` and `index.pt-br.md`
- Language-specific suffixes: `.en.md` (English), `.pt-br.md` (Portuguese)
- Pattern: kebab-case for directory names (e.g., `building-my-homelab`, `do-job-titles-matter`)
- Location: `layouts/` directory
- Naming: `[type]/[context].html` (e.g., `talks/single.html`, `partials/header.html`)
- Custom overrides mirror theme structure
- Pattern: file names are descriptive and lowercase with hyphens
- Location: `assets/css/`
- Naming: prefix with underscore for partials (e.g., `_custom.scss`, `_override.scss`)
- Pattern: kebab-case with underscore prefix
### Directory Structure
## Code Style
### Hugo Templates
- Use `{{- ` and ` -}}` to control whitespace in templates
- Example: `{{- define "title" }}...{{ end -}}`
- This produces clean HTML without extra line breaks
- Consistent indentation (4 spaces typical in template files)
- Comments use Hugo syntax: `{{- /* Comment */ -}}`
- Multiline conditional blocks properly indented
- Use `.` for current context
- Use `$variable` for assigned variables
- Use `.Site` for global site configuration
- Use `.Params` for frontmatter parameters
- Use `| safeHTML` when outputting user content that contains HTML
- Pattern: `{{ . | safeHTML }}`
- Location: `layouts/partials/header.html` line 11, 21, etc.
### SCSS/CSS
- Standard SCSS conventions with proper indentation
- Comments use `// ` for single-line comments
- CSS variables for theming
- Dark theme selector: `[theme=dark] .class-name`
- Light theme selector: `[theme=light] .class-name`
- Auto theme with media query: `@media (prefers-color-scheme: dark)`
- Pattern observed in `assets/css/_custom.scss` for logo styling
## Content Front Matter Conventions
- Every post must have both `index.en.md` and `index.pt-br.md`
- Both files contain identical frontmatter
- Content is translated between versions
## Configuration Conventions
- TOML format with nested section grouping
- Language configurations under `[languages.en]` and `[languages.pt-br]`
- Parameters under `[params]` and nested subsections
- All important settings documented inline
- Environment variables: Google Analytics ID configured (G-KYX115R541)
- Theme settings: darkMode auto-detection enabled
- Content rendering: Goldmark parser with extensions (tables, footnotes, strikethrough)
- Menu configuration: Language-specific menus defined per language
## Comments and Documentation
- Template logic that isn't immediately obvious (visible in headers/footers)
- Override reasons in custom layouts
- Complex conditional rendering
## Module/Partial Organization
- Reusable components in `layouts/partials/`
- Subdirectories by category: `plugin/`, `function/`
- Invoked with: `{{ partial "path/to/partial.html" . }}`
- Can pass context and data through `dict`
## Hugo-Specific Patterns
- Use `$.` to preserve top-level context in nested ranges
- Pattern: `{{ range .Items }}{{ $.Site.Title }}{{ end }}`
- `{{- if condition }}...{{ end -}}`
- `{{- with .Value }}...{{ end -}}` (checks existence and sets context)
- `{{- if eq value "string" }}...{{ end -}}`
- Use pipes to chain Hugo functions: `| relLangURL | safeHTML`
- Example: `{{ .URL | relLangURL }}`
- Hugo Scratch used for managing state across template execution
- Pattern: `$.Scratch.Set "key" value` and `$.Scratch.Get "key"`
## Linting and Formatting
- No ESLint, Prettier, or formal linting configuration
- No pre-commit hooks for code formatting
- No automated style checking tools
- Developers expected to follow conventions by observation
- Theme defaults provide consistent styling baseline
- SCSS follows standard SCSS conventions
## Build Configuration
- Version: 0.139.4+ (specified in CI workflow)
- Extended build required (for SCSS compilation)
- Build flags in CI: `hugo --gc --minify`
- Environment variables: `HUGO_ENVIRONMENT=production`, `HUGO_ENV=production`
- Local: `hugo server -D` (includes drafts)
- Watch mode automatic with dev server
- No separate build/watch configuration needed
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

## Pattern Overview
- Hugo-based static site generation (v0.153.2 for deployment, v0.139.4 for PR checks)
- Markdown-driven content with TOML frontmatter
- Multi-language support (English and Portuguese)
- Theme-based layout inheritance with custom overrides
- Automated CI/CD deployment to GitHub Pages
- PostCSS/SCSS asset pipeline for styling
## Layers
- Purpose: Markdown files containing blog posts, talks, and reading lists
- Location: `content/`
- Contains: Markdown files with YAML/TOML frontmatter defining metadata
- Depends on: Front matter specifications (title, date, tags, categories)
- Used by: Rendering layer to generate pages
- Purpose: Hugo templates that define page layouts and structure
- Location: `layouts/`, `themes/LoveIt/`
- Contains: HTML templates using Go's text/template syntax
- Depends on: Content metadata, theme configuration, Hugo built-ins
- Used by: Hugo build process to render HTML
- Purpose: Base design and component library (LoveIt theme as submodule)
- Location: `themes/LoveIt/`
- Contains: Default layouts, styles, JavaScript, and theme configuration
- Depends on: Hugo configuration
- Used by: Custom layouts for inheritance and component reuse
- Purpose: Custom stylesheets and images
- Location: `assets/css/`, `assets/images/`, `static/`
- Contains: SCSS overrides (`_custom.scss`, `_override.scss`), static images, favicons
- Depends on: Theme asset pipeline, Hugo resource processing
- Used by: Template rendering and page styling
- Purpose: CI/CD automation and static file generation
- Location: `.github/workflows/`
- Contains: GitHub Actions workflows for building and deploying
- Depends on: Hugo CLI, Node.js (for PostCSS), git submodules
- Used by: GitHub Pages hosting
- Purpose: Site-wide settings and behavior
- Location: `config.toml`, `.devcontainer/devcontainer.json`
- Contains: Hugo parameters, menu definitions, language settings
- Depends on: Theme parameter specifications
- Used by: Hugo rendering engine, all templates
## Data Flow
- Language variants determined by file naming: `index.en.md`, `index.pt-br.md`
- Config defines language weights and parameters per language
- Menu navigation differs per language (e.g., "My reading list" vs "Minha lista de livros")
- Same content structure replicated across language variants
- Hugo Scratch API used in templates to store computed values and configuration
- `init.html` partial initializes scratch variables for CDN, analytics, fingerprinting
- Page-level params merged with site-level params for cascading overrides
## Key Abstractions
- Purpose: Represents a publishable item (post, talk, reading list)
- Examples: `content/posts/building-my-homelab/index.en.md`, `content/talks/index.pt-br.md`
- Pattern: Front matter metadata (title, date, tags, categories, draft status) + markdown body
- Properties: title, date, lastmod, draft, author, description, tags, categories, featured image
- Purpose: Layout definitions for different content types
- Examples:
- Pattern: Go template with partial composition, conditional rendering, front matter access
- Purpose: Reusable template components
- Examples: `layouts/partials/header.html` (nav and search), `layouts/partials/plugin/img.html` (image rendering)
- Pattern: Modular chunks called via `{{ partial "name.html" . }}`
- Responsibility: Render self-contained UI sections with responsive desktop/mobile variants
- Purpose: Hierarchical settings organized by concern
- Examples:
## Entry Points
- Location: `content/_index.pt-br.md`, `content/_index.en.md`
- Triggers: HTTP request to `/` (language-specific variant served)
- Responsibilities: Display hero profile, recent posts (disabled via config), social links
- Location: `content/posts/[slug]/index.[lang].md`
- Triggers: HTTP request to `/[slug]` or browse `/posts` (section page)
- Responsibilities: Display single post with metadata, syntax highlighting, sharing options, ToC
- Location: `content/talks/index.[lang].md`, template `layouts/talks/single.html`
- Triggers: HTTP request to `/talks/`
- Responsibilities: Custom talk-specific layout with featured image support
- Location: Auto-generated based on frontmatter tags/categories in posts
- Triggers: HTTP request to `/tags/[tag]` or `/categories/[cat]`
- Responsibilities: List posts tagged with term, display term-level metadata via `layouts/taxonomy/term.html`
- Location: `static/` directory (favicon, manifest, redirects)
- Triggers: Direct HTTP requests to static paths
- Responsibilities: Serve static assets, redirect rules, web manifest
## Error Handling
- Hugo emits warnings for missing includes, broken internal links (when `enableMissingTranslationChecks` enabled)
- Build log captured in CI/CD workflow (`.github/workflows/pr-checks.yml`)
- Draft posts excluded from production builds via Hugo `-D` flag control
- Markdown parsing errors prevent build completion
- CSS/JS build failures (PostCSS) surface in GitHub Actions workflow logs
## Cross-Cutting Concerns
- Language-specific content files (`index.en.md`, `index.pt-br.md`)
- Menu translations in `config.toml` under `[languages.[lang].menu.main]`
- Template translation strings via `{{ T "key" }}` function (LoveIt theme)
- Google Analytics ID: `G-KYX115R541`
- Google Analytics integration via theme partial
- Environment-aware: disabled in development (`hugo.Environment != "production"`)
- Privacy settings: DNT enabled, YouTube enhanced privacy
- Open Graph image: `/images/logo.svg`
- Sitemap generation enabled (`enableRobotsTXT = true`)
- Markdown output format supported (`[outputFormats.MarkDown]`)
- Favicon/Apple Touch Icon configuration via params
- Social sharing buttons configurable per post
- Hugo minification and garbage collection flags in production builds
- Resource fingerprinting (SHA256) for cache-busting
- CDN data loading from `data/cdn/jsdelivr.yml` (not committed, downloaded at build)
- Resources cached in GitHub Actions between builds
<!-- GSD:architecture-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd:quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd:debug` for investigation and bug fixing
- `/gsd:execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd:profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
