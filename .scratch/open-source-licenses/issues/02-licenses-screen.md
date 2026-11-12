# 02: The Open Source Licenses row, its screens and their guard

Status: ready-for-agent

**What to build:** everything else in `../spec.md`, in one change:
- the `Resources/Licenses/` manifest and Factory's license text;
- `OpenSourceLicense`, `LicensesViewModel`, `LicensesView` and `LicenseDetailView` in `Features/Settings/About/Licenses/`;
- the About section's new last row;
- `scripts/licenses.py check`, wired into `scripts/check.sh`;
- the licenses rule in `CODING_STANDARDS.md`;
- the three String Catalog keys.

**Blocked by:** 01.

- [ ] `Resources/Licenses/licenses.json` lists Factory, 3.5.3, MIT, https://github.com/hmlongco/Factory, with `Factory.txt`. `Factory.txt` is Factory's `LICENSE` at tag 3.5.3, byte for byte.
- [ ] "Open Source Licenses" is the last row of About, below Support, and opens the list, which has the same title, shown inline.
- [ ] Each list row shows the name, the version as a secondary subtitle and the license name as the trailing value, sorted by name.
- [ ] A library's page shows Version, License and a Repository link row (title in `.primary`, trailing `arrow.up.forward`), then the license text, reflowed into paragraphs and selectable.
- [ ] A missing or unreadable manifest or text calls `assertionFailure` and leaves the list empty.
- [ ] `scripts/licenses.py check` fails when:
  - a shipped pin has no entry,
  - an entry's version differs from its pin,
  - an entry has no pin,
  - an entry's text file is missing.

  It skips `swiftlintplugins`. `scripts/check.sh` runs it and its header comment lists it. Each failure case was seen to fail once, by temporarily breaking the manifest.
- [ ] `CODING_STANDARDS.md` has the rule: adding, removing or upgrading a dependency that ships in the app updates its entry and text in `Resources/Licenses/` in the same change, and `scripts/licenses.py check` enforces this.
- [ ] `settings.about.licenses`, `settings.about.licenses.license` and `settings.about.licenses.repository` are set in EN and UK through `scripts/xcstrings.py set`.
- [ ] `build_sim`, `test_sim` and `scripts/check.sh` pass.
- [ ] The `docs/agents/ui-check.md` check passes on iOS 27, in English and Ukrainian, and Repository opens the page in Safari.

## Comments
