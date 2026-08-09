# italovietro.com

A personal site: writing, a reading list, speaking history, and an About page. The vocabulary below is the one used in commit messages, stylesheet comments, tickets and post-build assertions. Where two words competed for the same thing, one was picked.

## Language

**Measure**:
The single 800px column every page is laid out in. One number, one left edge, site-wide — see [ADR-0004](./docs/adr/0004-one-800px-measure.md).
_Avoid_: Container, wrapper, content width, column width

**Signpost**:
The sentence on the home page that links to each section and says which ones are still moving. It replaced a four-row list of labelled routes, which repeated the navigation one line below it. Routing is its job; the navigation's job is getting there from anywhere.
_Avoid_: Route list, section cards, links block, secondary nav

**Greeting**:
The line opening the home page — "Hey 👋", "Oi 👋". It is the loudest text on the page and is styled as a heading, not as body text. It greets and nothing else; the paragraph beneath it does the introducing. It is not the site title, which lives in the header, and it is not a tagline — the aphorism that used to sit here read as a claim made before anything had been said.
_Avoid_: Tagline, subtitle, headline, strapline, hero text

**Upcoming**:
A confirmed future appearance, held in `data/upcoming.yaml` and rendered above the past ones on the speaking page. It disappears by itself once its date passes; nothing has to remember to remove it. Distinct from an entry, which is something that already happened.
_Avoid_: Events, calendar, schedule, next

**Elsewhere**:
Writing published on someone else's site, listed on the writing archive with its host and date. It is not a link roundup — these are his pieces, living at another URL.
_Avoid_: External links, guest posts, links, press

**Entry**:
One item in one of the three lists: a book, newsletter or podcast on the reading list; a talk or podcast appearance on the speaking page; a post on the writing archive. Entries share a treatment — title, muted metadata, description.
_Avoid_: Item, card, row, listing

**Accent**:
The amber that marks links, link hover, pagination, the active navigation item and selected text. Five roles, deliberately counted — see [ADR-0001](./docs/adr/0001-amber-accent-colour.md). It does not mark section headings.
_Avoid_: Brand colour, primary colour, highlight

**Marker**:
The ★ on the two archive posts whose ideas still hold. A symbol rather than a word, because the site is bilingual and a symbol needs no translation.
_Avoid_: Badge, flag, star rating, featured

**Featured**:
The heavier of the two reading-list entry treatments, used for the "Start Here" set. A property of how an entry is displayed, not a score.
_Avoid_: Highlighted, top pick, recommended

**Read year**:
The year an entry on the reading list was read, shown as a right-aligned column. Distinct from the year the book was published, which the site does not record.
_Avoid_: Date, published date, year

**Post-build assertion**:
A check in `scripts/check-build.sh` run against the generated HTML and compiled CSS, not against source. It asserts what a browser receives, so it survives reorganisation of content and stylesheets.
_Avoid_: Test, lint, smoke test
