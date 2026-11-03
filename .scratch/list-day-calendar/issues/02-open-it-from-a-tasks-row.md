# 02: Open the floating Day calendar from a Task's row

**What to build:** Spec stories 1–19.

- The row's halves: left edits, right opens the card; hidden from VoiceOver as the name is.
- `TaskDayCalendar` in the view model: open, choose (the Move), close (grace period, rebuild), midnight, closing when the Task is gone.
- `TaskDayCalendarPlacement`, a pure function with tests.
- The overlay in `ScheduleView`, with its backdrop, the row highlight, and the transition from the tap point.

**Blocked by:** 01

**Status:** resolved

- [x] Placement tests.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.
- [x] The UI check on iOS 27 (iPhone 18 Pro) confirms all of these:
  - the left half edits;
  - the right half, its top margin and an Overdue Day open the card;
  - it opens below a row near the top, above one near the bottom, and on the side with more room, with the buttons hidden, when it fits neither;
  - choosing a Day (a Day cell, and the Tomorrow button) Moves the Task to it and closes the card, with the list staying put;
  - a tap outside, on another row, only closes the card;
  - the ✕ closes it;
  - a tap on a row whose swipe actions are open only closes them.

## Comments

- The row's margins above and below moved into the row as padding (`.margins(.vertical, 0)`), so its full height takes the tap. Rows keep the same height.
- The list's frame from `onGeometryChange` is already between the bars, though its safe-area insets still name them, so it's used as is.
- The card's side is chosen from its measured full height. Until the first measurement it uses a 400 pt guess, so on the first opening after launch, or after a text-size change, a row whose space is within a few points of the threshold can open on the other side.
- The halves split at the middle of the name and Day. The left half also gets the circle's 10 pt padding, so the right half is about 5 pt narrower.
- Highlight colour: the asset `TaskRowHighlight` (systemGray4's values).
- Not checked: Move Tasks on (the handle is a cell accessory outside the row's content, so the split ends before it), a Complete Task while Complete Tasks are hidden, and midnight. All reuse the Day picker's and the chip calendar's code paths.
