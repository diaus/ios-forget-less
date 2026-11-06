# 02: The Move All label and the floating Day picker

**What to build:** Spec stories 1–10, 14–26 and 28: the label in the Overdue header, a tap opening the floating Day picker by the header, and the Move.

- `DayChoiceTarget` gains the Overdue Tasks case; `choose(_:for:)` Moves the Tasks Overdue at that moment, at once in `ScheduleTasks`, saved through `TaskMoves` in one call, with `dropUnsavedMoves()` and the error alert on failure.
- `FloatingDayPickerPresentation` holds a `DayChoiceTarget` instead of a Task ID; the row highlight and the listing's held IDs read its `taskID`.
- `OverdueHeaderView` shows the label (accent tint, `.subheadline` regular, trailing) while there are Overdue Tasks, highlighted while touched or while its picker is open; the list controller reports its frame and the tap point, and reconfigures the header when the label appears or goes.
- `observeSchedule` closes the picker once nothing is Overdue.
- VoiceOver: a button labelled "Move All" with its hint; the plural announcement once saved.
- Strings via `scripts/xcstrings.py`.

**Blocked by:** 01

**Status:** ready-for-agent

- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.
- [x] The UI check on iOS 27 confirms all of these:
  - the label shows with an Incomplete Overdue Task, with Move Tasks on and off, and not when Overdue holds only Tasks completed on Today;
  - a tap opens the picker by the header, on Today's month with nothing chosen;
  - choosing a Day (a Day cell, and the Tomorrow button) Moves every Overdue Task to the top of it in Overdue's order, leaves the Complete ones in Overdue, and closes the card, with the list staying put;
  - a tap outside, and the ✕, only close the card;
  - VoiceOver reads the label as a button and announces the count and Day after the Move.
