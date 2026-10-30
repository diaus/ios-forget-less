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

For any UI change, before reporting done, drive the running app with MobileBuildMCP's UI tools (`snapshot_ui`, `tap`, `drag`) on an iOS 27 simulator (the session default, iPhone 18 Pro). The iOS 18 deployment target is the user's own check, outside the agent's work: an acceptance box naming iOS 18 is ticked once the check passes on iOS 27, without waiting for them. Run iOS 18 only when they ask. Confirm each action from the snapshot in its own result (`capture.targets`) rather than a separate `snapshot_ui`, since a tool's success status can't tell a dropped tap from a landed one, and a `screenshot` can lag seconds behind the screen. Call `snapshot_ui` only once `build_run_sim` has returned. An elementRef tap hits the element's centre; when that misses a small control, tap its point with `scripts/sim-tap.sh X Y`, then `snapshot_ui`. While the software keyboard shows, type by tapping its keys: `type_text` sends hardware-keyboard events, which hide it until the user toggles it back with ⌥⌘K in Xcode's Device Hub. Once it's hidden (the snapshot lists no keys), type with `type_text`. Type dictionary words, since a pending autocorrect suggestion takes the next Return or button tap. `replaceExisting` appends rather than replaces. Relaunch with `xcrun simctl terminate`/`launch <udid> com.andrew.ForgetLess`: `stop_app_sim` and `launch_app_sim` need a bundle ID the session defaults lack. A check that couldn't run is reported as skipped, with its acceptance box left unticked.

## Editing

Add or change String Catalog keys with `scripts/xcstrings.py set KEY EN UK`, which writes the file in Xcode's own format and keeps SwiftLint's key prefixes in step.
