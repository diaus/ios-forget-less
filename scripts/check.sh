#!/usr/bin/env bash
# Checks the app build doesn't cover: SwiftLint over the local packages (the build plugin lints only the app target),
# the String Catalog's format, its en/uk coverage and its lint prefixes, and every local package's tests on the Mac.
# Prints one summary line per package and ends with "check.sh: OK"; the first failure stops it with a non-zero exit.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"

(cd "$root/ForgetLess" && swiftlint lint --quiet --strict)
"$root/scripts/xcstrings.py" check
for p in "$root"/ForgetLess/Packages/*/; do
    swift test --quiet --disable-xctest --package-path "$p"  # the packages use Swift Testing only
done
echo "check.sh: OK"
