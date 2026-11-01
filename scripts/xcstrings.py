#!/usr/bin/env python3
"""Edit or check the app's String Catalog, writing it byte-for-byte the way Xcode does.

  scripts/xcstrings.py set KEY EN UK   add a manually managed key, or change its English and Ukrainian values
  scripts/xcstrings.py set-plural KEY LANG CATEGORY=VALUE...
                                       set one language's plural forms of a key, replacing its value there
                                       (e.g. zero="No tasks" one="%(count)lld task" other="%(count)lld tasks")
  scripts/xcstrings.py remove KEY      delete a key
  scripts/xcstrings.py sync            rewrite SwiftLint's catalog_key_literal prefixes from the catalog
  scripts/xcstrings.py check           exit 1 if the file isn't in Xcode's format, a key lacks en or uk,
                                       a plural lacks a form its language needs, or those prefixes are stale

Xcode generates the Swift symbol from the key after the next build (e.g. "day.today" -> .dayToday).
Name placeholders for the symbol's arguments: "Delete “%(name)@”?" -> .taskDeleteConfirmation(name:).

SwiftLint's catalog_key_literal rule (ForgetLess/.swiftlint.yml) lists the catalog's top-level key
groups, so a typed "group.key" literal fails the build. `set` and `remove` keep that list in step.
"""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
CATALOG = ROOT / "ForgetLess/ForgetLess/Resources/Localizable.xcstrings"
SWIFTLINT = ROOT / "ForgetLess/.swiftlint.yml"
LANGUAGES = ("en", "uk")
# The CLDR plural categories each language needs. A String Catalog also takes "zero" in any language.
PLURAL_CATEGORIES = {"en": {"one", "other"}, "uk": {"one", "few", "many", "other"}}
OPTIONAL_PLURAL_CATEGORIES = {"zero"}
# The `(?:group|group|...)\.[A-Za-z.]*"` part of the catalog_key_literal regex.
PREFIXES = re.compile(r'(\(\?:)([A-Za-z|]+)(\)\\\.\[A-Za-z\.\]\*")')


def ordered(value):
    # Xcode sorts object keys case-insensitively.
    if isinstance(value, dict):
        return {k: ordered(value[k]) for k in sorted(value, key=lambda k: (k.lower(), k))}
    if isinstance(value, list):
        return [ordered(v) for v in value]
    return value


def dumps(catalog):
    # Xcode's spacing (" : ") and no trailing newline.
    return json.dumps(ordered(catalog), indent=2, separators=(",", " : "), ensure_ascii=False)


def groups(strings):
    return sorted({key.split(".")[0] for key in strings}, key=lambda g: (g.lower(), g))


def untranslated(strings):
    # Keys missing a localization in any shipped language; Xcode's own "stale" keys are left to Xcode.
    return [
        key for key, entry in strings.items()
        if entry.get("extractionState") != "stale"
        and any(lang not in entry.get("localizations", {}) for lang in LANGUAGES)
    ]


def bad_plurals(strings):
    # "key (lang)" for each plural lacking a form its language needs, or holding one it never uses.
    found = []
    for key, entry in strings.items():
        for lang, localization in entry.get("localizations", {}).items():
            plural = localization.get("variations", {}).get("plural")
            needed = PLURAL_CATEGORIES.get(lang)
            if plural is not None and needed is not None \
                    and not needed <= plural.keys() <= needed | OPTIONAL_PLURAL_CATEGORIES:
                found.append(f"{key} ({lang})")
    return found


def lint_prefixes(yml):
    found = PREFIXES.findall(yml)
    if len(found) != 1:
        sys.exit(f"{SWIFTLINT}: expected one catalog_key_literal prefix list, found {len(found)}")
    return found[0][1].split("|")


def sync_lint(strings):
    yml = SWIFTLINT.read_text(encoding="utf-8")
    lint_prefixes(yml)
    wanted = "|".join(groups(strings))
    if not wanted:
        return  # an empty alternation would match every string; keep the old list until a key exists
    SWIFTLINT.write_text(PREFIXES.sub(lambda m: m[1] + wanted + m[3], yml, count=1), encoding="utf-8")


def load(args):
    if CATALOG.exists():
        raw = CATALOG.read_text(encoding="utf-8")
        return raw, json.loads(raw)
    if args[:1] == ["set"]:
        return None, {"sourceLanguage": "en", "strings": {}, "version": "1.0"}
    sys.exit(f"{CATALOG} doesn't exist yet; create it with `scripts/xcstrings.py set KEY EN UK`.")


def main(args):
    raw, catalog = load(args)
    strings = catalog["strings"]
    match args:
        case ["check"]:
            if dumps(catalog) != raw:
                sys.exit(f"{CATALOG} is not in Xcode's format; run `scripts/xcstrings.py set` on any key to rewrite it.")
            if missing := untranslated(strings):
                sys.exit(f"{CATALOG}: keys missing {' or '.join(LANGUAGES)}: {', '.join(sorted(missing))}")
            if bad := bad_plurals(strings):
                sys.exit(f"{CATALOG}: plurals without their language's forms: {', '.join(sorted(bad))}")
            if lint_prefixes(SWIFTLINT.read_text(encoding="utf-8")) != groups(strings):
                sys.exit(f"{SWIFTLINT}: catalog_key_literal's prefixes don't match the catalog's key groups; run `scripts/xcstrings.py sync`.")
            return
        case ["sync"]:
            sync_lint(strings)
            return
        case ["set", key, en, uk]:
            entry = strings.setdefault(key, {"extractionState": "manual"})
            localizations = entry.setdefault("localizations", {})
            for lang, value in zip(LANGUAGES, (en, uk)):
                localizations[lang] = {"stringUnit": {"state": "translated", "value": value}}
        case ["set-plural", key, lang, *forms] if lang in LANGUAGES and forms:
            plural = {}
            for form in forms:
                category, sep, value = form.partition("=")
                if not sep or category not in PLURAL_CATEGORIES[lang] | OPTIONAL_PLURAL_CATEGORIES:
                    sys.exit(f"Not a {lang} plural form: {form!r}")
                plural[category] = {"stringUnit": {"state": "translated", "value": value}}
            if missing := PLURAL_CATEGORIES[lang] - plural.keys():
                sys.exit(f"{lang} needs the plural forms {', '.join(sorted(missing))}")
            entry = strings.setdefault(key, {"extractionState": "manual"})
            entry.setdefault("localizations", {})[lang] = {"variations": {"plural": plural}}
        case ["remove", key]:
            if strings.pop(key, None) is None:
                sys.exit(f"No key {key!r}")
        case _:
            sys.exit(__doc__)
    CATALOG.write_text(dumps(catalog), encoding="utf-8")
    sync_lint(strings)


if __name__ == "__main__":
    main(sys.argv[1:])
