# Phase 3: Features and Publishing - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-04
**Phase:** 03-features-and-publishing
**Areas discussed:** Star rating display, Anchor navigation style, Publishing readiness

---

## Star Rating Display

### Display Style

| Option | Description | Selected |
|--------|-------------|----------|
| Filled stars only | Show only filled stars, no empty outlines. Uses Font Awesome fas fa-star. | ✓ |
| Filled + empty stars (5 total) | Always show 5 stars — filled in accent, empty outlines for remainder. | |
| You decide | Claude picks what fits the design. | |

**User's choice:** Filled stars only (Recommended)

### Placement

| Option | Description | Selected |
|--------|-------------|----------|
| After the title, same line | Stars inline with title link — compact, scannable. | ✓ |
| Below the author line | Stars on own line between author and description. | |
| Before the title | Stars first, then title. | |

**User's choice:** After the title, same line

### Rating Parameter

| Option | Description | Selected |
|--------|-------------|----------|
| Numeric 1-5 | Simple number: rating="5" shows 5 stars. | ✓ |
| Tier-based labels | rating="must-read" auto-maps to stars. | |
| You decide | Claude picks. | |

**User's choice:** Numeric 1-5 (Recommended)

---

## Anchor Navigation Style

### Visual Style

| Option | Description | Selected |
|--------|-------------|----------|
| Horizontal pill buttons (current) | Keep existing styled pill buttons, add Currently Reading. | |
| Simple inline text links | Plain text links separated by · or |. | |
| You decide | Claude picks what fits editorial design. | ✓ |

**User's choice:** Claude's discretion

### Sticky Behavior

| Option | Description | Selected |
|--------|-------------|----------|
| No, static | Stays at top of page content. No JS needed. | ✓ |
| Yes, sticky on scroll | Fixed at top when scrolling past. | |

**User's choice:** No, static (Recommended)

---

## Publishing Readiness

### Deployment Concerns

| Option | Description | Selected |
|--------|-------------|----------|
| Just make sure it builds and deploys | Standard deployment check. | |
| Update social meta tags too | Update OG image, description, sharing metadata. | |
| You decide what's needed | Claude determines necessary checks. | ✓ |

**User's choice:** Claude's discretion

### Page Title/Slug

| Option | Description | Selected |
|--------|-------------|----------|
| Keep current title and slug | "My Reading & Listening List" at /my-reading-list/ stays. | |
| Rename now | Change title and/or slug to something more shareable. | ✓ |

**User's choice:** Rename now

### New Title

| Option | Description | Selected |
|--------|-------------|----------|
| Recommended Reading | Short, clean, professional. | |
| Recommended Reading for Engineering Leaders | Specific, targets audience. | |
| What I'm Reading | Personal, casual tone matching writing style. | ✓ |

**User's choice:** What I'm Reading

### New Slug

| Option | Description | Selected |
|--------|-------------|----------|
| Keep /my-reading-list/ | No broken links. Title changes but URL stays. | |
| Change to /recommended-reading/ | Cleaner URL matching new title. Needs redirect. | ✓ |

**User's choice:** Change to /recommended-reading/

---

## Claude's Discretion

- Anchor nav visual style
- Star icon size and exact styling
- Social meta tag updates
- Additional publishing checks
- Portuguese page title and slug localization

## Deferred Ideas

- Content consolidation from CTO blog posts — v2
- "Last updated" timestamp — v2
- "Back to top" links — v2
