# Move All Overdue Tasks

Status: ready-for-agent

## Problem Statement

After a few days away, Overdue fills up. Each Task has to be moved on its own, by a drag, a swipe and the Choose a Day sheet, or its row's floating Day picker. Replanning ten Overdue Tasks for Today takes ten Moves. The user wants to Move every Overdue Task to one Day at once.

## Solution

The Overdue section's header gets a **Move All** label at its trailing edge. A tap opens the floating Day picker beside the header. A long press opens the Choose a Day sheet. Choosing a Day Moves every Overdue Task to the top of that Day, in the order Overdue listed them, and saves at once (see **Move** and **Overdue** in `GLOSSARY.md`).

## User Stories

### The label

1. As a user, I want a "Move All" label at the trailing edge of the Overdue header, where a Day header has its "+", so that I can replan all of Overdue in one go.
2. As a user, I want it in the accent tint, in the header's `.subheadline` font but not bold, so that it reads as an action and not as part of the title.
3. As a user, I want it shown only while Overdue holds at least one Incomplete Task, so that it never offers a Move of nothing. A section holding only Tasks completed from it on Today has no label.
4. As a user, I want it whether Move Tasks is on or off, so that it works like the other Day pickers: choosing a Day is a deliberate act and never changes the list by accident.
5. As a user, I want the label highlighted while it's touched and while its floating Day picker is open, so that I can see what the picker is for. The rows aren't highlighted.

### The floating Day picker (tap)

6. As a user, I want a tap on the label to open the floating Day picker: five weeks, paging sideways, the Today, Tomorrow and weekday buttons and the ✕, the same card a Task's row opens.
7. As a user, I want it to open on Today's month with nothing chosen, since no Overdue Day can be chosen.
8. As a user, I want it placed by the header the way a row's picker is placed by its row: below if the full card fits under it, else above, else on the side with more room. It is centred on the tap within the rows' margins and grows out of the tap point.
9. As a user, I want a tap on a Day to Move the Tasks at once and close the card about 0.15 s later, with no confirmation, as for one Task.
10. As a user, I want a touch outside the card, or its ✕, to close only the card, without scrolling the list.

### The sheet (long press)

11. As a user, I want a long press on the label (about 0.35 s, with a medium impact haptic when it's recognised) to open the Choose a Day sheet, as a long press on the composer's Day chip does, while a shorter tap still opens the floating Day picker.
12. As a user, I want the sheet unchanged: medium height, draggable to large, nothing chosen and Done disabled until I tap a Day, its summary line counting the chosen Day's Incomplete Tasks.
13. As a user, I want Done to Move the Tasks, and Cancel or a swipe down to change nothing.

### The Move

14. As a user, I want every Overdue Task Moved to the chosen Day, so that the label does what it says.
15. As a user, I want Tasks completed from Overdue on Today left where they are, still struck through in Overdue until Today rolls over, so that a done Task isn't planned again and a mis-tap can still be undone.
16. As a user, I want the moved Tasks at the top of the chosen Day, above every Task already there, Complete ones and hidden ones included, so that the work I've been putting off comes first.
17. As a user, I want them in the order Overdue listed them, oldest Day first, then by their position within their Day, so that the plan I had is kept.
18. As a user, I want the Tasks that are Overdue when I choose the Day moved, including any that became Overdue at midnight while the picker was open, so that "all" means all.
19. As a user, I want the Move saved as one change: if the save fails, every Task goes back to Overdue and the error alert shows, so that the list never holds half a Move.
20. As a user, I want the list to stay where it is after the Move, as after any other Day picker, so that I don't lose my place. Overdue disappears when nothing is left in it.
21. As a user, I want Moving never to make a Task Complete or Incomplete.
22. As a user, I want an open picker or sheet to close if nothing Overdue is left, for example after the widget moved the last one, so that it never offers a Move of nothing.
23. As a user, I want midnight handled as both pickers already handle it: Today's Day becomes choosable, past Days dim, and a chosen Day that's now past is cleared in the sheet.
24. As a user, I want the Lock Screen and Home Screen widgets to show the Tasks in their new places, as after any Move.

### VoiceOver

25. As a VoiceOver user, I want the label read as a button, "Move All", with the hint "Moves every Overdue Task to a Day", so that I know what it does.
26. As a VoiceOver user, I want a double tap to open the floating Day picker, as a tap does.
27. As a VoiceOver user, I want a "Choose Day" action on the label that opens the sheet, so that the long press has a VoiceOver equivalent, as on the composer's Day chip.
28. As a VoiceOver user, I want the count and the Day announced once the Move is saved ("5 tasks moved to Tomorrow", "1 task moved to 3 Dec"), so that I know what happened.

## Implementation Decisions

### Language

- This is a **Move** (`GLOSSARY.md`). "Reschedule" is under _Avoid_ and the `glossary_avoided_term` rule rejects it. Identifiers, catalog keys and comments say Move: for example `schedule.overdue.moveAll`, `moveOverdueTasks(to:)`. The glossary gains no terms, and there's no ADR: a single bulk save is easy to change later.
- "The Overdue Tasks" means the Incomplete ones in `Schedule.overdue`, which also lists Tasks completed from it on Today (ADR 0002). Give that subset a property on `Schedule` so the view model and the label read it the same way. Name it for what it is (for example `overdueIncomplete` or `overdueToMove`), never a broad one-word name (memory: specific type names).

### Domain

- **The order is a pure function.** Next to `TodoTask.order(afterMoving:to:in:)`, add an ordering that puts a list of Tasks, in the order given, at the top of a Day above that Day's Tasks, giving each its new Day and `sortIndex`. Test it in Domain.
- **One repository call.** `TodoTaskRepository` gains `move(ids: [UUID], toStartOf day: Date)` (or a similar name). It Moves the Tasks with those IDs, in that order, to the top of `day` in a single save, notifying once (ADR 0002: every write goes through the notifying save). IDs with no Task are skipped. The Days the Tasks leave keep their order.
- **The optimistic list** uses the same ordering through an `Array<TodoTask>` extension beside `movingTask(id:to:)` (for example `movingTasks(ids:toStartOf:)`), so the list moves at once and matches what the store will hold.
- **The move rule**: the chosen Day must pass `canBePlanned(today:)`, which both pickers already enforce. No new use case (`CODING_STANDARDS.md`'s use-case rule).

### App

- **The target.** `DayChoiceTarget` gains a case for the Overdue Tasks (for example `.overdueTasks`). `choose(_:for:)` handles it by reading the Overdue Tasks **at that moment**, moving them in `ScheduleTasks` at once, and saving through `TaskMoves` with one repository call. A failed save calls `dropUnsavedMoves()` and shows the error alert, as for one Task. `choose` returns `false` when there's nothing to Move.
- **The floating picker's presentation** names its target instead of a Task ID: `FloatingDayPickerPresentation` holds a `DayChoiceTarget`, and `highlightRow(of:)` and the listing's held IDs read its `taskID`. Opening it for Overdue builds `FloatingDayPickerState(today:day:)` with a Day before Today, which already opens on Today's month with nothing chosen.
- **The sheet** opens through `showSheetDayPicker(on:for:)` with the new target and a Day before Today, which opens it with nothing chosen. `SheetDayPickerState.newDay` then gives the chosen Day. `sheetDayPickerDidClose` has no Task to relist for this target.
- **Closing when empty.** `observeSchedule` closes a floating picker whose target is the Overdue Tasks once none are left, as it closes one whose Task is gone. The sheet closes the same way.
- **The header's frame.** `FloatingDayPickerOrigin` takes the header's frame and the tap point, in the same coordinates as a row's. The Overdue header reports them through the list controller, as a row's cell does. `FloatingDayPickerPlacement` is unchanged.
- **The header view.** `OverdueHeaderView` takes whether to show the label and its actions (tap, long press, highlighted). The list controller reconfigures the header when the label's visibility changes. Today, "the Overdue header never changes" (`ScheduleListController`), so it is no longer excluded from the header reconfiguration.
- **The long press** reuses the composer chip's gesture: a `LongPressGesture` of 0.35 s and 10 pt `exclusively(before:)` a `TapGesture`, with a medium impact haptic. Pull it into a shared helper (for example a `View` modifier or gesture in `Shared/`) that the chip and the label both use, keeping the chip's behaviour unchanged.
- **The announcement** is a plural catalog string with the count and `relativeNameOrShortDate(today:)`, posted once the save succeeds, alongside `Date+MoveAnnouncement.swift`.
- **Strings** (via `scripts/xcstrings.py set` / `set-plural`):
  - `schedule.overdue.moveAll`: "Move All" / "Перенести все".
  - Its hint: "Moves every Overdue Task to a Day" / "Переносить усі прострочені завдання на інший день".
  - The announcement, plural: en one "%lld task moved to %@", other "%lld tasks moved to %@"; uk one/few "%lld завдання перенесено на %@", many/other "%lld завдань перенесено на %@". Check the Ukrainian Day names read naturally after "на".
  - Reuse `task.chooseDay` for the VoiceOver action.
- **Folders** follow `CODING_STANDARDS.md`. The header's view stays in `Features/Schedule/List/Components/`, and the view-model code goes in a `ScheduleViewModel+…` file of its own if it doesn't fit the existing ones.

## Testing Decisions

Swift Testing; `today` passed explicitly; Days are GMT midnights.

- **Domain:**
  - **The ordering:** the moved Tasks come first on the Day, in the order given, above the Day's Incomplete, Complete and hidden Tasks; the Day's own Tasks keep their order; each moved Task takes the Day; moving to an empty Day.
  - **The Overdue Tasks property:** Incomplete Overdue Tasks only, oldest Day first, then position; Tasks completed from Overdue on Today are left out.
  - **`movingTasks(ids:toStartOf:)`:** matches the ordering, and the result stays in order of Day, then position.
- **Data:** the repository call Moves the Tasks in one save, in order, to the top of the Day; the Days they leave keep their order; unknown IDs are skipped; an open stream sends once.
- **App:** the shared long-press helper needs no test. No view-model, UI or snapshot tests, as before. The UI check (`docs/agents/ui-check.md`) on iOS 27 covers the label, both pickers and the Move.

## Out of Scope

- The widgets: they show the Tasks in their new places but get no Move All of their own.
- Moving only some of the Overdue Tasks.
- Undo.
- Any change to the single-Task pickers, dragging or the Move Up and Move Down actions.

## Further Notes

- Grilled on 2026-11-06. The user chose "Move All" over "Reschedule" as the label, so the screen uses the glossary word.
- Issues, in order: `issues/01` the bulk Move in Domain and Data, `02` the label and the floating Day picker, `03` the long press, the sheet and VoiceOver's "Choose Day".
