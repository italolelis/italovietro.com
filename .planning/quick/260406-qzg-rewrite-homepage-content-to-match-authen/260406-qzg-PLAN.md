---
phase: quick
plan: 260406-qzg
type: execute
wave: 1
depends_on: []
files_modified:
  - content/_index.en.md
  - content/_index.pt-br.md
  - config.toml
  - assets/css/_custom.scss
autonomous: true
requirements: [D-01, D-02, D-03, D-04, D-05, D-06, D-07, D-08]

must_haves:
  truths:
    - "Homepage bio tells thematic stories grouped by lessons, not a role-by-role resume"
    - "Subtitle is personal and memorable with no emojis, displayed via TypeIt animation"
    - "No inline styles remain in homepage content files"
    - "Both EN and PT-BR versions reflect the same structure and voice"
  artifacts:
    - path: "content/_index.en.md"
      provides: "Rewritten English homepage with thematic storytelling"
      contains: "home-content"
    - path: "content/_index.pt-br.md"
      provides: "Rewritten Portuguese homepage matching EN structure"
      contains: "home-content"
    - path: "config.toml"
      provides: "Updated subtitles for both languages"
    - path: "assets/css/_custom.scss"
      provides: "Homepage intro paragraph styles replacing inline styles"
      contains: ".home-intro"
  key_links:
    - from: "content/_index.en.md"
      to: "assets/css/_custom.scss"
      via: "CSS class on intro paragraph"
      pattern: "class=\"home-intro\""
    - from: "config.toml"
      to: "LoveIt theme TypeIt animation"
      via: "subtitle config with typeit = true"
      pattern: "typeit = true"
---

<objective>
Rewrite homepage content to match the authentic, direct voice from the reading list page. Replace the corporate resume-style bio with thematic storytelling, update the subtitle to something personal and memorable, and move inline styles to SCSS.

Purpose: The homepage currently reads like a press release. The reading list page has a much better voice -- direct, self-aware, opinionated. Bring that same voice to the homepage so Italo can confidently share it.

Output: Updated EN and PT-BR homepage content, updated config.toml subtitles, homepage-specific SCSS styles.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@content/_index.en.md
@content/_index.pt-br.md
@content/recommended-reading/index.en.md
@config.toml
@assets/css/_custom.scss
</context>

<tasks>

<task type="auto">
  <name>Task 1: Update subtitles and move inline styles to SCSS</name>
  <files>config.toml, assets/css/_custom.scss</files>
  <action>
**config.toml subtitle updates (per D-03, D-04):**
- Line 67 (EN subtitle): Replace `"Engineering Leader 👨‍💼 • Platform Engineering 🚀 • Coffee Lover ☕"` with a personal, memorable subtitle matching the reading list voice. Something direct and self-aware like: `"I build teams, break monoliths, and brew strong coffee"`. No emojis. Keep `typeit = true` on the next line (per D-04).
- Line 122 (PT-BR subtitle): Replace with Portuguese equivalent, same tone. e.g., `"Construo times, quebro monolitos e faco cafe forte"` (use proper accents).

**SCSS homepage styles (per D-08):**
- In `assets/css/_custom.scss`, add a `.home-intro` class BEFORE the `@import "reading-list"` line.
- The class replaces the inline `style="font-size: 1.25rem; color: #666; margin: 1.5rem 0 2.5rem;"` currently on the intro paragraph.
- Style definition:
  ```scss
  .home-intro {
      font-size: 1.25rem;
      color: #666;
      margin: 1.5rem 0 2.5rem;
  }

  [theme=dark] .home-intro {
      color: #aaa;
  }

  @media (prefers-color-scheme: dark) {
      [theme=auto] .home-intro {
          color: #aaa;
      }
  }
  ```
- Note: Adding dark mode support that the inline style lacked -- follows the same `[theme=dark]` pattern already in `_custom.scss` for the logo.
  </action>
  <verify>
    <automated>cd /Users/italovietro/projects/italovietro.com && grep -c "home-intro" assets/css/_custom.scss && grep "subtitle" config.toml | grep -v "#" | head -4</automated>
  </verify>
  <done>Both subtitles updated to personal/memorable text with no emojis, typeit still enabled. `.home-intro` class in SCSS with light/dark mode support. No inline styles referenced.</done>
</task>

<task type="auto">
  <name>Task 2: Rewrite EN and PT-BR homepage content</name>
  <files>content/_index.en.md, content/_index.pt-br.md</files>
  <action>
**Voice reference:** Study `content/recommended-reading/index.en.md` for tone. Notice: first person, direct, opinionated, self-aware humor ("The book that taught me...", "Sounds cheesy, but it works", "Stop writing code for compilers; write it for humans"). Apply this voice to homepage.

**English homepage (`content/_index.en.md`) -- per D-01, D-02, D-05, D-06, D-07:**

Structure (inside existing `<div class="home-content">`):

1. **Title:** Keep `# Hello, I'm Italo Vietro`

2. **Intro paragraph (per D-06):** Replace the inline-styled `<p>` with `<p class="home-intro">`. Rewrite content -- no "architecting the future" press-release language. Something direct about what he does and cares about. One short paragraph. Reference Parloa naturally but not as a sales pitch.

3. **Thematic section (per D-01, D-02):** Replace "Engineering for Scale, Leading for Impact" and "Where I've Made Impact" with 2-3 thematic sections. Group by LESSONS, not companies. Companies become supporting evidence.

   Suggested thematic headings (Claude's discretion on exact wording):
   - Something about building teams/people (lessons from HelloFresh scaling, N26 squad ownership, Urban Sports Club TechHub)
   - Something about systems/architecture (monolith-to-microservices at HelloFresh, platform at Babbel, microservices at Lykon)
   - Something about culture/leadership (RFCs at Lykon, blameless post-mortems, "you build it you run it")

   Each section: 2-3 sentences max. Mention companies as evidence, not as headers. Use the same direct voice as the reading list descriptions.

4. **Cut "What Drives Me" section entirely (per D-07).** The thematic sections already convey this.

5. **"Beyond the Code" section (per D-05):** Keep but tighten. One paragraph max. Keep: homelab, coffee, D&D, family. Cut: the second paragraph about home automation details and aviation (redundant with homelab mention). Make it punchy like the reading list voice.

6. **Keep the `---` horizontal rules** between major sections for visual separation.

7. **Frontmatter:** Update `description` to match new voice (not the current press-release version).

**Portuguese homepage (`content/_index.pt-br.md`):**
- Same structure as English.
- Translate with natural Brazilian Portuguese (informal "voce", contractions like "pra" where natural -- matching the current PT-BR file's existing informal tone).
- Update frontmatter `description` to match.
- Use `<p class="home-intro">` (same class, not inline style).

**Critical: Do NOT add inline styles anywhere.** The `<p class="home-intro">` class handles all styling via SCSS from Task 1.
  </action>
  <verify>
    <automated>cd /Users/italovietro/projects/italovietro.com && echo "=== Inline style check ===" && grep -c 'style=' content/_index.en.md content/_index.pt-br.md; echo "=== home-intro class ===" && grep -c 'home-intro' content/_index.en.md content/_index.pt-br.md; echo "=== No Where I Made Impact ===" && grep -c "Where I" content/_index.en.md; echo "=== Hugo build ===" && hugo --gc --minify 2>&1 | tail -3</automated>
  </verify>
  <done>Both homepage files rewritten with thematic storytelling (not role-by-role). No inline styles (grep returns 0). Both use `home-intro` class. No "Where I've Made Impact" section. Hugo builds without errors. Voice matches reading list page -- direct, self-aware, personal.</done>
</task>

</tasks>

<verification>
1. `hugo server` -- homepage renders correctly in both EN and PT-BR
2. Toggle dark mode -- intro paragraph text color adapts (no longer hardcoded #666)
3. TypeIt animation still plays on the new subtitle
4. No company-by-company resume section remains
5. Voice feels consistent with the reading list page
</verification>

<success_criteria>
- Homepage reads like the same person who wrote the reading list descriptions
- Subtitle is personal and memorable, no emojis, TypeIt animates it
- Zero inline styles in homepage content files
- Dark mode works for intro paragraph (SCSS handles it)
- Hugo builds and serves without errors in both languages
- Both EN and PT-BR have the same structure with natural translations
</success_criteria>

<output>
After completion, create `.planning/quick/260406-qzg-rewrite-homepage-content-to-match-authen/260406-qzg-SUMMARY.md`
</output>
