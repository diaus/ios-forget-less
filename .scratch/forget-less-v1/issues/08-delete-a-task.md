# 08: Delete a Task

**What to build:** Swiping a Task's row left reveals a trash button (spec story 25). Tapping it asks `Delete "name"?` with Delete (destructive) and Cancel. Confirming removes the Task for good. A full swipe never deletes on its own.

**Blocked by:** 03: Add a Task to Today

**Status:** ready-for-agent

- [ ] Swiping left shows a trash icon button. A full swipe doesn't trigger it.
- [ ] Tapping the trash shows a confirmation dialog naming the Task. Delete removes it; Cancel leaves it in place.
- [ ] A deleted Task is gone after relaunch, and the other Tasks of its Day keep their order.
- [ ] Works for Complete and Incomplete Tasks. Once 07 has landed, it also works in the Overdue section.
- [ ] The view model calls the repository directly (per the use-case rule).
- [ ] Data test: delete removes only that Task.
- [ ] `scripts/check.sh` passes.
