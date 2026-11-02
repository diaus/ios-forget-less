# 05: VoiceOver for the Day chip calendar

**What to build:** VoiceOver support for opening, paging and choosing in the calendar (spec stories 37–42).

- **The chip:** its default activation (a double-tap) toggles the calendar. Its adjustable action still steps one Day.
- **The calendar:**
  - a modal container (`.isModal`), so focus moves into it on open and stays there;
  - an escape action that closes only the calendar, while the composer's own escape still dismisses the composer when the calendar is closed.
- **The month header:**
  - a heading (`.isHeader`);
  - adjustable: increment pages to the next month, decrement to the previous one;
  - decrement on Today's month does nothing, with the rigid haptic.
- **Each Day:** the shared cell keeps the sheet's accessibility:
  - a button labelled with its full date;
  - its Incomplete Task count as its value;
  - dimmed before Today;
  - selected on the chip's Day.
- **Blank cells and padding rows** are hidden from VoiceOver.
- **The announcement:** while editing, the new Day is announced once the Move is saved (from ticket 02). Check that it isn't cut off by the focus moving back to the chip as the calendar closes.
- **New catalog keys,** if any (for example a hint on the chip), are added with `scripts/xcstrings.py` in `en` and `uk`.

**Blocked by:** 04: Fitting the calendar

**Status:** ready-for-agent

- [ ] The UI check on iOS 27, with the accessibility tree read back (`snapshot_ui`, `axe describe-ui`, or `lldb` for traits the tools don't report, as in Choose a Day's ticket 03), confirms:
  - the chip is adjustable and can be activated;
  - while the calendar is open, only its elements are in the tree;
  - the month header is an adjustable heading;
  - each Day's label, value and traits;
  - blank cells are absent.
- [ ] The escape gesture closes only the calendar, checked on the simulator or reported as skipped.
- [ ] The announcement after a Move gives the new Day, checked in the console or the accessibility notification log, or reported as skipped.
- [ ] `build_sim`, `test_sim` and `scripts/check.sh` pass.
