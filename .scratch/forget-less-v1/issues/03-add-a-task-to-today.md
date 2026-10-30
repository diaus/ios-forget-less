# 03: Add a Task to Today

**What to build:** The tracer bullet through every layer. The red floating "+" opens the composer from 02 on Today. The user types a name and presses ▶ or Return. The Task appears under a Today section and is still there after relaunching the app. The composer stays open with the name cleared and the same Day, ready for the next Task.

The list in this ticket only needs the Today section, with a plain header and plain rows (circle and name). The full window, header styling, completing and the other states come in later tickets.

For the domain model, the `AddTask` use case, the repository and the Day encoding, see the spec's "Domain model", "Use cases" and "Repository" sections and ADR 0001.

**Blocked by:** 01: Project scaffold and tooling; 02: Composer keyboard prototype

**Status:** ready-for-agent

- [x] The red floating "+" sits at the bottom trailing corner and opens the composer with the Day chip showing `Today` in green. The keyboard comes up with no delay, as in 02.
- [x] ▶ is accent-red when the trimmed name isn't empty, and grey and disabled otherwise. Return does nothing while the name is blank.
- [x] ▶ and Return both add the Task: Incomplete, at the end of Today's Tasks, with its name trimmed. The composer stays open with an empty field and the same Day.
- [x] Tasks under Today appear in the order they were added, and still do after relaunch.
- [x] Domain tests:
  - the name rule (trimming; an empty or whitespace-only name refused);
  - the end-of-Day rule (an empty Day starts at 0; gaps allowed);
  - `AddTask` appends at the end of its Day and refuses an empty name, against a fake repository.
- [x] Data tests:
  - a Task round-trips every field;
  - a Day saved with a UTC−4 calendar and with a UTC+2 calendar is stored as UTC midnight of the same year/month/day and reads back as local midnight of that Day;
  - Tasks on a Day come back only for that Day.
- [x] Every new catalog key has `en` and `uk`. `scripts/check.sh` passes, and the flow is driven with UI snapshots.

## Comments

- 2026-10-25: Implemented on branch `docs/forget-less-v1-spec`. `scripts/check.sh` passes, and the three new catalog keys (`error.title`, `error.emptyName`, `error.unexpected`) have `en` and `uk`. The agent drove the flow on the iPhone 18 Pro (iOS 27) simulator through UI snapshots:
  - "+" brings up the composer with the keyboard and a green `Today` chip. ▶ is grey and not tappable while the field is empty, and Return on a blank name adds nothing and keeps the keyboard up.
  - ▶ added "Buy milk" and Return added "Call mom". Each time the field cleared, the keyboard stayed up and ▶ went grey again.
  - After a relaunch both came back under Today in that order, and a third Task added after them landed last.
- The repository protocol has only `tasks(on:)` and `create(_:)` so far; later tickets add the rest of the spec's methods as they need them. The view model loads Today's Tasks straight from the repository and sorts them by `sortIndex`; ticket 04's Schedule takes over.
- Return would normally drop focus, so the composer puts focus back on the field in the same action as submitting.
- Review fixes:
  - The repository's default calendar is `.autoupdatingCurrent`, not `.current`. It's a singleton, and a `.current` snapshot would keep converting Days in the old time zone after the user travels.
  - Each add waits for the previous one, so two quick adds can't read the same end of Day and take the same `sortIndex`.
- Errors reach the user through `error.userMessage` and `.errorAlert(message:)`, as the spec says. This is the first ticket with writes.
- Not done here: the full refresh (on becoming active, and on a significant time change) is ticket 07's. Until then, Today stays at launch's Day.
