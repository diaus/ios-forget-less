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

**Status:** resolved

- [x] The UI check on iOS 27, with the accessibility tree read back (`snapshot_ui`), confirms:
  - "Choose Day" is among the row's actions;
  - each Day's label, value and traits;
  - blank cells are absent;
  - month headers are headings.
- [x] Done's announcement gives the new Day, checked in the console or the accessibility notification log, or reported as skipped if the simulator can't show it.
- [x] Any new catalog key has `en` and `uk`, added with `scripts/xcstrings.py`.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.

## Comments

- **Swipe action:** nothing added. `axe describe-ui` lists `Delete` and `Choose Day` among each row's custom actions, Overdue rows included.
- **Day cells:** `snapshot_ui` and `axe describe-ui` read each Day as a button labelled with its full date ("Monday, 2 November 2026") and valued with its count ("1 task", "2 tasks", "No tasks"). Neither tool reports `isSelected`, so the traits were read with `lldb` attached from the shell (Xcode's `RunProject` needs the user's approval to open a workspace): the chosen Day is 9 (button, selected), a Day before Today 257 (button, not enabled), any other Day 1 (button).
- **Blank cells and headers:** November 2026 starts on a Sunday, so a Monday-first week has six blank cells before the 1st. The tree goes straight from the "November" heading (traits 65600: header, static text) to "Sunday, 1 November 2026", with no element between.
- **Full date:** `Date.fullDate` uses the `.complete` date style in GMT, so it follows the locale ("Friday, 1 January 2027" in en-GB) and always includes the year, unlike the summary line.
- **Announcement:** with a breakpoint on `UIAccessibilityPostNotification` for announcements (1008), Done after choosing Tomorrow posted "Tomorrow" at high priority. The check used a temporary Task written into the store; the store was restored from a backup afterwards.
- **Catalog:** no new key: the Day's value reuses `dayPicker.taskCount`.
