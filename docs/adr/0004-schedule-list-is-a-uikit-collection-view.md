---
status: accepted
---

# The Schedule list is a UIKit collection view, so Tasks can be moved across Days

Moving a Task drags it by a handle that starts the drag on touch-down. The drop can land on any listed Day, including an empty one, and some drops are refused: nothing lands in Overdue except an Overdue Task going back where it was. Swipe to delete, renaming by tapping the row, and the complete circle keep working while the handles are shown, which they are by default. SwiftUI's `List` can't do this on iOS 18, so the Schedule list is a `UICollectionView` list, wrapped for SwiftUI, with its rows still drawn in SwiftUI. The always-visible reorder accessory starts the drag. The delegate's `targetIndexPathForMoveOfItemFromOriginalIndexPath:atCurrentIndexPath:toProposedIndexPath:` sends a refused drop back to where the Task started.

A prototype confirmed it (`.scratch/move-tasks/issues/01-drag-prototype.md`): the accessory drags outside editing mode, a drop lands in an empty section, and the list auto-scrolls during a drag, on iOS 27 and iOS 18 alike.

## Considered Options

- **SwiftUI `List` with `onMove`.** Rejected on four counts:
  - It can't move a row between sections.
  - Outside edit mode, a drag only starts after a long press.
  - Edit mode turns off swipe actions.
  - It can't refuse a move until the row has already landed.
- **SwiftUI `reorderable(collectionID:)` and `reorderContainer`, iOS 27 only.** These do move rows between sections. Rejected because:
  - They have no handle API, and the drag isn't documented to start on touch-down.
  - They can't refuse a drop into one collection.
  - Nobody has confirmed that they drop into empty sections or that swipe actions still work.
  - iOS 18 would get no moving at all.
- **`.draggable` and `.dropDestination`.** Rejected: the system drag starts on a long press.
- **`UITableView` in permanent editing mode.** It moves rows across sections on touch-down and can refuse a drop. Rejected because editing mode turns off swipe actions.

## Consequences

- The list never proposes a drop into an empty section by itself. The target-index-path delegate sends the gap to an empty section when the lifted row is over that section's header.
- Wrapping a UIKit list under SwiftUI's safe area has pitfalls on iOS 18. The prototype's Comments record them and how it avoided them.
- Once the deployment target reaches iOS 27, check whether SwiftUI's reordering has caught up. If it has, the list can go back to SwiftUI.
