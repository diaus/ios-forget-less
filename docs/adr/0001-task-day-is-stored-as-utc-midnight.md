---
status: accepted
---

# A Task's Day is a GMT-midnight `Date` everywhere; only Today reads the local calendar

A Task belongs to a calendar Day of the user's local calendar, and that Day must not shift when the user changes time zone. A Day is one `Date` holding 00:00:00 GMT of its year/month/day, in storage, in Domain and in the app alike. A single column sorts and filters cheaply in SwiftData predicates, and with one form everywhere nothing converts at a boundary: Data stores and queries the value as given.

Every Day is reckoned in `Calendar.gmt` (Domain): the current calendar with its time zone set to GMT. Use it to add Days, compare them and format them. The local calendar is read in one place only, to work out which year/month/day it is now: Today is `Date.today` (Domain).

## Considered Options

- **Separate year/month/day fields**, as PillsTracker does. Rejected: three columns to keep consistent, and range queries ("everything from Today on") get awkward.
- **A `Day` value object in Domain**, as PillsTracker does. Rejected as more model than a todo list needs; a `Date` at GMT midnight is enough for grouping and comparison.
- **Local start of day outside Data, UTC midnight inside it**, our first design. Data converted in every mapping and every predicate with an injected `Calendar`, and every Day helper outside Data took a `calendar:` parameter. Rejected: two forms of one value, a conversion at every boundary, and Days held in memory went stale on a time-zone change.
- **Store the local moment as-is.** Rejected: a time-zone change would move Tasks to another Day.

## Consequences

- Never compute with a Day using `Calendar.current` or `startOfDay(for:)`. Either one shifts the Day by the UTC offset. Use `Calendar.gmt`, and format with `Date.FormatStyle(calendar: .gmt, timeZone: .gmt)`.
- A time-zone change leaves every Day valid. The app only recomputes Today: at midnight, and when the local year/month/day changes with the zone.
