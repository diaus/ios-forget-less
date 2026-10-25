# 07: Overdue

**What to build:** An "Overdue" section above Today holds the Incomplete Tasks from earlier Days, so unfinished work is never lost (spec stories 5–7 and 13):
- Each row shows its own Day as a small red label at the bottom trailing edge.
- A Task completed from this section stays there, struck through, until the list next refreshes. A mis-tap can be undone.
- Editing an Overdue Task shows its Day on the chip as a red short date.

The full refresh (recompute Today, forget the kept Overdue Tasks) happens on launch, when the app becomes active, and on a significant time change, which fires at midnight and on time-zone changes. A reload after a write keeps them. See `LoadSchedule` in the spec.

**Blocked by:** 04: The 100-Day schedule and per-Day add; 05: Complete / Incomplete; 06: Rename a Task

**Status:** ready-for-agent

- [ ] The "Overdue" section appears above Today only when there are Overdue Tasks. Its header is primary bold with no "+".
- [ ] It lists Incomplete Tasks whose Day is before Today, oldest Day first, then by order within the Day.
- [ ] Each Overdue row shows its Day (e.g. `20 Oct`, with the year if not the current year) in red at the bottom trailing edge.
- [ ] Completing an Overdue Task keeps it in the section, struck through. Making it Incomplete again works. It disappears at the next full refresh.
- [ ] When Today rolls over at midnight while the app is open, the list rebuilds: yesterday's Incomplete Tasks move into Overdue, and the window shifts.
- [ ] After a time-zone change, every Task stays on the Day it was planned for (ADR 0001).
- [ ] Tapping an Overdue row opens the composer in edit mode with its Day as a red short date on the chip.
- [ ] Domain tests:
  - Overdue holds only Incomplete Tasks before Today, in the right order;
  - a kept Overdue Task stays after being completed;
  - `LoadSchedule` composes its queries correctly, against a fake repository.
- [ ] Data tests: the boundary of the "Incomplete before Today" query at Today, and fetching Tasks by id.
- [ ] `scripts/check.sh` passes. Verified on the iOS 18 simulator, including changing the simulator's time zone.
