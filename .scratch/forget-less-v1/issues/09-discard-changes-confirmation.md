# 09: Discard-changes confirmation

**What to build:** Dismissing the composer with unsaved changes asks before throwing them away (spec stories 21 and 24). The dialog is "Discard changes?" with **Discard** (destructive) and **Keep Editing**. Dismissing with no changes closes silently.

What counts as a change:
- **Add mode:** the trimmed name isn't empty. After adding several Tasks in a row, the field is empty again, so dismissing doesn't ask.
- **Edit mode:** the trimmed name differs from the saved one.

Return on a blank name does nothing in both modes, so it never shows the dialog.

A saved edit closes the composer through `ScheduleView.dismissComposer()`, the same path as a dismissal. So the check goes on the dismiss gestures (tap outside, swipe down, VoiceOver escape), not on that close.

**Blocked by:** 06: Rename a Task

**Status:** ready-for-agent

- [x] Tapping the dimmed background or swiping the panel down with a change shows the dialog. Without a change, the composer closes immediately.
- [x] Discard closes the composer and drops the draft or the edit.
- [x] Keep Editing leaves the composer open with the text intact, and returns focus to the field with the keyboard up.
- [x] The composer stays visible behind the dialog while focus is away (visibility is separate from focus, as proven in 02).
- [x] Whitespace-only input counts as no change in both modes. (In edit mode, this means whitespace around the saved name; a cleared name is a change. See Comments.)
- [x] `scripts/check.sh` passes, and the UI check covers both modes.

## Comments

- 2026-10-31: Implemented on branch `docs/forget-less-v1-spec`. `scripts/check.sh` passes, and so do the app tests.
  - `ComposerState.hasChanges` holds the rule. Its tests are in the app target, beside `DateDayChipTests`: it's a pure rule on app-layer state, not view-model logic.
    - Add mode: the trimmed name isn't empty.
    - Edit mode: the trimmed name differs from the saved one.
  - Decided with the user: while renaming, a cleared (blank) name differs from the saved one, so dismissing asks (story 24). The acceptance box's "whitespace-only input" covers whitespace around the saved name (`" Buy milk\n"`), which counts as no change.
  - The dialog is an `.alert`, not a `.confirmationDialog`. On iOS 27 the confirmation dialog shows as a popover. That popover hides the cancel-role Keep Editing, and it leaves the keyboard up.
  - Showing the alert drops the field's focus but leaves the composer visible. Keep Editing focuses the field again, synchronously in its action.
  - `ComposerView` takes two callbacks: `onDismiss` for the user's dismissals (tap outside, swipe down, VoiceOver escape), which ask first, and `onRenamed` for a saved edit, which closes without asking.
  - `ScheduleViewModel.dismissComposer()` now always clears the typed name, so Discard drops an add draft too. This also clears 06's known edge where a draft left in a dismissed composer was overwritten by the next row tap.
  - New catalog keys, each with `en` and `uk`: `composer.discardChanges` ("Discard changes?" / "Відкинути зміни?"), `composer.discard` ("Discard" / "Відкинути"), and `composer.keepEditing` ("Keep Editing" / "Редагувати далі"). "Скасувати" was avoided, because iOS uses it for Cancel.
- UI check on the iPhone 18 Pro (iOS 27), driven through UI snapshots:
  - Add mode:
    - A whitespace-only name closed at once, on both tap outside and swipe down, and the draft was cleared.
    - "milk" asked on both gestures.
    - Keep Editing brought the keyboard back with "milk" intact, and typing went on into the field ("milks").
    - Discard closed the composer with the field blank and no Task added.
  - Edit mode:
    - An untouched name, and the name plus a trailing space, closed at once.
    - "eggs sdfx" asked, and Keep Editing refocused the field.
    - Discard of an edit, and of a cleared name, left the Task's name unchanged.
    - Saving a rename closed the composer without asking.
  - The panel stays visible behind the alert (screenshot).
- Not checked: VoiceOver escape, live. It calls the same `onDismiss` as the gestures. iOS 18 wasn't run (only on request).
