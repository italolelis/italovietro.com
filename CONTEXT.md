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
Writing published on someone else's site. It sits in the same chronological archive as the posts written here, told apart only by the source in its right-hand column — a row with a host ran elsewhere, a row without one ran here. Not a link roundup: these are his pieces, living at another URL.
_Avoid_: External links, guest posts, links, press

**Entry**:
One item in one of the three lists: a book, newsletter or podcast on the reading list; a talk or podcast appearance on the speaking page; a post on the writing archive. Entries share a treatment — title, muted metadata, description.
_Avoid_: Item, card, row, listing

**Accent**:
The amber that marks links, link hover, pagination, the active navigation item and selected text. Five roles, deliberately counted — see [ADR-0001](./docs/adr/0001-amber-accent-colour.md). It does not mark section headings.
_Avoid_: Brand colour, primary colour, highlight

**Featured**:
The heavier of the two reading-list entry treatments, used for the "Start Here" set. A property of how an entry is displayed, not a score.
_Avoid_: Highlighted, top pick, recommended

**Episode page**:
A podcast appearance on its own page under `/episodes/`: the episode chapter by chapter, each with a short summary, the quotes that carry it, and the lesson pulled out. Written by Claude from the transcript, in the third person, and it says so at the top; only the quotes are Italo's. Not writing -- it stays out of the archive, the feeds and the tags -- and not show notes or a transcript. Linked from its entry on the speaking page as "Highlights".
_Avoid_: Recap, write-up, episode notes, retold episode, post

**Masthead**:
The top of a post or an Episode page: a kicker (where the piece sits), the headline, the dek (the italic line that says what it is) and one quiet meta line, in that order. One partial renders it for both, so Italo's writing opens like the pages he did not write. It is not the site header, which is the bar above every page, and not the Greeting, which opens the home page.
_Avoid_: Hero, page header, title block, byline block, post meta

**Moment**:
A quote on an episode page, verbatim and linked to the second it was said. The timeline marks each one.
_Avoid_: Quote card, clip, highlight, timestamp

**Plate**:
A watercolour on a page (the home page's desk, an Episode page's seven), painted by `scripts/watercolour/`. It has a role: **hero** (under a masthead, eager), **spot** (three fifths of the measure, caption beside it) or **inline** (the full measure, the default). Never wider than the measure. Objects, never a face.
_Avoid_: Illustration, image, hero image, graphic

**Post-build assertion**:
A check in `scripts/check-build.sh` run against the generated HTML and compiled CSS, not against source. It asserts what a browser receives, so it survives reorganisation of content and stylesheets.
_Avoid_: Test, lint, smoke test
