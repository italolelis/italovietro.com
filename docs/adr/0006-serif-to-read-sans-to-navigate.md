# ADR-0006: Serif to read, sans to navigate

## Status

Accepted — 2026-10-08

## Context

The site has one serif voice and, until now, it lived on two pages. The Episode pages set their headline, dek and running text in a serif, under a kicker and a meta line in the system sans, and they read like a magazine feature. Every other page rendered through the theme's stock templates: a post's title was a 1.6rem bold sans, its body the theme's 1rem sans at 1.5rem leading, and Italo's own writing looked like a theme default beside pages Claude had written.

Why the voice could not simply be shared:

- **It was declared where no other page could reach it.** `$ep-serif` and the kicker mixin sat in `_episode.scss`, which is imported after every other page stylesheet. A Sass variable is not visible to a file compiled before it.
- **Type was set page by page.** The greeting, the intro, the signpost, the archive's titles, the speaking entries and the reading list each chose their own sizes. `_typography.scss` held only dark heading colours, and the site-wide h2 and the Measure lived in `_reading-list.scss`, a stylesheet for one page.
- **Which file was last decided a heading.** `_typography.scss` had to be imported last so its dark heading colours won, by cascade order, over two-class rules written earlier in other files. A comment in it said so; nothing enforced it.
- **The stack was pasted, not named.** The sans was written out in thirteen rules in the Episode stylesheet. A serif stack pasted into every headline rule could drift by one family in one place and look identical in a diff.

The question was never whether the rest of the site should look like the Episode pages. It was what the rule is, so that a new page gets it without anyone remembering to ask.

## Decision

**Serif to read, sans to navigate.**

| Serif | Sans |
| --- | --- |
| Headlines: a page or post title, an Episode page's title, the Greeting, an article's h2 and h3 | The header, the footer, the navigation |
| The dek | Kickers and meta lines |
| Running text: posts, About, Episode pages, the paragraphs that introduce the reading list and the speaking page, the home page's prose | Entry lists: reading list, speaking, the writing archive, the reading list's in-page nav |
| Blockquotes | Tables, figures and captions, an Episode page's timeline and chapter list |

A headline is something you read to find out what the piece is. A year heading in the archive, an Entry's title or a date column is something you scan, so it takes the sans, and the two faces tell you at a glance which is which. It is how a newspaper feature is set, and it is why the Episode pages worked.

**One module owns the voice: `assets/css/_typography.scss`.** It is imported first, ahead of every page stylesheet, and holds:

- the two stacks, as mixins (`serif`, `sans`), and the serif as the custom property `--font-serif`, so the stack is written once and every use is `var(--font-serif)`. The sans is the theme's own `--global-font-family`;
- a short scale of sizes (display, headline, section, subsection, body, ui, caption, kicker), with the phone value beside each that has one;
- the masthead's parts as mixins: `headline`, `display` (the Episode title, a step up and at the regular weight), `dek` and `kicker`;
- the Measure: `$measure: 800px` and a `measure` mixin, for anything that sits outside `.content`;
- what is true of every page that renders through `.single`: the column, the title above it, an article's headings, lists, quotations, the rule.

**Page stylesheets set no `font-family` of their own.** They call `@include sans` (an Entry, the reading list's nav) or `@include serif` (a figure's title) from the module. The default is the other way round from the theme's: the column is serif and the pieces that are not prose opt out, which is why a new page needs no seam to be on-voice.

System fonts only. The serif stack is `Charter, "Bitstream Charter", "Sitka Text", Cambria, "Iowan Old Style", Georgia, serif`: Charter ships with macOS and iOS, Sitka and Cambria with Windows, Bitstream Charter with most Linux desktops, and Georgia is everywhere else. **[ADR-0002](./0002-no-webfonts.md) stands.** No font is downloaded and no third-party host is contacted.

Four alternatives were considered:

1. **Serif for headlines only, sans for the body.** Rejected: the body is the thing a post is for, and the Episode pages already read serif. A serif headline over a sans paragraph is a theme with a nicer heading.
2. **Serif everywhere, navigation included.** Rejected: it removes the signal. The sans around the reading is what says "this is furniture, not prose".
3. **A webfont (Source Serif, Newsreader, a Cheltenham stand-in).** Rejected by ADR-0002 on cost, and not reopened.
4. **Serif by opt-in, through a class the page declares on its content.** Rejected: it needs a template change per page type, and a page that forgets the class silently reads as a theme default. Opt-out costs one `@include sans` per non-prose component, and the post-build assertions name each one.

## Consequences

- **Every page changes size.** Running text goes from the theme's 16px to 19px (18px on a phone) at 1.65 leading, so every post and every page is longer than it was. The Measure is unchanged (ADR-0004): 800px at this size is about 85 characters.
- **A new component inside `.content` is serif until it opts out.** An Entry, a table and a caption already do; the gate asserts that the reading list's nav and Entries and the speaking Entries are sans. The next Entry-like thing has to say so, and a reviewer has to look.
- **The stack lives in one place.** The gate fails if `Bitstream Charter` appears in the compiled stylesheet more than once, and if a post title, the archive title and an Episode page title do not each say `var(--font-serif)`. Typography is still at the mercy of the visitor's OS (ADR-0002), and Georgia's metrics are not Charter's, so the line breaks differ by platform.
- **An article's headings are the column's direct children.** A shortcode's own heading is nested in the markup it belongs to and is styled there. Reaching into it from the site rules is what made a page's rules lose to the site's on specificity.
- **The hairline under an h2 belongs to the pages whose h2 heads a list of Entries** (the reading list and the speaking page) and to an Episode chapter. In an article it was ornament, and it is gone.
- **Two theme decorations go.** The amber `#` and `|` before every heading, and the blue box and bar on a blockquote: a second accent that belongs to nothing else here (ADR-0001 counts the accent's roles). A quote is italic behind a quiet grey rule; an Episode page's own quotes stay upright.
- **The Measure is one number** (`$measure`), where ADR-0004 recorded it as one value in two places. Changing it reflows every page at once, as that ADR said it would.
- **Colour is untouched.** The dark heading colour keeps its three-selector copies, as the rest of the site does, until the colour tokens are reworked. This ADR is about faces, sizes and the Measure.
- **What it does not decide:** the post masthead (kicker, meta line, share links), which will be built from the mixins above, and the Entry's markup.
