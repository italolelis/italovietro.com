# ADR-0005: The site serves inbound — talks, podcasts, peers

## Status

Accepted — 2026-08-09

## Context

The site had been redesigned twice without anyone stating what it was for, so every question about it — how much biography, whether to route or feed, whether the archive stays — was being answered on taste. Three readings were live at once:

1. **Inbound.** Someone heard a podcast or saw a conference bill and is checking who this is.
2. **Archive.** A record of what has been read, said and thought, kept for its own sake.
3. **Recruiting.** Engineers considering Parloa look up the person who would lead them.

The evidence in the repo pointed at the first without ever having said so:

- `/about/` offers the portrait at two resolutions, with a comment explaining it is for event organisers who currently ask by email
- the speaking page carries eight appearances, the newest two months old
- a podcast is hosted, not merely guested on

And the site failed at that job in three specific, measurable ways:

- **No contact path.** `me@italovietro.com` sat in `[params.author]` and rendered on zero pages. An organiser who wanted to book a talk could not, from this site.
- **No link preview.** `og:image` resolved to the logo SVG. No platform renders SVG in a preview card, so every share of this domain showed a blank. The fallback, `params.seo.image`, pointed at LoveIt's own marketing screenshot — a device mockup of the theme demo, cartoon avatar and "© 2019-2020 xxxx" included.
- **No sense of the future.** The page listed what had happened and nothing that was going to, while a confirmed appearance at PENGDEX London in October 2026 existed and was not mentioned.

Two further findings came from checking claims rather than assuming them. The Critical Channel was listed as `date="Ongoing"`; its feed stops at episode 23, January 2023. And the home page said the writing stopped in 2021, while its author had published on Parloa Labs in June 2026 and given a written interview in February 2026 — neither reachable from here.

## Decision

**The site's first job is inbound: someone arriving from a talk, an episode or a search, deciding whether to take this person seriously and get in touch.**

That ranks everything else:

- Contact is a first-class element, not a footnote. The address goes in the footer of every page, and the speaking page says outright that invitations are welcome.
- Sharing is part of the product. A page's link preview is the first thing many people see of it, so the card is a real 1200×630 image and is asserted to exist as a file, not merely referenced.
- What is next outranks what happened. Confirmed future appearances render above past ones, and disappear on their own once the date passes.
- Every claim about currency has to be true, because the audience is checking. Dormant things say so with dates; work published elsewhere is listed here rather than left to a search engine.

The archive and recruiting readings are not abandoned — the writing stays, the About page still describes how he runs teams — but where they conflict with inbound, inbound wins.

## Consequences

- The site now asks for something, which it did not before. That is a change in posture: the survey in `.planning/research/minimal-personal-site-patterns.md` found identity-first sites to be a minority of 3 in 14, and both of the clearest cases belong to people with something to sell. This site now sits closer to them than to danluu.
- Maintenance debt is created deliberately. `data/upcoming.yaml` and `data/elsewhere.yaml` need an edit whenever something is booked or published. The upcoming section is built to fail quiet rather than fail wrong — it renders nothing once dates pass — but nobody is reminded to add the next one.
- Claims are now assertable, and asserted: the email resolving, the card existing as a file, no entry claiming to be "Ongoing" without a date.
- If the answer to "what is this site for" ever changes, this is the ADR to supersede. Several decisions above are only correct given this one.
