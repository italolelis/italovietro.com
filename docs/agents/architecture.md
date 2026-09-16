# Architecture

Detail split out of `AGENTS.md` so the always-loaded file stays small. Read this when you need the layout of the repo; the rules and commands are in `AGENTS.md`.

## Stack

- **Hugo extended** — 0.153.2 pinned in both workflows and in `vercel.json`. The standard (non-extended) build cannot compile the theme's SCSS.
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
│   ├── css/                     # 9 SCSS partials, see below
│   ├── images/                  # avatar.webp + portrait.jpg, logo.svg
│   └── music/
├── content/                     # see content map below
├── data/upcoming.yaml           # confirmed future appearances
├── docs/
│   ├── adr/                     # 5 architecture decision records
│   └── agents/                  # agent-facing conventions (incl. this file)
├── layouts/                     # theme overrides only
├── scripts/check-build.sh       # THE BUILD GATE (~593 lines)
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

**Posts render at the site root**, not under `/posts/` — `[Permalinks] posts = ":contentbasename"`. `/posts/` is the archive index, rendered by `layouts/_default/section.html`.

15 post bundles. **8 of them are "Elsewhere"** — pieces published on another site (Parloa Labs, InsideN26, HelloTech, Medium, Urban Sports Club Tech), carrying a `host:` front-matter key. They sit in the same chronological archive as posts written here, told apart only by the source in the right-hand column. See the *Elsewhere* entry in `CONTEXT.md`.

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
│   ├── section.html              # post archive, incl. Elsewhere rows
│   └── _markup/                  # codeblock render hooks (goat, mermaid, default)
├── partials/
│   ├── header.html
│   ├── footer.html               # carries the contact address on every page
│   ├── init.html                 # theme version + CDN/analytics scratch setup
│   ├── internal/x.html, x_simple.html
│   ├── rss/item.html
│   └── plugin/
│       ├── analytics.html        # Vercel Analytics + Speed Insights
│       └── img.html
├── shortcodes/
│   ├── talk.html                 # speaking entries
│   ├── upcoming.html             # future appearances from data/upcoming.yaml
│   ├── book.html                 # reading list entries
│   ├── portrait.html             # About page headshot + downloads
│   ├── x.html, x_simple.html, instagram.html
├── speaking/single.html
└── taxonomy/term.html
```

## Stylesheets

`assets/css/` — nine partials:

| File | Scope |
| --- | --- |
| `_override.scss` | Theme variable overrides: accent, muted text, entry type accents, code font, motion |
| `_typography.scss` | Type scale and the 800px measure |
| `_custom.scss` | General custom rules |
| `_home.scss` | Home page intro and signpost |
| `_about.scss` | About page + portrait |
| `_speaking.scss` | Speaking page entries |
| `_reading-list.scss` | Reading list entries |
| `_archive.scss` | Post archive |
| `_interactions.scss` | Shared hover/focus/underline rules, focus rings |

Every colour override in `_override.scss` carries its **measured contrast ratio** in a comment, with the threshold it targets (4.5:1 text, 3:1 non-text). Match that when adding one — ADR-0001 and the build gate both depend on it.

Theme modes need three selectors, all updated together:

```scss
.thing              { }   // light
[theme=dark] .thing { }   // dark
@media (prefers-color-scheme: dark) { [theme=auto] .thing { } }
```

Mobile breakpoint is 680px, aligned with LoveIt's own.

## Shortcode contracts

### `talk` — speaking page entries

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
| `video_url` | no | renders **Watch** |
| `recordings` | no | pipe-separated `Label=URL` for a talk given more than once |
| `slides_url` | no | renders **Slides** |
| `event_url` | no | renders **Event** — for panels with an event page but no recording |

Type drives icon and accent: `talk` → `fa-microphone` (amber), `panel` → `fa-users` (teal), `podcast` → `fa-podcast` (purple), `host` → `fa-headphones` (amber).

**Entries carry no description.** Commit `b551ae7` removed all eight paragraphs: the titles already say what each session was, the voice now sits once at the top of the page next to the invitation, and eight paragraphs in two languages was 400 words per language of translation liability. The shortcode still renders inner content so a single entry *can* carry a note when there is genuinely something to add — but it is not the default, and adding one back to every entry reverses a deliberate decision.

A talk given more than once is **one entry with several recordings**, not one entry per stage. Labels are written per language, so a city is `Florence` in en and `Florença` in pt-br.

Sections, in order: Upcoming (auto) → Conference Talks → Panels & Roundtables → Podcast Appearances → The Critical Channel. Don't prefix panel titles with `"Panel: "`; the icon and heading carry it, and the gate asserts the prefix is absent.

### `upcoming` — future appearances

Reads `data/upcoming.yaml`. Param: `heading` (required, passed per language). Renders **nothing at all — not even the heading** once every entry's `until` date has passed, because an empty "Upcoming" heading says the opposite of what it exists to say. Entries expire by date rather than by anyone remembering to delete them.

When an appearance happens, move it into `content/speaking/index.*.md` and delete it from the YAML. Nothing does this automatically.

### `book` — reading list entries

Params: `title`, `author`, `link` (required), `type` (`book`\|`newsletter`\|`podcast`), `featured` (optional). **There is no rating param** — it was removed because every entry scored 4 or 5 out of 5, and a scale whose values all sit in the top 40% is decoration. Read the comment before reintroducing one.

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
