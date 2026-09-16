# Italo Vietro's Personal Website

The repository for [italovietro.com](https://italovietro.com) — writing on engineering leadership, a reading list, and a record of talks, panels and podcast appearances.

Built with [Hugo](https://gohugo.io/) and the [LoveIt theme](https://github.com/dillonzq/LoveIt), built by GitHub Actions and hosted on [Vercel](https://vercel.com/).

## Contents

- [What's here](#whats-here)
- [Running it locally](#running-it-locally)
- [Project layout](#project-layout)
- [Why things are the way they are](#why-things-are-the-way-they-are)
- [Deployment](#deployment)
- [Working with AI agents](#working-with-ai-agents)
- [Contributing](#contributing)
- [License](#license)

## What's here

Four sections, each in English and Brazilian Portuguese:

| Section | English | Português |
| --- | --- | --- |
| Writing — posts on engineering leadership and technology | [/posts/](https://italovietro.com/posts/) | [/posts/](https://italovietro.com/pt-br/posts/) |
| Reading — books, newsletters and podcasts worth the time | [/recommended-reading/](https://italovietro.com/recommended-reading/) | [/leituras-recomendadas/](https://italovietro.com/pt-br/leituras-recomendadas/) |
| Speaking — talks, panels and podcast appearances | [/speaking/](https://italovietro.com/speaking/) | [/palestras/](https://italovietro.com/pt-br/palestras/) |
| About — background, and headshots for event organisers | [/about/](https://italovietro.com/about/) | [/sobre/](https://italovietro.com/pt-br/sobre/) |

The writing archive includes pieces published elsewhere — on Parloa Labs, InsideN26, HelloTech and others — listed alongside the ones written here and marked with their source.

## Running it locally

You need **Hugo extended**. The standard build cannot compile the theme's SCSS.

```bash
git clone --recurse-submodules https://github.com/italolelis/italovietro.com.git
cd italovietro.com
hugo server -D
```

Then open <http://localhost:1313>. The `-D` flag includes drafts.

If you cloned without `--recurse-submodules`, the theme will be missing:

```bash
git submodule update --init --recursive
```

### Using DevContainers

Open the project in VS Code and accept the "Reopen in Container" prompt, or run **Dev Containers: Reopen in Container** from the command palette. The container ships Go and Hugo extended and forwards port 1313.

### Building for production

```bash
hugo --gc --minify && ./scripts/check-build.sh public
```

`scripts/check-build.sh` runs a few hundred assertions against the generated site — checking what a browser actually receives, such as the current job title being present, tracking scripts being absent, and contrast-critical styles surviving. **It gates every deploy**, so run it before opening a pull request.

## Project layout

```
├── assets/css/       # SCSS: theme variable overrides + per-page partials
├── content/          # Markdown, one file per language per page
├── data/             # upcoming.yaml — confirmed future appearances
├── docs/adr/         # Architecture decision records
├── layouts/          # Theme overrides and shortcodes
├── scripts/          # check-build.sh — the post-build assertion gate
├── static/           # Favicons, manifest, link-preview card
├── themes/LoveIt/    # Theme (git submodule — not edited directly)
├── CONTEXT.md        # Glossary of the project's own vocabulary
├── config.toml       # Site configuration, heavily commented
└── vercel.json       # Hosting configuration
```

Content lives in page bundles — a directory per page holding both languages and any images that page uses:

```
content/posts/do-job-titles-matter/
├── index.en.md
├── index.pt-br.md
└── featured-image.jpg
```

Posts are served from the site root (`/do-job-titles-matter/`), not under `/posts/` — that path is the archive index.

## Why things are the way they are

Non-obvious choices are written down rather than left to be rediscovered. `config.toml`, the layout overrides and the assertion script carry inline comments explaining what was tried and rejected, [`CONTEXT.md`](CONTEXT.md) fixes the vocabulary, and `docs/adr/` records the larger decisions:

- [ADR-0001](docs/adr/0001-amber-accent-colour.md) — the amber accent, and the five roles it is allowed
- [ADR-0002](docs/adr/0002-no-webfonts.md) — why the site loads no webfonts
- [ADR-0003](docs/adr/0003-logo-redrawn-as-vector.md) — the logo as a vector
- [ADR-0004](docs/adr/0004-one-800px-measure.md) — one 800px column, site-wide
- [ADR-0005](docs/adr/0005-the-site-serves-inbound.md) — what the site is for, and what that ranks above everything else

## Deployment

GitHub Actions builds the site; Vercel hosts it.

| Workflow | Trigger | Result |
| --- | --- | --- |
| `.github/workflows/deploy-vercel.yml` | Push to `master` | Builds, asserts, deploys to production |
| `.github/workflows/pr-checks.yml` | Pull request | Builds, asserts, deploys a preview |

Vercel's own Git integration is deliberately switched off. Both pipelines run `scripts/check-build.sh` as a gate, and nothing deploys if an assertion fails — letting Vercel build directly would publish whatever was on `master` regardless.

Analytics is [Vercel Web Analytics](https://vercel.com/docs/analytics) and Speed Insights, which are cookieless. Google Analytics and the cookie consent banner were both removed, so the site sets no tracking cookies and shows no banner.

## Working with AI agents

Agent-facing context lives in [`AGENTS.md`](AGENTS.md), following the [AGENTS.md convention](https://agents.md/), with the longer reference material in [`docs/agents/`](docs/agents/). That is the single source of truth for agents; there is intentionally no second copy under another filename.

## Contributing

Spotted a typo, a broken link, or something factually wrong? Open an issue or a pull request — both welcome.

Pull requests get a Vercel preview deployment automatically, so you can see your change rendered before it merges. Please check that `hugo --gc --minify && ./scripts/check-build.sh public` passes, and if you touch content, update both the `.en.md` and `.pt-br.md` files.

For anything larger, open an issue first so we can talk about it before you spend time on it.

## License

MIT — see [LICENSE](LICENSE).

The licence covers the site's code and configuration. Post content, images and the portrait are not licensed for reuse.
