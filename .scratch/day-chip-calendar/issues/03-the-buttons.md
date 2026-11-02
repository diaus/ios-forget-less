# 03: Today, Tomorrow and the weekday after

**What to build:** Three buttons under the calendar's month (spec stories 29–31).

- **Labels:**
  - "Today" (`.dayToday`);
  - "Tomorrow" (`.dayTomorrow`);
  - the weekday of Today + 2, from `weekday(capitalizationContext: .beginningOfSentence)`, the same as the chip's weekday label ("Wednesday").
  
  No new catalog keys.
- **Look:**
  - Capsules on the chip's fill (`.fill.tertiary`), each label in its Day's chip colour (`dayChipColor(today:)`).
  - Equal width, in one row.
  - No extra highlight for the chip's Day.
- **Action:** exactly a tap on that Day, through the same view-model call, including the 0.15 s chosen circle when the month shown holds that Day, and the close.
- **The state** gives the buttons' Days: Today, Tomorrow and Today + 2.

**Blocked by:** 02: The Day chip calendar

**Status:** ready-for-agent

- [ ] State tests: the buttons' Days are Today, Tomorrow and Today + 2, including across a month's end and a year's end.
- [ ] The UI check on iOS 27, on a 6.9″ iPhone, confirms:
  - the three labels, with the third one Today + 2's weekday;
  - each label in its chip colour;
  - each button sets the chip, or Moves the Task being edited, as a tap on its Day does;
  - the button for the chip's own Day only closes;
  - the buttons work while a month other than Today's is shown.
- [ ] Ukrainian labels checked on screen.
- [ ] `build_sim`, `test_sim` and `scripts/check.sh` pass.
