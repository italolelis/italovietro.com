# Quick Task 260406-qzg: Rewrite homepage content to match authentic voice - Context

**Gathered:** 2026-04-06
**Status:** Ready for planning

<domain>
## Task Boundary

Rewrite the homepage content (`content/_index.en.md` and `content/_index.pt-br.md`) to match the authentic, direct voice from the reading list descriptions. Fix inline styles. Update config.toml subtitle.

</domain>

<decisions>
## Implementation Decisions

### Bio Structure
- **D-01:** Replace the company-by-company chronological history with thematic storytelling. Group by lessons learned, not roles held. Companies become supporting evidence ("At HelloFresh, I learned X"), not the headline.
- **D-02:** Structure: intro hook → thematic sections (what I've learned about teams/systems/leadership) → Beyond the Code. No "Where I've Made Impact" role-by-role section.

### Subtitle and First Impression
- **D-03:** Replace the emoji-filled subtitle with something personal and memorable matching the reading list voice. e.g., "I build teams, break monoliths, and brew strong coffee" — direct, self-aware, a bit playful.
- **D-04:** Keep TypeIt animation enabled for the subtitle.

### Content Decisions
- **D-05:** Keep "Beyond the Code" section (homelab, coffee, D&D, family) — tighten it but preserve the personal touch.
- **D-06:** Keep the intro hook paragraph but rewrite in authentic voice — no press-release tone like "architecting the future of AI-powered customer service."
- **D-07:** Cut the full company-by-company history (the current "Where I've Made Impact" section with 6 company blocks).

### Technical
- **D-08:** Fix inline styles — move `<p style="font-size: 1.25rem; color: #666;">` to SCSS (same pattern Phase 1 used). Add homepage-specific styles to `_custom.scss`.

### Claude's Discretion
- Exact thematic section headings
- Which companies to mention and in what context
- Subtitle wording (within the "personal and memorable" direction)
- How to tighten "Beyond the Code"
- Portuguese translation approach

</decisions>

<canonical_refs>
## Canonical References

- `content/_index.en.md` — Current homepage content (50 lines, to be rewritten)
- `content/_index.pt-br.md` — Portuguese version (needs same treatment)
- `content/recommended-reading/index.en.md` — Reference for authentic voice (book descriptions)
- `config.toml:67` — Subtitle config (EN)
- `config.toml:122` — Subtitle config (PT-BR)
- `assets/css/_custom.scss` — Where homepage styles should go
- `.planning/seeds/SEED-007-homepage-rewrite.md` — Full analysis of voice gap

</canonical_refs>
