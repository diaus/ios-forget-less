# Day Calendar From a Task's Row

Status: resolved

## Problem Statement

The Day chip calendar reaches any Day with one tap, but only from the composer: to Move a Task with it, the user opens the composer on the Task, which brings up the keyboard, and then taps the chip. The Choose a Day sheet needs a swipe first. The user wants to pick a Task's Day straight from its row.

## Solution

The part of a Task's row between its circle and its handle is split into two halves of equal width, each the row's full height. A tap on the left half edits the Task, as a row tap does now. A tap on the right half, which holds an Overdue Task's Day, opens the **floating Day calendar** for that Task: the Day chip calendar's month card, on its own, with no composer and no keyboard, next to the row. Tapping a Day Moves the Task to the end of that Day and closes the card.

## User Stories

### The row

1. As a user, I want a tap on the left half of a Task's row to edit it at once, so that editing stays one quick tap.
2. As a user, I want a tap on the right half, an Overdue Task's Day included, to open the floating Day calendar for that Task, so that I can replan it without the composer.
3. As a user, I want the halves to split the space from the circle to the handle, or to the row's trailing edge while Move Tasks is off, so that both halves are always the same width.
4. As a user, I want it on every listed Task, Incomplete, Complete or Overdue, whether Move Tasks is on or off, so that it works like the Day chip.
5. As a user, I want a tap on a row whose swipe actions are open to only close them, as now.

### The calendar

6. As a user, I want the card to be the Day chip calendar's: five weeks, paging sideways, the Today, Tomorrow and weekday buttons and the ✕, so that both read the same.
7. As a user, I want it to open on the Task's month with its Day chosen, or for an Overdue Task on Today's month with nothing chosen.
8. As a user, I want it next to the row: below if the full card fits under it, else above if it fits there, else on the side with more room, fitted by hiding the buttons and then shrinking the rows, so that the row stays in view.
9. As a user, I want it no wider than the list's rows and about 400 pt, centred on where I tapped and kept within the rows' margins, growing out of the tap point and shrinking back into it.
10. As a user, I want the row highlighted while the card is open, so that I can see which Task I'm moving.

### Choosing and closing

11. As a user, I want a tap on a Day to Move the Task to the end of that Day and save at once, then close the card about 0.15 s later, as in the Day chip calendar.
12. As a user, I want the Task's own Day to only close the card, so that confirming doesn't reorder it.
13. As a user, I want the list to stay where it is after the Move, as after the sheet's Done.
14. As a user, I want a failed save to put the Task back and show the error alert.
15. As a user, I want a touch anywhere outside the card, or its ✕, to close only the card, without scrolling the list.
16. As a user who has hidden Complete Tasks, I want a Complete Task to stay listed while its card is open and get a fresh grace period when it closes.
17. As a user, I want the card to stay where it opened if the list changes, and to close if its Task is gone.
18. As a user, I want midnight handled as in the Day chip calendar.
19. As a VoiceOver user, I want the circle's "Choose Day" action to keep opening the Choose a Day sheet, so that nothing changes for me; VoiceOver's new Day announcement still follows a Move from the card.

## Implementation Decisions

- **The card is shared.** The month card (its view, month view, buttons, state and fitting) moves out of `Features/Composer/DayChipCalendar/` into `Features/FloatingDayCalendar/`, a component of its own, as `FloatingDayCalendarView`, `FloatingDayCalendarState` and so on. It takes its state as a binding, the height it has, and callbacks for choosing and closing, which differ between the composer and the list. Its month view reads the Incomplete Task counts from the view model itself. The composer keeps its overlay and anchors in `Features/Composer/DayChipCalendar/`.
- **The state's Day** is no longer "the chip's Day" but the Day the card opened on (`day`).
- **The keyboard.** Only the composer's card can take the keyboard down to fit. The card is told whether a keyboard is up; the list's never is.
- **The list's card** lives in `Features/Schedule/TaskDayCalendar/`: the view model holds the Task's ID with the card's state (`TaskDayCalendar`), and `ScheduleView` draws it in an overlay above everything, with a clear backdrop that takes every touch.
- **Placement is a pure function** (`TaskDayCalendarPlacement`), tested in the app's tests: from the row's frame, the tap point, the space the list shows (below the quick settings bar, above the bottom safe area) and the card's full height, it gives the side and the frame the card fits in, with the height it can use. The overlay grows the card from the tap point.
- **Geometry stays in the view.** The row's frame and the tap point, in window coordinates, come from the list controller (the cell records where its last touch began) and are kept in `ScheduleView`'s state, not the view model.
- **Choosing** reuses the Move: `Schedule.canMove(_:toDay:)`, `destinationAtEnd(of:forTaskWithID:)`, `saveMove`, with `dayAnnouncement`. No new repository call or use case.
- **Listed while open.** `rebuildSchedule` keeps the Task listed while its card is open, as for the composer's and the Day picker's Task.

## Testing Decisions

Swift Testing; `today` passed explicitly; Days are GMT midnights.

- **The state and fitting** keep their tests under their new names.
- **Placement:** below when the full card fits under the row; above when it fits only above; the side with more room when it fits neither, below on a tie, with that side's height; the width capped and centred on the tap point, kept within the row's edges.
- No view-model, UI or snapshot tests. The UI check on iOS 27 covers the row's halves and the card.

## Out of Scope

- Any change to the Choose a Day sheet or its swipe action.
- A VoiceOver action for the floating Day calendar.
- A double tap on a row.

## Further Notes

- The glossary gains no terms: "floating Day calendar" names a view. No ADR.
- Tickets: `issues/01` share the card, `02` open it from a Task's row.
