# Left out count on the widget

Status: ready-for-agent

## Problem Statement

Every "Upcoming" widget leaves out from the end the Tasks it can't fit: the Lock Screen after 4 or 8 rows, the small size after 8, and the medium and large sizes once their full-size rows fill the height. Nothing shows that Tasks were left out, so the user can miss that more is due than the widget lists.

## Solution

A new widget setting, "Show Left Out Count", on by default on every size. While it's on and the widget leaves out Overdue or Today Tasks, a "+N" ends the last row shown, in the widget's bottom-right. N counts only those Overdue and Today Tasks: Tomorrow's never count, so when only Tomorrow's are left out, nothing shows.

## User Stories

1. As a user, I want a "+N" at the end of the last row shown when the widget leaves out N Overdue or Today Tasks, so that I know more is due than I see.
2. As a user, I want Tomorrow's Tasks never counted, and no "+N" when only Tomorrow's are left out, so that the count means what's due now.
3. As a user, I want a Task my settings exclude (Overdue with "Show Overdue Tasks" off) never counted, since the widget doesn't list it anyway.
4. As a user, I want the "+N" never to cost a row: the last row's name is cut shorter to make room for it.
5. As a user, I want the "+N" on every size: the Lock Screen (at the end of the right column's last row with two columns), small, medium (just before the arrows) and large.
6. As a user, I want the "+N" in the row's font and the secondary style, with monospaced digits, so that it reads apart from the Task's name.
7. As a user, I want a "Show Left Out Count" setting, on by default, right after "Show Tomorrow's Tasks" on every size, so that I can turn the "+N" off.
8. As a VoiceOver user, I want the "+N" read as "N more tasks".
9. As a user, I want tapping the "+N" to open the app, like the rest of the widget.

## Implementation Decisions

- **Domain:** the content carries the count of Overdue and Today Tasks it leaves out past its row cap (`leftOutTaskCount`). The view adds the Overdue and Today rows it couldn't fit.
- **Widget:**
  - `UpcomingWidgetIntent` gains `showsLeftOutCount`, default `true`, placed after `showsTomorrowTasks` in every summary.
  - The "+N" sits at the trailing end of the last row shown. On the sizes with controls, it comes before the arrows.
- **String Catalog**, through `scripts/xcstrings.py`:
  - `widget.showLeftOutCount`: EN "Show Left Out Count", UK "Показувати кількість решти".
  - `widget.leftOutCount`, a plural for VoiceOver: EN "%lld more task" / "%lld more tasks" (`one`, `other`), UK "ще %lld завдання" / "ще %lld завдання" / "ще %lld завдань" / "ще %lld завдання" (`one`, `few`, `many`, `other`).

## Testing Decisions

- **Domain**, through the content and the count, with ordered Tasks and an explicit `today`:
  - Overdue and Today Tasks past the cap are counted;
  - Tomorrow's Tasks past the cap aren't, and only Tomorrow's past it gives 0;
  - with Overdue not listed, Overdue Tasks aren't counted;
  - no cap (the sizes with controls) gives 0 from the content.
- **Widget:** `RenderPreview` of each size with the setting on and off, with Overdue and Today Tasks left out, with only Tomorrow's left out, and on the Lock Screen in one and two columns.
- **Done:** `build_sim`, `test_sim` and `scripts/check.sh` pass. On the iOS 27 simulator, the Lock Screen and Home Screen widgets show the "+N", and turning the setting off hides it.

## Out of Scope

- Showing which Tasks were left out, or opening them.
- Counting Tomorrow's Tasks, or Tasks a setting excludes.
