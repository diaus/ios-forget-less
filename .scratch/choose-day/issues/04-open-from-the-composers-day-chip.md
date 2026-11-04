# 04: Open the Choose a Day sheet from the composer's Day chip

**What to build:** a long press on the composer's Day chip opens the Choose a Day sheet, so the user can see several months at once (spec stories 34–41). A tap still opens the Day chip calendar, and a sideways swipe still steps the Day.

- **The gesture.** The chip gains a long press next to its tap (`vm.toggleDayChipCalendar`) and its swipe (`simultaneousGesture(dayStepSwipe)`):
  - it's recognised after 0.35 s, with a `.impact(weight: .medium)` haptic as it's recognised;
  - a finger that moves more than about 10 pt first cancels it (`maximumDistance`), and the swipe steps as now;
  - once it's recognised, the sheet opens and the rest of that drag neither steps the Day nor dismisses the composer;
  - a tap shorter than 0.35 s still opens the calendar, with no delay added to it. Check this on the simulator: tap and long press on one view can make the tap wait.
- **The sheet's state opens on a Day, not a Task.** `DayPickerState` now takes a `TodoTask`. It opens instead on a Day (the composer's Day, or the Task's), with the same rules: nothing chosen when that Day is before Today, Days before Today refused, and midnight clearing a chosen Day that turns past. The Day to move to is `nil` while nothing is chosen, or when the chosen Day is the Day it opened on.
  - The view model records what opened the sheet: a Task's row (its ID, which `rebuildSchedule` keeps listed as now) or the composer (whose edited Task is already kept listed). For example, an enum beside the state. Never a broad one-word type.
- **Done from the composer** goes through `changeComposerDay(to:onSaved: dayAnnouncement(day))`, the call the Day chip calendar's choose and `stepComposerDay` already share:
  - adding: the chip is set to the chosen Day, so the next Tasks added go there, and nothing is saved;
  - editing: the Task Moves to the end of that Day and saves at once, VoiceOver announces the new Day once it's saved, and a failed save puts the chip and the Task back and shows the error alert;
  - Done on the Day the sheet opened on does nothing;
  - either way, it counts as a step (`hasSteppedDay`), so dismissing the composer brings that Day into view.
- **Cancel or a swipe down** changes nothing.
- **Keyboard and focus.**
  - Opening the sheet drops the name field's focus, which takes the keyboard down. Don't rely on the sheet doing it.
  - The composer stays open under the sheet, with what's typed.
  - When the sheet closes, however it closed, the name field gets focus back. VoiceOver focus goes back to the chip, as when the Day chip calendar closes.
- **The sheet is unchanged otherwise:**
  - it opens at medium height, centred on the chosen Day;
  - its summary counts are the stored Tasks' (an edited Task on its stored Day, a Task being added not at all).
- **VoiceOver.** The chip gains a custom action, "Choose Day" (the existing `task.chooseDay` key), that opens the sheet. Its default action still toggles the calendar, and its adjustable action still steps.
- **Folders.** No new folder. The sheet stays in `Features/DayPicker/`, the chip in `Features/Composer/`.

**Blocked by:** none (01–03 are resolved).

- [x] **The state's tests** (prior art: `DayPickerStateTests`), rewritten for opening on a Day:
  - it opens on that Day, already chosen;
  - it opens with nothing chosen when that Day is before Today;
  - there's no Day to move to while nothing is chosen, or when the chosen Day is the Day it opened on;
  - the existing refusal and midnight tests still pass.
- [x] **The composer's tests:** choosing a Day from the sheet sets `hasSteppedDay`, so `revealsDayOnDismiss` holds, as after a step. This may already be covered by `changeComposerDay`'s tests.
- [x] **The UI check on iOS 27** (`docs/agents/ui-check.md`):
  - a tap opens the calendar, a long press opens the sheet, and a swipe steps;
  - Done while adding sets the chip;
  - Done while editing Moves the Task and saves;
  - Cancel changes nothing;
  - the keyboard comes back after each close;
  - "Choose Day" is among the chip's accessibility actions (`snapshot_ui`).
  - The haptic can't be felt on the simulator; the sheet opening on a held press shows the press is recognised then.
- [x] The swipe action on a Task's row still opens the sheet, and Done there still Moves the Task.
- [x] Any new catalog key has `en` and `uk`, added with `scripts/xcstrings.py`. None is expected.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.
