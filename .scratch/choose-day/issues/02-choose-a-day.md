# 02: Choose a Day from the swipe action

**What to build:** The calendar swipe action, the Day picker sheet, and the Move on Done (spec stories 1–29).

- **Swipe action:**
  - `calendar` on `.systemBlue` with no title, returned after Delete in `swipeActions(at:)` so Delete stays outermost.
  - Its image's accessibility label is a new catalog key, "Choose Day".
  - It shows whether Move Tasks is on or off.
- **State:**
  - The view model holds the Task being moved, the chosen Day and whether the sheet shows.
  - The choice rules are a value type in `Features/Schedule/DayPicker/`, like `ComposerState`, tested in the app's tests:
    - open on the Task's Day, or with nothing chosen for an Overdue Task;
    - refuse a Day before Today;
    - clear a chosen Day that a new Today leaves in the past;
    - give no Day to move to while nothing is chosen, or when the chosen Day is the Task's own Day.
- **Sheet:**
  - `ScheduleView` presents it with `.presentationDetents([.medium, .large])`, starting at medium.
  - The toolbar has Cancel and Done in the accent tint, with no title. Done is disabled while nothing is chosen. Its catalog key avoids the word "Done" in the symbol, which the glossary lint rule forbids (for example `dayPicker.confirm`).
  - Pinned at the top:
    - the weekday row, in `firstWeekday` order;
    - the summary line: the chosen Day ("Fri 6 Nov", with the year only outside the current year) and its Incomplete Task count ("1 task", "No tasks"), or "Choose a Day" while nothing is chosen.
  - Below them, a lazy vertical stack of about 60 months from the current month (from ticket 01). Each month has a header ("November", "January 2027") with the year only outside the current year.
  - Each Day:
    - before Today: dimmed and not tappable;
    - weekends: the same as other Days;
    - Today: its number in the accent colour;
    - chosen: a filled accent circle with a white number;
    - with Incomplete Tasks: a dot, grey or white on the chosen Day.
  - It opens scrolled so the chosen Day is centred, or Today while nothing is chosen.
- **Interaction:**
  - A tap chooses a Day, with a selection haptic. A tap on the chosen Day keeps it chosen.
  - Cancel, or swiping the sheet down, closes with no write.
  - If Today rolls over while the sheet is open, the sheet updates through the choice rules.
- **Done:**
  - With no Day to move to, Done only closes.
  - Otherwise the view model checks `canMove(_:toDay:)`, moves the Task at once to `destinationAtEnd(of:forTaskWithID:)`, and saves with `move(id:to:)`. A failed save puts back the observed Tasks and shows the error alert. The list doesn't scroll.
- **Kept listed:**
  - `rebuildSchedule` lists the sheet's Task while the sheet is open.
  - Closing the sheet gives a Complete Task a fresh grace period while Complete Tasks are hidden, as `dismissComposer` does.
- **Strings:**
  - The Task count needs plural variations: English one/other plus zero, and Ukrainian one/few/many/other plus zero.
  - Extend `scripts/xcstrings.py` to set plural variations, and make `check` accept them.
  - Reuse an existing "Cancel" key if there is one.

**Blocked by:** 01: The months and the Task counts

**Status:** ready-for-agent

- [ ] Choice-rule tests in `ForgetLessTests/Features/Schedule/DayPicker/` cover the rules listed under State.
- [ ] The UI check (`docs/agents/ui-check.md`) on iOS 27 confirms:
  - the calendar action sits inside Delete, is blue, and shows with Move Tasks off;
  - the sheet opens at medium, centred on the Task's Day, already chosen, and drags to large;
  - an Overdue Task opens with nothing chosen, "Choose a Day", and Done disabled;
  - Days before Today can't be chosen;
  - the summary line and dots match the Tasks, counting the Task being moved;
  - Done on another Day moves the Task to the end of that Day without scrolling the list;
  - an Overdue Task moved to Today leaves Overdue;
  - a Complete Task stays Complete;
  - Done on the Task's own Day changes nothing;
  - Cancel and swiping down change nothing;
  - Done on a Day after the 100-Day window lists that Day;
  - with Complete Tasks hidden, a just-completed Task stays listed while the sheet is open.
- [ ] Today rolling over while the sheet is open clears a chosen Day that is now past (`SIMCTL_CHILD_TZ`, as in the move-tasks check).
- [ ] The widget shows the moved Task in its new place (`docs/agents/ui-check.md`, "Lock Screen widget").
- [ ] Every new catalog key has `en` and `uk`, with the plural forms, added with `scripts/xcstrings.py`.
- [ ] `build_sim`, `test_sim` and `scripts/check.sh` pass.
