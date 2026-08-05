# Minimal Personal Sites for Senior Technical People

**Project:** italovietro.com — homepage and section structure
**Researched:** 2026-08-05
**Method:** Every site below was fetched directly (`curl` for HTML + linked CSS) and read as source. No blog posts, listicles, or design commentary were used. Where a claim depends on a colour value, font stack, or nav item, it comes from that site's own markup or stylesheet.
**Confidence:** HIGH on structure, typography, and colour (read from source). MEDIUM on intent (inferred from the sites' own wording, which is quoted wherever it carries the claim).

---

## Sample

15 sites attempted, **14 with primary-source data**.

| # | Site | Fetched | Notes |
|---|------|---------|-------|
| 1 | https://yegge.ai/ | yes | HTML + `style.css` (38 KB) |
| 2 | https://macwright.com/ | yes | single inline `<style>`, no external CSS |
| 3 | https://danluu.com/ | yes | 5-rule inline `<style>`, no external CSS |
| 4 | https://simonwillison.net/ | yes | HTML + `all.7977d7c44aeb.css` |
| 5 | https://jvns.ca/ | yes | HTML + `screen.css` |
| 6 | https://gwern.net/ | yes | HTML + `head.css` + `style.css` (50 KB) |
| 7 | https://patrickcollison.com/ | yes | HTML (1.4 KB) + `style.css` (583 B) |
| 8 | https://tomcritchlow.com/ | yes | HTML + `all.css` + Tachyons |
| 9 | https://maggieappleton.com/ | yes | HTML + two Astro CSS bundles |
| 10 | https://brandur.org/ | yes | HTML + Tailwind + `tailwind_custom.css` |
| 11 | https://apenwarr.ca/ | yes | HTML + `apenwarr.css` (284 B) |
| 12 | https://lethain.com/ | yes | added — closest professional analogue (eng leader, books, talks) |
| 13 | https://thorstenball.com/ | yes | added — has Books + Talks + Podcasts as separate sections |
| 14 | https://ciechanow.ski/ | yes | added — homepage is a single long article |
| — | https://rachelbythebay.com/ | **no** | Unreachable from three separate egress paths: `curl` over IPv4 and IPv6 timed out at 45 s on `/` and `/w/`; `WebFetch` returned `ECONNREFUSED 216.218.228.215:443`; a reader proxy returned 403. She is known to block automated fetchers. **Excluded from all counts** rather than described from memory. |

`lethain.com`, `thorstenball.com`, and `ciechanow.ski` were added because they cover cases the original list did not: an engineering leader with books and a speaking history (Larson), a site with `Talks`, `Podcasts`, and `Books` as distinct dated sections (Ball), and a site whose homepage is a single article that has not changed in 20 months (Ciechanowski). All three are directly relevant to the archived-writing and speaking questions.

**All counts below are out of 14.**

---

## Table 1 — What the homepage does, and how you navigate

| Site | First screen, specifically | Primary job | Top-level nav items | Nav names | Portrait? |
|---|---|---|---|---|---|
| yegge.ai | 375×500 portrait captioned "Photographed 2025", beside a client pull-quote with an SVG ornament | identity | 6 | About · Services · Atlas · Friends · Search · Get in touch | **yes** — large, first screen |
| macwright.com | Name, 7-link list, 3-button theme toggle, then `Writing ⇢` with 10 dated items | contents | 7 | Writing · Reading · Photos · Projects · Drawings · Micro · About | no |
| danluu.com | A `<ul>` of 197 posts, each prefixed `mm/yy`. No name, no nav, **no `<title>` tag** | feed | 0 (6 text links in footer) | — | no |
| simonwillison.net | Tag cloud with counts (`generative-ai 1,918`), search box, sponsor line, then full-text entries | feed | 4 | About · Subscribe · TILs · Tools (+ 6 type tabs) | no |
| jvns.ca | Orange nav bar; "Hey! I'm Julia… Here's every post I've ever written, organized by category"; 10 newest; then the whole archive | feed | 6 (+4 secondary) | About · Talks · Projects · Mastodon · Bluesky · Github (+ Favorites · TIL · Zines · RSS) | no |
| gwern.net | JS warning, 7-link bar, then a ~45-entry topic directory, then "This is the website of Gwern Branwen. I write about AI, psychology, & statistics." | contents | 7 | Site · Me · New · Blog · Links · Patreon · Substack | no |
| patrickcollison.com | Name and 15 links, right-aligned. **`<div id="content">` is empty.** | contents | **15** | About · Advice · Bookshelf · Culture · Dispatches · Fast · Growth · Labs · Links · Pollution · Progress · Questions · Solar · SV history · Travel | no |
| tomcritchlow.com | Fixed left sidebar with icons; 3-paragraph bio; then `Latest Writing` (10 dated); then 4 project cards | identity | 6 (+2 Projects, +3 Elsewhere) | Home · About me · Writing · Library · Newsletter · Search | no |
| maggieappleton.com | 10–12 item menu **with a description per item**; 2-line bio; then per-section digests with relative ages | contents | 10–12 | The Garden · Essays · Notes · Patterns · Smidgeons · Talks · Podcasts · Library · Antilibrary · Now · About | no |
| brandur.org | 8-link bar + 3-state theme toggle; one routing paragraph; full-bleed photograph; 3 items with type badges | contents | 8 | Articles · Atoms · Fragments · Newsletter · Sequences · Now · Uses · About | no |
| apenwarr.ca | `/` **302-redirects to the newest post.** Blue textured wordmark image (372×63), Comic Sans tagline "Pithy. / Like an orange", disclaimer, then the post | feed | 0 | — | no (the image is a **wordmark**, not a face) |
| lethain.com | Site title "Irrational Exuberance", 5 links, 2-sentence bio, then a long dated feed with ⭐ markers | feed | 5 | Popular · Tags · Newsletter · RSS · About | no |
| thorstenball.com | Left sidebar of 8 items; square avatar; "Hello! I'm Thorsten." + 4 short paragraphs | identity | 8 | About · Books · Blog · Podcasts · Talks · Register Spill · Misc · Contact | **yes** — avatar, top of column |
| ciechanow.ski | Name + 7 links, then the full **December 17, 2024** article ("Moon"), unchanged | feed | 7 | Blog · Archives · Patreon · X/Twitter · Instagram · e-mail · RSS | no |

### Counts from Table 1

- **The sample disagrees on the homepage's job.** Feed-first **6/14** (danluu, simonwillison, jvns, apenwarr, lethain, ciechanow). Contents-first **5/14** (macwright, gwern, patrickcollison, maggieappleton, brandur). Identity-first **3/14** (yegge, tomcritchlow, thorstenball). There is no majority and no basis for claiming one is standard.
- **First-person prose about the person appears on 9/14 homepages.** Absent on 5 (macwright, danluu, simonwillison, patrickcollison, ciechanow). Where present it is short: the longest is tomcritchlow at 3 paragraphs, then yegge at 3, thorstenball at 4 short ones. **No site in the sample runs essay-length biography on the homepage.**
- **Nav size: of the 12 sites with a nav, 10 have 4–8 items** (4, 5, 6, 6, 6, 7, 7, 7, 8, 8; median **7**). Only two exceed 8: maggieappleton (10–12) and patrickcollison (15). Two sites have no nav at all (danluu, apenwarr).
- **A portrait appears on 2/14 homepages** — yegge.ai and thorstenball.com. Both are people with something to sell (advisory engagements; self-published books). The other 12, including every pure-writing site, show no face.
- **2/14 homepages are literally the newest post** (apenwarr via a 302 redirect; ciechanow serving a 20-month-old article at `/`).
- **1/14 has an empty content area** — patrickcollison.com ships `<div id="content"></div>`. The homepage is nothing but a name and 15 links.

---

## Table 2 — Typography, colour, and what the accent is for

| Site | Body type | Heading type | Webfont? | Distinct colours | Accent | Accent's jobs |
|---|---|---|---|---|---|---|
| yegge.ai | serif — Crimson Pro | serif — Cormorant Garamond | **yes**, Google, 4 families | 3 hues / 11 tokens, warm cream + warm near-black | **oxblood** `#6b1d1d` light, `#d97070` dark | links, the `.ai` in the wordmark, active nav item, CTA button, `::selection`, focus outline, card hover border, badges — **7 jobs** |
| macwright.com | sans — system stack | sans — same | no | 2 (bg/text) + 1 blue | **none for links**: `--link: var(--text)` | Blue is confined to the `/micro` section only. Links elsewhere are body-coloured and underlined. |
| danluu.com | browser default (serif) | n/a | no | **0 declared** | none | Nothing. The CSS is 5 layout rules; `<meta name=color-scheme content="light dark">` is the entire theming. |
| simonwillison.net | sans — Helvetica Neue | sans; georgia for quotes | no | **38 `--color-*` tokens** | blue `#0303bb` / `#7eb8ff` dark; purple `#636` visited | links, a *separate* link-underline colour, visited links, and a different colour per content type (release = purple, TIL = green) |
| jvns.ca | serif — PT Serif | sans — Montserrat | **yes**, 4 families | ~8 | **orange family**: `#FF7E3E` nav, `#FF5E00` h1, `#CC4B00` links | nav bar background, h1, links, a 35 px striped border-image frame, triangular corner cuts, favourite stars |
| gwern.net | serif — Source Serif 4 | serif + decorative initials | **yes**, self-hosted, **175 `@font-face`** | many, named (`--GW-blood-red`, `--GW-holly-leaf-green`) | red / green, seasonal variants | links, visited links, hover — with named seasonal palettes |
| patrickcollison.com | sans — Helvetica 13px | sans — Myriad Pro | no | **5** (`#333` `#0864c7` `#aaa` `#777` `#eee`) | blue `#0864c7` | **links only** |
| tomcritchlow.com | sans — Libre Franklin | sans | **yes**, Google, 3 families | ~6 | **green** `#02AD28` + `#00ff00` | prose links, uppercase section labels, borders, a highlighter-pen hover (`box-shadow: inset 0 -24px 0 rgba(0,255,0,.4)`), dotted arrows, a bullet dot. **Post titles in the homepage list are black, not green.** |
| maggieappleton.com | serif — Canela Text | serif — Canela Deck + Lato | **yes**, self-hosted, 6 files | **15 named colours × 2 themes** (crimson, salmon, sea-blue, gold, purple, three creams…) | a palette, not an accent | illustration, tags, links |
| brandur.org | sans — `ui-sans-serif` | sans; serif for deks | no | cream `#f6f5e9` + slate scale | **none** | Links get `border-b` + bold sans + no underline. No colour on links at all. |
| apenwarr.ca | serif — et-book/Palatino (named, not loaded) | browser default | no | 5 | blue `#0000cc` | the Comic Sans tagline, `.related` links (`#44f`); **green** marks the current nav item |
| lethain.com | sans — system stack (Tachyons) | sans | no | ~4 | **none for titles** | Post titles are black. ⭐ marks featured posts. |
| thorstenball.com | sans — Inter, self-hosted, preloaded | sans — Inter | **yes**, 6 woff2 | 5 | gold | link/hover accent |
| ciechanow.ski | sans — Inter | sans — IBM Plex Sans | **yes**, Google, 2 families | ~8 | blue `#0181eb`, gold `#CA9839` | links |

### Counts from Table 2

- **Sans body type 8/14** (macwright, simonwillison, patrickcollison, tomcritchlow, brandur, lethain, thorstenball, ciechanow). **Serif body 5/14** (yegge, jvns, gwern, maggieappleton, apenwarr). **No font declared at all: 1** (danluu).
- **Webfonts split exactly 7/7.** Loaded: yegge, jvns, gwern, tomcritchlow, maggieappleton, thorstenball, ciechanow. System stack only: macwright, danluu, simonwillison, patrickcollison, brandur, apenwarr, lethain. **This is the sample's sharpest internal disagreement** — there is no defensible "minimal sites use system fonts" claim.
- **One accent hue, used on links: 7/14** (yegge, patrickcollison, tomcritchlow, jvns, thorstenball, ciechanow, apenwarr).
- **No colour on links at all: 4/14** (macwright, danluu, brandur, lethain). All four are heavily-read writing sites. Brandur substitutes a bottom border + bold sans; macwright substitutes an underline and *reserves* colour for one section; lethain and danluu just use black.
- **Multiple accent hues: 3/14** (simonwillison 38 tokens, gwern seasonal named palettes, maggieappleton 15 named colours).
- **Accent used for links only (nothing else): 3/14** — patrickcollison, thorstenball, ciechanow. Where a site has one accent doing *many* jobs, the count is high: yegge 7 jobs, jvns 5, tomcritchlow 5.
- **Explicit light+dark support: 6/14** (yegge — dark by default via `data-theme`; macwright — `light-dark()` + `color-scheme` + a 3-button toggle; simonwillison — `prefers-color-scheme` + `[data-theme]`; brandur — 3-state radio toggle with `localStorage`; maggieappleton — every colour token has a dark twin; gwern — a `mode-selector` widget). `danluu` declares `color-scheme: light dark` and nothing else. **8/14 are light-only**, including jvns, patrickcollison, tomcritchlow, apenwarr, lethain, thorstenball, ciechanow.
- **Of the 6 with real dark modes, 4 lift the accent rather than reuse it**: yegge `#6b1d1d → #d97070`, simonwillison `#0303bb → #7eb8ff`, maggieappleton crimson `#5f023e → #e85aab`, macwright blue `blue → #b5b5ff`. Two sites (yegge, maggieappleton) leave dated CSS comments about re-tuning for WCAG AA in dark.

---

## Table 3 — Personality, omissions, and dormant content

| Site | Personality carried by | Deliberately omitted | Dormant / archival content |
|---|---|---|---|
| yegge.ai | all-serif Garamond setting; oxblood; a drop cap; a `¶` closing mark; an abstract SVG ornament ("Ghost Track" `lp-mark.svg`) used twice — as a quote rule and a footer mark; portrait; wordmark with an accented `.ai` | dates on the homepage; social icons; comments | **Best-in-sample.** `/talks.html` owns the gaps in prose: *"Most of my talks were never recorded, or the recordings have been lost. But I've managed to find a few of them."* `/atlas.html` grades 150+ old essays with a legend: **★ Essentials · 👍 Good read · 💩 Not worth it · 🔮 Called it · 🤡 Whiffed it** — old work is kept and rated, including "not worth it". Cross-links: *"Long-form podcast conversations live on the Podcasts page."* |
| macwright.com | nothing decorative; personality is in the section names (Micro, Drawings) and the writing. Star ratings as inline SVG `<use>` on books | social icons (only `rel=me` in `<head>`); search; comments; bio | `/writing/` is one **flat list back to 2011** — no year headers, no pagination, no "archive" framing. Every item ISO-dated. Current nav item marked `⇠`. |
| danluu.com | **nothing at all.** No title tag, no nav, no fonts, no colours | title tag; nav; header; fonts; colours; search; images; comments | Two tiers in one list: his own posts, then a `#pt` anchor row labelled "Patreon posts" with a placeholder date `xx/xx`. A 2017–2019 Patreon run is kept inline, dated `mm/yy`. |
| simonwillison.net | content-type badges; source favicons on links; his own pelican illustrations | dark-only design; comments on the homepage | Tag counts (`security 620`) act as a durability signal. Type tabs (Entries · Links · Quotes · Notes · Guides · Elsewhere) let old material be filtered rather than hidden. |
| jvns.ca | **colour** — orange nav bar, `noise.png` texture, a striped `border-image` frame, triangular corner cuts, `star.svg` between nav items. Loudest identity in the sample | dark mode; search; comments | `/talks/` opens with a hedge: *"Here's a mostly up to date list of all the talks I've given."* Newest talk 2023; years live inside the titles; no notice, no demotion. A `Favorites` nav item and an orange star surface durable posts. |
| gwern.net | **typography as identity** — 175 `@font-face`, decorative drop-cap faces (Cheshire Initials, Goudy Initialen, Kanzlei Initialen), sidenotes, link popups; named seasonal colours | dates on the index; a photo | The homepage index is undated. Old and new sit together under topics; `New`/`changelog` is a separate nav item that carries recency instead. |
| patrickcollison.com | **nothing.** Plain Helvetica 13px, right-aligned link list. Personality = the choice of 15 idiosyncratic topics (Fast, Pollution, Solar, SV history) | everything: images, dates, search, social, comments, even homepage content | **The most on-point precedent in the sample.** `/bookshelf` opens with a dated staleness notice: *"As of mid 2026, this page has not been updated in around 10 years. It is currently kept around for posterity, though I may remove it at some stage."* The page stays in nav, unchanged, undemoted. Books are flagged green (great) / light blue (above average). |
| tomcritchlow.com | green + a highlighter-pen link hover + hand-drawn dotted arrows + the tagline "Move. Think. Create." | dark mode; comments | Homepage `Latest Writing` shows June 2026, then **August 2025** — an 11-month gap displayed with full dates and no comment. `/library` uses tabs (Music · Books · All Links) + tag filters. |
| maggieappleton.com | **illustration** — a hand-drawn cover for every essay, talk, and book. She is an illustrator | dates (absolute); comments; social icons | **Relative ages on every item**: "3 months ago", "over 1 year ago". A count badge per section (`10` talks, `64` library books). Section descriptions in the nav itself. Hedged one-liner: *"I occassionally give talks."* A separate **Antilibrary** — "Books I like the idea of having read". |
| brandur.org | a full-bleed photograph on the homepage; cream `#f6f5e9` paper; a serif drop-cap `::first-letter` on articles | link colour; social icons; comments; search | **Routes by cadence.** The homepage's only prose: *"The section updated most often is **atoms**… I update my **now page** monthly according to what I'm working on… I **publish a newsletter** as often as I can."* Footer note: *"These are a short selection of recently posted writing across all categories."* `/now` admits the lapse in the copy — *"It's been way too long since I updated this page. I knew it was a problem, so I set a monthly calendar reminder to update it, and … it didn't work."* — carries *"This page was last updated on Jul 25, 2026"*, and keeps prior versions stacked below by date. |
| apenwarr.ca | **deliberate anti-design** — a Comic Sans tagline, a blue textured wordmark JPEG, a `chicken.gif` favicon, a 6-inch measure, an "I do not speak for your employer" disclaimer | nav; dark mode; comments; search | Actively **resurfaces** old posts: `Related` / `Unrelated` blocks pull items from 2006, 2012, 2019 **with the year in parentheses**. Old work is a feature, not a liability. |
| lethain.com | nothing visual. The blog name "Irrational Exuberance" and ⭐ markers on featured posts | dark mode; images; social icons; comments | **Dates everything, including the About page** — `/about/` reads "Published on April 1, 2007." Body copy dates the archive explicitly: *"This blog, Irrational Exuberance, has been around since 2007."* Links out to *"some public speaking as well"* rather than giving speaking a nav slot. |
| thorstenball.com | avatar + gold accent; otherwise the writing. Notable: ~30 lines of commented-out "What I value" prose left in the HTML | dark mode; search; comments; images | **Dormant and live sections sit as equal siblings.** `/talks`: newest **17 Nov 2024**, then a **7-year gap** back to 14 Sep 2017 — no label, no apology, dates do the work. `/podcasts`: 20 entries, newest **22 Jan 2026**, actively growing. Both are plain `date / venue / title (Slides)` lists. |
| ciechanow.ski | the interactive WebGL diagrams inside the articles | dark mode; comments; search; a photo | **No signal at all.** A Dec 2024 article is served at `/` in Aug 2026, presented as current. `Archives` is a separate nav item. |

### Counts from Table 3

- **0/14 homepages carry a comment widget.** Every `comment` string found was a false positive (post titles; simonwillison's `/elsewhere/comment/` content type).
- **0/14 homepage documents contain a consent banner or newsletter modal.**
- **Search: 4/14** (yegge — nav item + Pagefind; simonwillison — a `<form action="/search/">` on the homepage; gwern; tomcritchlow — nav item). **10/14 omit it.**
- **Iconised social rows: 1/14** — tomcritchlow, using Feather icons in a sidebar group literally labelled "Elsewhere". Everyone else either uses plain text links (danluu footer, jvns header, ciechanow nav, gwern nav) or folds them into prose (thorstenball: *"You can also find me on Twitter, Bluesky…"*; apenwarr: *"You can find me on Bluesky. Or subscribe with RSS."*). **7/14 have no social links on the homepage at all** (macwright, simonwillison, patrickcollison, maggieappleton, brandur, lethain, yegge).
- **Dates on the homepage: 9/14 absolute** (macwright ISO, danluu `mm/yy`, simonwillison full, jvns `Jul 21 2026`, tomcritchlow full, brandur full, apenwarr ISO, lethain full, ciechanow full). **1/14 relative** (maggieappleton). **4/14 none** (yegge, gwern, patrickcollison, thorstenball).
- **Every dated site shows the year.** No exceptions. The shortest format in the sample is danluu's `mm/yy` — which still carries the year in 5 characters.
- **Nobody hides a dormant section. 0/14 removed it from nav, collapsed it, or moved it below the fold.** All 14 keep dormant material at the same level as live material.
- **Explicit dated staleness notice: 2/14** — patrickcollison `/bookshelf`, brandur `/now`.
- **Framing prose that owns the gap without a formal notice: 2/14** — yegge `/talks`, jvns `/talks`.
- **Dates or relative ages do all the work, no notice: 8/14** — macwright, thorstenball, lethain, tomcritchlow, danluu, maggieappleton, apenwarr, simonwillison.
- **No signal at all, stale content presented as current: 2/14** — ciechanow, gwern (undated index).
- **A curation marker separating durable old work from the rest: 6/14** — yegge (emoji legend), lethain (⭐), jvns (Favorites + orange star), macwright (star ratings), patrickcollison (green / light-blue book flags), simonwillison (tag counts). **This is the single most common active response to an ageing archive.**
- **Talks and podcasts are separate sections in 3/3 sites that have both** — thorstenball (`/talks`, `/podcasts`), yegge (`talks.html`, `podcasts.html`, cross-linked in prose), maggieappleton (`/talks`, `/podcasts`, each with a description). No site in the sample merges them.
- **Reading lists use a rating or flag in 4/5 cases** — macwright (star SVGs), patrickcollison (colour flags), tomcritchlow (tags), maggieappleton (a curated Library plus a separate Antilibrary). Only maggieappleton and macwright also show a date per book.

---

## Where the sample contradicts itself

Stated plainly, because these are the places where "best practice" claims would be manufactured:

1. **Homepage job — no majority.** 6 feed-first, 5 contents-first, 3 identity-first. Anyone claiming minimal sites "should" route rather than feed is picking a faction.
2. **Webfonts — an exact 7/7 tie.** gwern loads 175 `@font-face` declarations; danluu declares no font at all. Both are among the most-read technical writers alive.
3. **Link colour — 7 use one accent, 4 use none, 3 use a palette.** The four with no link colour (macwright, danluu, brandur, lethain) are not the least designed sites; brandur's is among the most designed.
4. **Nav size — 4 to 15 items.** patrickcollison's 15-item nav is the *entire* homepage; maggieappleton's 12 items each carry a one-line description. Both work; neither is minimal by count.
5. **Dark mode — 6 of 14.** Half the sample, including several 2026-updated sites, ships light-only.
6. **Portrait — 2 of 14,** and both belong to people selling something. If a photo were table stakes for credibility, this sample would show it. It does not.
7. **Dormancy — 4 sites signal it in words, 8 let dates speak, 2 signal nothing.** The only unanimous finding is the negative one: nobody hides it.

---

## Implications for italovietro.com

Grounded in the current repo state, which was read directly: `config.toml` (3 nav items per language, `[params.home.profile]` enabled with `avatarURL = "/images/avatar.png"` and a `typeit` subtitle, `[params.home.posts] enable = false`), `content/_index.en.md` (an existing `.home-routes` block with three described routes, followed by ~1,000 words of first-person prose in four sections), `assets/css/_override.scss` (`$single-link-color: #b45309` / `#f59e0b` dark, plus global-link-hover and pagination), and `static/images/logo.svg` (704 B, hexagon + steam + `>` chevron + coffee cup, single amber `#c2680a`).

### 1. The homepage already routes. The question is what sits above the routes.

The `.home-routes` block already does what macwright, maggieappleton, and brandur do — named sections with a one-line description each. That is not a gap. The gap is that ~1,000 words of biography sit *below* it, and **no site in the sample runs essay-length biography on its homepage.** The longest is 4 short paragraphs (thorstenball); yegge and tomcritchlow each use 3.

Two supported options:

- **Option A — contents-first (macwright, maggieappleton, brandur).** Routes near the top; biography cut to 2–4 paragraphs; the "What I've learned about people / teams / systems" material moves to a dedicated `/about/` page (which does not currently exist — the homepage *is* the about page). *Trade-off:* creating `/about/` means two new bilingual pages and a fourth nav item, taking EN and pt-BR to 4 items — still well under the sample median of 7. It also means the strongest writing on the site stops being the first thing a visitor sees.
- **Option B — identity-first (yegge, thorstenball).** Portrait plus a tight 3-paragraph narrative, then the routes as tiles. *Trade-off:* both sample precedents are people with a commercial ask (advisory work; books). Given that a Speaking page exists and speaking invitations are a plausible goal, this is defensible — but it changes the site's posture from "here is my thinking" to "here is what I offer", and the sample shows that posture is the minority (3/14).

What the evidence **rules out**: a feed-first homepage. All six feed-first sites have live feeds — danluu 197 items, simonwillison daily, lethain weekly, jvns monthly. Six posts with the newest from March 2021 cannot carry a feed. Keeping `[params.home.posts] enable = false` is correct and matches 8 of 14.

### 2. Fix the section date format before anything else. This is the one clear defect.

`config.toml` sets `[params.section] dateFormat = "01-02"` and `[params.list] dateFormat = "01-02"` — **month and day, no year.** Every dated site in the sample shows the year, without exception, down to danluu's 5-character `mm/yy`. A 2021 post rendered as `03-14` on `/posts/` reads as if it were published this March. For an archive the author is ambivalent about, a date format that hides the year is worse than no date at all: it does not merely fail to signal age, it actively misleads.

Change both to a year-bearing format (`2006-01` or `2006-01-02`, matching the site-level `dateFormat` already set to `2006-01-02`). Zero translation cost. This is the highest-value change on the list and it is a one-line config edit.

### 3. The archived writing section — three supported options, all additive.

The unanimous finding is the negative one: **0 of 14 sites hide a dormant section.** So keeping `Writing` / `Artigos` in the nav is correct, and the existing route description — "Older posts on leadership, teams, and systems." / its pt-BR twin — is already doing the quiet-labelling job. Beyond that:

- **Option C — the Collison notice (2/14 precedent, exact situational match).** A dated one-line banner at the top of `/posts/`, stating the last update and the ambivalence. Collison's wording is the template: *"As of mid 2026, this page has not been updated in around 10 years. It is currently kept around for posterity, though I may remove it at some stage."* An Italo version would read something like *"Last updated March 2021. Kept here because the ideas still hold, not because I'm still writing."* Cost: one sentence × 2 languages, in the section's `_index` front matter or a `content/posts/_index.*.md` file. *Trade-off:* it commits to a position in public. That is also its virtue — it converts an unexplained silence into a deliberate choice, and it matches Italo's actual ambivalence rather than papering over it.
- **Option D — dates only (8/14, the plurality).** Do nothing but fix the date format (item 2). Thorsten Ball's `/talks` page has a 7-year gap between its two newest entries and says nothing about it; the dates carry it. *Trade-off:* it is the lowest-effort option and the most common, but it leaves a visitor to infer intent. With only 6 posts spanning a short window, the inference is easy to get wrong.
- **Option E — a curation marker (6/14, the most common *active* response).** Mark which of the 6 still hold up. Yegge grades 150 essays with an emoji legend; lethain uses ⭐; jvns uses a `Favorites` nav item. With 6 posts a legend is overkill, but a single durable/star flag on the two or three that still stand is cheap and needs no translation. *Trade-off:* it requires an editorial judgement on each post — content work, not engineering. It also pairs well with C rather than competing with it.

C and E combine cleanly (a dated notice plus flags on the survivors). D is the floor. Whichever, note that `Writing` / `Artigos` are already better labels than "Blog" — no dormant section in the sample is called "Blog", and both existing labels name an artefact rather than promising a cadence.

### 4. Amber currently does 3 jobs. The evidence supports up to about 7, with one warning.

`_override.scss` assigns `#b45309` / `#f59e0b` to link colour, global link hover, and pagination. The closest structural precedent in the sample is **yegge.ai**: one accent, lifted in dark (`#6b1d1d → #d97070`, mirroring amber's `#b45309 → #f59e0b`), doing seven jobs — links, one fragment of the wordmark, the active nav item, the CTA, `::selection`, the focus ring, and card hover borders.

- **Option F — expand to 5 jobs.** Add the **active nav item** and **`::selection`**. Both have direct precedent (yegge for both; apenwarr colours the current nav item green for exactly this reason). Both are theme-agnostic, both need zero translation, and neither adds a visual element to the page — they only make an existing element legible. Cheapest personality gain available.
- **Option G — stay at links only (3/14: patrickcollison, thorstenball, ciechanow).** Defensible and the most restrained reading. *Trade-off:* it leaves a distinctive asset underused.

**The warning, and it is corroborated on both sides.** tomcritchlow — the sample's closest analogue for a single strong accent — keeps homepage post titles **black** and reserves green for section labels, prose links, and hover states. And `assets/css/_reading-list.scss` already records the same lesson from this repo's own history: *"amber stars, an amber '#' on every heading, an amber nav strip and amber titles"* was the state that had to be undone. External evidence agrees with the internal note. Whatever amber is expanded to, do not let it land on list titles *and* section labels *and* markers on the same surface. One accent job per surface.

Note also that 4 of 14 sites (macwright, danluu, brandur, lethain) give links **no** colour at all, and macwright's variant is instructive: he reserves the coloured link for exactly one section (`/micro`). If amber ever feels like too much, confining it to one section rather than removing it is a precedented middle path.

### 5. The logo is the best personality asset on hand, and it has a second role available.

Only 1 of 14 sites uses an image logo in the header (apenwarr's wordmark JPEG). But **yegge reuses one abstract SVG mark in two places** — as an ornament on a pull-quote rule and as a footer mark — plus a `¶` as a closing mark. The mark earns more than one appearance when it is abstract rather than a name.

- **Option H — header only (current).** Safe.
- **Option I — header plus one ornament role.** A section divider on long pages, or an end-of-content mark. The asset is ideal for this: 704 bytes, single amber colour so it needs no dark-mode variant, clean vector so it scales to 16 px, and — critically — **it needs no translation.** Under a bilingual constraint, a mark is the cheapest possible way to add personality; every word costs double.
- *Trade-off:* Italo's mark is semi-representational (a coffee cup, a `>` prompt). Yegge's works as decoration because it is abstract. Repeating a recognisable object risks reading as branding rather than typography. Mitigation: use only the hexagon outline or only the `>` chevron as the ornament, not the full mark.

### 6. The portrait: 2 of 14, and both are selling something.

The prism-streak portrait is a strong asset, but the sample gives no support for a face being necessary — 12 of 14, including every pure-writing site, show none. Note also that `[params.home.profile]` is currently `enable = true` with `avatarURL = "/images/avatar.png"` (428 KB PNG), while `content/_index.en.md` opens with its own `<h1>` and `.home-intro` — worth verifying whether the profile avatar and the markdown heading are both rendering, since the sample's identity-first sites (yegge, thorstenball) show a portrait *once*, not alongside a duplicate title.

- **Option J — no portrait on the homepage** (12/14). Reserve it for a future `/about/` page, which is where lethain keeps his headshots (`/about/` offers four resolutions plus thumbnails, explicitly for event organisers — a directly copyable idea given a Speaking page exists).
- **Option K — portrait in the first screen, yegge-style with a caption** (2/14). Defensible if inbound speaking invitations are a goal. *Trade-off:* the prism streak introduces the only non-amber colour on the site; check it does not fight `#b45309` / `#f59e0b`. Also budget the 428 KB PNG down.

### 7. Speaking: 3 of 3 comparable sites separate talks from podcasts.

thorstenball, yegge, and maggieappleton all keep `/talks` and `/podcasts` as distinct sections; none merges them. The current single `/speaking/` page merges both.

- **Option L — one page, two clearly labelled groups.** Keep the nav slot and the bilingual page count; add a heading per group, a date and venue per entry, and a count. Every talks page in the sample carries a date and a venue per entry.
- **Option M — split into two nav items.** EN and pt-BR each go to 4 items — still under the median. *Trade-off:* two more bilingual pages to maintain, and it splits a page that is currently coherent.

Either way, two cheap borrowings apply. First, **the hedging one-liner**: 2 of 3 talks pages in the sample open with one — jvns's *"Here's a mostly up to date list of all the talks I've given"* and yegge's *"Most of my talks were never recorded, or the recordings have been lost."* One sentence, two languages, and it pre-empts the "is this complete?" question. Second, **the cross-link**: yegge's *"Long-form podcast conversations live on the Podcasts page"* is how a merged or split page tells a visitor where the other half is.

Note the asymmetry Ball's site demonstrates and Italo's may share: **talks can be dormant while podcasts stay live.** If that is true here, the two halves want different treatment — which is an argument for Option M, or at minimum for dating both groups so the difference is visible rather than averaged away.

### 8. Reading list: already ahead of most of the sample, with one free idea left.

Star ratings are already implemented (per `_reading-list.scss`), which puts it in the 4-of-5 majority that rates or flags. Two additions have precedent:

- **A read date per book** (macwright, maggieappleton). macwright's grid is `title | author | ISO date | star SVG` — four columns, no commentary. Zero translation cost.
- **maggieappleton's Antilibrary** — a separate list of "Books I like the idea of having read". This is the one idea in the sample with no analogue on Italo's site, it is free content (books already on the shelf unread), and it needs only a heading translated. *Trade-off:* it is a distinctive move that reads as playful; it may or may not fit the site's register.

### 9. What the sample says not to add.

- **Comments** — 0/14. `[params.page.comment] enable = false` already matches.
- **Consent banners and newsletter modals** — 0/14. Already off, with a good comment in `config.toml` explaining why.
- **Iconised social rows** — 1/14. `[params.social]` is already down to GitHub, LinkedIn, RSS; the sample's dominant pattern is text links or prose mentions, not an icon strip.
- **Search** — 10/14 omit it, and no `[params.search]` block exists, so LoveIt's search is off. That matches the majority. Note the counter-evidence: the two sites with the largest archives (simonwillison, gwern) both have search, so this is a function of archive size, not taste. At 6 posts, omitting it is right.
- **Share buttons** — `[params.page.share]` currently enables Twitter, Facebook, HackerNews, **Line**, and **Weibo**. Line and Weibo are LoveIt defaults, not choices. This is an observation about the repo, not a finding from the sample (share buttons on post pages were not surveyed) — but no homepage in the sample carries share affordances, and two of the five enabled networks are implausible for a bilingual EN/pt-BR audience.

### 10. The bilingual constraint reorders everything above.

Nothing in the sample is bilingual, so there is no precedent to cite — but the constraint has a clear structural consequence: **prefer signals that carry no words.** Ranked by translation cost, using only mechanisms observed in the sample:

| Cost | Mechanism | Seen at |
|---|---|---|
| **Zero** | Dates with the year; star / ⭐ / flag markers; the amber accent in more roles; the SVG mark as an ornament; count badges; `⇢` `⇠` `→` arrows; the active-nav-item colour; `::selection` | macwright, lethain, jvns, patrickcollison, yegge, maggieappleton, apenwarr |
| **One line × 2** | A section description; a dated staleness notice; a talks-page completeness hedge; a cross-link between talks and podcasts | maggieappleton, patrickcollison, brandur, jvns, yegge |
| **High** | Essay-length homepage prose (already ~1,000 words × 2 and growing) | nobody in the sample |

Every high-confidence recommendation above — the date-format fix, expanding amber to the active nav item and `::selection`, a durable-post flag, the mark as an ornament — sits in the zero-cost row. The one-line-cost row holds the Collison notice and the talks hedge, both of which buy a lot for two sentences. The high-cost row is where the current homepage is over-invested relative to every site in the sample.

---

## Raw material

Fetched HTML and CSS for all 14 sites, plus 14 subpages (`/talks`, `/podcasts`, `/library`, `/bookshelf`, `/now`, `/reading`, `/writing`, `/atlas`, `/about`), are in the session scratchpad at
`/private/tmp/claude-502/-Users-italo-vietro-projects/87c97e7f-f8c1-4dba-b947-aa321c42d3c6/scratchpad/sites/`.
These are session-scoped and will not persist; re-fetch from the URLs in Table 1 to verify any claim.
