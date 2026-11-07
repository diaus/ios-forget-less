# 01: History in Domain and Data

**What to build:** The Domain and Data parts of spec stories 11–17 and 23–24, with no UI: a Schedule that lists History, and a stream that sends the past.

- `Schedule` takes the History listing (for example an optional first Day) and holds Today explicitly. In History it lists every Day from the first Day on, empty ones included, with all their Tasks, Complete ones included, and no Overdue. Outside History it's unchanged.
- The move rules (`canMove(_:to:)`, the drop rule, `canMoveToEnd(_:of:)`, Move Up/Down) accept past Days in History and refuse them outside it. They read Today from the Schedule, not from `days.first`.
- `RelativeDay` gains `yesterday`; the widget's `UpcomingRow` treats it as `beforeToday`.
- A rule for choosing a Day that accepts any Day in History, and stays `canBePlanned(today:)` outside it.
- `TodoTaskRepository`'s Schedule stream takes an optional first Day. With one, it sends every Task from that Day on, Complete or not. Without one, the query is unchanged (ADR 0006).

**Blocked by:** None

**Status:** ready-for-agent

- [ ] Domain tests: the History Schedule, the move rules in and out of History, `relativeDay` and the choosing rule (see the spec's Testing Decisions).
- [ ] Data tests: the stream with and without a first Day.
- [ ] `build_sim`, `test_sim` and `scripts/check.sh` pass.
