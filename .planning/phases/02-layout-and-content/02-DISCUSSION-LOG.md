# Phase 2: Layout and Content - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-03
**Phase:** 02-layout-and-content
**Areas discussed:** Book entry format, Currently Reading section, Category presentation

---

## Book Entry Format

| Option | Description | Selected |
|--------|-------------|----------|
| Keep markdown lists | Current format: bullet + linked title + description. Simple to edit, no template changes needed. | |
| Structured markdown entries | Title as bold/heading, author on separate line, description below. Still pure markdown. | |
| Hugo shortcode per entry | Custom shortcode like `{{< book >}}`. Enables rich rendering and easy Phase 3 integration. | ✓ |

**User's choice:** Hugo shortcode per entry (Recommended)
**Notes:** Chose shortcode to enable structured rendering now and seamless star rating integration in Phase 3.

### Follow-up: Shortcode Fields

| Option | Description | Selected |
|--------|-------------|----------|
| Link (URL to purchase/read) | Keeps the current Amazon/external links | ✓ |
| Description (inner content) | Personal note/commentary as shortcode body text | ✓ |
| Type tag (book/newsletter/podcast) | Lets template render differently per type | ✓ |

**User's choice:** All three fields selected
**Notes:** Fields: title, author, link, type, description (body). Rating field deferred to Phase 3.

---

## Currently Reading Section

| Option | Description | Selected |
|--------|-------------|----------|
| Same shortcode with a flag | Add 'current: true' parameter. Template auto-renders flagged entries at top. | |
| Dedicated section in markdown | Manual `## Currently Reading` section at the top. Move entries in/out manually. | ✓ |
| Separate shortcode | Different shortcode with own styling. | |

**User's choice:** Dedicated section in markdown
**Notes:** Simple, explicit control. User curates manually.

### Follow-up: Entry Info

| Option | Description | Selected |
|--------|-------------|----------|
| Personal note (why you're reading it) | Short sentence like "Revisiting for our org design discussions" | ✓ |
| Started date | When started, e.g., "Started March 2026" | |
| Link to purchase/read | Same external link as regular entries | ✓ |

**User's choice:** Personal note + Link (no started date)
**Notes:** Keep it simple. Uses same book shortcode, personal note as body content.

---

## Category Presentation

### Visual Separation

| Option | Description | Selected |
|--------|-------------|----------|
| Simple h2 headings with dividers | Clean h2 + subtle horizontal rule between sections | |
| Styled section blocks | Different background shade or border-left accent per category | |
| You decide | Claude picks approach fitting typography-driven design goal | ✓ |

**User's choice:** Claude's discretion
**Notes:** Goal is scannable sections, not decorative styling.

### Tier Labels

| Option | Description | Selected |
|--------|-------------|----------|
| Keep current tier labels | Essential, Highly Recommended stay as-is | |
| Remove tiers, let ratings speak | Drop text labels, Phase 3 ratings convey ranking | |
| Reword tiers for consistency | Standardize to 3 tiers across all categories | ✓ |

**User's choice:** Reword tiers for consistency

### Follow-up: Tier Vocabulary

| Option | Description | Selected |
|--------|-------------|----------|
| Must Read / Recommended / Worth Your Time | Warm, personal tone matching writing style | ✓ |
| Essential / Highly Recommended / Good Read | Close to current labels, standardized | |
| You decide | Claude picks tier names | |

**User's choice:** Must Read / Recommended / Worth Your Time
**Notes:** Warm, personal tone consistent with Italo's writing voice.

---

## Claude's Discretion

- Category visual separation approach (headings, dividers, spacing)
- Exact HTML structure of the book shortcode
- Whether to use a single shortcode or type-specific variants
- How tier labels are styled

## Deferred Ideas

- Star ratings — Phase 3
- Anchor nav changes — Phase 3
- Content consolidation from blog posts — v2
- Page rename/rebrand — v2
