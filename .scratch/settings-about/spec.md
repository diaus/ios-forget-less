# About section in Settings

Status: ready-for-agent

## Problem Statement

Settings shows nothing about the app itself. The user can't see which version they run, which they need when they report a problem, and the app links to neither its privacy policy nor its support page.

## Solution

An "About" section at the bottom of Settings, below "Keep Complete Tasks For", with three rows: the version and build ("1.0 (3)"), a link to the privacy policy and a link to the support page. The links open in Safari.

## User Stories

1. As a user, I want an "About" section at the bottom of Settings, so that the app's own details sit apart from its settings.
2. As a user, I want a "Version" row showing the version and the build as "1.0 (3)", so that I can tell Support exactly what I run.
3. As a user, I want a long press on the Version row to offer "Copy", which copies "1.0 (3)", so that I can paste it into a message to Support.
4. As a user, I want a "Privacy Policy" row that opens https://diaus.github.io/forgetless/privacy/ in Safari.
5. As a user, I want a "Support" row that opens https://diaus.github.io/forgetless/support/ in Safari.
6. As a user, I want the two link rows in the primary text colour with a trailing `arrow.up.forward` glyph, as in the Settings app, so that they read as pages outside the app rather than as buttons.
7. As a Ukrainian-speaking user, I want the section in Ukrainian. The two pages are the same for every language.
8. As a VoiceOver user, I want the link rows read as links with their titles, and the Version row read as "Version, 1.0 (3)".

## Implementation Decisions

- **Folder:** the section is a part of the Settings screen, `Features/Settings/About/AboutSectionView.swift`, beside `KeptDuration/`.
- **Version:** `CFBundleShortVersionString` and `CFBundleVersion` from `Bundle.main`, shown as `"\(version) (\(build))"`, untranslated. `SettingsViewModel` exposes it (`appVersion`) and owns the copy (`copyAppVersion()`, to `UIPasteboard`), so the context menu's button carries no logic.
- **Links:** a plain SwiftUI `Link` for each, so they open in Safari on iOS 18 and 27 alike. The URLs are constants in the About part. No in-app browser and no URL in Info.plist.
- **Row look:** each link's label is the title in `.primary` with a trailing `Image(systemName: "arrow.up.forward")` in the secondary style, overriding the accent tint a `Link` gets in a `List`.
- **String Catalog**, through `scripts/xcstrings.py set`:
  - `settings.about`: EN "About", UK "Про застосунок".
  - `settings.about.version`: EN "Version", UK "Версія".
  - `settings.about.privacyPolicy`: EN "Privacy Policy", UK "Політика конфіденційності".
  - `settings.about.support`: EN "Support", UK "Підтримка".
  - `settings.about.copy`: EN "Copy", UK "Скопіювати".

## Testing Decisions

- No unit tests. The section has no Domain logic, and view models stay untested.
- **Done:** `build_sim`, `test_sim` and `scripts/check.sh` pass, and the `docs/agents/ui-check.md` check passes on iOS 27. On the simulator: the section sits last in Settings, the Version row shows the build's version and build, Copy puts it on the pasteboard, and each link opens its page in Safari.

## Out of Scope

- An in-app browser for the links.
- A Build row apart from Version, a copyright line, or any other About content.
- Localised versions of the two pages.
- Renaming the Settings screen's "kept duration" code and catalog keys to Grace Period, the glossary's term for it.
