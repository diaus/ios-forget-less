#!/usr/bin/env bash
# Taps the booted simulator at X Y (points), for a control an elementRef tap misses: MobileBuildMCP's `tap` hits an
# element's centre and takes no coordinates. Uses the axe CLI bundled with MobileBuildMCP's npx install.
set -euo pipefail
[ $# -eq 2 ] || { echo "usage: scripts/sim-tap.sh X Y" >&2; exit 2; }

axe="$(ls -t "$HOME"/.npm/_npx/*/node_modules/mobilebuildmcp/bundled/axe 2>/dev/null | head -1)"
[ -n "$axe" ] || { echo "sim-tap.sh: no axe bundled with mobilebuildmcp under ~/.npm/_npx" >&2; exit 1; }
udid="$(xcrun simctl list devices booted | grep -o -E '[0-9A-F]{8}(-[0-9A-F]{4}){3}-[0-9A-F]{12}' | head -1)"
[ -n "$udid" ] || { echo "sim-tap.sh: no booted simulator" >&2; exit 1; }

"$axe" tap -x "$1" -y "$2" --udid "$udid"
