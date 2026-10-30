# 07: Overdue

**What to build:** An "Overdue" section above Today holds the Incomplete Tasks from earlier Days, so unfinished work is never lost (spec stories 5–7 and 13):
- Each row shows its own Day as a small red label at the bottom trailing edge.
- A Task completed from this section stays there, struck through, until the list next refreshes. A mis-tap can be undone.
- Editing an Overdue Task shows its Day on the chip as a red short date.

The full refresh (recompute Today, forget the kept Overdue Tasks) happens on launch, when the app becomes active, and on a significant time change, which fires at midnight and on time-zone changes. A reload after a write keeps them. See `LoadSchedule` in the spec.

**Blocked by:** 04: The 100-Day schedule and per-Day add; 05: Complete / Incomplete; 06: Rename a Task

**Status:** ready-for-agent

- [x] The "Overdue" section appears above Today only when there are Overdue Tasks. Its header is primary bold with no "+".
- [x] It lists Incomplete Tasks whose Day is before Today, oldest Day first, then by order within the Day.
- [x] Each Overdue row shows its Day (e.g. `20 Oct`, with the year if not the current year) in red at the bottom trailing edge.
- [x] Completing an Overdue Task keeps it in the section, struck through. Making it Incomplete again works. It disappears at the next full refresh.
- [x] When Today rolls over at midnight while the app is open, the list rebuilds: yesterday's Incomplete Tasks move into Overdue, and the window shifts.
- [x] After a time-zone change, every Task stays on the Day it was planned for (ADR 0001).
- [x] Tapping an Overdue row opens the composer in edit mode with its Day as a red short date on the chip.
- [x] Domain tests:
  - Overdue holds only Incomplete Tasks before Today, in the right order;
  - a kept Overdue Task stays after being completed;
  - `LoadSchedule` composes its queries correctly, against a fake repository.
- [x] Data tests: the boundary of the "Incomplete before Today" query at Today, and fetching Tasks by id.
- [x] `scripts/check.sh` passes, and the UI check includes changing the simulator's time zone.

## Comments

- 2026-10-30: Implemented on branch `docs/forget-less-v1-spec`. `scripts/check.sh` passes, and so do the app tests.
  - `Schedule` gains `overdue`, built from `tasks`, `today` and `keepingOverdue`.
  - `LoadSchedule(today:keepingOverdue:)` composes the three queries. A kept Task made Incomplete again comes back from two of them, so it's de-duplicated by id.
  - The repository gains `incompleteTasks(before:)` and `tasks(ids:)`.
  - The view model's `refresh()` runs on launch, whenever the scene becomes `.active`, and on `significantTimeChangeNotification`. Each reload is numbered, so one that finishes after a newer one has started is dropped. Without this, a write's reload that started before a midnight refresh could put back yesterday's Schedule.
  - The colour asset `DayChipPast` is now `OverdueDay`. It's shared by the row's Day label and the edit chip's past Day.
  - New catalog keys, each with `en` and `uk`:
    - `schedule.overdue`, the section header;
    - `task.nameOnDay`, the circle's VoiceOver label on an Overdue row, so VoiceOver reads the Day as well as the name.
- UI check on the iPhone 18 Pro (iOS 27), driven through UI snapshots. Past-Day Tasks were written straight into the app's SwiftData store with `sqlite3` (see `docs/agents/ui-check.md`). Results:
  - The Overdue section sat above Today with a bold primary header and no "+". Its order was 31 Dec 2025, then 20 Oct (sort index 0, then 2, with the Complete Task at index 1 left out), then 29 Oct.
  - Each row showed its Day in red at the bottom trailing edge, with the year for 2025. Both appearances were checked.
  - Completing "Pay rent" struck it through and kept it in the section. Tapping again made it Incomplete. Completed again, it disappeared once the app went to the background (Settings opened over it, in the same process) and came back.
  - Posting `SignificantTimeChangeNotification` inside the simulator (`notifyutil`) dropped a kept Task, so the time-change refresh runs. This was checked again after the review fixes. This is the notification iOS posts at midnight.
  - Time zones: relaunched under `TZ=Pacific/Kiritimati` (UTC+14, where it was already 31 Oct), Today was 31 Oct. The three 30 Oct Tasks moved into Overdue, still labelled `30 Oct`, and the window started at 31 Oct. Under `TZ=Pacific/Pago_Pago` (UTC−11), Today was 30 Oct again, with every Task on its own Day.
  - Tapping an Overdue row opened the composer on its name, with a red `20 Oct` on the chip.
- Not checked live: an actual clock crossing midnight, or a zone change while the app runs. The handler for both was driven by the posted notification, and a refresh's new Today by relaunching under `TZ`.
- A refresh also runs on a return from `.inactive`, such as after pulling down Control Center, so kept Tasks go then too. Story 13 says "app becomes active again", so this follows the spec.
- The view model decides which Task to keep (`schedule.overdue` contains it when its circle is tapped). That's one membership check; the rule that a kept Task stays is in `Schedule` and tested there.

