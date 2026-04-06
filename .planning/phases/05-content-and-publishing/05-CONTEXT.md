# Phase 5: Content and Publishing - Context

**Gathered:** 2026-04-06
**Status:** Ready for planning

<domain>
## Phase Boundary

Rewrite all talk descriptions in Italo's authentic voice, add an intro paragraph, rename the page to "Speaking" at `/speaking/`, create the Portuguese version, and update config.toml menu entries. This is the final phase of v1.1.

</domain>

<decisions>
## Implementation Decisions

### Description Rewrite
- **D-01:** Rewrite all 7 talk descriptions in the same voice as the reading list. Personal anecdotes, opinions, context. "I gave this talk because...", "This one came from a real incident at...". Direct and experience-driven.
- **D-02:** No em dashes. Short sentences. Personal, not corporate.
- **D-03:** The intro paragraph should set the tone for the page. What speaking means to Italo, why he does it, what topics he covers. Same authentic voice.

### Portuguese Version
- **D-04:** Translate descriptions into natural informal Brazilian Portuguese (same approach as the homepage rewrite). Talk titles stay in English since the talks were given in English.
- **D-05:** Portuguese page headings localized (e.g., "Palestras" for Conference Talks, section headings in Portuguese).

### Page Rename
- **D-06:** Page title changes to "Speaking" (EN) / appropriate Portuguese equivalent.
- **D-07:** URL slug changes from `/talks/` to `/speaking/`. Add Hugo `aliases` redirect from old URL.
- **D-08:** Portuguese slug localized. Add redirect from old PT-BR URL.
- **D-09:** Config.toml menu entries updated for both languages with new title and URL.

### Claude's Discretion
- Intro paragraph content (within the authentic voice direction)
- Exact description rewrites (personal anecdotes, context per talk)
- Portuguese page title and slug localization
- Whether to reorder any entries within sections

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Content to rewrite
- `content/talks/index.en.md` — Current EN content with 7 shortcode entries (descriptions need rewrite)
- `content/talks/index.pt-br.md` — Portuguese version (needs full update to match)

### Voice reference
- `content/recommended-reading/index.en.md` — Gold standard for Italo's authentic voice
- `content/_index.en.md` — Homepage rewrite (also authentic voice)

### Config
- `config.toml` — Menu entries for both languages (lines ~25-35 EN, ~88-98 PT-BR)

### Phase 4 output
- `layouts/shortcodes/talk.html` — Shortcode template (already built)
- `assets/css/_speaking.scss` — SCSS (already built)
- `.planning/phases/04-shortcode-and-layout/04-CONTEXT.md` — Phase 4 decisions

</canonical_refs>

<code_context>
## Existing Code Insights

### Current State
- 7 shortcode entries already in `index.en.md` with placeholder descriptions
- Three sections: Conference Talks (5), Podcast Appearances (1), The Critical Channel (1)
- Hugo `aliases` frontmatter used successfully in reading list rename (Phase 3)

### Integration Points
- Content directory may need renaming from `content/talks/` to `content/speaking/` to match new slug
- Config.toml menu URLs need updating
- Portuguese file needs full content (currently still has old markdown format or may need creation)

</code_context>

<specifics>
## Specific Ideas

No specific references. Follow the reading list description voice. The original talk descriptions (from before the shortcode migration) have good raw material that can be personalized.

</specifics>

<deferred>
## Deferred Ideas

None. This is the final phase of v1.1.

</deferred>

---

*Phase: 05-content-and-publishing*
*Context gathered: 2026-04-06*
