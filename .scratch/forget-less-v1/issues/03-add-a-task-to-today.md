# 03: Add a Task to Today

**What to build:** The tracer bullet through every layer. The red floating "+" opens the composer from 02 on Today. The user types a name and presses ▶ or Return. The Task appears under a Today section and is still there after relaunching the app. The composer stays open with the name cleared and the same Day, ready for the next Task.

The list in this ticket only needs the Today section, with a plain header and plain rows (circle and name). The full window, header styling, completing and the other states come in later tickets.

For the domain model, the `AddTask` use case, the repository and the Day encoding, see the spec's "Domain model", "Use cases" and "Repository" sections and ADR 0001.

**Blocked by:** 01: Project scaffold and tooling; 02: Composer keyboard prototype

**Status:** ready-for-agent

- [ ] The red floating "+" sits at the bottom trailing corner and opens the composer with the Day chip showing `Today` in green. The keyboard comes up with no delay, as in 02.
- [ ] ▶ is accent-red when the trimmed name isn't empty, and grey and disabled otherwise. Return does nothing while the name is blank.
- [ ] ▶ and Return both add the Task: Incomplete, at the end of Today's Tasks, with its name trimmed. The composer stays open with an empty field and the same Day.
- [ ] Tasks under Today appear in the order they were added, and still do after relaunch.
- [ ] Domain tests:
  - the name rule (trimming; an empty or whitespace-only name refused);
  - the end-of-Day rule (an empty Day starts at 0; gaps allowed);
  - `AddTask` appends at the end of its Day and refuses an empty name, against a fake repository.
- [ ] Data tests:
  - a Task round-trips every field;
  - a Day saved with a UTC−4 calendar and with a UTC+2 calendar is stored as UTC midnight of the same year/month/day and reads back as local midnight of that Day;
  - Tasks on a Day come back only for that Day.
- [ ] Every new catalog key has `en` and `uk`. `scripts/check.sh` passes, and the flow is driven on the iOS 18 simulator with UI snapshots.
