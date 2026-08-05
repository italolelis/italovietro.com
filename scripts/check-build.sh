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
