# 04: The 100-Day schedule and per-Day add

**What to build:** The list becomes the full Schedule (spec stories 1–4, 14, 17):
- one section per Day from Today through Today + 99, every Day shown even when empty;
- after the window, a section for each later Day that has Tasks, with no empty Days between them;
- each header has a "+" that opens the composer for that Day;
- the composer's Day chip shows the right label and colour for the Day it was opened on.

**Blocked by:** 03: Add a Task to Today

**Status:** ready-for-agent

- [ ] Headers read `25 Oct · Today · Sunday`, `26 Oct · Tomorrow · Monday` or `27 Oct · Tuesday`. "Today" and "Tomorrow" are the only relative labels. The year is added when the Day isn't in the current year. Dates are formatted for the device locale (Ukrainian on a Ukrainian device).
- [ ] A header and its "+" are bold primary when the Day has any Task (Complete or not), and grey when it has none.
- [ ] A header's "+" opens the composer for that Day, and the new Task lands at the end of that Day. The floating "+" still means Today.
- [ ] The Day chip is categorised by the Day relative to Today, with colours from the asset catalog that have dark and higher-contrast light variants:

  | Category | Label | Colour |
  |---|---|---|
  | Today | `Today` | green |
  | Tomorrow | `Tomorrow` | orange |
  | Before Today + 7 | the weekday, e.g. `Sunday` | light blue |
  | Today + 7 or later | short date, e.g. `Nov 10`, with the year if not the current year | light grey |
  | Before Today | short date | red |

  The past category isn't reachable until editing (06/07), but is categorised and tested now.
- [ ] A Task planned beyond Today + 99 appears under its own header after the window.
- [ ] No navigation bar or title.
- [ ] Domain tests for building the Schedule:
  - the 100-Day window, including empty Days;
  - later Days appear only when they have Tasks;
  - Tasks are ordered within a Day;
  - a window that crosses a year boundary.
- [ ] App tests for the chip category: Today, Tomorrow, Today + 6, Today + 7, a past Day, and the year rule. No assertions on UI copy.
- [ ] Data tests: the boundary of the "from Today on" query at Today.
- [ ] `scripts/check.sh` passes. Verified on the iOS 18 simulator in both appearances.
