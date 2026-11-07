# History

Status: ready-for-agent

## Problem Statement

The Schedule only looks forward. Days before Today are gone from it, except for the Incomplete Tasks gathered in Overdue. The user can't look back at what they did on a past Day. They can't record a Task they did yesterday on yesterday. They can't put a Task back on a past Day, for example to undo a Move or to make it Overdue on purpose so it waits in Overdue. Every Day picker refuses Days before Today, and nothing lands in Overdue.

## Solution

A new quick setting, **History** (see `GLOSSARY.md`), switches how the Schedule lists Days.

- With History on, the list has no Overdue section. It shows every Day before Today, empty ones included, each with all its Tasks, Complete or not. Scrolling up loads further back without limit.
- Everything works as it does outside History, except that any Day can be chosen. Tasks can be Moved and added onto past Days, where an Incomplete Task is Overdue at once and shows in Overdue once History is off.
- History is kept in memory only and is off at every launch.

## User Stories

### The button

1. As a user, I want a History button in the quick settings bar, so that I can look back at past Days in one tap.
2. As a user, I want it first in the bar, before Show Complete Tasks, Move Tasks and Settings, since it changes what the whole list shows.
3. As a user, I want its glyph to be `clock.arrow.circlepath` whether History is on or off, so that it reads as "the past".
4. As a user, I want its square filled with the primary colour and the glyph inverted while History is on, so that I can tell at a glance that the list is showing History. On iOS 26 and later the fill is the square's glass tinted with the primary colour; on iOS 18 it's a plain primary fill.
5. As a user, I want the change between on and off animated, as the other quick settings are.
6. As a user, I want History off every time the app launches, so that the app always opens on what's next.
7. As a user, I want History to stay on while the app is in the background, until the app is quit or the system ends it.

### Show Complete Tasks while History is on

8. As a user, I want the Show Complete Tasks button replaced by the Go to a Day button while History is on, since History always lists Complete Tasks (amended 2026-11-08; it was dimmed and disabled at first).
9. As a user, I want my Show Complete Tasks choice kept as it was, and working again once History is off.
10. As a user with Complete Tasks hidden, I want a Task I completed in History gone from the list as soon as History is off, with no grace period, since I've already seen it ticked off.

### What History lists

11. As a user, I want every Day before Today listed in History, each with all its Tasks, Complete and Incomplete, so that I see what each Day held.
12. As a user, I want empty past Days listed too, with their headers, so that the past reads as a calendar and I can drop or add a Task on any of them.
13. As a user, I want no Overdue section and no Move All in History, since Overdue Tasks are already on their own Days.
14. As a user, I want an Overdue Task in History to look like any Incomplete Task on its Day, with no extra marker. The unticked circle stands out among struck-through Tasks.
15. As a user, I want the Day before Today's header to read "Yesterday", for example "6 Nov · Yesterday · Friday", as Today's and Tomorrow's headers do.
16. As a user, I want week and month separators carried on into the past, as from Today on.
17. As a user, I want Today and the Days after it listed exactly as outside History, Complete Tasks included.
18. As a user, I want to scroll back without limit, with further past Days loading as I near the top. Nothing spins, and the rows on screen don't move while they load.

### Turning History on and off

19. As a user, I want turning History on to always scroll so that Yesterday's header is at the top of the list, with Today below it, so that I start at the most recent past.
20. As a user, I want turning History off to always scroll to the top of the list, Overdue or else Today, so that I'm back where normal mode starts.
21. As a user, I want both jumps instant, with no scrolling animation.
22. As a user, I want nothing to jump at midnight, in History or not. The old Today becomes Yesterday and the Day on screen stays where it is.

### Moving and adding in History

23. As a user, I want to drag a Task onto any listed Day in History, past ones included, so that I can put a Task back where it was or make it Overdue on purpose.
24. As a VoiceOver user, I want Move Up and Move Down to step across past Days in History, as they do across later Days.
25. As a user, I want the floating Day picker in History to open on the Task's Day's month with that Day chosen, even when it's past. Past Days aren't dimmed and can be chosen, and the picker pages back without limit.
26. As a user, I want the Choose a Day sheet in History to show past Days undimmed and let Done accept them.
27. As a user, I want the Today, Tomorrow and weekday buttons on the floating Day picker unchanged in History, with no Yesterday button, since Yesterday is one tap in the grid.
28. As a user, I want a "+" on every past Day's header in History, opening the composer on that Day, so that I can record a Task I did then and tick it off.
29. As a user, I want the composer's Day chip and its picker in History to step and choose past Days.
30. As a user, I want the red floating "+" to add to Today, in History as everywhere else.
31. As a user, I want a Task Moved or added onto a past Day to be Overdue there if it's Incomplete, and to show in Overdue once History is off.
32. As a user, I want a Task completed on Today and Moved onto a past Day to show struck through in Overdue once History is off, until Today rolls over, as any Task completed from Overdue does.
33. As a user, I want turning History off while the composer holds a past Day to keep that Day, so that saving adds an Overdue Task, since I chose that Day on purpose.
34. As a user, I want Day pickers opened outside History to refuse past Days as they do now.
35. As a VoiceOver user, I want a Move onto Yesterday announced as "moved to Yesterday", and onto an earlier Day with its short date.
36. As a user, I want completing, renaming and deleting to work in History as they do everywhere.

### VoiceOver

37. As a VoiceOver user, I want the History button read as a switch, "History", with its on/off value, as the other quick settings are.
38. As a VoiceOver user, I want the Go to a Day button in place of the Show Complete Tasks switch while History is on (amended 2026-11-08; the switch was read as dimmed at first).

### Widgets

39. As a user, I want the widgets unchanged: they never show the past, and they show Tasks I Moved in History in their new places, as after any Move.

### Go to a Day

40. As a user in History, I want a calendar button, `calendar.badge.clock`, in Show Complete Tasks's place in the quick settings bar, so that I can reach any Day without scrolling to it.
41. As a user, I want the button never filled, since it's a button, not a switch, and the swap between it and Show Complete Tasks animated with History turning on or off.
42. As a VoiceOver user, I want it read as a button, "Go to a Day".
43. As a user, I want it to open the Choose a Day sheet with the Day at the top of the screen chosen, so that the calendar shows where I am.
44. As a user, I want to choose any Day there, before Today or not, across the months the sheet offers in History.
45. As a user, I want the line under the calendar to show only the chosen Day's weekday and date, with no Task count, since I'm going there, not moving a Task.
46. As a user, I want Done to scroll the list, without animation, so the chosen Day's header is at the top, or as near as the end of the list allows.
47. As a user, I want Done with the Day it opened on still chosen, or Cancel, to leave the list where it is.
48. As a user, I want a Day further back than History has loaded to load and then be landed on, with room above it to keep scrolling back.
49. As a user, I want an empty Day after the 100 listed from Today, which the list doesn't show, to land on the closest listed Day before it.
50. As a VoiceOver user, I want focus on the header of the Day the list lands on, so that I hear where it went.
51. As a user, I want nothing to scroll at midnight while the sheet is open, and the chosen Day kept.

## Implementation Decisions

### Language

- **History** and **Yesterday** are in `GLOSSARY.md`. Identifiers, catalog keys and comments use them: for example `showsHistory`, `day.yesterday`, `schedule.history`. Avoid "archive", "past mode", "log" and "timeline". It's a Move, never a "reschedule".
- ADR 0006 records how History loads the past. It amends ADR 0002's stream and lifts ADR 0004's "nothing lands in Overdue" and `canBePlanned(today:)` while History is on.

### Domain

- **`Schedule` takes the History listing.** A new input, for example an optional first Day: `nil` lists as today, and a Day lists in History from that Day on. In History the Schedule:
  - lists one Day for every Day from the first Day through the window, empty ones included, followed by the later Days with Tasks;
  - lists Complete Tasks by `showsComplete` and `keptTaskIDs` as outside History; the Schedule's view model passes `showsComplete` on while History is on;
  - leaves `overdue` empty.
- **`Schedule` holds Today explicitly.** The move rules read Today today from `days.first`, which in History is the first Day, not Today.
- **The move rules accept past Days in History.** `canMove(_:to:)`, the drop rule, `canMoveToEnd(_:of:)` and Move Up/Down accept any listed Day. `canMoveOverdueTasks(toStartOf:)` is never reached in History, since there's no Overdue.
- **Choosing a Day takes the mode.** `canBePlanned(today:)` stays as is for outside History. The pickers and the composer get a rule (on the Day helpers, or a small value they share) that accepts any Day in History. Name it for what it decides. Never a broad one-word name (memory: specific type names).
- **`RelativeDay` gains `yesterday`.** `beforeToday` keeps the Days before it. The widget's `UpcomingRow` treats `yesterday` as it treats `beforeToday` today.

### Data

- **The stream takes a lower bound.** `scheduleTasks(today:)` gains an optional first Day, or a second method sits beside it. With a first Day it sends every Task whose Day is on or after it, Complete or not, in order of Day, then position. Without one, the query is unchanged. It sends again after every write and never throws after the first fetch, as ADR 0002 says.

### App

- **The state.** `ScheduleViewModel` holds `showsHistory` (in memory, default `false`) and the History first Day. `ScheduleListing` carries both, so `ScheduleTasks.relist()` builds the History Schedule. Turning History on or off releases the Kept Tasks and resubscribes the observation.
- **The observation.** `observeSchedule` subscribes with the first Day while History is on. The first Day starts about 60 Days before Today and moves back 60 when the list nears its top, which resubscribes. A new Today moves nothing back by itself.
- **Loading near the top.** The list controller tells the view model when its first rows come near the top of the screen, for example within a screen's height. A page loaded above must not move the rows on screen, so the list keeps its content offset anchored to the first visible row across the snapshot that adds the page.
- **The jumps.** Turning History on, the list scrolls, without animation, so Yesterday's header is at the top. Turning it off, it scrolls, without animation, to the top. Both are one-off requests like `DayReveal`, carried out once the matching Schedule is shown. Midnight sends no request.
- **The button.** `QuickSettingsView` gains the History button first, with `clock.arrow.circlepath`. When on, the square's background is the primary colour and the glyph inverts. On iOS 26 and later it's a primary-tinted interactive glass. Its `accessibilityRepresentation` is a `Toggle` labelled `schedule.history`, as for the other two. While History is on, the Go to a Day button takes Show Complete Tasks's place (see "Go to a Day" below).
- **The pickers.** `FloatingDayPickerState` and `SheetDayPickerState` take whether History is on. With it on, every Day can be chosen and is undimmed, a past Day opens chosen on its own month, and the floating picker pages back without limit. `PickerDayView` reads the same rule.
- **The composer.** In History `ComposerSession` steps and chooses past Days. Its Day chip picker accepts them. A past Day held when History turns off stays, and saving adds there.
- **The "+"** on a Day header shows for past Days in History. It already shows on every listed Day.
- **Strings** (via `scripts/xcstrings.py set`):
  - `schedule.history`: "History" / "Історія".
  - `day.yesterday`: "Yesterday" / "Вчора". Check that it reads naturally after "на" in the move announcement ("перенесено на вчора"); lowercase it there if the existing Today and Tomorrow strings do.
- **Folders** follow `CODING_STANDARDS.md`. New view-model code goes in a `ScheduleViewModel+History` file if it doesn't fit the existing ones.

### Go to a Day

Added on 2026-11-08 (stories 8, 38, 40–51).

- **Language.** "Go to a Day" is navigation, not something done to a Task, so it isn't a glossary term. Name the code for it, for example `DayChoiceTarget.goToDay` or `HistoryJump.Destination.day(_:)`, and never "Move", "reschedule" or a broad one-word name.
- **The button.** In `QuickSettingsView`, while History is on, the second square is a plain `Button` with `calendar.badge.clock`, never filled, in Show Complete Tasks's place. The swap animates with `showsHistory`'s change, which is already toggled in `withAnimation`. Its `accessibilityLabel` is `schedule.goToDay`, read as a button. Outside History Show Complete Tasks is as before, and the `.disabled(showsHistory)` goes.
- **The sheet.** The button opens the sheet Day picker with a new `DayChoiceTarget` for going to a Day. It opens on the Day at the top of the screen, with `showsHistory` on, so any Day can be chosen across the months it already offers in History. The list controller keeps the view model told which Day that is, as the list scrolls and as it shows a new Schedule: the first Day in `sectionsOnScreen` with at least half its last row, or its header when it has no rows, below the bar's edge, so a Day whose header alone peeks out from under the bar doesn't count. For this target the summary line shows only `shortWeekday` and `shortDate`, with no Task count, since the count covers only the Tasks loaded. The prompt, Cancel and Done are unchanged.
- **Done.** `confirmSheetDayPicker` acts only on `newDay`, so Done on the Day it opened on does nothing, as does Cancel. For this target, `choose(_:for:)` asks the list to go to the Day and moves no Task.
- **Loading back to the Day.** If the chosen Day is before the History first Day, the first Day moves to 60 Days before the chosen Day (`Schedule.historyFirstDay(listing:from:)` in Domain), which resubscribes as a page further back does. That leaves room above the landing Day to scroll on back with the existing paging.
- **Landing.** The request is a one-off, like `HistoryJump` (for example a new `HistoryJump.Destination` holding the Day). It's carried out without animation, by `ScheduleListScroller.jump`, with the retries it already makes. Publish it, or carry it out, only once the shown Schedule lists back to the Day, which `listedDay(onOrBefore:)` tells by giving `nil` until then. The scroller marks a request done even when the snapshot lacks its section, so a request carried out too early would be lost. It puts the landing Day's header at the top; `offsetYPuttingHeaderAtTop` already clamps to the list's end. The landing Day is the chosen Day if the Schedule lists it, else the closest listed Day before it. That happens only to an empty Day after the 100 listed from Today, and Today always comes before it.
- **VoiceOver.** Once landed, and once the sheet has closed, focus moves to the landing Day's header by posting `.layoutChanged` with the header view. Not before the sheet has closed: as it closes, VoiceOver's focus goes back to the button that opened it. The view model sets a one-off request of its own, the jump whose landing Day takes focus, and the list controller answers it after the jump.
- **Midnight.** A new Today sends no request. The sheet keeps its chosen Day, since in History every Day can be chosen.
- **Strings:** `schedule.goToDay`: "Go to a Day" / "Перейти до дня", via `scripts/xcstrings.py set`.

## Testing Decisions

Swift Testing; `today` passed explicitly; Days are GMT midnights. Test what a caller sees, not how it's computed. Every seam already exists.

- **Domain, `Schedule` (prior art `ScheduleTests`), the main seam:**
  - History lists every Day from the first Day through the window, empty ones included, followed by the later Days with Tasks;
  - it lists Tasks completed from Overdue on their own Days, and its `overdue` is empty;
  - week and month starts carry on across the past and into Today;
  - in History, a Move, a drop and a Move to the end land on a past Day, and Move Up from Today's first Task lands at the end of Yesterday;
  - outside History all four still refuse past Days;
  - outside History nothing changes from the existing tests.
- **Domain, the Day helpers (prior art `DateDayTests`):** `relativeDay` gives `yesterday`, and the choosing rule accepts past Days only in History.
- **Data, the stream (prior art `TodoTaskRepositoryLiveTests`):** with a first Day it sends every Task from that Day on, Complete and Incomplete, in order, leaves out those before it, and sends again after a write. Without one, it behaves as now.
- **App:**
  - `ScheduleTasksTests`: an optimistic Move onto a past Day in History.
  - `FloatingDayPickerStateTests` and `SheetDayPickerStateTests`: past Days choosable in History, opening on a past Day's month with it chosen, and refused outside History.
  - `ComposerStateTests` or the composer's tests: stepping back past Today in History.
  - `DateDayFormattingTests`: "Yesterday" in the header and the announcement.
- **Not unit-tested:** the button, loading near the top with the rows held still, and the jumps. The UI check (`docs/agents/ui-check.md`) on iOS 27 covers them.
- **Go to a Day:**
  - **Domain, `Schedule` (prior art `ScheduleTests+History`):** the landing Day rule, `listedDay(onOrBefore:)`. A listed past Day, Today and a later Day give themselves. An empty Day after the window gives the closest listed Day before it, whether that's a later Day with Tasks or the window's last Day. A Day before the first listed Day gives none. The loading-back rule, `historyFirstDay(listing:from:)`: a Day History lists already keeps the first Day, and a Day before it moves the first Day a page before that Day.
  - **App, `SheetDayPickerStateTests`:** opened for going to a Day in History, a past or later Day can be chosen, and Done on the Day it opened on gives no Day.
  - **Not unit-tested:** the button and its swap, the Day at the top, the jump and VoiceOver focus. The UI check on iOS 27 covers them, apart from VoiceOver focus, which needs a device.

## Out of Scope

- The widgets: no History, no past Days.
- Search, or any limit or setting for how far back History goes.
- Go to a Day outside History.
- Keeping History across launches.
- A marker on Overdue Tasks in History, and a Yesterday button on the floating Day picker.

## Further Notes

- Grilled on 2026-11-07. The user picked `clock.arrow.circlepath` with a filled square over swap-glyph icons such as `clock` / `clock.fill`. Both jumps were animated at first, pending the user's feel on the device; on 2026-11-07 the user made them instant, as the animation wasn't smooth.
- Issues, in order:
  - `issues/01`: History in Domain and Data.
  - `02`: the button and the History list.
  - `03`: choosing past Days in the pickers, the composer and "+".
  - `04`: Go to a Day.
- Go to a Day was grilled on 2026-11-08. The user picked `calendar.badge.clock` over `calendar`. The composer covers the quick settings bar, so the button can't be reached while it's open.
