# 09: Discard-changes confirmation

**What to build:** Dismissing the composer with unsaved changes asks before throwing them away (spec stories 21 and 24). The dialog is "Discard changes?" with **Discard** (destructive) and **Keep Editing**. Dismissing with no changes closes silently.

What counts as a change:
- **Add mode:** the trimmed name isn't empty. After adding several Tasks in a row, the field is empty again, so dismissing doesn't ask.
- **Edit mode:** the trimmed name differs from the saved one.

Return on a blank name does nothing in both modes, so it never shows the dialog.

**Blocked by:** 06: Rename a Task

**Status:** ready-for-agent

- [ ] Tapping the dimmed background or swiping the panel down with a change shows the dialog. Without a change, the composer closes immediately.
- [ ] Discard closes the composer and drops the draft or the edit.
- [ ] Keep Editing leaves the composer open with the text intact, and returns focus to the field with the keyboard up.
- [ ] The composer stays visible behind the dialog while focus is away (visibility is separate from focus, as proven in 02).
- [ ] Whitespace-only input counts as no change in both modes.
- [ ] `scripts/check.sh` passes, and the UI check covers both modes.
