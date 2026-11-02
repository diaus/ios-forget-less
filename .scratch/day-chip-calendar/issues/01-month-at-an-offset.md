# 01: A month at an offset

**What to build:** The Domain change the calendar pages with (spec "Domain"). There is no UI yet, and the app looks exactly as before.

- **One month at an offset** from Today's month, offset 0 being Today's month. It has the same fields as `DayPickerCalendar.Month`: its first Day, how many blank cells come before it in its week, its Days, and its `weeks`.
  - Make it a public `DayPickerCalendar.Month` initialiser, or a static function beside it.
  - `DayPickerCalendar.init(today:monthCount:firstWeekday:)` builds its months with it, so the sheet and the calendar share one way of building a month.
- **The weekday header without any month:** the 7 weekdays in `firstWeekday` order, available without building a run of months.
- Every Day is a GMT midnight. Any calendar arithmetic it needs is a helper in Domain's `Date` Day extensions, since `Calendar` is read nowhere else.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] Tests in `DayPickerCalendarTests` (or a sibling file, if it grows too large):
  - offset 0 is Today's month;
  - an offset that crosses into the next year;
  - a month at an offset has the same blank cells and Days as the same month built by `DayPickerCalendar(today:monthCount:)`;
  - the weekday header's order for a Monday start and a Sunday start, without building any month.
- [ ] The existing `DayPickerCalendarTests` still pass unchanged.
- [ ] `build_sim`, `test_sim` and `scripts/check.sh` pass.
