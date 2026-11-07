# 02: The History button and the History list

**What to build:** Spec stories 1–24, 31–32 and 36–39: the quick setting, the History list with its endless past, the jumps, and Moves onto past Days by dragging and Move Up/Down.

- `ScheduleViewModel` holds `showsHistory` (in memory, off at launch) and the History first Day. `ScheduleListing` carries them. Turning History on or off releases the Kept Tasks and resubscribes the observation with or without the first Day.
- The first Day starts about 60 Days before Today and moves back 60 when the list's first rows near the top. The list keeps the rows on screen still while a page lands above them.
- Turning History on scrolls, without animation, so Yesterday's header is at the top. Turning it off scrolls, without animation, to the top. Both are one-off requests carried out once the matching Schedule shows. Midnight jumps nowhere.
- `QuickSettingsView`:
  - The History button goes first: `clock.arrow.circlepath`, with the square filled in the primary colour and the glyph inverted when on. On iOS 26 and later the fill is primary-tinted interactive glass.
  - VoiceOver reads it as a `Toggle` labelled `schedule.history`.
  - Show Complete Tasks is disabled while History is on.
- Day headers read "Yesterday" (`day.yesterday`). The move announcement says it too.
- Strings via `scripts/xcstrings.py`: `schedule.history` "History" / "Історія", and `day.yesterday` "Yesterday" / "Вчора".

**Blocked by:** 01

**Status:** resolved

- [x] App tests: `ScheduleTasks` Moves onto a past Day in History; "Yesterday" in `DateDayFormattingTests`.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.
- [x] The UI check on iOS 27 confirms all of these:
  - the button is first and looks on and off as described, and Show Complete Tasks dims while History is on;
  - turning History on lists past Days with their Complete Tasks and no Overdue, and scrolls to Yesterday at the top;
  - scrolling up keeps loading further back, empty Days included, with no jump;
  - a Task dragged onto a past Day shows in Overdue once History is off, and turning History off scrolls to the top;
  - History is off after a relaunch;
  - VoiceOver reads the button as a switch.

## Comments

- **2026-11-07, where the first Day travels:** not through `ScheduleListing`. `ScheduleTasks.observe(_:historyFirstDay:)` takes the first Day the observed Tasks were fetched from, and the Schedule lists History from that one. The view model's `historyFirstDay` is the one asked for, and it changes before its Tasks arrive. With the listing carrying it, turning History on would list 60 empty Days before Today until the fetch landed. `Schedule` exposes `historyFirstDay` in place of its private `showsHistory`.
- **2026-11-07, holding still:** the list holds the first section on screen still when the Schedule's `historyFirstDay` changes: a page landing, or History turning on or off. A jump that follows then starts from where the user was. Launch and midnight outside History behave as before, so after a midnight outside History, rows can still shift as Overdue gains the old Today's Tasks above them.
- **2026-11-07, the jumps:** a jump ends off its target when rows on the way are laid out at estimated heights. Once its animation ends, it scrolls again, at most three times, until the target is reached. A drag cancels it. Loading further back runs on any scroll near the top, VoiceOver's included, except while a jump is on its way.
- **2026-11-07, instant jumps:** the animated jumps weren't smooth, so both jumps are now instant. A jump can still land off its target when the Days where it lands are laid out at estimated heights, so it scrolls again straight away, at most three times, until the target is reached. With nothing in flight, there's no jump for a drag to cancel, and loading further back runs on any scroll near the top.
- **2026-11-07, grace periods:** a Task completed while the list shows History gets none, since History lists Complete Tasks. So with Complete Tasks hidden, it's gone as soon as History is off (story 10).
- **2026-11-07, "Yesterday" beyond the headers:** `relativeName` now names Yesterday, so it also reads "Yesterday" in Move announcements and on a Day chip, such as the composer's when editing a Task from Yesterday.
