# Move Tasks

Status: ready-for-agent

## Problem Statement

Once a Task is written down, its place is fixed. It stays on the Day it was added to, at the end of that Day, in the order it was added. When plans change, the user has to delete the Task and type it again on another Day. When priorities change within a Day, there's no way at all to put one Task above another. An Overdue Task can only be completed or deleted, never replanned for Today or later.

## Solution

The user can Move a Task: give it a new place, on its own Day or on another (see `GLOSSARY.md`). A new quick setting, **Move Tasks**, is on by default. While it's on, every row shows a grip handle at its trailing edge. Touching the handle lifts the Task at once, with no long press, and the user drags it to any listed Day and position. Dropping it there gives the Task that Day and that position. Completing, renaming and deleting work as before.

The Overdue section only gives Tasks up. An Overdue Task can be moved to Today or later. Dropping it back inside Overdue cancels the drag, and nothing else can be dropped there.

VoiceOver users get "Move Up" and "Move Down" actions that step a Task one place at a time.

To make this possible, the Schedule list is rebuilt as a UIKit collection-view list, wrapped for SwiftUI (ADR 0004, `proposed` until a prototype confirms it).

## User Stories

### The quick setting

1. As a user, I want a Move Tasks button in the quick settings bar, next to Show Complete Tasks, so that moving is one tap away from being turned on or off.
2. As a user, I want Move Tasks on by default, so that I can move Tasks without first finding a setting.
3. As a user, I want my Move Tasks choice kept across launches, so that the list stays the way I left it.
4. As a user, I want the button drawn as `lock.open` while Move Tasks is on and `lock` while it's off, in the same neutral square either way, so that the icon tells me whether my Tasks can move.
5. As a VoiceOver user, I want the button read as a toggle labelled "Move Tasks" with its on/off value, so that I know what it does and its state.
6. As a user, I want the handles to animate in and out when I toggle Move Tasks, so that the change is easy to follow.

### Handles

7. As a user, I want every listed Task, Complete or not and in every section, to show a `line.3.horizontal` handle at its trailing edge while Move Tasks is on, so that I can see what I can move.
8. As a user, I want an Overdue row's handle placed after its red Day label, so that the label stays readable.
9. As a user, I want no handle while Move Tasks is off, and no way to move a Task then, including by long press, so that the list stays calm and can't change by accident.
10. As a user, I want the circle, a tap on the row and swipe-to-delete to keep working while handles are shown, so that turning on Move Tasks costs me nothing.

### Dragging

11. As a user, I want the drag to start the moment I touch a handle, with no long press, so that moving feels immediate.
12. As a user, I want the dragged row lifted, and a gap opening where it would land, so that I can see where the Task will go before I let go.
13. As a user, I want the list to auto-scroll while I drag near its top or bottom edge, so that I can reach Days far from where I started.
14. As a user, I want a light haptic when the row lifts and a tick each time the drag enters a different Day, so that I can feel the Day change without reading headers.
15. As a user, I want the dragged Task dropped exactly where the gap is, so that I put it where I mean.

### Where a Task can land

16. As a user, I want to drop a Task on any listed Day, so that I can replan it for any Day I can see.
17. As a user, I want to drop a Task at any position within its own Day, so that I can order a Day's Tasks the way I'll do them.
18. As a user, I want to drop a Task into an empty Day, where it becomes that Day's only Task, so that I can plan for a Day that has nothing on it yet.
19. As a user, I want to drop a Task on a Day after the 100-Day window, as long as that Day is listed, so that later Days work like the rest.
20. As a user, I want a moved Task to take the Day of the section it's dropped in, so that moving between Days replans it.
21. As a user, I want moving never to make a Task Complete or Incomplete, so that moving and completing stay separate.
22. As a user, I want a Complete Task to be movable too, so that the rule is simple: anything listed can move.
23. As a user with Complete Tasks hidden, I want a dropped Task to land right after the Task shown above it, before any hidden Task that follows that one, so that it lands where I see it land.
24. As a user with Complete Tasks hidden, I want a Task dropped at the top of a Day to go first, before any hidden Task, so that "top" means top.
25. As a user, I want a Day after the window that a move leaves empty to disappear from the list, so that the list follows the same rule as for any other change.

### Overdue

26. As a user, I want to move an Overdue Task to Today or any later Day, so that I can replan unfinished work instead of retyping it.
27. As a user, I want a moved Overdue Task to leave the Overdue section, so that it's no longer counted as late.
28. As a user, I want an Overdue Task dropped anywhere inside Overdue to snap back to where it was, so that I have a way to cancel a drag.
29. As a user, I want Overdue Tasks never reordered among themselves, so that Overdue stays oldest Day first.
30. As a user, I want a Task that isn't Overdue never dropped into Overdue, with no gap opening there and a drop cancelling the drag, so that I can't plan a Task in the past.
31. As a user, I want a Task completed from Overdue on Today, still listed struck through in Overdue, to follow the same rules as an Overdue Task, so that the section behaves one way.

### VoiceOver

32. As a VoiceOver user, I want the handle hidden from VoiceOver, so that the rotor isn't cluttered by something I can't drag.
33. As a VoiceOver user, I want "Move Up" and "Move Down" actions on each Task while Move Tasks is on, so that I can move Tasks without dragging.
34. As a VoiceOver user, I want each step to move the Task one place among the Tasks shown, skipping hidden Complete Tasks, so that a step matches what I'd see.
35. As a VoiceOver user, I want "Move Down" on the last Task of a Day to make it the first Task of the next listed Day, and "Move Up" on the first Task of a Day to make it the last Task of the previous listed Day, so that I can move a Task across Days one step at a time.
36. As a VoiceOver user, I want an empty Day to count as a stop, so that I can plan a Task for an empty Day.
37. As a VoiceOver user, I want no "Move Up" on the first Task of Today and no "Move Down" on the last Task of the last listed Day, so that I'm only offered steps that do something.
38. As a VoiceOver user, I want an Overdue Task to offer only "Move Down", which takes it to the top of Today, so that the Overdue rules hold for me too.
39. As a VoiceOver user, I want the Task's new Day announced after each step ("Tomorrow", "3 Nov"), so that I know where it went.
40. As a VoiceOver user, I want no move actions while Move Tasks is off, so that the setting means the same for me as for everyone.

### Elsewhere

41. As a user, I want Tasks within a Day in the order I added or moved them, so that the list is stable and mine.
42. As a user, I want the Lock Screen widget to show a moved Task in its new place right after I move it, so that it agrees with the app.
43. As a user, I want a Task added from the composer still to go to the end of its Day, so that adding works as before.
44. As a user, I want a wrong drop fixed by dragging the Task back, with no separate undo, so that the app stays simple.
45. As a user, I want the Schedule to look and behave exactly as before in every other way, including headers, Overdue labels, the quick settings bar and its blur, the floating "+", and the composer that opens with no delay, so that moving costs nothing else.

## Implementation Decisions

### Domain

- **Place** is a new value type: a Day, plus the Task the moved Task goes right after, or none for first. A drop and a VoiceOver step each resolve to a Place. It names an existing Task rather than an index, so hidden Tasks need no special handling.
- **The order rule** is a pure function beside the end-of-Day rule. Given every Task of the destination Day in order (hidden ones included, the moved Task excluded) and a Place, it returns the Day's new order, so that each Task's `sortIndex` can be its position from 0.
  - "After A" puts the Task right after A, ahead of whatever followed A.
  - "First" puts it ahead of every Task.
  - If the named Task isn't on that Day, for example because it was deleted meanwhile, the Task goes to the end of the Day.
- **The move rule** lives on `Schedule`, which already knows the sections:
  - **Overdue is never a destination.** Dropping an Overdue Task inside Overdue and dropping any other Task there are both no-ops, so the drag is cancelled with no write.
  - **Every listed Day is a destination.**
  - **Steps for VoiceOver.** `Schedule` computes the Place one step above and one step below a Task among the Tasks it lists, or `nil` when there's none. It follows stories 34–38: hidden Tasks are skipped because `Schedule` already holds only the Tasks shown, a step at a Day's edge crosses into the neighbouring listed Day, empty Days are stops, an Overdue Task's only step is the top of Today, and nothing above the first Task of Today.
- `TodoTask` is unchanged. Moving changes `day` and `sortIndex` and never `completeDay`.
- **No use case.** Moving is a single repository call, so the view model calls the repository directly, as it does for set Complete and delete (`CODING_STANDARDS.md`'s use-case rule). The repository applies the order rule itself, as `create(name:day:)` applies the end-of-Day rule, so two moves at once can't take the same place. The view model checks the move rule on `Schedule` before writing.

### Data

- `TodoTaskRepository` gains `move(id:to:)`, taking a Place. In one actor call with no suspension, and one notifying save, it:
  - reads the destination Day's Tasks,
  - applies the order rule,
  - sets the Task's Day,
  - writes the new `sortIndex` of every Task on that Day.
- The Day the Task left keeps its gaps, which the end-of-Day rule already allows. A move within one Day renumbers only that Day.
- Moving a Task that doesn't exist does nothing, like rename and delete.
- The schema is unchanged, so no migration is needed.
- The notifying save makes every open `scheduleTasks(today:)` stream send again (ADR 0002), and its after-save hook reloads the widget (ADR 0003).

### App

- **The Schedule list is rebuilt in UIKit (ADR 0004).** It becomes a `UICollectionView` list with a diffable data source, wrapped for SwiftUI.
  - The row content and the Day and Overdue headers stay SwiftUI, through `UIHostingConfiguration`.
  - Swipe-to-delete moves to the list's native trailing swipe actions, with no full swipe and a confirmation before deleting.
  - It must look the same as the SwiftUI `List` it replaces: same section style, separators inset to the text, the bottom content margin under the floating "+", the quick settings bar above it (`safeAreaBar` with its scroll edge effect on iOS 26+, `safeAreaInset` with `.bar` on iOS 18), and the default list animation when rows change.
  - Accessibility focus returning to a row or a header's "+" after the composer closes keeps working.
- **The handle** is the list's reorder accessory, always visible while Move Tasks is on and not tied to editing mode. Whether that works is the prototype's first question.
- **Refusing a drop.** The collection view's target-index-path delegate method asks `Schedule`'s move rule. A drop into Overdue resolves to the Task's original index path, so no gap opens there and letting go returns the Task.
- **On drop**, the view model works out the Place from the drop position: the Day of the destination section, and the Task shown just above, or none. It applies the move to its last observed Tasks at once, so the row doesn't snap back while the write is in flight, rebuilds the Schedule, and writes through the repository. The stream then confirms. On failure, the next stream element puts the Task back, and the error alert shows.
- **Today rolling over during a drag** cancels the drag.
- **The quick setting.**
  - The `ScheduleViewModel` holds `movesTasks`, stored in `UserDefaults` with a default of `true`, the same way it holds `showsComplete`.
  - The button is the second square in the quick settings bar, after Show Complete Tasks. Its `accessibilityRepresentation` is a `Toggle` labelled with a new catalog key for "Move Tasks".
- **VoiceOver actions.**
  - "Move Up" and "Move Down" are named accessibility actions on the row's circle element, beside the existing Rename action.
  - Each is present only while Move Tasks is on and the move rule returns a Place for that direction.
  - After a step, the app announces the Task's Day, using the header's relative wording or short date.
  - All the new strings go through the String Catalog with `scripts/xcstrings.py`.
- **Haptics.** A light impact when the row lifts, and a selection tick when the drag's destination section changes. If the prototype shows that the chosen approach can't support part of this list, simplify it rather than build around it.
- **Fallback.** If the prototype finds the reorder accessory only drags in editing mode, or can't drop into an empty section, or doesn't auto-scroll, research how existing apps and libraries solve this before choosing a fallback (ADR 0004). The known candidate is a zero-delay pan on the handle driving `beginInteractiveMovementForItem(at:)`, with the auto-scroll written by hand.

## Testing Decisions

A good test exercises behaviour through a public interface and asserts on outcomes: returned values and repository contents. Tests pass `today` explicitly, and Days are GMT midnights. Swift Testing only.

- **Domain** (prior art: the Schedule tests and the end-of-Day rule tests):
  - **The order rule:**
    - after a Task in the middle, after the last Task, first;
    - into an empty Day;
    - after a Task followed by hidden ones, which lands before them;
    - a named Task that isn't on the Day, which goes to the end;
    - a move within the same Day, earlier and later.
  - **The move rule:**
    - Overdue refused for an Overdue Task and for a Task on Today;
    - every window Day and a listed later Day accepted;
    - a Task completed from Overdue on Today follows the Overdue rules.
  - **VoiceOver steps:**
    - within a Day;
    - across a Day edge both ways;
    - onto an empty Day;
    - none above the first Task of Today;
    - none below the last Task of the last listed Day;
    - an Overdue Task's only step is the top of Today;
    - with Complete Tasks hidden, hidden Tasks are skipped;
    - across the window's end into a listed later Day.
- **Data** (prior art: the repository tests against an in-memory `ModelContainer`):
  - `move(id:to:)` sets the Day and renumbers the destination Day in order;
  - it leaves the Day it came from as it was;
  - it keeps `completeDay`;
  - it moves an Overdue Task to Today;
  - it does nothing for an unknown `id`;
  - every open `scheduleTasks(today:)` stream sends again.
- **App:** no view-model, UI or snapshot tests, as in v1. The prototype ticket and the UI check (`docs/agents/ui-check.md`) on iOS 27 cover the drag, the refusals, the quick setting and the unchanged look.

## Out of Scope

- A date picker, or moving a Task to a Day that isn't listed.
- Moving several Tasks at once.
- Undo for a move.
- A "Move to Tomorrow" action or any other shortcut besides drag and the two VoiceOver steps.
- Moving from the Lock Screen widget.
- Reordering or replanning within Overdue.

## Further Notes

- Vocabulary: **Move** is in `GLOSSARY.md`. ADR 0004 records why the list is UIKit. ADRs 0002 and 0003 explain why nothing beyond the notifying save is needed to refresh the list and the widget.
- The v1 spec's Out of Scope no longer lists moving a Task to another Day or reordering, and its story 8 now reads "in the order I added or moved them".
- Icon previews chosen during design: handle H1 `line.3.horizontal`, quick setting B1 `lock.open` / `lock`.
- Issues, in order: `issues/01` the drag prototype, `02` Domain and Data, `03` the Schedule list in UIKit with no behaviour change, `04` Moving Tasks and the quick setting, `05` the VoiceOver actions.
