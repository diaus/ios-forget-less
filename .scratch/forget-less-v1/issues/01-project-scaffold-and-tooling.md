# 01: Project scaffold and tooling

**What to build:** Set the Xcode project up the way the spec's "Project" section and `CODING_STANDARDS.md` describe, so every later ticket starts on a green build:
- iOS 18 and strict Swift 6 everywhere;
- empty `Domain` and `Data` local packages, wired to the app;
- Factory for DI;
- the SwiftLint build plugin;
- an en/uk String Catalog;
- `scripts/check.sh` passing.

The app still shows a placeholder screen. Nothing user-facing changes yet.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] Deployment target is iOS 18. The app target and both packages use the Swift 6 language mode with complete strict concurrency, and packages also declare macOS 15 so `swift test` runs on the Mac.
- [ ] The UITests target is deleted, along with its scheme entries.
- [ ] The app's folders follow the layout in `CLAUDE.md` (`App/`, `Composition/`, `Features/`, `Shared/`, `Resources/`). The template's `ContentView` is replaced by a placeholder in `Features/`.
- [ ] `Domain` (Foundation only) and `Data` (depends on Domain, SwiftData, FactoryKit) packages exist, each with a Swift Testing test target containing one real smoke test, and the app links both.
- [ ] Factory is added. Data has a `DI/` registration for the `ModelContainer`, and the app has a `Composition/` extension ready for use cases.
- [ ] The SwiftLint build plugin runs `ForgetLess/.swiftlint.yml` on the app target. A typed `Text("literal")` fails the build.
- [ ] The String Catalog exists with at least one key carrying both `en` and `uk`, created with `scripts/xcstrings.py set`. `scripts/xcstrings.py check` passes.
- [ ] The accent colour is the reference red, with light and dark variants in the asset catalog.
- [ ] `build_sim` succeeds and `scripts/check.sh` ends with `check.sh: OK`.
