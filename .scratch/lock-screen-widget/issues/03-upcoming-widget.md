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
  - Each badge is as large as the checklist, centred on its top-right corner, with the checklist cut away around it (agreed with the user after `RenderPreview`). The composed symbol is centred, about two-thirds of the widget's height.
  - The sizes are tuned with `RenderPreview` and agreed with the user before closing.
- **Other:**
  - No widget URL.
  - Not privacy-sensitive, so names show while the phone is locked.
  - The gallery snapshot shows sample Tasks, including an Overdue one. The placeholder is the same sample, which iOS redacts.

**Blocked by:** 01: One shared order for every fetch; 02: The store in the App Group, with a widget reload after every save

**Status:** ready-for-agent

- [x] Data tests for `incompleteTasks(from:through:)`:
  - with no lower bound, every Incomplete Task through the last Day;
  - with Today as the lower bound, no Overdue Tasks;
  - Tomorrow's Tasks only when the last Day is Tomorrow;
  - never a Complete Task, including one completed from Overdue on Today;
  - Tasks inserted out of order come back in the shared order.
- [x] Domain tests:
  - where a Day sits relative to Today, for before Today, Today, Tomorrow and Today + 2, including across a year boundary;
  - Today at a moment and the next rollover, in pinned zones on both sides of GMT, away from a daylight-saving change.
- [x] Previews (`RenderPreview`) show:
  - 1 Task and 4 Tasks in one column;
  - 5, 7 and 8 Tasks in balanced columns with the line between;
  - 9 or more Tasks capped at 8;
  - long names ending "…" in one column and "⋮" in two, with "!" and "→" never cut;
  - each marker;
  - the empty and unreadable states.
- [x] The composed symbols' sizes and placement are agreed with the user.
- [x] Previews cover each settings combination: Overdue on or off, crossed with Tomorrow on or off. With Overdue off no "!" shows. With Tomorrow on, Tomorrow's Tasks come last with "→".
- [x] The widget extension builds with the App Group entitlement. The gallery name, description and setting labels have `en` and `uk` values, added with `scripts/xcstrings.py`.
- [x] `CODING_STANDARDS.md`'s folder list includes the widget's folders.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.
- [x] On the simulator's Lock Screen (iOS 27, iPhone 18 Pro), the widget is added from the gallery, shows the empty state with no Tasks, and lists Tasks after an app write.
- [x] At midnight, on the Lock Screen, Today's Tasks turn Overdue with "!" without the app opening.

## Comments

- The badge started at about 60% of the checklist's size. After seeing the previews, the user chose a badge as large as the checklist. A square cut out of the checklist around the badge keeps the two from running together. The spec says the same now.
- ~~The real Lock Screen check was skipped, since the tools can't add a Lock Screen widget.~~ That was wrong: the simulator's Lock Screen can be driven (PillsTracker's widget was checked that way). The steps are now in `docs/agents/ui-check.md`.
- **2026-10-31, on the iOS 27 simulator (iPhone 18 Pro):** the gallery lists ForgetLess > "Upcoming", "Planned tasks", with sample rows "!Pay rent", "Buy oat milk", "Call mum". Added to the Lock Screen, the widget's settings sheet shows Show Overdue Tasks on and Show Tomorrow's Tasks off. With no Tasks it shows the checklist with the checkmark badge. After "Water plants" and "Call mum" were added on Today in the app and the simulator was locked, it listed both, in one column, with no marker. A third, "Feed cat", showed up the same way.
- **2026-10-31, midnight on the iOS 27 simulator:** `launchctl setenv TZ` never reached the widget extension, whose environment had no `TZ`. Booting with `SIMCTL_CHILD_TZ=GMT+0631` moved the whole simulator to that zone, and the extension then ran with `TZ=GMT+0631`. chronod rebuilt the timeline at boot (`environmentMismatch`), with 2 entries and the reload set for `2026-11-01T00:00:00+06:31`. At 00:00 on Sun 1 Nov the Lock Screen widget showed "!Water plants", "!Call mum" and "!Feed cat", and the app was never opened. The simulator was then rebooted without the override.
- The previews were checked with `RenderPreview` in interactive mode on iOS 27 (iPhone 18 Pro). A static render comes back transparent for accessory widgets.
