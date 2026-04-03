# Feature Landscape

**Domain:** Personal reading list page (tech leader / engineering manager audience)
**Researched:** 2026-04-03
**Reference:** The Pragmatic Engineer's reading list (blog.pragmaticengineer.com/my-reading-list/)

---

## Table Stakes

Features visitors expect. Missing = page feels unfinished or hard to share.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Anchor-based category navigation | Long pages without jump links frustrate readers; NNGroup confirms ToC improves scanability | Low | Flat list of `#section` links near the top; already partially present |
| Category sections with clear headings | Visitors self-select by role (engineer vs manager vs listener); unorganized list feels like a dump | Low | Engineering Books, Management Books, Newsletters, Podcasts match existing mental model |
| Per-entry description (1-3 sentences) | Title alone is not enough — visitors need "why should I read this?" to decide to click | Low | Already present in current page; keep and refine for consolidated content |
| External link per entry | The call-to-action is "find the book"; a list without links is a dead end | Low | Already present; Amazon affiliate status should be declared or avoided |
| Page-level intro paragraph | Sets curator authority and reading philosophy; without it the list has no personality | Low | Already present and strong; preserve verbatim |
| Mobile-responsive layout | Personal sites are frequently opened on phones when someone shares a link in Slack | Low | Already handled by LoveIt theme; new layout must not break it |
| Light/dark mode compatibility | LoveIt site already supports both; a hardcoded-color redesign would look broken | Low | Must use CSS variables (`--global-background-color`, `--header-title-color`, etc.) |

---

## Differentiators

Features that set this page apart and drive sharing. Not expected, but valued.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Star ratings (5-star, Unicode) | Makes top picks scannable in seconds — the single most cited feature on Pragmatic Engineer's list; visitors share pages that have instant signal | Low | Unicode ★/☆ characters, no JS needed. Implementation: `★★★★☆` inline. Group as "Essential" (5★), "Highly Recommended" (4★), "Worth Reading" (3★) |
| "Currently Reading" section at top | Creates a sense of the curator as a live person, not a static list; increases return visits; Pragmatic Engineer uses this pattern | Low | One to three entries max. Title + author + one-line personal note ("Midway through — the org design chapter is exceptional") |
| Consolidated content from CTO blog posts | Three editions of CTO Reading List contain article recs and book commentary that lives buried in posts from 2020; surfacing the book picks onto the main page creates a single shareable URL | Medium | Requires content curation decisions per post. Articles from those posts are time-stamped and should NOT be merged — only the book picks |
| "Last updated" timestamp | Signals the page is maintained; readers trust curated lists more when they know recency | Low | Simple text near the top: "Last updated: March 2026" |
| Personal voice per entry | Italo's existing descriptions are unusually good ("Changed everything about how I approached readability"). This is a differentiator — most reading lists are dry. Preserve and extend to all entries | Low | No new work needed for existing entries; apply same standard to new ones from blog posts |
| Renamed/rebranded page title | "My Reading & Listening List" is fine but not shareable-first; something like "Recommended Reading for Engineering Leaders" signals the audience and makes the link self-descriptive when dropped in Slack | Low | Frontmatter `title:` change only; slug can remain `my-reading-list` for URL stability |
| Subtle tier labels within categories | "Essential" / "Highly Recommended" tier labels (currently used in the page) communicate priority without requiring stars; can work alongside star ratings | Low | Already present in current design as bold text; elevate to a consistent system |
| "Back to top" links after each section | Reduces scroll fatigue on long pages; common on well-maintained reference pages | Low | Simple Markdown anchor `[↑ Back to top](#top)` after each `## Section` |

---

## Anti-Features

Features to deliberately NOT build. Each represents a temptation to avoid.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| Book cover images | Adds visual noise, requires image hosting, slows page load, breaks the clean editorial style of the reference design; PROJECT.md explicitly calls this out of scope | Use bold title text + star rating as the visual anchor |
| Interactive filtering / sorting | Requires JavaScript; LoveIt theme is mostly CSS-driven; the list is not large enough to need filtering (< 30 items total); adds maintenance surface | Use static anchor navigation to categories |
| Goodreads / external tracker integration | External service dependency; Goodreads has poor API reliability and a degraded product; creates synchronization problem | Manually maintain the "Currently Reading" section — it only needs to change a few times per year |
| Reading progress bars or "X% done" indicators | Gimmicky for a professional recommendation page; looks like a reading app, not a curated list | One-line personal note ("Midway through") communicates the same thing without the widget |
| Comment section / reactions | Content management overhead; reading lists are reference pages not blog posts | The existing "send me a DM" CTA is sufficient for feedback |
| Separate pages per book / modal book detail | Over-engineering for a list with at most ~30 entries; adds navigation complexity | Each entry's description is the detail — keep it on the same page |
| Pagination | No list this size needs pagination; creates friction when sharing specific books | Single long page with anchor navigation |
| Auto-generated "reading stats" (books per year, genres breakdown) | Requires data model, JavaScript, and maintenance; adds complexity without reader value | If desired later, this is a future milestone not part of this redesign |
| Podcast episode lists | The podcast sections list the shows, not individual episodes. Expanding into per-episode lists would require ongoing curation that's unsustainable | Keep to show-level entries with a one-line description |

---

## Feature Dependencies

```
"Currently Reading" section → needs consolidated content decision (what moves from blog posts)
Star ratings → must be assigned to all entries before publishing (partial ratings look unfinished)
Consolidated content → must curate book picks from CTO Reading List posts 1, 2, 3 first
  → then assign star ratings to those picks
  → then slot into appropriate category sections
Anchor navigation → depends on final category/section names being stable
"Last updated" timestamp → trivial; no dependencies
Page rename → slug must remain stable (my-reading-list) to avoid broken links
```

---

## Content to Consolidate from CTO Reading List Posts

Books referenced in the three CTO Reading List blog posts that are candidates for the main page:

| Book | Post | Already on main page? |
|------|------|----------------------|
| The Phoenix Project | Edition 1 | Yes — Management > Essential |
| Grokking Algorithms | Edition 2 | Yes — Engineering > Essential |
| Software Engineering at Google | Edition 3 | No — needs to be added |

Articles from those posts should NOT be consolidated — they are time-stamped commentary, not evergreen recommendations.

---

## MVP Recommendation

For this milestone, prioritize in order:

1. **Typography-driven layout** — remove card borders, convert to clean list rows with bold titles and descriptions. Foundation that everything else builds on.
2. **Star ratings** — Unicode characters, assigned to all entries. The single highest-signal differentiator with the lowest implementation cost.
3. **"Currently Reading" section at top** — one to three entries. Gives the page a live feeling.
4. **Consolidated book picks from CTO posts** — surface "Software Engineering at Google" and any other missing books. Small content lift.
5. **Anchor navigation ToC** — already present; refine styling to match new layout.
6. **"Last updated" timestamp and page rename** — one-line changes each; very low cost, clear shareability benefit.

Defer:
- "Back to top" links: Nice to have, add if time allows.
- Per-section tier labels: Already present as bold text; polish can wait.
- Newsletter and Podcast section content expansion: Current entries are sufficient.

---

## Sources

- [The Pragmatic Engineer — My Reading & Listening List](https://blog.pragmaticengineer.com/my-reading-list/) — reference design (HIGH confidence, directly inspected)
- [Lethain.com — Best Books](https://lethain.com/best-books/) — alternative pattern: ranked list without star ratings (HIGH confidence, directly inspected)
- [Coding Horror — Recommended Reading for Developers](https://blog.codinghorror.com/recommended-reading-for-developers/) — cover image + description pattern (MEDIUM confidence, inspected)
- [Staff Engineer's Path Resource List](https://www.noidea.dog/staff-resources) — chapter-organized pattern without ratings (MEDIUM confidence, inspected)
- [NNGroup — Table of Contents: The Ultimate Design Guide](https://www.nngroup.com/articles/table-of-contents/) — anchor navigation UX research (HIGH confidence)
- [NNGroup — In-Page Links for Content Navigation](https://www.nngroup.com/articles/in-page-links-content-navigation/) — in-page link behavior (HIGH confidence)
- Existing site content: `content/my-reading-list/index.en.md`, `content/posts/cto-reading-list-{1,2,3}/index.en.md` (HIGH confidence, directly read)
