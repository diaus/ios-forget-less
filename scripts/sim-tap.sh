#!/usr/bin/env bash
# Taps the booted simulator at X Y (points), for a control an elementRef tap misses: MobileBuildMCP's `tap` hits an
# element's centre and takes no coordinates. With --key CODE, presses a hardware key by HID code instead (40 is Return).
# Uses the axe CLI bundled with MobileBuildMCP's npx install.
#
# On iOS 27 the simulator opens its HID services only after a client connects, and drops what the client sent if it
# disconnects first, while axe still reports success (AXe issue #71). So one axe session sends an inert touch-up, waits
# for the services, sends the input, and stays connected until it lands.
set -euo pipefail
if [ $# -eq 2 ] && [ "$1" = --key ]; then
    input="key $2"
elif [ $# -eq 2 ]; then
    # Held like a finger's tap, not axe's instant one.
    input="touch -x $1 -y $2 --down --up --delay 0.05"
else
    echo "usage: scripts/sim-tap.sh X Y | --key CODE" >&2
    exit 2
fi

axe="$(ls -t "$HOME"/.npm/_npx/*/node_modules/mobilebuildmcp/bundled/axe 2>/dev/null | head -1)"
[ -n "$axe" ] || { echo "sim-tap.sh: no axe bundled with mobilebuildmcp under ~/.npm/_npx" >&2; exit 1; }
udid="$(xcrun simctl list devices booted | grep -o -E '[0-9A-F]{8}(-[0-9A-F]{4}){3}-[0-9A-F]{12}' | head -1)"
[ -n "$udid" ] || { echo "sim-tap.sh: no booted simulator" >&2; exit 1; }

"$axe" batch --udid "$udid" \
    --step "touch -x 1 -y 1 --up" \
    --step "sleep 0.5" \
    --step "$input" \
    --step "sleep 0.3"
