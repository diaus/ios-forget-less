# 05: Complete / Incomplete

**What to build:** Tapping a Task's circle makes it Complete, and tapping again makes it Incomplete (spec stories 10–12). A Complete Task shows a filled grey circle with a white checkmark, and its name is struck through and greyed. The Task never moves when its state changes. The state survives relaunch.

**Blocked by:** 03: Add a Task to Today

**Status:** ready-for-agent

- [ ] Tapping the circle toggles Complete and Incomplete. Tapping the rest of the row does not (that's reserved for renaming in 06).
- [ ] Complete styling: a filled grey circle with a checkmark, and a struck-through, greyed name. Incomplete: an empty grey ring and a primary name. Both read well in light and dark appearance.
- [ ] Toggling doesn't change the Task's position within its Day.
- [ ] The state persists across relaunch.
- [ ] The view model calls the repository directly, with no use case (per the use-case rule).
- [ ] Data test: setting Complete and back to Incomplete is persisted.
- [ ] `scripts/check.sh` passes. Verified on the iOS 18 simulator.
