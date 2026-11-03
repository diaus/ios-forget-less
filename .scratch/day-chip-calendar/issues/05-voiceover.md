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
- **Days from the months either side** (ticket 06) read as any Day: their full date says which month they're in.
- **The ✕** reads as a "Close" button and closes only the calendar.
- **The announcement:** while editing, the new Day is announced once the Move is saved (from ticket 02). Check that it isn't cut off by the focus moving back to the chip as the calendar closes.
- **New catalog keys,** if any (for example a hint on the chip), are added with `scripts/xcstrings.py` in `en` and `uk`.

**Blocked by:** 04: Fitting the calendar

**Status:** resolved

- [x] The UI check on iOS 27, with the accessibility tree read back (`snapshot_ui`, `axe describe-ui`, or `lldb` for traits the tools don't report, as in Choose a Day's ticket 03), confirms:
  - the chip is adjustable and can be activated;
  - while the calendar is open, only its elements are in the tree;
  - the month header is an adjustable heading;
  - each Day's label, value and traits, a Day from another month included;
  - the ✕ is a button labelled "Close".
- [x] The escape gesture closes only the calendar, checked on the simulator or reported as skipped.
- [x] The announcement after a Move gives the new Day, checked in the console or the accessibility notification log, or reported as skipped.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.

## Comments

- The header's adjustable action pages through `DayChipCalendarState.page(by:)`. It refuses a month before Today's and returns whether it paged, and `DayChipCalendarStateTests` covers it. A refusal gives the swipe's rigid haptic.
- The chip gained the hint `composer.dayHint` ("Opens a calendar to choose a Day from.", "Відкриває календар, щоб вибрати день."), the button trait, and a default action that toggles the calendar.
- Focus moves. On open, VoiceOver focus goes to the shown month's header. After an adjust, it goes to the new month's header. When the calendar closes through the ✕, the escape, the backdrop or a chosen Day, it goes back to the chip. Closes that don't go through the calendar (typing, submitting, dismissing the composer) leave focus alone.
- The check ran on an iPhone 18 Pro, iOS 27.2. `snapshot_ui` and `axe describe-ui` list hidden and modal-covered elements too, and axe leaves `traits` empty. So the tree, traits and actions were read with lldb on the SwiftUI accessibility nodes:
  - With the calendar open, the hosting view's `accessibilityElements` hold only the modal node (`accessibilityViewIsModal`) and its elements.
  - The month header is `0x11040` (header, adjustable, static text). Increment paged November to December, decrement paged back, and a decrement on November reached the refused branch.
  - Days read as, for example, "Monday, 26 October 2026" on November's page and "Monday, 30 November 2026" on December's, with "No tasks" or "2 tasks" as the value. A past Day is `0x101` (button, not enabled), and the chip's Day is `0x9` (button, selected).
  - The ✕ is a button labelled "Close". The chip is `0x1001` (button, adjustable), and `accessibilityActivate` opened the calendar.
  - `accessibilityPerformEscape` on the modal node closed only the calendar, with the composer and keyboard still up. With the calendar closed, the escape walked up from the chip and dismissed the composer.
  - Editing an Overdue Task and choosing 10 Nov posted `UIAccessibilityPostNotification` 1008 with "10 Nov" at high announcement priority.
- Not observable without VoiceOver, which the simulator lacks:
  - Whether each focus move lands. The headers of the pages either side are already in the tree, so the focus request has an element to land on.
  - Whether the chip's readout cuts the announcement off. The Move usually saves within the calendar's 0.15 s close, so the announcement comes first. It's high priority, which other speech can't interrupt, and the chip's value repeats the new Day anyway.
- Review notes left as they are: the chip's VoiceOver focus is a binding passed like `isNameFocused`, not through the view model as `composerOpenerFocus` is. The month view takes both `month` and `offset`. The adjustable-action switch has the same shape as the chip's.
