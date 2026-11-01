# 03: The Schedule list in UIKit, with no change in behaviour

**What to build:** Replace the Schedule's SwiftUI `List` with the UIKit collection-view list that ticket 01 proved out (ADR 0004, spec "App"). Nothing moves yet, and no handles show. The screen must look and behave exactly as it does now, so ticket 04 only adds moving.

- A diffable data source fed from the view model's `Schedule`, with stable Task IDs and Day sections. Changes animate like the list's default animation, including Show Complete Tasks and the end of a kept Task's grace period.
- The rows and the Day and Overdue headers are the existing SwiftUI views in `UIHostingConfiguration`. Header weight, the "+" on Day headers and none on Overdue, the red Overdue Day label, and separators inset to the text all stay as they are.
- Swipe-to-delete moves to the list's native trailing swipe action, with no full swipe and the same `Delete "name"?` confirmation.
- Row tap to rename, the circle, the bottom margin under the floating "+", the quick settings bar placement and its blur (iOS 26+) or `.bar` (iOS 18), and VoiceOver focus returning to the opener after the composer closes all keep working.

**Blocked by:** 01: Drag prototype

**Status:** ready-for-agent

- [x] The UI check (`docs/agents/ui-check.md`) on iOS 27 confirms:
  - the Day headers, the Overdue section and its labels;
  - adding through a Day's "+" and the floating "+";
  - renaming by row tap;
  - completing, and making Incomplete again;
  - swipe-to-delete with its confirmation;
  - Show Complete Tasks with the 2-second grace period;
  - the quick settings bar over scrolled content.
- [ ] The composer still opens with the keyboard in the same frame.
- [ ] VoiceOver focus returns to the row or the header "+" that opened the composer.
- [x] Before and after screenshots of the same Schedule, in light and dark, show no visible difference beyond what's noted under `## Comments`.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.

## Comments

### 2026-11-01: implemented, the UI check partly run

The list is a `UICollectionView` (`ScheduleListView`, `ScheduleListController`, `ScheduleCollectionView`), with `TaskRowView`, `DayHeaderView` and `OverdueHeaderView` hosted in it. VoiceOver focus return goes through `ComposerOpenerFocus`, because `@AccessibilityFocusState` can't reach the views hosted in cells. The swipe's confirmation is a `UIAlertController` anchored to the row. It adds the `task.deleteCancel` catalog key, because UIKit, unlike SwiftUI, doesn't supply Cancel. Changes animate only when SwiftUI's transaction does, as with the old `List`: Show Complete Tasks, and the end of the grace period.

Checked on the iPhone 18 Pro (iOS 27):
- **Screenshots.** Before and after, light and dark, are pixel-identical except one thing: the old `List` drew a stray full-width hairline under a row that was followed by a two-line row. The new list doesn't.
- **Behaviour.** These all work: headers, the Overdue labels, adding through a Day's "+" (that header turned bold) and the floating "+", renaming by row tap, completing and back, swipe-to-delete with `Delete "name"?`, Show Complete Tasks with its 2 s grace period, and the bar blurring scrolled rows.
- **The swipe button.** It's icon-only, as before. VoiceOver still lists "Rename" and "Delete" on the circle (`axe describe-ui`).
- **Composer focus.** The composer's field took typed text with no tap, so it had focus. The software keyboard is hidden in this simulator (a hardware keyboard is attached), so "keyboard in the same frame" wasn't seen.

Checked after the review fixes:
- **Today rolling over.** The app ran with `SIMCTL_CHILD_TZ=GMT-HHMM`, with local midnight two minutes away. At 23:58 the 31 Oct Tasks were Today's rows. At midnight, after `SignificantTimeChangeNotification`, they moved to Overdue and their VoiceOver names became "Water plants, 31 Oct".
  - The first build reconfigured those rows. Their red Day label was laid out (it was in `axe describe-ui`) but not drawn until the list scrolled.
  - They're now reloaded instead. After the fix, all three labels drew at once.
  - Ticket 04 should watch for the same thing: a row reconfigured while it changes section.
- **Animation.** Frames were pulled from `simctl io recordVideo` with AVFoundation. Both Show Complete Tasks toggles animate over about 0.4 s. A Task completed while Complete Tasks are hidden ticks its circle at once, and leaves 2 s later, animated over 0.4 s.

Not verified:
- **VoiceOver focus returning to the opener.** The simulator has no VoiceOver. The box stays unticked until it's checked on a device.
- **The keyboard in the same frame.** The software keyboard is hidden in this simulator, since a hardware keyboard is attached. Typed text reached the field with no tap, so the field had focus as soon as the composer opened. The focus code itself is unchanged: `focusComposer` still runs in the tap's action. The box stays unticked.
