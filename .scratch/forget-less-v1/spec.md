# Forget Less v1

Status: ready-for-human (spec agreed; not started)

## Problem Statement

The user wants a plain, fast todo list for planning what to do on which day. They want to write a Task down in a second, without waiting for the keyboard, and then tick it off.

## Solution

An iPhone app with one screen: a scrolling list of Days from Today through the next 99 Days. Overdue Tasks sit in a section above Today. Each Day has a header with a "+", and a red floating "+" adds to Today. Adding or editing happens in a quick-add composer pinned above the keyboard, which comes up together with the panel. A Task is completed by tapping its circle, renamed by tapping its row, and deleted by swiping left. The look follows the reference screenshot without the "Inbox" project label.

## User Stories

### The list

1. As a user, I want one list of Day sections from Today through Today + 99, every Day shown even when it has no Tasks, so that I can plan ahead without navigating.
2. As a user, I want a Task planned beyond Today + 99 to still appear under its own Day header after the window (empty Days between are not shown), so that nothing I planned is hidden.
3. As a user, I want each Day header to read `25 Oct · Today · Sunday`, `26 Oct · Tomorrow · Monday` or `27 Oct · Tuesday`, with the year added when it isn't the current year (`3 Jan 2027 · Sunday`), formatted for the device locale, so that I always know which Day I'm looking at.
4. As a user, I want a Day header and its "+" in bold primary colour when the Day has any Task (Complete or not), and in grey when it has none, so that busy Days stand out.
5. As a user, I want an "Overdue" section above Today listing my Incomplete Tasks from earlier Days, oldest Day first, so that unfinished work is never lost.
6. As a user, I want each Overdue row to show its own Day as a small red label (`20 Oct`) at the bottom trailing edge, so that I can tell how late it is.
7. As a user, I want the Overdue section to have no "+", so that I can't plan a Task in the past.
8. As a user, I want Tasks within a Day in the order I added them, so that the list is stable.
9. As a user, I want no navigation bar or title, just the list and a red floating "+" at the bottom trailing corner, so that the screen stays calm.

### Completing

10. As a user, I want to tap a Task's circle to make it Complete and tap again to make it Incomplete, so that a mis-tap is reversible.
11. As a user, I want a Complete Task shown with a filled grey check circle and its name struck through and greyed, so that done and not-done are obvious at a glance.
12. As a user, I want a Task to keep its place when I complete it, so that the list doesn't jump under my finger.
13. As a user, I want a Task I complete from the Overdue section to stay there (struck through) until the list next refreshes (app becomes active again, or Today rolls over), so that I can undo a mis-tap.

### Adding

14. As a user, I want the floating "+" to open the composer for Today and a Day header's "+" to open it for that Day, so that I add exactly where I mean.
15. As a user, I want the composer to appear as a rounded panel right above the keyboard with the name field already focused, with no delay before the keyboard shows, so that I can type immediately.
16. As a user, I want the composer to show the Task Name field, a Day chip, and an `arrowtriangle.right.fill` submit button, so that I see where the Task will go.
17. As a user, I want the Day chip to read `Today` (green), `Tomorrow` (orange), a weekday such as `Sunday` (light blue) for Days before Today + 7, or a short date such as `Nov 10` (light grey, with the year if not the current year) for later Days, with darker equivalents in light mode for contrast, so that the Day reads at a glance.
18. As a user, I want the submit button accent-red when the trimmed name isn't empty and grey and disabled otherwise, and Return on a blank name to do nothing, so that I can't add a blank Task.
19. As a user, I want the submit button to add the Task at the end of its Day and keep the composer open with the name cleared and the same Day, so that I can add several Tasks in a row.
20. As a user, I want to dismiss the composer by tapping the dimmed background or swiping down, so that leaving is easy.
21. As a user, I want to be asked "Discard changes?" (Discard / Keep Editing) when I dismiss with a non-empty trimmed name, so that I don't lose typing by accident; Keep Editing returns me to the field with the keyboard up.

### Editing and deleting

22. As a user, I want tapping a Task's row (Complete or not) to open the same composer with its name filled in and its Day on the chip, so that I can fix a typo.
23. As a user, I want saving an edit to close the composer, so that a single fix is a single action.
24. As a user, I want to be asked "Discard changes?" when I dismiss an edit whose trimmed name differs from the saved one, so that edits aren't lost by accident.
25. As a user, I want to swipe a row left to reveal a trash button, then confirm `Delete "name"?` (Delete / Cancel), so that deleting is deliberate; a full swipe does not delete on its own.

### Quality

26. As a user, I want my Tasks to stay on the device, with no account or sync, so that my list is private.
27. As a user, I want the app in English and Ukrainian, following the device language, so that it speaks my language.
28. As a user, I want a Task's Day never to move when I travel across time zones, so that my plan stays as I made it.
29. As a user, I want the app to follow the system light/dark appearance, with the reference screenshot as the dark rendering and red as the accent, so that it fits the rest of my phone.

## Implementation Decisions

### Project

- Layout mirrors PillsTracker: `ForgetLess/ForgetLess.xcodeproj`, the app at `ForgetLess/ForgetLess/` (`App/`, `Composition/`, `Features/<Feature>/`, `Shared/{Components,Extensions,Modifiers,Preview}/`, `Resources/`), app tests in `ForgetLess/ForgetLessTests/`, local packages in `ForgetLess/Packages/{Domain,Data}`.
- No `Utils` package in v1. It is created when the first project-independent helper turns up.
- Deployment target iOS 18. Swift 6 language mode with complete strict concurrency in the app target and in both packages (`swiftLanguageModes: [.v6]`). Packages also declare `.macOS(.v15)` so `swift test` runs on the Mac.
- Delete the `ForgetLessUITests` target.
- Factory (`FactoryKit`) for DI: Data registers the `ModelContainer` and the repository in `DI/`; the app registers use cases in `Composition/`.
- SwiftLint build plugin with `ForgetLess/.swiftlint.yml`, a String Catalog at `ForgetLess/ForgetLess/Resources/Localizable.xcstrings` with `en` and `uk` for every key, edited with `scripts/xcstrings.py`. `scripts/check.sh` runs before reporting done.
- Storage is local SwiftData with a `VersionedSchema` from day one. No CloudKit, no App Group.

### Domain model

- **`TodoTask`** (an entity; the glossary word is Task, and the type name avoids shadowing Swift's `Task`): `id: UUID`, `name: String`, `day: Date` (00:00 GMT of its year/month/day, ADR 0001), `isComplete: Bool`, `sortIndex: Int`. A `Sendable` value type.
- **Name rule** (pure function in Domain): trim whitespace and newlines; an empty result throws `DomainError.emptyName`. Single line, no length limit.
- **End-of-Day rule** (pure function in Domain): `TodoTask.nextSortIndex(in tasksOfDay:)` is the highest `sortIndex` + 1, or 0 for an empty Day. Gaps are allowed.
- **Schedule** (a read model, never stored): the Overdue Tasks (by Day ascending, then `sortIndex`) and one entry per Day from Today through Today + 99, followed by an entry for each later Day that has Tasks. Each entry holds its Tasks ordered by `sortIndex`. Building it is a pure Domain function of the Tasks and Today.
- There is no `Day` type and no clock. Today is a parameter (`today: Date`, 00:00 GMT). Domain computes it as `Date.today`, the one place the local calendar is read, and the view model reads it.

### Use cases

Per the use-case rule in `CODING_STANDARDS.md`:

- **`AddTask(name:day:)`**: applies the name rule, then has the repository create the Task.
- **`LoadSchedule(today:keepingOverdue:)`**: fetches the Tasks from Today on, the Incomplete Tasks before Today, and the Tasks whose ids are in `keepingOverdue` (Overdue Tasks completed since the last refresh, story 13), then builds the Schedule.
- Called directly from the view model, with no use case: rename (name rule, then `repository.rename`), set Complete/Incomplete, delete.

### Repository

- `TodoTaskRepository` (Domain protocol, async throwing) has these methods:
  - `tasks(on:)`
  - `tasks(onOrAfter:)`
  - `incompleteTasks(before:)`
  - `tasks(ids:)`
  - `create(name:day:)`: creates the Task Incomplete at the end of its Day. It reads the Day and inserts in one actor call with no suspension between, so two creates at once can't take the same place.
  - `rename(id:name:)`
  - `setComplete(id:isComplete:)`
  - `delete(id:)`
- `TodoTaskRepositoryLive` (Data) is an actor conforming to `ModelActor`, as in PillsTracker.
- Day storage is per ADR 0001. A Day is already 00:00 GMT in Domain, so Data stores and queries it as given, with no `Calendar`.
- No change stream. All writes come from the one screen, whose view model reloads after each write.

### App

- **`ScheduleViewModel`** (`@MainActor @Observable`):
  - It owns Today, the Schedule, the composer state and all writes.
  - It does a full refresh (recompute Today, clear `keepingOverdue`) on launch, when the scene becomes active, and on `significantTimeChangeNotification`, which fires at midnight and on time-zone changes.
  - After a write it reloads while keeping `keepingOverdue`.
- **Composer** (the no-delay keyboard approach):
  - No `.sheet`. The composer panel and its `TextField` are always mounted in a `ZStack` over the list and hidden while unused, with `opacity`, or with an off-screen `offset` if a hidden field can't take focus.
  - The "+" and row-tap actions set the composer's visible state and `@FocusState` **synchronously** in the same action, so the keyboard starts in the same frame. Never use `asyncAfter` or `Task.sleep` delays.
  - The panel respects the keyboard safe area, so it rides up with the keyboard.
  - Visibility is its own state, separate from focus, so the "Discard changes?" dialog can take focus away without closing the composer.
  - A dim layer behind the panel catches the tap-outside dismissal, and a downward drag on the panel dismisses too.
  - The Day chip is display-only: there's no date picker in v1.
- **Day chip category**: Today, Tomorrow, weekday (before Today + 7), later, or past (an Overdue Task being edited: short date in red). It's a pure function of the Day and Today, mapped to label and colour in `Shared/Extensions/`. Colours are asset-catalog colours with light and dark variants.
- **Rows**: the circle is an empty grey ring, or a filled grey circle with a white checkmark when Complete. Separators are inset to the text. Swipe actions have `allowsFullSwipe: false`.
- Errors reach the user through `error.userMessage` and `.errorAlert(message:)`, as in PillsTracker.

## Testing Decisions

A good test exercises behaviour through a public interface and asserts on outcomes: returned values, thrown errors, repository contents. Tests pass `today` explicitly, and Days are GMT midnights, so nothing depends on wall time or the machine's time zone. Only the Today rule's tests pin a local time zone. Swift Testing only.

- **Domain**:
  - the name rule (trimming, empty name refused);
  - the end-of-Day rule (empty Day, gaps);
  - the Today rule: a moment falls on its local year/month/day as 00:00 GMT, in time zones on both sides of GMT;
  - the Day count between two Days, and the same-year check behind the short date's year rule;
  - building the Schedule:
    - the 100-Day window, including empty Days;
    - later Days appear only when they have Tasks;
    - Overdue holds only Incomplete Tasks before Today, ordered by Day then index;
    - Tasks are ordered within a Day;
    - a kept Overdue Task stays after it's completed;
    - the window crosses a year boundary;
  - `AddTask`: creates the Task with the trimmed name and refuses an empty name, against a fake repository;
  - `LoadSchedule`, against a fake repository.
- **Data**, against an in-memory `ModelContainer`:
  - round trip of every field;
  - `create(name:day:)` creates the Task Incomplete at the end of its Day;
  - the Day round trip, including that the stored value is the Day as given;
  - `tasks(onOrAfter:)` and `incompleteTasks(before:)` boundaries at Today;
  - delete.
- **App**: the Day chip category for Today, Tomorrow, Today + 6, Today + 7 and a past Day.
- No view-model, UI or snapshot tests in v1.

## Out of Scope

- Date picker and moving a Task to another Day.
- Reordering, projects (the screenshot's "Inbox"), labels, priorities, search.
- Reminders and notifications, recurring Tasks.
- Widgets, iCloud or any sync, accounts, export.
- Auto-hiding or archiving Complete Tasks.

## Further Notes

- Vocabulary is in `GLOSSARY.md`; the decision on Day storage is ADR 0001.
- Suggested slices:
  1. Project settings and package scaffold, with lint, catalog and `check.sh` wired in.
  2. **Composer prototype** on the simulator: confirm the keyboard appears in the same frame as the panel, before building any other UI on it.
  3. Domain, with tests.
  4. Data, with tests.
  5. The Schedule list (headers, rows, completing, Overdue).
  6. Composer add and edit, with discard confirmation.
  7. Swipe to delete.
  8. Ukrainian strings and the light-mode colour pass.
