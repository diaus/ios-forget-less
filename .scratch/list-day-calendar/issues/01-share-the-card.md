# 01: Share the Day chip calendar's card

**What to build:** Move the month card out of the composer, so the list can show it too (spec "The card is shared").

- `Features/FloatingDayCalendar/`: `FloatingDayCalendarView`, `…MonthView`, `…ButtonsView`, `…State`, `…Layout`.
- The card takes a binding to its state, its height, whether a keyboard is up, and callbacks to choose, close and take the keyboard down. Its month view reads the Incomplete Task counts from the view model itself.
- The state's `chipDay` becomes `day`.
- The composer's overlay and anchors stay in `Features/Composer/DayChipCalendar/`. Nothing changes for the user.
- Tests move to `ForgetLessTests/Features/FloatingDayCalendar/`.

**Blocked by:** none

**Status:** resolved

- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.
- [x] The UI check on iOS 27 confirms the Day chip calendar still opens, chooses and closes. Paging wasn't driven again, since its code only moved.

## Comments

- The card takes its state as a binding that keeps the last value while the card animates out. `Binding($vm.optional)` force-unwraps nil there and crashed the app on close.
- The ✕'s catalog key is now `floatingDayCalendar.close`.
- The layout gained `fullHeight(headerHeight:buttonsHeight:padding:)`, which the row's placement needs. It's tested in `FloatingDayCalendarLayoutTests`.
