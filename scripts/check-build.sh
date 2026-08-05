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
nowhere() {
    local needle=$1 desc=$2 hits
    hits=$(grep -rlIF -- "$needle" "$PUBLIC" 2>/dev/null || true)
    if [ -z "$hits" ]; then
        ok "$desc"
    else
        bad "$desc, found in:"
        printf '          %s\n' $hits
    fi
}

if [ ! -d "$PUBLIC" ]; then
    printf 'error: "%s" does not exist -- build the site before running this\n' "$PUBLIC" >&2
    exit 2
fi

EN_HOME="$PUBLIC/index.html"
PT_HOME="$PUBLIC/pt-br/index.html"

echo 'Job title'
contains "$EN_HOME" 'Senior Director of Engineering' 'en homepage states the current title'
contains "$PT_HOME" 'Senior Director of Engineering' 'pt-br homepage states the current title'
nowhere 'Head of Engineering' 'superseded title appears nowhere'

echo
if [ "$failures" -gt 0 ]; then
    printf '%d assertion(s) failed\n' "$failures" >&2
    exit 1
fi
printf 'all post-build assertions passed\n'
