# Choose a Day

Status: resolved

## Problem Statement

A Task can be Moved to another Day in two ways. The user can drag it by its handle to a Day on screen, or step the composer's Day chip one Day at a time. Both are slow for a Day weeks or months away: the drag has to auto-scroll the whole way there, and the chip has to be swiped once for each Day. A Day after the 100-Day window can't be reached by drag at all unless it already has Tasks. The user wants to go straight to a Day on a calendar.

## Solution

Every listed Task gets a second swipe action: a blue `calendar` button inside Delete. It opens a sheet with a calendar that scrolls through months. Tapping a Day chooses it, and Done Moves the Task to the end of that Day (see **Move** in `GLOSSARY.md`). The sheet looks like the design screenshot: Cancel and Done, a pinned weekday row and summary line, then the months. It has no title and no chevron button, and weekends aren't dimmed.

## User Stories

### Opening the sheet

1. As a user, I want a `calendar` swipe action on every listed Task, Incomplete, Complete or Overdue, so that I can replan any Task.
2. As a user, I want it inside Delete, with Delete still on the outer edge and the calendar action on a blue background, so that it's easy to tell apart from Delete.
3. As a user, I want the calendar action whether Move Tasks is on or off, so that it works like the composer's Day chip, which is a deliberate choice and never changes the list by accident.
4. As a user, I want the sheet to open at full height and to be draggable down to medium, so that I see more months at once and can still bring the list back into view when I need it.
5. As a user, I want the sheet to open centred on the Task's own Day, already chosen, so that I start from where the Task is.
6. As a user moving an Overdue Task, I want nothing chosen at first, and Done disabled until I tap a Day, so that I make a real choice instead of confirming a Day I can't use.

### The sheet

7. As a user, I want Cancel on the leading edge and Done on the trailing edge, both in the accent tint and with no title between them, so that the sheet stays plain.
8. As a user, I want a weekday row starting on my locale's first weekday, pinned at the top, so that I can read the columns while I scroll.
9. As a user, I want a summary line under the weekday row, also pinned, giving the chosen Day and how many Incomplete Tasks it has ("Fri 6 Nov · 1 task", "Fri 1 Jan 2027 · No tasks"), so that I know what's planned there before I commit.
10. As a user, I want the summary line to read "Choose a Day" while nothing is chosen, so that I know why Done is disabled.
11. As a user, I want the summary line to show the year only when the Day isn't in the current year, by the same rule as the Schedule's headers, so that dates read the same everywhere.
12. As a user, I want the Task I'm moving counted on the Day it's on now, so that the calendar agrees with the list behind it.
13. As a user, I want the months to run from the current month to about five years ahead, each with a header ("November", "January 2027") that shows the year only outside the current year, so that I can plan far ahead.
14. As a user, I want Days before Today dimmed and not tappable, so that I can't plan a Task in the past.
15. As a user, I want weekends drawn like every other Day, so that no Day looks less available.
16. As a user, I want a dot under every Day that has an Incomplete Task, in secondary grey, turning white on the chosen Day, so that I can see which Days are busy.
17. As a user, I want Today's number in the accent colour, turning white once Today is chosen, so that I can find Today.
18. As a user, I want the chosen Day drawn as a filled accent circle, so that my choice is clear.

### Choosing

19. As a user, I want a tap on a Day to choose it, with a selection haptic, and to save nothing yet, so that I can change my mind.
20. As a user, I want a tap on the chosen Day to keep it chosen, so that a second tap never clears my choice.
21. As a user, I want Cancel, or swiping the sheet down, to close it without asking, so that backing out is quick when there's nothing typed to lose.
22. As a user, I want the sheet to update if Today rolls over while it's open: the new past Day dims, and if it was the chosen Day, the choice clears and Done is disabled, so that I can't plan a Task in the past even at midnight.

### Done

23. As a user, I want Done to Move the Task to the end of the chosen Day, as stepping the composer's Day chip does, so that both ways of picking a Day land the Task in the same place.
24. As a user, I want Done on the Task's own Day to do nothing, so that confirming the Day it already has doesn't reorder it.
25. As a user, I want the list to stay where it is after Done, so that I don't lose my place in the part of the list I was tidying.
26. As a user, I want moving never to make a Task Complete or Incomplete, so that moving and completing stay separate.
27. As a user who has hidden Complete Tasks, I want a Complete Task I opened the sheet on to stay listed while the sheet is open, and to get a fresh grace period when it closes, so that it doesn't disappear while I'm moving it.
28. As a user, I want a failed save to put the Task back and show the error alert, as for any other move, so that the list always matches the store.
29. As a user, I want the Lock Screen widget to show the Task in its new place, so that it agrees with the app.

### VoiceOver

30. As a VoiceOver user, I want the calendar swipe action offered under Actions as "Choose Day", so that I can open the sheet without swiping.
31. As a VoiceOver user, I want each Day in the sheet read as a button labelled with its full date ("Friday, 1 January 2027"), with its Incomplete Task count as its value, so that I know which Day I'm on and how busy it is.
32. As a VoiceOver user, I want Days before Today read as dimmed and the chosen Day read as selected, so that I hear the same state everyone else sees.
33. As a VoiceOver user, I want the Task's new Day announced after Done ("Tomorrow", "3 Dec"), as for the Move Up and Move Down actions, so that I know where the Task went.

### From the composer's Day chip

34. As a user, I want a long press (about 0.35 s) on the composer's Day chip to open the sheet, with a haptic as it's recognised, so that I can see several months at once while a tap still opens the Day chip calendar.
35. As a user, I want a finger that moves sideways before the press is recognised to step the Day as now, so that the swipe keeps working.
36. As a user, I want the sheet to open on the chip's Day, already chosen, or with nothing chosen when I'm editing an Overdue Task, as from a row.
37. As a user adding Tasks, I want Done to set the chip to the chosen Day, so that the next Tasks I add go there.
38. As a user editing a Task, I want Done to Move it to the end of the chosen Day and save at once, as stepping the chip does, and to do nothing on its own Day.
39. As a user, I want Done to count as a step, so that closing the composer brings that Day into view, and Cancel or a swipe down to change nothing.
40. As a user, I want the keyboard to go down while the sheet is open and the name field to get focus back when it closes, so that I can carry on typing.
41. As a VoiceOver user, I want a "Choose Day" action on the chip that opens the sheet, so that the long press has a VoiceOver equivalent.

## Implementation Decisions

### Domain

- **Moving reuses what exists.** Done is a Move to the end of a Day, which is the same move as stepping the composer's Day chip:
  - `Schedule.canMove(_:toDay:)` checks it;
  - `[TodoTask].destinationAtEnd(of:forTaskWithID:)` gives the `MoveDestination`;
  - `move(id:to:)` saves it.
  
  No new repository call, and no use case (`CODING_STANDARDS.md`'s use-case rule).
- **The months are a read model**, computed by a pure function in Domain because laying out months needs the calendar, which is read only in Domain's Day extensions (ADR 0001, the `calendar_outside_day_extensions` lint rule).
  - It takes `today`, the number of months, and `firstWeekday`. It gives the 7 weekdays of the header in order, and for each month its first Day, how many blank cells come before that Day in its week, and its Days.
  - Every Day is a GMT midnight, as everywhere else.
  - Name it for what it is, never a broad one-word type (for example `DayPickerCalendar`, not `Calendar` or `Month`).
- **Incomplete Task counts by Day** come from a pure function over the Tasks, tested in Domain. Its input is the view model's last Tasks: they come from `scheduleTasks(today:)` and hold every Task from Today onward, Complete ones included, whether or not Complete Tasks are hidden.

### App

- **The swipe action.**
  - `ScheduleListController.swipeActions(at:)` returns the calendar action after Delete, so Delete stays the outermost.
  - The action uses the `calendar` symbol on `.systemBlue`. It has no title, and its image's accessibility label comes from a new catalog key, "Choose Day".
  - It calls the view model, which the controller already injects.
- **The sheet's state** lives on `ScheduleViewModel`: the Task being moved, the chosen Day (or `nil`) and whether the sheet shows. `ScheduleView` presents the sheet from it with `.sheet` and `.presentationDetents([.medium, .large], selection:)`, each opening starting at large.
- **The choice rules are a small value type** next to the sheet, like `ComposerState`, tested in the app's tests:
  - it opens on the Task's Day, or with nothing chosen for an Overdue Task;
  - choosing a Day before Today is refused;
  - a new Today clears a chosen Day that is now before it;
  - the Day to move to is `nil` when nothing is chosen and when the chosen Day is the Task's own Day.
- **Done** asks for that Day. If there is none, it only closes. Otherwise the view model checks `canMove(_:toDay:)`, moves the Task at once in its own Tasks, and saves, as `stepComposerDay` does, announcing the new Day once it's saved (`moveAnnouncingDay`'s wording). A failed save puts back the Tasks last observed and shows the error alert.
- **Keeping the Task listed.** While the sheet is open, `rebuildSchedule` adds the Task's ID to the listed IDs, as it does for the composer's edited Task. Closing the sheet gives a Complete Task a fresh grace period while Complete Tasks are hidden, as `dismissComposer` does.
- **The calendar view** is SwiftUI: a lazy vertical stack of months in a scroll view, with the weekday row and the summary line pinned above it. It opens scrolled so the chosen Day is centred, or Today when nothing is chosen. It is not `UICalendarView` or `DatePicker(.graphical)`, which page one month at a time and can't show the summary line or the dots.
- **Done's label.** SwiftLint's glossary rule forbids "Done" as a whole camelCase segment of an identifier or generated catalog symbol. The catalog key for the button must avoid it, for example `dayPicker.confirm`, with the values "Done" / "Готово".
- **Strings.** The new strings are "Choose Day", "Choose a Day", "Cancel" (reuse the existing key if there is one), "Done" and the Task count. Add them with `scripts/xcstrings.py`.
  - The Task count needs plural forms: English one/other, Ukrainian one/few/many/other, and a zero form ("No tasks").
  - `scripts/xcstrings.py` writes only plain string units, so it gains a way to set plural variations, and `check` accepts them.
- **Formatting.**
  - The summary line's Day reuses the short-date year rule (`shortDate(today:)`) with the weekday in front.
  - Month headers use the same year rule.
  - Days are formatted in GMT, as everywhere.
- **Folder.** The sheet is a part of the Schedule screen, so it goes in `Features/Schedule/DayPicker/`: its view, its state type, and any subviews. Its tests mirror that path. The composer's Day chip should be able to reuse it later without changes, but no reuse is built now.

## Testing Decisions

Tests check behaviour through a public interface. Tests pass `today` explicitly, and Days are GMT midnights. Swift Testing only.

- **Domain** (prior art: `ScheduleTests+WeeksAndMonths`, `DateDayTests`):
  - **The months:**
    - the first month is Today's month, and the number of months is the number asked for;
    - the blank cells before the first Day follow `firstWeekday` (Monday and Sunday starts);
    - the number of Days in each month, including February in a leap year;
    - the run crosses a year boundary;
    - the weekday header's order follows `firstWeekday`.
  - **The counts:**
    - only Incomplete Tasks count;
    - Tasks are counted on their own Day;
    - a Day with only Complete Tasks has none.
- **App** (prior art: `ComposerStateTests`):
  - **The choice rules:**
    - it opens on the Task's Day;
    - an Overdue Task opens with nothing chosen;
    - a Day before Today is refused;
    - a new Today clears a chosen Day before it and keeps one on or after it;
    - there is no Day to move to while nothing is chosen, or when the chosen Day is the Task's own Day.
- **No view-model, UI or snapshot tests**, as before. The UI check (`docs/agents/ui-check.md`) on iOS 27 covers the sheet.

## Out of Scope

- Choosing a Day for several Tasks at once.
- Undo.
- Any change to dragging, the Move Up and Move Down actions, or the composer's Day chip besides its long press (stories 34–41). A tap on the chip opens its own calendar: see `.scratch/day-chip-calendar/spec.md`.
- A sheet title, the chevron button from the screenshot, and dimmed weekends.

## Further Notes

- Vocabulary: this is a **Move** (`GLOSSARY.md`). The glossary gains no terms. No ADR either: the custom calendar view is easy to change later.
- The move-tasks spec's Out of Scope listed "A date picker". It now points here.
- Issues, in order: `issues/01` the months and counts in Domain, `02` choosing a Day from the swipe action, `03` VoiceOver, `04` opening the sheet from the composer's Day chip (stories 34–41; added after 01–03 were built, once the chip's tap had gone to the Day chip calendar).
