---
id: SEED-004
status: dormant
planted: 2026-04-06
planted_during: v1.0 milestone complete
trigger_when: blog revival, content strategy, or navigation overhaul
scope: Medium
---

# SEED-004: Add blog posts to navigation and create an archive page

## Why This Matters

Blog posts are invisible. There's no "Blog" or "Posts" link in the main menu — the only way to find posts is through direct URLs or search engines. The homepage has posts disabled (`enable = false` in config.toml line 76). Six published posts and a draft exist but are effectively hidden.

For someone writing thoughtful leadership content ("Do Job Titles Matter?", "5 Ways to Keep Coding as an Engineering Manager"), this content deserves visibility. The reading list page is now beautifully designed — but it's the only content visitors can discover through navigation.

What's needed:
- Add "Writing" or "Blog" to the main menu
- Create a posts archive/list page with clean typography matching the reading list design
- Consider enabling recent posts on homepage (currently disabled)
- The 3 CTO Reading List blog posts could cross-link to the new recommended-reading page

## When to Surface

**Trigger:** When blog content, publishing, or navigation is a milestone goal.

This seed should be presented during `/gsd:new-milestone` when the milestone scope matches any of these conditions:
- Blog, writing, or content publishing
- Navigation redesign or menu restructuring
- Content discoverability or site architecture
- Resume building, professional presence

## Scope Estimate

**Medium** — Menu config changes, list page template, possible homepage integration. 1-2 phases.

## Breadcrumbs

- `config.toml:76` — Homepage posts disabled (`enable = false`)
- `config.toml:25-35` — EN menu (only 2 items: reading list + talks)
- `config.toml:88-98` — PT-BR menu (same 2 items)
- `content/posts/` — 7 post directories (6 published + 1 draft)
- `layouts/taxonomy/term.html` — Custom taxonomy page exists (tags/categories work)

## Notes

The CTO Reading List blog posts (3 editions) overlap with the new recommended-reading page. These could be updated with a note redirecting readers to the consolidated reading list, or the book recommendations could be extracted and merged (this was deferred as CEXP-01 in v1.0 requirements).
