#!/usr/bin/env bash
#
# Post-build assertions over the generated site.
#
# These check what a browser actually receives, not how the source is authored.
# That distinction is deliberate: asserting on the compiled output survives any
# reorganisation of content files or stylesheets, and only fails when something
# a visitor experiences has actually regressed.
#
# Needs nothing beyond bash and grep, both already present wherever the site
# builds, so it runs inside the existing build job without new dependencies.
#
# Usage: scripts/check-build.sh [public-dir]

set -uo pipefail

PUBLIC="${1:-public}"
failures=0

ok()  { printf '  ok    %s\n' "$1"; }
bad() { printf '  FAIL  %s\n' "$1"; failures=$((failures + 1)); }

# contains <file> <literal> <description>
contains() {
    local file=$1 needle=$2 desc=$3
    if [ ! -f "$file" ]; then
        bad "$desc (no such file: $file)"
    elif grep -qF -- "$needle" "$file"; then
        ok "$desc"
    else
        bad "$desc"
    fi
}

# nowhere <literal> <description> -- asserts the string is absent from every
# generated file, which catches partial edits that fix visible copy but leave
# metadata, search indexes or alternate output formats stale.
#
# Sourcemaps are excluded: they embed the theme's original SCSS verbatim, so
# they legitimately contain values that were overridden downstream. Including
# them would make every override look like a failure.
nowhere() {
    local needle=$1 desc=$2 hits
    hits=$(grep -rlIF --exclude='*.map' -- "$needle" "$PUBLIC" 2>/dev/null || true)
    if [ -z "$hits" ]; then
        ok "$desc"
    else
        bad "$desc, found in:"
        printf '          %s\n' $hits
    fi
}

# exists <file> <description>
exists() {
    if [ -f "$1" ]; then ok "$2"; else bad "$2 (no such file: $1)"; fi
}

# missing <file> <description> -- the inverse of exists, for output that must not
# be generated.
missing() {
    if [ ! -f "$1" ]; then ok "$2"; else bad "$2 (exists: $1)"; fi
}

# matches <file> <regex> <description> -- for assertions about two things being
# adjacent in the output, which a fixed-string search cannot express.
matches() {
    local file=$1 pattern=$2 desc=$3
    if [ ! -f "$file" ]; then
        bad "$desc (no such file: $file)"
    elif grep -qE -- "$pattern" "$file"; then
        ok "$desc"
    else
        bad "$desc"
    fi
}

# same_count <file> <literalA> <literalB> <description> -- asserts two things occur
# equally often. Better than a fixed number for "every entry has one of these": it
# keeps passing when entries are added and fails when one is added without.
same_count() {
    local file=$1 a=$2 b=$3 desc=$4 na nb
    if [ ! -f "$file" ]; then
        bad "$desc (no such file: $file)"
        return
    fi
    na=$(grep -oF -- "$a" "$file" | wc -l | tr -d ' ')
    nb=$(grep -oF -- "$b" "$file" | wc -l | tr -d ' ')
    if [ "$na" = "$nb" ]; then
        ok "$desc"
    else
        bad "$desc ($a x$na, $b x$nb)"
    fi
}

# occurs <file> <literal> <count> <description> -- exact occurrence count, for
# assertions about how many of a thing a page has rather than whether it has any.
occurs() {
    local file=$1 needle=$2 want=$3 desc=$4 got
    if [ ! -f "$file" ]; then
        bad "$desc (no such file: $file)"
        return
    fi
    got=$(grep -oF -- "$needle" "$file" | wc -l | tr -d ' ')
    if [ "$got" = "$want" ]; then
        ok "$desc"
    else
        bad "$desc (wanted $want, got $got)"
    fi
}

# absent_from <file> <literal> <description>
absent_from() {
    local file=$1 needle=$2 desc=$3
    if [ ! -f "$file" ]; then
        bad "$desc (no such file: $file)"
    elif grep -qF -- "$needle" "$file"; then
        bad "$desc"
    else
        ok "$desc"
    fi
}

# valid_utf8 -- asserts every generated page decodes as UTF-8.
#
# Not paranoia. The pt-br speaking page shipped a truncated multi-byte character
# after an edit that changed nothing near it: Hugo's HTML minifier cut a character
# in half at an internal buffer boundary, and which boundary that is depends on the
# byte length of everything before it. So any edit anywhere on a page can trigger
# it, on the page with the most accented characters -- which on a bilingual site is
# always the Portuguese one, read by the half of the audience least likely to
# report it.
#
# It survives a browser (they recover, showing a replacement glyph) and survives
# every other assertion here, because grep matches the surrounding bytes fine.
valid_utf8() {
    local hits=0 f
    while IFS= read -r f; do
        if ! iconv -f UTF-8 -t UTF-8 "$f" >/dev/null 2>&1; then
            bad "valid UTF-8 in every page (broken: ${f#"$PUBLIC"/})"
            hits=$((hits + 1))
        fi
    done < <(find "$PUBLIC" -name '*.html' -type f)
    if [ "$hits" -eq 0 ]; then
        ok 'every generated page is valid UTF-8'
    fi
}

if [ ! -d "$PUBLIC" ]; then
    printf 'error: "%s" does not exist -- build the site before running this\n' "$PUBLIC" >&2
    exit 2
fi

EN_HOME="$PUBLIC/index.html"
PT_HOME="$PUBLIC/pt-br/index.html"
EN_SPEAKING="$PUBLIC/speaking/index.html"
PT_SPEAKING="$PUBLIC/pt-br/palestras/index.html"
EN_ARCHIVE="$PUBLIC/posts/index.html"
EN_READING="$PUBLIC/recommended-reading/index.html"
PT_READING="$PUBLIC/pt-br/leituras-recomendadas/index.html"
EN_ABOUT="$PUBLIC/about/index.html"
PT_ABOUT="$PUBLIC/pt-br/sobre/index.html"
PT_ARCHIVE="$PUBLIC/pt-br/posts/index.html"
# Any post page would do for the share buttons; this one is also the older of the
# two carrying the durability marker, so it is the page most likely to be read.
EN_POST="$PUBLIC/5-ways-to-keep-coding-being-an-engineering-manager/index.html"
# The stylesheet name carries a content fingerprint, so resolve it rather than
# hardcoding a hash that changes on every style edit.
CSS=$(find "$PUBLIC/css" -maxdepth 1 -name 'style.min.*.css' ! -name '*.map' -print -quit 2>/dev/null)
if [ -z "$CSS" ]; then
    printf 'error: no compiled stylesheet found under %s/css\n' "$PUBLIC" >&2
    exit 2
fi

echo 'Job title'
contains "$EN_HOME" 'Senior Director of Engineering' 'en homepage states the current title'
contains "$PT_HOME" 'Senior Director of Engineering' 'pt-br homepage states the current title'
nowhere 'Head of Engineering' 'superseded title appears nowhere'

echo 'Speaking page'
# No apostrophe in the needle: the entry renders it as &#39; in the body and
# literally in metadata, and this should assert the entry, not the encoding.
contains "$EN_SPEAKING" 'AI Kitchen: How the Company Building Agents' 'en speaking page lists the Beyond Vibe Coding episode'
contains "$PT_SPEAKING" 'AI Kitchen: How the Company Building Agents' 'pt-br speaking page lists the Beyond Vibe Coding episode'
contains "$EN_SPEAKING" 'https://bvc.fm/2026/07/09/005.html' 'en episode links to the episode page'
contains "$PT_SPEAKING" 'https://bvc.fm/2026/07/09/005.html' 'pt-br episode links to the episode page'

echo 'Accent'
contains "$CSS" '#b45309' 'compiled css carries the light accent'
contains "$CSS" '#f59e0b' 'compiled css carries the dark accent'
absent_from "$CSS" '#2d96bd' 'superseded link colour is gone from the stylesheet'
absent_from "$CSS" '#ef3982' 'theme default hover pink is gone from the stylesheet'

# The Vercel routing in .github/scripts/vercel-output.sh sends unmatched paths
# to these two files by name. If Hugo stopped emitting either, that route would
# resolve to nothing and the failure would only surface as a broken 404 page in
# production -- the least likely place anyone looks.
# The reading list was rebuilt around a featured set. These guard the three things
# that would silently undo it: the placeholder coming back, ratings returning, and
# entry titles reverting to h4 (which skipped a heading level, because sections
# here have no subheadings).
# The highest-value guard on the site. Six published posts sat live at /posts/
# with nothing in the nav or on the homepage linking to them, so a visitor
# arriving at the domain could not reach any of them. Nothing about that failure
# was visible: the posts returned 200, they were indexed, and RSS carried them.
echo 'Writing is reachable'
contains "$EN_HOME" '/posts/' 'en homepage links to the writing archive'
contains "$PT_HOME" '/pt-br/posts/' 'pt-br homepage links to the writing archive'
contains "$EN_HOME" '>Writing<' 'Writing appears in the en nav'
contains "$PT_HOME" '>Artigos<' 'Artigos appears in the pt-br nav'
contains "$EN_HOME" '>Reading<' 'nav uses the short parallel label, not the sentence fragment'

# The four-row route list is gone -- it repeated the four nav labels one line
# below the nav, in amber, which is a second navigation dressed as content. A
# sentence routes instead. What still has to hold is the thing the list existed
# for: every section reachable from the domain root, in both languages. That is
# asserted on the links themselves rather than on any markup the sentence uses,
# so rewording the copy cannot break it and deleting a link cannot pass.
contains "$EN_HOME" 'home-signpost' 'the home page routes in prose'
contains "$PT_HOME" 'home-signpost' 'and so does the pt-br home page'
# The opening line greets and stops. Asserted because it comes from config rather
# than from the content file, which is the least likely place to look when the
# first line of the site is wrong.
matches "$EN_HOME" 'home-subtitle>Hey' 'the en home page opens with the greeting'
matches "$PT_HOME" 'home-subtitle>Oi' 'the pt-br home page opens with the greeting'
# Asserted at the theme's own specificity, which is the whole point: styling this
# line from `.home .home-subtitle` is one class short of the theme's rule, so it
# loses and the greeting silently renders at 1rem with 8px of padding. The
# stylesheet said 1.75rem for two commits while the browser showed 16px.
matches "$CSS" '\.home \.home-profile \.home-subtitle\{[^}]*font-size:2\.75rem' 'the greeting is styled at a specificity that beats the theme'
matches "$CSS" '\.home \.home-profile \.home-subtitle\{[^}]*padding:0' 'and keeps the one left edge, with no padding of its own'
absent_from "$EN_HOME" 'home-route__name' 'the route list that mirrored the nav is gone'
contains "$EN_HOME" 'href=/recommended-reading/' 'en home page reaches the reading list'
contains "$EN_HOME" 'href=/speaking/' 'en home page reaches the speaking page'
contains "$PT_HOME" 'href=/pt-br/leituras-recomendadas/' 'pt-br home page reaches the reading list'
contains "$PT_HOME" 'href=/pt-br/palestras/' 'pt-br home page reaches the speaking page'

# The home page ran roughly 1,000 words of biography in each language, above four
# routes nobody could see without scrolling past it. None of the 14 sites surveyed
# in .planning/research/minimal-personal-site-patterns.md runs essay-length
# biography on a home page. The prose is now at /about/, and these guard the three
# ways it could creep back: the portrait, the duplicate name heading, and a route
# list that quietly loses its fourth item.
#
# Asserted on '<h1' rather than the heading text because the failure is structural:
# the site header already carries the name, so a second first-level heading on the
# home page is wrong whatever it says.
echo 'Home page is contents, not biography'
absent_from "$EN_HOME" '<h1' 'en home page has no heading repeating the name in the header'
absent_from "$PT_HOME" '<h1' 'pt-br home page has no heading repeating the name either'
absent_from "$EN_HOME" 'home-avatar' 'no portrait on the en home page'
absent_from "$PT_HOME" 'home-avatar' 'no portrait on the pt-br home page'
nowhere '/images/avatar.png' 'the 428KB portrait PNG is referenced nowhere'
absent_from "$EN_HOME" 'learned about people' 'the moved biography is not left behind on the en home page'
absent_from "$PT_HOME" 'aprendi sobre pessoas' 'the moved biography is not left behind on the pt-br home page'

# One measure, one left edge -- see docs/adr/0004. The profile block sits outside
# the wrapper that carries the 800px cap, so without this rule the tagline drifts
# 140px left of the prose on any screen wider than about 1690px. Invisible on a
# laptop, which is exactly why it needs asserting rather than eyeballing.
#
# The route list is asserted as a grid because the alignment of the four
# descriptions depends on it: under flex each description started wherever its own
# label ended, and `max-content` is what sizes the label track to the longest label
# in whichever language is rendering.
matches "$CSS" '\.home \.home-profile\{max-width:800px' 'the profile block shares the 800px measure'
absent_from "$EN_HOME" '<hr' 'no rule between the routes and the last section'
absent_from "$PT_HOME" '<hr' 'nor on the pt-br home page'
matches "$CSS" '\.home-intro\{font-size:1\.125rem;color:#161209' 'the intro paragraph is body colour, not muted'

# Dark mode gave headings the same colour as the body text under them, so hierarchy
# rested on size alone. Light mode never had the problem: its body text is a
# near-black that already reads as the strongest thing on the page.
# Dark carries one grey. The muted tier used to be #a8a29e against body text at
# #a9a9b3 -- 1% apart, so a caption that was meant to read quieter than the
# paragraph under it read identically. Two tokens, one visible colour, and no way
# to tell from a screenshot which rule had won.
absent_from "$CSS" '#a8a29e' 'the second dark grey is gone'
matches "$CSS" '\[theme=dark\][^{]*\.portrait__sizes[^{]*\{color:#a9a9b3' 'the headshot line uses the same grey as the prose'

echo 'Headings outrank body text in dark'
matches "$CSS" '\[theme=dark\] \.single-title[^{]*\{color:#e7e5e4\}' 'dark headings take the brighter colour'
matches "$CSS" '\[theme=dark\] \.home \.home-profile \.home-subtitle\{color:#e7e5e4\}' 'the greeting is treated as a heading, not body text'

# About is where the biography went, and it is the only page that carries the
# photograph. The two sizes exist for event organisers, who ask by email today.
echo 'About page'
exists "$EN_ABOUT" 'en About page is built'
exists "$PT_ABOUT" 'pt-br About page is built at its localized path'
contains "$EN_ABOUT" "What I&rsquo;ve learned about people" 'en About carries the moved sections'
contains "$PT_ABOUT" 'O que aprendi sobre pessoas' 'pt-br About carries the moved sections'
contains "$EN_ABOUT" 'What 18+ years of building software' 'en About has its own description for indexing'
contains "$PT_ABOUT" 'O que 18+ anos construindo software' 'pt-br About has its own description'
contains "$EN_HOME" '/about/' 'en home page routes to About'
contains "$PT_HOME" '/pt-br/sobre/' 'pt-br home page routes to About'
contains "$EN_HOME" '>About<' 'About appears in the en nav'
contains "$PT_HOME" '>Sobre<' 'Sobre appears in the pt-br nav'
contains "$EN_ABOUT" 'portrait__img' 'the portrait renders on About'
contains "$EN_ABOUT" 'portrait__sizes' 'About offers the portrait at more than one resolution'
# The size links are muted, not amber. They lost to the theme's own content-link
# rule in dark mode -- three classes and a type against a bare class -- so the line
# rendered as a grey label beside two amber links. The qualified selector is the
# fix, and this asserts it stays qualified.
matches "$CSS" '\.single \.content \.portrait__sizes a\{color:#57534e' 'the headshot line is one colour in light'
matches "$CSS" '\[theme=dark\] \.single \.content \.portrait__sizes a[,{]' 'and one colour in dark'
contains "$PT_ABOUT" 'portrait__img' 'the portrait renders on pt-br About too'

# The photograph was a 428KB PNG of a 512x512 image -- 7x the bytes for no extra
# pixels. This ceiling fails loudly if an unoptimised export replaces it.
PORTRAIT="$PUBLIC/images/portrait.jpg"
if [ ! -f "$PORTRAIT" ]; then
    bad "portrait is materially smaller than the 428KB it replaced (no such file: $PORTRAIT)"
elif [ "$(wc -c < "$PORTRAIT")" -lt 120000 ]; then
    ok 'portrait is materially smaller than the 428KB it replaced'
else
    bad "portrait is materially smaller than the 428KB it replaced (got $(wc -c < "$PORTRAIT") bytes, ceiling 120000)"
fi

# The archive page showed link-and-date rows and nothing else, while every post
# already carried a description in front matter. These guard the substance.
echo 'Writing archive has substance'
# Descriptions are gone. The page lists fourteen things -- eight published
# elsewhere, six here -- and a paragraph under only the six made it read as two
# kinds of page stacked together. The invariant that replaced it: every row carries
# its source and date in the right-hand column, the same one the reading list and
# speaking page use, so the meta lines up instead of landing at a different x on
# every row.
absent_from "$EN_ARCHIVE" 'archive-item__desc' 'archive entries are rows, not write-ups'
matches "$CSS" '\.archive-item__date\{margin-left:auto' 'archive meta sits in the right-hand column'
same_count "$EN_ARCHIVE" 'archive-item__title' 'archive-item__date' 'every archive row carries a date, off-site ones included'
contains "$EN_ARCHIVE" '>Writing<' 'archive has its own title, not the generic "All Posts"'
absent_from "$EN_ARCHIVE" '](http' 'no raw markdown link syntax leaks into a description'

# The durability marker is gone: with the notice removed there was nothing on the
# page explaining what a star meant, and a marker nobody can decode is decoration.
nowhere 'archive-item__mark' 'no unexplained marker remains on any page'
# The dated notice is gone. It described a page that no longer exists -- one where
# everything below it was old -- while the archive now opens on 2026. The dates do
# the work the notice was doing, which is what 8 of the 14 surveyed sites rely on.
#
# What replaces it as the guard: the oldest year still renders. Off-site pieces are
# pages with `render: never`, so a misconfigured paginator or a build option
# regression would drop rows silently, and 2017 disappearing is the visible edge of
# that.
echo 'Writing archive'
absent_from "$EN_ARCHIVE" 'archive-intro' 'the archive opens on the list, with no notice above it'
matches "$EN_ARCHIVE" 'group-title>2017<' 'the oldest year is still on the page -- nothing truncated'
matches "$PT_ARCHIVE" 'group-title>2017<' 'and in pt-br'
missing "$PUBLIC/scaling-parloa-when-the-platform-becomes-the-product/index.html" 'a link post renders no page of its own'
contains "$PUBLIC/posts/index.xml" 'parloa.com/labs' 'the feed sends a link post to the piece, not to a stub'

# Talks and podcasts are separate groups on one page. Dates and venues are what
# make a dormant talks list and a live podcast list tell themselves apart, so every
# entry must carry both -- asserted as a count match rather than a fixed number, so
# adding a talk without a date fails but adding a complete one does not.
#
# The completeness hedge #303 asked for is deliberately absent. It was drafted,
# approved and then rejected on sight by the owner, so the dates now carry the
# whole job: a reader who sees a gap between 2019 and 2024 can read it as a gap
# without being told to. The assertions below keep it from creeping back in.
echo 'Speaking page separates talks from podcasts'
contains "$EN_SPEAKING" 'Conference Talks' 'en talks have their own heading'
contains "$EN_SPEAKING" 'Podcast Appearances' 'en podcast appearances have their own heading'
contains "$PT_SPEAKING" '>Palestras<' 'pt-br talks have their own heading'
contains "$PT_SPEAKING" 'Participações em Podcasts' 'pt-br podcast appearances have their own heading'
absent_from "$EN_SPEAKING" 'Not everything is here' 'the rejected completeness hedge stays off the en page'
absent_from "$PT_SPEAKING" 'Nem tudo está aqui' 'and off the pt-br page'
same_count "$EN_SPEAKING" 'talk-entry__title' 'talk-entry__date' 'every en entry carries a date'
same_count "$EN_SPEAKING" 'talk-entry__title' 'talk-entry__event' 'every en entry carries a venue'
same_count "$PT_SPEAKING" 'talk-entry__title' 'talk-entry__date' 'every pt-br entry carries a date'
same_count "$PT_SPEAKING" 'talk-entry__title' 'talk-entry__event' 'every pt-br entry carries a venue'

# Two new jobs for amber: the nav item for the section you are in, and selected
# text. Both were measured against the theme's real backgrounds -- 4.73:1 for the
# active item on the #f8f8f8 header, and 13.70:1 / 9.32:1 for text on the
# composited selection background.
#
# The last two assert what amber must NOT do. Section headings and year groups stay
# uncoloured: entry titles are amber because they are links, and if the headings
# above them took the accent too, nothing on the page would read as more important
# than anything else. That is the state this site had to undo once already.
echo 'Accent in its new roles'
contains "$CSS" 'rgba(180,83,9,0.22)' 'selected text takes the accent in light'
contains "$CSS" 'rgba(180,83,9,0.45)' 'selected text takes the accent in dark'
absent_from "$CSS" 'rgba(53,166,247' 'theme default selection blue is gone'
matches "$CSS" 'a\.active\{font-weight:900;color:#b45309\}' 'the active nav item takes the accent, and keeps a weight cue'
occurs "$EN_ABOUT" 'menu-item active' 2 'the current section is marked in both the desktop and mobile navs'
occurs "$PT_ABOUT" 'menu-item active' 2 'and in pt-br too'
matches "$CSS" '\.archive \.group-title\{[^}]*color:#57534e' 'archive year headings stay muted rather than accented'
matches "$CSS" '\.single \.content h2\{[^}]*color:#161209' 'reading list section headings stay uncoloured'

# Line and Weibo were theme defaults, not choices, and neither is plausible for a
# readership reading in English and Portuguese.
echo 'Share buttons'
contains "$EN_POST" 'data-sharer=twitter' 'Twitter is still offered'
contains "$EN_POST" 'data-sharer=facebook' 'Facebook is still offered'
contains "$EN_POST" 'data-sharer=hackernews' 'Hacker News is still offered'
nowhere 'data-sharer=line ' 'Line is offered on no page'
nowhere 'data-sharer=weibo ' 'Weibo is offered on no page'

echo 'Reading list'
nowhere '[Book Title]' 'the placeholder entry appears nowhere'
absent_from "$EN_READING" 'fa-star' 'no star ratings remain'
absent_from "$EN_READING" '<h4' 'entry titles are h3, leaving no gap in the heading outline'
contains "$EN_READING" 'Start Here' 'en has the featured section'
contains "$PT_READING" 'Comece por aqui' 'pt-br has the featured section, translated'
nowhere 'Must Read' 'the tier subheadings are gone from both languages'


# The site's job is inbound -- see docs/adr/0005. These guard the three things that
# job depends on and that nothing on the page reveals when they break.
#
# Contact: the address sat in [params.author] and rendered nowhere for the life of
# the site, while /about/ offered a headshot "for event organisers".
#
# Preview card: og:image was the logo SVG, which no platform renders, so every
# share showed a blank card. Asserted as a real file on disk too -- a URL in a meta
# tag pointing at nothing looks identical in the HTML.
#
# Upcoming: renders only while data/upcoming.yaml holds a future date, so this
# asserts the mechanism (the shortcode's output shape) rather than any one event,
# which would fail the day the event passes.
echo 'Inbound: contact, sharing, what is next'
contains "$EN_HOME" 'mailto:me@italovietro.com' 'the email is reachable from the en home page'
contains "$PT_HOME" 'mailto:me@italovietro.com' 'and from the pt-br home page'
contains "$EN_SPEAKING" 'Happy to talk at your event' 'the en speaking page invites invitations'
contains "$PT_SPEAKING" 'Fico feliz em falar no seu evento' 'the pt-br speaking page invites invitations'
contains "$EN_HOME" '/images/og-card.jpg' 'the preview card is the og:image'
exists "$PUBLIC/images/og-card.jpg" 'and the card is actually published'
nowhere 'Apple-Devices-Preview' 'the theme demo mockup is referenced nowhere'
nowhere '"xxxx"' 'the theme placeholder publisher name is gone'
absent_from "$EN_HOME" 'images/logo.svg" />' 'og:image is not an SVG, which no platform renders'

# The Critical Channel stopped in January 2023 and the page said "Ongoing" -- the
# one untrue claim on a site whose redesign was about dating things honestly.
nowhere 'date="Ongoing"' 'nothing on the site claims to be ongoing without a date'
contains "$EN_SPEAKING" '23 episodes' 'the podcast carries its episode count'
contains "$EN_SPEAKING" '2020' 'and the years it ran'

# Writing did not stop in 2021, it moved. The archive lists the off-site pieces so
# a visitor can find the recent work from here.
echo 'Writing elsewhere'
matches "$EN_ARCHIVE" 'group-title>2026<' 'the archive opens on the year of the newest piece, wherever it ran'
absent_from "$EN_ARCHIVE" 'group-title>Elsewhere' 'off-site writing is not a separate block any more'
contains "$EN_ARCHIVE" 'Parloa Labs' 'off-site rows name their source'
contains "$PT_ARCHIVE" 'Parloa Labs' 'in both languages -- the source is a name, not prose'
contains "$EN_ARCHIVE" 'Scaling Parloa' 'the Parloa Labs piece is listed'
contains "$EN_ARCHIVE" 'parloa.com/labs' 'and links to it'
contains "$EN_HOME" 'went out elsewhere' 'the en home page no longer says the writing simply stopped'
absent_from "$EN_SPEAKING" 'Encourage Heroism' 'the written interview is off the podcast list'

# Portuguese with its diacritics intact. Asserted on the words that were wrong,
# because a missing accent is invisible to anyone reading the page in English --
# which is to say, to the person most likely to be editing it.
echo 'Portuguese reads as Portuguese'
absent_from "$PT_SPEAKING" 'versao' 'no unaccented "versao"'
absent_from "$PT_SPEAKING" 'decisoes' 'no unaccented "decisoes"'
absent_from "$PT_SPEAKING" 'lideranca' 'no unaccented "lideranca"'
absent_from "$PT_SPEAKING" 'seguranca psicologica' 'no unaccented "seguranca psicologica"'

valid_utf8

echo 'Error pages'
exists "$PUBLIC/404.html" 'en 404 page exists for the catch-all route'
exists "$PUBLIC/pt-br/404.html" 'pt-br 404 page exists for the localized route'

echo 'Logo'
LOGO="$PUBLIC/images/logo.svg"
contains "$LOGO" '#c2680a' 'the standalone favicon copy carries a literal colour'
# The header mark is inlined SVG so it can take the accent per theme -- no single
# colour clears 3:1 on both headers (#f59e0b measures 2.02:1 on the light one).
contains "$EN_HOME" 'logo-mark' 'the header mark is inlined, not an <img>'
matches "$CSS" '\.header-title \.logo-mark\{[^}]*color:#b45309' 'the mark takes the light accent'
matches "$CSS" '\[theme=dark\] \.header-title \.logo-mark\{color:#f59e0b\}' 'and the dark accent'
# The mark was a 247KB traced bitmap masquerading as a vector. A hand-authored
# version of it is well under 2KB, so this ceiling fails loudly if a traced
# export ever replaces it again.
if [ ! -f "$LOGO" ]; then
    bad "logo is small enough to be a real vector (no such file: $LOGO)"
elif [ "$(wc -c < "$LOGO")" -lt 4096 ]; then
    ok 'logo is small enough to be a real vector'
else
    bad "logo is small enough to be a real vector (got $(wc -c < "$LOGO") bytes, ceiling 4096)"
fi

# The banner is gone because nothing sets cookies any more. These assert it
# stays gone: re-enabling it would silently pull two jsDelivr requests back and
# ask visitors to consent to storage that no longer exists.
#
# Asserted against the pages, not the whole output: the theme's bundled JS
# contains the cookieconsent initialiser unconditionally and never runs it
# unless the page injects a config. A `nowhere` check would fail on that bundle
# forever and prove nothing.
echo 'Cookie banner removed'
absent_from "$EN_HOME" 'cookieconsent' 'en pages neither load nor configure the consent library'
absent_from "$PT_HOME" 'cookieconsent' 'pt-br pages neither load nor configure it either'
absent_from "$EN_HOME" '#1aa3ff' 'theme default banner blue is gone'

# Analytics is the one thing on the site with no visible symptom when it breaks:
# a dropped script means silently zero data, discovered weeks later.
# The theme's entire JS bundle hangs off window.config: its constructor reads
# `this.config.data` before doing anything else, so a null config kills the mobile
# menu, the theme switch and every scroll handler at once. The failure is silent --
# no visual change on a desktop, nothing in the HTML, an error only in a console.
echo 'Theme JS has a config to boot from'
nowhere 'window.config=null' 'window.config is never null'
contains "$EN_HOME" 'window.config=' 'the config script is emitted at all'

echo 'Analytics'
contains "$EN_HOME" '/_vercel/insights/script.js' 'Vercel Web Analytics script is present'
contains "$EN_HOME" '/_vercel/speed-insights/script.js' 'Vercel Speed Insights script is present'
contains "$PT_HOME" '/_vercel/insights/script.js' 'pt-br pages carry the analytics script too'
nowhere 'googletagmanager.com' 'no Google Analytics tag remains'
nowhere 'G-KYX115R541' 'the retired Google measurement id appears nowhere'

echo 'Fonts'
nowhere 'fonts.googleapis.com' 'no reference to the external font host'
nowhere 'fonts.gstatic.com' 'no reference to the external font CDN'

# Every asset is served from this origin. Outbound <a href> links in content are
# untouched by these -- they are destinations a visitor chooses, not resources
# the browser fetches without being asked.
#
# Cross-origin HTTP caches have been partitioned per-site in every major browser
# since 2020, so a public CDN no longer buys a warm cache from another site.
# Self-hosting is now strictly faster: same origin, multiplexed over a
# connection that is already open, and covered by this site's SRI fingerprints.
echo 'No third-party asset hosts'
nowhere 'cdn.jsdelivr.net' 'nothing loads from jsDelivr'
nowhere 'cdnjs.cloudflare.com' 'nothing loads from cdnjs'
nowhere 'unpkg.com' 'nothing loads from unpkg'
contains "$EN_HOME" '/lib/fontawesome-free/' 'icon CSS is served from this origin'
# TypeIt used to type the tagline in and is now off in both languages, so the
# assertion flips: it guards that no typing script comes back rather than that it
# is self-hosted. The tagline is the first line above the fold and should be there
# at first paint.
absent_from "$EN_HOME" 'typeit' 'no typing animation script on the en home page'
absent_from "$PT_HOME" 'typeit' 'nor on the pt-br home page'

# Presence only. These assert the rules survive a refactor or a theme bump --
# they say nothing about whether the result looks right, which is why the
# interaction work is signed off by review in both themes rather than by CI.
echo 'Interaction rules present'
contains "$CSS" ':focus-visible' 'keyboard focus styling is present'
contains "$CSS" 'prefers-reduced-motion' 'reduced-motion guard is present'
contains "$CSS" '(hover: hover)' 'hover styling is gated to real pointers'

echo
if [ "$failures" -gt 0 ]; then
    printf '%d assertion(s) failed\n' "$failures" >&2
    exit 1
fi
printf 'all post-build assertions passed\n'
