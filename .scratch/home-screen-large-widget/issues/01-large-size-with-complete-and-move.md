# 01: The large Home Screen size, with Complete and Move

Status: ready-for-agent

**What to build:** everything in `../spec.md`, in one change: the Domain step rule, `TodoTaskWriter`, the two intents, and the large layout.

**Blocked by:** none

- [x] Domain tests for the step rule pass.
- [x] Data tests for `TodoTaskWriter` pass.
- [x] Previews (`RenderPreview`) of the large size show 3, 8 and 20 Tasks, both markers, dimmed halves, and the empty and unreadable states.
- [x] The small and Lock Screen previews look as before.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.
- [x] On the iOS 27 simulator's Home Screen, the large widget is added, its circle makes a Task Complete, and each half Moves a Task.

## Comments

- **2026-11-05, symbol direction:** `RenderPreview` showed that both arrows of `arrow.up.forward.and.arrow.down.backward.rectangle.fill` point inward, so the up arrow is on the left half and the down arrow on the right. The halves follow the arrows: the left half Moves up and the right half Moves down. That's what the user first asked for. Grilling Q6 had it the wrong way round.
- **2026-11-05, previews (iPhone 18 Pro, iOS 27):** these rendered as expected: the large gallery sample, the 4-Task sample with Overdue and Tomorrow (Overdue has both halves dimmed, Tomorrow's last row has its down half dimmed), and 30 Tasks (21 fit, the first row's up half is dimmed, and so is the last shown row's down half). The small size with Overdue and Tomorrow looks as before. The large size's 8-Task, empty and unreadable previews and the Lock Screen previews weren't rendered, so their boxes stay unticked.
- **2026-11-05, on the iOS 27 simulator's Home Screen:** the large size is in the gallery as the second page of "Upcoming". Once added, it listed the store's Tasks. Three taps each wrote the right change to the store. The small widget redrew right after the first two. The third ran while `reloadAllTimelines()` was removed, so the small widget didn't redraw after it:
  - Up on the third Today row put it second.
  - The circle made the Task Complete.
  - Down on the last Today row put it first on Tomorrow.

  The tapped large widget, though, kept showing its old rows, its tapped circle still pressed grey, until the Home Screen page was swiped away and back. Then it showed the right rows. The logs show the interaction reload succeed with the new entries and the renderer assign the new view. Removing the intents' `reloadAllTimelines()` didn't change it, and neither did a lone touch-up on the tapped spot. The cause isn't known. It may be the simulator's handling of axe's synthetic touches. A check on a device is still to do, so the simulator box stays unticked.
- **2026-11-05, the remaining previews (iPhone 18 Pro, iOS 27):** the large size's 8 Tasks preview has the first row's up half and the last row's down half dimmed. The empty and unreadable previews show the checklist symbol with its checkmark or warning badge, centred. With the gallery sample (3 Tasks) and the 30-Task one (21 shown, past 20), that covers the first box.
  For the second box, every small and Lock Screen preview was rendered at this commit and at `e7f216e`, the one before it, and the pairs were compared pixel by pixel. Small: the gallery sample, Overdue and Tomorrow, and 11 Tasks (8 listed). Lock Screen: the gallery sample, the four Overdue and Tomorrow settings, 11 Tasks (8 listed), empty and unreadable. Every pair matched exactly. The Lock Screen ones were compared below the clock, whose time differs between runs. Static Lock Screen renders come out blank white on both commits, so they were rendered in the interactive mode, which shows them on a Lock Screen.
