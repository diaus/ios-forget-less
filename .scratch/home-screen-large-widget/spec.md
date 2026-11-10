# Large and medium Home Screen widgets

Status: ready-for-agent

## Problem Statement

The "Upcoming" widget shows what's left to do, but acting on it means opening the app. On the Home Screen, the user wants to tick a Task off and nudge it up or down the list straight from the widget.

## Solution

The "Upcoming" widget gains the large and medium Home Screen sizes (`.systemLarge`, `.systemMedium`), the sizes with controls. They list the same Tasks with the same settings. Each row adds a circle at the front, which makes the Task Complete, and two arrows at the end, `arrowshape.up` and `arrowshape.down`: the up arrow Moves the Task one step up, and the down arrow Moves it one step down. Tapping anywhere else opens the app.

## User Stories

1. As a user, I want a large "Upcoming" widget on the Home Screen, with the same settings and the same Tasks in the Schedule's order, so that I see more of my list.
2. As a user, I want the sizes with controls to keep every row at the full font and gap (17pt, 5pt apart), listing as many as fit from the top and never shrinking them, so that every row stays readable and its controls easy to hit. The small widget still fits rows by shrinking the gaps first, then the font.
3. As a user, I want a circle at the front of each row that makes the Task Complete on Today, so that I tick it off without opening the app.
4. As a user, I want a Task I complete to stay in its place, struck through, for the widget's Grace Period, then leave, so that the widget holds only what's still to do and a mis-tap can be undone.
5. As a user, I want the up arrow to Move the Task one step up and the down arrow to Move it one step down, so that each arrow does what it shows.
6. As a user, I want a step to pass the listed Task beside it, skipping the Complete Tasks the widget doesn't list, so that every tap changes what I see.
7. As a user, I want a step down from the last Today row to put the Task first on Tomorrow, and a step up from the first Tomorrow row to put it last on Today, so that I can push a Task to Tomorrow and bring it back.
8. As a user, I want a Task never Moved into or out of Overdue from the widget, and an Overdue Task Moved only within its own Day, as in the app.
9. As a user, I want a step down from the last Today row only while Tomorrow is listed, so that a Task never disappears after a tap.
10. As a user, I want a step never to take a Task past a row the widget couldn't fit, so that a Task never disappears after a tap.
11. As a user, I want an arrow that can't Move the Task hidden, with its place kept so the arrows line up, so that I know before tapping.
12. As a user, I want the arrows' tap targets wider than the glyph, so that a thumb hits them.
13. As a user, I want the "!" and "→" markers kept on the sizes with controls, so that Overdue and Tomorrow rows still stand apart.
14. As a VoiceOver user, I want the circle read as "Complete" and the arrows as "Move Up" and "Move Down", with an arrow that can't act left out.
15. As a user, I want the small widget and the Lock Screen widget unchanged.
16. As a user, I want a medium "Upcoming" widget with the large one's circle and arrows, so that I can tick off and Move Tasks from a widget half the size.
17. As a user, I want to tap the checked circle of a Task in its Grace Period to make it Incomplete again, in place, so that I undo a mis-tap without opening the app.
18. As a user, I want to set each medium and large widget's Grace Period ("Keep Complete Tasks For": Off, 3 s, 5 s, 10 s or 20 s; 3 s by default), with Off dropping a Task at once, so that each widget keeps a Task as long as suits it.
19. As a user, I want a Task in its Grace Period to show no Move arrows, and the "+N" to stay as it was until the Task leaves, so that only the undo is offered and the rest of the widget doesn't shift.
20. As a user, I want a Task I complete in the app kept on a widget for what's left of that widget's Grace Period, so that every widget follows one rule.
21. As a user, I want a Task in its Grace Period dropped at the rollover, so that the widget shows the new Today straight away.
22. As a VoiceOver user, I want the checked circle read as "Make Incomplete".
23. As a user, I want a Task I complete from Overdue in the app to stay in Overdue, Complete, for an hour, even past midnight, so that a mis-tap can be undone whatever my time zone.

## Implementation Decisions

- **Domain:**
  - A pure step rule on the widget's listed Tasks gives each Task its step up and step down as a `MoveDestination`, or none.
  - The step down has a second form for the last row shown while rows after it are left out. That form is none when the step would pass one of those rows.
  - `MoveDestination` becomes `Hashable`.
- **Data:**
  - A read-write App Group repository for the widget (`TodoTaskWriter`). It's nil while the app hasn't created the store, and it never creates or wipes a store.
- **Widget:**
  - `.systemLarge` and `.systemMedium` join the supported families.
  - One `WidgetFamily` check says whether a size has controls, beside `isOnLockScreen`. The rows view and the timeline provider ask it, not `== .systemLarge`.
  - The sizes with controls have their own `TextRowsSizing`, whose smallest gap and font are the full ones, so rows never shrink and those that don't fit are left out from the end.
  - The settings sheet shows the Lock Screen's settings only on the Lock Screen, and the small size's settings on every Home Screen size.
  - The content keeps every listed Task for the sizes with controls, and each row carries its steps.
  - Two App Intents, Complete and Move, write through `TodoTaskWriter`. They're hidden from Shortcuts. A failed write is logged.
  - Each intent reloads every timeline after its write (ADR 0005).
  - The row controls live with the rows views.
- **Grace Period and the Overdue hour** (issues 03 and 04):
  - A Task stores `completeTime`, the moment it was made Complete, in place of `completeDay` (ADR 0007). V1 is edited in place, with `originalName` for the one device holding real data.
  - Overdue keeps a Task completed from it for an hour after `completeTime`, measured against now, and the app rebuilds the Schedule when that hour ends.
  - The widget's setting is a `WidgetConfigurationIntent` parameter, shown only on the sizes with controls. The timeline lists the Complete Tasks within it, with an entry for each one's leaving, and none in the rollover entry.
  - The circle of a Task in its Grace Period runs an intent that makes it Incomplete.
- **ADR 0005** records that the widget writes, and supersedes ADR 0003's no-write consequence.

## Testing Decisions

- **Domain**, through the step rule, with ordered Tasks and an explicit `today`:
  - within a Day, past a hidden Complete Task;
  - the edges of a Day;
  - the Today/Tomorrow border, both ways, and with Tomorrow not listed;
  - Overdue Tasks, on one past Day and across two;
  - the last row shown while later rows are left out, both the same-Day case and the Tomorrow case.
- **Data:** `TodoTaskWriter` against a store file in a temporary folder. It returns nil with no store, and it saves a write that a fresh reader then reads.
- **Widget:** `RenderPreview` of the large and medium sizes with 3, 8 and 20 Tasks, every marker, hidden arrows, the empty and unreadable states, and the gallery sample.
- **Done:** `build_sim`, `test_sim` and `scripts/check.sh` pass. On the iOS 27 simulator's Home Screen, the large and medium widgets are added and a Complete and a Move each change the list.

## Out of Scope

- The extra-large size, and controls on the small size or the Lock Screen.
- Undo from the widget after the Grace Period.
- Opening a specific Task on tap.
- Showing that Tasks were left out: see `.scratch/widget-left-out-count/`.
