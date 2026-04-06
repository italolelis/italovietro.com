# Phase 4: Shortcode and Layout - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md. This log preserves the alternatives considered.

**Date:** 2026-04-06
**Phase:** 04-shortcode-and-layout
**Areas discussed:** Type-based visual treatment, Section structure

---

## Type-Based Visual Treatment

| Option | Description | Selected |
|--------|-------------|----------|
| Font Awesome icon per type | Small icon before title: microphone/headphones/podcast | |
| Colored accent label | Small "Talk"/"Podcast"/"Host" label in accent color | |
| Structural difference only | Sections provide context, entries look the same | |
| You decide | Claude picks what fits the typography-driven design | ✓ |

**User's choice:** Claude's discretion

---

## Section Structure

### Ordering

| Option | Description | Selected |
|--------|-------------|----------|
| Newest first | Most recent at top of each section | ✓ |
| Manual order | User controls position in markdown | |
| You decide | Claude picks | |

**User's choice:** Newest first (Recommended)

### Featured Image

| Option | Description | Selected |
|--------|-------------|----------|
| Keep it | Speaking photo stays as hero/banner | ✓ |
| Remove it | Drop hero, content speaks for itself | |
| You decide | Claude picks | |

**User's choice:** Keep it

---

## Claude's Discretion

- Type-based visual differentiation approach
- Talk entry shortcode field details (date format, link rendering)
- Featured image SCSS styling
- Whether titles link to video_url

## Deferred Ideas

- JSON-LD SpeakingEvent schema
- Upcoming talks section
- Per-talk dedicated pages
