# External Integrations

**Analysis Date:** 2026-04-03

## APIs & External Services

**Analytics:**
- Google Analytics 4 - Primary analytics platform
  - SDK/Client: Google Tag Manager script (gtag.js)
  - Config ID: `G-KYX115R541`
  - Location: `config.toml` - `params.analytics.google.id`
  - Implementation: `layouts/partials/plugin/analytics.html`
  - Privacy: Anonymize IP enabled, consent-based tracking with default deny

- Fathom Analytics - Alternative privacy-focused analytics (optional)
  - SDK/Client: Fathom tracker script
  - Config: `params.analytics.fathom` in config
  - Location: `layouts/partials/plugin/analytics.html`

- Plausible Analytics - Alternative privacy analytics (optional)
  - SDK/Client: Plausible script
  - Config: `params.analytics.plausible` in config
  - Location: `layouts/partials/plugin/analytics.html`

- Yandex Metrica - Russian analytics platform (optional)
  - SDK/Client: Yandex Metrica tag
  - Config: `params.analytics.yandexMetrica` in config
  - Location: `layouts/partials/plugin/analytics.html`

**Maps & Geolocation:**
- Mapbox GL JS - Interactive mapping (when enabled in params)
  - Access Token: `pk.eyJ1IjoiZGlsbG9uenEiLCJhIjoiY2s2czd2M2x3MDA0NjNmcGxmcjVrZmc2cyJ9.aSjv2BNuZUfARvxRYjSVZQ`
  - Config location: `config.toml` - `params.page.mapbox`
  - Features: Navigation control, geolocation, scale, fullscreen
  - Styles: Light v10 and dark v10 styles

**Fonts & CDN:**
- Google Fonts - Roboto and Open Sans font delivery
  - Load URL: `https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&family=Open+Sans:wght@400;700&display=swap`
  - Config location: `assets/css/style.scss`

- jsDelivr - CDN for third-party libraries
  - Config: `params.cdn.data` references `jsdelivr.yml`
  - Used for library resource caching and delivery

- Font Awesome CDN - Icon delivery (integrated via theme)
  - Version: Font Awesome 5+
  - Usage: `fontawesome` extended syntax in markdown

## Data Storage

**Databases:**
- Not used - Static site generator, no database backend

**File Storage:**
- Local filesystem only
  - Static assets: `static/` directory
  - Content: `content/` directory (Markdown files)
  - Generated output: `public/` directory
  - Hugo resources cache: `resources/` directory

**Caching:**
- GitHub Actions cache for Hugo resources
  - Path: `resources/`
  - Cache key: Based on markdown file hashes (`**/*.md`)
  - Strategy: Restore keys used for incremental builds

## Authentication & Identity

**Auth Provider:**
- Gravatar - User avatar fetching
  - Email: `me@italovietro.com`
  - Config: `languages.en.params.home.profile.gravatarEmail` in config.toml
  - Usage: Home page profile avatar
  - Implementation: Theme integrates Gravatar image URL generation

**Social Media Links:**
- GitHub - Social link to `italolelis`
- LinkedIn - Social link to `italolelis`
- Email contact - `me@italovietro.com`
- RSS feeds enabled
- No OAuth or third-party authentication

## Monitoring & Observability

**Error Tracking:**
- None configured

**Logs:**
- GitHub Actions workflow logs
- Hugo build warnings captured in CI/CD pipeline (`.github/workflows/pr-checks.yml`)
- No external log aggregation

**Site Status:**
- GitHub Pages - Provides build status and deployment logs

## CI/CD & Deployment

**Hosting:**
- GitHub Pages - Primary deployment platform
- Repository: `https://github.com/italolelis/italovietro.com`
- Base URL: `https://italovietro.com`

**CI Pipeline:**
- GitHub Actions
- Workflows location: `.github/workflows/`

**Deploy Workflow (pages.yml):**
- Trigger: Push to `master` branch
- Environment: `ubuntu-latest`
- Hugo version: 0.153.2 extended
- Node.js: Version 20
- Steps:
  1. Checkout with submodules (recursive, full depth)
  2. Setup Hugo 0.153.2
  3. Setup Node.js 20
  4. Install npm dependencies (if package-lock.json exists)
  5. Cache Hugo resources
  6. Build with `hugo --gc --minify --baseURL`
  7. Upload to GitHub Pages artifact
  8. Deploy to GitHub Pages

**PR Checks Workflow (pr-checks.yml):**
- Trigger: Pull requests to `master`
- Hugo version: 0.139.4 extended (note: different from production)
- Node.js: Version 20
- Steps:
  1. Checkout with submodules
  2. Setup Hugo 0.139.4
  3. Setup Node.js 20
  4. Install npm dependencies
  5. Cache Hugo resources
  6. Build with `hugo --gc --minify`
  7. Check for build warnings

## Environment Configuration

**Required env vars:**
- None hardcoded - All configuration in `config.toml`
- DevContainer has placeholder: `HUGO_SERVICES_INSTAGRAM_ACCESSTOKEN` (unused)

**Secrets location:**
- No secrets stored in git
- Mapbox token exposed in public config (appears to be a demo/public token)
- `.env` files present but not committed (`.gitignore`)
- GitHub Pages permissions via GitHub token (`GITHUB_TOKEN`)

**Configuration Files:**
- `.github/dependabot.yml` - Automated dependency updates
- `.github/release.yml` - Release configuration

## Webhooks & Callbacks

**Incoming:**
- GitHub Push webhook - Triggers CI/CD pipeline on master branch push
- GitHub Pull Request webhook - Triggers PR checks workflow

**Outgoing:**
- None configured
- Site is static, no outbound API calls during build
- Google Analytics and optional analytics platforms receive page view data from client

## Social & Sharing

**Social Share Buttons (in posts):**
- Enabled: Twitter, Facebook, HackerNews, Line, Weibo
- Disabled: LinkedIn, WhatsApp, Pinterest, Tumblr, Reddit, and others
- Implementation: `config.toml` - `params.page.share`

## Search Functionality

**Local Search:**
- Lunr.js for client-side full-text search (optional, if enabled)
- Chinese text support via segmentit library
- Search index generation during Hugo build

## SEO & Verification

**Search Engine Verification:**
- Google, Bing, Yandex, Pinterest, Baidu verification tokens (placeholders)
- Location: `config.toml` - `params.verification`
- Sitemap generation enabled
- Robots.txt auto-generation enabled
- Open Graph and Twitter Card support with preview images

---

*Integration audit: 2026-04-03*
