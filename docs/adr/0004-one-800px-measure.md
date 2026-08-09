# ADR-0004: One measure — 800px, one left edge

## Status

Accepted — 2026-08-09

## Context

The theme lays every page out in two nested centred boxes:

```scss
.page          { max-width: 1080px; width: 64%; margin: 0 auto; }   // theme
.single .content { max-width: 800px; margin: 0 auto; }              // this site
```

Anything inside `.single .content` sits in the inner 800px box. Anything that is a sibling of `.single` — on the home page, the profile block carrying the tagline and the social row — sits in the outer 1080px box.

Both are centred, so they share a **centre line** and disagree on their **left edge**. Above roughly 1690px of viewport, where `.page` stops growing at its 1080px cap, that disagreement is a fixed 140px. The tagline began 140px to the left of the paragraph beneath it.

This was invisible on a laptop and obvious on a desktop monitor, which is how it survived a redesign whose stated goal was the opposite: `_home.scss` opens by describing the page as having stopped "stacking two alignment systems" and committing to one axis. It committed to *left over centred*. It did not commit to one column.

Three options were considered:

1. **800px everywhere** — pull the profile block into the same box.
2. **1080px everywhere** — drop the inner cap so prose runs the full width of `.page`. Rejected: at this body size that is roughly 120 characters per line, well past the point where a reader loses their place returning to the left edge.
3. **Two edges on purpose** — treat the tagline as a masthead hung outside the text column, the way some editorial sites hang bylines. Rejected: the outdent only exists above 1690px. Below 960px `.page` widens to 80% and then 100%, so the effect that justifies it disappears on most screens, leaving an inconsistency that reads as a bug because it is indistinguishable from one.

## Decision

**One measure of 800px governs the whole site, and everything on a page shares one left edge.**

The home page's profile block takes the same `max-width: 800px; margin: 0 auto` as the content wrapper. Any future element placed outside `.single .content` — a banner, a masthead, a full-width figure — must either adopt the measure or state in a comment why it is deliberately breaking it.

800px is about 90 characters at the current body size. That is at the upper end of the comfortable range rather than the middle of it; 680px was considered and rejected as too large a change to reflow the reading list, archive and speaking pages for a defect that is about alignment, not measure.

## Consequences

- The tagline, social row, intro, route list and prose all begin on one x, at every width.
- The measure is now a constraint, not an accident. A future page that renders outside `.single .content` inherits nothing and will drift unless it opts in.
- A post-build assertion fails if `.home .home-profile` loses its `max-width: 800px`, because this is a defect no one sees on the machine they are most likely to be developing on.
- The site keeps a ~90-character line. If that proves too long in practice, changing the measure is now a one-value change in two places rather than a per-page argument — but it will reflow every page at once.
- Nothing changes below 1024px, where `.page` is already narrower than 800px and both boxes collapse to the same width.
