# Day Chip Calendar

Status: ready-for-agent

## Problem Statement

The composer's Day chip steps one Day per swipe. To add a Task to a Day a few weeks away, or Move the Task being edited there, the user swipes once for each Day. The Choose a Day sheet reaches any Day, but only from a row's swipe action, and opening a sheet would take the keyboard down mid-typing. The user wants to tap the chip and pick a Day from a month without losing their place in the composer.

## Solution

A tap on the Day chip opens the **Day chip calendar**: a card over the composer, its bottom in line with the composer's, that shows one month at a time in five week rows, with the Days of the months either side filling the rows. A sideways swipe pages between months. Tapping a Day sets the chip to it and closes the card, which Moves the Task being edited at once, as a step does. Under the month are three buttons: Today, Tomorrow, and the weekday after Tomorrow (for example "Wednesday"). The keyboard stays up. A ✕ in the card's corner, or a tap anywhere outside the card, closes only the card.

## User Stories

### Opening and closing

1. As a user, I want a tap on the Day chip to open the calendar, so that I can reach a Day further away than a few swipes.
2. As a user, I want a sideways swipe on the chip to keep stepping one Day while the calendar is closed, so that the next Day or two stay one swipe away.
3. As a user, I want the keyboard to stay up and the name field to keep focus when the calendar opens, so that I can carry on typing.
4. As a user, I want the calendar to grow out of the chip (scale and fade, anchored at its bottom-leading corner) and shrink back into it when it closes, so that I can see where it came from.
5. As a user, I want the calendar's bottom edge in line with the composer's, right above the keyboard, and its leading edge in line with the composer's, covering the composer, so that it has the most height for its month.
6. As a user, I want the calendar as wide as the composer, but no wider than about 400 pt, so that its Days never turn into huge, sparse cells on an iPad or in landscape.
7. As a user, I want the calendar drawn on the composer's background, with a soft shadow, so that it reads as lifted above the composer it covers.
8. As a user, I want a tap anywhere outside the calendar (the backdrop, the list, or any part of the composer the calendar doesn't cover) to close only the calendar and do nothing else, so that closing it never changes anything underneath.
9. As a user, I want a ✕ at the calendar's top-trailing corner that closes only the calendar, with the keyboard staying up, so that I can close it without reaching for a spot outside it. While the calendar is open it covers the chip, so the chip's Day never changes under an open calendar.
10. As a user, I want typing in the name field to close the calendar, so that I can go straight back to typing.
11. As a user, I want submitting from the keyboard to close the calendar and then submit as usual, so that ▶ works the same with the calendar open.
12. As a user, I want dragging the composer down to close both the calendar and the composer, so that the dismiss gesture still works.

### The month

13. As a user, I want a header with the month's name, with the year only outside the current year ("November", "January 2027", by the same rule as the sheet's month headers), then the weekday row starting on my locale's first weekday, so that I can read the month at a glance.
14. As a user, I want every month drawn with 5 week rows, starting with the week that holds its 1st, so that the calendar's height and its buttons don't jump from one month to the next. A month that runs into a 6th week loses that row's Days (at most 2) here; they open the next month's first row.
15. As a user, I want each Day drawn as in the Choose a Day sheet (Days before Today dimmed and not tappable, Today's number in the accent colour, a dot under a Day with an Incomplete Task, weekends like every other Day), so that both calendars read the same.
15a. As a user, I want the cells before the 1st and after the last Day filled with the Days of the months either side, tappable like any Day, with an ordinary Day's number in blue (dark blue in light mode, light blue in dark mode), so that I can reach those Days without paging and still tell which month I'm on. A Day from another month before Today stays dimmed as any past Day; Today keeps its accent number, the chip's Day its chosen circle, and a Day with an Incomplete Task its dot.
16. As a user, I want the chip's Day drawn chosen (a filled accent circle with a white number and a white dot), wherever it shows, a neighbouring month's row included, so that I can see where the Task is now.
17. As a user, I want the calendar to open on the month of the chip's Day, so that I start from where the Task is.
18. As a user editing an Overdue Task, I want the calendar to open on Today's month with nothing chosen, so that I never open on a month where nothing can be chosen.

### Paging

19. As a user, I want to swipe left for the next month and right for the previous one, with the month following my finger, so that it pages like a calendar.
20. As a user, I want to page forward with no limit, so that I can plan as far ahead as I like.
21. As a user, I want swiping right on Today's month to bounce back with the chip's rigid haptic, so that I know there's nothing earlier to plan.

### Choosing

22. As a user, I want a tap on a Day, one from a neighbouring month included, to give a selection haptic, show the chosen circle on it for about 0.15 s, then close the calendar and set the chip to that Day, so that I see what I picked.
23. As a user adding Tasks, I want the chosen Day to be where the next Tasks I add go, so that I can add several to a far Day.
24. As a user editing a Task, I want choosing a Day to Move the Task to the end of that Day and save at once, as stepping the chip does, so that every way of picking a Day lands the Task in the same place.
25. As a user, I want choosing the chip's own Day to only close the calendar, so that confirming where a Task already is doesn't reorder it.
26. As a user, I want a Day chosen from the calendar to count as a step, so that closing the composer brings that Day into view, as after stepping.
27. As a user, I want moving never to make a Task Complete or Incomplete, so that moving and completing stay separate.
28. As a user, I want a failed save to put the chip and the Task back and show the error alert, as for a step, so that the list always matches the store.

### The buttons

29. As a user, I want three buttons under the month: "Today", "Tomorrow" and the weekday after Tomorrow ("Wednesday"), so that the nearest Days are one tap away on any month.
30. As a user, I want them drawn like the chip (a capsule on the same fill, with each Day's chip colour), equal width in one row, so that they read as quick Day chips.
31. As a user, I want a button to work exactly as tapping its Day does, so that there's one rule to learn.

### Fitting

32. As a user on a smaller screen, I want the calendar to make room for itself in the space from the top of the screen to the composer's bottom, in this order, so that it always fits:
    1. the full calendar: rows the sheet's height (about 50 pt) and the buttons;
    2. the buttons hidden;
    3. the rows shrunk toward about 36 pt;
    4. the keyboard hidden, then the same steps from 1 again in the space that frees;
    5. all the height there is, the rows and the Day numbers shrinking further, with nothing scrolling inside the calendar.
33. As a user, I want the calendar to refit live while it's open (for example when I switch to the emoji keyboard), so that it always fits the space as it is now.
34. As a user, I want the keyboard, once the calendar has hidden it, to stay down until the calendar closes, so that the calendar never bounces as it refits.
35. As a user, I want the name field to get focus again when a calendar that hid the keyboard closes, unless the composer is closing too, so that my place in the composer is kept.

### Midnight

36. As a user, I want the calendar to update if Today rolls over while it's open: the new past Day dims, the chip's Day stops being drawn chosen if it's now past, and if Today's month changes, the earliest month I can page back to moves forward with it, so that I can't plan a Task in the past even at midnight.

### VoiceOver

37. As a VoiceOver user, I want a double-tap on the chip to open the calendar, while swiping up or down on the chip still steps its Day, so that both ways of choosing a Day are reachable.
38. As a VoiceOver user, I want focus to move into the calendar when it opens and stay in it, so that I don't wander into the composer behind it.
39. As a VoiceOver user, I want the month header to be adjustable (swiping up or down changes month) and read as a heading, so that I can page without a sideways swipe.
40. As a VoiceOver user, I want each Day, one from a neighbouring month included, read as in the Choose a Day sheet: a button labelled with its full date, its Incomplete Task count as its value, dimmed before Today, selected on the chip's Day, so that I hear the same state everyone else sees.
41. As a VoiceOver user, I want the escape gesture (a two-finger scrub) to close only the calendar, so that the composer stays open.
42. As a VoiceOver user editing a Task, I want its new Day announced after the Move is saved ("Tomorrow", "3 Dec"), as after Done in the Choose a Day sheet, so that I know where it went.

## Implementation Decisions

### Domain

- **A month at an offset.** The calendar pages without a limit, so it can't take a month count up front as `DayPickerCalendar(today:monthCount:firstWeekday:)` does. Domain gains a way to build one month at an offset from Today's month (offset 0 is Today's month), and the weekday header without any month.
  - Shape it as a public `DayPickerCalendar.Month` initialiser, or a static function beside it, and build `DayPickerCalendar.init` on it, so the sheet's months and the calendar's months are built by the same code.
  - Every Day is a GMT midnight. Any calendar arithmetic stays in Domain's `Date` Day extensions (ADR 0001, the `calendar_outside_day_extensions` lint rule).
- **Five weeks.** A month's `weeks` has 4 to 6 rows, with `nil` for the cells outside the month, and the Choose a Day sheet keeps using it. Domain gains a grid of a given number of weeks in which every cell is a Day (for example `Month.weeks(count:) -> [[Date]]`): it starts on the first Day of the week that holds the month's 1st and runs on consecutive Days, so the cells before the 1st are the previous month's last Days and those after the last Day the next month's first. The calendar asks it for 5.
- **Moving reuses what exists.** Choosing a Day while editing is the same Move as a step: `Schedule.canMove(_:toDay:)`, `[TodoTask].destinationAtEnd(of:forTaskWithID:)`, `move(id:to:)`. `canMove(_:toDay:)` accepts any Day from Today onward, so the missing forward limit needs nothing new. No new repository call, and no use case.

### App

- **Folder.** The calendar is part of the composer: `Features/Composer/DayChipCalendar/`, holding its view, its state type, its fitting type and any subviews. Tests mirror it in `ForgetLessTests/Features/Composer/DayChipCalendar/`.
- **The Day cell is shared.** `DayPickerDayView` reads `vm.dayPicker` for whether its Day is chosen, can be chosen and is Today, and calls `vm.dayPicker?.choose`. It takes these as parameters instead (chosen, can be chosen, Today, the count, and an action), and moves to a shared place both calendars can reach (for example `Shared/Views/`). Its size comes from its caller, so the calendar can shrink it. Rename it if a name fits both better, never a broad one-word type.
- **A Day from another month.** The cell also learns whether its Day is in the month shown. Its number's colour, in order: `.tertiary` when it can't be chosen, white when chosen, the accent for Today, a new colour asset `DayPickerOtherMonthDay` (`#0068A8` light, `#64D2FF` dark, the values of `DayChipWeekday` under a name of its own) for a Day from another month, `.primary` otherwise. The sheet always passes "in the month".
- **The state is a small value type**, like `ComposerState` and `DayPickerState`, tested in the app's tests (for example `DayChipCalendarState`). It holds Today, the chip's Day, the month shown (as an offset from Today's month) and whether it hid the keyboard. Its rules:
  - it opens on the chip's Day's month, or on Today's month when the chip's Day is before Today;
  - the chip's Day is the chosen Day only when it can be planned;
  - a Day before Today can't be chosen;
  - the three buttons' Days are Today, Tomorrow and Today + 2;
  - it can't page before offset 0;
  - a new Today moves offset 0 to its month and moves a month shown before it forward.
- **The view model** owns the calendar's state next to `composer`, so `dismissComposer` can end it. Choosing a Day goes through one view-model call shared with `stepComposerDay`:
  - while adding, `composer.step(to:)`;
  - while editing, the step's checked, immediate, rolled-back-on-failure Move, plus `dayAnnouncement` once saved;
  - on the chip's own Day, nothing.
  Stepping and choosing then differ only in how the Day is picked.
- **Where it's drawn.** The calendar needs the space above the composer, so `ScheduleView` draws it in an overlay above `ComposerView`, placed from the composer's frame (an anchor preference), not inside the composer's padded `VStack`: its bottom in line with the composer's bottom, its leading edge with the composer's. It still grows from the chip, anchored bottom-leading. Under the calendar and above everything else, a clear layer takes every touch while the calendar is open: a tap closes the calendar, and a mostly-down drag that starts over the composer (where it shows past the calendar) dismisses the composer, as `ComposerView.dismissDrag` does. Keyboard input isn't hit-tested, so typing still reaches the name field.
- **The ✕** sits at the card's top-trailing corner, on the month name's line, outside the paging months so it doesn't page. It closes only the calendar; the keyboard stays up. On iOS 26+ it's `Button(role: .close)`; on iOS 18 an `xmark` in a small circle on `.fill.tertiary`, labelled "Close" (a new catalog key through `scripts/xcstrings.py` only if the system's own label can't be reused).
- **The chip** gains a tap that toggles the calendar, next to its swipe (`simultaneousGesture(dayStepSwipe)`). While the calendar is open it covers the chip, and the clear layer covers anything of it that shows, so a swipe there only closes the calendar.
- **Typing closes it.** A change to `composer.taskName` while the calendar is open closes the calendar. Submitting closes the calendar before `submitComposer()`.
- **Paging** is a horizontal `ScrollView` with `.scrollTargetBehavior(.paging)` over a lazy row of months identified by offset, starting at 0 and growing forward in chunks as the user nears the end, as `TinyReminder/Calendar/CalendarPagerView.swift` does vertically (without its backward growth). It opens on the state's month with no animation. The scroll view's own rubber band at offset 0 is the nudge. A swipe that tries to go before offset 0 gives the chip's rigid impact haptic (`.impact(flexibility: .rigid, intensity: 0.5)`), once per swipe.
- **Fitting is a pure function**, tested in the app's tests (for example `DayChipCalendarLayout`). It takes the height available from the top safe area to the composer's bottom, the measured heights of the header and the button row, the padding, and whether the keyboard is up. It gives the row height, whether the buttons show, and whether the keyboard must go down, following story 32. The view measures the header and the buttons at the current Dynamic Type size and refits whenever the available height changes. When the function says the keyboard must go down, the view drops the name field's focus and records it in the state. Closing the calendar gives focus back, unless the composer is closing too.
- **The cell's numbers** shrink with the row (for example `minimumScaleFactor`), so step 5 still shows every Day.
- **Choosing's 0.15 s.** The tapped Day is drawn chosen at once, and the calendar closes about 0.15 s later. The Move and the chip's change happen at the tap, so a second tap in that window is ignored.
- **Width.** `min(composer width, about 400 pt)`, leading-aligned with the composer.
- **Strings.** The buttons reuse `.dayToday`, `.dayTomorrow` and `weekday(capitalizationContext: .beginningOfSentence)`. The month header reuses `monthName(today:)`. Any new key (for example a VoiceOver hint) is added with `scripts/xcstrings.py`.
- **VoiceOver.** The calendar is a modal container (`.isModal`) with an escape action that closes only it. The month header is a heading with an adjustable action that pages. The chip's default activation toggles the calendar, and its adjustable action still steps.

## Testing Decisions

Tests check behaviour through a public interface. Tests pass `today` explicitly, and Days are GMT midnights. Swift Testing only.

- **Domain** (prior art: `DayPickerCalendarTests`):
  - offset 0 is Today's month;
  - an offset into the next year;
  - blank cells and Day counts at an offset match the same month built by `DayPickerCalendar(today:monthCount:)`;
  - the weekday header's order for a Monday start and a Sunday start, without building any month;
  - a 5-week grid starts on the first Day of the week holding the 1st and runs on consecutive Days;
  - a month that spans 6 weeks loses its last row's Days from its 5-week grid, and they open the next month's grid;
  - a February that spans 4 weeks gets March's first week as its 5th row.
- **App: the state** (prior art: `DayPickerStateTests`, `ComposerStateTests`):
  - it opens on the chip's Day's month, with that Day chosen;
  - with the chip on a Day before Today, it opens on Today's month with nothing chosen;
  - a Day before Today can't be chosen;
  - the buttons' Days are Today, Tomorrow and Today + 2, including across a month's end;
  - it can't page before Today's month;
  - a new Today in the next month moves the earliest month forward, and moves a month shown before it.
- **App: fitting:** one test per step of story 32, plus:
  - with the keyboard down, steps 1–3 apply again;
  - the row height never goes below what fits in step 5.
- **App: the composer:** choosing a Day sets `hasSteppedDay`, so `revealsDayOnDismiss` holds as after a step.
- **No view-model, UI or snapshot tests**, as before. The UI check (`docs/agents/ui-check.md`) on iOS 27 covers the calendar.

## Out of Scope

- Any change to the Choose a Day sheet, besides sharing its Day cell: it keeps its 4 to 6 rows per month, with blank cells outside each month.
- Months before Today's month.
- A summary line ("Fri 6 Nov · 1 task") or chevron buttons in the calendar.
- Paging to a neighbouring month when one of its Days is tapped: the tap chooses the Day.
- Opening the calendar from anywhere but the composer's Day chip.
- Undo.

## Further Notes

- Vocabulary: choosing a Day while editing is a **Move** (`GLOSSARY.md`). "The weekday after Tomorrow" is Today + 2, not a glossary term. The glossary gains no terms, and there's no ADR: the calendar is a view, easy to change later.
- The Choose a Day spec's Out of Scope listed "Opening the sheet from the composer's Day chip". It now points here.
- Issues, in order: `issues/01` a month at an offset in Domain, `02` the calendar, `06` five weeks and the card over the composer, `03` the buttons, `04` fitting, `05` VoiceOver. `06` came after `02` was built: the calendar first sat above the chip with 6 rows and blank cells, then moved over the composer for the height, with a ✕ to close it.
