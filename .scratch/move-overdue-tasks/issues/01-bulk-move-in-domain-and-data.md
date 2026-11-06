# 01: The bulk Move in Domain and Data

**What to build:** The Domain and Data parts of spec stories 14–19 and 21: everything the label needs to Move the Overdue Tasks, without the UI.

- A property on `Schedule` giving the Overdue Tasks: the Incomplete ones in `overdue`, oldest Day first, then position.
- A pure ordering beside `TodoTask.order(afterMoving:to:in:)` that puts Tasks, in the order given, at the top of a Day above all its Tasks.
- `movingTasks(ids:toStartOf:)` on `[TodoTask]`, beside `movingTask(id:to:)`, for the optimistic list.
- `TodoTaskRepository.move(ids:toStartOf:)` and its live implementation: one save, one notification, unknown IDs skipped, the Days left keep their order.

**Blocked by:** None

**Status:** ready-for-agent

- [x] Domain tests: the ordering, the Overdue Tasks property, `movingTasks(ids:toStartOf:)` (see the spec's Testing Decisions).
- [x] Data tests: the repository call.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.
