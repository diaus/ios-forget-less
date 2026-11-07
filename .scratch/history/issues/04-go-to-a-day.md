# 04: Go to a Day

**What to build:** Spec stories 8, 38 and 40–51, and "Go to a Day" under Implementation Decisions. While History is on, a calendar button replaces Show Complete Tasks. It opens the sheet Day picker, and Done scrolls the list to the chosen Day.

- `QuickSettingsView`: while History is on, the second square is a `calendar.badge.clock` button. It's never filled, labelled `schedule.goToDay` ("Go to a Day" / "Перейти до дня") and read as a button. It swaps with Show Complete Tasks, animated with History's toggle. Show Complete Tasks loses its `.disabled(showsHistory)`.
- The sheet Day picker opens for a new `DayChoiceTarget` on the Day at the top of the screen, which the list controller keeps the view model told of. Any Day can be chosen, across the months the sheet offers in History. The summary line shows only the weekday and date, with no Task count.
- Done on a new Day asks the list to go there and moves no Task. Done on the Day it opened on, and Cancel, leave the list where it is.
- A Day before the History first Day moves the first Day to 60 Days before it. The list lands once the shown Schedule lists back to it, never earlier, since the scroller drops a request whose section is missing.
- It lands without animation, with the landing Day's header at the top, or as near as the end of the list allows. The landing Day is the chosen Day if listed, else the closest listed Day before it, for an empty Day after the 100 listed from Today.
- VoiceOver focus moves to the landing Day's header.
- Midnight scrolls nothing, and the open sheet keeps its chosen Day.

**Blocked by:** 03

**Status:** ready-for-agent

Progress (2026-11-08): implemented, and the UI check on iOS 27 passes. The code review ran, and its findings are fixed. VoiceOver focus now moves to the landing Day's header only once the sheet has closed, since UIKit hands focus back to the Go to a Day button as it closes. That move is unconfirmed: the simulator has no VoiceOver, so check it on a device.

- [x] Domain tests (`ScheduleTests+History`): the landing Day rule for a listed past Day, Today, a later Day, and an empty Day after the window.
- [x] App tests (`SheetDayPickerStateTests`): opened to go to a Day in History, past and later Days can be chosen, and Done on the Day it opened on gives no Day.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.
- [x] The UI check on iOS 27 confirms all of these:
  - turning History on swaps Show Complete Tasks for the calendar button, animated, and turning it off swaps it back;
  - the sheet opens on the Day at the top of the screen, and Done unchanged leaves the list still;
  - choosing a loaded past Day lands its header at the top, instantly;
  - choosing a Day months back loads it and lands on it, and scrolling up from there keeps loading;
  - choosing a later Day within the 100 lands on it, and an empty Day beyond them lands on the closest listed Day before it;
  - the summary line shows no Task count;
  - axe reads the button as "Go to a Day".
