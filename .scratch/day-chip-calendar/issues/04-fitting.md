# 04: Fitting the calendar

**What to build:** The calendar always fits the space from the top safe area to the composer's bottom, refitting live (spec stories 32–35). It has 5 week rows (ticket 06), and its ✕ sits on the header's line, adding no height.

- **Fitting is a pure function** in `Features/Composer/DayChipCalendar/` (for example `DayChipCalendarLayout`), tested in the app's tests.
  - Inputs: the height available from the top safe area to the composer's bottom, the measured heights of the header and the button row, the padding, and whether the keyboard is up.
  - Outputs: the row height, whether the buttons show, and whether the keyboard must go down.
  - It tries, in order:
    1. rows the sheet's height (about 50 pt) with the buttons;
    2. without the buttons;
    3. rows shrunk toward about 36 pt;
    4. with the keyboard down, steps 1–3 again in the larger space;
    5. rows that take all the height there is.
- **The view:**
  - It measures the header and the button row at the current Dynamic Type size, and the space from the top safe area to the composer's bottom.
  - It refits whenever any of these change, for example when switching to the emoji keyboard, rotating, or changing Dynamic Type.
  - The Day numbers shrink with the row (for example `minimumScaleFactor`).
  - Nothing scrolls vertically inside the calendar.
- **The keyboard:**
  - When the function says the keyboard must go down, the view drops the name field's focus and records it in the calendar's state.
  - Once down, the keyboard stays down until the calendar closes, however much room it frees.
  - Closing gives the name field focus again, unless the composer is closing too.

**Blocked by:** 03: Today, Tomorrow and the weekday after

**Status:** resolved

- [x] Fitting tests: one per step, plus:
  - with the keyboard down, steps 1–3 apply again;
  - step 5's row height fills the space exactly.
- [x] A state test: a calendar that hid the keyboard says so until it closes.
- [ ] The UI check on iOS 27 confirms:
  - a 6.9″ iPhone shows the full calendar with the buttons;
  - a 6.1″ iPhone fits by the first step that works for its height (expected: the full calendar with the buttons, now that the calendar covers the composer and has 5 rows), recorded in Comments;
  - the iPhone SE (or the smallest iOS 27 simulator) hides the buttons, shrinks the rows, or hides the keyboard, recorded in Comments;
  - iPhone landscape hides the keyboard and fits;
  - switching to the emoji keyboard refits;
  - an iPad caps the width at about 400 pt;
  - the largest accessibility text size fits without scrolling;
  - closing a calendar that hid the keyboard brings it back, and dragging the composer down doesn't.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.

## Comments

- The UI check box stays unticked for one item: "iPhone landscape hides the keyboard and fits". This simulator setup can't rotate: Simulator.app isn't installed, and neither axe nor `simctl` has a rotate command. Every other item was confirmed on iOS 27.2.
- 6.9″ (iPhone 18 Pro Max): the full calendar, with the buttons, fits by step 1 with the keyboard up, on the emoji keyboard too.
- 6.1″ (iPhone 17e): the full calendar, with the buttons, fits by step 1 at the default text size, as expected. It's also the smallest iOS 27 simulator, since there's no SE, so the other steps were reached through text size:
  - AX Large to AX XXXL: the buttons hide and the rows stay 50 pt (step 2).
  - AX XXXL on the emoji keyboard: the rows shrink to 47 pt (step 3), so switching keyboards refits.
  - At the largest text size, every Day shows and nothing scrolls.
- No real screen here gets below 36 pt rows without landscape. So the keyboard path was exercised by raising the floor for a run, then putting it back to 36:
  - at 49 pt on the 17e: the emoji keyboard pushed the rows under the floor, the keyboard went down, and the calendar refit with full rows and the buttons in the space it freed;
  - the ✕ and a tap on the backdrop each brought the keyboard back;
  - at 51 pt on the Pro Max: choosing a Day brought it back with the chip on that Day;
  - dragging the composer down past the card closed both, and the keyboard stayed down.
- iPad Pro 11″: the card's width stops at 400 pt.
- At AX XL, the weekday names wrapped onto two lines. The month name and the weekday names now stay on one line and scale down. Each weekday name scales on its own, so at the largest sizes they differ a little in size.
- At AX sizes the button labels truncate ("Tomor…"). That's ticket 03's look, left as is.
- The calendar keeps 8 pt clear under the top safe area, so it doesn't touch the status bar.
- The keyboard goes down through `UIApplication.resignFocus()` (in Utils), and comes back through the name field's focus binding when the calendar closes. "Keyboard up" is `!hasHiddenKeyboard`. With a hardware keyboard, step 4 takes focus away without freeing any space, and gives it back on close.
- After a choice, the keyboard comes back with the close, 0.15 s after the tap. Focusing at the tap would refit the calendar while it shows the choice. CODING_STANDARDS' rule against focusing after a delay was dropped: it guarded only the composer's opening, which its own code comments explain.
