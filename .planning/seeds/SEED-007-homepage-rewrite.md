---
id: SEED-007
status: dormant
planted: 2026-04-06
planted_during: v1.0 milestone complete
trigger_when: homepage redesign, personal branding, or content voice milestone
scope: Medium
---

# SEED-007: Rewrite homepage content to sound like Italo

## Why This Matters

The current homepage bio reads like a polished LinkedIn summary — corporate, third-person energy, heavy on company names and titles. It doesn't match the voice in the reading list descriptions, which are personal, opinionated, and direct ("Stop writing code for compilers; write it for humans", "Sounds cheesy, but it works").

Specific problems:
- **Corporate tone:** "architecting the future of AI-powered customer service" — sounds like a press release, not a person
- **Title-heavy:** Every section leads with job title + company. The voice is "I was VP at X" rather than "Here's what I learned"
- **Repetitive structure:** Each company block follows the same pattern (role → what I did → clever one-liner). Gets predictable.
- **Inline styles:** `<p style="font-size: 1.25rem; color: #666;">` — should be in SCSS (same problem Phase 1 fixed for the reading list)
- **Subtitle:** "Engineering Leader 👨‍💼 • Platform Engineering 🚀 • Coffee Lover ☕" uses emoji as filler — the reading list page proves the site looks better without them
- **The reading list descriptions show Italo's real voice:** direct, self-deprecating, experience-driven ("First half will feel familiar if you've done on-call", "Wish I'd read this before my first CTO gig"). The homepage should match this energy.

The homepage is the first thing people see. After the reading list redesign, it's now the weakest page on the site.

## When to Surface

**Trigger:** When homepage, personal branding, bio, or content voice is a milestone goal.

This seed should be presented during `/gsd:new-milestone` when the milestone scope matches any of these conditions:
- Homepage redesign or improvement
- Personal branding or professional presence
- Content voice, tone, or writing quality
- "Make the site feel more like me"
- Site-wide design consistency

## Scope Estimate

**Medium** — Rewrite the bio content (both EN and PT-BR), extract inline styles to SCSS, possibly redesign the section layout. Needs Italo's input on tone and what stories to tell. 1-2 phases.

## Breadcrumbs

- `content/_index.en.md` — Current homepage content (50 lines, corporate tone, inline styles)
- `content/_index.pt-br.md` — Portuguese version (needs same treatment)
- `config.toml:67` — Subtitle with emoji ("Engineering Leader 👨‍💼 • Platform Engineering 🚀 • Coffee Lover ☕")
- `content/recommended-reading/index.en.md` — Reference for Italo's authentic voice (book descriptions)
- `assets/css/_custom.scss` — Where homepage styles should live (not inline)

## Notes

The reading list descriptions are the gold standard for Italo's voice. A homepage rewrite should study those descriptions and replicate that directness. Consider: less company-name-dropping, more "here's what I actually learned" storytelling. The subtitle could be a single punchy line instead of emoji-separated buzzwords.
