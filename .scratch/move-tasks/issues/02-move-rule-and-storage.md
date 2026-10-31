# 02: The move rule and its storage

**What to build:** The Domain rules and the repository write behind Moving a Task (spec "Domain" and "Data"). There's no UI yet, and the app looks exactly as before.

- **Domain:**
  - **Place:** a Day plus the Task to go right after, or none for first.
  - **The order rule:** a pure function beside the end-of-Day rule that returns a Day's new order for a Place. A Task named in the Place that isn't on the Day sends the moved Task to the end.
  - **The move rule on `Schedule`:** Overdue is never a destination, and every listed Day is. `Schedule` also gives the Place one step above and one step below a Task, for VoiceOver (spec stories 34–38).
- **Data:** `move(id:to:)` on `TodoTaskRepository` and its live actor. In one actor call and one notifying save, it reads the destination Day, applies the order rule, sets the Day and renumbers the destination Day from 0. It leaves `completeDay` and the Day it left as they were. An unknown `id` does nothing.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] Order rule tests: after a middle Task, after the last, first, into an empty Day, after a Task followed by hidden ones (lands before them), a named Task not on the Day (goes to the end), and within the same Day both earlier and later.
- [ ] Move rule tests:
  - Overdue is refused for an Overdue Task, for a Task completed from Overdue on Today, and for a Task on Today.
  - Window Days, empty ones included, and a listed later Day are accepted.
- [ ] Step tests:
  - within a Day, across a Day edge both ways, onto an empty Day, and across the window's end into a listed later Day;
  - none above the first Task of Today, and none below the last Task of the last listed Day;
  - an Overdue Task's only step is the top of Today;
  - hidden Complete Tasks are skipped.
- [ ] Data tests against an in-memory store:
  - a move to another Day sets the Day and the new order;
  - a move within a Day reorders it;
  - the Day left keeps its gaps;
  - `completeDay` is kept;
  - an Overdue Task moves to Today;
  - an unknown `id` changes nothing;
  - an open `scheduleTasks(today:)` stream sends again.
- [ ] Test names use glossary terms (Move, Day, Overdue, Complete).
- [ ] `build_sim`, `test_sim` and `scripts/check.sh` pass.
