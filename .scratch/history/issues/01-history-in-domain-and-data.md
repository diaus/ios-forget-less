# 01: History in Domain and Data

**What to build:** The Domain and Data parts of spec stories 11–17 and 23–24, with no UI: a Schedule that lists History, and a stream that sends the past.

- `Schedule` takes the History listing (for example an optional first Day) and holds Today explicitly. In History it lists every Day from the first Day on, empty ones included, with all their Tasks, Complete ones included, and no Overdue. Outside History it's unchanged.
- The move rules (`canMove(_:to:)`, the drop rule, `canMoveToEnd(_:of:)`, Move Up/Down) accept past Days in History and refuse them outside it. They read Today from the Schedule, not from `days.first`.
- `RelativeDay` gains `yesterday`; the widget's `UpcomingRow` treats it as `beforeToday`.
- A rule for choosing a Day that accepts any Day in History, and stays `canBePlanned(today:)` outside it.
- `TodoTaskRepository`'s Schedule stream takes an optional first Day. With one, it sends every Task from that Day on, Complete or not. Without one, the query is unchanged (ADR 0006).

**Blocked by:** None

**Status:** resolved

- [x] Domain tests: the History Schedule, the move rules in and out of History, `relativeDay` and the choosing rule (see the spec's Testing Decisions).
- [x] Data tests: the stream with and without a first Day.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.

## Comments

- **2026-11-07, the choosing rule:** `Date.canBeChosen(today:showsHistory:)` in `Date+Day`. `canMoveToEnd(_:of:)` uses it, so in History it accepts a Day before the first Day listed too, as the floating picker that pages back without limit (story 25) will need.
- **2026-11-07, the Schedule:** `Schedule(…, historyFirstDay:)`; `nil` lists outside History. A first Day on or after Today lists no past Day but still lists as History (no Overdue, Complete Tasks shown). Issue 02 never passes one, as the first Day starts about 60 Days back.
- **2026-11-07, the stream:** `scheduleTasks(today:historyFirstDay:)`. The app passes `nil` until issue 02 holds the History state.
- **2026-11-07, `yesterday`:** the app's Day chip, header formatting and the widget preview treat it as `beforeToday` until issue 02 names it "Yesterday". `DateDayChipTests` and `DateDayFormattingTests` gained a Day before Yesterday, since their only past Day is now Yesterday.
