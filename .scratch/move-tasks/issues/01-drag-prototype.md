# 01: Drag prototype

**What to build:** Before the Schedule is rebuilt on it, prove that a UIKit collection-view list can move rows the way the spec asks (ADR 0004, spec "App").

Build a throwaway screen, or a debug-only replacement for the Schedule list. It's a `UICollectionView` list with a diffable data source, wrapped for SwiftUI, and it holds a few sections of sample rows, one of them empty and one standing in for Overdue. Each row is a SwiftUI view in a `UIHostingConfiguration` with a leading circle button, a row tap, a trailing swipe action and an always-visible reorder accessory (`line.3.horizontal`). Use enough sections that the list scrolls well past one screen.

Nothing is saved. A drop only reorders the in-memory sample data.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] A drag starts on touch-down on the accessory, with no long press, **outside editing mode**.
- [ ] A row moves within its section and into another section, including an **empty** one.
- [ ] The list **auto-scrolls** while a row is dragged near its top or bottom edge.
- [ ] A drop into the Overdue stand-in is refused: no gap opens there, and letting go returns the row to where it started.
- [ ] With the accessory showing, the circle button, the row tap and the trailing swipe action still work.
- [ ] On iOS 26+, the quick settings bar placed with `safeAreaBar(edge: .top)` above the wrapped list still blurs the rows scrolling under it. On iOS 18, `safeAreaInset` with `.bar` still works.
- [ ] A light haptic on lift and a selection tick on entering another section are feasible, or what blocks them is noted.
- [ ] Checked on the iOS 27 simulator through the UI check (`docs/agents/ui-check.md`). The user confirms how the drag feels on a device or simulator.
- [ ] Findings, including anything surprising, are recorded under a `## Comments` heading here. If they confirm the approach, ADR 0004 goes to `accepted`.
- [ ] **If any of the first three boxes fails:** don't pick a fallback yet. Research how existing apps and libraries move rows across sections from a handle that starts on touch-down, record the options with sources under `## Comments`, and bring them to the user. One known candidate is a zero-delay pan that drives `beginInteractiveMovementForItem(at:)`, with the auto-scroll written by hand.
