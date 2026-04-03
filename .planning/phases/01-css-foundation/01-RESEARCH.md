# Phase 01: CSS Foundation - Research

**Researched:** 2026-04-03
**Domain:** Hugo/LoveIt SCSS customization, dark mode theming, CI/CD pipeline verification
**Confidence:** HIGH — all findings based on direct codebase inspection of source files

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** Replace all broken `var()` references with LoveIt's actual SCSS variables. LoveIt uses compiled SCSS, not CSS custom properties — the current `var(--header-title-color)` etc. resolve to nothing. Map each broken reference to the closest LoveIt SCSS variable or hardcode theme-aware values with `[theme=dark]` overrides.
- **D-02:** Do not define new CSS custom properties. Use LoveIt's existing SCSS variable system to stay consistent with the theme.
- **D-03:** Create a dedicated `assets/css/_reading-list.scss` partial for all reading list styles. Import it from `_custom.scss`. This keeps reading list styles isolated from the existing logo/home styles in `_custom.scss`.
- **D-04:** Remove all `<style>` blocks from both `index.en.md` and `index.pt-br.md` completely. Zero inline styles should remain.
- **D-05:** Follow the `[theme=dark] &` SCSS pattern already established in `_custom.scss` for logo handling.
- **D-06:** Also handle `[theme=auto]` with `@media (prefers-color-scheme: dark)` — same pattern as the existing logo dark mode code in `_custom.scss`.

### Claude's Discretion

- Exact color values for light/dark mode (map to closest LoveIt equivalents)
- Whether to use SCSS nesting or flat selectors
- How to handle the `<style>` extraction (one commit or incremental)

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope.
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| FOUND-01 | Broken CSS custom property references (`var(--header-title-color)` etc.) are fixed to use actual LoveIt theme variables | Variable mapping table below; all broken refs identified and mapped |
| FOUND-02 | Inline `<style>` blocks extracted from both language markdown files into `_custom.scss` | Style block is identical in both files; extract to `_reading-list.scss`, import from `_custom.scss` |
| FOUND-03 | Dark mode works correctly with `[theme=dark] &` SCSS selectors for all new styles | Pattern confirmed in `_custom.scss` and `_page/_single.scss`; dark variable values documented |
| LAYOUT-04 | Layout is mobile-responsive and works with LoveIt theme breakpoints | LoveIt breakpoints documented: 680px (mobile toggle), 960px, 1280px, 1440px |
</phase_requirements>

---

## Summary

Phase 1 is a pure cleanup operation: extract ~130 lines of inline `<style>` from two markdown files and fix 13 broken `var()` references. No design changes, no new features. The root cause is straightforward — the inline styles reference CSS custom properties (`var(--header-title-color)`, `var(--single-link-color)`, `var(--global-border-color)`) that do not exist in LoveIt. The theme compiles SCSS variables to hardcoded hex values and never exposes them as CSS custom properties on `:root`. The properties silently fall back to browser defaults, making the page render with incorrect typography and broken theming in both light and dark mode.

The fix requires three coordinated changes: (1) create `assets/css/_reading-list.scss` with all reading list styles using direct SCSS variable references, (2) add `[theme=dark] .reading-list-content` selector blocks for every color that must adapt, (3) mirror the auto-theme `@media (prefers-color-scheme: dark) { [theme=auto] ... }` pattern already established in `_custom.scss`, then remove all `<style>` blocks from both language markdown files.

CI/CD validation is already in good shape: both `pages.yml` and `pr-checks.yml` use `extended: true`. The only actionable CI concern is the `resources/` cache keyed on `**/*.md` — this cache will correctly invalidate when the markdown files are changed (removing the `<style>` blocks), so SCSS recompilation will happen on the first CI run after the change.

**Primary recommendation:** Create `_reading-list.scss` with the complete translated style set using LoveIt SCSS variables and `[theme=dark]` nesting, import it from `_custom.scss`, then delete the `<style>` blocks from both `.md` files in a single commit.

---

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Hugo Extended | 0.153.2 (prod), 0.139.4 (PR checks) | SCSS compilation pipeline | Required to process `_reading-list.scss`; already configured with `extended: true` in both workflows |
| LoveIt theme | 0.2.X (git submodule) | SCSS variable system, dark mode selectors | Source of all color tokens; `_variables.scss` is the single source of truth |
| SCSS (Sass) | Bundled with Hugo Extended | Stylesheet language for `_reading-list.scss` | Already used by `_custom.scss` and `_override.scss` |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| PostCSS | Theme package.json | CSS post-processing in CI | Already wired in CI; no change needed |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| SCSS with `[theme=dark]` nesting | CSS custom properties on `:root` | Custom properties would work but violate D-02 (don't add new custom properties) and diverge from LoveIt's compilation model |
| Single `_reading-list.scss` | Inline styles kept in markdown | Inline styles violate D-04, cause dual-file maintenance, and break dark mode |

---

## Architecture Patterns

### Recommended Project Structure

```
assets/css/
├── _override.scss       # Existing: font imports, SCSS variable overrides
├── _custom.scss         # Existing: logo dark mode + NEW @import for reading list
└── _reading-list.scss   # NEW: all reading list page styles
```

### Pattern 1: SCSS Dark Mode (LoveIt Standard)

**What:** Color rules are written twice — once for light (default), once nested under `[theme=dark]` or `[theme=auto]` + media query.

**When to use:** Every color property in `_reading-list.scss` that differs between light and dark.

**Example (from `assets/css/_custom.scss`, line 27-38):**
```scss
// Light mode default
.header-title .logo {
    filter: none;
}

// Dark theme via JS toggle
[theme=dark] .header-title .logo {
    filter: invert(1) brightness(1.2);
}

// Auto theme via OS preference
[theme=auto] .header-title .logo {
    filter: none;
}

@media (prefers-color-scheme: dark) {
    [theme=auto] .header-title .logo {
        filter: invert(1) brightness(1.2);
    }
}
```

The same two-block pattern must be applied to every color in `_reading-list.scss`.

### Pattern 2: SCSS Nesting with `[theme=dark] &`

**What:** Nest the dark variant inside the rule using `&` back-reference, keeping light and dark rules co-located.

**When to use:** When the SCSS nesting style is preferred (Claude's Discretion). This is the pattern used inside `themes/LoveIt/assets/css/_page/_single.scss`.

**Example (from `_single.scss`, line 94-97):**
```scss
h2, h3, h4, h5, h6 {
    font-weight: bold;

    [theme=dark] & {
        font-weight: bolder;
    }
}
```

Either the flat selector pattern (from `_custom.scss`) or the nested `[theme=dark] &` pattern (from `_single.scss`) is valid. Pick one and apply consistently throughout `_reading-list.scss`.

### Pattern 3: SCSS Import Chain

**What:** `_reading-list.scss` must be `@import`-ed from `_custom.scss` so Hugo's SCSS pipeline picks it up.

**Example (to add to the bottom of `_custom.scss`):**
```scss
@import "reading-list";
```

Hugo's SCSS importer strips the leading underscore and `.scss` extension automatically.

### Anti-Patterns to Avoid

- **`var(--header-title-color)` in SCSS files:** LoveIt exposes only font/size tokens as CSS custom properties (verified in `_core/_variables.scss`). Color tokens are never on `:root`. Using `var(--header-title-color)` compiles to a literal `var(--header-title-color)` string that resolves to empty at runtime.
- **Scoping reading list styles to `.single .content`:** The `.single .content` selector already has theme rules from `_single.scss`. Adding more rules at the same specificity will produce hard-to-debug cascade conflicts. Use a scoped class like `.reading-list-content` on the page instead, or rely on LoveIt's existing `.content` scoping and write overrides at a higher specificity only where necessary.
- **Leaving `<style>` in only one language file:** Both `index.en.md` and `index.pt-br.md` contain identical `<style>` blocks. Both must be cleared in the same change.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Dark mode theming | Custom JavaScript to toggle colors | LoveIt's `[theme=dark]` SCSS selector system | LoveIt already handles the JS toggle; CSS just needs to be scoped correctly |
| Mobile breakpoints | Custom media queries at arbitrary widths | LoveIt's established breakpoints (680px, 960px, 1280px, 1440px) | Consistency with the rest of the site's responsive behavior |
| Color tokens | Hardcoded hex values unrelated to theme | LoveIt SCSS variables (`$single-link-color`, `$global-border-color`, etc.) | Variables ensure colors stay consistent with the theme; if LoveIt is updated, colors update automatically |

---

## Broken CSS Variable Mapping

This is the complete list of broken references in both markdown files, with the correct SCSS replacement for light and dark modes.

| Broken `var()` Reference | Light Mode SCSS Value | Dark Mode SCSS Value | Source Variable |
|-------------------------|----------------------|----------------------|-----------------|
| `var(--header-title-color)` | `$global-font-color` → `#161209` | `$global-font-color-dark` → `#a9a9b3` | `_variables.scss` line 23-24 |
| `var(--global-border-color)` | `$global-border-color` → `#f0f0f0` | `$global-border-color-dark` → `#363636` | `_variables.scss` line 39-40 |
| `var(--global-background-color)` | `$global-background-color` → `#fff` | `$global-background-color-dark` → `#292a2d` | `_variables.scss` line 19-20 |
| `var(--single-link-color)` | `$single-link-color` → `#2d96bd` | `$single-link-color-dark` → `#55bde2` | `_variables.scss` line 84-85 |

These four variables cover all 13 broken references in the current `<style>` block. The inline style block references `var(--header-title-color)` 4 times, `var(--global-border-color)` 4 times, `var(--global-background-color)` 3 times, and `var(--single-link-color)` 3 times (counting hover state uses).

---

## LoveIt Breakpoints (for LAYOUT-04)

The current inline style uses `@media (max-width: 768px)`. LoveIt's actual breakpoints from `_core/_media.scss`:

| Breakpoint | What Changes |
|------------|-------------|
| 1440px | `.page` width: 60% → narrower |
| 1280px | `.page` width: 52% |
| 960px | TOC hides, `.page` width: 80% |
| **680px** | **Mobile header toggle: desktop nav hides, mobile nav shows; `.page` width: 100%** |

The reading list's `@media (max-width: 768px)` in the current inline style does not match any LoveIt breakpoint. For LAYOUT-04, the mobile breakpoint in `_reading-list.scss` should use **680px** to align with LoveIt's mobile header switch. This ensures the reading list layout changes at the same moment the rest of the page goes mobile.

---

## Common Pitfalls

### Pitfall 1: CSS Custom Properties That Don't Exist

**What goes wrong:** `var(--header-title-color)` and similar references in inline styles silently resolve to empty string. No build error. Page renders with browser default colors — black text on white, losing all theming in both light and dark mode.

**Why it happens:** LoveIt exposes only 10 CSS custom properties on `:root` (font/size tokens only, confirmed in `themes/LoveIt/assets/css/_core/_variables.scss`). Color variables are SCSS-only, compiled to hardcoded hex at build time. They are never available at runtime via `var()`.

**How to avoid:** Use SCSS variables directly in `_reading-list.scss`. The SCSS file is compiled by Hugo Extended — variables resolve at build time to hardcoded hex values with `[theme=dark]` selector variants for the dark hex.

**Warning signs:** DevTools shows `var(--header-title-color)` computing to an empty string; elements render in browser default colors regardless of theme toggle.

### Pitfall 2: `resources/` Cache Serving Stale CSS

**What goes wrong:** Both CI workflows cache the `resources/` directory keyed on `hashFiles('**/*.md')`. If the cache is hit, Hugo skips SCSS recompilation and serves whatever was last compiled. New styles in `_reading-list.scss` would not appear in the deployed build.

**Why it happens:** The cache key includes `**/*.md` — removing the `<style>` block from both `.md` files will change the hash, correctly busting the cache. However, if only `_reading-list.scss` is changed (without touching any `.md` file), the cache key does not change and stale CSS is served.

**How to avoid:** The planned change removes the `<style>` blocks from both `.md` files in the same commit that creates `_reading-list.scss`. This guarantees the `**/*.md` hash changes, cache busts, and SCSS recompiles correctly. If iterating on `_reading-list.scss` alone after the initial change, the cache key will not change — verify by checking the CI build log confirms SCSS was recompiled, not served from cache.

**Warning signs:** Styles look correct locally (`hugo server`) but wrong in the PR preview or deployed site; build log shows "Using cached resources."

### Pitfall 3: Only Updating One Language File

**What goes wrong:** Both `index.en.md` and `index.pt-br.md` contain identical `<style>` blocks. Removing the block from only the English file leaves the Portuguese file with the broken inline styles still active. Worse — the Portuguese page will still render with broken `var()` references even after the fix is deployed.

**Why it happens:** Two separate files, easy to forget the second.

**How to avoid:** Remove the `<style>` block from both files in the same commit. The English and Portuguese `<style>` blocks are byte-for-byte identical (lines 8-137 in both files).

### Pitfall 4: Selector Specificity Conflict with `.single .content`

**What goes wrong:** The theme's `_single.scss` already defines styles for `.single .content > h2`, `.single .content > h3`, etc. If `_reading-list.scss` also defines rules for `.content h2` with the same or lower specificity, the cascade order determines which rule wins — and it may not be the right one.

**Why it happens:** `.content` is a theme-owned class on the page content wrapper. Writing flat `.content h2` rules in a custom file creates an implicit dependency on load order.

**How to avoid:** Either (a) use `.single .content` as the base selector in `_reading-list.scss` (matching theme specificity) and rely on cascade order with the `@import` at the bottom of `_custom.scss`, or (b) scope rules to a page-specific class. Given Phase 1's goal is a direct extraction without layout changes, option (a) is sufficient — the extracted rules are written after the theme's own rules, so same-specificity overrides apply as expected.

---

## Code Examples

### Correct Pattern: SCSS Variable + Dark Mode Override

```scss
// Source: Direct extraction from existing inline style, with var() replaced by SCSS variables
// Light mode (default)
.single .content h2 {
    font-size: 2rem;
    margin-top: 3rem;
    margin-bottom: 1.5rem;
    padding-bottom: 0.75rem;
    border-bottom: 3px solid $global-border-color;
    color: $global-font-color;
}

// Dark mode override
[theme=dark] .single .content h2 {
    border-bottom-color: $global-border-color-dark;
    color: $global-font-color-dark;
}

// Auto theme (OS preference)
@media (prefers-color-scheme: dark) {
    [theme=auto] .single .content h2 {
        border-bottom-color: $global-border-color-dark;
        color: $global-font-color-dark;
    }
}
```

### Correct Import in `_custom.scss`

```scss
// Add at the bottom of assets/css/_custom.scss
@import "reading-list";
```

### Mobile Breakpoint (Aligned with LoveIt)

```scss
// Use 680px to match LoveIt's mobile header breakpoint (_core/_media.scss line 45)
@media (max-width: 680px) {
    .single .content h2 {
        font-size: 1.6rem;
    }

    .single .content > ul > li {
        padding: 1.25rem;
    }

    .single .content > ul:first-of-type {
        flex-direction: column;
    }

    .single .content > ul:first-of-type li a {
        display: block;
        text-align: center;
    }
}
```

### Verify No Broken `var()` References After Build

After removing the `<style>` blocks and creating `_reading-list.scss`, open the deployed page in DevTools:
1. Inspect any `h2` in the reading list
2. Check Computed styles — no property should show `var(--header-title-color)` or similar as its value
3. Toggle dark mode using the LoveIt moon icon and verify `h2` color changes

---

## CI/CD Verification (from direct workflow inspection)

Both workflows already use `extended: true`:

| Workflow | File | Hugo Version | Extended |
|----------|------|-------------|---------|
| Production | `.github/workflows/pages.yml` | 0.153.2 | `extended: true` (line 45) |
| PR checks | `.github/workflows/pr-checks.yml` | 0.139.4 | `extended: true` (line 29) |

No CI changes are needed for this phase. The SCSS pipeline is already correctly configured.

**Cache key note:** The `resources/` cache in both workflows uses `key: ${{ runner.os }}-hugo-resources-${{ hashFiles('**/*.md') }}`. Removing `<style>` blocks from the markdown files will change this hash, ensuring a clean SCSS recompile on the first CI run.

---

## Environment Availability

Step 2.6: SKIPPED — this phase makes no use of external tools beyond Hugo Extended (already verified above in both workflows with `extended: true`). No new external dependencies are introduced.

---

## Validation Architecture

Step 4: SKIPPED — `workflow.nyquist_validation` is explicitly `false` in `.planning/config.json`.

---

## Open Questions

1. **Scoping to `.single .content` vs a page-specific class**
   - What we know: Current inline style uses `.content` as the root selector. LoveIt's `_single.scss` also defines `.single .content` rules. Both selectors target the same element.
   - What's unclear: Whether to use `.single .content` (matches theme specificity) or introduce a page-specific class via a custom layout template.
   - Recommendation: Use `.single .content` for Phase 1 (direct extraction, no layout changes). Phase 2 can introduce a custom layout template with a scoped class if needed.

2. **SCSS nesting style**
   - What we know: `_custom.scss` uses flat `[theme=dark] .selector` (no nesting). `_single.scss` uses nested `[theme=dark] &`. Both are valid SCSS.
   - What's unclear: Which style to use in the new `_reading-list.scss`.
   - Recommendation: Use the flat selector pattern from `_custom.scss` since that is the established pattern in the project's custom CSS layer. The nested style is a LoveIt-internal pattern.

---

## Sources

### Primary (HIGH confidence)

- Direct inspection: `themes/LoveIt/assets/css/_core/_variables.scss` — confirmed: only font/size tokens are CSS custom properties; no color tokens on `:root`
- Direct inspection: `themes/LoveIt/assets/css/_variables.scss` — all SCSS color variables and their light/dark pairs
- Direct inspection: `assets/css/_custom.scss` — established `[theme=dark]` + `[theme=auto]` pattern
- Direct inspection: `themes/LoveIt/assets/css/_page/_single.scss` — `.content` class scoping and dark mode nesting pattern
- Direct inspection: `themes/LoveIt/assets/css/_core/_media.scss` — LoveIt breakpoints (680px, 960px, 1280px, 1440px)
- Direct inspection: `content/my-reading-list/index.en.md` lines 8-137 — complete inline `<style>` block, all broken `var()` references
- Direct inspection: `content/my-reading-list/index.pt-br.md` lines 8-137 — confirmed identical `<style>` block
- Direct inspection: `.github/workflows/pages.yml` line 45 — `extended: true` confirmed
- Direct inspection: `.github/workflows/pr-checks.yml` line 29 — `extended: true` confirmed
- Direct inspection: `.planning/research/PITFALLS.md` — comprehensive pre-existing pitfall analysis

### Secondary (MEDIUM confidence)

- `themes/LoveIt/assets/css/_core/_base.scss` — confirms LoveIt color theming is SCSS-compiled via `[theme=dark]` selectors, not runtime CSS custom properties

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — directly verified in source files
- Architecture patterns: HIGH — extracted from actual theme SCSS and existing `_custom.scss`
- Pitfalls: HIGH — verified against direct file inspection; variable mapping confirmed against `_variables.scss`
- CI/CD: HIGH — both workflows read and `extended: true` confirmed in both

**Research date:** 2026-04-03
**Valid until:** 2026-07-03 (stable tech — Hugo and LoveIt version pinned; low churn)
