# 01: Drag prototype

**What to build:** Before the Schedule is rebuilt on it, prove that a UIKit collection-view list can move rows the way the spec asks (ADR 0004, spec "App").

Build a throwaway screen, or a debug-only replacement for the Schedule list. It's a `UICollectionView` list with a diffable data source, wrapped for SwiftUI, and it holds a few sections of sample rows, one of them empty and one standing in for Overdue. Each row is a SwiftUI view in a `UIHostingConfiguration` with a leading circle button, a row tap, a trailing swipe action and an always-visible reorder accessory (`line.3.horizontal`). Use enough sections that the list scrolls well past one screen.

Nothing is saved. A drop only reorders the in-memory sample data.

**Blocked by:** None (can start immediately)

**Status:** resolved

- [x] A drag starts on touch-down on the accessory, with no long press, **outside editing mode**.
- [x] A row moves within its section and into another section, including an **empty** one.
- [x] The list **auto-scrolls** while a row is dragged near its top or bottom edge.
- [x] A drop into the Overdue stand-in is refused: no gap opens there, and letting go returns the row to where it started.
- [x] With the accessory showing, the circle button, the row tap and the trailing swipe action still work.
- [x] On iOS 26+, the quick settings bar placed with `safeAreaBar(edge: .top)` above the wrapped list still blurs the rows scrolling under it. On iOS 18, `safeAreaInset` with `.bar` still works.
- [x] A light haptic on lift and a selection tick on entering another section are feasible, or what blocks them is noted.
- [x] Checked on the iOS 27 simulator through the UI check (`docs/agents/ui-check.md`). The user confirms how the drag feels on a device or simulator.
- [x] Findings, including anything surprising, are recorded under a `## Comments` heading here. If they confirm the approach, ADR 0004 goes to `accepted`.
- [x] N/A, none of the first three failed. **If any of the first three boxes fails:** don't pick a fallback yet. Research how existing apps and libraries move rows across sections from a handle that starts on touch-down, record the options with sources under `## Comments`, and bring them to the user. One known candidate is a zero-delay pan that drives `beginInteractiveMovementForItem(at:)`, with the auto-scroll written by hand.

## Comments

### Verdict (2026-10-31)

The approach holds: ADR 0004 is now `accepted`, and the user confirmed on a device that the drag feels OK. Every behaviour box passed on the iOS 27 simulator (iPhone 18 Pro). On iOS 18.5 (iPhone 16 Pro), only the moves (within a section, across sections, into an empty one), auto-scroll and the bar were checked. The Overdue refusal, the row actions with handles showing and the haptic hooks ran on iOS 27 only. The fallback box didn't apply: none of the first three checks failed.

The prototype is on the throwaway branch `prototype/move-tasks-drag` (commit `fd49d25`), in `ForgetLess/ForgetLess/Features/Schedule/Prototype/DragPrototypeView.swift`. It stands in for the Schedule as the app's root. It never merges.

### What was confirmed, and how

Taps and snapshots followed the UI check (`docs/agents/ui-check.md`, MobileBuildMCP `tap` and `snapshot_ui`). Drags departed from it: each was scripted with `axe` in one HID session, as `scripts/sim-tap.sh` does for taps, so it could start on the handle's point with no hold. The prototype's own event line ("Lift", "Gap in <section>", "Drop", "Row tap", "Circle", "Swipe delete") was read back from `snapshot_ui` or the app log, and mid-drag states from screenshots.

- **A drag with no long press, outside editing mode.** `UICellAccessory.reorder(displayed: .always)` with `reorderingHandlers.canReorderItem` lifts the row on the first movement after touch-down, with no hold and `isEditing` false. A finger held still on the handle lifts nothing (checked for 3 s), so the lift haptic comes with the first movement, not with the touch. On a device this felt immediate. Under the hood the accessory's own pan (`_UICollectionViewListCellReorderControl pan:`) drives the collection view's interactive movement. That's the same mechanism as the known fallback, already wired up.
- **Moving rows.** A row moves within its section and into another section. `reorderingHandlers.didReorder` reports the drop.
- **Empty sections need help.** Out of the box, the list never proposes an index path in an empty section, so the gap skips straight past it. The target-index-path delegate fixes this. It runs on every finger move, so when the lifted cell is over an empty section's header band, the delegate returns `[section, 0]`. Once the gap is there, the list's own proposals keep it there. With that, a drop into an empty Day works, and so does passing through one, during auto-scroll too.
  - The lifted cell is the visible cell whose `configurationState.isReordering` is true. `cellForItem(at: currentIndexPath)` is the cell at the gap, not the one under the finger.
- **Auto-scroll** works in both directions on both OS versions, with no code. It runs from just inside the list's content area, so the top edge starts just under the quick settings bar.
- **Refusing Overdue.** Returning `originalIndexPath` when the proposal is in Overdue keeps Overdue closed. While the row is held over Overdue, no gap opens there, and the gap stays where the row started. Letting go returns the row with no `didReorder`. An Overdue row moved within Overdue snaps back too, and one moved to Today is accepted.
- **Row actions with the handles showing.** The circle (a SwiftUI `Button`), the row tap (SwiftUI `onTapGesture` in the hosted row) and the native trailing swipe action (`trailingSwipeActionsConfigurationProvider`, no full swipe) all work. Scrolling by dragging a row's body works too.
- **The bar on iOS 26+.** A wrapped `UICollectionView` under `safeAreaBar(edge: .top)` gets the scroll edge effect: rows scrolled under the bar blur and fade. On iOS 18, the rows pass under `safeAreaInset` with `.bar` as before.
- **Haptics are feasible.**
  - *Lift:* `configurationUpdateHandler` sees `state.isReordering` turn true, which drives `UIImpactFeedbackGenerator(style: .light)`.
  - *Entering another section:* the target-index-path delegate sees the target section change, which drives `UISelectionFeedbackGenerator`.
  - *Ordering:* the delegate's first call comes at lift, before `isReordering`. It must not tick, or the lift plays two haptics.
  - *A tick for ticket 04 to avoid:* the prototype ticks whenever the gap's section changes. A row held over Overdue sends the gap back to the Day it started in, so a drag from Day +2 that passes through Today into Overdue ticks for Day +2, a Day the finger never entered. Story 14 wants a tick per Day entered.

### Surprises, for ticket 03

- **The safe area must stay `.automatic` (iOS 18).** SwiftUI gives a wrapped view no safe-area insets of its own, so the list's insets (bar, home indicator, the floating "+" margin) are read with a `GeometryReader` and the view ignores the safe area.
  - My first version set `contentInsetAdjustmentBehavior = .never` and wrote the full insets by hand. With that, UIKit hands the window's safe area to every cell under the status bar or the home indicator (`safeAreaInsets.bottom = 34`, top up to about 53).
  - On iOS 18, those cells' content then keeps a layout shifted by half that inset after they scroll away. Rows were left overlapped or cut off after a long auto-scroll drag, and after plain scrolling too. iOS 27 didn't show it.
  - The fix keeps `.automatic`, so the scroll view absorbs the safe area and no cell sees it, and adds only SwiftUI's extra (the bar) as `contentInset`. It recomputes in `safeAreaInsetsDidChange` and keeps a list resting at the top there in `adjustedContentInsetDidChange`. See `InsetCollectionView` on the prototype branch.
  - Found with a scripted check: relaunch on iOS 18.5, drag or scroll, then compare each row's text frame with its handle's in `axe describe-ui`. Red 4/4 before the fix, green after.
  - No public report matched exactly. Related reports are self-sizing compositional layouts collapsing cells on fast scrolling ([Apple forums 690773](https://developer.apple.com/forums/thread/690773)), and self-sizing with interactive movement on iOS 14.0, fixed in 14.2 ([659090](https://developer.apple.com/forums/thread/659090)).
- **`didReorder` runs inside the data source's own apply.** Applying a snapshot from it throws "attempted to apply a snapshot … while it was already applying a snapshot". Refresh the headers (an empty Day's grey weight) by reconfiguring the visible supplementary views in place, or apply later.
- **iOS 18 uppercases hosted section headers** unless the header view sets `.textCase(nil)`, as the Schedule's headers already do.
- **The reorder accessory is a VoiceOver element**, labelled "Reorder" plus the row's first label ("Reorder Circle"). Story 32 hides it, so tickets 04 and 05 must deal with it.
- **A cell that never self-sizes crashes iOS 18 mid-drag.** Returning the given attributes from `preferredLayoutAttributesFitting` sent the compositional layout into endless `_updateVisibleCellsNow:` recursion during auto-scroll. Keep the list's self-sizing.

### Not to copy from the prototype

It's throwaway code, reviewed against `CODING_STANDARDS.md`. Ticket 03 should take the mechanisms above, not these shortcuts:
- **Colours:** use the asset catalog's `.overdueDay` and `.deleteAction`, as `TaskRowView` does (`UIColor(resource: .deleteAction)` for the swipe action). The prototype hard-codes `.red` and `.systemRed`.
- **Keys:** key sections by Day and items by `TodoTask.ID`. The prototype's `Int` serves as both section identifier and section index, and works only because the two happen to match.
- **Overdue:** ask `Schedule`'s move rule (spec "Refusing a drop"), not a flag on the section.
- **Names:** use glossary terms for the project's own identifiers (Move, not drag or reorder: `movingTaskID`, not `reorderingID`). UIKit's own names (`isReordering`, `didReorder`) stay.
- **Files:** one type per file by role, and a `UIViewRepresentable` named like a view. The prototype keeps seven types in one file.
- **Doc comments:** the "why `.automatic`" note on `InsetCollectionView` belongs inline beside the inset code, not in the doc comment.
