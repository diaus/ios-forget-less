#!/usr/bin/env bash
# Checks the app build doesn't cover: no source folder holds more than seven Swift files at one level,
# SwiftLint over the local packages (the build plugin lints only the app target),
# the String Catalog's format, its en/uk coverage and its lint prefixes, the open source licenses list against
# the pinned dependencies, and every local package's tests on the Mac.
# Prints one summary line per package and ends with "check.sh: OK"; the first failure stops it with a non-zero exit.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"

# A backstop for CODING_STANDARDS' "One concept per folder": past seven files a folder almost always holds two.
max_files=7
oversized=$(cd "$root/ForgetLess" && find ForgetLess ForgetLessWidget ForgetLessTests Packages/*/Sources Packages/*/Tests \
    -type d -name .build -prune -o -type d -print | while read -r dir; do
    count=$(find "$dir" -maxdepth 1 -type f -name '*.swift' | wc -l | tr -d ' ')
    if [ "$count" -gt "$max_files" ]; then echo "  ForgetLess/$dir ($count files)"; fi
done)
if [ -n "$oversized" ]; then
    echo "check.sh: these folders hold more than $max_files Swift files; split each by concept (CODING_STANDARDS.md › Folders):" >&2
    echo "$oversized" >&2
    exit 1
fi

(cd "$root/ForgetLess" && swiftlint lint --quiet --strict)
"$root/scripts/xcstrings.py" check
"$root/scripts/licenses.py" check
for p in "$root"/ForgetLess/Packages/*/; do
    swift test --quiet --disable-xctest --package-path "$p"  # the packages use Swift Testing only
done
echo "check.sh: OK"
