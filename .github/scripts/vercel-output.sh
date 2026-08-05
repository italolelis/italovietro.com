#!/usr/bin/env bash
#
# Packages Hugo's output for Vercel's Build Output API (v3), so Vercel serves
# finished files and runs no build of its own.
#
# Shared by the production deploy and the PR preview so both publish byte
# identical output -- a preview that differs from production is worse than no
# preview.
#
# Usage: .github/scripts/vercel-output.sh [public-dir]

set -euo pipefail

PUBLIC="${1:-public}"
OUT=".vercel/output"

if [ ! -d "$PUBLIC" ]; then
    printf 'error: "%s" does not exist -- build the site first\n' "$PUBLIC" >&2
    exit 2
fi

rm -rf "$OUT"
mkdir -p "$OUT"
cp -r "$PUBLIC" "$OUT/static"

# Routes are declared here rather than in static/_redirects, which is Netlify
# syntax that Vercel ignores. The rules that file carried were dead anyway:
# they pointed at /zh-cn/404.html and /fr/404.html, neither of which this site
# builds, since only en and pt-br are enabled.
#
# "handle": "filesystem" serves any real file first; the two rules after it are
# the fallbacks, so a missing Portuguese page gets the Portuguese 404 instead of
# the English one.
cat > "$OUT/config.json" <<'JSON'
{
  "version": 3,
  "trailingSlash": true,
  "routes": [
    { "handle": "filesystem" },
    { "src": "/pt-br/.*", "status": 404, "dest": "/pt-br/404.html" },
    { "src": "/.*", "status": 404, "dest": "/404.html" }
  ]
}
JSON

printf 'packaged %s files for Vercel\n' "$(find "$OUT/static" -type f | wc -l | tr -d ' ')"
