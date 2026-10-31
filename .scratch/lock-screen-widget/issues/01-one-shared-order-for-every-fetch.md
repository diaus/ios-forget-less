# 01: One shared order for every fetch

**What to build:** Every Task fetch returns its Tasks in the Schedule's order: by Day, then by position within the Day. The Schedule screen looks exactly as before. This is the prefactor for the widget (spec "Repository" and "Domain"), so its fetch gets the order for free.

- **Data:** one sort, by Day then position, shared by `tasks(on:)` and `scheduleTasks(today:)`, applied in the query.
  - Each protocol method's doc comment says "in order of Day, then position within it" instead of "in no particular order".
  - `tasks(on:)` is sorted too for consistency, even though the end-of-Day rule doesn't need it.
- **Domain:** `Schedule` stops sorting.
  - It relies on its input already being in that order. Grouping by Day and filtering keep it.
  - Its `init` doc comment states that input contract.
- **`CODING_STANDARDS.md`:** the line "SwiftData fetches are unordered unless sorted" stays true. Tests can now compare order where the repository promises it.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] `tasks(on:)` and `scheduleTasks(today:)` return Tasks by Day, then position. Each Data test inserts Tasks out of order and asserts the order.
- [ ] Both protocol doc comments state the order. `Schedule`'s `init` doc comment states its input contract.
- [ ] `Schedule` has no sort of its own. `ScheduleTests` feed it ordered input and drop the cases that only checked its sorting. The grouping, window, Overdue and hiding cases still pass.
- [ ] The Schedule screen lists Overdue (oldest Day first) and each Day's Tasks in the same order as before, confirmed by the UI check (`docs/agents/ui-check.md`) on iOS 27.
- [ ] `build_sim`, `test_sim` and `scripts/check.sh` pass.
