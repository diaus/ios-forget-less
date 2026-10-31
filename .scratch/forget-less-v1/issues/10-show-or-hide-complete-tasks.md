# 10: Show or hide Complete Tasks

**What to build:** A quick settings bar, fixed at the top trailing edge, with one button that shows or hides Complete Tasks (spec stories 30–35, and the changes to 2, 4, 9, 12 and 13):
- The bar sits above the list, which starts below it and scrolls under it: `safeAreaBar(edge: .top)` on iOS 26+, `safeAreaInset(edge: .top)` with the `.bar` material on iOS 18. Each setting is a 36 pt rounded-square icon button, 8 pt apart: Liquid Glass on iOS 26+, a neutral `.fill.tertiary` square on iOS 18.
- The button shows the current state: `checklist.checked` while Complete Tasks are shown, `checklist.unchecked` while they're hidden. The square looks the same either way; no accent colour.
- Complete Tasks are shown by default. The choice is kept across launches in `UserDefaults`, not in the Task store.
- While Complete Tasks are hidden, a Task you complete stays, struck through, for 2 seconds, then animates out. Making it Incomplete within that time cancels its timer and keeps it.
- Hiding drops every Complete Task, including those completed from Overdue on Today. A Day's header follows the Tasks it shows, so a Day whose Tasks are all hidden is grey. A Day after the window whose Tasks are all hidden isn't listed, and the Overdue section goes when it has nothing to show.

The filtering is in Domain: `Schedule` takes `showsComplete` and `keptTaskIDs` (the Tasks in their grace period). `ScheduleViewModel` holds the choice, `keptTaskIDs` with a timer per Task, and the last Tasks the stream sent, and rebuilds the Schedule when any of them or Today changes. Data and the repository stream don't change (ADR 0002).

**Blocked by:** 05: Complete / Incomplete; 07: Overdue

**Status:** ready-for-agent

- [x] The bar shows at the top trailing edge and stays put while the list scrolls under it.
- [x] Tapping the button hides every Complete Task, in Days and in Overdue, and tapping again brings them back. Rows animate in and out, and the glyph switches between `checklist.checked` and `checklist.unchecked`.
- [x] Complete Tasks are shown on a fresh install, and the choice survives a relaunch.
- [x] While hidden, a completed Task stays struck through for 2 seconds, then leaves. Making it Incomplete within that time keeps it in place.
- [x] While hidden, a Day with only Complete Tasks has a grey header and "+".
- [x] While hidden, a Day after the window with only Complete Tasks isn't listed.
- [x] While shown, a Task completed from Overdue still stays there until Today rolls over (story 13 is unchanged).
- [x] VoiceOver reads the button as a toggle, "Show Complete Tasks", with its on/off value. The key `schedule.showCompleteTasks` has `en` "Show Complete Tasks" and `uk` «Показувати виконані завдання», added with `scripts/xcstrings.py`.
- [x] `ScheduleTests` cover hiding: Complete Tasks leave Days and Overdue except those in `keptTaskIDs`; a later Day with only hidden Tasks isn't listed; a window Day with only hidden Tasks stays, empty.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass, and the UI check (`docs/agents/ui-check.md`) covers the items above on iOS 27.

## Comments

- 2026-10-31: Implemented on branch `docs/forget-less-v1-spec`. `build_sim`, `test_sim` and `scripts/check.sh` pass.
  - `Schedule` takes `showsComplete` and `keptTaskIDs`, and drops hidden Tasks before grouping them by Day. So header weight, later Days and the Overdue section all follow the Tasks shown, with no further code. `ScheduleTests` has four new cases.
  - `ScheduleViewModel` keeps the last Tasks observed and rebuilds the Schedule when the choice or the kept Tasks change. Each kept Task has its own 2-second timer. Making a Task Incomplete cancels its timer but leaves it in `keptTaskIDs`, so a rebuild before the write lands (another kept Task's timer, say) can't drop it for a moment. Changing the choice drops every kept Task. The code review found the first version, which dropped it from `keptTaskIDs` at once.
  - Deviations from the first draft of the spec, now updated there: on iOS 18 the square is a neutral `.fill.tertiary` square, because `.bordered` tints it with the accent. iOS 26+ uses `safeAreaBar`, which extends the scroll edge effect under the bar. The view model reads and writes `UserDefaults` itself, because `@AppStorage` doesn't work inside an `@Observable` type.
  - The button's `accessibilityRepresentation` is a `Toggle`, so VoiceOver reads a switch with an on/off value, and the button's look stays custom.
- UI check on the iPhone 18 Pro (iOS 27), driven through UI snapshots and `axe describe-ui`:
  - The bar shows top-trailing and stays fixed while the list scrolls under it, with the scroll edge blur.
  - Hiding drops Complete Tasks from Overdue and from Today, and the glyph switches. Showing brings them back.
  - While hidden, a Task completed from Overdue stayed for 2 seconds, then left, and the Overdue section went with it. A Task completed and made Incomplete again within the 2 seconds stayed, Incomplete. Taps were sent in one `axe` session: `sim-tap.sh` takes about 3 seconds per tap.
  - While hidden, Today with only a Complete Task had a grey header.
  - While shown, a Task completed from Overdue stayed there, struck through.
  - The hidden choice survived a relaunch. With no stored choice (`defaults delete`), the app started with Complete Tasks shown.
  - VoiceOver sees a switch, "Show Complete Tasks", with the value 1 or 0.
  - Showing Complete Tasks while the list is a little below the top keeps the rows on screen in place, and the Overdue rows that come back go above, out of view. At the very top, Overdue appears below the bar. This is `List`'s usual handling of rows inserted above what's visible, and was agreed as expected.
  - A Complete Task moved to 28 Feb 2027 (after the window, which ends on 7 Feb) put that Day at the end of the list while shown. With Complete Tasks hidden through the in-app toggle, the list ended at 7 Feb. Writing the choice with `simctl spawn … defaults write` doesn't reach the running app's preferences, so set it through the toggle. iOS 18 wasn't run (only on request).
