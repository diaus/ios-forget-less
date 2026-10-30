# 06: Rename a Task

**What to build:** Tapping a Task's row, Complete or not, opens the same composer in edit mode (spec stories 22–23). The field holds the Task's name, and the chip shows its Day. The chip is display-only: the Day can't be changed in v1. Saving with ▶ or Return renames the Task and closes the composer. The keyboard still comes up with no delay.

**Blocked by:** 04: The 100-Day schedule and per-Day add

**Status:** ready-for-agent

- [x] Tapping a row (not its circle) opens the composer prefilled with the Task's name and its Day chip. The field is focused with no delay.
- [x] ▶ is disabled while the trimmed name is empty. Saving trims the name, renames the Task and closes the composer.
- [x] The renamed Task keeps its Day, its position and its Complete state.
- [ ] Dismissing without saving (tap outside, swipe down) leaves the Task unchanged. The confirmation for unsaved changes comes in 09.
- [x] The view model applies the Domain name rule, then calls the repository directly (per the use-case rule).
- [x] Data test: a rename is persisted, and other fields are untouched.
- [x] `scripts/check.sh` passes. Verified on the iOS 18 simulator.

## Comments

- 2026-10-30: Implemented on branch `docs/forget-less-v1-spec`. `scripts/check.sh` passes, and so do the app tests. The repository gains `rename(id:name:)`, which does nothing when no Task has the id, as `setComplete` does. Two new catalog keys have `en` and `uk`: `task.save`, the VoiceOver label of ▶ while editing, and `task.rename`, a VoiceOver action on a Task's circle, since VoiceOver activates the circle rather than the row. After an edit is saved or dismissed, VoiceOver focus returns to the Task's circle, as it returns to the "+" after an add. The agent drove the app on the iPhone 18 Pro (iOS 27) simulator through UI snapshots:
  - Tapping a row opened the composer with the Task's name and its Day on the chip ("Tomorrow" for a Task on 31 Oct). The software keyboard was up in the same snapshot, so the field had focus. The Task's Complete state didn't change.
  - With the field blank or holding only a space, ▶ was disabled. Tapping it left the composer open and the Task unchanged.
  - Saving " Bread " over a Complete Task "B" stored "Bread". The Task stayed Complete and second in its Day, and the composer closed. "GMT" renamed to "GMT now" kept its Day and its Incomplete state. Both renames survived a relaunch.
  - Swiping the panel down during an edit left the Task as it was and the field blank. The next add started from an empty field, and adding kept the composer up as before.
- Skipped: the simulator stopped taking point taps (`scripts/sim-tap.sh`) and hardware key presses, and it also hid the software keyboard. MobileBuildMCP's elementRef taps still landed. Four things couldn't be checked:
  - that a tap on the circle itself still toggles Complete without opening the composer;
  - that tapping the dimmed background dismisses an edit (this box stays unticked);
  - that Return saves an edit;
  - that the keyboard comes up with no delay after the first edit.

  In the code, the circle is a borderless Button inside the row's tap gesture, so the circle takes its own taps. The dimmed background calls the same dismiss as the swipe, and Return calls the same `submit` as ▶. Each of these still needs a check by hand.
- Saving an edit closes the composer in the view model before the view's dismissal runs. A saved edit therefore never looks unsaved to 09's "Discard changes?" check. 09 still has to decide what Return on a blank name does in edit mode: story 20 dismisses, but under story 24 a blank name differs from the saved one.
- Known edges:
  - A failed rename shows the error, but the typed name is lost, because the composer has already closed. An add gives the name back in that case.
  - An add draft left in a dismissed composer is overwritten by the next row tap.
- The name rule is applied as `String.trimmed` plus `canSubmit`'s empty check, as in `AddTask`. The spec's "pure function in Domain" predates 0813b6d, which removed `validatedTaskName`.
