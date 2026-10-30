# 06: Rename a Task

**What to build:** Tapping a Task's row, Complete or not, opens the same composer in edit mode (spec stories 22–23). The field holds the Task's name, and the chip shows its Day. The chip is display-only: the Day can't be changed in v1. Saving with ▶ or Return renames the Task and closes the composer. The keyboard still comes up with no delay.

**Blocked by:** 04: The 100-Day schedule and per-Day add

**Status:** ready-for-agent

- [x] Tapping a row (not its circle) opens the composer prefilled with the Task's name and its Day chip. The field is focused with no delay.
- [x] ▶ is disabled while the trimmed name is empty. Saving trims the name, renames the Task and closes the composer.
- [x] The renamed Task keeps its Day, its position and its Complete state.
- [x] Dismissing without saving (tap outside, swipe down) leaves the Task unchanged. The confirmation for unsaved changes comes in 09.
- [x] The view model applies the Domain name rule, then calls the repository directly (per the use-case rule).
- [x] Data test: a rename is persisted, and other fields are untouched.
- [x] `scripts/check.sh` passes. Verified on the iOS 18 simulator.

## Comments

- 2026-10-30: Implemented on branch `docs/forget-less-v1-spec`. `scripts/check.sh` passes, and so do the app tests. The repository gains `rename(id:name:)`, which does nothing when no Task has the id, as `setComplete` does. Two new catalog keys have `en` and `uk`: `task.save`, the VoiceOver label of ▶ while editing, and `task.rename`, a VoiceOver action on a Task's circle, since VoiceOver activates the circle rather than the row. After an edit is saved or dismissed, VoiceOver focus returns to the Task's circle, as it returns to the "+" after an add. The agent drove the app on the iPhone 18 Pro (iOS 27) simulator through UI snapshots:
  - Tapping a row opened the composer with the Task's name and its Day on the chip ("Tomorrow" for a Task on 31 Oct). The software keyboard was up in the same snapshot, so the field had focus. The Task's Complete state didn't change.
  - With the field blank or holding only a space, ▶ was disabled. Tapping it left the composer open and the Task unchanged.
  - Saving " Bread " over a Complete Task "B" stored "Bread". The Task stayed Complete and second in its Day, and the composer closed. "GMT" renamed to "GMT now" kept its Day and its Incomplete state. Both renames survived a relaunch.
  - Swiping the panel down during an edit left the Task as it was and the field blank. The next add started from an empty field, and adding kept the composer up as before.
- 2026-10-30: The four checks first skipped here have now run on the iPhone 18 Pro (iOS 27), and all pass:
  - A point tap on the circle of "Eggs Milk" toggled it Complete and back four times, and never opened the composer.
  - During an edit of "Cheese", a tap on the dimmed background at (200, 120), over the "A" row, closed the composer. Neither Task changed, and the field was blank again.
  - Typing "pples" after "A" and pressing Return (a hardware key) renamed it "Apples" and closed the composer. It stayed first in its Day and Incomplete. Tapping the software keyboard's `return` during an edit also saved and closed it.
  - With the software keyboard on, its keys were in the same snapshot as each edit, on the second edit and on the third, which followed a `return` dismissal.
- Why those checks were skipped: the simulator, not the app, was dropping input. On iOS 27 the simulator opens its HID services only once a client connects, and drops the input of a client that disconnects first, while axe reports success (AXe issue #71). axe's one-shot commands, and so MobileBuildMCP's `tap` and `key_press`, often disconnect first. `scripts/sim-tap.sh` now waits for the services in one session and takes `--key CODE`, and `CLAUDE.md` has `tap` pass `postDelay: 1`. The software keyboard was hidden because Device Hub had attached a hardware keyboard (the simulator log shows it right after boot); ⌥⌘K brings it back only while a field has focus.
- Seen once and not reproduced: a synthetic tap whose touch-down and touch-up were 0.3 ms apart, sent during an add, reached the "A" row under the dimmed background and opened its edit. A second tap like it, and every tap held like a finger's, closed the composer.
- Saving an edit closes the composer in the view model before the view's dismissal runs. A saved edit therefore never looks unsaved to 09's "Discard changes?" check. 09 still has to decide what Return on a blank name does in edit mode: story 20 dismisses, but under story 24 a blank name differs from the saved one.
- Known edges:
  - A failed rename shows the error, but the typed name is lost, because the composer has already closed. An add gives the name back in that case.
  - An add draft left in a dismissed composer is overwritten by the next row tap.
- The name rule is applied as `String.trimmed` plus `canSubmit`'s empty check, as in `AddTask`. The spec's "pure function in Domain" predates 0813b6d, which removed `validatedTaskName`.
