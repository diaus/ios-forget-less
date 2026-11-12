# Open Source Licenses in Settings › About

Status: ready-for-agent

## Problem Statement

The app ships Factory, an open source library under the MIT license. MIT requires the copyright notice and the license text to ship with the software, and the app shows them nowhere. The SPM dependencies also follow version ranges ("up to next major"), so the exact version that ships, and the one a license entry would name, can change without anyone choosing it.

## Solution

Pin every SPM dependency to an exact version, the latest one. Then add an "Open Source Licenses" row as the last row of Settings › About. It opens a list of the libraries the app ships, each with its version and license, and each library's page shows its full license text. The list is written by hand and updated in the same change as any dependency, and `scripts/check.sh` fails when the list and the pinned dependencies disagree. Nothing is generated at build time.

## User Stories

1. As a user, I want an "Open Source Licenses" row as the last row of the About section, below Support, that opens the list of the libraries the app uses.
2. As a user, I want the list titled "Open Source Licenses", with one row per library sorted by name: the name as the title, the version as a secondary subtitle, the license name ("MIT") as the trailing value, and a disclosure chevron.
3. As a user, I want a library's page titled with its name, showing its Version, its License and a "Repository" row that opens the library's repository in Safari.
4. As a user, I want the library's full license text below, as paragraphs that wrap to the screen's width and follow Dynamic Type, and I want to be able to select it.
5. As a Ukrainian-speaking user, I want the row, titles and labels in Ukrainian. The license texts stay in English, the language they're published in.
6. As a VoiceOver user, I want each list row read with its name, version and license, and the Repository row read as a link.
7. As the developer, I want every SPM dependency pinned to an exact version, so that the version shipped is the one I chose and the one the license list names.
8. As the developer, I want `scripts/check.sh` to fail when a shipped dependency has no license entry, an entry's version differs from the pin, an entry has no pin, or an entry's text file is missing, so that the hand-written list can't drift.

## Implementation Decisions

- **Pinning:** Factory is pinned to `exactVersion 3.5.3`, the latest, in `project.pbxproj`, and to `exact: "3.5.3"` in `Packages/Data/Package.swift`. Both `Package.resolved` files are refreshed. SwiftLintPlugins is already pinned to exact 0.65.1, which is the latest.
- **Which libraries are listed:** only what ships in the app. SwiftLintPlugins is a build-tool plugin that downloads the SwiftLint binary, and nothing of it is linked into the app, so it's left out.
- **Data:** `Resources/Licenses/licenses.json` is an array of `{name, version, license, repositoryURL, file}`, where `file` names a text file beside it. `Resources/Licenses/Factory.txt` is Factory's `LICENSE`, copied byte for byte at tag 3.5.3. The folder sits in the app's synchronized `Resources/` folder, so both files are copied into the bundle.
- **Code:** in `Features/Settings/About/Licenses/`:
  - `OpenSourceLicense` is the decoded entry. The name is specific on purpose, not `License` or `Library`.
  - `LicensesViewModel` loads the manifest and each text from `Bundle.main`, resolved through Factory like the other view models. A missing or unreadable manifest or text is a programmer error: `assertionFailure`, then an empty list.
  - `LicensesView` is the list.
  - `LicenseDetailView` is a library's page.
- **Navigation:** Settings is already pushed in Quick Settings' `NavigationStack`. The About row is a `NavigationLink` to `LicensesView`, and each list row is a `NavigationLink` to `LicenseDetailView`. Both titles use `.navigationBarTitleDisplayMode(.inline)`.
- **List row:** the name, with the version in the secondary style below it, and the license name as the trailing value. It follows the `LabeledContent` look of the Version row.
- **Detail page:**
  - a first section with Version, License and Repository. The Repository row is a `Link` styled like the About section's Privacy Policy and Support rows: title in `.primary`, trailing `arrow.up.forward` in `.secondary`;
  - a second section with the license text, `.textSelection(.enabled)`.
- **License text reflow:** the stored file stays verbatim. For display, lines within a paragraph are joined with a space, and blank lines stay as paragraph breaks, the way AcknowList shows license files. Without this, hard-wrapped 80-column text would break into ragged half-lines.
- **Guard:** `scripts/licenses.py check` runs from `scripts/check.sh` and reads the app's `ForgetLess.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`. It keeps a short list of build-only identities (`swiftlintplugins`), and fails with a message naming the entry when any of these is true:
  - a pin not on that list has no entry,
  - an entry's version differs from its pin,
  - an entry names a library with no pin,
  - an entry's `file` is missing.
- **CODING_STANDARDS.md** gains two rules:
  - Every SPM dependency, in the app project and in each local package, is pinned to an exact version, the latest one when it's added or upgraded.
  - Adding, removing or upgrading a dependency that ships in the app updates its entry and text in `Resources/Licenses/` in the same change, and `scripts/licenses.py check` enforces this.
- **String Catalog**, through `scripts/xcstrings.py set`:
  - `settings.about.licenses`: EN "Open Source Licenses", UK "Ліцензії відкритого коду". It's used for both the row and the list's title.
  - `settings.about.licenses.license`: EN "License", UK "Ліцензія".
  - `settings.about.licenses.repository`: EN "Repository", UK "Репозиторій".
  - The Version row reuses `settings.about.version`. Library names, versions, license names and texts are data, not catalog keys.

## Testing Decisions

- No unit tests. The screens have no Domain logic, view models stay untested, and `scripts/licenses.py check` covers the data.
- **Done:** `build_sim`, `test_sim` and `scripts/check.sh` pass, and the `docs/agents/ui-check.md` check passes on iOS 27. On the simulator:
  - the row sits last in About and opens the list;
  - Factory shows as 3.5.3, MIT;
  - its page shows the reflowed MIT text, and the text can be selected;
  - Repository opens https://github.com/hmlongco/Factory in Safari.

## Out of Scope

- Generating the list at build time, or with a tool such as LicensePlist. It can replace the hand-written manifest later without changing the screens.
- A Settings.bundle page in the iOS Settings app.
- Listing build tools such as SwiftLint.
- Translating license texts.
- A footer or intro text on the list.
