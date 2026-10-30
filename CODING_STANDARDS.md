# Coding Standards

These are the judgement calls for reviewing a diff. Tooling already enforces the mechanical rules, so a review skips them:
- SwiftLint (`ForgetLess/.swiftlint.yml`): its default style rules, plus catalog symbols instead of string literals, no `localizedDescription`, no GLOSSARY "Avoid" words in identifiers, no `Calendar` outside Domain's Day extensions.
- Zero warnings: compiler and SwiftLint warnings are errors in the app and the packages.
- The String Catalog format and its `en`/`uk` coverage (`scripts/xcstrings.py check`).

Domain vocabulary lives in `GLOSSARY.md`, decisions in `docs/adr/`.

## Architecture

- **Layers.** Domain imports neither SwiftData nor SwiftUI, so it doesn't depend on the storage or the UI chosen. Only Data imports SwiftData. Factory wiring lives in Data's `DI/` and the app's `Composition/`.
- **Utils is project-independent.** It holds helpers another project could reuse (a concurrency primitive, a Foundation extension). It imports only the standard library and Apple's system frameworks: no Domain, no Data, no third-party package. The glossary lint rule skips it.
- **A Task's Day is a `Date` at 00:00 GMT everywhere** (ADR 0001). Data stores and queries it as given. The local calendar is read only for Today, which is Domain's `Date.today`. A new Day operation is a helper in Domain's `Date+Day`, and Days are formatted in GMT (`Date.FormatStyle(calendar: .gmt, timeZone: .gmt)`).
- **Folders by role.** A new file goes in the folder for its role:
  - Domain: `Models/`, `Repositories/` (protocols), `UseCases/`, `Errors/`, `Extensions/`. `Models/` splits by DDD building block:
    - `Entities/`: a stored record with its own ID (`TodoTask`).
    - `ValueObjects/`: a value without an ID, equal by its fields.
    - `ReadModels/`: computed for a screen, never stored (`Schedule`).
  - Data: `Repositories/` (the concrete repositories only), `Infrastructure/` (generic SwiftData helpers the repositories share), `Mapping/` (model ↔ domain), `Schema/V<n>/`, `DI/`, `Errors/`.
  - App: `App/`, `Composition/`, `Features/<Feature>/` (a view and its view model), `Shared/{Components,Extensions,Modifiers,Preview}/`.
  - Mixed folders get split. Repositories and helper infrastructure don't share a folder.
- **A use case exists only when an operation does at least one of these:**
  - (a) applies a business rule beyond passing values through;
  - (b) composes more than one repository call;
  - (c) is shared by several view models.

  Otherwise the view model calls the repository directly: no pass-through use cases. `AddTask` qualifies: it applies the name rule before creating. So does `LoadSchedule`, which composes the queries behind the Schedule. Set Complete and delete are single repository calls made directly. A rule that needs no I/O, such as the end-of-Day rule, is a pure Domain function or entity method. Use cases and view models call it, and it's tested without fakes. A repository calls it when the rule must read and write in one step, as `create(name:day:)` does with the end-of-Day rule, so two creates at once can't take the same place. If nearly all data access ends up going through use cases, route all of it that way for consistency.
- **No speculative abstraction.** Add a protocol, wrapper or injection point only for a need the current spec has. View models read `Date.today`; use cases take `today` as a parameter, so there is no clock or `DateProvider` to inject. A two-case enum that only means yes/no is a `Bool`.

## Naming

- **The glossary word is Task; the type is `TodoTask`.** That's the one place the code departs from the glossary, so it doesn't shadow Swift's `Task`. Derived names follow the type (`TodoTaskRepository`). Prose, test names and catalog keys say Task (`addTaskAppendsAtEndOfItsDay`).
- **One concept, one name across features.** If two views or view models hold the same thing (the Task being edited, the composer's Day), they name it the same way.
- **An extension file's name covers all its members.** `Date+DayChip.swift` holds the category, label and colour of a Day chip. `Date+ChipLabel.swift` would mislead.
- **A SwiftUI view's type ends in `View`** (`ScheduleView`, `ComposerView`, `TaskRowView`), and its file takes the same name.
- Use glossary terms in names, keys and test names, even where the linter can't see the word (test display strings, comments, catalog values).

## Layout

- **A type with more than one group of members marks each group with `// MARK: - <Group>`.** Stored properties and `init` lead the type unmarked. Each group after them opens with its MARK on its own line, a blank line before it and none after. Views use `Body`, `UI Components` (the subviews `body` composes), `Actions` and `Gestures`. A view model names its groups by what they drive (`Loading`, `Composer`). A test suite splits `Tests` from `Helpers`, and private helpers anywhere go under `Helpers`. A type with one group after its `init` (`AddTask`, `FakeTodoTaskRepository`) has no MARKs.

## Comments

- **A doc comment says what a thing is for, not how it works,** so it stays true when the layout changes, another symbol is renamed, or a constant or initializer is added. It leaves out visuals (colours, fonts, layout), constants and thresholds (`Today + 99`), call sequences and what the symbols it uses do, and project-wide rules restated per symbol ("as 00:00 GMT" on every Day). The exception is a contract the caller relies on and can't see in the signature: "in no particular order", "does nothing when no Task has `id`", the error thrown. `Schedule` reads "What the Schedule screen lists.", not the window it spans.
- **No doc comment when the name already says it** (`days`, `toggleComplete`, `dayChipColor`, private actions).
- **An inline `//` gives the why for the line beside it** ("Only the circle takes the tap: a row tap is for renaming."). A why that concerns one line goes there, not in the doc comment.

## SwiftUI

- **View models** are `@MainActor @Observable` and own the async work. Views call into them from `.task`, `.onChange` and actions. A view holds its view model as `vm`, never `viewModel`.
- **Conditional containers render something on every path.** When `.task`, `.onAppear` or `.onChange` hang off a `Group` or `if` chain, every branch, including the loading state, produces a view (`ProgressView()`, never nothing). An empty first render never fires `.task`, and the screen stays blank.
- **Keyboard focus is set synchronously, in the action that asks for it,** on a field that is already mounted. Never focus from a delayed `onAppear`, `asyncAfter` or `Task.sleep`. Never put a text field that must focus at once inside a `.sheet`.
- **Colours with meaning come from the asset catalog with light and dark variants,** never a hard-coded `Color.green`, so both appearances stay readable.
- Errors reach the user through `error.userMessage` and `.errorAlert(message:)`.

## Tests

- **Each test can fail for a real regression.** Reject tests that:
  - compare against UI copy (`String(localized: .dayToday) == "Today"`), because they break on every wording change;
  - restate a declaration: an enum's `allCases`, a schema version, a constant;
  - re-check what the compiler already guarantees (generated catalog symbols, exhaustive switches);
  - use a fake the code under test can never reach, so the assertion passes whatever the code does.
- **Tests never depend on the machine's clock or time zone.** Pass `today`, never `Date.today`. Days are GMT midnights, so only the Today rule's tests pin a local time zone, on both sides of GMT.
- **SwiftData fetches are unordered unless sorted.** Tests compare as sets or sort first. Code that needs an order sorts explicitly (by `sortIndex` within a Day).
- Test names describe behaviour in glossary terms (`keepsACompletedOverdueTaskUntilRefresh`).

## Blast radius

Run `graft build . --no-ignore && graft blast --base <fixed-point> --no-owners` once per review. The build takes under a second and makes a fresh clone work. For uncommitted work, omit `--base`: with it, blast compares the merge base with HEAD and sees nothing, while without it, blast diffs the working tree against HEAD. Blast lists the code that depends on the changed lines, and marks each changed area `✗` when no test reaches it. Without the `graft` CLI, report this step as skipped.

- **Every listed dependent still fits the change.** Read each one against the new behaviour: a caller that passes old arguments, a screen that shows a changed view, a use case that relies on an old rule.
- **A `✗` area that holds logic gets a test,** in the package's tests where the logic lives. View models stay untested in v1 (spec); logic in one that deserves a test moves to Domain. A view with no logic of its own needs none.
- **The list undercounts.** graft misses calls through a protocol (`repository.create(...)`) and callers of a name two symbols share. Grep the changed protocol methods and shared names before calling a change contained.
