# 03: The "Upcoming" Lock Screen widget

**What to build:** A rectangular Lock Screen widget, "Upcoming", that lists Overdue and Today's Incomplete Tasks in the Schedule's order. Two settings, Show Overdue Tasks and Show Tomorrow's Tasks, choose which Tasks it lists. The widget has one column for up to 4 Tasks, and two balanced columns with "⋮" truncation for 5–8. It shows composed symbols for the empty and unreadable states. A tap opens the app. Spec stories 1–35.

- **Repository:** `incompleteTasks(from:through:)` returns the Incomplete Tasks whose Day is from the first Day (no lower bound when nil) through the last Day, using the shared order from 01. The widget passes:
  - first Day: nil with Show Overdue Tasks on, Today with it off;
  - last Day: Today with Show Tomorrow's Tasks off, Tomorrow with it on.
- **Domain Day helpers:** three pure helpers, inside Domain's Day extensions so the local calendar is read only there:
  - where a Day sits relative to Today: before Today, Today, Tomorrow or later;
  - Today at a given moment;
  - the next rollover after a moment.
- **Widget extension:** one widget, rectangular accessory family only, sharing the App Group from 02 and the app's String Catalog by target membership. Its folders follow PillsTracker's widget by role (configuration, timeline, views), and `CODING_STANDARDS.md`'s folder list gains them.
- **Configuration:**
  - An App Intent configuration with "Show Overdue Tasks" / «Показувати прострочені завдання» (on by default) and "Show Tomorrow's Tasks" / «Показувати завдання на завтра» (off by default).
  - Gallery name "Upcoming" / «Найближчі», description "Planned tasks" / «Заплановані завдання».
- **Timeline:**
  - One entry for now and one at the next rollover, each built for the Today of its moment, reloaded at the end.
  - When the store can't be read, the entry shows the unreadable state and the timeline reloads in 15 minutes.
  - When there's no store yet, the entry shows the empty state.
- **Rows:**
  - One line per Task. Overdue starts with a bold "!", Tomorrow with a bold "→", both with no space before the name. Today has no marker.
  - The font size is fixed whatever the count, sized so 4 rows fill the height. Padding is minimal.
  - More than 8 Tasks: the first 8 show.
- **Layout:**
  - 1–4 Tasks: one vertically centred column, with names cut by the system's "…".
  - 5–8 Tasks: two columns, ⌈n/2⌉ on the left, read down the left column first.
    - The grid is vertically centred, each column top-aligned within it, rows level across columns, with a vertical line between.
    - The widget measures each name against its column and cuts it to end with "⋮". The marker is never cut.
- **States:**
  - The empty state is `checklist.unchecked` with a `checkmark` badge. The unreadable state is `checklist.unchecked` with an `exclamationmark.triangle` badge.
  - Each badge is about 60% of the checklist's size, centred on its top-right corner. The composed symbol is centred, about two-thirds of the widget's height.
  - The sizes are tuned with `RenderPreview` and agreed with the user before closing.
- **Other:**
  - No widget URL.
  - Not privacy-sensitive, so names show while the phone is locked.
  - The gallery snapshot shows sample Tasks, including an Overdue one. The placeholder is the same sample, which iOS redacts.

**Blocked by:** 01: One shared order for every fetch; 02: The store in the App Group, with a widget reload after every save

**Status:** ready-for-agent

- [ ] Data tests for `incompleteTasks(from:through:)`:
  - with no lower bound, every Incomplete Task through the last Day;
  - with Today as the lower bound, no Overdue Tasks;
  - Tomorrow's Tasks only when the last Day is Tomorrow;
  - never a Complete Task, including one completed from Overdue on Today;
  - Tasks inserted out of order come back in the shared order.
- [ ] Domain tests:
  - where a Day sits relative to Today, for before Today, Today, Tomorrow and Today + 2, including across a year boundary;
  - Today at a moment and the next rollover, in pinned zones on both sides of GMT, away from a daylight-saving change.
- [ ] Previews (`RenderPreview`) show:
  - 1 Task and 4 Tasks in one column;
  - 5, 7 and 8 Tasks in balanced columns with the line between;
  - 9 or more Tasks capped at 8;
  - long names ending "…" in one column and "⋮" in two, with "!" and "→" never cut;
  - each marker;
  - the empty and unreadable states.
- [ ] The composed symbols' sizes and placement are agreed with the user.
- [ ] Previews cover each settings combination: Overdue on or off, crossed with Tomorrow on or off. With Overdue off no "!" shows. With Tomorrow on, Tomorrow's Tasks come last with "→".
- [ ] The widget extension builds with the App Group entitlement. The gallery name, description and setting labels have `en` and `uk` values, added with `scripts/xcstrings.py`.
- [ ] `CODING_STANDARDS.md`'s folder list includes the widget's folders.
- [ ] `build_sim`, `test_sim` and `scripts/check.sh` pass.
- [ ] The check on a real Lock Screen (adding the widget, seeing it update after an app write and at midnight) is reported as skipped unless the user runs it, since the tools can't add a Lock Screen widget.
