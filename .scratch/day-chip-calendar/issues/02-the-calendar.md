# 02: The Day chip calendar

**What to build:** Tapping the Day chip opens a floating month above it. Months page sideways, a tap on a Day chooses it, and the calendar closes on any touch outside it (spec stories 1–28 and 36). The calendar shows no buttons yet, and every row is the sheet's full height. Fitting is ticket 04.

- **The shared Day cell:**
  - `DayPickerDayView` takes its state as parameters (chosen, can be chosen, Today, the Incomplete Task count, an action) instead of reading `vm.dayPicker`.
  - It moves to a shared place both calendars use, for example `Shared/Views/`, and takes its size from its caller.
  - The Choose a Day sheet looks and works as before.
- **The state:** a value type in `Features/Composer/DayChipCalendar/` (for example `DayChipCalendarState`), tested in the app's tests. It holds Today, the chip's Day and the month shown, as an offset from Today's month. Its rules:
  - it opens on the chip's Day's month, or on Today's month when the chip's Day is before Today;
  - the chip's Day is the chosen Day only when it can be planned;
  - a Day before Today can't be chosen;
  - it can't page before offset 0;
  - a new Today moves offset 0 to its month and moves a month shown before it forward.
- **The view model:**
  - It owns the calendar's state next to `composer`, and `dismissComposer` ends it.
  - Choosing a Day goes through one call shared with `stepComposerDay`:
    - while adding, `composer.step(to:)`;
    - while editing, the step's checked, immediate Move to the end of the Day, rolled back on failure, with `dayAnnouncement` once saved;
    - on the chip's own Day, it only closes.
- **The chip:** a tap toggles the calendar. The sideways swipe still steps while the calendar is closed.
- **The calendar view:**
  - `ScheduleView` draws it in an overlay above `ComposerView`, placed from the chip's frame through an anchor preference.
  - Its bottom edge sits right above the chip and its leading edge in line with the composer's, overlapping the name field. It's as wide as the composer, up to about 400 pt.
  - It uses the composer's background (`.background.secondary`, corner radius 20) with a soft shadow, and grows from the chip on open: scale and fade, anchored at bottom-leading. Closing reverses it.
  - Its header holds the month's name (`monthName(today:)`) and the weekday row (from ticket 01).
  - It always shows 6 week rows, padding shorter months with empty rows.
- **Paging:**
  - A horizontal `ScrollView` with `.scrollTargetBehavior(.paging)` over a lazy row of months identified by offset.
  - It starts at 0 and grows forward in chunks near its end, as `TinyReminder/Calendar/CalendarPagerView.swift` does, without its backward growth.
  - It opens on the state's month with no animation.
  - At offset 0 the scroll view rubber-bands. A swipe that tries to go before it gives the chip's `.impact(flexibility: .rigid, intensity: 0.5)` haptic, once per swipe.
- **Choosing:**
  - A tap on a Day gives a selection haptic and draws that Day chosen at once. The chip's Day changes, and the Move starts, at the tap.
  - The calendar closes about 0.15 s later, and a second tap in that window is ignored.
- **Closing:**
  - While the calendar is open, a clear layer under it and over everything else takes every touch. A tap closes only the calendar. A mostly-down drag that starts over the composer dismisses the composer and the calendar, as `ComposerView.dismissDrag` does.
  - A touch on the chip, a swipe included, only closes the calendar.
  - A change to `composer.taskName` closes the calendar.
  - Submitting closes it before `submitComposer()`.
  - The keyboard stays up throughout.
- **Kept listed:** the composer already lists its edited Task, so nothing new is needed.

**Blocked by:** 01: A month at an offset

**Status:** ready-for-agent

- [ ] State tests in `ForgetLessTests/Features/Composer/DayChipCalendar/` cover the rules listed under State.
- [ ] A `ComposerStateTests` test: choosing a Day sets `hasSteppedDay`, so `revealsDayOnDismiss` holds as after a step.
- [ ] The UI check (`docs/agents/ui-check.md`) on iOS 27, on a 6.9″ iPhone so the full calendar fits, confirms:
  - a tap on the chip opens the calendar on the chip's Day's month, with that Day chosen, and the keyboard stays up;
  - an Overdue Task being edited opens on Today's month with nothing chosen;
  - the swipe still steps the chip while the calendar is closed;
  - paging forward and back, months past five years ahead, and the bounce at Today's month;
  - while adding, a tapped Day becomes the chip's Day and the next Task added lands there;
  - while editing, a tapped Day Moves the Task to its end at once, and closing the composer brings that Day into view;
  - a Complete Task being edited stays Complete;
  - a tap on the chip's own Day changes nothing;
  - taps on the backdrop, the list, the name field, ▶ and the chip each close only the calendar;
  - typing closes it;
  - dragging the composer down closes both;
  - the Choose a Day sheet still looks and works as before.
- [ ] Today rolling over while the calendar is open dims the new past Day (`SIMCTL_CHILD_TZ` at boot, or a real midnight).
- [ ] `build_sim`, `test_sim` and `scripts/check.sh` pass.
