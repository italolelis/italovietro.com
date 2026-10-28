#!/usr/bin/env bash
#
# The production build, the same wherever it runs: both GitHub workflows, the
# Vercel fallback in vercel.json, and locally before the gate.
#
#   ./scripts/build.sh && ./scripts/check-build.sh public
#
# Two things it does that a bare `hugo --gc --minify` does not:
#
# Fresh output. public/ is emptied first. Hugo never deletes a file it has
# stopped producing, so stale pages and fingerprinted stylesheets pile up across
# builds, and the gate asserts on whatever is there -- it once had two
# stylesheets to choose from and took the first. A `hugo server` started without
# --renderToMemory writes into public/ too, and one that had been running since
# before i18n/ existed kept writing pages with every new string empty.
#
# Warnings fail the build. --panicOnWarning turns any WARN into an error, and the
# two print flags make Hugo report what it otherwise passes over in silence: a
# translation key missing from one language (which renders as an empty string),
# and two pages written to the same path. Deprecation notices are WARNs too, so a
# Hugo upgrade that deprecates something stops here instead of shipping until the
# removal breaks it.
#
# HUGO overrides the binary, for vercel.json, which downloads its own into ./hugo.
# Any other arguments go to hugo.

set -euo pipefail

cd "$(dirname "$0")/.."
rm -rf public
exec "${HUGO:-hugo}" --gc --minify --panicOnWarning --printI18nWarnings --printPathWarnings "$@"
