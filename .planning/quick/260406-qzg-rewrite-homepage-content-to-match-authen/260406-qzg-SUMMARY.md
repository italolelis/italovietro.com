---
phase: quick
plan: 260406-qzg
subsystem: content
tags: [homepage, content, voice, scss, config]
dependency_graph:
  requires: []
  provides: [homepage-rewrite, home-intro-scss]
  affects: [content/_index.en.md, content/_index.pt-br.md, config.toml, assets/css/_custom.scss]
tech_stack:
  added: []
  patterns: [thematic-storytelling, scss-class-over-inline-style, dark-mode-scss]
key_files:
  created: []
  modified:
    - content/_index.en.md
    - content/_index.pt-br.md
    - config.toml
    - assets/css/_custom.scss
decisions:
  - "Subtitle uses personal, playful tone: 'I build teams, break monoliths, and brew strong coffee' — no emojis, TypeIt preserved"
  - "Homepage bio grouped by lessons (teams, systems) not company-by-company chronology"
  - "home-intro CSS class added to _custom.scss with dark mode support — replaces inline style that had no dark mode awareness"
  - "What Drives Me section cut entirely — thematic sections carry the same message more authentically"
  - "Beyond the Code tightened to one punchy paragraph — homelab, coffee, D&D, family"
metrics:
  duration: "~15 minutes"
  completed_date: "2026-04-06"
  tasks_completed: 2
  files_modified: 4
---

# Quick Task 260406-qzg: Rewrite Homepage Content to Match Authentic Voice — Summary

**One-liner:** Homepage bio rewritten from company-by-company resume to lessons-based thematic storytelling with personal subtitle, no inline styles, and dark mode-aware SCSS.

## What Was Done

Rewrote the homepage content for both English and Portuguese-BR to match the direct, self-aware voice already present on the reading list page. The previous homepage read like a press release ("architecting the future of AI-powered customer service"). The new version groups content by themes — what Italo learned about teams, what he learned about systems — with companies named as supporting evidence rather than headings.

Two commits:

1. **62c0be9** — `feat(quick-260406-qzg): update subtitles and add home-intro SCSS`
   - Updated EN subtitle in `config.toml` to "I build teams, break monoliths, and brew strong coffee"
   - Updated PT-BR subtitle to "Construo times, quebro monolitos e faço café forte"
   - Added `.home-intro` SCSS class with light/dark mode support to `_custom.scss`

2. **2efe7bc** — `feat(quick-260406-qzg): rewrite homepage content with thematic storytelling`
   - Rewrote `content/_index.en.md` with intro hook, two thematic sections, tightened Beyond the Code
   - Rewrote `content/_index.pt-br.md` with natural Brazilian Portuguese translation (same structure)
   - Zero inline styles in either file — both use `<p class="home-intro">`
   - Removed "Where I've Made Impact" and "What Drives Me" sections
   - Updated frontmatter descriptions to match new voice

## Verification Results

```
=== Inline style check ===
content/_index.en.md:0
content/_index.pt-br.md:0
=== home-intro class ===
content/_index.en.md:1
content/_index.pt-br.md:1
=== No Where I Made Impact ===
0
=== Hugo build ===
Total in 346 ms
```

Hugo builds without errors. All success criteria met.

## Deviations from Plan

None — plan executed exactly as written.

## Known Stubs

None. All content is wired. Currently Reading section remains a placeholder in the reading list (pre-existing, out of scope for this task).

## Self-Check: PASSED

- content/_index.en.md: exists with home-intro class, zero inline styles
- content/_index.pt-br.md: exists with home-intro class, zero inline styles
- config.toml: both subtitles updated, no emojis, typeit preserved
- assets/css/_custom.scss: home-intro class present with dark mode variants
- Commits 62c0be9 and 2efe7bc: both verified in git log
- Hugo build: clean, no errors
