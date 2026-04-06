---
id: SEED-003
status: dormant
planted: 2026-04-06
planted_during: v1.0 milestone complete
trigger_when: talks page redesign or content model restructuring
scope: Medium
---

# SEED-003: Restructure talks as Hugo content model (not manual markdown)

## Why This Matters

The talks page is a single manually-maintained markdown file. Every new talk requires editing a monolithic page. This is the same problem the reading list had before v1.0 — and it has the same solution: a Hugo shortcode or content model.

Benefits of restructuring:
- **Each talk becomes a page bundle** — can have its own featured image, slides PDF, video embed
- **A shortcode like `{{< talk >}}`** with params: title, event, date, video_url, slides_url, type (keynote/talk/podcast)
- **Auto-sorted by date** — newest talks first, no manual reordering
- **JSON-LD SpeakingEvent schema** can be generated per talk (links to SEED-002)
- **Filter by type** — separate conference talks from podcast appearances
- The custom `layouts/talks/single.html` already exists and has good bones (pulse animation, featured image)

Current talks inventory: 7+ entries including LeadingEng Berlin 2024, Ventellect Podcast, The Critical Channel (own podcast).

## When to Surface

**Trigger:** When talks page, speaking engagements, or content model restructuring is mentioned.

This seed should be presented during `/gsd:new-milestone` when the milestone scope matches any of these conditions:
- Talks page improvement or redesign
- Content model or template restructuring
- Speaker/conference presence optimization
- Portfolio or professional showcase work

## Scope Estimate

**Medium** — Create shortcode, migrate existing talks, update layout template. Similar scope to reading list Phase 2. 2 phases.

## Breadcrumbs

- `content/talks/index.en.md` — Current monolithic talks page
- `content/talks/index.pt-br.md` — Portuguese version
- `layouts/talks/single.html` — Custom layout with pulse animation and featured image support
- `layouts/shortcodes/book.html` — Pattern to follow (same approach, different domain)

## Notes

The reading list v1.0 established the shortcode pattern. Applying the same pattern to talks would create a consistent content architecture across the site. Could also add a "Upcoming Talks" section similar to "Currently Reading."
