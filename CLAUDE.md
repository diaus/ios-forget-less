## Agent skills

### Issue tracker

Issues live as local markdown files under `.scratch/<feature>/`. See `docs/agents/issue-tracker.md`.

### Triage labels

Default canonical labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`), recorded as a `Status:` line in each issue file. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## Layout

The project is `ForgetLess/ForgetLess.xcodeproj`. Beside it are:
- the app, `ForgetLess/ForgetLess/` (`App/`, `Composition/`, `Features/<Feature>/`, `Shared/`, `Resources/`);
- the app tests, `ForgetLess/ForgetLessTests/`;
- the local packages, `ForgetLess/Packages/{Domain,Data}`.

Review rules are in `CODING_STANDARDS.md`. The v1 spec is `.scratch/forget-less-v1/spec.md`.

## Building

Build, test and run through the MobileBuildMCP tools (`build_sim`, `test_sim`, `build_run_sim`).

`test_sim` runs only the app target's tests. Before reporting done, run `scripts/check.sh`: it lints the packages, checks the String Catalog's format and en/uk coverage, and runs every local package's tests on the Mac.

SourceKit's "No such module 'Domain'/'Data'" diagnostics are index noise; `build_sim` is the source of truth.

For any UI change, before reporting done, drive the running app with MobileBuildMCP's UI tools (`snapshot_ui`, `tap`, `type_text`) on the deployment target, iOS 18. Confirm each action from the snapshot it returns, since a tool's success status can't tell a dropped tap from a landed one. A check that couldn't run is reported as skipped, with its acceptance box left unticked.

## Editing

Add or change String Catalog keys with `scripts/xcstrings.py set KEY EN UK`, which writes the file in Xcode's own format and keeps SwiftLint's key prefixes in step.
