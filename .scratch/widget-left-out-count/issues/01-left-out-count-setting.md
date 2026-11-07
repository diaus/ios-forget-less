# 01: The "Show Left Out Count" setting and the "+N"

Status: resolved

**What to build:** everything in `../spec.md`, in one change: the content's `leftOutTaskCount`, the setting, the "+N" on every size, and the two String Catalog keys.

**Blocked by:** `.scratch/home-screen-large-widget/issues/02-medium-size-and-full-size-rows.md`, since the medium size and the full-size rows decide which rows are left out on the sizes with controls.

- [x] Domain tests for the count pass: Overdue and Today past the cap counted, Tomorrow's not, only Tomorrow's left out gives 0, Overdue not listed isn't counted.
- [x] Previews (`RenderPreview`) show the "+N" on the Lock Screen (one and two columns), small, medium and large, and none with the setting off or with only Tomorrow's Tasks left out.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.
- [x] On the iOS 27 simulator, the Lock Screen and Home Screen widgets show the "+N", and turning "Show Left Out Count" off hides it.

## Comments

- **2026-11-07, Domain tests:** Overdue and Today past the cap counted, Tomorrow's not, only Tomorrow's left out gives 0, and no cap gives 0, in `UpcomingWidgetContentTests`. "Overdue not listed isn't counted" has no content test: with "Show Overdue Tasks" off the provider asks the repository `from: today`, so the content never receives an Overdue Task and a content test could never go red. Data's `incompleteTasks(from: today, …)` test covers it.
- **2026-11-07, previews (iPhone 18 Pro, iOS 27):** in `UpcomingRowView.swift`. Lock Screen one column "+2" at the bottom-right; two columns "+2" ending the right column's last row, its name cut shorter; small "+3"; medium "+3" and large "+5", each just before the arrows. No "+N" with the setting off (Lock Screen, small, medium, large) or with only Tomorrow's Tasks left out (Lock Screen, small, medium, large).
- **2026-11-07, preview thunk:** `Text(.widgetLeftOutCount(count:))` inline in `.accessibilityLabel` broke the preview build ("ambiguous use of `__designTimeSelection`"), though `build_sim` passed, so the label is built in a helper property.
- **2026-11-07, on the simulator:** skipped at the user's request, so that box stays unticked.
