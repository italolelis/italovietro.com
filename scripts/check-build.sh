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

# in_order <file> <regex> <description> -- `matches` over the whole file as one
# line. The minifier keeps some newlines (Hugo's shortcode output brings its own),
# so two elements far apart on a page can sit on different lines, where a
# line-based grep can never see them in sequence.
in_order() {
    local file=$1 pattern=$2 desc=$3
    if [ ! -f "$file" ]; then
        bad "$desc (no such file: $file)"
    elif tr -d '\n' < "$file" | grep -qE -- "$pattern"; then
        ok "$desc"
    else
        bad "$desc"
    fi
}

# text_has <file> <sentence> <description> -- the page's text, not its markup: every tag
# dropped (a block's closing tag leaves a space, so two paragraphs do not run together)
# and whitespace collapsed. For a sentence with a link in the middle of it, which
# `contains` cannot hold whole because the tag is in the way. Entities are NOT decoded:
# a needle writes the typographer's `&rsquo;` and `&ldquo;` as the page does (the
# footgun in AGENTS.md), which is also why a straight apostrophe here matches nothing.
text_has() {
    local file=$1 needle=$2 desc=$3
    if [ ! -f "$file" ]; then
        bad "$desc (no such file: $file)"
    elif tr '\n' ' ' < "$file" | sed -E 's#</(p|h[1-6]|div|section|li)>#& #g; s/<[^>]*>//g; s/[[:space:]]+/ /g' | grep -qF -- "$needle"; then
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

# The three below ask the compiled stylesheet "what does this selector set?",
# which grep over one minified line cannot: `.single .single-title,.archive
# .single-title{font-family:...}` is one rule for two selectors, and an assertion
# that has to match that comma-separated list as text breaks the day someone adds a
# third selector to it. These split a rule's selector list and test each one whole.
#
# Both arguments are regexes (awk ERE). The selector is anchored: it matches one
# selector in a rule's list completely, so `.single .content` does not also match
# `.single .content h2`. Rules inside @media are included, their at-rule header
# being dropped by the match. Commas inside a selector (:is(a,b), :not(a,b)) would
# split wrongly; no selector on this site has one.

# css_rules -- every rule in the compiled stylesheet, `selectors{body}`, one a line.
css_rules() { grep -oE '[^{}]+\{[^{}]*\}' "$CSS"; }

# rules_with <selector-regex> <declaration-regex> -- how many rules have a selector
# matching the first and a body matching the second.
rules_with() {
    css_rules | SEL="$1" DECL="$2" awk '
        BEGIN { sel = "^(" ENVIRON["SEL"] ")$"; decl = ENVIRON["DECL"] }
        {
            i = index($0, "{"); body = substr($0, i + 1)
            n = split(substr($0, 1, i - 1), a, ",")
            for (k = 1; k <= n; k++) if (a[k] ~ sel && body ~ decl) { hits++; break }
        }
        END { print hits + 0 }'
}

# rule_sets <selector-regex> <declaration-regex> <description>
rule_sets() {
    if [ "$(rules_with "$1" "$2")" -gt 0 ]; then ok "$3"; else bad "$3"; fi
}

# rule_lacks <selector-regex> <declaration-regex> <description> -- the inverse.
# Passes vacuously for a selector nothing styles, so pair it with a rule_sets on
# the same selector wherever that would hide a real regression.
rule_lacks() {
    if [ "$(rules_with "$1" "$2")" -eq 0 ]; then ok "$3"; else bad "$3"; fi
}

# The colour tokens are custom properties: set on :root for light, and set again on
# [theme=dark] for the ones that change. A component reads `var(--ink)` and never says
# which mode it is in, so what to assert about colour is the token's value per mode,
# and that no component restates one.

# token_value <light|dark> <name> -- the value a token has in a mode. Dark falls back
# to :root for a token that [theme=dark] does not set, which is the cascade's own
# answer: a token that does not change is inherited unchanged. (The minifier keeps the
# space a custom property's value starts with, so it is trimmed here.)
token_value() {
    local mode=$1 name=$2 v=''
    if [ "$mode" = dark ]; then
        v=$(css_rules | grep -E '^\[theme=dark\]\{' | grep -oE -- "[{;]--$name:[^;}]*" | head -1)
    fi
    if [ -z "$v" ]; then
        v=$(css_rules | grep -E '^:root\{' | grep -oE -- "[{;]--$name:[^;}]*" | head -1)
    fi
    v=${v#*:}
    printf '%s' "${v# }"
}

# token <name> <light> <dark> <description> -- a token has these two values, and the
# dark one comes from the [theme=dark] rule, not from a copy of the light one.
token() {
    local name=$1 light=$2 dark=$3 desc=$4 got
    got=$(token_value light "$name")
    if [ "$got" = "$light" ]; then ok "$desc: light $light"; else bad "$desc: light wanted $light, got '${got:-nothing}'"; fi
    got=$(token_value dark "$name")
    if [ "$got" = "$dark" ] && [ "$(rules_with '\[theme=dark\]' "--$name:")" -gt 0 ]; then
        ok "$desc: dark $dark"
    else
        bad "$desc: dark wanted $dark from [theme=dark], got '${got:-nothing}'"
    fi
}

# token_constant <name> <value> <description> -- a token that is the same in both
# modes, so [theme=dark] must not set it.
token_constant() {
    local name=$1 value=$2 desc=$3 got
    got=$(token_value light "$name")
    if [ "$got" = "$value" ] && [ "$(rules_with '\[theme=dark\]' "--$name:")" -eq 0 ]; then
        ok "$desc: $value in both modes"
    else
        bad "$desc: wanted $value, set once on :root (got '${got:-nothing}')"
    fi
}

# contrast <hex> <hex> -- the WCAG 2 contrast ratio of two colours, to two places.
contrast() {
    awk -v a="$1" -v b="$2" '
        function h2d(c) { return index("0123456789abcdef", tolower(c)) - 1 }
        function chan(s, k,   v) {
            v = (h2d(substr(s, 2 * k, 1)) * 16 + h2d(substr(s, 2 * k + 1, 1))) / 255
            return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ^ 2.4
        }
        function lum(s) {
            if (length(s) == 4) s = "#" substr(s,2,1) substr(s,2,1) substr(s,3,1) substr(s,3,1) substr(s,4,1) substr(s,4,1)
            return 0.2126 * chan(s, 1) + 0.7152 * chan(s, 2) + 0.0722 * chan(s, 3)
        }
        BEGIN {
            x = lum(a); y = lum(b)
            if (x < y) { t = x; x = y; y = t }
            printf "%.2f", (x + 0.05) / (y + 0.05)
        }'
}

# contrast_of <foreground-token> <background-token> <minimum> <description> -- checks
# the pair in both modes, against the token values the browser will actually resolve.
# The ratios the comments in the stylesheets quote are measured once, by hand; this is
# what stops a later edit to a value from quietly dropping one under its threshold.
contrast_of() {
    local fg=$1 bg=$2 min=$3 desc=$4 mode f b r line=''
    for mode in light dark; do
        f=$(token_value "$mode" "$fg"); b=$(token_value "$mode" "$bg")
        if [[ ! $f =~ ^#[0-9a-fA-F]{3,6}$ || ! $b =~ ^#[0-9a-fA-F]{3,6}$ ]]; then
            bad "$desc ($mode: --$fg is '$f', --$bg is '$b', neither can be measured)"
            return
        fi
        r=$(contrast "$f" "$b")
        if awk -v r="$r" -v m="$min" 'BEGIN { exit !(r + 0 >= m + 0) }'; then
            line="$line $mode $r:1"
        else
            bad "$desc ($mode measures $r:1, needs $min:1)"
            return
        fi
    done
    ok "$desc (${line# })"
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
# A tag page: the Entry's fourth list. `cto` is the one tag three posts share.
EN_TAG="$PUBLIC/tags/cto/index.html"
PT_TAG="$PUBLIC/pt-br/tags/cto/index.html"
# Any post page would do for the share buttons; this one is also the older of the
# two carrying the durability marker, so it is the page most likely to be read.
EN_POST="$PUBLIC/5-ways-to-keep-coding-being-an-engineering-manager/index.html"
# The stylesheet name carries a content fingerprint, so resolve it rather than
# hardcoding a hash that changes on every style edit.
#
# Exactly one, or stop. Hugo never deletes what it stops producing, so a public/
# that has seen several builds holds one stylesheet per build, and picking the
# first would assert against whichever one `find` happened to return -- a stale
# file passes or fails for reasons unrelated to the change. scripts/build.sh
# empties public/ first; this catches an output directory that was not built
# that way.
CSS_ALL=$(find "$PUBLIC/css" -maxdepth 1 -name 'style.min.*.css' ! -name '*.map' 2>/dev/null)
CSS_COUNT=$(printf '%s' "$CSS_ALL" | grep -c . || true)
if [ "$CSS_COUNT" -eq 0 ]; then
    printf 'error: no compiled stylesheet found under %s/css\n' "$PUBLIC" >&2
    exit 2
elif [ "$CSS_COUNT" -gt 1 ]; then
    printf 'error: %s stylesheets under %s/css -- stale output from earlier builds.\n' "$CSS_COUNT" "$PUBLIC" >&2
    printf '       Build fresh with ./scripts/build.sh, which empties public/ first.\n' >&2
    exit 2
fi
CSS=$CSS_ALL

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
# The opening line greets and stops, and it is the page's h1. It was a div the theme
# drew from config, which left the loudest text on the page with no heading meaning
# at all: a screen reader's heading list opened on "Beyond the Code". It is front
# matter now, in each language's own file, rendered by layouts/index.html.
matches "$EN_HOME" '<h1 class=home-greeting>Hey' 'the en home page opens with the greeting, as its h1'
matches "$PT_HOME" '<h1 class=home-greeting>Oi' 'the pt-br home page opens with the greeting, as its h1'
# While the Greeting was the theme's `.home-subtitle` div it had to be styled at the
# theme's own specificity: one class short lost silently, and it rendered at 1rem with
# 8px of padding while the stylesheet said 1.75rem for two commits. The layout draws
# its own h1 now, so there is no theme rule to beat; what is asserted is that it is
# the headline step, and that nothing pads it off the left edge.
rule_sets '\.home \.home-greeting' 'font-size:2\.75rem' 'the greeting is the headline step'
rule_lacks '\.home \.home-greeting' 'padding-left' 'and keeps the one left edge, with no side padding of its own'
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
# the site header already carries the name, so a second first-level heading restating
# it is wrong whatever it says. The guard used to be "no h1 at all". The Greeting is
# the page's h1 now (see 'Home page layout'), so it is that there is exactly one and
# that it is not the name.
echo 'Home page is contents, not biography'
occurs "$EN_HOME" '<h1' 1 'en home page has one first-level heading'
occurs "$PT_HOME" '<h1' 1 'pt-br home page has one first-level heading'
absent_from "$EN_HOME" '<h1 class=home-greeting>Italo' 'and it is not the name the header already carries'
absent_from "$PT_HOME" '<h1 class=home-greeting>Italo' 'in pt-br either'
absent_from "$EN_HOME" 'home-avatar' 'no portrait on the en home page'
absent_from "$PT_HOME" 'home-avatar' 'no portrait on the pt-br home page'
nowhere '/images/avatar.png' 'the 428KB portrait PNG is referenced nowhere'
absent_from "$EN_HOME" 'learned about people' 'the moved biography is not left behind on the en home page'
absent_from "$PT_HOME" 'aprendi sobre pessoas' 'the moved biography is not left behind on the pt-br home page'

# The home page is a layout (layouts/index.html) that assembles named parts, in this
# order: the Greeting, an intro, the Signpost, "Beyond the Code", the Plate. It was raw
# HTML inside Markdown: a wrapper div, classed paragraphs, and a Signpost with every
# URL typed out per language, repeating the menu that already holds them. Same order
# and same words, by decision (Italo); only the structure changed, so what is asserted
# here is the words, in order, and where each part's links come from.
echo 'Home page layout'
in_order "$EN_HOME" '<h1 class=home-greeting>.*class=home-intro>.*<p class=home-signpost>.*<section class=home-beyond><h2[^>]*>Beyond the Code</h2>.*<figure class="plate plate--[a-z]+">' 'the en home page runs Greeting, intro, Signpost, Beyond the Code, Plate'
in_order "$PT_HOME" '<h1 class=home-greeting>.*class=home-intro>.*<p class=home-signpost>.*<section class=home-beyond><h2[^>]*>Além do Código</h2>.*<figure class="plate plate--[a-z]+">' 'and so does the pt-br home page'
# The Plate is last: nothing but closing tags between its figure and the end of the page's
# content, so a new part cannot be added after the picture without this noticing.
matches "$EN_HOME" '<figure class="plate plate--[a-z]+">.*</figure>(</section>|</div>)*</main>' 'the en Plate comes last'
matches "$PT_HOME" '<figure class="plate plate--[a-z]+">.*</figure>(</section>|</div>)*</main>' 'the pt-br Plate comes last'
# The words, whole, as a reader gets them. The typographer curls a quote or an apostrophe
# the way it does anywhere else in Markdown, which is the one visible change from the
# raw HTML these sentences used to sit in, so the needles are written curled (`&rsquo;`).
text_has "$EN_HOME" 'I&rsquo;m Senior Director of Engineering at Parloa, where we&rsquo;re figuring out how to make AI conversations actually work reliably at scale. The kind of problem where &ldquo;move fast and break things&rdquo; doesn&rsquo;t fly. I&rsquo;ve been in tech for 18+ years. Started fixing computers in João Pessoa, Brazil, eventually moved into software, and made my way across Europe building teams and systems.' 'the en intro, word for word'
text_has "$PT_HOME" 'Sou Senior Director of Engineering na Parloa, onde a gente tá descobrindo como fazer conversas com IA funcionarem de verdade em escala. O tipo de problema onde &ldquo;move fast and break things&rdquo; não cola. Estou na área de tecnologia há 18+ anos. Comecei consertando computadores em João Pessoa, migrei para software, e fui fazendo meu caminho pela Europa construindo times e sistemas.' 'the pt-br intro, word for word'
text_has "$EN_HOME" 'I write from time to time, and those thoughts end up in writing. I read a good deal more than I write, and the books that stuck are in reading. I also like talking about what I have had to figure out the hard way, which is speaking. If you want the longer version of all this, it is in about.' 'the en Signpost, word for word'
text_has "$PT_HOME" 'Escrevo de vez em quando, e esses textos acabam em artigos. Leio bem mais do que escrevo, e os livros que ficaram estão em leituras. Também gosto de falar sobre o que tive que descobrir na marra, e isso está em palestras. Se quiser a versão mais longa de tudo isso, está em sobre.' 'the pt-br Signpost, word for word'
text_has "$EN_HOME" 'When I&rsquo;m not thinking about distributed systems, you&rsquo;ll find me managing my homelab (Kubernetes clusters, self-hosted everything), brewing coffee with an amount of precision that my family finds unreasonable, strategizing over D&amp;D campaigns, and being a dedicated dad and husband. The homelab is where I experiment. The coffee is where I focus. The D&amp;D is where I accept that even the best-laid plans fall apart.' 'the en Beyond the Code paragraph, word for word'
text_has "$PT_HOME" 'Quando não estou pensando em sistemas distribuídos, você me encontra gerenciando meu homelab (clusters Kubernetes, self-hosting de tudo), preparando café com uma precisão que minha família acha excessiva, bolando estratégias em campanhas de D&amp;D e sendo pai dedicado e marido presente. O homelab é onde eu experimento. O café é onde eu foco. O D&amp;D é onde eu aceito que até os melhores planos desmoronam.' 'the pt-br Além do Código paragraph, word for word'
# The Signpost's links are the menu's: the set of hrefs inside the sentence is exactly
# the set in the navigation, in each language. Typing a URL into the sentence, or a menu
# entry that the sentence forgets, makes the two sets differ. Compared as sets, so the
# order the sentence mentions the sections in is the copy's business.
links_in() { # links_in <file> <sed-expression picking the region> -- its hrefs, one a line, unique
    tr -d '\n' < "$1" | sed -E "$2" | grep -oE 'href=[^ >]+' | sort -u
}
for lang in en pt; do
    if [ "$lang" = en ]; then file=$EN_HOME; else file=$PT_HOME; fi
    signpost=$(links_in "$file" 's#.*<p class=home-signpost>##; s#</p>.*##')
    menu=$(links_in "$file" 's#.*<div class=menu>##; s#<span class="menu-item delimiter">.*##')
    if [ -n "$signpost" ] && [ "$signpost" = "$menu" ]; then
        ok "the $lang Signpost links to exactly the sections the menu lists"
    else
        bad "the $lang Signpost links to exactly the sections the menu lists (signpost: $(echo $signpost), menu: $(echo $menu))"
    fi
done
# The one assertion in this script that reads source and not output, because the output
# cannot say who wrote a <div>: the page's wrapper, its classed paragraphs and its typed
# URLs were all authored in the content file, and what compiled from them looks the same
# whoever wrote it. The home page's Markdown holds prose, and a shortcode call, and no
# tags. (`{{<` opens a shortcode, and is not a tag.) With `unsafe = false` in config.toml
# Hugo already fails the build on a tag in any Markdown file; this is what still says so
# if someone turns that back on for a post, and it names the file.
for f in "$(dirname "${BASH_SOURCE[0]}")"/../content/_index.*.md; do
    if awk '/^---[[:space:]]*$/ { n++; next } n >= 2' "$f" | grep -qE '(^|[^{])</?[A-Za-z][A-Za-z0-9-]*([ />]|$)'; then
        bad "no layout HTML in $(basename "$f")"
    else
        ok "no layout HTML in $(basename "$f"), prose only"
    fi
done

# One measure, one left edge -- see docs/adr/0004. The profile block sits outside
# the wrapper that carries the 800px cap, so without this rule the tagline drifts
# 140px left of the prose on any screen wider than about 1690px. Invisible on a
# laptop, which is exactly why it needs asserting rather than eyeballing.
#
# The route list is asserted as a grid because the alignment of the four
# descriptions depends on it: under flex each description started wherever its own
# label ended, and `max-content` is what sizes the label track to the longest label
# in whichever language is rendering.
rule_sets '\.home \.home-greeting' 'max-width:800px' 'the greeting shares the 800px measure'
absent_from "$EN_HOME" '<hr' 'no rule between the routes and the last section'
absent_from "$PT_HOME" '<hr' 'nor on the pt-br home page'
rule_sets '\.home-intro' 'color:var\(--ink\)' 'the intro paragraph is body colour, not muted'

# Dark mode gave headings the same colour as the body text under them, so hierarchy
# rested on size alone. Light mode never had the problem: its body text is a
# near-black that already reads as the strongest thing on the page.
# Dark carries one grey. The muted tier used to be #a8a29e against body text at
# #a9a9b3 -- 1% apart, so a caption that was meant to read quieter than the
# paragraph under it read identically. Two tokens, one visible colour, and no way
# to tell from a screenshot which rule had won.
absent_from "$CSS" '#a8a29e' 'the second dark grey is gone'
rule_sets '\.portrait__sizes' 'color:var\(--muted\)' 'the headshot line is muted text, which in dark is the grey of the prose'

echo 'Headings outrank body text in dark'
rule_sets '\.single-title' 'color:var\(--heading\)' 'a title takes the heading colour, which dark makes the brighter one'
rule_sets '\.single \.content h2' 'color:var\(--heading\)' 'and so does a section heading, wherever it sits in the column'
rule_sets '\.home \.home-greeting' 'color:var\(--heading\)' 'the greeting is treated as a heading, not body text'
if awk -v h="$(contrast "$(token_value dark heading)" "$(token_value dark paper)")" -v i="$(contrast "$(token_value dark ink)" "$(token_value dark paper)")" 'BEGIN { exit !(h + 0 > i + 0) }'; then
    ok 'in dark a heading is brighter than the body text under it'
else
    bad 'in dark a heading is brighter than the body text under it'
fi

# About is where the biography went, and it is the only page that carries the
# photograph. The two sizes exist for event organisers, who ask by email today.
# The desk: a watercolour of the "Beyond the Code" paragraph, closing the page.
# Last and lazy, so the greeting stays the first thing painted; a still life, so
# the no-portrait decision above still holds.
echo 'Home page plate'
contains "$EN_HOME" 'class="plate plate--inline"' 'the en home page carries its plate'
contains "$PT_HOME" 'class="plate plate--inline"' 'and so does the pt-br home page'
in_order "$EN_HOME" 'Beyond the Code.*class="plate plate--inline"' 'the plate closes the page, after the paragraph it illustrates'
in_order "$PT_HOME" 'Além do Código.*class="plate plate--inline"' 'in pt-br too'
matches "$EN_HOME" 'class="plate plate--inline"><img [^>]*loading=lazy' 'the plate is lazy-loaded, behind the text'

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
rule_sets '\.single \.content \.portrait__sizes a' 'color:var\(--muted\)' 'the headshot line is one colour, label and links alike'
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
absent_from "$EN_ARCHIVE" 'entry__note' 'archive entries are rows, not write-ups'
rule_sets '\.entry \.entry__date' 'grid-column:2' 'archive meta sits in the right-hand column'
same_count "$EN_ARCHIVE" 'entry__title' 'entry__date' 'every archive row carries a date, off-site ones included'
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
same_count "$EN_SPEAKING" 'entry__title' 'entry__date' 'every en entry carries a date'
same_count "$EN_SPEAKING" 'entry__title' 'entry__meta' 'every en entry carries a venue'
# One talk given three times is one entry with three recordings, not three entries
# with the same title. These assert both halves: the entry appears once, and every
# stage it was given on is reachable.
occurs "$EN_SPEAKING" 'Designing for failure</h3>' 1 'the repeated talk is a single entry, not three rows'
contains "$EN_SPEAKING" 'youtu.be/BOn3R41UrV8' 'the GoLab recording is linked'
contains "$EN_SPEAKING" 'youtu.be/QWRPWb1Tzqs' 'the Golang Piter recording is linked'
contains "$EN_SPEAKING" 'youtu.be/DKhC_XH8fDs' 'the GoDays recording is linked'
contains "$PT_SPEAKING" 'youtu.be/QWRPWb1Tzqs' 'and all three in pt-br, with localized city names'
same_count "$PT_SPEAKING" 'entry__title' 'entry__date' 'every pt-br entry carries a date'
same_count "$PT_SPEAKING" 'entry__title' 'entry__meta' 'every pt-br entry carries a venue'

# Panels are their own group rather than talks with "Panel:" typed into the title.
# The negative assertion is the load-bearing one: the prefix is what the entries
# looked like before the group existed, and re-adding one by hand is the likely
# way this regresses -- it reads as fine in a diff and quietly makes the heading
# above it redundant.
#
# The panel type is asserted through its own modifier class, not the icon, because
# the icon is a Font Awesome name that a theme bump could rename.
echo 'Panels are a group, not a title prefix'
# "Roundtables" rather than the full heading: the ampersand survives as a bare
# `&` here but there is no guarantee it stays unescaped through a Goldmark or
# minifier change, and a needle that stops matching would make this pass
# vacuously. Same reasoning as the apostrophe-free needles above.
contains "$EN_SPEAKING" 'Roundtables' 'en panels have their own heading'
contains "$PT_SPEAKING" 'Painéis e Mesas Redondas' 'pt-br panels have their own heading'
occurs "$EN_SPEAKING" 'entry--panel' 2 'both en panels are typed as panels'
occurs "$PT_SPEAKING" 'entry--panel' 2 'both pt-br panels are typed as panels'
nowhere '>Panel: ' 'no entry carries the superseded title prefix'
# A panel leaves no recording, so the event page is the only thing to click. If
# this link goes, the entry becomes the one row on the page with no destination.
contains "$EN_SPEAKING" 'luma.com/ywjxiy8b' 'the en panel links to the event that hosted it'
contains "$PT_SPEAKING" 'luma.com/ywjxiy8b' 'the pt-br panel links to it too'

# Podcast appearances on their own pages, by layouts/episodes/single.html: chapter by
# chapter, a summary, the quotes and the lesson. Claude writes them from the
# transcript; the quotes are the only words on them that are Italo's. Most of what
# such a page promises is invisible when it breaks -- a quote whose link goes
# nowhere still reads fine, and a missing disclaimer leaves a page that reads as
# his.
#
# One entry per episode page: its slug and the id of its first chapter. A new
# episode page is a new line here, and gets every assertion below.
EPISODES=(
    "shipping-more-not-faster platform"
    "show-people-their-impact career"
)
echo 'Episode pages'
for entry in "${EPISODES[@]}"; do
    read -r slug first <<< "$entry"
    EN_EPISODE="$PUBLIC/episodes/$slug/index.html"
    PT_EPISODE="$PUBLIC/pt-br/episodes/$slug/index.html"
    exists "$EN_EPISODE" "$slug: the episode page is built"
    exists "$PT_EPISODE" "$slug: and its pt-br translation"
    contains "$EN_SPEAKING" "href=/episodes/$slug/>Highlights<" "$slug: its speaking entry links to it"
    contains "$PT_SPEAKING" "href=/pt-br/episodes/$slug/>Destaques<" "$slug: and the pt-br entry to the translation"
    # Said before anything else on the page, in both languages: Claude wrote it,
    # and only the quotes are his.
    contains "$EN_EPISODE" 'Written by Claude, not by Italo.' "$slug: the page says who wrote it"
    contains "$PT_EPISODE" 'Escrito pelo Claude, não pelo Italo.' "$slug: and so does the pt-br page"
    in_order "$EN_EPISODE" 'class=ep-disclaimer.*class=ep-map ' "$slug: before the first chapter, not in a colophon"
    # Not writing, so not where the writing is: the archive, the feeds, the tags.
    absent_from "$EN_ARCHIVE" "/episodes/$slug/" "$slug: the writing archive does not list it"
    absent_from "$PUBLIC/index.xml" "/episodes/$slug/" "$slug: the site feed does not carry it"
    absent_from "$PUBLIC/posts/index.xml" "/episodes/$slug/" "$slug: nor does the writing feed"
    absent_from "$EN_EPISODE" 'href=/tags/' "$slug: and it is filed under no tag"
    # The intro, then the chapter list, then the chapters. An earlier layout drew
    # the list into a slot the content marked; when the marker did not survive
    # rendering, the list landed after the last chapter. Asserted on order.
    in_order "$EN_EPISODE" "class=ep-map .*<h2 id=$first " "$slug: the chapter list sits above the first chapter"
    in_order "$PT_EPISODE" "class=ep-map .*<h2 id=$first " "$slug: and in pt-br"
    # The timeline pinned under the header is drawn from the same chapters as the
    # headings, one band each.
    same_count "$EN_EPISODE" 'class=ep-timeline__seg' 'class=ep-chapter data-chapter' "$slug: the timeline has one band per chapter"
    # Every quote can be heard: each names its speaker and links into the
    # recording. A count match, so a quote added without its link fails.
    same_count "$EN_EPISODE" 'class=ep-moment__who' 'class=ep-moment__play href="https://' "$slug: every en quote links to the moment it was said"
    same_count "$PT_EPISODE" 'class=ep-moment__who' 'class=ep-moment__play href="https://' "$slug: every pt-br quote does too"
    # Linked, not embedded. A player is a third-party host that loads on every
    # visit whether or not anyone presses play.
    absent_from "$EN_EPISODE" '<iframe' "$slug: the recording is linked, not embedded"
    absent_from "$EN_EPISODE" '<audio' "$slug: and no third-party audio player loads with the page"
    # The page's own words come from i18n/, and it still renders without them. It
    # has happened: a `hugo server` started before i18n/ existed renders every
    # string empty. A clean build is fine; this keeps such a page from shipping.
    contains "$EN_EPISODE" '>The lesson<' "$slug: the lessons carry their en label"
    contains "$PT_EPISODE" '>A lição<' "$slug: and their pt-br one, accented"
    contains "$PT_EPISODE" 'Capítulo' "$slug: pt-br chapter headings keep their accent"
    # Questions put to the reader (partials/episode/ask.html) arrive answered
    # without JavaScript, and every answer links to the moment in the recording
    # that gives it. Count matches, so they hold for a page with no questions too.
    same_count "$EN_EPISODE" 'class="ep-viz ep-ask' 'class=ep-ask__play' "$slug: every question's answer links into the recording"
    same_count "$PT_EPISODE" 'class="ep-viz ep-ask' 'class=ep-ask__play' "$slug: in pt-br too"
    same_count "$EN_EPISODE" 'data-ask=guess' 'class=ep-ask__controls hidden' "$slug: guess controls start hidden"
    same_count "$EN_EPISODE" 'data-ask=choice' 'ep-choice__option is-correct' "$slug: every choice arrives answered without JavaScript"
    matches "$EN_EPISODE" 'src=/js/episode\.[0-9a-f]+\.js integrity=' "$slug: the page script is served from this origin, with SRI"
    # The share card is the episode's own plate, not the site card, and a file.
    contains "$EN_EPISODE" "og:image\" content=\"https://italovietro.com/episodes/$slug/cover.jpg" "$slug: the preview card is the episode plate"
    exists "$PUBLIC/episodes/$slug/cover.jpg" "$slug: and the card is published"
    # The hero is above the fold, so it is the one Plate that is not lazy; every other
    # Plate on the page is (see 'Plates' below, which checks that for every page).
    matches "$EN_EPISODE" 'class="plate plate--hero"><img [^>]*fetchpriority=high' "$slug: the hero Plate is not lazy-loaded"
    matches "$PT_EPISODE" 'class="plate plate--hero"><img [^>]*fetchpriority=high' "$slug: nor is the pt-br one"
    occurs "$EN_EPISODE" 'fetchpriority=high' 1 "$slug: and it is the only eager image on the page"
done
# The toy model's days are invented, and the figure has to say so where the
# numbers are: the episode gives no breakdown of Parloa's cycle time, and a reader
# must not come away thinking it did.
contains "$PUBLIC/episodes/shipping-more-not-faster/index.html" 'The days are invented' 'the toy model says its numbers are made up'
contains "$PUBLIC/pt-br/episodes/shipping-more-not-faster/index.html" 'Os dias são inventados' 'in both languages'
# The timeline's full-width background is a painted shadow. A pseudo-element
# positioned out to the window's edges once drew its hairline, and gave every
# episode page a sideways scroll on every screen.
absent_from "$CSS" 'left:-100vmax' 'nothing on an episode page is laid out past the window'

# One measure (docs/adr/0004). The masthead and hero sit outside .content and
# take the cap explicitly; without it the title starts 140px left of the prose.
matches "$CSS" '\.episode>\.ep-disclaimer\{max-width:800px' 'the disclaimer takes the 800px measure'
rule_sets '\.single figure\.plate--hero' 'max-width:800px' 'and so does a hero Plate'

# Plates (partials/plate.html): one figure, `plate plate--<role>`, the role being hero,
# spot or inline. The role decides the framing (one stylesheet, _plate.scss), the
# `sizes` the browser is told and whether the image is eager; a page asks for a Plate
# by name and role, and never by a class of its own. Everything below is read off the
# compiled pages, so a Plate placed on a post tomorrow is covered the day it is placed.
echo 'Plates'
# plate_imgs <page> -- the <img> of every Plate on a page, one a line.
plate_imgs() { grep -oE '<figure class="plate plate--[a-z]+"><img [^>]*>' "$1" || true; }
# plates_lacking <page> <regex> -- how many of a page's Plates do not match it.
plates_lacking() { plate_imgs "$1" | { grep -cvE -- "$2" || true; }; }
# plates_sized_by_role <page> -- a spot Plate is told it is 480px wide, any other 800px.
plates_sized_by_role() {
    plate_imgs "$1" | awk '
        /plate--spot"/ { if ($0 !~ /sizes="[^"]*480px/) n++; next }
        { if ($0 !~ /sizes="[^"]*800px/) n++ }
        END { print n + 0 }'
}
plate_pages=("$EN_HOME" "$PT_HOME")
for entry in "${EPISODES[@]}"; do
    read -r slug _ <<< "$entry"
    plate_pages+=("$PUBLIC/episodes/$slug/index.html" "$PUBLIC/pt-br/episodes/$slug/index.html")
done
for page in "${plate_pages[@]}"; do
    name=${page#"$PUBLIC"/}; name=${name%index.html}; name=${name:-home}
    if [ "$(plate_imgs "$page" | wc -l | tr -d ' ')" -gt 0 ]; then ok "$name: carries a Plate"; else bad "$name: carries a Plate"; fi
    [ "$(plates_lacking "$page" 'width=[0-9]+ height=[0-9]+')" -eq 0 ] && ok "$name: every Plate declares its size, so nothing jumps when it loads" || bad "$name: every Plate declares its size"
    [ "$(plates_lacking "$page" 'loading=lazy|fetchpriority=high')" -eq 0 ] && ok "$name: every Plate is lazy, or the hero is eager" || bad "$name: every Plate is lazy, or the hero is eager"
    [ "$(plates_sized_by_role "$page")" -eq 0 ] && ok "$name: every Plate is told its width by its role" || bad "$name: every Plate is told its width by its role"
    own_class=$(grep -cE 'class="?(ep-plate|home-plate)' "$page" || true)
    [ "$own_class" -eq 0 ] && ok "$name: no Plate carries a page's own class" || bad "$name: no Plate carries a page's own class"
done
# A spot Plate is the one that sits beside its caption.
in_order "$PUBLIC/episodes/shipping-more-not-faster/index.html" 'class="plate plate--spot"><img [^>]*>[[:space:]]*<figcaption>' 'a spot Plate carries its caption beside it'
# The plates are watercolours with an alpha edge, saved as WebP at twice the measure. A
# PNG export is ten times the size and looks the same. Found from the pages rather than
# from a list of folders: every file a Plate links to, its resized widths included,
# wherever it lives.
plate_files=()
while IFS= read -r url; do
    plate_files+=("$PUBLIC$url")
done < <(grep -rhoE --include='*.html' '<figure class="plate plate--[a-z]+"><img [^>]*>' "$PUBLIC" | grep -oE '/[^ ",=]+\.webp' | sort -u)
if [ "${#plate_files[@]}" -ge 8 ]; then ok "the pages link ${#plate_files[@]} Plate files, resized widths included"; else bad "the pages link at least eight Plate files (found ${#plate_files[@]})"; fi
oversized=0
# (An empty array is unbound under `set -u` in the bash 3.2 macOS ships, hence the `+`.)
for plate in ${plate_files[@]+"${plate_files[@]}"}; do
    if [ ! -f "$plate" ]; then
        bad "every Plate a page links to is published (${plate#"$PUBLIC"/} is not)"
        oversized=1
    elif [ "$(wc -c < "$plate")" -ge 160000 ]; then
        bad "every plate is under 160KB (${plate#"$PUBLIC"/} is $(wc -c < "$plate") bytes)"
        oversized=1
    fi
done
[ "$oversized" -eq 0 ] && ok 'every plate is under 160KB'

# One masthead for a post and an Episode page (partials/masthead.html): a kicker, the
# headline, the dek and one quiet meta line. The two used to be unrelated: a post
# rendered through the theme's own template -- a 1.6rem sans title, a byline with an
# icon, a word count, a git hash -- and the Episode page carried a masthead of its
# own, inline in its layout, which Claude had written. Italo's pages looked like a
# theme default beside the pages he did not write.
#
# The pages are found rather than listed. A post is a local row of the writing
# archive (an Elsewhere row links off the site and has no page here), so a new post
# is covered by the loop the day it is written. The Episode pages are the list
# above. The loop asserts on both languages of each.
echo 'The masthead: one for posts and Episode pages'
POSTS=()
while IFS= read -r slug; do
    POSTS+=("$slug")
done < <(grep -oE 'class=entry__title><a href=/[^ >]+/>' "$EN_ARCHIVE" | sed -E 's#.*href=/([^ >]+)/>#\1#')
if [ "${#POSTS[@]}" -gt 0 ]; then
    ok "the writing archive links ${#POSTS[@]} posts written here, and each is checked in both languages"
else
    bad 'the writing archive links no post written here, so the masthead loop below would check nothing'
fi
MASTHEAD_POSTS=()
MASTHEAD_EPISODES=()
for slug in "${POSTS[@]}"; do
    MASTHEAD_POSTS+=("$PUBLIC/$slug/index.html" "$PUBLIC/pt-br/$slug/index.html")
done
for entry in "${EPISODES[@]}"; do
    read -r slug _ <<< "$entry"
    MASTHEAD_EPISODES+=("$PUBLIC/episodes/$slug/index.html" "$PUBLIC/pt-br/episodes/$slug/index.html")
done
for page in "${MASTHEAD_POSTS[@]}" "${MASTHEAD_EPISODES[@]}"; do
    name=${page#"$PUBLIC"/}; name=${name%/index.html}
    # The same markup on both kinds of page, in this order. `in_order`, because the
    # minifier keeps some newlines and the four parts sit on different lines.
    in_order "$page" 'class=masthead>.*class=masthead__kicker>.*<h1 class="single-title masthead__title">.*class=masthead__dek>.*class=masthead__meta>' "$name: a kicker, the headline, the dek and the meta line, in that order"
    occurs "$page" 'class=masthead>' 1 "$name: one masthead"
    occurs "$page" '<h1' 1 "$name: and one h1, which is the headline"
    # What the theme drew above a post and Italo decided against (#320): the icons
    # beside the byline, the date and the category, the word count, the title that
    # flipped in, and the theme's whole meta block. The class names, not the words:
    # "words" is a word a post may use.
    for gone in 'fa-user-circle' 'fa-calendar-alt' 'fa-pencil-alt' 'fa-clock' 'fa-folder' 'class=post-meta' 'animate__flipInX'; do
        absent_from "$page" "$gone" "$name: no theme meta furniture ($gone)"
    done
    # What the theme drew under it, and Italo decided against: the git hash beside
    # "Updated on", a link to the raw Markdown, and "Back | Home".
    absent_from "$page" 'class=git-hash' "$name: no git hash"
    absent_from "$page" 'class=link-to-markdown' "$name: no link to the Markdown"
    absent_from "$page" 'window.history.back()' "$name: no Back | Home"
    absent_from "$page" 'Updated on' "$name: nor the theme's Updated on line"
    # Sharing is part of the product (ADR-0005), so it stays, on a post and on an
    # Episode page alike.
    contains "$page" 'data-sharer=x' "$name: the share links are kept (X)"
    contains "$page" 'data-sharer=facebook' "$name: and Facebook"
    contains "$page" 'data-sharer=hackernews' "$name: and Hacker News"
done

# A post's meta line: who, when it was written, how long it takes. The date is written
# out in the page's language, with the day machine-readable beside it; the byline goes
# to the About page, where someone arriving from a search finds out who this is.
MONTHS_EN='January|February|March|April|May|June|July|August|September|October|November|December'
MONTHS_PT='janeiro|fevereiro|março|abril|maio|junho|julho|agosto|setembro|outubro|novembro|dezembro'
for page in "${MASTHEAD_POSTS[@]}"; do
    name=${page#"$PUBLIC"/}; name=${name%/index.html}
    case $name in
        pt-br/*)
            in_order "$page" 'class=masthead__meta><span class=masthead__line>Por <a href=/pt-br/sobre/ rel=author>[^<]+</a>.*<time datetime=[0-9]{4}-[0-9]{2}-[0-9]{2}>[0-9]{1,2} de ('"$MONTHS_PT"') de [0-9]{4}</time>.*[0-9]+ min de leitura' "$name: the meta line reads byline, date written out, reading time" ;;
        *)
            in_order "$page" 'class=masthead__meta><span class=masthead__line>By <a href=/about/ rel=author>[^<]+</a>.*<time datetime=[0-9]{4}-[0-9]{2}-[0-9]{2}>('"$MONTHS_EN"') [0-9]{1,2}, [0-9]{4}</time>.*[0-9]+ min read' "$name: the meta line reads byline, date written out, reading time" ;;
    esac
    # An "Updated" date is a claim about currency, and the audience is checking
    # (ADR-0005): it appears only for a later day than the one the post was written.
    published=$(grep -oE 'masthead__line>.{0,200}<time datetime=[0-9-]{10}' "$page" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)
    updated=$(grep -oE '(Updated|Atualizado em) <time datetime=[0-9-]{10}' "$page" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)
    if [ -z "$updated" ] || [[ $updated > $published ]]; then
        ok "$name: an update is announced only for a later day than the one it was written (${updated:-none})"
    else
        bad "$name: updated $updated is not after published $published"
    fi
done
# The dek is the post's description, or its own `subtitle` where it has one.
in_order "$PUBLIC/do-job-titles-matter/index.html" 'class=masthead__dek>I like to reflect on titles from time to time' 'the dek of a post is its description'
in_order "$PUBLIC/pt-br/do-job-titles-matter/index.html" 'class=masthead__dek>[A-ZÀ-Ú]' 'and in pt-br too'

# An Episode page's meta line: what it is based on, then when it came out, how long it
# runs and when it was written up. Same partial, so the strings are `masthead.*` keys,
# and the dates are written out in the page's language.
for page in "${MASTHEAD_EPISODES[@]}"; do
    name=${page#"$PUBLIC"/}; name=${name%/index.html}
    in_order "$page" 'class=masthead__kicker><span class=masthead__lead>[^<]+</span>.*class=masthead__meta><span class=masthead__line>.*<strong>[^<]+</strong>.*</span><span class=masthead__line>' "$name: the kicker leads with the show, and the meta line is two lines: what it is based on, then the dates"
    case $name in
        pt-br/*)
            matches "$page" 'Publicado em [0-9]{1,2} de ('"$MONTHS_PT"') de [0-9]{4}' "$name: released date written out"
            matches "$page" 'Escrito pelo Claude a partir da transcrição do episódio, em [0-9]{1,2} de ('"$MONTHS_PT"') de [0-9]{4}' "$name: and when it was written up" ;;
        *)
            matches "$page" 'Released ('"$MONTHS_EN"') [0-9]{1,2}, [0-9]{4}' "$name: released date written out"
            matches "$page" 'Written by Claude from a transcript of the episode, ('"$MONTHS_EN"') [0-9]{1,2}, [0-9]{4}' "$name: and when it was written up" ;;
    esac
    # The note that says who wrote the page comes straight after the masthead, ahead of
    # the plate and the chapters.
    matches "$page" '</div><p class=ep-disclaimer>' "$name: the disclaimer sits directly under the masthead"
    # An Episode page keeps the share links and none of the rest of the theme's post
    # footer: no tags (it is filed under none), no previous and next, no Updated line.
    absent_from "$page" 'class=post-nav' "$name: no previous and next"
    absent_from "$page" 'class=post-tags' "$name: no tags"
    # The visible links, not the `<link rel=prev>` the head carries for crawlers.
    absent_from "$page" 'class=prev rel=prev' "$name: nor a link to the previous episode"
    absent_from "$page" 'class=next rel=next' "$name: nor to the next"
done

# The footer of a post: tags, the share links and the previous and next posts. The
# last two are Italo's decision to keep. Every post here has tags and a neighbour.
for page in "${MASTHEAD_POSTS[@]}"; do
    name=${page#"$PUBLIC"/}; name=${name%/index.html}
    in_order "$page" 'id=post-footer>.*class=post-tags>.*href=/(pt-br/)?tags/' "$name: the footer lists its tags"
    # Every link there is, with an address. The assertion used to be `class=(prev|next)`
    # alone, which an `<a href class=prev>` satisfies: the section's neighbour can be an
    # Elsewhere post (`build.render: never`, no page here), whose RelPermalink is empty,
    # and six of the twelve pages shipped a previous or next link that went nowhere.
    matches "$page" '<a href=/[^ >]+ class=(prev|next) ' "$name: and links the post before or after it"
    if [ "$(grep -oE '<a [^>]*class=(prev|next)[^>]*>' "$page" | grep -vcE '^<a href=/[^ >]+ ' || true)" -eq 0 ]; then
        ok "$name: every previous and next link has an address"
    else
        bad "$name: a previous or next link has no address (its neighbour has no page here)"
    fi
    # The Contents box is the theme's, and kept: the floating one and the one inside
    # the article, and the list they share.
    contains "$page" 'id=toc-auto' "$name: the Contents box is kept (floating)"
    contains "$page" 'id=toc-static' "$name: and the one inside the article"
    matches "$page" '<nav id=TableOfContents>(<ul>|<li>)+<a href=#' "$name: with its entries (a post whose headings are all h3 opens on an empty list item)"
    # Its entries carry no emoji. A heading is written with one; a list to scan is not
    # improved by one in every row. Found by the bytes, not by a list of emoji, so a
    # new one is caught: a character outside the Basic Multilingual Plane (every
    # pictograph added since 2010, lead byte F0), a variation selector, a zero-width
    # joiner, or an entry opening on a symbol or dingbat (U+2600 to U+27BF).
    if grep -oE '<a href=#[^ >]+>[^<]*' "$page" | LC_ALL=C grep -qE $'\xf0|\xef\xb8\x8f|\xe2\x80\x8d|>\xe2[\x98-\x9e]'; then
        bad "$name: a Contents entry carries an emoji"
    else
        ok "$name: no Contents entry carries an emoji"
    fi
done
# Previous is the older post, next the newer, and an Elsewhere post (no page here) is
# skipped over rather than linked: the oldest post written here has no previous, and
# the newest no next.
in_order "$PUBLIC/do-job-titles-matter/index.html" '<a href=/cto-reading-list-1/ class=prev .*<a href=/cto-reading-list-2/ class=next ' 'a post'"'"'s previous link is the older post and its next the newer'
absent_from "$PUBLIC/5-ways-to-keep-coding-being-an-engineering-manager/index.html" 'class=prev ' 'the oldest post written here has no previous link, not one to a post published elsewhere'
absent_from "$PUBLIC/how-do-we-manage-our-github-organization-at-lyko/index.html" 'class=next ' 'nor the newest a next one'
# Only the Contents box is stripped: the heading it points to keeps its emoji.
contains "$PUBLIC/do-job-titles-matter/index.html" 'href=#-democratic-decisions>Democratic decisions</a>' 'a Contents entry is the heading without its emoji'
contains "$PUBLIC/do-job-titles-matter/index.html" '👨‍⚖️ Democratic decisions</h3>' 'and the heading itself is left as it was written'

# The stylesheet behind it (_masthead.scss and _post.scss). The masthead is built from the
# type module's pieces, so what is asserted here is that it reads them: the Measure, the
# kicker, the headline step an Episode page lifts to the display step, and tokens for
# every colour. What the theme drew in its own voice -- the amber "|" before each Contents
# entry, the tag icon, the arrows -- is asserted gone.
echo 'The masthead and a post: stylesheet'
rule_sets '\.masthead' 'max-width:800px' 'the masthead is the 800px Measure, so the headline starts on the prose edge'
rule_sets '\.masthead__kicker' 'text-transform:uppercase' 'a kicker is small caps'
rule_sets '\.masthead__kicker' 'color:var\(--muted\)' 'in the muted colour'
rule_sets '\.masthead__kicker a' 'color:var\(--heading\)' 'a category, which is the lead of its kicker, a step darker'
rule_sets '\.masthead__kicker a:hover' 'color:var\(--accent\)' 'and the Accent when pointed at'
rule_sets '\.masthead__meta' 'font-size:\.875rem' 'the meta line is the scale'"'"'s ui step'
rule_sets '\.masthead__line' 'display:block' 'and each line of it is its own block'
rule_sets '\.masthead__meta a' 'border-bottom:1px solid var\(--hairline\)' 'the byline is a link on a hairline'
rule_sets '\.masthead__meta a:hover' 'color:var\(--accent\)' 'which takes the Accent when pointed at'
rule_sets '\.single \.masthead__title' 'margin:0 0 1\.1rem' 'a headline inside a masthead takes no top margin of its own'
rule_sets '\.episode \.single-title\.masthead__title' 'font-size:3\.75rem' 'an Episode page lifts the headline to the display step'
rule_sets '\.episode \.single-title\.masthead__title' 'font-weight:400' 'at the regular weight, as it was'
rule_lacks '\.masthead.*' 'font-family:(Charter|Georgia)' 'no masthead rule spells out a stack'
rule_sets '\.toc \.toc-content ul a:first-child::before' 'content:none' 'a Contents entry has no amber mark before it'
rule_sets '\.toc \.toc-title' 'text-transform:uppercase' 'the Contents title is a kicker'
rule_sets '\.toc \.toc-content a' 'color:var\(--muted\)' 'its entries are muted'
rule_sets '#toc-auto \.toc-content a\.active' 'color:var\(--accent\)' 'and the one you are reading, in the floating box, takes the Accent'
rule_sets '#toc-auto' 'border-left:1px solid var\(--rule\)' 'the floating box has a hairline down its side, not the theme'"'"'s 4px bar'
rule_sets '\.single #toc-static' 'border-top:1px solid var\(--rule\)' 'the box inside the article is ruled above'
rule_sets '\.single #toc-static' 'border-bottom:1px solid var\(--rule\)' 'and below, not filled'
rule_sets '\.single \.post-footer' 'max-width:800px' 'the foot of a post is the Measure'
rule_sets '\.single>\.post-share' 'max-width:800px' 'and so is the share row an Episode page ends on'
rule_sets '\.post-tags li:not\(:last-child\)::after' 'content:"\\00B7"' 'tags are separated by a middle dot that follows its tag'
rule_sets '\.post-tags a' 'color:var\(--muted\)' 'a tag is muted'
rule_sets '\.post-tags a:hover' 'color:var\(--accent\)' 'and the Accent when pointed at'
rule_sets '\.post-share__links a' 'color:var\(--muted\)' 'a share link is muted'
rule_sets '\.post-share__label' 'text-transform:uppercase' 'under a kicker label'
rule_sets '\.post-nav a' 'color:var\(--heading\)' 'the neighbouring posts are titled in the heading colour'
rule_sets '\.post-nav a:hover' 'color:var\(--accent\)' 'and the Accent when pointed at'
rule_sets '\.single \.post-footer \.post-nav::before' 'content:none' 'the theme'"'"'s clearfix does not become a flex item'

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
rule_sets '\.archive \.group-title' 'color:var\(--muted\)' 'archive year headings stay muted rather than accented'
rule_lacks '\.single \.content h2' 'color:var\(--accent' 'section headings stay uncoloured'

# Line and Weibo were theme defaults, not choices, and neither is plausible for a
# readership reading in English and Portuguese.
echo 'Share buttons'
contains "$EN_POST" 'data-sharer=x' 'the Twitter button is still offered, under its new name'
contains "$EN_POST" 'data-sharer=facebook' 'Facebook is still offered'
contains "$EN_POST" 'data-sharer=hackernews' 'Hacker News is still offered'
nowhere 'data-sharer=line ' 'Line is offered on no page'
nowhere 'data-sharer=weibo ' 'Weibo is offered on no page'
# The 2025 theme bump switched these two on by default, which is how Line and Weibo
# got here in the first place.
nowhere 'data-sharer=threads ' 'Threads arrived with a theme bump and is off'
nowhere 'data-sharer=diaspora ' 'so did Diaspora'

echo 'Reading list'
nowhere '[Book Title]' 'the placeholder entry appears nowhere'
absent_from "$EN_READING" 'fa-star' 'no star ratings remain'
absent_from "$EN_READING" '<h4' 'entry titles are h3, leaving no gap in the heading outline'
contains "$EN_READING" 'Start Here' 'en has the featured section'
contains "$PT_READING" 'Comece por aqui' 'pt-br has the featured section, translated'
nowhere 'Must Read' 'the tier subheadings are gone from both languages'

# The reading list's in-page nav (the four anchor links under the intro) was styled
# through `.single .content > ul:first-of-type`, which names no page: it matched the
# first top-level list on every page that renders through .single. In "Do job titles
# matter?" that is the five-step job ladder, and it rendered as one muted, dotted,
# inline strip instead of a list. Every other top-level list lost its bullets to the
# `> ul` reset beside it. A page's rules reach only that page, through the markup
# the page itself declares -- here, the Entry (`.entry--book`), which only the
# reading list renders.
echo 'Reading-list styles stay on the reading list'
absent_from "$CSS" '.single .content>ul:first-of-type' 'no rule styles the first top-level list of every page'
rule_lacks '\.single \.content>ul' 'list-style:none' 'top-level lists keep their bullets site-wide'
rule_sets '\.single \.content:has\(\.entry--book\)>ul:first-of-type' 'display:flex' 'the reading list keeps its nav strip, behind its own Entries'
rule_sets '\.single \.content:has\(\.entry--book\)>ul:first-of-type li:not\(:first-child\)::before' 'content:"\\00B7"' 'with the dots between its links'
rule_sets '\.single \.content:has\(\.entry--book\)>ul:first-of-type li a' 'color:var\(--muted\)' 'its links are muted text, in both modes, still scoped to the reading list'
rule_sets '\.single \.content:has\(\.entry--book\) h2\+p' 'color:var\(--muted\)' 'and so are its section lines, which have one rule and so one guard'
# What the CSS is aimed away from: the ladder is a plain list in the page, in both
# languages, on a page that renders no Entry.
for post in "$PUBLIC/do-job-titles-matter/index.html" "$PUBLIC/pt-br/do-job-titles-matter/index.html"; do
    matches "$post" '<ul><li>Junior Software Developer/Engineer</li>' "the job ladder is a list (${post#"$PUBLIC"/})"
    absent_from "$post" 'entry--book' 'on a page with no reading-list Entry, so no reading-list rule reaches it'
done

# The Entry (CONTEXT.md): one item in a list, whichever list. It was five templates
# and three stylesheets, each restating its title, its muted line, its date column and
# its hover row, and the five had drifted: the writing archive's rows had no hover at
# all, the tag page's title was an h2 and its dates an unstyled grey, and a talk's
# title was 700 weight to a book's 600 because the theme's heading rule beat the
# declared one on one page and not the other. One partial, layouts/partials/entry.html,
# renders all of them, and one stylesheet, _entry.scss, sets them.
#
# What is asserted is the shape a visitor sees, on each list in both languages: every
# Entry has a title; the lists that date their Entries have a date in the right-hand
# column on every one, a count match so adding an Entry without one fails and adding a
# whole one does not; and the writing lists carry no note.
echo 'The Entry is one shape, on every list'
for page in "$EN_ARCHIVE" "$PT_ARCHIVE" "$EN_TAG" "$PT_TAG"; do
    name=${page#"$PUBLIC"/}
    matches "$page" 'class="entry entry--post"' "the writing list renders Entries ($name)"
    contains "$page" 'class=entry__head' "each with the Entry's one head ($name)"
    same_count "$page" 'class="entry entry--' 'entry__title' "every Entry has a title ($name)"
    same_count "$page" 'class="entry entry--' 'entry__date' "and a date ($name)"
    absent_from "$page" 'entry__note' "and none a note: a writing list is a list, not a set of write-ups ($name)"
done
# A tag page is a page with a title, so its title is the h1, as the archive's is. It was
# an h2, the defect the archive had already fixed (see layouts/_default/section.html),
# and the Entries below it are h2s, not h3s, so the outline has no gap.
for tag in "$EN_TAG" "$PT_TAG"; do
    matches "$tag" '<h1 class="single-title' "a tag page opens on an h1 (${tag#"$PUBLIC"/})"
    absent_from "$tag" '<h2 class="single-title' 'and not on an h2'
    in_order "$tag" '<h1 class="single-title[^>]*>[^<]*</h1>.*<h2 class=entry__title>' 'its Entries are h2s below it, leaving no gap in the outline'
done

# The speaking page's Entries are the same shape: a title, a venue on the muted line,
# a date, links on that line, and no note. A talk's title is plain text, and its links
# (Highlights, Watch, a recording per city, Slides, Event) sit on the meta line, so
# there is one more thing here than on the writing lists and it is the links, not a
# different shape.
for page in "$EN_SPEAKING" "$PT_SPEAKING"; do
    name=${page#"$PUBLIC"/}
    matches "$page" 'class="entry entry--(talk|panel|podcast|host)"' "the speaking page renders Entries ($name)"
    contains "$page" 'class=entry__head' "each with the Entry's one head ($name)"
    same_count "$page" 'class="entry entry--' 'entry__title' "every Entry has a title ($name)"
    same_count "$page" 'class="entry entry--' 'entry__date' "and a date ($name)"
    same_count "$page" 'class="entry entry--' 'entry__meta' "and a venue on the muted line ($name)"
    absent_from "$page" 'entry__note' "and none a note: the speaking page is a list, not a set of write-ups ($name)"
    absent_from "$page" '<h4' "titles are h3s under the group's h2, leaving no gap in the outline ($name)"
done
# What links is written per language. The links' words were hard-coded English in the
# shortcode, so the Portuguese page said "Watch", "Slides" and "Event" between
# Portuguese cities and a Portuguese heading, and a visitor reading it in Portuguese
# was the only one who noticed. The language's words now come from i18n/, and a missing
# one fails the build (build.sh prints missing translations and panics on a warning).
contains "$EN_SPEAKING" '>Watch<' 'en: a recording says Watch'
contains "$EN_SPEAKING" '>Slides<' 'en: a talk with slides says Slides'
contains "$EN_SPEAKING" '>Event<' 'en: a panel with an event page says Event'
contains "$PT_SPEAKING" '>Assistir<' 'pt-br: a recording says Assistir'
contains "$PT_SPEAKING" '>Apresentação<' 'pt-br: a talk with slides says Apresentação'
contains "$PT_SPEAKING" '>Evento<' 'pt-br: a panel with an event page says Evento'
absent_from "$PT_SPEAKING" '>Watch<' 'pt-br has no English Watch'
absent_from "$PT_SPEAKING" '>Slides<' 'pt-br has no English Slides'
absent_from "$PT_SPEAKING" '>Event<' 'pt-br has no English Event'
# Upcoming is a list of Entries too, rendered through the same partial. It renders
# nothing -- not even its heading -- while data/upcoming.yaml has no future date, which
# is most of the time, so this asserts whichever half the data allows: with none, no
# heading and no Entry; with one, the heading opens a list of Entries that carry a
# calendar icon, a title and a date. (The general count matches above already require
# each Upcoming Entry to have a title, a date and a venue.)
for page in "$EN_SPEAKING" "$PT_SPEAKING"; do
    if grep -qF 'entry--upcoming' "$page"; then
        in_order "$page" '<h2 class=upcoming-title>[^<]+</h2><div class="entry entry--upcoming">' "an Upcoming heading opens its Entries (${page#"$PUBLIC"/})"
        contains "$page" 'fa-calendar-day' 'and each carries the calendar icon'
    else
        absent_from "$page" 'upcoming-title' "with nothing upcoming there is no heading either (${page#"$PUBLIC"/})"
    fi
done

# The reading list's Entries are the same shape with a note, which is the one list that
# carries one (CONTEXT.md used to say all three did; the speaking page and the archive
# dropped theirs by decision). A book has no date: a third of the list is newsletters
# and podcasts, which have no year you could honestly give. Its title leaves the site,
# so it opens in a new tab, and is an h3 under the section's h2.
for page in "$EN_READING" "$PT_READING"; do
    name=${page#"$PUBLIC"/}
    matches "$page" 'class="entry entry--book' "the reading list renders Entries ($name)"
    contains "$page" 'class=entry__head' "each with the Entry's one head ($name)"
    same_count "$page" 'class="entry entry--' 'entry__title' "every Entry has a title ($name)"
    same_count "$page" 'class="entry entry--' 'entry__note' "and a note, the one list that has them ($name)"
    absent_from "$page" 'entry__date' "and no date ($name)"
    matches "$page" '<h3 class=entry__title><a href=https?://[^ >]+ target=_blank rel="noopener noreferrer">' "a title is an h3 link that opens in a new tab ($name)"
    contains "$page" 'entry--featured' "and the featured set is still there ($name)"
done
# The two weights of a book, in the stylesheet: compact puts the author on the title's
# line, featured gives it room. And neither has an edge of its own, in either mode.
rule_sets '\.entry--book:not\(\.entry--featured\) \.entry__head' 'display:flex' "a compact book's author shares its title's line"
rule_sets '\.entry--featured \.entry__head>\.entry__title' 'font-size:1\.375rem' 'a featured title is a step up the scale'
rule_lacks '\.entry--featured.*' 'border-left' 'a featured Entry has no edge of its own: size and space say it is featured'

# The stylesheet's half of "one": no per-page stylesheet restates an Entry's title, meta
# or date, because the class names those rules wore no longer exist anywhere in the
# build. The date column's figures are set by exactly one rule.
echo 'The Entry is set once'
nowhere 'book-entry' 'no page carries the reading list'"'"'s old Entry classes, in markup or in CSS'
nowhere 'talk-entry' 'nor the speaking page'"'"'s'
# The archive's are checked on the four pages that were ours, not everywhere: the theme
# keeps an `archive-item` of its own in its stylesheet and on its categories page.
absent_from "$CSS" 'archive-item__' 'nor the archive'"'"'s, in CSS'
for page in "$EN_ARCHIVE" "$PT_ARCHIVE" "$EN_TAG" "$PT_TAG"; do
    absent_from "$page" 'archive-item' "nor the archive's or a tag page's, in markup (${page#"$PUBLIC"/})"
done
if [ "$(rules_with '.*entry__date' 'font-variant-numeric:tabular-nums')" -eq 1 ]; then
    ok 'one rule sets the date column in tabular figures'
else
    bad "one rule sets the date column in tabular figures (got $(rules_with '.*entry__date' 'font-variant-numeric:tabular-nums'))"
fi
rule_sets '\.entry \.entry__head>\.entry__title' 'margin:0' 'a title beats the theme'"'"'s heading margin, which would otherwise float it'
rule_sets '\.entry \.entry__head>\.entry__title' 'font-weight:600' 'and its weight, so a title is the same on every list'

# One voice for the site -- see docs/adr/0006: serif to read, sans to navigate.
#
# The serif existed on the two Episode pages and nowhere else, declared in the last
# stylesheet imported, so no other page could reach it; a post's title was the
# theme's 1.6rem sans while the Episode title above a near-identical masthead was a
# 60px serif. These assert the rule rather than any one page: every headline takes
# the one stack, running text takes it, and what you navigate by does not.
#
# The stack is a custom property, written once, and every use is `var(--font-serif)`.
# That is what makes "a post title, the archive title and an Episode title compile
# to the same serif" assertable at all: a stack pasted into each rule can drift by
# one family name in one place, and look identical in a diff. The sans is the
# theme's own `--global-font-family`.
echo 'One type voice: serif to read, sans to navigate'
occurs "$CSS" 'Bitstream Charter' 1 'the serif stack is written once'
rule_sets ':root' '--font-serif: ?Charter' 'and named as a custom property, for every use to read'
absent_from "$CSS" 'font-family:system-ui,-apple-system,Segoe UI,Roboto,Emoji' 'no page stylesheet spells out the sans stack either'
# Headlines: a post, the archive and an Episode page each say `var(--font-serif)`,
# and that is one stack, so the three cannot disagree.
rule_sets '\.single \.single-title' 'font-family:var\(--font-serif\)' 'a post title is set in the serif'
rule_sets '\.archive \.single-title' 'font-family:var\(--font-serif\)' 'so is the archive title'
rule_sets '\.episode \.single-title\.masthead__title' 'font-family:var\(--font-serif\)' 'and so is an Episode page title, from the same stack'
rule_sets '\.home \.home-greeting' 'font-family:var\(--font-serif\)' 'the Greeting is a headline, so it is serif too'
rule_sets '\.single \.content>h2' 'font-family:var\(--font-serif\)' 'article section headings are serif'
rule_sets '\.single \.content>h3' 'font-family:var\(--font-serif\)' 'and so are its subheadings'
# Not the headings inside a shortcode: an Entry title is an h3 too, and it is a title
# in a list, not a subhead. An article rule that reached it would also outrank the
# Entry's own, which is how the speaking page's titles once grew to 1.375rem.
rule_lacks '\.single \.content h[1-6]' 'font-family:var\(--font-serif\)' 'no article heading rule reaches into the markup of an Entry'
rule_sets '\.masthead__dek' 'font-family:var\(--font-serif\)' 'a dek is serif'
# Running text. The paragraph has no rule of its own: it inherits from the column,
# so a post, About and an Episode page read in the same face.
rule_sets '\.single \.content' 'font-family:var\(--font-serif\)' 'running text on posts, About and Episode pages is serif'
rule_lacks '\.single \.content p' 'font-family' 'a paragraph inherits it rather than choosing'
# Furniture. The page itself is sans, so the header, nav, footer and every
# post-meta line are without a declaration; what is asserted is that no rule
# reaching them takes the serif, and that what sits inside the serif column but is
# not prose opts back out.
rule_sets 'html' 'font-family:var\(--global-font-family\)' 'the page is sans, so the header and footer are'
rule_lacks '.*(header|footer|menu|toc|post-meta|post-footer).*' 'font-family:var\(--font-serif\)' 'nothing that navigates takes the serif'
rule_sets '\.masthead__kicker' 'font-family:var\(--global-font-family\)' 'a kicker is sans'
rule_sets '\.single \.content:has\(\.entry--book\)>ul:first-of-type' 'font-family:var\(--global-font-family\)' 'the reading list nav is sans, though the column around it is serif'
rule_sets '\.entry' 'font-family:var\(--global-font-family\)' 'Entries are sans, on every list: the speaking page, the writing lists, and the reading list'
rule_sets '\.single \.content table' 'font-family:var\(--global-font-family\)' 'tables are sans'
rule_sets '\.single \.content figcaption' 'font-family:var\(--global-font-family\)' 'and so are figure captions'
# What the theme decorates, undone. A blockquote was a blue box with a thick blue bar
# -- a second accent unrelated to the palette (docs/adr/0001) -- and every heading
# carried an amber "#" or "|" before it. A quote is set in italic behind a quiet rule;
# a heading is just the words. An Episode page's quotes are its own, set upright.
rule_sets '\.single \.content blockquote' 'background:none' 'a blockquote is not the theme blue box'
rule_sets '\.single \.content blockquote' 'font-style:italic' 'it is italic, behind a rule'
rule_sets '\[theme=dark\] \.single \.content blockquote' 'background-color:transparent' 'and in dark, where the theme tints it again'
rule_sets '\[theme=dark\] \.single \.content blockquote' 'border-left-color:var\(--rule\)' 'and recolours its bar, which the theme draws again in dark'
rule_sets '\.single \.content blockquote' 'border-left:2px solid var\(--rule\)' 'the bar is the rule colour, a grey and not an accent'
rule_sets '\.episode \.content \.ep-moment blockquote' 'font-style:normal' 'an Episode quote stays upright'
rule_sets '\.single \.content \.header-mark' 'display:none' 'headings carry no accent mark'
# One measure, one number (docs/adr/0004): the column and the title above it.
rule_sets '\.single \.content' 'max-width:800px' 'the column is the 800px measure'
rule_sets '\.single \.single-title' 'max-width:800px' 'and the title above it starts on the same edge'
# The module comes first. With the headings' rules in it, and none of them
# restated later, which file was imported last no longer decides a heading.
for marker in 'home-signpost' 'portrait__img' 'entry__head' 'entry__meta' 'masthead__kicker'; do
    in_order "$CSS" ":root\{--font-serif:.*\.$marker" "the type module is compiled before .$marker"
done

# Colour is a set of tokens, switched once -- see docs/agents/architecture.md.
#
# Every colour the site chooses is a custom property on :root, overridden once on
# [theme=dark] (the theme sets that attribute on <body>, from the visitor's choice or
# their OS). A component reads `var(--ink)` and does not know which mode it is in, so
# there is no dark copy of it to forget, and no value written twice. Before this, about
# a seventh of the stylesheet restated colours per mode, three selectors to a rule, and
# one of the three (`[theme=auto]`) never matched: nothing sets that attribute.
#
# What is asserted is the token's value in each mode. The ratios beside the values in
# the stylesheet were measured by hand, once; contrast_of measures them again from the
# compiled values, so changing one cannot quietly take a pair under its threshold.
echo 'Colour tokens: one value per mode'
token paper '#fff' '#292a2d' 'the page'
token header '#f8f8f8' '#252627' 'the header bar'
token ink '#161209' '#a9a9b3' 'body text'
token heading '#161209' '#e7e5e4' 'headlines'
token muted '#57534e' '#a9a9b3' 'muted text'
token hairline '#f0f0f0' '#363636' 'the faint divider'
token rule '#d6d3d1' '#4b4d52' 'a visible rule'
token accent '#b45309' '#f59e0b' 'the Accent'
token accent-hover '#92400e' '#fbbf24' 'the Accent on hover'
token accent-wash 'rgba(180,83,9,0.06)' 'rgba(245,158,11,0.1)' 'the tint under a hovered Entry'
token selection-ink '#161209' '#fff' 'text over a selection'
token entry-podcast '#9b59b6' '#bb8fce' 'the podcast icon'
token entry-panel '#0f766e' '#5eead4' 'the panel icon'
token ep-ink '#3d4f7a' '#9db0e0' 'the Episode ink'
token on-ink '#fff' '#1c1d20' 'text on a filled ink'
token ep-fill-1 '#e7e5e4' '#3a3b40' 'figure fill 1'
token ep-fill-2 '#d6d3d1' '#44464b' 'figure fill 2'
token ep-fill-3 '#cfcac4' '#4e5056' 'figure fill 3'
token ep-fill-4 '#c4beb7' '#575a60' 'figure fill 4'
token ep-lesson '#f7f2e7' 'rgba(255,255,255,0.045)' 'the lesson box'
token ep-tip '#fffdf7' '#34353a' 'the timeline preview'
token ep-bar '#78716c' '#8a8c93' 'the guess bar'
token ep-paper '#efe7d4' '#cfc5ae' 'the timeline ruler'
token plate-filter 'none' 'brightness(0.9)' 'plate dimming'
# The ruler is a printed object, in both themes: the ink on it does not follow the mode.
token_constant ep-ruler-ink '#3d4f7a' 'the ink printed on the ruler'
# Dark carries one grey for text. It was #a8a29e against body text at #a9a9b3, 1% apart,
# so a caption meant to read quieter than a paragraph read identically.
if [ "$(token_value dark muted)" = "$(token_value dark ink)" ]; then
    ok 'in dark, muted text is the body grey: the tier is carried by size and weight'
else
    bad 'in dark, muted text is the body grey: the tier is carried by size and weight'
fi

echo 'Colour tokens: every pair clears its threshold in both modes'
contrast_of ink paper 4.5 'body text on the page'
contrast_of heading paper 4.5 'headlines on the page'
contrast_of muted paper 4.5 'muted text on the page'
contrast_of accent paper 4.5 'the Accent on the page (ADR-0001)'
contrast_of accent-hover paper 4.5 'the Accent on hover'
contrast_of accent header 4.5 'the Accent on the header, for the active nav item'
contrast_of entry-podcast paper 3 'the podcast icon, which is not text'
contrast_of entry-panel paper 3 'the panel icon'
contrast_of ep-ink paper 4.5 'the Episode ink on the page'
contrast_of on-ink ep-ink 4.5 'text on a filled Episode ink'
contrast_of ep-bar paper 3 'the guess bar, which is not text'
contrast_of heading ep-fill-1 4.5 'text on figure fill 1'
contrast_of heading ep-fill-2 4.5 'text on figure fill 2'
contrast_of heading ep-fill-3 4.5 'text on figure fill 3'
contrast_of heading ep-fill-4 4.5 'text on figure fill 4'
contrast_of heading ep-tip 4.5 'text on the timeline preview'
contrast_of ep-ruler-ink ep-paper 4.5 'the ink printed on the ruler'

# A component takes a token and says nothing about dark. Each rule below is the one rule
# for its element, in both modes; the checks under 'no dark copies' assert there is no second.
echo 'Colour tokens: components read them'
rule_sets '\.footer-social a' 'color:var\(--muted\)' 'footer links are muted text'
rule_sets '\.footer-social a' 'border-bottom:1px solid var\(--hairline\)' 'on a hairline'
rule_sets '\.footer-social a:hover' 'color:var\(--accent\)' 'that takes the Accent when pointed at'
rule_sets '\.masthead__dek' 'color:var\(--heading\)' 'a dek is set in the heading colour'
rule_sets '\.single \.content>hr' 'border-top:1px solid var\(--hairline\)' 'a rule across the column is the hairline'
rule_sets '\[theme=dark\] \.single \.content>hr' 'border-top-color:var\(--hairline\)' 'and is recoloured in dark, where the theme draws its own'
rule_sets '\.single figure\.plate img' 'filter:var\(--plate-filter\)' 'a Plate, wherever it is, is dimmed by the token, not by a dark rule'
occurs "$CSS" 'filter:var(--plate-filter)' 1 'and that is the one rule that dims a Plate, the home page'"'"'s and the Episode pages'"'"' alike'
absent_from "$CSS" 'ep-plate' 'no Episode-page Plate rules: one stylesheet frames every Plate'
absent_from "$CSS" 'home-plate' 'no home-page Plate rules either'
rule_sets '\.single figure\.plate' 'margin:2\.5rem 0' 'every Plate has the same room above and below it'
rule_sets '\.single figure\.plate--hero' 'margin-top:0' 'a hero Plate sits straight under the masthead'
rule_sets '\.single figure\.plate--spot' 'grid-template-columns:3fr 2fr' 'a spot Plate is three fifths of the Measure, its caption beside it'
rule_sets '\.single \.content \.portrait__sizes a' 'border-bottom:1px solid var\(--hairline\)' 'the headshot links are underlined in the hairline'
rule_sets '\.single \.content \.portrait__sizes a:hover' 'color:var\(--accent\)' 'and take the Accent when pointed at'
rule_sets '\.entry \.entry__title a' 'color:var\(--accent\)' 'an Entry title, in the archive and on every list, is a link, so the Accent'
rule_sets '\.entry \.entry__title a:hover' 'color:var\(--accent-hover\)' 'a step darker when pointed at'
rule_sets '\.entry \.entry__date' 'color:var\(--muted\)' 'Entry dates are muted'
rule_sets '\.archive-intro p' 'color:var\(--muted\)' 'and so is the line under the archive title'
rule_sets '\.archive \.group-title' 'border-bottom:1px solid var\(--hairline\)' 'year headings sit on a hairline'
rule_sets '\.single \.content>h2:has\(~\.entry\)' 'border-bottom:1px solid var\(--hairline\)' 'a heading above a list of Entries sits on a hairline, on the reading list and the speaking page alike: found by the Entries after it, not by a page'
rule_sets '\.single \.content:has\(\.entry--book\)>ul:first-of-type li:not\(:first-child\)::before' 'color:var\(--muted\)' 'the dots in the reading-list nav are muted'
rule_sets '\.single \.content:has\(\.entry--book\)>ul:first-of-type li a:hover' 'color:var\(--accent\)' 'and its links take the Accent when pointed at'
rule_sets '\.entry \.entry__note' 'color:var\(--ink\)' 'a note is body text'
rule_sets '\.entry \.entry__icon' 'color:var\(--muted\)' 'an Entry icon is muted until its kind says otherwise'
rule_sets '\.entry \.entry__meta' 'color:var\(--muted\)' 'the venue and the author are muted'
rule_sets '\.entry \.entry__links a' 'color:var\(--accent\)' 'links on the meta line are links, so the Accent'
rule_sets '\.entry \.entry__links a:hover' 'color:var\(--accent-hover\)' 'a step darker when pointed at'
rule_sets '\.entry--talk \.entry__icon' 'color:var\(--accent\)' 'a talk is the Accent'
rule_sets '\.entry--host \.entry__icon' 'color:var\(--accent\)' 'so is a hosted show'
rule_sets '\.entry--upcoming \.entry__icon' 'color:var\(--accent\)' 'and so is what is next, in both modes'
rule_sets '\.entry--panel \.entry__icon' 'color:var\(--entry-panel\)' 'a panel is teal'
rule_sets '\.entry--podcast \.entry__icon' 'color:var\(--entry-podcast\)' 'a podcast is purple'
rule_sets '\.entry:hover' 'background-color:var\(--accent-wash\)' 'a hovered Entry is washed with the Accent, on every list'
rule_sets '\.entry:hover' 'border-left-color:var\(--accent\)' 'and gains an Accent edge'
rule_sets '\.entry:focus-within' 'background-color:var\(--accent-wash\)' 'a focused one gets the same'
rule_sets 'a:focus-visible' 'outline:2px solid var\(--accent\)' 'the focus ring is the Accent'
rule_sets '::selection' 'color:var\(--selection-ink\)' 'selected text takes its colour from the token'
rule_sets '#header-mobile \.menu \.menu-item\.active' 'color:var\(--accent\)' 'the active mobile nav item takes the Accent'
rule_sets '#header-mobile \.menu \.menu-item\.active' 'border-left:3px solid var\(--accent\)' 'and its edge'

# The Episode pages, the largest single user of colour. Each is one rule for both modes.
# The ruler is printed paper in both, so its ink is a constant, and its ticks are that
# ink at an alpha.
rule_sets '\.masthead__lead' 'color:var\(--heading\)' 'the lead of a kicker, a show or a category, is a heading colour'
rule_sets '\.masthead__meta' 'color:var\(--muted\)' 'the meta line is muted'
rule_sets '\.masthead__meta strong' 'color:var\(--heading\)' 'with its figures a step up'
rule_sets '\.episode \.ep-disclaimer' 'color:var\(--ink\)' 'the disclaimer is body text, not fine print'
rule_sets '\.episode \.ep-disclaimer' 'border:1px solid var\(--rule\)' 'outlined in the rule colour'
rule_sets '\.episode \.ep-disclaimer strong' 'color:var\(--ep-ink\)' 'its emphasis in the Episode ink'
rule_sets '\.episode \.ep-disclaimer a' 'color:var\(--accent\)' 'and its link, being a link, in the Accent'
rule_sets '\.episode \.content \.ep-chapter' 'border-bottom:1px solid var\(--hairline\)' 'a chapter sits on a hairline'
rule_sets '\.episode \.content \.ep-moment' 'border-left:2px solid var\(--rule\)' 'a quote has a rule beside it'
rule_sets '\.episode \.content \.ep-moment--pull blockquote::before' 'color:var\(--rule\)' 'a pull quote hangs a quotation mark in the same grey'
rule_sets '\.episode \.content \.ep-map__heading' 'color:var\(--heading\)' 'the map heading is a heading colour'
rule_sets '\.episode \.content \.ep-map__legend' 'border-top:1px solid var\(--rule\)' 'the legend sits between two rules'
rule_sets '\.episode \.content \.ep-map__legend a' 'border-bottom:1px solid var\(--rule\)' 'one under each row'
rule_sets '\.episode \.content \.ep-map__legend \.ep-map__num' 'color:var\(--muted\)' 'with muted numbers'
rule_sets '\.episode \.content \.ep-map__legend a\.is-current \.ep-map__num' 'color:var\(--ep-ink\)' 'the current one in the Episode ink'
rule_sets '\.episode \.ep-timeline' 'background:var\(--header\)' 'the timeline bar is the header colour'
rule_sets '\.episode \.ep-timeline' 'box-shadow:0 0 0 100vmax var\(--header\)' 'out to the edge of the window'
rule_sets '\.episode \.ep-timeline__clock b' 'color:var\(--heading\)' 'its clock is a heading colour'
rule_sets '\.episode \.ep-timeline__ruler' 'background-color:var\(--ep-paper\)' 'the ruler is the paper token'
rule_sets '\.episode \.ep-timeline__label' 'color:var\(--ep-ruler-ink\)' 'and is printed in the ruler ink, which is the same in both modes'
rule_sets '\.episode \.ep-timeline__head' 'background:var\(--ep-ruler-ink\)' 'as is the playhead'
contains "$CSS" 'rgba(61,79,122,0.55)' 'its ticks are that ink at an alpha, computed from the one value'
rule_sets '\.episode \.content \.ep-hl__lesson' 'background:var\(--ep-lesson\)' 'the lesson box is the lesson token'
rule_sets '\.episode \.content \.ep-hl__lesson' 'border-left:3px solid var\(--ep-ink\)' 'with an ink edge'
rule_sets '\.episode \.content \.ep-hl__lesson-kicker' 'color:var\(--ep-ink\)' 'and an ink kicker'
rule_sets '\.episode \.content \.ep-viz' 'border-top:2px solid var\(--heading\)' 'a figure opens on a heavy rule'
rule_sets '\.episode \.content \.ep-viz' 'border-bottom:1px solid var\(--rule\)' 'and closes on a hairline'
rule_sets '\.episode \.content \.ep-viz__title' 'color:var\(--heading\)' 'its title is a heading colour'
rule_sets '\.episode \.content \.ep-viz__kicker' 'color:var\(--muted\)' 'its kicker is muted'
rule_sets '\.episode \.content \.ep-viz__button' 'background:var\(--heading\)' 'a button is a solid of the heading colour'
rule_sets '\.episode \.content \.ep-viz__button' 'color:var\(--on-ink\)' 'with the text that goes on one'
rule_sets '\.episode \.content \.ep-viz__toggle' 'color:var\(--ink\)' 'a toggle is body text'
rule_sets '\.episode \.content \.ep-viz__toggle' 'border:1px solid var\(--rule\)' 'in a box'
rule_sets '\.episode \.content \.ep-viz__toggle-box' 'border:1\.5px solid var\(--muted\)' 'its checkbox is muted until pressed'
rule_sets '\.episode \.content \.ep-viz__toggle\[aria-pressed="true"\] \.ep-viz__toggle-box' 'background:var\(--ep-ink\)' 'and the Episode ink when pressed'
rule_sets '\.episode \.content \.ep-viz__toggle\[aria-pressed="true"\] \.ep-viz__toggle-box::after' 'border:solid var\(--on-ink\)' 'with a tick the ink can carry'
rule_sets '\.episode \.content \.ep-guess input\[type="range"\]' 'accent-color:var\(--ep-ink\)' 'a slider takes the ink'
rule_sets '\.episode \.content \.ep-guess__bar' 'background:var\(--ep-fill-1\)' 'a guess track is the first fill'
rule_sets '\.episode \.content \.ep-guess__bar>span' 'background:var\(--ep-bar\)' 'the reader bar is its own token'
rule_sets '\.episode \.content \.ep-guess__row--real \.ep-guess__bar>span' 'background:var\(--ep-ink\)' 'and the answer is the ink'
rule_sets '\.episode \.content \.ep-choice__option' 'color:var\(--ink\)' 'a choice is body text'
rule_sets '\.episode \.content \.ep-choice__option' 'border:1px solid var\(--rule\)' 'in a box'
rule_sets '\.episode \.content \.ep-choice__option\.is-correct' 'background:var\(--ep-ink\)' 'the right one is filled with the ink'
rule_sets '\.episode \.content \.ep-choice__option\.is-correct' 'color:var\(--on-ink\)' 'and its text is the colour for that'
rule_sets '\.episode \.content \.ep-choice__option\.is-wrong' 'color:var\(--muted\)' 'the wrong one steps back'
for n in 1 2 3 4; do
    rule_sets "\.episode \.content \.ep-model__seg--$n" "background:var\(--ep-fill-$n\)" "stage band $n is fill $n"
done
rule_sets '\.episode \.content \.ep-model__seg' 'color:var\(--heading\)' 'the text on a band is a heading colour'
rule_sets '\.episode \.content \.ep-model__seg--accent' 'background:var\(--ep-ink\)' 'the highlighted band is the ink'
rule_sets '\.episode \.content \.ep-model__seg--accent' 'color:var\(--on-ink\)' 'with the text that goes on it'
rule_sets '\.episode \.content \.ep-flow__steps::before' 'background:var\(--rule\)' 'the rail is the rule colour'
rule_sets '\.episode \.content \.ep-flow__step::before' 'background:var\(--paper\)' 'a station is the page until lit'
rule_sets '\.episode \.content \.ep-flow__branch' 'border:1px solid var\(--rule\)' 'a branch is boxed'
rule_sets '\.episode \.content \.ep-flow \.ep-flow__branch\.is-taken' 'border-color:var\(--ep-ink\)' 'the one taken in the ink'
absent_from "$CSS" 'ep-station-dark' 'a lit station has one animation, whose colours are tokens'
rule_sets '\.episode \.ep-timeline__tip' 'background:var\(--ep-tip\)' 'the preview is its own token'
rule_sets '\.episode \.ep-timeline__tip' 'color:var\(--heading\)' 'with heading-coloured text'
rule_sets '\.episode \.ep-timeline__tip-clock' 'color:var\(--ep-ink\)' 'and an ink clock'
rule_sets '\.episode \.ep-timeline__moment\.is-hot' 'background:var\(--ep-ink\)' 'a hovered quote dot is the ink'
rule_sets '\.episode \.content \.ep-colophon' 'border-top:2px solid var\(--heading\)' 'the colophon opens on a heavy rule'
rule_sets '\.episode \.content \.ep-colophon' 'color:var\(--muted\)' 'in muted text'
rule_sets '\.episode \.content \.ep-colophon__title' 'color:var\(--heading\)' 'under a heading-coloured title'

echo 'Colour tokens: no dark copies'
# No [theme=dark] rule restates a colour of ours. A rule that did would be a second place
# to change one, and the one place that drifts. What is allowed under [theme=dark] is a
# token block, and the rules that fight the theme's own dark rules at a specificity a
# light rule cannot reach (a quotation's bar, a rule across the column, bold text), none
# of which has a value of its own. The theme's rules are its own and are not asserted.
COLOUR_DECL='(color|background|border|outline|filter|shadow|animation)'
dark_copy() { # dark_copy <description> <selector-regex>
    rule_lacks "\\[theme=dark\\] .*($2).*" "$COLOUR_DECL" "no dark copy of $1"
}
dark_copy 'the footer, the logo and the home intro' '\.footer-social|\.logo-mark|\.home-intro'
dark_copy 'the Greeting, a title or a heading' '\.home-greeting|\.single-title|\.single \.content h[1-6]'
dark_copy 'a Plate' '\.plate'
dark_copy 'the headshot line' '\.portrait'
dark_copy 'the archive' '\.archive-intro|\.group-title'
dark_copy 'the reading list nav' ':has\(\.entry--book\)'
# The Entry has no dark rule at all. It had one: the featured Entry's edge, shown in dark
# and not in light by an accident of specificity. It is gone (see _entry.scss).
dark_copy 'an Entry, on any list' '\.entry'
rule_lacks '\[theme=dark\] .*\.entry.*' '.' 'and no [theme=dark] rule touches an Entry, whatever it sets'
dark_copy 'the focus ring or the active nav item' ':focus-visible|\.menu-item\.active'
dark_copy 'an Episode page' '\.episode|\.ep-'
# (Not the Contents box, the foot's wrapper or a bare `.post-tags`: the theme draws those under
# [theme=dark] itself, for its home-page summaries too, and those rules are its own.)
dark_copy 'the masthead, the share row and the tags' '\.masthead|\.post-share|\.post-nav__label|\.post-footer__row|\.single \.post-footer \.post-tags'
# The theme paints the selection's background itself, under [theme=dark]; what is ours is
# the text on it.
rule_lacks '\[theme=dark\] ::selection' '(^|;)color:' 'no dark copy of the selected text colour'

echo 'Colour tokens: switched once'
# `[theme=auto]` was the third copy of every rule, and it never matched: nothing sets that
# attribute. The theme sets `dark` on <body> from the visitor's choice or, by default, from
# the OS, in baseof.html, once, before first paint. So the stylesheet never waits on the OS
# itself, and there is no media query to write a rule under.
absent_from "$CSS" 'theme=auto' 'no rule waits on [theme=auto], which nothing sets'
absent_from "$CSS" 'prefers-color-scheme' 'and the stylesheet never reads the OS preference: the page does, once'
# What is left under [theme=dark] reads a token and nothing else: the two rules the theme
# draws again in dark at a specificity a light rule cannot reach (a quotation, and the
# rule across the column). There was a third, the featured Entry's edge, which was more
# specific than the Entry row's and so showed in dark only; the Entry rework decided it
# belongs in neither mode and removed it. A third would be a place to restate a value, so
# adding one is a decision, and this is where it is counted.
if [ "$(rules_with '\[theme=dark\] .*' 'var\(--')" -eq 2 ]; then
    ok 'only two [theme=dark] rules read a token, both undoing the theme'
else
    bad "only two [theme=dark] rules read a token, both undoing the theme (got $(rules_with '\[theme=dark\] .*' 'var\(--'))"
fi
# Everything after the token blocks is ours. None of it spells a hex colour: a component
# takes a token, so the value exists in one place and is read from there. (What it may
# spell is a translucent black for a shadow, and the ruler's ink at an alpha, which is the
# same in both modes and so has no mode to switch.)
hex_in_ours=$(css_rules | awk '/^\[theme=dark\]\{--paper/ { f = 1; next } f' | grep -cE '#[0-9a-fA-F]{3,8}\b' || true)
if [ "$hex_in_ours" -eq 0 ]; then
    ok 'no rule of ours spells a hex colour: each is a token'
else
    bad "no rule of ours spells a hex colour: each is a token ($hex_in_ours rules do)"
fi
# And a value only this site uses is written once. These were each written in the light
# stylesheet and again for dark, and again for the dead [theme=auto] copy, up to 36 times.
for value in '#9db0e0' '#bb8fce' '#5eead4' '#8a8c93' '#34353a' '#1c1d20' '#cfc5ae' '#4b4d52' '#3a3b40' '#44464b' '#4e5056' '#575a60' \
             '#57534e' '#9b59b6' '#0f766e' '#f7f2e7' '#fffdf7' '#78716c' '#efe7d4' '#cfcac4' '#c4beb7'; do
    occurs "$CSS" "$value" 1 "$value is written once"
done


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
contains "$EN_HOME" 'I write from time to time' 'the en home page routes in first person, not in a status report'
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
rule_sets '\.header-title \.logo-mark' 'color:var\(--accent\)' 'the mark takes the Accent, whichever mode it is in'
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
# The theme gives the footer a fixed 2rem height, written when it held one line.
# It holds two. Left alone, the overflow pushed the document past 100vh and made a
# half-screen home page scroll -- a defect that only shows on the shortest page,
# which is the one least likely to be checked for scrolling.
matches "$CSS" 'footer\{height:auto' 'the footer sizes to its contents, not to a fixed 2rem'

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

# Which Hugo built this, against the one pinned in .hugo-version for CI and
# Vercel. A note, not a failure: CI always builds with the pin, and a local build
# on a newer Hugo is how an upgrade gets tried. But it is how two versions drift
# apart unnoticed, which is what made a deprecation fix need a pinned-version
# bump nobody had planned.
PINNED=$(cat "$(dirname "$0")/../.hugo-version" 2>/dev/null || true)
BUILT=$(grep -o 'name=generator content="Hugo [0-9.]*"' "$EN_HOME" 2>/dev/null | grep -o '[0-9][0-9.]*' || true)
if [ -n "$PINNED" ] && [ -n "$BUILT" ] && [ "$PINNED" != "$BUILT" ]; then
    echo
    printf 'note: built with Hugo %s; .hugo-version pins %s for CI and Vercel\n' "$BUILT" "$PINNED"
fi

echo
if [ "$failures" -gt 0 ]; then
    printf '%d assertion(s) failed\n' "$failures" >&2
    exit 1
fi
printf 'all post-build assertions passed\n'
