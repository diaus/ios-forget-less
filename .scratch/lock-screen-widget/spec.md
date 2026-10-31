# Lock Screen widget

Status: ready-for-agent

## Problem Statement

To see what's left to do, the user has to unlock the phone and open the app. They want a glance at the Lock Screen to show their Overdue and Today's Incomplete Tasks, and optionally Tomorrow's, without unlocking anything.

## Solution

A Lock Screen widget in the rectangular accessory family, called "Upcoming". It lists Overdue and Today's Incomplete Tasks in the Schedule's order, one line each. A bold "!" marks an Overdue Task, and a bold "→" marks a Tomorrow Task when Tomorrow is turned on.

- **Up to 4 Tasks** fill one column. A name that doesn't fit ends with "…".
- **5 to 8 Tasks** split into two balanced columns with a vertical line between them. A name that doesn't fit ends with "⋮".
- **No Tasks** shows a checklist symbol with a checkmark badge.

Two settings choose whether Overdue Tasks (on by default) and Tomorrow's Tasks (off by default) are listed. The widget updates after every change made in the app, and at midnight. Tapping it opens the app.

## User Stories

### What the widget lists

1. As a user, I want my Incomplete Tasks for Today on the Lock Screen, so that I see what's left without unlocking the phone.
2. As a user, I want my Overdue Tasks listed too, so that unfinished work from earlier Days isn't forgotten.
3. As a user, I want each Overdue Task to start with a bold "!", with no space before its name (`!Pay rent`), so that late Tasks stand out without costing width.
4. As a user, I want Today's Tasks to have no marker, so that the usual case reads cleanest.
5. As a user, I want the Tasks in the Schedule's order, so that the widget matches the app: Overdue first, oldest Day first, then by position within the Day; then Today's by position; then Tomorrow's by position.
6. As a user, I want Complete Tasks never listed, including a Task completed from Overdue on Today that the Schedule still shows until Today rolls over, so that the widget holds only what's still to do.
7. As a user, I want a "Show Overdue Tasks" setting, on by default, so that I can leave Overdue Tasks off my Lock Screen.
8. As a user, I want a "Show Tomorrow's Tasks" setting, off by default, so that I can plan ahead from the Lock Screen when I want to.
9. As a user, I want each Tomorrow Task to start with a bold "→", with no space before its name, so that I can tell it apart from Today's and Overdue Tasks.
10. As a user, I want the settings labelled "Show Overdue Tasks" / «Показувати прострочені завдання» and "Show Tomorrow's Tasks" / «Показувати завдання на завтра», so that they read in my language.

### Layout

11. As a user, I want each Task on one line, never wrapping, so that the list stays a list.
12. As a user, I want 1 to 4 Tasks in a single column, vertically centred, with a name that doesn't fit ending in "…", so that a short list looks balanced.
13. As a user, I want 5 to 8 Tasks in two columns, the left taking the larger half (5 → 3+2, 6 → 3+3, 7 → 4+3, 8 → 4+4), so that the widget holds up to twice as many Tasks.
14. As a user, I want the two columns read down the left column first, then down the right, so that the order stays the Schedule's.
15. As a user, I want the two-column grid vertically centred, each column top-aligned within it, and its rows level across columns, so that the grid looks tidy.
16. As a user, I want a vertical line between the two columns, so that names from both columns don't run together.
17. As a user, I want a name in the two-column layout that doesn't fit to end in "⋮" instead of "…", so that a cut name takes less width.
18. As a user, I want a Task's marker never cut, so that I can always tell Overdue and Tomorrow Tasks apart, however long the name.
19. As a user, I want the first 8 Tasks listed when there are more than 8, and the rest left out, so that the widget stays readable.
20. As a user, I want the text the same size whatever the number of Tasks, sized so 4 rows fill the widget's height, so that the widget doesn't jump in size as Tasks come and go.
21. As a user, I want minimal padding, so that the most text fits in a small widget.

### Empty and error states

22. As a user, I want a `checklist.unchecked` symbol with a `checkmark` badge when there's nothing to list, so that I see at a glance that I'm done.
23. As a user, I want the same empty state before I've ever opened the app, so that a new widget doesn't look broken.
24. As a user, I want a `checklist.unchecked` symbol with an `exclamationmark.triangle` badge when the widget can't read my Tasks, so that it never falsely tells me I'm done.
25. As a user, I want the widget to try again by itself when it couldn't read my Tasks, so that it recovers without me doing anything.
26. As a user, I want each badge smaller than the checklist and centred on its top-right corner, with the whole symbol centred in the widget, so that the two read as one sign.

### Staying current

27. As a user, I want the widget to update right after I add, rename, complete, make Incomplete or delete a Task in the app, so that it never lags behind my list.
28. As a user, I want the widget to roll over at midnight without my opening the app: Today's Tasks become Overdue, with "!", and Tomorrow's become Today's, so that it's right first thing in the morning.
29. As a user, I want a Task's Day to stay put in the widget when I travel across time zones, so that it agrees with the app (ADR 0001).

### Interaction and privacy

30. As a user, I want tapping the widget to open the app, so that I can act on what I see.
31. As a user, I want Task names shown while the phone is locked, so that the widget is useful at a glance.
32. As a user, I want my Tasks to stay on the device, shared only between the app and its widget, so that my list stays private.

### Gallery

33. As a user, I want the widget named "Upcoming" / «Найближчі» and described as "Planned tasks" / «Заплановані завдання» in the widget gallery, so that I can find it.
34. As a user, I want the gallery preview to show sample Tasks, so that I can see what the widget does before adding it.
35. As a user, I want the widget in English and Ukrainian, following the device language, like the app.

## Implementation Decisions

### Store in the App Group (ADR 0003)

- The app and a new widget extension share an App Group, and the SwiftData store moves into its container. The widget opens the store read-only and works out Today itself, with the same Domain code as the app.
- Only the app creates the store. The widget's reader returns nothing while the store doesn't exist yet, and the widget shows the empty state.
- In the simulator only, a store that won't open is still deleted and created again, now in the App Group. SwiftUI previews keep the in-memory store.
- The old store in the app's sandbox isn't moved or deleted, because no install holds real data.

### Repository

- `TodoTaskRepository` gains `incompleteTasks(from firstDay: Date?, through lastDay: Date)`: the Incomplete Tasks whose Day is from `firstDay` through `lastDay`, with no lower bound when `firstDay` is nil. The widget passes:
  - `firstDay`: nil with Show Overdue Tasks on, Today with it off.
  - `lastDay`: Today with Show Tomorrow's Tasks off, Tomorrow with it on.
- Every fetch is sorted in the query, by Day and then by position within it, through one sort that Data shares among `tasks(on:)`, `scheduleTasks(today:)` and `incompleteTasks(from:through:)`. Each one's doc comment says "in order of Day, then position within it" instead of "in no particular order". `tasks(on:)` is sorted too for consistency, even though its one caller doesn't need the order.
- The repository takes an after-save hook as an `init` parameter and runs it after every successful save, never after a failed one.
  - Data's Factory registers a hook that does nothing.
  - The app overrides it to reload every widget timeline, so Data stays free of WidgetKit.
  - The hook is separate from the `ChangeNotifier` that feeds open streams (ADR 0002), because it must run on every save even when no stream is open (ADR 0003).
- Data exposes a read-only repository over the App Group store for the widget, created fresh for each timeline or snapshot request so a long-lived widget process sees the app's latest save.

### Domain

- `Schedule` stops sorting and relies on its input already being in order of Day, then position, as the repository now sends it. Grouping by Day and filtering keep that order. Its `init` doc comment states the input contract, since the caller can't see it in the signature.
- Domain's Day extensions gain three pure helpers:
  - **Where a Day sits relative to Today:** before Today, Today, Tomorrow, or later. The widget picks a Task's marker from it.
  - **Today at a given moment:** the Day that moment falls on in the local calendar. The widget computes the midnight entry's Today ahead of time.
  - **The next rollover after a given moment:** the next local midnight.

  The local calendar stays readable only inside Domain's Day extensions, which the SwiftLint rule enforces.
- No new glossary term: the set the widget lists is "Overdue and Today's Incomplete Tasks", plus Tomorrow's when that setting is on. **Tomorrow** is now in the glossary.

### Widget extension

- A new widget extension with one widget, "Upcoming", supporting the rectangular accessory family only. Its folders follow PillsTracker's widget by role: configuration, timeline and views. `CODING_STANDARDS.md`'s folder list gains them.
- **Configuration:**
  - An App Intent configuration with two Bool parameters, "Show Overdue Tasks" (default on) and "Show Tomorrow's Tasks" (default off).
  - The widget shares the app's String Catalog by target membership, as PillsTracker does. Keys are added with `scripts/xcstrings.py`.
  - The gallery name is "Upcoming" / «Найближчі», and the description "Planned tasks" / «Заплановані завдання».
- **Timeline:**
  - There's one entry for now and one at the next rollover, each with the Tasks for the Today of its moment. The reload policy is at the end.
  - When the store can't be read, the entry is the unreadable state and the next reload is in 15 minutes.
  - When the store doesn't exist yet, the entry is the empty state.
- **Content:**
  - The content is a list of rows or one of two states: empty, or unreadable.
  - Each row is a Task's name plus its marker: Overdue "!", Today none, Tomorrow "→". Both markers are bold, with no space before the name.
  - At most 8 rows; any further Tasks are dropped.
- **Layout:**
  - **1–4 rows:** one column, vertically centred. Names are cut by the system with "…".
  - **5–8 rows:** two columns. The left takes ⌈n/2⌉ rows. The grid is vertically centred, each column top-aligned within it, rows level across columns, with a vertical line between. SwiftUI can't change the truncation glyph, so the widget measures each name against its column's width and cuts it itself, ending it with "⋮". The marker is never cut.
  - **Text and padding:** the font size is fixed whatever the count, sized so 4 rows fill the widget's height. Padding is minimal.
- **Symbols:**
  - The empty state is `checklist.unchecked` with a `checkmark` badge. The unreadable state is `checklist.unchecked` with an `exclamationmark.triangle` badge.
  - Each badge is about 60% of the checklist's size, centred on its top-right corner. The composed symbol is centred in the widget, at about two-thirds of its height.
  - The sizes are tuned with `RenderPreview` and agreed with the user.
- **Interaction and appearance:**
  - There's no widget URL: a tap opens the app as it was.
  - The view isn't marked privacy-sensitive, so names show while the phone is locked.
  - Markers and states stand apart by glyph and weight, not colour, because the Lock Screen renders accessory widgets in one vibrant tint.
- **Gallery:** the gallery snapshot shows sample Tasks, including an Overdue one. The placeholder is the same sample, which iOS redacts.

### Docs

- ADR 0003 records the App Group store and the after-save hook.
- The UI check doc's "Tasks on past Days" step names the store's new location, in the App Group container rather than the app's data container.

## Testing Decisions

A good test exercises behaviour through a public interface and asserts on outcomes: returned Tasks and their order, how often the hook ran. Tests pass `today` explicitly, Days are GMT midnights, and only the Today-at-a-moment tests pin a local time zone, on both sides of GMT. Swift Testing only.

- **Data**, against an in-memory `ModelContainer`, as in `TodoTaskRepositoryLiveTests`:
  - `incompleteTasks(from:through:)`:
    - With no lower bound, it holds every Incomplete Task up to and including `lastDay`.
    - With Today as the lower bound, it leaves out Overdue Tasks.
    - It includes Tomorrow's Tasks only when `lastDay` is Tomorrow.
    - It never holds a Complete Task, including one completed from Overdue on Today.
  - Order: `tasks(on:)`, `scheduleTasks(today:)` and `incompleteTasks(from:through:)` each return Tasks by Day, then position, with the Tasks inserted out of order.
  - The after-save hook runs once for each successful create, rename, setComplete and delete, and never when a save fails.
- **Domain**:
  - `ScheduleTests` feed ordered input, as the repository now sends it, and drop the cases that only checked `Schedule`'s own sorting. The grouping, window, Overdue and hiding cases stay.
  - The new Day helpers, as in `DateDayTests` and `CalendarDayTests`:
    - Where a Day sits relative to Today, for a Day before Today, Today, Tomorrow and Today + 2, including across a year boundary.
    - Today at a moment, and the next rollover after it, at fixed moments in pinned zones on both sides of GMT, away from a daylight-saving change.
- **Widget**: no test target. Its layouts are checked through Xcode previews (`RenderPreview`):
  - 1, 4, 5, 7 and 8 rows, and 9 or more
  - long names in both layouts
  - every marker
  - the empty and unreadable states
- No view-model, UI or snapshot tests, as in v1.
- **Done:**
  - `build_sim`, `test_sim` and `scripts/check.sh` pass.
  - The app's UI check on iOS 27 confirms the Schedule still lists Tasks in the same order.
  - The widget on a real Lock Screen can't be driven by the tools, so that check is reported as skipped unless the user runs it.

## Out of Scope

- Completing or otherwise changing Tasks from the widget (interactive widgets).
- Home Screen and StandBy widgets, and every accessory family other than rectangular.
- Opening a specific screen or Task on tap.
- Moving the old sandbox store into the App Group.
- A widget test target.
- Custom VoiceOver labels for the markers.
- Any setting beyond Show Overdue Tasks and Show Tomorrow's Tasks.

## Further Notes

- This feature lifts v1's "Widgets" out-of-scope line. The v1 spec stays as it shipped.
- Prior art: PillsTracker's Lock Screen widget, with its App Group store (its ADR 0003), per-save reload hook (its ADR 0005), read-only widget repository and midnight timeline entry.
- With Show Overdue Tasks off, no "!" ever shows. With more than 8 Tasks, Tomorrow's Tasks are the first to drop, since they come last.
- Tickets are in `issues/`: 01 (one shared order) and 02 (the App Group store and reload hook) can run in parallel, and 03 (the whole widget, settings included) follows both.
