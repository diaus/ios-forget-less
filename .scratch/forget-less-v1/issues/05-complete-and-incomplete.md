# 05: Complete / Incomplete

**What to build:** Tapping a Task's circle makes it Complete, and tapping again makes it Incomplete (spec stories 10–12). A Complete Task shows a filled grey circle with a white checkmark, and its name is struck through and greyed. The Task never moves when its state changes. The state survives relaunch.

**Blocked by:** 03: Add a Task to Today

**Status:** ready-for-agent

- [x] Tapping the circle toggles Complete and Incomplete. Tapping the rest of the row does not (that's reserved for renaming in 06).
- [x] Complete styling: a filled grey circle with a checkmark, and a struck-through, greyed name. Incomplete: an empty grey ring and a primary name. Both read well in light and dark appearance.
- [x] Toggling doesn't change the Task's position within its Day.
- [x] The state persists across relaunch.
- [x] The view model calls the repository directly, with no use case (per the use-case rule).
- [x] Data test: setting Complete and back to Incomplete is persisted.
- [x] `scripts/check.sh` passes.

## Comments

- 2026-10-30: Implemented on branch `docs/forget-less-v1-spec`. `scripts/check.sh` passes, and so do the app tests. The two new catalog keys have `en` and `uk`: `task.complete` and `task.incomplete`, the VoiceOver value of a Task's circle, whose label is the Task's name. The agent drove the app on the iPhone 18 Pro (iOS 27) simulator through UI snapshots:
  - Tapping a circle made the Task Complete: a grey disc with a white checkmark, and a struck-through grey name. It read well in both light and dark appearance. Tapping again made it Incomplete.
  - Tapping the middle of the row and the name left the Task as it was.
  - A Task that was made Complete kept its place above the Task added after it.
  - Complete, and the return to Incomplete, both survived a relaunch.
- The snapshot taps an element at its frame's centre, and a List row's button spans the row, so the circle itself was tapped by its coordinates.
- Known edge: the row flips the state it was drawn with, and redraws only after the write and the reload. Two taps landing before that reload both send Complete. The window is one local save, well under the gap between two taps.
- `setComplete` does nothing when no Task has the id. Rename and delete (06, 08) will need the same lookup by id.
