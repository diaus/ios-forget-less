# 04: Fitting the calendar

**What to build:** The calendar always fits the space above the chip, refitting live (spec stories 32–35).

- **Fitting is a pure function** in `Features/Composer/DayChipCalendar/` (for example `DayChipCalendarLayout`), tested in the app's tests.
  - Inputs: the height available above the chip, the measured heights of the header and the button row, the padding, and whether the keyboard is up.
  - Outputs: the row height, whether the buttons show, and whether the keyboard must go down.
  - It tries, in order:
    1. rows the sheet's height (about 50 pt) with the buttons;
    2. without the buttons;
    3. rows shrunk toward about 36 pt;
    4. with the keyboard down, steps 1–3 again in the larger space;
    5. rows that take all the height there is.
- **The view:**
  - It measures the header and the button row at the current Dynamic Type size, and the space from the top safe area to the chip.
  - It refits whenever any of these change, for example when switching to the emoji keyboard, rotating, or changing Dynamic Type.
  - The Day numbers shrink with the row (for example `minimumScaleFactor`).
  - Nothing scrolls vertically inside the calendar.
- **The keyboard:**
  - When the function says the keyboard must go down, the view drops the name field's focus and records it in the calendar's state.
  - Once down, the keyboard stays down until the calendar closes, however much room it frees.
  - Closing gives the name field focus again, unless the composer is closing too.

**Blocked by:** 03: Today, Tomorrow and the weekday after

**Status:** ready-for-agent

- [ ] Fitting tests: one per step, plus:
  - with the keyboard down, steps 1–3 apply again;
  - step 5's row height fills the space exactly.
- [ ] A state test: a calendar that hid the keyboard says so until it closes.
- [ ] The UI check on iOS 27 confirms:
  - a 6.9″ iPhone shows the full calendar with the buttons;
  - a 6.1″ iPhone hides the buttons;
  - the iPhone SE (or the smallest iOS 27 simulator) shrinks the rows, or hides the keyboard;
  - iPhone landscape hides the keyboard and fits;
  - switching to the emoji keyboard refits;
  - an iPad caps the width at about 400 pt;
  - the largest accessibility text size fits without scrolling;
  - closing a calendar that hid the keyboard brings it back, and dragging the composer down doesn't.
- [ ] `build_sim`, `test_sim` and `scripts/check.sh` pass.
