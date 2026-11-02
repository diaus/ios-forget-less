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

**Blocked by:** 06: Five weeks, and the card over the composer

**Status:** resolved

- [x] State tests: the buttons' Days are Today, Tomorrow and Today + 2, including across a month's end and a year's end.
- [x] The UI check on iOS 27, on a 6.9″ iPhone, confirms:
  - the three labels, with the third one Today + 2's weekday;
  - each label in its chip colour;
  - each button sets the chip, or Moves the Task being edited, as a tap on its Day does;
  - the button for the chip's own Day only closes;
  - the buttons work while a month other than Today's is shown.
- [x] Ukrainian labels checked on screen.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.

## Comments

- The UI check ran on an iPhone 18 Pro Max, iOS 27.2, in light mode. Tomorrow while adding drew 3 Nov chosen for about 0.2 s (from a screen recording's frames), then closed with the chip on Tomorrow. Wednesday and Tomorrow tapped with December shown set the chip, and while editing Moved the Task to the end of that Day. Today on the chip's own Day only closed, and the Task kept its place.
- The labels come from `dayChipLabel(today:)`, which gives `.dayToday`, `.dayTomorrow` and the weekday for Today + 2, so they always match the chip's label for those Days.
- The buttons sit under the paging months, not on a page, so they stay put while the months page.
- They take the chip's look exactly, vertical padding included (26 pt tall on iPhone). A review noted the chip and the buttons repeat the same font, padding and fill; a shared modifier was left out, as the chip's label sits in a container of its own for its step transition.
