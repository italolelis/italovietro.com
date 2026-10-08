# Architecture

Detail split out of `AGENTS.md` so the always-loaded file stays small. Read this when you need the layout of the repo; the rules and commands are in `AGENTS.md`.

## Stack

- **Hugo extended** — pinned once, in `.hugo-version`, which both workflows and `vercel.json` read; `scripts/check-build.sh` notes when the Hugo that built the output differs. Every build goes through `scripts/build.sh`: it empties `public/` first and fails on any Hugo warning (`--panicOnWarning`, with missing translations and duplicate paths reported). The standard (non-extended) build cannot compile the theme's SCSS. **0.158 is the floor**: the templates use `hugo.Sites`, `hugo.Data`, `.Site.Language.Locale` and `.Language.Label`, and `config.toml` uses the `locale`/`label` language keys, all of which replaced deprecated names in 0.156–0.158. A new warning now fails the build rather than waiting to be noticed.
- **LoveIt theme** — git submodule at `themes/LoveIt`, currently `v0.2.11-219-gc8b65127`. Never edit it; override instead.
- **Goldmark** markdown, **SCSS** via Hugo Pipes, **TOML** config (~570 lines, heavily commented).
- **No npm dependencies at the site root.** The workflows run `npm ci` only if a root `package-lock.json` exists; it doesn't. The lockfile under `themes/LoveIt/` is the theme's own tooling and plays no part in building this site.
- **No CDN.** `params.cdn.data` is deliberately empty so the theme serves the library copies it ships instead of rewriting URLs to jsDelivr.

## Directory map

```
italovietro.com/
├── .github/
│   ├── workflows/
│   │   ├── deploy-vercel.yml    # master → build, assert, deploy prod
│   │   └── pr-checks.yml        # PR → build, assert, deploy preview
│   ├── scripts/vercel-output.sh # Build Output API packaging
│   └── dependabot.yml           # monthly: actions, docker, submodule
├── .planning/                   # GSD planning artifacts
├── assets/
│   ├── css/                     # 10 SCSS partials, see below
│   ├── images/                  # avatar.webp + portrait.jpg, logo.svg
│   ├── js/episode.js            # the episode page's timeline; no dependencies
│   └── music/
├── content/                     # see content map below
├── data/upcoming.yaml           # confirmed future appearances
├── i18n/                        # strings for the episode layout and the speaking links, merged over the theme's
├── docs/
│   ├── adr/                     # 6 architecture decision records
│   └── agents/                  # agent-facing conventions (incl. this file)
├── layouts/                     # theme overrides only
├── scripts/
│   ├── check-build.sh           # THE BUILD GATE (~670 lines)
│   └── watercolour/             # paints the episode plates; not run in CI
├── static/                      # favicons, manifest, og-card.jpg
├── themes/LoveIt/               # submodule — do not edit
├── CONTEXT.md                   # domain glossary — read before naming things
├── config.toml
└── vercel.json
```

## Content map

Page bundles, one file per language. **The directory name is not the URL** — `slug` and `aliases` in front matter control routing.

| Directory | EN route | PT-BR route |
| --- | --- | --- |
| `content/_index.*.md` | `/` | `/pt-br/` |
| `content/posts/` | `/posts/` (archive) | `/pt-br/posts/` |
| `content/posts/<slug>/` | `/<slug>/` | `/pt-br/<slug>/` |
| `content/about/` | `/about/` | `/pt-br/sobre/` |
| `content/recommended-reading/` | `/recommended-reading/` | `/pt-br/leituras-recomendadas/` |
| `content/speaking/` | `/speaking/` | `/pt-br/palestras/` |
| `content/episodes/<slug>/` | `/episodes/<slug>/` | `/pt-br/episodes/<slug>/` |

**Posts render at the site root**, not under `/posts/` — `[Permalinks] posts = ":contentbasename"`. `/posts/` is the archive index, rendered by `layouts/_default/section.html`.

15 post bundles. **8 of them are "Elsewhere"** — pieces published on another site (Parloa Labs, InsideN26, HelloTech, Medium, Urban Sports Club Tech), carrying a `host:` front-matter key. They sit in the same chronological archive as posts written here, told apart only by the source in the right-hand column. See the *Elsewhere* entry in `CONTEXT.md`.


**Episode pages** live in `content/episodes/`, not in `posts/`: Claude writes them, and the writing section is only what Italo writes. The section has no list page (`build.render: never`); each episode is reached from its entry on the speaking page. See *Episode pages* under *Shortcode contracts*.

Old paths are preserved as `aliases` (`/talks/` → `/speaking/`, `/my-reading-list/` → `/recommended-reading/`). Keep them when renaming; they are live inbound links.

`content/tags/*/_index.{fr,zh-cn}.md` are leftover theme samples in languages this site doesn't build. Harmless; ignore.

## Navigation

Four routes, same order in both languages, asserted by name in the build gate:

| EN | PT-BR | URL |
| --- | --- | --- |
| Writing | Artigos | `/posts/` |
| Reading | Leituras | `/recommended-reading/` ・ `/leituras-recomendadas/` |
| Speaking | Palestras | `/speaking/` ・ `/palestras/` |
| About | Sobre | `/about/` ・ `/sobre/` |

The home page routes to all four in prose — the **Signpost**, not a list of cards. That distinction is deliberate and defined in `CONTEXT.md`; a labelled route list was tried and removed because it repeated the navigation one line below it.

## Layout overrides

```
layouts/
├── _default/
│   ├── section.html              # post archive, incl. Elsewhere rows, each an Entry
│   └── _markup/                  # codeblock render hooks (goat, mermaid, default)
├── _default/baseof.html          # theme mirror: .Site.Language.Locale
├── index.rss.xml, posts/rss.xml, # theme mirrors: .Site.Language.Locale
│   taxonomy/rss.xml
├── episodes/single.html          # episode pages
├── partials/
│   ├── episode/                  # timeline, chapters, chapter-heading, moment, clock, seconds
│   ├── entry.html                # THE Entry: every list's items, one markup (see its contract below)
│   ├── plate.html                # a watercolour, responsive; episode pages and home
│   ├── head/seo.html             # theme mirror: .Site.Language.Locale
│   ├── header.html
│   ├── footer.html               # carries the contact address on every page
│   ├── init.html                 # theme version + CDN/analytics scratch setup
│   ├── internal/x.html, x_simple.html
│   ├── rss/item.html
│   └── plugin/
│       ├── analytics.html        # Vercel Analytics + Speed Insights
│       └── img.html
├── shortcodes/
│   ├── talk.html                 # speaking Entries, through partials/entry.html
│   ├── home-plate.html           # the home page's watercolour, from assets/
│   ├── upcoming.html             # future appearances from data/upcoming.yaml, as Entries
│   ├── book.html                 # reading list Entries, through partials/entry.html
│   ├── portrait.html             # About page headshot + downloads
│   ├── x.html, x_simple.html, instagram.html
├── speaking/single.html
└── taxonomy/term.html            # a tag page: an h1, then Entries
```

## Stylesheets

`assets/css/` — twelve partials:

| File | Scope |
| --- | --- |
| `_override.scss` | Theme variable overrides, the Sass inputs the theme reads at compile time: accent, muted text, entry type accents, code font, motion |
| `_tokens.scss` | **The site's colour** (see *Colour is tokens* below), imported first of all. Every colour as a custom property, set on `:root` and overridden once on `[theme=dark]`, with its measured contrast beside it. Components read `var(--ink)` and never say which mode they are in |
| `_typography.scss` | **The site's voice** (ADR-0006), imported right after the tokens. The serif stack (`--font-serif`) and the `serif`/`sans` mixins, the size scale, the Measure (`$measure`, `measure`), the masthead mixins (`headline`, `display`, `dek`, `kicker`), and what holds for every `.single` page: the column, the title above it, an article's headings, lists, quotations, the rule. Page stylesheets read from it and set no `font-family` of their own |
| `_custom.scss` | Logo, footer, the home intro; imports `_tokens.scss`, then `_typography.scss`, then every page stylesheet below |
| `_home.scss` | Home page: the Greeting, the signpost, the plate |
| `_about.scss` | About page + portrait |
| `_entry.scss` | **The Entry**, one stylesheet for every list: the row, the title, the muted line and its links, the date column in tabular figures, the note, the book's compact and featured weights, the icon colour per kind, the one hover, and the hairline under an h2 that heads a list of Entries. No page stylesheet restates any of it |
| `_speaking.scss` | Speaking page: the banner photograph. Its Entries are `_entry.scss`'s |
| `_episode.scss` | Episode pages: the timeline, chapter list, quotes, lessons, figures, plates. Everything scoped under `.episode` |
| `_reading-list.scss` | The reading list's in-page nav and the line under each section heading. Scoped through `.single .content:has(.entry--book)`, so none of it reaches another page |
| `_archive.scss` | The writing archive and tag pages, around their Entries: the Measure, the line under the title, the year headings |
| `_interactions.scss` | Focus rings, selected text, the active mobile nav item, reduced motion. (The Entry's hover is `_entry.scss`'s) |

**A page stylesheet styles only its own page**, through markup the page declares: a class on its wrapper, or a kind of Entry (`.entry--book`, the reading list's own). A selector that names no page (`.single .content > ul:first-of-type`) matches every page that renders through `.single`; that is how a post's job ladder once rendered as the reading list's nav strip. Rules that are true of every page belong in `_typography.scss`.

### Colour is tokens

Every colour the site chooses is a custom property in `_tokens.scss`: set on `:root` for light, overridden once on `[theme=dark]` for dark. A rule reads the token and says nothing about the mode:

```scss
.thing { color: var(--muted); border-bottom: 1px solid var(--hairline); }   // both themes
```

There is no `[theme=dark] .thing`, and there is never a `[theme=auto]`: nothing sets that attribute. `baseof.html` sets `theme=dark` on `<body>` once, before first paint, from the visitor's saved choice or else their OS (`defaultTheme = "auto"`), and the theme's own script toggles light and dark. Light is the default and has no selector of its own. The stylesheet never reads the OS preference.

| Token | What it is | Token | What it is |
| --- | --- | --- | --- |
| `--paper` | the page | `--accent` | **the Accent** (ADR-0001): one token, so its roles are countable with `grep -o 'var(--accent)'` |
| `--header` | the header's own bar | `--accent-hover` | the Accent, hovered |
| `--ink` | body text | `--accent-wash` | the tint under a hovered Entry |
| `--heading` | headlines, brighter than `--ink` in dark | `--selection-ink` | text over a selection |
| `--muted` | dates, labels, captions | `--entry-podcast`, `--entry-panel` | the two Entry types that are not the Accent |
| `--hairline` | the faint divider under a heading | `--ep-ink`, `--on-ink` | the Episode ink, and text on a fill of it |
| `--rule` | a visible rule: a quote's bar, a box | `--ep-fill-1..4`, `--ep-lesson`, `--ep-tip`, `--ep-bar` | Episode figures |
| `--plate-filter` | how a watercolour plate is dimmed | `--ep-paper`, `--ep-ruler-ink` | the timeline's ruler: paper, and the ink on it, which is the same in both modes |

Adding or changing a colour:

1. **A new colour is a new token** in both blocks of `_tokens.scss`, light and dark, with its **measured contrast** in a comment beside it (4.5:1 for text, 3:1 for anything that is not). Do not write a literal in a component. Not even a one-off: a literal is how a colour ends up written three times.
2. **Assert it**: a `token` line (its value in each mode) and, if it is text or an icon, a `contrast_of` line in `scripts/check-build.sh`. The gate measures every pair again from the compiled values, in both modes, so editing a value cannot quietly take one under its threshold.
3. **Do not add a `[theme=dark]` rule** to switch a colour: change the token. The only dark rules besides the token block are the ones that undo something the *theme* draws again under `[theme=dark]` at a specificity a light rule cannot reach (a quotation's box, the rule across the column, bold text). They read tokens, set no value, and the gate counts them; a new one is a decision. (The Entry has none. It had one, the featured Entry's edge, which showed in dark only; the Entry rework removed it, and the gate asserts that no `[theme=dark]` rule touches an Entry.) The gate also fails if any rule of ours spells a hex colour instead of reading a token.
4. A token that is the same in both modes (`--ep-ruler-ink`) is set on `:root` only; the gate asserts `[theme=dark]` does not set it.
5. A value the theme's own stylesheet also reads (the accent, the greys, the borders) stays in `_override.scss`, because the theme consumes it at compile time. The token is wired to that variable, so the value is still chosen once.

Mobile breakpoint is 680px, aligned with LoveIt's own.

## Shortcode contracts

### The Entry — `layouts/partials/entry.html`

One partial renders every Entry (CONTEXT.md): a book, a talk, an Upcoming appearance, a post on the archive and on a tag page. One stylesheet, `_entry.scss`, sets them. A page passes what it has and nothing else; an Entry with no date has no date column, one with no meta has no second line.

```
{{ partial "entry.html" (dict "title" "…" "link" "…" "meta" "…" "date" "…" "kind" "post") }}
```

| Key | Notes |
| --- | --- |
| `title` | **Required.** Plain text, or HTML that is already safe |
| `link` | Where the title goes. An absolute `http…` URL opens in a new tab; anything else stays on the site. Without one the title is plain text, as a talk's is |
| `meta` | The muted line under the title: an author, a venue |
| `links` | A list of `{ label, url }` on the meta line after `meta`: a talk's Watch, Slides, Event. Absolute ones open in a new tab |
| `date` | The right-hand column, in tabular figures, on the title's row. Text, because `2020–2023` is a date here. A source goes in front (`Parloa Labs · June 4`): that is how a row tells Elsewhere from a post written here |
| `note` | HTML under the rest. Only the reading list passes one |
| `kind` | `book`, `post`, `talk`, `panel`, `podcast`, `host`, `upcoming`; default `post`. Becomes `entry--<kind>` and, for the last five, picks the icon |
| `featured` | bool. The reading list's heavier "Start Here" weight |
| `level` | Heading level of the title, default 3. The tag page passes 2: its title is the h1 and no year heading comes between |

The shape is title, then date on the same row, then the muted line, then the note; on a phone it is one column, with the date under the meta. A book's author shares the title's line unless it is featured. Rules that hold for it, each asserted by the gate: the title is `600` weight and `margin: 0` on every list (it needs three classes of specificity to beat the theme's `.single .content h3`, which once made a talk's title 700 with 19px of margin on one page and 600 on another); the date is the only rule that sets tabular figures; there is one hover, a tint and an Accent edge, on every list; and no `[theme=dark]` rule touches an Entry.

A new list of Entries is a new call to this partial, not new markup and not new CSS. An h2 above Entries gets its hairline from them (`.single .content > h2:has(~ .entry)`), so a page declares nothing. The home page renders Upcoming the same way: `title` the event, `link` its page, `meta` the venue, `date` the display date, `kind` `upcoming`.

### `talk` — speaking page Entries

Renders an Entry through `layouts/partials/entry.html` (contract below): the title is plain text, the venue is its muted line, the links sit on that line, the date is in the right-hand column.

```
{{< talk title="…" event="…" date="…" type="panel" event_url="…" >}}
{{< /talk >}}
```

| Param | Required | Notes |
| --- | --- | --- |
| `title` | yes | |
| `event` | yes | Event name, plus city where useful |
| `date` | yes | Free text, e.g. `August 2026` |
| `type` | yes | `talk` \| `panel` \| `podcast` \| `host` |
| `video_url` | no | renders **Watch** (*Assistir* in pt-br) |
| `recordings` | no | pipe-separated `Label=URL` for a talk given more than once |
| `slides_url` | no | renders **Slides** (*Apresentação* in pt-br) |
| `event_url` | no | renders **Event** (*Evento*) — for panels with an event page but no recording |
| `highlights_url` | no | the episode's page under `/episodes/`, passed through `relLangURL`. Renders **Highlights** (*Destaques*), first in the row because it is the only link that stays on the site. Not "Read": the page is not Italo's writing |
| `highlights_label` | no | overrides that word. The default is the language's own, so the content need not pass it |

The words of Watch, Slides, Event and Highlights are i18n keys (`entry.watch`, `entry.slides`, `entry.event`, `entry.highlights` in `i18n/`), not template strings: the Portuguese page said all three in English until they were. A recording's own label is written per language in the content.

Type drives icon and accent: `talk` → `fa-microphone` (amber), `panel` → `fa-users` (teal), `podcast` → `fa-podcast` (purple), `host` → `fa-headphones` (amber).

**Speaking Entries carry no note.** Commit `b551ae7` removed all eight paragraphs: the titles already say what each session was, the voice now sits once at the top of the page next to the invitation, and eight paragraphs in two languages was 400 words per language of translation liability. The shortcode still renders inner content so a single entry *can* carry a note when there is genuinely something to add — but it is not the default, and adding one back to every entry reverses a deliberate decision.

A talk given more than once is **one entry with several recordings**, not one entry per stage. Labels are written per language, so a city is `Florence` in en and `Florença` in pt-br.

Sections, in order: Upcoming (auto) → Conference Talks → Panels & Roundtables → Podcast Appearances → The Critical Channel. Don't prefix panel titles with `"Panel: "`; the icon and heading carry it, and the gate asserts the prefix is absent.

### `upcoming` — future appearances

Reads `data/upcoming.yaml`. Param: `heading` (required, passed per language). Renders **nothing at all — not even the heading** once every entry's `until` date has passed, because an empty "Upcoming" heading says the opposite of what it exists to say. Entries expire by date rather than by anyone remembering to delete them.

When an appearance happens, move it into `content/speaking/index.*.md` and delete it from the YAML. Nothing does this automatically.

### Episode pages — `content/episodes/`

A podcast appearance on its own page: the episode chapter by chapter, each with a short summary, the quotes that carry it, and the lesson pulled out. **Claude writes these pages, from a transcript of the recording, and the page says so** -- a disclaimer under the masthead, `author: "Claude"` in front matter (so the structured data says so too), and the summaries in the third person. The quotes are the only words on the page that are Italo's: verbatim from the recording, lightly trimmed with brackets and ellipses, each linked to its second.

Because they are not his writing, they are kept out of everything that presents his writing: not in `content/posts/`, not in the archive, not in either RSS feed, no tags or categories. They are in the sitemap, and reached from the speaking page through the talk shortcode's `highlights_url`.

Everything below the masthead is built from front matter; the Markdown body is only the short intro. A new episode is a transcript turned into a few hundred words per language. A full long-read format was built for the first episode and dropped in its favour: ten times the words to maintain in two languages, for a page most readers skim for the lessons.

The page carries a masthead, the chapter list, a colophon, and a timeline pinned under the header: the episode as a ruler, with the clock showing the last real timestamp the reader has passed and a playhead that follows the scroll.

Front matter:

| Key | Notes |
| --- | --- |
| `episode.show`, `.number` | the kicker above the title, written per language |
| `episode.title`, `.released` | the original episode's title and air date, for the meta line |
| `episode.duration` | seconds; scales the timeline |
| `episode.hosts` | list |
| `episode.at`, `.at_label` | where a timestamp goes: a URL with `%d` for the second (YouTube `…&t=%ds`, Spotify `…?t=%d`), and the platform's name for the link title |
| `episode.listen` | `[{ label, url }]`, the "listen" links in the colophon, labels written per language |
| `episode.hero` | `{ src, alt }`, a plate from the bundle |
| (no `layout`) | the section picks `layouts/episodes/single.html` |
| `chapters` | per chapter: `id`, `n`, `t` (start, seconds), `title`, `summary`, `moments: [{ t: "mm:ss", text, size }]`, `lesson`, and an optional `plate: { src, alt, caption, size }` (`size: spot` for the smaller, captioned-beside treatment) |
| `images` | `["cover.jpg"]`, the 1200×630 card cut from the hero |

**Interactive figures** are front matter too, per chapter, so a new episode gets them without new code:

| Key | Renders | Where |
| --- | --- | --- |
| `ask: { type: guess, … }` | a slider the reader commits on, then their guess against the real value. `scale` (log/linear), `min`, `max`, `start`, `ticks`, `unit` (`"%s people"`), `zero`, `answer`, optional `you`/`real` labels | after the chapter heading, before the summary that would give it away |
| `ask: { type: choice, … }` | buttons, then the right one marked and the wrong pick struck. `options`, `answer` (index) | same |
| `figures: [{ type: model, … }]` | a toy model: `stages` with `value`, and `cut`/`toggle` to speed one up; `unit`, and a `note` that must say so if the values are invented | after the summary |
| `figures: [{ type: flow, … }]` | a process top to bottom: `steps` (`name`, `note`, `items`, one `fork` keyed by `path`) and `paths`, the buttons that light a branch | after the summary |

Every `ask` also takes `question`, `verdict` and `t`, the moment in the recording that answers it; the verdict links there. Without JavaScript each figure renders in its final state (answered, at its starting point, both branches) with its controls hidden. Partials: `layouts/partials/episode/ask.html`, `figure.html`; behaviour in `assets/js/episode.js`.

The timeline previews a quote on hover (pointer devices only) and goes to it on click. It sits in the article's column, pinned under the header; its full-width background is a clipped box-shadow, never a positioned element, which once made every episode page scroll sideways -- the gate checks for that.

The recording is **linked, not embedded**: a player is a third-party host loading on every visit, which the asset-host rule exists to prevent. Without JavaScript the timeline is a static ruler; nothing else depends on the script. Interface strings live in `i18n/en.toml` and `i18n/pt-br.toml`.

The plates are painted by `scripts/watercolour/` (`uv run scripts/watercolour/paint.py [plate]`), which writes 2× PNG masters to a gitignored `out/` and exports WebP with a deckled alpha edge to where each plate lives (`DEST` in `paint.py`), cutting each episode's share card from its hero. Only the WebP and JPEG files are committed; the gate fails any plate over 160KB.

A new episode page also needs a line in `EPISODES` at the top of the episode section of `scripts/check-build.sh` (its slug and first chapter id), which runs every episode assertion against it, and a `highlights_url` on its speaking entry.

### `book` — reading list Entries

Renders an Entry (contract below) with the shortcode's body as its **note**: the reading list is the one list whose Entries carry one. Params: `title`, `author`, `link` (required), `featured` (optional), and `type` (`book`\|`newsletter`\|`podcast`), which is read and no longer rendered: it was a modifier class no style used, and a `podcast` one would collide with the speaking page's. The content still sets it. **There is no rating param** — it was removed because every entry scored 4 or 5 out of 5, and a scale whose values all sit in the top 40% is decoration. Read the comment before reintroducing one.

### `portrait` — About page

Params: `alt`, `download_label` (both required). Derives every resolution from the single `assets/images/avatar.webp` master at build time. To add a size, change a number in the shortcode — do not add another binary. The master must stay WebP (it has a real alpha channel) and under the size ceiling the gate enforces.

## Deployment

**GitHub Actions builds; Vercel hosts.** Vercel's own Git integration is disabled (`git.deploymentEnabled: false` in `vercel.json`) specifically so the `check-build.sh` gate cannot be bypassed — letting Vercel build would publish whatever is on `master` regardless of whether the assertions passed.

| Workflow | Trigger | Does |
| --- | --- | --- |
| `deploy-vercel.yml` | push to `master`, manual | build → assert → `vercel deploy --prebuilt --prod` |
| `pr-checks.yml` | PR to `master` | build → assert → preview deploy |

Both check out submodules recursively with `fetch-depth: 0` (needed for `enableGitInfo`), cache `resources/`, and package output through `.github/scripts/vercel-output.sh`. Preview deploys are skipped rather than failed when `VERCEL_TOKEN` is absent, so the build check still works without deploy access.

Secrets: `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`. `vercel.json` sets `trailingSlash: true`. There is no `static/_redirects` — that was Netlify-era.

## Analytics and privacy

**Google Analytics was removed** (it was `G-KYX115R541`). No `googleAnalytics` key, no `[privacy.googleAnalytics]` block. Replaced by **Vercel Web Analytics + Speed Insights**, configured under `[params.analytics.vercel]` and rendered by `layouts/partials/plugin/analytics.html` as two `<script defer>` tags from `/_vercel/*`. No npm package involved.

They render **only** in production (`hugo.IsProduction`), because `/_vercel/*` exists on Vercel's edge and not in Hugo's output — on `hugo server` they would 404 into the console.

**The cookie banner is off** (`params.cookieconsent.enable = false`) because both replacements are cookieless, so there is nothing left to consent to. The gate asserts the banner's CSS and JS are absent from output. If it is ever re-enabled, recover the palette settings from git history — they were tuned to fix a 2.72:1 contrast failure in the theme's default banner.

Still active: `[privacy.x] enableDNT`, `[privacy.youtube] privacyEnhanced`.
