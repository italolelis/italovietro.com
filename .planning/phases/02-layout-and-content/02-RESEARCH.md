# Phase 02: Layout and Content - Research

**Researched:** 2026-04-03
**Domain:** Hugo shortcodes, SCSS typography patterns, content migration
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** Create a Hugo shortcode `{{< book >}}` for each entry with parameters: `title`, `author`, `link` (URL), `type` (book/newsletter/podcast). The description/personal note is passed as the shortcode body content.
- **D-02:** The shortcode renders a clean typography-driven entry — no cards, no borders, no hover effects. Title as a linked heading-style element, author on a secondary line, description below.
- **D-03:** The shortcode must be extensible for Phase 3 — a `rating` parameter will be added later for star ratings. Do not add it now, but design the HTML structure so it can be inserted without breaking layout.
- **D-04:** A manually curated `## Currently Reading` section at the top of the page, before all category sections. The user moves entries in/out of this section as they finish books.
- **D-05:** "Currently Reading" entries use the same `{{< book >}}` shortcode with the same fields. The personal note (body content) serves as "why I'm reading this."
- **D-06:** No "started date" field — keep it simple. 1-3 entries at any time.
- **D-07:** Category visual separation is Claude's discretion — pick what best fits a clean, editorial, typography-driven design.
- **D-08:** Standardize to 3 consistent tiers across ALL categories: **Must Read**, **Recommended**, **Worth Your Time**. Replace current inconsistent labels (Essential, Highly Recommended).
- **D-09:** Tier labels are rendered as styled sub-headings within each category section.
- **D-10:** All content remains in markdown files (`index.en.md`, `index.pt-br.md`). No Hugo data files.
- **D-11:** Existing content must be preserved and migrated to the shortcode format. No entries lost.

### Claude's Discretion

- Category visual separation approach (headings, dividers, spacing)
- Exact HTML structure of the book shortcode (semantic elements, CSS classes)
- Whether to use a single shortcode template or type-specific variants
- How tier labels are styled (bold text, small caps, colored accent, etc.)

### Deferred Ideas (OUT OF SCOPE)

- Content consolidation from CTO Reading List blog posts — v2 scope (CEXP-01)
- Page rename/rebrand — v2 scope (CEXP-02)
- Star ratings display — Phase 3 (RATE-01, RATE-02, RATE-03)
- Anchor-based category navigation — Phase 3 (LAYOUT-03)
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| LAYOUT-01 | Card-based design replaced with clean typography-driven layout (no borders, no hover effects) | Phase 1 SCSS card selectors identified for removal; shortcode pattern provides replacement HTML without card markup |
| LAYOUT-02 | Category sections have clear, consistent headings | `## h2` with border-bottom already styled in Phase 1; tier `### h3` redesigned as small-caps metadata labels via UI-SPEC |
| CONT-01 | "Currently Reading" section displayed prominently at the top with 1-3 entries | Placed as first section in markdown after intro paragraph; uses same `{{< book >}}` shortcode |
| CONT-02 | Each "Currently Reading" entry has title, author, and a personal note | Covered by shortcode parameters `title`, `author`, and `.Inner` body content |
| CONT-03 | Page-level intro paragraph preserved | Both `index.en.md` and `index.pt-br.md` intro paragraphs are identified verbatim for carry-forward |
| CONT-04 | Per-entry descriptions preserved and consistent across all entries | All 14 existing entries audited and mapped to shortcode migration; description = shortcode body |
</phase_requirements>

---

## Summary

Phase 2 delivers two concrete artifacts: a Hugo shortcode (`layouts/shortcodes/book.html`) and updated content in both language markdown files. The shortcode replaces the raw Markdown bullet list pattern with structured, semantic HTML that supports a clean typography-driven design. Phase 1 established the SCSS foundation and dark mode pattern; Phase 2 replaces the Phase 1 card styles with shortcode-specific selectors and adds the Currently Reading section.

The research confirms all decisions are pre-resolved in 02-CONTEXT.md and 02-UI-SPEC.md. The UI-SPEC contains the exact HTML structure, SCSS selectors, typography values, color assignments, and spacing scale the implementer needs. No architectural ambiguity remains. The primary risk is the content migration — both language files must be migrated in parallel with zero entry loss.

The LoveIt shortcode pattern is well-established (admonition.html, link.html, typeit.html are working examples in the theme). The correct approach for body content is `.Inner | .Page.RenderString` to allow markdown inside the shortcode body.

**Primary recommendation:** Implement in 3 sequential tasks: (1) create the shortcode template and SCSS, (2) migrate the English content file, (3) migrate the Portuguese content file. Each task is independently verifiable by running `hugo server` and inspecting the output.

---

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Hugo Extended | 0.153.2 | Static site generator; shortcode rendering | Project-locked (CLAUDE.md); extended required for SCSS |
| LoveIt theme | 0.2.X | SCSS variable system, layout inheritance | Project-locked (CLAUDE.md); submodule |
| SCSS | — | Styling; all new styles go in `_reading-list.scss` | Project-locked (CLAUDE.md) |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Hugo Go templating | built-in | Shortcode HTML template authoring | All shortcode templates |
| Font Awesome 5+ | loaded by theme | Icon library (reserved for Phase 3 star ratings) | Not used in Phase 2 |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Single `{{< book >}}` shortcode | Type-specific shortcodes per content type | Single shortcode preferred — simpler, extensible via `type` parameter; type-specific variants add files with no benefit for Phase 2 |
| `.Inner` for description | Separate `description` parameter | `.Inner` preserves multi-paragraph markdown; a single-line parameter would strip formatting |

**Installation:** No new packages. All dependencies already present.

---

## Architecture Patterns

### File Locations

```
layouts/shortcodes/book.html         # New — shortcode template
assets/css/_reading-list.scss        # Existing — append shortcode styles, remove card styles
content/my-reading-list/index.en.md  # Existing — full content rewrite to shortcode syntax
content/my-reading-list/index.pt-br.md  # Existing — parallel rewrite (translated)
```

### Pattern 1: Hugo Named-Parameter Shortcode with Inner Body

Hugo shortcodes in `layouts/shortcodes/` are invoked from Markdown content. Named parameters are accessed via `.Get "paramname"`. The body between opening and closing tags is accessed via `.Inner`. To allow Markdown in the body, use `.Inner | .Page.RenderString`.

```html
{{- /* layouts/shortcodes/book.html */ -}}
{{- $title  := .Get "title" -}}
{{- $author := .Get "author" -}}
{{- $link   := .Get "link" -}}
{{- $type   := .Get "type" | default "book" -}}
{{- $inner  := .Inner | .Page.RenderString -}}
<div class="book-entry book-entry--{{ $type }}">
    <div class="book-entry__header">
        <h4 class="book-entry__title">
            <a href="{{ $link }}" target="_blank" rel="noopener noreferrer">{{ $title }}</a>
        </h4>
        <span class="book-entry__author">{{ $author }}</span>
    </div>
    <div class="book-entry__description">
        {{- $inner -}}
    </div>
    {{- /* .book-entry__rating slot reserved for Phase 3 — absent in Phase 2 */ -}}
</div>
```

**Confidence:** HIGH — pattern verified against `admonition.html` in LoveIt theme which uses the identical `.Inner | .Page.RenderString` approach with named parameters.

**Shortcode call in Markdown:**
```markdown
{{< book title="Clean Code" author="Robert C. Martin" link="https://amzn.to/3f4tfO8" type="book" >}}
Read this five years into my career. Changed everything about how I approached readability, testing, and maintenance.
{{< /book >}}
```

### Pattern 2: SCSS Append with Dark Mode Tripling

Established in Phase 1. All new styles go in `assets/css/_reading-list.scss`. Each new selector requires three declarations: light (default), `[theme=dark]`, and `@media (prefers-color-scheme: dark) { [theme=auto] ... }`.

**Confidence:** HIGH — pattern in existing `_reading-list.scss` lines 1–231, enforced by Phase 1 CONTEXT.md D-05/D-06.

### Pattern 3: SCSS Variable-Only Styling

No raw hex values or CSS `var()`. All color and font references use SCSS variables from `themes/LoveIt/assets/css/_variables.scss`, resolved at build time.

Key variables for Phase 2:
- `$global-font-color` / `$global-font-color-dark` — body text
- `$global-font-secondary-color` / `$global-font-secondary-color-dark` — author line, tier labels
- `$single-link-color` / `$single-link-color-dark` — book title link
- `$single-link-hover-color` / `$single-link-hover-color-dark` — book title hover
- `$global-background-color` / `$global-background-color-dark` — never applied to book entries (no card background)
- `$global-border-color` / `$global-border-color-dark` — h2 border-bottom only

**Confidence:** HIGH — verified against `_variables.scss` lines 1–102.

### Anti-Patterns to Avoid

- **Using `.Inner` without `.Page.RenderString`:** `.Inner` returns raw markdown string. Without `| .Page.RenderString`, paragraph text will not be converted to `<p>` tags, breaking description layout.
- **Using positional parameters (`.Get 0`):** Named parameters (`.Get "title"`) are required for readability and maintainability. The shortcode has 4 required parameters — positional access is unworkable.
- **Adding card styles to shortcode entries:** Phase 1 `ul > li` card styles (background, border, border-radius, box-shadow, hover transform) must be removed, not preserved. Book entries are typography-only.
- **Leaving Phase 1 card selectors in place:** The old `ul > li` selectors become inert once markdown content is replaced, but they must be cleaned up in the same PR to keep SCSS minimal (per UI-SPEC).
- **Migrating only the English file:** Both `index.en.md` and `index.pt-br.md` must be migrated in parallel. Portuguese content is semantically identical, just translated.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Dark mode SCSS | Custom `prefers-color-scheme` logic | LoveIt `[theme=dark]` + `@media` pattern from Phase 1 | Already established, consistent with rest of site |
| Content rendering in shortcode body | Manual HTML in shortcode body | `.Inner \| .Page.RenderString` | Hugo built-in Markdown-to-HTML pipeline; handles paragraphs, emphasis, links correctly |

**Key insight:** Hugo's shortcode system is purpose-built for exactly this pattern — structured parameters + markdown body content. No custom rendering pipeline needed.

---

## Content Inventory

### English file: `content/my-reading-list/index.en.md`

**Existing sections and entry count:**

| Section | Tier labels | Entry count |
|---------|-------------|-------------|
| Engineering Books | Essential (3), Highly Recommended (4) | 7 |
| Management Books | Essential (3), Highly Recommended (1) | 4 |
| Newsletters > Tech Leadership | — | 3 |
| Newsletters > Software Engineering | — | 1 |
| Podcasts > Tech Leadership | — | 1 |
| Podcasts > Software Engineering | — | 3 |
| **Total** | | **19** |

**Migration target tier labels:**

| Current | Target |
|---------|--------|
| Essential | Must Read |
| Highly Recommended | Recommended |
| (none — third tier absent currently) | Worth Your Time (available for future entries) |

**Intro paragraph:** Two paragraphs starting "I've always believed that **knowledge travels faster than code**..." — preserved verbatim.

**Currently Reading section:** New section, not present in current file. Italo will supply 1-3 entries. Plan task should include a placeholder with one representative entry as an example to show the pattern.

**Anchor nav:** The existing `* [Engineering Books](#engineering-books)` bullet list at the top — Phase 3 will replace this with proper anchor nav (LAYOUT-03). For Phase 2, the anchor nav bullet list is preserved as-is in Markdown above the Currently Reading section.

**Newsletters sub-sections (`### Tech Leadership`, `### Software Engineering`):** These are existing `h3` sub-headings within Newsletters. They are structural sub-categories, not tier labels. The new tier label `h3` styling (all-caps, secondary color) will visually differentiate tier labels. However, the Newsletters and Podcasts sub-section headings will also receive the same `h3` styling since they use the same HTML element — this is acceptable: sub-category headings benefit from the same subdued, secondary-text treatment. **No conflict.**

### Portuguese file: `content/my-reading-list/index.pt-br.md`

Structurally identical to English. All entries exist, all descriptions are translated. Tier labels are currently "Essenciais" / "Altamente Recomendados" — migrate to "Must Read" / "Recommended" / "Worth Your Time" (tier labels remain in English as a deliberate design choice — they are editorial vocabulary, not UI chrome, and Italo's Portuguese content already uses English-origin tech vocabulary throughout).

---

## Common Pitfalls

### Pitfall 1: `.Inner` Whitespace and Paragraph Wrapping

**What goes wrong:** `.Inner | .Page.RenderString` with a blank line before/after content can produce unexpected `<p>` wrapping or an extra leading newline in the rendered HTML.
**Why it happens:** Hugo processes the inner content as a mini-document. Leading/trailing whitespace matters.
**How to avoid:** Use `{{- $inner := trim .Inner "\n" | .Page.RenderString -}}` to strip leading/trailing newlines before rendering. The admonition shortcode pattern uses this approach.
**Warning signs:** Description appears with an extra blank line above it, or description text is wrapped in a `<p>` that has unexpected margin.

### Pitfall 2: Phase 1 Card Styles Silently Remaining

**What goes wrong:** After migrating content to use shortcodes, the old `ul > li` card selectors in `_reading-list.scss` appear to be gone because there are no more `ul > li` elements inside `.single .content` matching the card pattern — but the selectors remain in the CSS output, bloating it silently.
**Why it happens:** SCSS selectors are always compiled whether or not matching elements exist in HTML.
**How to avoid:** Explicitly delete the Phase 1 card selectors (identified in UI-SPEC "Styles to remove / replace from Phase 1" section) in the same PR as the shortcode introduction.
**Warning signs:** Running `hugo --gc --minify` and checking CSS output; card transition/transform rules visible in DevTools with no matching elements.

### Pitfall 3: Multi-Language File Divergence

**What goes wrong:** English file is migrated to shortcodes; Portuguese file is not updated, causing the Portuguese reading list to show the old raw list format.
**Why it happens:** Two separate files, easy to forget the second.
**How to avoid:** Treat both files as a single logical unit. Plan tasks must explicitly include both files.
**Warning signs:** `/pt-br/minha-lista-de-leitura/` showing bullet list while `/my-reading-list/` shows shortcode layout.

### Pitfall 4: `h3` Style Conflict Between Tier Labels and Sub-Category Headings

**What goes wrong:** Newsletters and Podcasts have `### Tech Leadership` / `### Software Engineering` sub-headings. The new tier label h3 styling (all-caps, secondary color, small size) will apply to these sub-headings too.
**Why it happens:** Both structural sub-headings and tier labels use `h3` elements. There is no CSS class to differentiate them.
**How to avoid:** Accept the collision — sub-category headings styled as secondary metadata is visually appropriate. They are organizational labels, not primary navigation. This is a known design decision, not a bug.
**Warning signs:** If sub-category headings look unexpectedly small — expected behavior. Not a bug.

### Pitfall 5: Shortcode Body Not Rendering as HTML

**What goes wrong:** Description text appears as raw markdown (e.g., `**bold**` instead of **bold**) or as plain text without paragraph tags.
**Why it happens:** Using `.Inner` without `.Page.RenderString`.
**How to avoid:** Always use `{{- $inner := .Inner | .Page.RenderString -}}` and output `{{- $inner -}}` (not `{{ .Inner }}`).
**Warning signs:** Bold/italic markdown markers visible as asterisks in browser output.

---

## Code Examples

### Shortcode Template (from UI-SPEC and LoveIt admonition pattern)

```html
{{- /* layouts/shortcodes/book.html */ -}}
{{- /* Parameters: title (required), author (required), link (required), type (required), rating (reserved Phase 3) */ -}}
{{- $title  := .Get "title" -}}
{{- $author := .Get "author" -}}
{{- $link   := .Get "link" -}}
{{- $type   := .Get "type" | default "book" -}}
{{- $inner  := trim .Inner "\n" | .Page.RenderString -}}
<div class="book-entry book-entry--{{ $type }}">
    <div class="book-entry__header">
        <h4 class="book-entry__title">
            <a href="{{ $link }}" target="_blank" rel="noopener noreferrer">{{ $title }}</a>
        </h4>
        <span class="book-entry__author">{{ $author }}</span>
    </div>
    <div class="book-entry__description">
        {{- $inner -}}
    </div>
    {{- /* .book-entry__rating slot reserved for Phase 3 — absent in Phase 2 */ -}}
</div>
```

### SCSS Additions for Shortcode (from UI-SPEC Shortcode SCSS Contract)

```scss
// Book entry — typography-driven, no cards
.single .content .book-entry {
    margin-bottom: 24px; // lg
}

.single .content .book-entry__title {
    font-size: 1.125rem;   // 18px
    font-weight: 600;
    margin-bottom: 4px; // xs
    line-height: 1.3;
}

.single .content .book-entry__title a {
    color: $single-link-color;
    text-decoration: none;
    transition: color 0.2s ease;
}

.single .content .book-entry__title a:hover {
    color: $single-link-hover-color;
}

.single .content .book-entry__author {
    font-size: 0.8125rem;  // 13px — secondary metadata
    color: $global-font-secondary-color;
    margin-bottom: 8px; // sm
    display: block;
}

.single .content .book-entry__description {
    font-size: 1rem;       // 16px body
    line-height: 1.5;
    color: $global-font-color;
}

// Tier labels (h3 within category sections)
.single .content h3 {
    font-size: 0.8125rem;  // 13px
    font-weight: 600;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: $global-font-secondary-color;
    margin-top: 32px; // xl
    margin-bottom: 12px;
}
```

Dark mode and auto-theme additions follow the existing `[theme=dark]` / `@media (prefers-color-scheme: dark) [theme=auto]` pattern from Phase 1.

### SCSS Selectors to REMOVE from Phase 1

The following selectors in `_reading-list.scss` target the old card pattern and must be deleted:

```scss
// REMOVE these Phase 1 selectors:
.single .content > ul > li { ... }          // card background, border, border-radius, box-shadow, transition
.single .content > ul > li:hover { ... }    // transform, box-shadow, border-color
.single .content > ul > li strong { ... }
.single .content > ul > li a { ... }
.single .content > ul > li a:hover { ... }

// REMOVE their dark/auto equivalents:
[theme=dark] .single .content > ul > li { ... }
[theme=dark] .single .content > ul > li:hover { ... }
// ... and all corresponding [theme=auto] / @media variants
```

### Content Migration Example — One Engineering Books Entry

```markdown
### Must Read

{{< book title="Clean Code" author="Robert C. Martin" link="https://amzn.to/3f4tfO8" type="book" >}}
Read this five years into my career. Changed everything about how I approached readability, testing, and maintenance. Stop writing code for compilers; write it for humans.
{{< /book >}}

{{< book title="Domain-Driven Design" author="Eric Evans" link="https://amzn.to/32NQx63" type="book" >}}
The book that taught me to speak business language in code. Ubiquitous language and bounded contexts aren't buzzwords—they're how you survive complex domains without losing your mind.
{{< /book >}}
```

### Currently Reading Section Skeleton

```markdown
## Currently Reading

{{< book title="[Title Here]" author="[Author Here]" link="[URL Here]" type="book" >}}
[Why I'm reading this — personal note.]
{{< /book >}}
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Raw Markdown `* [Title](url) - description` bullet list | Hugo shortcode `{{< book >}}` with named parameters | Phase 2 | Structured HTML, extensible for Phase 3 ratings |
| Card styling (border, border-radius, box-shadow, hover) | Typography-only (no card, no hover effect) | Phase 2 | Cleaner, editorial appearance |
| Inconsistent tier labels (Essential / Highly Recommended) | Standardized: Must Read / Recommended / Worth Your Time | Phase 2 | Consistent vocabulary across all categories |
| No Currently Reading section | Currently Reading at top of page | Phase 2 | Prominent display of active reading |

**Deprecated/outdated in this phase:**
- Phase 1 `ul > li` card SCSS selectors: replaced by `.book-entry` shortcode selectors
- "Essential" / "Highly Recommended" / "Essenciais" / "Altamente Recomendados" tier labels: replaced by standardized English vocabulary

---

## Environment Availability

Step 2.6: All dependencies are the project's own code. No external tools, services, or CLIs beyond Hugo (already verified in Phase 1). This phase is purely code/config changes.

Skipped: No external dependency audit needed.

---

## Validation Architecture

nyquist_validation is explicitly `false` in `.planning/config.json`. This section is skipped.

---

## Open Questions

1. **Currently Reading entries — who supplies initial content?**
   - What we know: D-04 says section is manually curated; D-06 says 1-3 entries.
   - What's unclear: The plan task cannot populate this with real entries without Italo's input. The current `index.en.md` has no existing "currently reading" entries to migrate.
   - Recommendation: Task should add 1 placeholder entry (or the plan comment should note that Italo replaces it post-implementation). The skeleton shown in Code Examples above is sufficient for the task.

2. **Anchor nav bullet list — keep or remove in Phase 2?**
   - What we know: The existing `* [Engineering Books](#engineering-books)` anchor nav at the top of both files is styled by Phase 1 CSS as anchor nav pills. LAYOUT-03 (anchor nav redesign) is Phase 3.
   - What's unclear: Does the anchor nav list need to be updated to include "Currently Reading" as a new anchor in Phase 2?
   - Recommendation: Add `* [Currently Reading](#currently-reading)` as the first anchor nav item, and update the anchor list to use the new section order. This is a one-line change per file and falls within Phase 2 scope as part of content structure changes.

---

## Sources

### Primary (HIGH confidence)

- LoveIt theme `layouts/shortcodes/admonition.html` — `.Inner | .Page.RenderString` pattern, named parameter pattern
- LoveIt theme `assets/css/_variables.scss` — all SCSS variable names and values verified
- `assets/css/_reading-list.scss` — Phase 1 selector inventory, Phase 2 removal targets
- `content/my-reading-list/index.en.md` — full content inventory, entry count, current tier labels
- `content/my-reading-list/index.pt-br.md` — Portuguese content parity confirmed
- `.planning/phases/02-layout-and-content/02-CONTEXT.md` — all implementation decisions D-01 through D-11
- `.planning/phases/02-layout-and-content/02-UI-SPEC.md` — HTML structure, SCSS contract, typography scale, spacing scale, color assignments
- `.planning/REQUIREMENTS.md` — LAYOUT-01, LAYOUT-02, CONT-01–04 definitions
- Hugo documentation (training data, HIGH confidence for core shortcode API — `.Get`, `.Inner`, `.Page.RenderString` are stable APIs since Hugo 0.60+)

### Secondary (MEDIUM confidence)

None required — all research domains resolved by primary sources.

### Tertiary (LOW confidence)

None.

---

## Metadata

**Confidence breakdown:**
- Shortcode API pattern: HIGH — verified against working theme shortcodes in the same repo
- SCSS variables: HIGH — verified from source file
- Content inventory: HIGH — direct read of both source files
- Migration approach: HIGH — all decisions pre-resolved in CONTEXT.md and UI-SPEC.md

**Research date:** 2026-04-03
**Valid until:** Stable architecture — valid for 90 days (Hugo and LoveIt are not changing rapidly)
