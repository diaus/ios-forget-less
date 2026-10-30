## Agent skills

### Issue tracker

Issues live as local markdown files under `.scratch/<feature>/`. See `docs/agents/issue-tracker.md`.

### Triage labels

Recorded as a `Status:` line in each issue file. The labels are in `docs/agents/triage-labels.md`.

### Domain docs

Before exploring the codebase, read `GLOSSARY.md` and the ADRs in `docs/adr/` that touch the area. How to use them is in `docs/agents/domain.md`.

## Layout

The project is `ForgetLess/ForgetLess.xcodeproj`, in a nested `ForgetLess/` folder beside the app (`ForgetLess/ForgetLess/`), its tests (`ForgetLess/ForgetLessTests/`) and the local packages (`ForgetLess/Packages/*`).

Before writing or reviewing code, read `CODING_STANDARDS.md`: it holds the review rules and where each new file goes. The v1 spec is `.scratch/forget-less-v1/spec.md`.

## Building

Build, test and run through the MobileBuildMCP tools (`build_sim`, `test_sim`, `build_run_sim`).

SourceKit's "No such module" diagnostics for the local packages are index noise; `build_sim` is the source of truth.

## Done

Before reporting done:
- `build_sim` and `test_sim` pass.
- `scripts/check.sh` ends with `check.sh: OK`. `test_sim` covers only the app target; `check.sh` covers the packages (lint and tests on the Mac) and the String Catalog.
- For any UI change, the check in `docs/agents/ui-check.md` passes on iOS 27. The iOS 18 deployment target is the user's own check: tick an acceptance box naming iOS 18 once the iOS 27 check passes, without waiting for them, and run iOS 18 only when they ask.
- A check that couldn't run is reported as skipped, with its acceptance box left unticked.

## Editing

Add or change String Catalog keys with `scripts/xcstrings.py set KEY EN UK`, which writes the file in Xcode's own format and keeps SwiftLint's key prefixes in step.

A file kept out of a target in a synchronized folder (such as a `.gitkeep`) is listed in a `PBXFileSystemSynchronizedBuildFileExceptionSet` in `project.pbxproj`. When you delete or rename one, update its entry; once a set is empty, delete it and the folder's `exceptions = (...)` reference to it, then run `build_sim`.
