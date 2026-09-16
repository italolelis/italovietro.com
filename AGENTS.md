# AGENTS.md

Context for AI agents working on italovietro.com — a bilingual Hugo site (writing, reading list, speaking record, About), built by GitHub Actions and hosted on Vercel.

The unusual thing about this repo: **a post-build assertion script decides whether anything ships**, and most non-obvious decisions are already recorded. Read before changing.

## Commands

```bash
# Clone with the theme submodule
git clone --recurse-submodules https://github.com/italolelis/italovietro.com.git

# Dev server, drafts included
hugo server -D               # http://localhost:1313

# Production build + the gate -- RUN THIS BEFORE CALLING ANY CHANGE DONE
hugo --gc --minify && ./scripts/check-build.sh public

# Theme submodule repair / update
git submodule update --init --recursive
git submodule update --remote

# Clear SCSS cache if styles look stale
rm -rf resources/ && hugo server -D
```

Hugo must be the **extended** build; the standard one cannot compile the theme's SCSS. There is no test suite, linter, or formatter — `scripts/check-build.sh` is the only automated check, and it is the one that matters.

## Hard rules

- **Never edit `themes/LoveIt/`** — it's a submodule. Mirror the path under `layouts/` instead.
- **Never add a webfont or Google Fonts import** — ADR-0002.
- **Never add a third-party asset host** — the gate fails on jsDelivr, cdnjs, unpkg.
- **Never reintroduce Google Analytics or the cookie banner** without asking first.
- **Never delete `aliases`** on renamed pages — they are live inbound links.
- **Never strip the long "why" comments** from `config.toml`, `scripts/check-build.sh`, or the overrides. They record what was tried and rejected; they are the project's memory.
- **Never reverse an ADR silently.** If a change contradicts one, say so explicitly.
- **Both languages, every time.** A change to `index.en.md` needs the matching `index.pt-br.md`. Portuguese is written with correct diacritics.
- **Never commit** `public/`, `resources/`, `.vercel/`, `.env*` (all gitignored).
- **Don't claim a change is done** without running the gate.

## Read these first

This repo documents its own decisions. Before anything non-trivial:

- **`CONTEXT.md`** — the domain glossary. When your output names a concept (commit message, issue title, class name, assertion description), use the term as defined there and avoid the synonyms it explicitly rejects: Measure, Signpost, Greeting, Upcoming, Elsewhere, Entry, Accent, Featured, Post-build assertion.
- **`docs/adr/`** — five accepted decisions. Read the ones touching your area:
  - `0001-amber-accent-colour.md` — the accent, and its counted roles
  - `0002-no-webfonts.md` — why no webfont is loaded
  - `0003-logo-redrawn-as-vector.md`
  - `0004-one-800px-measure.md` — one column width, site-wide
  - `0005-the-site-serves-inbound.md` — **read this before any content or layout work.** It decides what the site is for, and therefore what wins: contact is first-class, sharing is part of the product, **what is next outranks what happened**, and every claim about currency must be true because the audience is checking.
- **`docs/agents/architecture.md`** — directory map, content and routing map, stylesheets, shortcode contracts, deployment, analytics. Split out of this file to keep it small; read it when you need the layout of things.
- **Source comments** — `config.toml`, `scripts/check-build.sh` and the layout overrides carry long comments explaining why each non-obvious choice was made, including rejected alternatives. They are the most reliable source in the repo. Read them before "simplifying" anything.

**This file is the single source of agent context.** There is deliberately no `CLAUDE.md`; it was removed after drifting badly. If tooling recreates it, delete it again or reduce it to a pointer here. Do not maintain two descriptions of this repo.

## The build gate

`scripts/check-build.sh` runs ~593 lines of assertions against the generated `public/` directory and gates both PR checks and production deploys. If it fails, nothing deploys.

It asserts on **compiled output** — what a browser actually receives — not on how the source is authored, so it survives file reorganisation and only fails when something a visitor experiences has regressed. A *Post-build assertion* is deliberately not called a test; see `CONTEXT.md`.

Many assertions are **negative** (`nowhere`, `absent_from`), guarding against regressions a theme bump or careless revert could reintroduce invisibly — a superseded job title, a returning cookie banner, a third-party host, a re-added `"Panel: "` prefix.

**When you add something visible, add its assertion.** That is the established pattern here, and the reason the negative ones exist.

Helpers available: `contains`, `contains_re`/`matches`, `nowhere`, `absent_from`, `exists`, `missing`, `occurs`, `same_count`. There is no `nowhere_re`.

Two documented footguns:

- Goldmark's typographer renders `I've` as `I&rsquo;ve`, so a needle containing a straight apostrophe matches nothing and makes an `absent_from` assertion pass **vacuously**. Use an apostrophe-free substring or the generated heading id. The same applies to `&` in headings.
- `--minify` changes attribute shape (`data-sharer=line` vs `data-sharer="line"`). Use the regex variants where that matters.

## Content conventions

Blog posts and pages are **page bundles** — a directory holding `index.en.md`, `index.pt-br.md`, and that page's images, referenced relatively (`![alt](image.jpg)`).

```yaml
---
title: "Post Title"
date: 2026-01-15T10:00:00+00:00
lastmod: 2026-01-15T10:00:00+00:00
draft: false
author: "Italo Vietro"
description: "Brief description for SEO"
tags: ["Engineering", "Leadership"]
categories: ["Engineering"]
---
```

Non-post pages also carry `slug`, and `aliases` where a path changed. Every page needs its own `description`. Posts published elsewhere carry `host:` — see *Elsewhere* in `CONTEXT.md`.

**The speaking page is a list, not a set of write-ups.** Entries are title + venue + date + links, with no description. Voice lives once at the top of the page, next to the invitation. Don't re-add a paragraph per entry.

Where prose does exist (home page, About, reading list, post bodies) it is first person and takes positions. If a position isn't known, **ask rather than invent one.**

## Agent skills

**Issue tracker** — GitHub Issues on `italolelis/italovietro.com` via the `gh` CLI; conventions in `docs/agents/issue-tracker.md`. Artifacts under `.planning/` are *not* issues; don't mirror them.

**Triage labels** — `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

**Domain docs** — single-context repo: one `CONTEXT.md`, one `docs/adr/`. See `docs/agents/domain.md`.

**GSD workflow** — `.planning/` holds GSD artifacts (`PROJECT.md`, `ROADMAP.md`, `STATE.md`, phases, milestones). No GSD slash commands are installed in this checkout; if you have them, confirm with the owner whether planning work should route through them.

## Pre-flight checklist

1. `hugo --gc --minify && ./scripts/check-build.sh public` — all assertions pass
2. New visible behaviour has a new assertion
3. Both languages updated, Portuguese correctly accented
4. New colours measured for contrast; all three theme selectors covered
5. Relevant ADRs read, none silently contradicted; `CONTEXT.md` vocabulary used
6. No new third-party host, webfont, or tracking script
7. `git status` clean of `public/`, `resources/`, `.vercel/`

---

**Hugo:** 0.153.2 extended (CI and Vercel) · **Theme:** LoveIt 0.2.11 (submodule) · **Maintainer:** Italo Vietro
