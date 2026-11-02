# 06: Five weeks, and the card over the composer

**What to build:** The calendar shows every month in 5 week rows filled with the Days of the months either side, sits over the composer with its bottom in line with the composer's, and closes from a ✕ in its corner (spec stories 5, 7–9, 14–16, 22 and 40's cell).

- **Domain: a 5-week grid.**
  - A month gains a grid of a given number of weeks in which every cell is a Day (for example `DayPickerCalendar.Month.weeks(count:) -> [[Date]]`).
  - It starts on the first Day of the week that holds the month's 1st and runs on consecutive Days, so the cells before the 1st are the previous month's last Days and those after the last Day are the next month's first.
  - The existing `weeks` (`[[Date?]]`, 4 to 6 rows, `nil` outside the month) and `week(containing:)` stay as they are for the Choose a Day sheet.
  - Any calendar arithmetic it needs stays in Domain's `Date` Day extensions.
- **The month view** draws `weeks(count: 5)`: no blank cells and no padding rows. A month that runs into a 6th week loses that row's Days (at most 2); they open the next month's first row.
- **The shared Day cell** learns whether its Day is in the month shown. Its number's colour, in order:
  1. `.tertiary` when it can't be chosen (a Day before Today, from any month);
  2. white when chosen;
  3. the accent for Today;
  4. a new colour asset `DayPickerOtherMonthDay` (`#0068A8` light, `#64D2FF` dark, the values of `DayChipWeekday` under its own name) for a Day from another month;
  5. `.primary` otherwise.

  The chosen circle, Today's weight and the dot don't change. The Choose a Day sheet always passes "in the month" and looks as before.
- **Choosing a Day from another month** is the same as any Day: it chooses and closes, with no paging. The chip's Day is drawn chosen wherever it shows.
- **Placement:**
  - The calendar's bottom is in line with the composer's bottom and its leading edge with the composer's, so on iPhone it covers the composer. Its width stays `min(composer width, 400 pt)`.
  - It's placed from the composer's frame (`DayChipCalendarAnchors.composer`). The chip's frame is still the transition's origin: it grows from the chip (scale and fade, anchored bottom-leading) and shrinks back into it.
  - Until ticket 04, the rows stay the sheet's full height.
- **The ✕:**
  - At the card's top-trailing corner, on the month name's line, outside the paging months so it stays put while they page.
  - It closes only the calendar; the keyboard stays up and the name field keeps focus.
  - iOS 26+: `Button(role: .close)`. iOS 18: an `xmark` in a small circle on `.fill.tertiary`, labelled "Close". Add a catalog key with `scripts/xcstrings.py` (`en` and `uk`) only if the system's label can't be reused.
- **Unchanged:** typing closes the calendar; submitting closes it, then submits; a tap outside closes only it; a downward drag starting over any part of the composer that shows past the card dismisses both.

**Blocked by:** 02: The Day chip calendar

**Status:** resolved

- [x] Domain tests in `DayPickerCalendarTests`:
  - a 5-week grid starts on the first Day of the week holding the 1st and runs on consecutive Days;
  - a month spanning 6 weeks (for example March 2026 with a Monday start) loses its last row's Days, and the next month's grid opens with them;
  - a February spanning 4 weeks (for example February 2027 with a Monday start) gets March's first week as its 5th row;
  - a Sunday start gives the same grid shifted to Sundays;
  - the existing `weeks` tests still pass unchanged.
- [ ] The UI check (`docs/agents/ui-check.md`) on iOS 27, on a 6.9″ iPhone, in light and dark mode, confirms:
  - every month shows 5 rows, and paging doesn't change the calendar's height;
  - a month's 6th-week Days show in the next month's first row;
  - Days from the months either side are blue (dark blue in light mode, light blue in dark mode), and past ones look like any other past Day;
  - a tap on a Day from another month chooses it and closes, while adding and while editing;
  - Today shown in another month's row keeps its accent number, and the chip's Day shows chosen in both months it appears in;
  - the calendar covers the composer, its bottom in line with the composer's, and grows from and shrinks into the chip;
  - the ✕ closes only the calendar, with the keyboard still up;
  - the Choose a Day sheet looks and works as before.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.

## Comments

- The UI check box stays unticked for one item: "Today shown in another month's row keeps its accent number". Today was 2 Nov, and Today only shows in another month's row when it's one of its month's last Days (2 Nov never shows on a page from November on). A time zone moves Today by a day at most, so the check couldn't be set up. The cell tests Today before the other-month colour, as listed above. Every other item was confirmed on an iPhone 18 Pro Max, iOS 27.2, in light and dark mode. The grow and shrink were confirmed from frames of a screen recording.
- Outside a toolbar, iOS 27 draws `Button(role: .close)` with its title "Close" in the tint. The ✕ keeps the role with `.labelStyle(.iconOnly)`, on `.buttonStyle(.glass)` in a circle, so it differs a little from iOS 18's `.fill.tertiary` circle.
- iOS 18 has no close role to take a label from, so the catalog gained `dayChipCalendar.close` ("Close", "Закрити").
- The scale transition's anchor is now the chip's bottom-leading corner rather than the card's, which is where the card's corner used to sit when it opened above the chip.
- Open question for the spec: a chip on a lost 6th-week Day (for example 30 Nov 2026 with a Monday start) opens the calendar on its own month, where that Day isn't drawn. It shows chosen on the next month's page.
- `weeks(count:)` shares its base name with `weeks`, as the ticket suggested. A review noted the two hold different cells (`nil` against the months either side's Days); rename one if that reads badly.
