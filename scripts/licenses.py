#!/usr/bin/env python3
"""Check the hand-written list of the open source libraries the app ships against its pinned dependencies.

  scripts/licenses.py check   exit 1 if a shipped pin has no entry in Resources/Licenses/licenses.json,
                              an entry's version differs from its pin, an entry has no pin,
                              an entry's text file is missing, or two entries share a name

An entry matches the pin whose identity SwiftPM derives from the entry's repositoryURL
(its last path component, lowercased, without ".git"). Build-only dependencies, nothing of
which ships in the app, have no entry.
"""
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
RESOLVED = ROOT / "ForgetLess/ForgetLess.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
LICENSES = ROOT / "ForgetLess/ForgetLess/Resources/Licenses"
MANIFEST = LICENSES / "licenses.json"
# SwiftLintPlugins downloads the SwiftLint binary for a build-tool plugin; nothing of it is linked into the app.
BUILD_ONLY = {"swiftlintplugins"}


def identity(url):
    name = url.rstrip("/").rsplit("/", 1)[-1]
    return name.removesuffix(".git").lower()


def check():
    pins = {pin["identity"]: pin["state"].get("version") for pin in json.loads(RESOLVED.read_text())["pins"]}
    entries = json.loads(MANIFEST.read_text())
    errors = []
    listed = set()
    names = set()
    for entry in entries:
        name = entry["name"]
        # The app identifies a library by its name.
        if name in names:
            errors.append(f"{name}: two entries share this name")
        names.add(name)
        pin_identity = identity(entry["repositoryURL"])
        listed.add(pin_identity)
        if pin_identity not in pins:
            errors.append(f"{name}: no pinned dependency matches {entry['repositoryURL']}; remove its entry")
        elif entry["version"] != pins[pin_identity]:
            errors.append(f"{name}: the entry says {entry['version']}, the pin is {pins[pin_identity]}")
        if not (LICENSES / entry["file"]).is_file():
            errors.append(f"{name}: its text file {entry['file']} is missing from {LICENSES.relative_to(ROOT)}")
    for pin_identity in sorted(pins.keys() - listed - BUILD_ONLY):
        errors.append(f"{pin_identity}: it ships in the app but has no entry in {MANIFEST.relative_to(ROOT)}")
    for error in errors:
        print(f"licenses.py: {error}", file=sys.stderr)
    return 1 if errors else 0


def main(args):
    if args != ["check"]:
        print(__doc__, file=sys.stderr)
        return 2
    return check()


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
