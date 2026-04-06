---
id: SEED-002
status: dormant
planted: 2026-04-06
planted_during: v1.0 milestone complete
trigger_when: SEO, discoverability, or professional presence milestone
scope: Medium
---

# SEED-002: Add JSON-LD structured data and fix SEO gaps

## Why This Matters

The site has zero structured data (schema.org/JSON-LD). Google and LinkedIn rich previews are missing context. For someone sharing their reading list with colleagues and speaking at conferences like LeadingEng Berlin, this is low-hanging fruit that directly impacts professional visibility.

Specific gaps found:
- **No Person schema** on homepage — Google doesn't know this is an engineering leader's site
- **No Article schema** on blog posts — posts don't get rich snippets in search
- **No SpeakingEvent schema** on talks — speaking engagements invisible to search
- **SEO publisher name is literally "xxxx"** (config.toml line 304)
- **No site verification codes** configured (Google Search Console, Bing Webmaster)
- **Open Graph image** points to a generic logo, not a branded social card

## When to Surface

**Trigger:** When SEO, discoverability, search ranking, or professional branding is a milestone goal.

This seed should be presented during `/gsd:new-milestone` when the milestone scope matches any of these conditions:
- SEO, search, or discoverability is mentioned
- Professional presence, branding, or visibility is a goal
- "Make the site more shareable" or social media optimization

## Scope Estimate

**Medium** — Needs Hugo partial templates for JSON-LD injection, config.toml cleanup, social image creation, and verification setup. 2-3 phases.

## Breadcrumbs

- `config.toml:304` — SEO publisher name is "xxxx" (placeholder)
- `config.toml:327-329` — SEO image config with generic screenshots
- `config.toml:336` — Google Analytics ID (analytics exists, but no Search Console)
- `layouts/partials/` — Where JSON-LD partials would go
- `themes/LoveIt/layouts/partials/` — Theme's existing meta tag injection points

## Notes

LoveIt theme has basic Open Graph support but no JSON-LD. Custom partials in `layouts/partials/` can extend the theme's `<head>` without modifying the theme submodule. The Person schema should reference the same social links already in config.toml (GitHub, LinkedIn, Twitter).
