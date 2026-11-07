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

**Status:** ready-for-agent

- [ ] App tests: `FloatingDayPickerStateTests`, `SheetDayPickerStateTests` and the composer's tests, with past Days in and out of History.
- [ ] `build_sim`, `test_sim` and `scripts/check.sh` pass.
- [ ] The UI check on iOS 27 confirms all of these:
  - in History, a Task's floating picker opens on its past Day, and choosing an earlier Day Moves it there;
  - the sheet accepts a past Day;
  - "+" on a past Day adds a Task there, and it can be completed;
  - the composer's chip steps back past Today;
  - with History off, the pickers refuse past Days again;
  - a composer holding a past Day when History turns off still adds there.
