# AGENTS.md

This document provides AI agents with essential context about the italovietro.com project for effective code assistance, modifications, and maintenance.

## Project Overview

**Type:** Personal Website / Portfolio + Blog  
**Framework:** Hugo (Static Site Generator)  
**Theme:** LoveIt v0.2.X  
**Primary Language:** Go (Hugo), Markdown (content), SCSS (styling)  
**Hosting:** GitHub Pages  
**URL:** https://italovietro.com  
**Repository:** https://github.com/italolelis/italovietro.com

### Purpose
Professional portfolio and blog for Italo Vietro showcasing:
- Engineering leadership experience and career journey
- Technical blog posts on management and technology
- Consulting services
- Curated reading lists (books, newsletters, podcasts)
- Public talks and presentations

## Architecture

### Technology Stack
- **Hugo Extended:** v0.2.X+ (required for SCSS compilation)
- **LoveIt Theme:** Git submodule from https://github.com/dillonzq/LoveIt.git
- **Markdown Parser:** Goldmark (with footnotes, tables, task lists, strikethrough)
- **CSS Preprocessor:** SCSS/SASS
- **Analytics:** Google Analytics (G-KYX115R541)
- **Deployment:** GitHub Actions → GitHub Pages

### Key Directories

```
italovietro.com/
├── .devcontainer/       # VS Code DevContainer config (Go 1.20)
├── .github/             # GitHub Actions workflows + issue templates
├── archetypes/          # Content templates for new posts
├── assets/              
│   ├── css/            # Custom SCSS (_custom.scss, _override.scss)
│   ├── images/         # Site images, screenshots, photos
│   └── music/          # Audio files (Wavelength.mp3)
├── content/             # Markdown content (multilingual)
│   ├── posts/          # Blog posts (page bundles)
│   ├── consulting/     # Consulting services page
│   ├── my-reading-list/# Reading recommendations
│   └── talks/          # Public speaking engagements
├── layouts/             # Theme overrides
│   └── partials/       
│       ├── header.html # Custom header
│       └── plugin/     
│           └── analytics.html  # Custom analytics
├── resources/           # Generated SCSS (DO NOT EDIT)
├── static/              # Static assets (favicons, _redirects)
├── themes/              # Git submodule (LoveIt theme)
└── config.toml          # Main configuration (450+ lines)
```

## Configuration (config.toml)

### Critical Settings

**Base Configuration:**
```toml
baseURL = "https://italovietro.com"
defaultContentLanguage = "en"
theme = "LoveIt"
title = "Italo Vietro"
googleAnalytics = "G-KYX115R541"
```

**Multilingual Support:**
- Primary: English (en) - weight: 1
- Secondary: Portuguese (pt-br) - weight: 2
- All content should have both translations

**Navigation Menu (English):**
1. Consulting (/consulting/)
2. My reading list (/my-reading-list/)
3. Talks (/talks/)

**Important Feature Toggles:**
- `enableRobotsTXT = true` - SEO enabled
- `enableGitInfo = true` - Git metadata in pages
- `enableEmoji = true` - Emoji support in content
- Theme mode: auto/light/dark switching enabled
- Cookie consent: enabled (GDPR compliance)
- Social sharing: Twitter, Facebook, HackerNews, Line, Weibo

**Output Formats:**
- HTML (primary)
- RSS
- Markdown
- JSON (search index)

## Content Guidelines

### Blog Post Structure

All blog posts use **page bundles** (directory-based organization):

```
content/posts/my-post-title/
├── index.en.md          # English version (REQUIRED)
├── index.pt-br.md       # Portuguese version (REQUIRED)
├── featured-image.jpg   # Featured image
└── other-images.jpg     # Additional images
```

### Front Matter Template

```yaml
---
title: "Post Title"
date: 2024-01-15T10:00:00+00:00
lastmod: 2024-01-15T10:00:00+00:00
draft: false
author: "Italo Vietro"
authorLink: "https://italovietro.com"
description: "Brief description for SEO"
resources:
- name: "featured-image"
  src: "featured-image.jpg"
tags: ["Engineering", "Management", "Leadership"]
categories: ["Engineering"]
lightgallery: true
---
```

### Content Best Practices

1. **Always create bilingual content** (en + pt-br)
2. **Use page bundles** for posts with images
3. **Reference images relatively:** `![Alt text](image.jpg)`
4. **Follow existing post structure** in `content/posts/`
5. **Use semantic line breaks** in markdown
6. **Include descriptive alt text** for accessibility
7. **Add appropriate tags and categories** for discoverability

### Existing Content Structure

**Blog Posts (6 total):**
- 5 ways to keep up with code as an Engineering Manager
- CTO's reading list (editions 1, 2, 3)
- Do job titles matter
- How do we manage our GitHub organization at Lyko

**Pages:**
- Consulting services
- My reading list (books, newsletters, podcasts)
- Talks/presentations

## Development Workflow

### Local Development

**Using DevContainers (Recommended):**
```bash
# Open in VS Code and reopen in container
hugo server -D
# Visit http://localhost:1313
```

**Manual Setup:**
```bash
git clone --recurse-submodules https://github.com/italolelis/italovietro.com.git
cd italovietro.com
hugo server -D
```

**Important Commands:**
```bash
# Run dev server with drafts
hugo server -D

# Production build
hugo --minify

# Update theme submodule
git submodule update --remote

# Create new post
hugo new posts/my-new-post/index.en.md
```

### Theme Customization

**NEVER modify theme files directly.** Use overrides:

1. **CSS Customization:**
   - `assets/css/_custom.scss` - Custom styles
   - `assets/css/_override.scss` - Font overrides (currently: Roboto)

2. **Layout Overrides:**
   - Place custom layouts in `layouts/` (mirrors theme structure)
   - Example: `layouts/partials/header.html` overrides theme header

3. **Partial Overrides:**
   - `layouts/partials/plugin/analytics.html` - Custom analytics

### Git Workflow

**Important:**
- Theme is a git submodule - update with `git submodule update --remote`
- Never commit `public/` directory (auto-generated)
- Never commit `resources/_gen/` (auto-generated SCSS)
- Only `master` branch triggers deployment

## Deployment

### GitHub Actions Workflow

**Location:** `.github/workflows/pages.yml`

**Triggers:**
- Push to `master` branch
- Manual dispatch

**Build Process:**
1. Checkout repository with submodules
2. Setup Hugo extended (latest version)
3. Build: `hugo --minify` with production env vars
4. Upload artifacts from `./public`
5. Deploy to GitHub Pages

**Environment Variables:**
```bash
HUGO_ENVIRONMENT=production
HUGO_ENV=production
```

**Deployment Time:** ~1-2 minutes

### Dependabot Configuration

Automated dependency updates (monthly):
- GitHub Actions
- Docker images
- Git submodules (theme)

## Styling and Design

### Typography
- **Primary Font:** Roboto (Google Fonts)
- **Secondary Font:** Open Sans (fallback)
- Override in: `assets/css/_override.scss`

### Theme Features
- Responsive design (mobile + desktop)
- Auto/light/dark mode toggle
- Code syntax highlighting with copy button
- Table of contents auto-generation
- Light gallery for images
- TypeIt animation for subtitles
- Social sharing buttons

### Custom Styles
- Home content margin adjustments: `assets/css/_custom.scss`
- Font family overrides: `assets/css/_override.scss`

## SEO and Analytics

### Google Analytics
- Tracking ID: `G-KYX115R541`
- Privacy features enabled:
  - IP anonymization
  - Cookie consent required
  - DNT (Do Not Track) respected
- Custom implementation: `layouts/partials/plugin/analytics.html`

### SEO Features
- Sitemap generation enabled
- robots.txt enabled
- Open Graph tags for social sharing
- Structured data for publisher info
- Gravatar integration (me@italovietro.com)

## Common Tasks for AI Agents

### Creating a New Blog Post

```bash
# 1. Create post bundle
mkdir -p content/posts/my-new-post
touch content/posts/my-new-post/index.en.md
touch content/posts/my-new-post/index.pt-br.md

# 2. Add front matter to both files (see template above)
# 3. Write content in markdown
# 4. Add images to the same directory
# 5. Test locally: hugo server -D
# 6. Remove draft: false when ready
```

### Updating Navigation Menu

Edit `config.toml` under `[languages.en.menu.main]` or `[languages.pt-br.menu.main]`:

```toml
[[languages.en.menu.main]]
  identifier = "unique-id"
  name = "Display Name"
  url = "/url-path/"
  weight = 4  # Order in menu
```

### Adding Custom CSS

Edit `assets/css/_custom.scss`:

```scss
.my-custom-class {
  property: value;
}
```

Hugo will automatically compile SCSS to CSS.

### Modifying Theme Behavior

1. Identify the theme file in `themes/LoveIt/layouts/`
2. Copy structure to `layouts/` (same path)
3. Modify your copy (theme original remains untouched)

### Adding Analytics or Tracking

Modify `layouts/partials/plugin/analytics.html` or update config.toml analytics settings.

## Troubleshooting

### Common Issues

**Theme not loading:**
```bash
git submodule update --init --recursive
```

**CSS changes not appearing:**
```bash
# Clear resources cache
rm -rf resources/_gen/
hugo server -D
```

**Build fails on GitHub Actions:**
- Check Hugo version compatibility
- Verify all submodules are properly referenced
- Check for markdown syntax errors

**Images not displaying:**
- Ensure images are in same directory as index.md (page bundle)
- Use relative paths: `![alt](image.jpg)` not `![alt](/image.jpg)`
- Check image file names match exactly (case-sensitive)

## File Locations Reference

### Configuration
- Main config: `config.toml`
- Theme submodule: `.gitmodules`
- DevContainer: `.devcontainer/devcontainer.json`

### Custom Overrides
- Custom CSS: `assets/css/_custom.scss`
- Font overrides: `assets/css/_override.scss`
- Header: `layouts/partials/header.html`
- Analytics: `layouts/partials/plugin/analytics.html`

### Content
- Blog posts: `content/posts/*/index.{en,pt-br}.md`
- Consulting: `content/consulting/index.{en,pt-br}.md`
- Reading list: `content/my-reading-list/index.{en,pt-br}.md`
- Talks: `content/talks/index.{en,pt-br}.md`

### Static Assets
- Favicons: `static/*.{ico,png,svg}`
- Redirects: `static/_redirects`
- Web manifest: `static/site.webmanifest`

### Generated (DO NOT EDIT)
- SCSS output: `resources/_gen/assets/scss/`
- Build output: `public/` (gitignored)

## Code Style and Conventions

### Markdown
- Use semantic line breaks
- Headers: Title case
- Code blocks: Always specify language
- Lists: Consistent bullet style (-) 
- Links: Descriptive anchor text

### SCSS
- Follow BEM naming convention where applicable
- Keep specificity low
- Comment non-obvious styles
- Use variables from theme when possible

### Configuration
- TOML format
- Group related settings
- Comment complex configurations
- Maintain alphabetical order where logical

## Security and Privacy

### GDPR Compliance
- Cookie consent banner enabled
- Analytics requires user consent
- Privacy policy considerations in analytics config

### Analytics Privacy Settings
- `anonymizeIP = true`
- `respectDoNotTrack = true`
- `useSessionStorage = false`
- Consent management enabled

### Social Media Privacy
- Twitter privacy mode enabled
- YouTube privacy-enhanced mode enabled

## Performance Considerations

### Build Optimization
- Minification enabled in production
- Asset fingerprinting for cache busting
- Resource optimization via Hugo Pipes

### Image Optimization
- Use appropriate formats (WebP where possible)
- Include multiple sizes for responsive images
- Compress images before committing

### Caching Strategy
- Static assets cached aggressively
- HTML pages cached with revalidation
- Use Hugo's resource fingerprinting

## Testing

### Pre-deployment Checklist
1. Run `hugo server -D` - verify locally
2. Test both languages (en, pt-br)
3. Check responsive design (mobile + desktop)
4. Verify all images load
5. Test internal links
6. Check console for errors
7. Validate HTML/CSS
8. Test in multiple browsers

### Production Build Test
```bash
hugo --minify
# Check public/ directory for output
# Verify no errors in console
```

## Resources

### Documentation
- Hugo: https://gohugo.io/documentation/
- LoveIt Theme: https://hugoloveit.com/
- Goldmark: https://github.com/yuin/goldmark

### Tools
- Hugo Extended: https://github.com/gohugoio/hugo/releases
- DevContainers: https://code.visualstudio.com/docs/devcontainers/containers
- GitHub Actions: https://docs.github.com/en/actions

### Theme Repository
- LoveIt GitHub: https://github.com/dillonzq/LoveIt
- Theme docs: https://hugoloveit.com/theme-documentation-basics/

## Notes for AI Agents

### What to Preserve
- Bilingual content structure (always maintain both en and pt-br)
- Page bundle organization for posts
- Git submodule for theme (never modify theme directly)
- Existing navigation structure
- SEO and analytics configuration

### What to Watch Out For
- Never commit `public/` or `resources/_gen/`
- Always use page bundles for posts with images
- Maintain consistent front matter across translations
- Test both languages when making changes
- Respect theme override patterns (don't edit theme files)

### Common Requests
- Adding new blog posts (remember bilingual requirement)
- Updating reading list
- Modifying navigation menu
- Adding new pages (consulting, talks, etc.)
- CSS/styling adjustments
- Analytics or tracking updates

### Decision-Making Guidance
- **Adding Features:** Check if theme supports it first, then override if needed
- **Content Changes:** Always maintain bilingual parity
- **Style Changes:** Prefer `_custom.scss` over theme overrides
- **Configuration:** Document changes in comments
- **Dependencies:** Use Dependabot for updates

---

**Last Updated:** 2025-12-26  
**Hugo Version:** 0.2.X+ Extended  
**Theme Version:** LoveIt (latest from submodule)  
**Maintainer:** Italo Vietro
