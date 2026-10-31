# 05: VoiceOver "Move Up" and "Move Down"

**What to build:** Moving without dragging, for VoiceOver users (spec stories 32–40).

- The handle is hidden from VoiceOver.
- While Move Tasks is on, the row's circle element gets the named actions "Move Up" and "Move Down", beside Rename. Each is present only when `Schedule`'s step for that direction returns a Place.
- An action writes `move(id:to:)` with that Place, the same way a drop does, then announces the Task's new Day in the header's relative wording or short date.

**Blocked by:** 04: Move Tasks

**Status:** ready-for-agent

- [ ] The UI check on iOS 27, using `snapshot_ui` to read and invoke the actions, confirms:
  - a step within a Day;
  - "Move Down" from the last Task of Today onto Tomorrow;
  - "Move Up" from the first Task of Tomorrow onto Today;
  - an Overdue Task offers only "Move Down", which puts it first on Today;
  - the first Task of Today offers no "Move Up";
  - with Move Tasks off, no move actions are offered.
- [ ] The announcement names the new Day. If the simulator can't confirm the announcement, mark this box as skipped and say so.
- [ ] Both catalog keys have `en` and `uk`, added with `scripts/xcstrings.py`.
- [ ] `build_sim`, `test_sim` and `scripts/check.sh` pass.
