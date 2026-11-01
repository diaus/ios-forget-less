# 05: VoiceOver "Move Up" and "Move Down"

**What to build:** Moving without dragging, for VoiceOver users (spec stories 32–40).

- The handle is hidden from VoiceOver.
- While Move Tasks is on, the row's circle element gets the named actions "Move Up" and "Move Down", beside Rename. Each is present only when `Schedule`'s step for that direction returns a `MoveDestination`.
- An action writes `move(id:to:)` with that `MoveDestination`, the same way a drop does, then announces the Task's new Day in the header's relative wording or short date.

**Blocked by:** 04: Move Tasks

**Status:** resolved

- [x] The UI check on iOS 27 confirms the following. It read the actions with `axe describe-ui` and invoked them through Xcode's debugger, because `snapshot_ui` can't show or invoke them (see Comments):
  - a step within a Day;
  - "Move Down" from the last Task of Today onto Tomorrow;
  - "Move Up" from the first Task of Tomorrow onto Today;
  - an Overdue Task offers only "Move Down", which puts it first on Today;
  - the first Task of Today offers no "Move Up";
  - with Move Tasks off, no move actions are offered.
- [x] The announcement names the new Day. If the simulator can't confirm the announcement, mark this box as skipped and say so.
- [x] Both catalog keys have `en` and `uk`, added with `scripts/xcstrings.py`.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.

## Comments

### 2026-11-01: implemented and checked on iOS 27

**What changed**
- `TaskRowView` gives the circle "Move Up" and "Move Down", listed after Rename. Each appears only while Move Tasks is on and `Schedule.destinationOneStepUp(for:)` or `destinationOneStepDown(for:)` returns a `MoveDestination`. The row reads `vm.schedule`, so its actions follow changes to its neighbours.
- `ScheduleViewModel.moveAnnouncingDay(_:to:)` moves the Task the same way a drop does. Once the write succeeds, it announces the Day: Today, Tomorrow or the short date (`Date.relativeNameOrShortDate(today:)`, which shares `relativeName(today:)` with the header). Utils' `postAnnouncement` gained a `String` overload.
- `TaskRowCell` hides the handle from VoiceOver.

**Departure: the list's own move actions.** UIKit added its own "Move up" and "Move down" to every row with a reorder handle. Those step by index path, ignore the move rule, and would have sat beside ours. UIKit asks `canReorderItem` when it builds them. The cell's `accessibilityCustomActions` and `accessibilityElements` aren't consulted: overriding them did nothing. So `canReorderItem` now says yes only while a finger is on the row's handle (`TaskRowCell.isHandleTouched`, from the touches it was last hit by) or while the row is lifted. This relies on UIKit hit-testing the touch before it asks, which is observed rather than documented. A drag by the handle still lifts, moves and saves the row.

**Checked on the iPhone 18 Pro (iOS 27).** Tasks were seeded on Today and Tomorrow beside three Overdue Tasks. Actions were read with `axe describe-ui`, and invoked through Xcode's debugger, as `docs/agents/ui-check.md` now describes. Each result was read back from `describe-ui` and the store, and each announcement from a breakpoint on `UIAccessibilityPostNotification`.
- Within a Day: Move Up on Today's second Task made it first. Announced "Today".
- Move Down on the last Task of Today made it first on Tomorrow. Announced "Tomorrow".
- Move Up on the first Task of Tomorrow made it last on Today. Announced "Today".
- An Overdue Task offered Rename, Move Down and Delete only. Move Down put it first on Today, out of Overdue.
- The first Task of Today then offered no Move Up.
- Move Down on the last Task of Tomorrow put it on the empty 3 Nov. Announced "3 Nov".
- Move Tasks off: every row offered only Rename and Delete. Back on, the move actions returned.
- No "Reorder <name>" element is left, and UIKit's own "Move up"/"Move down" are gone. Delete is still offered on every row.
- A drag by the handle still moves and saves the row.

**Not verified**
- **Speech and focus.** The simulator has no VoiceOver, so the check confirmed the announcement text but couldn't hear it spoken at high priority. Whether focus follows the Task after a step, which matters for stepping across several Days, needs a pass with VoiceOver on a device.
- **iOS 18.** Not run, as `CLAUDE.md` asks.
