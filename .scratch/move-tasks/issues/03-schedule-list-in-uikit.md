# 03: The Schedule list in UIKit, with no change in behaviour

**What to build:** Replace the Schedule's SwiftUI `List` with the UIKit collection-view list that ticket 01 proved out (ADR 0004, spec "App"). Nothing moves yet, and no handles show. The screen must look and behave exactly as it does now, so ticket 04 only adds moving.

- A diffable data source fed from the view model's `Schedule`, with stable Task IDs and Day sections. Changes animate like the list's default animation, including Show Complete Tasks and the end of a kept Task's grace period.
- The rows and the Day and Overdue headers are the existing SwiftUI views in `UIHostingConfiguration`. Header weight, the "+" on Day headers and none on Overdue, the red Overdue Day label, and separators inset to the text all stay as they are.
- Swipe-to-delete moves to the list's native trailing swipe action, with no full swipe and the same `Delete "name"?` confirmation.
- Row tap to rename, the circle, the bottom margin under the floating "+", the quick settings bar placement and its blur (iOS 26+) or `.bar` (iOS 18), and VoiceOver focus returning to the opener after the composer closes all keep working.

**Blocked by:** 01: Drag prototype

**Status:** ready-for-agent

- [ ] The UI check (`docs/agents/ui-check.md`) on iOS 27 confirms:
  - the Day headers, the Overdue section and its labels;
  - adding through a Day's "+" and the floating "+";
  - renaming by row tap;
  - completing, and making Incomplete again;
  - swipe-to-delete with its confirmation;
  - Show Complete Tasks with the 2-second grace period;
  - the quick settings bar over scrolled content.
- [ ] The composer still opens with the keyboard in the same frame.
- [ ] VoiceOver focus returns to the row or the header "+" that opened the composer.
- [ ] Before and after screenshots of the same Schedule, in light and dark, show no visible difference beyond what's noted under `## Comments`.
- [ ] `build_sim`, `test_sim` and `scripts/check.sh` pass.
