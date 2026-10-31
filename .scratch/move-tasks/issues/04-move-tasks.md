# 04: Move Tasks

**What to build:** The Move Tasks quick setting and dragging Tasks by their handle (spec stories 1–31 and 41–45).

- **The quick setting:**
  - `movesTasks` on the view model, stored in `UserDefaults` with a default of `true`.
  - A second square in the quick settings bar, `lock.open` while on and `lock` while off.
  - VoiceOver reads it as a toggle labelled "Move Tasks", a new catalog key.
- **Handles:** the `line.3.horizontal` reorder accessory on every row while Move Tasks is on, animated in and out. No handle and no moving while it's off.
- **Drop:**
  - The target-index-path delegate asks `Schedule`'s move rule and sends a refused drop (into Overdue) back to the Task's original index path.
  - On drop, the view model works out the `MoveDestination` (destination Day, and the Task shown just above it or none), applies the move to its last observed Tasks at once, and calls `move(id:to:)`.
  - A failed write puts the Task back on the next stream element and shows the error alert.
- **Feel:** a light haptic on lift and a selection tick on entering another Day, simplified if ticket 01 found part of this unworkable.
- **Today rolling over** mid-drag cancels the drag.

**Blocked by:** 02: The move rule and its storage; 03: The Schedule list in UIKit

**Status:** ready-for-agent

- [ ] The UI check (`docs/agents/ui-check.md`) on iOS 27 confirms:
  - a Task moved within Today;
  - a Task moved from Today to an empty Day;
  - an Overdue Task moved to Today, which leaves Overdue;
  - an Overdue Task dropped back inside Overdue, which snaps back;
  - a Today Task dropped into Overdue, which is refused;
  - a Complete Task moved, which stays Complete;
  - with Complete Tasks hidden, a Task dropped between two shown Tasks lands right after the upper one;
  - auto-scroll to a far Day.
- [ ] Turning Move Tasks off hides the handles and stops moving. The choice survives a relaunch.
- [ ] The circle, row tap and swipe-to-delete still work with handles showing.
- [ ] The widget shows the moved Task in its new place after the app goes to the background (`docs/agents/ui-check.md`, "Lock Screen widget").
- [ ] The new catalog key has `en` and `uk`, added with `scripts/xcstrings.py`.
- [ ] `build_sim`, `test_sim` and `scripts/check.sh` pass.
