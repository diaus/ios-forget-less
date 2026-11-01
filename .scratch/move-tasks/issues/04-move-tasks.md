# 04: Move Tasks

**What to build:** The Move Tasks quick setting and dragging Tasks by their handle (spec stories 1–31 and 41–45).

- **The quick setting:**
  - `movesTasks` on the view model, stored in `UserDefaults` with a default of `true`.
  - A second square in the quick settings bar, `lock.open` while on and `lock` while off.
  - VoiceOver reads it as a toggle labelled "Move Tasks", a new catalog key.
- **Handles:** the `line.3.horizontal` reorder accessory on every row while Move Tasks is on, animated in and out. No handle and no moving while it's off.
- **Drop:**
  - The target-index-path delegate asks `Schedule`'s move rule and sends a refused drop (into Overdue) back to the Task's original index path.
  - On drop, the list asks `Schedule` for the `MoveDestination` (destination Day, and the Task shown just above it or none). The view model applies the move to its last observed Tasks at once, and calls `move(id:to:)`.
  - A failed write puts back the Tasks the stream last sent and shows the error alert.
- **Feel:** a light haptic on lift and a selection tick on entering another Day, simplified if ticket 01 found part of this unworkable.
- **Today rolling over** mid-drag cancels the drag.

**Blocked by:** 02: The move rule and its storage; 03: The Schedule list in UIKit

**Status:** resolved

- [x] The UI check (`docs/agents/ui-check.md`) on iOS 27 confirms:
  - a Task moved within Today;
  - a Task moved from Today to an empty Day;
  - an Overdue Task moved to Today, which leaves Overdue;
  - an Overdue Task dropped back inside Overdue, which snaps back;
  - a Today Task dropped into Overdue, which is refused;
  - a Complete Task moved, which stays Complete;
  - with Complete Tasks hidden, a Task dropped between two shown Tasks lands right after the upper one;
  - auto-scroll to a far Day.
- [x] Turning Move Tasks off hides the handles and stops moving. The choice survives a relaunch.
- [x] The circle, row tap and swipe-to-delete still work with handles showing.
- [x] The widget shows the moved Task in its new place after the app goes to the background (`docs/agents/ui-check.md`, "Lock Screen widget").
- [x] The new catalog key has `en` and `uk`, added with `scripts/xcstrings.py`.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.

## Comments

### 2026-11-01: implemented and checked on iOS 27

**What changed**
- **Domain** gains two pure functions, each with tests:
  - `Schedule.destination(forDropOf:on:at:)`: a drop position as a `MoveDestination`.
  - `[TodoTask].movingTask(id:to:)`: the view model's copy of the observed Tasks with the move already made, renumbered as the repository stores it.
- **The list:**
  - `ScheduleListController` adds the reorder accessory while Move Tasks is on, and `canReorderItem` refuses every move while it's off.
  - The target-index-path delegate asks the move rule. Overdue has no Day, so a drop there goes back to where the row started.
  - The drop follows the lifted row, not the list's proposal (`ScheduleCollectionView.moveTarget(at:from:)`): the Day whose header is the nearest above the row's centre, after that Day's rows whose middle is above it. The list's proposal never names an empty Day, names the next Day while the row is over the top half of its header, and in a Day entered from another names only the edge the row came in at. An earlier band around an empty Day's header missed the room above the next header and took the gap at the end of the Day above.
  - `TaskRowMove` holds the lifted row and its haptics.
- **The view model** holds `movesTasks` in `UserDefaults` (default on). `move(_:to:)` checks the move rule, moves the Task at once, and writes.

**Departures from the ticket**, now matched in the spec and above:
- The list, not the view model, asks `Schedule` for the drop's `MoveDestination`. It asks the `Schedule` the list shows, because the drop's index path belongs to that list, and the delegate asks the same. The view model still checks the move rule before writing.
- A failed write puts back the Tasks the stream last sent at once. A failed save notifies no stream, so no "next stream element" would come to put the Task back.
- **For the user to decide:** any change to the rows while a row is lifted cancels the move, not only Today rolling over. Rows can't change under a lifted one, and this also covers a kept Task leaving when its grace period ends mid-drag.
- The Day tick follows ticket 01's warning. A refused section is never entered, so a drag from Day +2 through Today into Overdue ticks only for Today.

**Checked on the iPhone 18 Pro (iOS 27).** Drags were scripted with `axe drag`, which sends explicit touch-move events. `axe swipe` is too coarse: the delegate isn't called for the last stretch, so a drop onto an empty Day's header can miss. Each check was read back from `axe describe-ui` and the store.
- All eight drag cases in the first box:
  - within Today;
  - Today to an empty Day;
  - Overdue to Today (it leaves Overdue, and its Day label goes);
  - an Overdue Task dropped within Overdue (the gap never left its index path);
  - a Today Task dropped into Overdue (every proposal into Overdue refused);
  - a Complete Task stays Complete;
  - with Complete Tasks hidden, a drop between two shown Tasks lands right after the upper one, ahead of the hidden one;
  - auto-scroll from 3 Nov to 14 Nov, dropping into an empty Day as it scrolls.
- Drops that keep the list's flat order were also saved: the last Overdue Task into an empty Today, and Today's only Task into an empty Tomorrow.
- **Move Tasks off:** no handles, and a drag where the handle was scrolls the list. It's still off after a relaunch. The icons are `lock` and `lock.open`. The handles fade over about 0.1 s, measured from `simctl io recordVideo` frames.
- **Row actions with handles:** the circle (Complete and back), a row tap (the composer on that Task), and swipe-to-delete with `Delete "name"?` all work.
- **Widget:** after locking, it showed "Buy milk" once that Task was moved into Today.
- **Today rolling over mid-drag:** the app ran in `GMT-0224`. A drag was held across local midnight, and `SignificantTimeChangeNotification` was posted mid-drag. The delegate stopped being called, letting go wrote nothing, and the row went back to Overdue with its red Day label drawn.

**Not verified**
- **Haptics.** The simulator can't play them. The lift comes from `isReordering`, as ticket 01 found, and the tick from the delegate.
- **iOS 18.** Not run, as `CLAUDE.md` asks.
- **The reorder accessory on VoiceOver.** It's still an element ("Reorder <name>"), and ticket 05 hides it.

