# 06: Rename a Task

**What to build:** Tapping a Task's row, Complete or not, opens the same composer in edit mode (spec stories 22–23). The field holds the Task's name, and the chip shows its Day. The chip is display-only: the Day can't be changed in v1. Saving with ▶ or Return renames the Task and closes the composer. The keyboard still comes up with no delay.

**Blocked by:** 04: The 100-Day schedule and per-Day add

**Status:** ready-for-agent

- [ ] Tapping a row (not its circle) opens the composer prefilled with the Task's name and its Day chip. The field is focused with no delay.
- [ ] ▶ is disabled while the trimmed name is empty. Saving trims the name, renames the Task and closes the composer.
- [ ] The renamed Task keeps its Day, its position and its Complete state.
- [ ] Dismissing without saving (tap outside, swipe down) leaves the Task unchanged. The confirmation for unsaved changes comes in 09.
- [ ] The view model applies the Domain name rule, then calls the repository directly (per the use-case rule).
- [ ] Data test: a rename is persisted, and other fields are untouched.
- [ ] `scripts/check.sh` passes. Verified on the iOS 18 simulator.
