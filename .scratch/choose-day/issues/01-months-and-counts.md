# 01: The months and the Task counts

**What to build:** The Domain functions the Day picker draws from (spec "Domain"). There is no UI yet, and the app looks exactly as before.

- **The months read model**, in `Models/ReadModels/`, named for what it is (for example `DayPickerCalendar`). From `today`, a month count and `firstWeekday` it gives:
  - the 7 weekdays of the header, in order;
  - for each month: its first Day, how many blank cells come before that Day in its week, and its Days.
  
  Every Day is a GMT midnight. Any calendar arithmetic it needs is a new helper in Domain's `Date+Day`, since `Calendar` is read nowhere else.
- **Incomplete Task counts by Day:** a pure function over Tasks that counts only Incomplete Tasks, each on its own Day.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [x] Month tests:
  - the first month is Today's month;
  - the number of months is the number asked for;
  - the blank cells before the first Day for a Monday start and a Sunday start;
  - the number of Days in a 30-Day month, a 31-Day month, and February in a leap year and in another year;
  - a run that crosses into the next year;
  - the weekday header's order for a Monday start and a Sunday start.
- [x] Count tests:
  - only Incomplete Tasks count;
  - each Task counts on its own Day;
  - a Day with only Complete Tasks has no count.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.
