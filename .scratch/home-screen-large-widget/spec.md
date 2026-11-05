# Large Home Screen widget

Status: ready-for-agent

## Problem Statement

The "Upcoming" widget shows what's left to do, but acting on it means opening the app. On the Home Screen, the user wants to tick a Task off and nudge it up or down the list straight from the widget.

## Solution

The "Upcoming" widget gains the large Home Screen size (`.systemLarge`). It lists the same Tasks with the same settings. Each row adds a circle at the front, which makes the Task Complete, and the `arrow.up.forward.and.arrow.down.backward.rectangle.fill` symbol at the end. Both of the symbol's arrows point inward: its left half, under the up arrow, Moves the Task one step up, and its right half, under the down arrow, Moves it one step down. Tapping anywhere else opens the app.

## User Stories

1. As a user, I want a large "Upcoming" widget on the Home Screen, with the same settings and the same Tasks in the Schedule's order, so that I see more of my list.
2. As a user, I want the large widget to fit rows as the small one does (the gaps shrink first, then the font, never below the Lock Screen's size), listing as many as fit, so that a long list still shows.
3. As a user, I want a circle at the front of each row that makes the Task Complete on Today, so that I tick it off without opening the app.
4. As a user, I want a completed Task to leave the widget, so that the widget holds only what's still to do.
5. As a user, I want the symbol's left half, under its up arrow, to Move the Task one step up, and its right half, under its down arrow, to Move it one step down, so that each half does what its arrow shows.
6. As a user, I want a step to pass the listed Task beside it, skipping the Complete Tasks the widget doesn't list, so that every tap changes what I see.
7. As a user, I want a step down from the last Today row to put the Task first on Tomorrow, and a step up from the first Tomorrow row to put it last on Today, so that I can push a Task to Tomorrow and bring it back.
8. As a user, I want a Task never Moved into or out of Overdue from the widget, and an Overdue Task Moved only within its own Day, as in the app.
9. As a user, I want a step down from the last Today row only while Tomorrow is listed, so that a Task never disappears after a tap.
10. As a user, I want a step never to take a Task past a row the widget couldn't fit, so that a Task never disappears after a tap.
11. As a user, I want a half that can't Move the Task dimmed, and to do nothing, so that I know before tapping.
12. As a user, I want the halves' tap targets wider than the glyph, so that a thumb hits them.
13. As a user, I want the "!" and "→" markers kept on the large size, so that Overdue and Tomorrow rows still stand apart.
14. As a VoiceOver user, I want the circle read as "Complete" and the halves as "Move Up" and "Move Down", with a half that can't act left out.
15. As a user, I want the small widget and the Lock Screen widget unchanged.

## Implementation Decisions

- **Domain:**
  - A pure step rule on the widget's listed Tasks gives each Task its step up and step down as a `MoveDestination`, or none.
  - The step down has a second form for the last row shown while rows after it are left out. That form is none when the step would pass one of those rows.
  - `MoveDestination` becomes `Hashable`.
- **Data:**
  - A read-write App Group repository for the widget (`TodoTaskWriter`). It's nil while the app hasn't created the store, and it never creates or wipes a store.
- **Widget:**
  - `.systemLarge` joins the supported families.
  - The settings sheet shows the Lock Screen's settings only on the Lock Screen, and the small size's settings on both Home Screen sizes.
  - The content keeps every listed Task for the large size, and each row carries its steps.
  - Two App Intents, Complete and Move, write through `TodoTaskWriter`. They're hidden from Shortcuts. A failed write is logged.
  - Each intent reloads every timeline after its write (ADR 0005).
  - The row controls live with the rows views.
- **ADR 0005** records that the widget writes, and supersedes ADR 0003's no-write consequence.

## Testing Decisions

- **Domain**, through the step rule, with ordered Tasks and an explicit `today`:
  - within a Day, past a hidden Complete Task;
  - the edges of a Day;
  - the Today/Tomorrow border, both ways, and with Tomorrow not listed;
  - Overdue Tasks, on one past Day and across two;
  - the last row shown while later rows are left out, both the same-Day case and the Tomorrow case.
- **Data:** `TodoTaskWriter` against a store file in a temporary folder. It returns nil with no store, and it saves a write that a fresh reader then reads.
- **Widget:** `RenderPreview` of the large size with 3, 8 and 20 Tasks, every marker, dimmed halves, the empty and unreadable states, and the gallery sample.
- **Done:** `build_sim`, `test_sim` and `scripts/check.sh` pass. On the iOS 27 simulator's Home Screen, the large widget is added and a Complete and a Move each change the list.

## Out of Scope

- The medium and extra-large sizes, and controls on the small size or the Lock Screen.
- Undo from the widget.
- Opening a specific Task on tap.
