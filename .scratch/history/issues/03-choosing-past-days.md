# 03: Choosing past Days in the pickers, the composer and "+"

**What to build:** Spec stories 25–30, 33–35: every way of choosing a Day accepts past Days while History is on.

- `FloatingDayPickerState` and `SheetDayPickerState` take whether History is on. In History:
  - every Day can be chosen and is undimmed;
  - a past Day opens chosen, on its own month;
  - the floating picker pages back without limit.

  Outside History they're unchanged. `PickerDayView` reads the same rule. The Today, Tomorrow and weekday buttons are unchanged.
- `ComposerSession` and the Day chip picker step and choose past Days in History. A past Day held when History turns off stays, and saving adds there.
- The "+" on a past Day's header opens the composer on that Day. The red floating "+" still adds to Today.
- Picker or sheet Moves onto past Days announce "Yesterday" or the short date.

**Blocked by:** 02

**Status:** resolved

- [x] App tests: `FloatingDayPickerStateTests`, `SheetDayPickerStateTests` and the composer's tests, with past Days in and out of History.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.
- [x] The UI check on iOS 27 confirms all of these:
  - in History, a Task's floating picker opens on its past Day, and choosing an earlier Day Moves it there;
  - the sheet accepts a past Day;
  - "+" on a past Day adds a Task there, and it can be completed;
  - the composer's chip steps back past Today;
  - with History off, the pickers refuse past Days again;
  - a composer holding a past Day when History turns off still adds there.

## Comments

- **2026-11-08, the composer's tests:** the composer steps by Domain's `nextDayToChoose` and `previousDayToChoose(today:showsHistory:)`, which replace `nextDayToPlan` and `previousDayToPlan`. `DateDayTests` covers them in and out of History. `ComposerSession` is untested, as view models are, so the wiring from `ScheduleViewModel.showsHistory` and story 33 are covered by the UI check only.
- **2026-11-08, a picker keeps the mode it opened in:** both picker states take `showsHistory` when they open and keep it. History can't change while one is open:
  - the floating picker's backdrop takes every touch outside it, and it's modal to VoiceOver;
  - the sheet is modal;
  - the composer's scrim takes every touch.

  Only VoiceOver reaches the History switch while the composer is up. `ComposerSession.showsHistory` follows the view model's at once.
- **2026-11-08, how far back the sheet reaches:** in History the sheet offers 60 months before Today's month, or from the month of the Day it opened on when that's earlier, then the usual 60 from Today's on. Only the floating picker pages back without limit (story 25). `DayPickerCalendar` takes a first month offset for this.
- **2026-11-08, Overdue's pickers:** they open with whether History is on, like the others. Overdue isn't listed in History, so they open only outside it. Its move rule (`canMoveOverdueTasks`) refuses past Days whatever the picker offers.
- **2026-11-08, the UI check:** confirmed on iOS 27 with axe and screenshots, as `snapshot_ui` timed out. A composer holding a past Day when History turns off was checked under the debugger. With the composer up, only VoiceOver can reach the History switch, and the simulator has no VoiceOver. So the view model's `showsHistory` was set from a breakpoint in `ComposerSession`. The composer kept 6 Nov, and saving added the Task there, shown in Overdue.
