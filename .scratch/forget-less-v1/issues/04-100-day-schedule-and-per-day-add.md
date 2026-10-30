# 04: The 100-Day schedule and per-Day add

**What to build:** The list becomes the full Schedule (spec stories 1–4, 14, 17):
- one section per Day from Today through Today + 99, every Day shown even when empty;
- after the window, a section for each later Day that has Tasks, with no empty Days between them;
- each header has a "+" that opens the composer for that Day;
- the composer's Day chip shows the right label and colour for the Day it was opened on.

**Blocked by:** 03: Add a Task to Today

**Status:** ready-for-agent

- [x] Headers read `25 Oct · Today · Sunday`, `26 Oct · Tomorrow · Monday` or `27 Oct · Tuesday`. "Today" and "Tomorrow" are the only relative labels. The year is added when the Day isn't in the current year. Dates are formatted for the device locale (Ukrainian on a Ukrainian device).
- [x] A header and its "+" are bold primary when the Day has any Task (Complete or not), and grey when it has none.
- [x] A header's "+" opens the composer for that Day, and the new Task lands at the end of that Day. The floating "+" still means Today.
- [x] The Day chip is categorised by the Day relative to Today, with colours from the asset catalog that have dark and higher-contrast light variants:

  | Category | Label | Colour |
  |---|---|---|
  | Today | `Today` | green |
  | Tomorrow | `Tomorrow` | orange |
  | Before Today + 7 | the weekday, e.g. `Sunday` | light blue |
  | Today + 7 or later | short date, e.g. `Nov 10`, with the year if not the current year | light grey |
  | Before Today | short date | red |

  The past category isn't reachable until editing (06/07), but is categorised and tested now.
- [x] A Task planned beyond Today + 99 appears under its own header after the window.
- [x] No navigation bar or title.
- [x] Domain tests for building the Schedule:
  - the 100-Day window, including empty Days;
  - later Days appear only when they have Tasks;
  - Tasks are ordered within a Day;
  - a window that crosses a year boundary.
- [x] App tests for the chip category: Today, Tomorrow, Today + 6, Today + 7, a past Day, and the year rule. No assertions on UI copy.
- [x] Data tests: the boundary of the "from Today on" query at Today.
- [x] `scripts/check.sh` passes, and the UI check covers both appearances.

## Comments

- 2026-10-25: Implemented on branch `docs/forget-less-v1-spec`. `scripts/check.sh` passes, and so do the app tests. The two new catalog keys have `en` and `uk`: `day.tomorrow`, and `task.addToDay`, the accessibility label of a header's "+". The agent drove the app on the iPhone 18 Pro (iOS 27) simulator through UI snapshots:
  - Headers read `25 Oct · Today · Sunday`, `26 Oct · Tomorrow · Monday` and `27 Oct · Tuesday`. Day-month order and abbreviations follow the device locale: the simulator's English locale writes `25 Oct`, and en-US would write `Oct 25`. Launched in Ukrainian, they read `25 жовт. · Сьогодні · неділя`.
  - Today is bold primary with a black "+". Empty Days are grey, with a grey "+".
  - The `27 Oct` "+" opened the composer with a light-blue `Tuesday` chip. The Task landed under `27 Oct`, that header turned bold, and the Task was still there after a relaunch. Chips from the other headers: orange `Tomorrow`, grey `1 Nov` for Today + 7, and `15 Mar 2027` with the year. The floating "+" still gives a green `Today`. In Ukrainian the weekday chip is capitalised: `Вівторок`.
  - Tasks seeded straight into the store on 2 Feb 2027 (Today + 100) and 15 Mar 2027 appeared under their own headers after `1 Feb 2027 · Monday`, with no empty Days between. Headers outside the current year carry the year.
  - Dark appearance: bold and grey headers, and the blue, orange and grey chips, all readable. The past (red) chip is reached only from 06/07.
- There's no `LoadSchedule` use case yet. With one query, the view model calls `repository.tasks(onOrAfter:)` and the pure `Schedule` builder directly, as CODING_STANDARDS.md allows. Ticket 07 introduces `LoadSchedule` when it adds the Overdue and kept-id queries, along with its fake-repository tests.
- The year rule is `Date.shortDateShowsYear(today:calendar:)`, which the chip and the headers share now and Overdue's red Day label will share later. It's tested apart from the copy.
- The first app test replaced `ForgetLessTests/.gitkeep`, and its project membership exception was removed with it.
