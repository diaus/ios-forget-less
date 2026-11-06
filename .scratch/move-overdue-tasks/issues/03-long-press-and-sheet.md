# 03: The long press, the sheet and VoiceOver's "Choose Day"

**What to build:** Spec stories 11–13, 22 (for the sheet) and 27: a long press on the label opens the Choose a Day sheet for the Overdue Tasks.

- Pull the composer Day chip's long press (0.35 s, 10 pt, `exclusively(before:)` a tap, medium impact haptic) into a shared helper, and use it on both the chip and the label. The chip behaves as before.
- The sheet opens through `showSheetDayPicker(on:for:)` with the Overdue Tasks target, with nothing chosen; Done Moves them via `choose(_:for:)`; closing relists nothing.
- The sheet closes once nothing is Overdue.
- A "Choose Day" accessibility action on the label (`task.chooseDay`) opens the sheet.

**Blocked by:** 02

**Status:** ready-for-agent

- [ ] `build_sim`, `test_sim` and `scripts/check.sh` pass.
- [ ] The UI check on iOS 27 confirms all of these:
  - a long press on the label opens the sheet with nothing chosen and Done disabled, and a short tap still opens the floating picker;
  - Done Moves every Overdue Task to the top of the chosen Day, and Cancel changes nothing;
  - the composer's Day chip still opens the sheet on a long press, steps on a swipe and opens its calendar on a tap;
  - VoiceOver's "Choose Day" action on the label opens the sheet.
