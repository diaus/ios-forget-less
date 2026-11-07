# 02: The History button and the History list

**What to build:** Spec stories 1–24, 31–32 and 36–39: the quick setting, the History list with its endless past, the jumps, and Moves onto past Days by dragging and Move Up/Down.

- `ScheduleViewModel` holds `showsHistory` (in memory, off at launch) and the History first Day. `ScheduleListing` carries them. Turning History on or off releases the Kept Tasks and resubscribes the observation with or without the first Day.
- The first Day starts about 60 Days before Today and moves back 60 when the list's first rows near the top. The list keeps the rows on screen still while a page lands above them.
- Turning History on scrolls, animated, so Yesterday's header is at the top. Turning it off scrolls, animated, to the top. Both are one-off requests carried out once the matching Schedule shows. Midnight jumps nowhere.
- `QuickSettingsView`:
  - The History button goes first: `clock.arrow.circlepath`, with the square filled in the primary colour and the glyph inverted when on. On iOS 26 and later the fill is primary-tinted interactive glass.
  - VoiceOver reads it as a `Toggle` labelled `schedule.history`.
  - Show Complete Tasks is disabled while History is on.
- Day headers read "Yesterday" (`day.yesterday`). The move announcement says it too.
- Strings via `scripts/xcstrings.py`: `schedule.history` "History" / "Історія", and `day.yesterday` "Yesterday" / "Вчора".

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] App tests: `ScheduleTasks` Moves onto a past Day in History; "Yesterday" in `DateDayFormattingTests`.
- [ ] `build_sim`, `test_sim` and `scripts/check.sh` pass.
- [ ] The UI check on iOS 27 confirms all of these:
  - the button is first and looks on and off as described, and Show Complete Tasks dims while History is on;
  - turning History on lists past Days with their Complete Tasks and no Overdue, and scrolls to Yesterday at the top;
  - scrolling up keeps loading further back, empty Days included, with no jump;
  - a Task dragged onto a past Day shows in Overdue once History is off, and turning History off scrolls to the top;
  - History is off after a relaunch;
  - VoiceOver reads the button as a switch.
