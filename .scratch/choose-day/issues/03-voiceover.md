# 03: VoiceOver for choosing a Day

**What to build:** VoiceOver support for the calendar action and the Day picker (spec stories 30–33).

- **The swipe action** appears under VoiceOver's Actions as "Choose Day". UIKit offers swipe actions as custom actions, so check that it shows up and add nothing unless it doesn't.
- **Each Day in the sheet:**
  - one button labelled with its full date, for example "Friday, 1 January 2027", formatted in GMT;
  - its Incomplete Task count as its value, using the plural key from ticket 02;
  - Days before Today read as dimmed (`.isNotEnabled`), and the chosen Day reads as selected (`.isSelected`).
- **Blank cells** before a month's first Day are hidden from VoiceOver.
- **Month headers** are headings, so the rotor can move by month.
- **After Done** moves the Task, VoiceOver announces its new Day in `moveAnnouncingDay`'s wording ("Tomorrow", "3 Dec").

**Blocked by:** 02: Choose a Day from the swipe action

**Status:** ready-for-agent

- [ ] The UI check on iOS 27, with the accessibility tree read back (`snapshot_ui`), confirms:
  - "Choose Day" is among the row's actions;
  - each Day's label, value and traits;
  - blank cells are absent;
  - month headers are headings.
- [ ] Done's announcement gives the new Day, checked in the console or the accessibility notification log, or reported as skipped if the simulator can't show it.
- [ ] Any new catalog key has `en` and `uk`, added with `scripts/xcstrings.py`.
- [ ] `build_sim`, `test_sim` and `scripts/check.sh` pass.
