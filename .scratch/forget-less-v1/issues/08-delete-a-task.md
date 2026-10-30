# 08: Delete a Task

**What to build:** Swiping a Task's row left reveals a trash button (spec story 25). Tapping it asks `Delete "name"?` with Delete (destructive) and Cancel. Confirming removes the Task for good. A full swipe never deletes on its own.

**Blocked by:** 03: Add a Task to Today

**Status:** ready-for-agent

- [x] Swiping left shows a trash icon button. A full swipe doesn't trigger it.
- [x] Tapping the trash shows a confirmation dialog naming the Task. Delete removes it; Cancel leaves it in place.
- [x] A deleted Task is gone after relaunch, and the other Tasks of its Day keep their order.
- [x] Works for Complete and Incomplete Tasks. Once 07 has landed, it also works in the Overdue section.
- [x] The view model calls the repository directly (per the use-case rule).
- [x] Data test: delete removes only that Task.
- [x] `scripts/check.sh` passes.

## Comments

- 2026-10-30: Implemented on branch `docs/forget-less-v1-spec`. `scripts/check.sh` passes, and so do the app tests.
  - The repository gains `delete(id:)`, which saves through the notifying save. Two Data tests cover it:
    - a delete removes only that Task, survives a fresh repository, and the rest of its Day keep their order;
    - the Schedule stream sends again after a delete.
  - `ScheduleViewModel.delete(_:)` calls the repository directly.
  - The row's swipe action has no full swipe. Its button has no `role: .destructive`: on iOS 27 that role made the List remove the row at once, and the row's confirmation dialog went with it. A new colour asset, `DeleteAction` (system red, light and dark), tints the button instead.
  - The dialog belongs to the row, so on iOS 27 it shows as a popover anchored to it.
  - New catalog keys, each with `en` and `uk`:
    - `task.delete`, the trash button's VoiceOver label and the dialog's Delete;
    - `task.deleteConfirmation`, the dialog title `Delete “name”?`.
- UI check on the iPhone 18 Pro (iOS 27), driven through UI snapshots:
  - A partial swipe and a full swipe across the screen (axe) both stopped at the icon-only trash button. Nothing was deleted, and no dialog opened.
  - The trash opened `Delete “fdsa”?`. Tapping outside left the Task in place. Delete removed it.
  - Deleted an Incomplete and a Complete Task from Today, and a Task from Overdue (written into the store with `sqlite3`, then removed).
  - After a relaunch the deleted Tasks stayed gone, and the rest of the Day kept their order (sort indexes 0 and 2 in the store).
  - The trash button was checked in light and dark appearance.
- On iOS 27 the dialog is a popover, which has no Cancel button: tapping outside cancels, as in the system apps. On iOS 18 the system adds its own Cancel to the action sheet. That wasn't checked live, since iOS 18 runs only on request.
- Not checked: whether VoiceOver offers Delete in the row's Actions rotor. The snapshot doesn't list custom actions.
