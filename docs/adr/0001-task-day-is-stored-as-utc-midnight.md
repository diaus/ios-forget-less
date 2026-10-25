---
status: accepted
---

# A Task's Day is stored as a UTC-midnight `Date`; only Data knows

A Task belongs to a calendar Day of the user's local calendar, and that Day must not shift when the user changes time zone. We store it as one `Date` column holding 00:00:00 UTC of that year/month/day, because a single column sorts and filters cheaply in SwiftData predicates. The encoding is Data's private business: there is no `Day` value object and no "UTC midnight" rule in Domain. Outside Data, a Task's Day is a plain `Date` at local start of day, compared and grouped with `Calendar.current`.

Data converts in both directions with the calendar it is given:

- **Save**: the year/month/day of the Task's `Date` in the local calendar → 00:00 UTC of that year/month/day.
- **Load**: the year/month/day of the stored value in UTC → local midnight of that year/month/day.

## Considered Options

- **Separate year/month/day fields**, as PillsTracker does. Rejected: three columns to keep consistent, and range queries ("everything from Today on") get awkward.
- **A `Day` value object in Domain**, as PillsTracker does. Rejected as more model than a todo list needs; a `Date` at local start of day is enough for grouping and comparison.
- **Store the local moment as-is.** Rejected: a time-zone change would move Tasks to another Day.

## Consequences

- Never read a stored Task day with a local calendar, and never pass a Domain `Date` to a predicate without converting it: both shift the Day by the UTC offset. Data's tests cover the round trip in time zones on both sides of UTC.
- `Date` values held in memory are local midnights, so after a time-zone change the app reloads (on becoming active, and on a significant time change) to rebuild them from storage.
