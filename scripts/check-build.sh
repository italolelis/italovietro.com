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
contains "$EN_SPEAKING" "Inside Parloa's AI Kitchen" 'en speaking page lists the Beyond Vibe Coding episode'
contains "$PT_SPEAKING" "Inside Parloa's AI Kitchen" 'pt-br speaking page lists the Beyond Vibe Coding episode'
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
contains "$EN_HOME" 'home-route__name' 'the homepage route list renders'
contains "$EN_HOME" '>Reading<' 'nav uses the short parallel label, not the sentence fragment'

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
occurs "$EN_HOME" 'home-route__name>' 4 'en home page offers four routes'
occurs "$PT_HOME" 'home-route__name>' 4 'pt-br home page offers four routes'
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
matches "$CSS" '\.home-routes\{display:grid;grid-template-columns:max-content 1fr' 'route descriptions share one column track'
absent_from "$EN_HOME" '<hr' 'no rule between the routes and the last section'
absent_from "$PT_HOME" '<hr' 'nor on the pt-br home page'
matches "$CSS" '\.home-intro\{font-size:1\.125rem;color:#161209' 'the intro paragraph is body colour, not muted'

# Dark mode gave headings the same colour as the body text under them, so hierarchy
# rested on size alone. Light mode never had the problem: its body text is a
# near-black that already reads as the strongest thing on the page.
echo 'Headings outrank body text in dark'
matches "$CSS" '\[theme=dark\] \.single-title[^{]*\{color:#e7e5e4\}' 'dark headings take the brighter colour'
matches "$CSS" '\[theme=dark\] \.home \.home-subtitle\{color:#e7e5e4\}' 'the tagline is treated as a heading, not body text'

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
contains "$EN_ARCHIVE" 'archive-item__desc' 'archive entries show their descriptions'
contains "$EN_ARCHIVE" '>Writing<' 'archive has its own title, not the generic "All Posts"'
absent_from "$EN_ARCHIVE" '](http' 'no raw markdown link syntax leaks into a description'

# The archive stopped in 2021 and says so, rather than leaving a visitor to work it
# out from the dates. Two posts carry a star saying the ideas still hold; the count
# is asserted exactly, because a marker that spreads to five posts marks nothing.
echo 'Writing archive is honestly dated'
contains "$EN_ARCHIVE" 'Nothing new here since March 2021' 'en archive opens with the dated notice'
contains "$PT_ARCHIVE" 'Nada novo por aqui desde março de 2021' 'pt-br archive opens with the dated notice'
contains "$EN_ARCHIVE" 'an open question' 'the en notice states the position on resuming, not only the date'
contains "$PT_ARCHIVE" 'uma pergunta em aberto' 'the pt-br notice states the position on resuming'
occurs "$EN_ARCHIVE" 'archive-item__mark' 2 'exactly two en posts carry the durability marker'
occurs "$PT_ARCHIVE" 'archive-item__mark' 2 'exactly two pt-br posts carry it'
matches "$EN_ARCHIVE" 'href=/do-job-titles-matter/.*</a></h3><span class=archive-item__mark' 'the job titles post is one of the two'
matches "$EN_ARCHIVE" 'href=/5-ways-to-keep-coding-being-an-engineering-manager/.*</a></h3><span class=archive-item__mark' 'the keeping-up-with-code post is the other'
contains "$EN_ARCHIVE" 'aria-label="Still holds up"' 'the marker has an accessible name, not a bare glyph'
contains "$PT_ARCHIVE" 'aria-label="Ainda se sustenta"' 'the pt-br marker is named in Portuguese'

# Talks and podcasts are separate groups on one page. Dates and venues are what
# make a dormant talks list and a live podcast list tell themselves apart, so every
# entry must carry both -- asserted as a count match rather than a fixed number, so
# adding a talk without a date fails but adding a complete one does not.
echo 'Speaking page separates talks from podcasts'
contains "$EN_SPEAKING" 'Conference Talks' 'en talks have their own heading'
contains "$EN_SPEAKING" 'Podcast Appearances' 'en podcast appearances have their own heading'
contains "$PT_SPEAKING" '>Palestras<' 'pt-br talks have their own heading'
contains "$PT_SPEAKING" 'Participacoes em Podcasts' 'pt-br podcast appearances have their own heading'
contains "$EN_SPEAKING" 'Not everything is here' 'en page opens with the completeness hedge'
contains "$PT_SPEAKING" 'Nem tudo está aqui' 'pt-br page opens with the completeness hedge'
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

# Read years are supported by the shortcode and styled as a right-hand column, but
# no entry carries one yet: the years are the owner's to supply, and a wrong date is
# worse than an absent one. So this asserts the rule survives, the way the
# interaction rules below are asserted -- presence, not appearance.
#
# When the first years land, add content assertions here for both languages, and a
# line to the reading list intro saying the years are when it was read rather than
# when it was published. A bare year beside a book title reads as the latter.
contains "$CSS" 'book-entry__date' 'the read-year column rule is present in the stylesheet'

echo 'Error pages'
exists "$PUBLIC/404.html" 'en 404 page exists for the catch-all route'
exists "$PUBLIC/pt-br/404.html" 'pt-br 404 page exists for the localized route'

echo 'Logo'
LOGO="$PUBLIC/images/logo.svg"
contains "$LOGO" '#c2680a' 'logo carries its own accent, so no per-theme filter is needed'
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
