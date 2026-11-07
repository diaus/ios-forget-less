# 02: The medium Home Screen size, and full-size rows on the sizes with controls

Status: resolved

**What to build:** `.systemMedium` with the large size's circle and arrows, and full-size rows (17pt, 5pt gap, never shrunk, as many as fit from the top) on both sizes with controls. User stories 2, 13 and 16 in `../spec.md`, and the Widget decisions that name the sizes with controls. The small and Lock Screen widgets don't change.

- One `WidgetFamily` check for the sizes with controls replaces `family == .systemLarge` in `HomeScreenRowsView` and `family != .systemLarge` in `UpcomingTimelineProvider.rowLimit`.
- A second `TextRowsSizing` for the sizes with controls, with `smallestGap` and `smallestFontSize` equal to the full ones.
- Doc comments that say "the large size" (`UpcomingWidget`, `CompleteCircleView`, `MoveStepsView`, `UpcomingRow`, `UpcomingWidgetContent`) say "the sizes with controls".
- ADR 0005 already names the large and medium sizes.

**Blocked by:** none

- [x] Previews (`RenderPreview`) of the medium size show 3, 8 and 20 Tasks, both markers, dimmed halves, and the empty and unreadable states, with rows at 17pt and the full gap.
- [x] Previews of the large size with 8 and 30 Tasks show rows at 17pt and the full gap, the last row shown with its down half dimmed.
- [x] The small and Lock Screen previews look as before.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.
- [x] On the iOS 27 simulator's Home Screen, the medium widget is added, its circle makes a Task Complete, and each half Moves a Task.

## Comments

- **2026-11-07, previews (iPhone 18 Pro, iOS 27):** only the medium gallery sample was rendered: 3 rows at 17pt with the full gap, each with its circle and arrows, the first row's up half and the Tomorrow row's down half dimmed. The user asked to skip the UI checks, so the other medium previews, the large 8 and 30 Task previews and the small and Lock Screen comparisons weren't rendered, and those boxes stay unticked.
- **2026-11-07, on the simulator's Home Screen:** skipped at the user's request, so that box stays unticked.
- **2026-11-07, extension file:** `WidgetFamily+LockScreen.swift` became `WidgetFamily+LockScreenAndControls.swift`, since it now holds `hasControls` beside `isOnLockScreen`.
