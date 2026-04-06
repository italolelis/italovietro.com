---
id: SEED-006
status: dormant
planted: 2026-04-06
planted_during: v1.0 milestone complete
trigger_when: reading list v2 or content consolidation milestone
scope: Small
---

# SEED-006: Consolidate CTO Reading List blog posts into the recommended-reading page

## Why This Matters

This was explicitly deferred as CEXP-01 in the v1.0 requirements. Three blog posts exist:
- "CTO's reading list ed.1" (Nov 2020)
- "CTO's reading list ed.2" (Nov 2020)
- "CTO's reading list ed.3" (Dec 2020)

Each contains 3 article recommendations + 1 book recommendation. The books overlap with the new recommended-reading page. The articles are unique content not captured elsewhere.

Options:
1. **Extract unique books** from the blog posts into the reading list page (using `{{< book >}}` shortcode)
2. **Add an "Articles" category** to the reading list for the article recommendations
3. **Cross-link** the blog posts to the reading list page with a note
4. **Archive** the blog posts with a redirect to the reading list

This closes the loop on the original v1.0 vision of a single consolidated reading page.

## When to Surface

**Trigger:** Reading list v2, content consolidation, or blog content cleanup.

This seed should be presented during `/gsd:new-milestone` when the milestone scope matches any of these conditions:
- Reading list improvements or v2
- Content consolidation or deduplication
- Blog content cleanup or archival

## Scope Estimate

**Small** — Extract ~12 recommendations across 3 posts, add to reading list shortcodes, update/redirect blog posts. A few hours.

## Breadcrumbs

- `content/posts/cto-reading-list-1/` — Edition 1
- `content/posts/cto-reading-list-2/` — Edition 2
- `content/posts/cto-reading-list-3/` — Edition 3
- `content/recommended-reading/index.en.md` — Target page
- `.planning/REQUIREMENTS.md` — CEXP-01 (deferred to v2)

## Notes

The `{{< book >}}` shortcode already supports `type="newsletter"` and `type="podcast"`. Adding `type="article"` would be trivial and could support the article recommendations from these posts.
