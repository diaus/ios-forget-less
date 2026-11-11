# 01: The About section in Settings

Status: ready-for-agent

**What to build:** everything in `../spec.md`, in one change: `AboutSectionView` with its Version row and two link rows, `SettingsViewModel`'s `appVersion` and `copyAppVersion()`, and the five String Catalog keys.

**Blocked by:** nothing.

- [x] The About section is the last one in Settings, with Version ("1.0 (3)" style, read from the bundle), Privacy Policy and Support rows.
- [x] A long press on Version offers Copy, which puts the version on the pasteboard.
- [x] Privacy Policy and Support open https://diaus.github.io/forgetless/privacy/ and https://diaus.github.io/forgetless/support/ in Safari.
- [x] The link rows show primary-coloured titles with a trailing `arrow.up.forward` glyph, in English and Ukrainian.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.
- [x] The `docs/agents/ui-check.md` check passes on iOS 27.

## Comments
