# Technology Stack

**Analysis Date:** 2026-04-03

## Languages

**Primary:**
- Go 1.18+ - Hugo static site generator core and theme dependencies
- HTML/Templating - Hugo's Go templating language (`.html` template files)
- SCSS/CSS - Styling with custom CSS and theme defaults
- JavaScript/Node.js - Theme build tooling and frontend interactivity

**Secondary:**
- TOML - Configuration files (`config.toml`)

## Runtime

**Environment:**
- Hugo 0.153.2 (extended version required) - Primary build tool for site generation
- Node.js 20 - Used in CI/CD for PostCSS and build tooling
- Go runtime - Available in DevContainer for Hugo extended features

**Package Manager:**
- npm - JavaScript dependency management for theme build tooling
- Lockfile: `package-lock.json` (in theme directory: `themes/LoveIt/package-lock.json`)

## Frameworks

**Core:**
- Hugo 0.153.2 (extended) - Static site generator with Goldmark markdown processor
- LoveIt Theme 0.2.X - Hugo theme for site layout and styling

**Frontend:**
- TypeIt - Text animation library for dynamic title/subtitle effects
- Font Awesome 5+ - Icon library (FontAwesome extended syntax in markdown)
- Mapbox GL JS - Interactive map rendering (when enabled)
- Google Fonts - Roboto and Open Sans font loading

**Build/Dev:**
- Babel 7.26.9 - JavaScript transpiler for theme scripts
- Browserify 17.0.1 - Module bundler for browser-compatible JavaScript
- PostCSS - CSS processing (used in CI/CD pipeline)
- Husky 9.1.7 - Git hooks management for theme development

**Testing:**
- Not configured in main site (theme has htmlproofer for link validation)

## Key Dependencies

**Critical:**
- Hugo Extended (0.153.2 in production, 0.139.4 in PR checks) - Required for theme SCSS processing
- Node.js 20 - PostCSS required for CSS pipeline during build

**Theme Build Dependencies:**
- @babel/cli 7.26.4 - JS transpilation
- @babel/core 7.26.9 - Babel core library
- @babel/preset-env 7.26.9 - Modern JavaScript transpilation
- core-js 3.40.0 - Polyfills for legacy browser compatibility
- babelify 10.0.0 - Browserify transform for Babel
- segmentit 2.0.3 - Chinese text segmentation for search
- husky 9.1.7 - Pre-commit hooks

**Theme Libraries:**
- LoveIt theme (via Git submodule) - Complete theme framework

## Configuration

**Environment:**
- Base configuration: `config.toml` - Main Hugo site configuration
- Theme configuration: Merged from theme defaults and `config.toml` overrides
- Environment variables for PostCSS used in GitHub Actions

**Build:**
- `config.toml` - Primary Hugo configuration file (436 lines)
- Theme configuration in `themes/LoveIt/theme.toml`
- Hugo uses Goldmark markdown processor with extensions:
  - Definition lists
  - Footnotes
  - Linkify
  - Strikethrough
  - Tables
  - Task lists
  - Typographer
  - Unsafe HTML rendering

**Features Configured:**
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

**Development:**
- Hugo 0.139.4+ (extended version)
- Node.js 20
- Go 1.20+ (for DevContainer)
- git (for submodule support)
- Docker (optional, for DevContainer setup)

**Production:**
- Deployment target: GitHub Pages
- Triggered on push to `master` branch
- Static HTML output only (no server-side runtime required)

## Deployment Pipeline

**Build Process:**
1. Hugo 0.153.2 extended build with `-gc --minify`
2. Optional Node.js 20 dependency installation (if package-lock.json present)
3. Hugo resources caching (based on markdown file hashes)
4. Static output to `./public` directory
5. GitHub Pages artifact upload and deployment

**CI/CD:**
- GitHub Actions workflows in `.github/workflows/`
- `pages.yml` - Production deployment workflow
- `pr-checks.yml` - Pull request validation (uses Hugo 0.139.4)
- Dependabot enabled for dependency monitoring

## Development Tools

**VS Code Extensions (in DevContainer):**
- golang.Go - Go language support
- bungcip.better-toml - TOML syntax highlighting
- davidanson.vscode-markdownlint - Markdown linting

**Local Development:**
- DevContainer configuration at `.devcontainer/Dockerfile`
- Base: Go 1.20-bullseye with Hugo extended
- Port forwarding: 1313 (Hugo server default)

---

*Stack analysis: 2026-04-03*
