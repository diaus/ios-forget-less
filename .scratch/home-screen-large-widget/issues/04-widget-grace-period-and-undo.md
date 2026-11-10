# 04: The widget's Grace Period, its setting, and undo

Status: ready-for-agent

**What to build:** On the medium and large sizes, a Task made Complete stays in its place, struck through, for the widget's Grace Period, then leaves. Tapping its checked circle within that time makes it Incomplete again. Each widget sets its own Grace Period. User stories 4 and 17–22 in `../spec.md`, and ADR 0005.

- **Setting:** a `WidgetConfigurationIntent` parameter titled "Keep Complete Tasks For" (the app's own label), an `AppEnum` with Off, 3 s, 5 s, 10 s and 20 s, defaulting to 3 s. The parameter summary shows it only for `.systemMedium` and `.systemLarge`. Off works as the widget does today. Add the keys with `scripts/xcstrings.py`, in English and Ukrainian.
- **Data:** the widget's read lists the Incomplete Tasks it lists today, plus the Complete Tasks in the same range whose `completeTime` is within a given duration before a given moment.
- **Domain:** `UpcomingWidgetContent` takes the kept Complete Tasks. A kept Task keeps its place among the rows and carries no steps. The steps of other rows pass over it, as they pass over the Complete Tasks the widget doesn't list, so that every tap still changes what's seen. A kept row counts towards the rows shown, so the "+N" doesn't change until it leaves.
- **Timeline:** for each kept Task, an entry at the moment it leaves (`completeTime` plus the widget's Grace Period), besides now and the rollover. The rollover entry keeps no Task. The small and Lock Screen sizes keep none.
- **Intents:** the circle of a kept row runs an intent that makes the Task Incomplete, through `WidgetStoreWrite`, as `CompleteTaskIntent` does. Either give `CompleteTaskIntent` an `isComplete` parameter or add a second intent, whichever reads better.
- **Views:** a kept row shows a checked circle and a struck-through name, styled as the app's `TaskRowView` shows a Complete Task, and no Move arrows (their place kept, so the rows line up). VoiceOver reads its circle as "Make Incomplete".
- A Task made Complete in the app is kept too, for what's left of the widget's Grace Period (ADR 0007).

**Blocked by:** 03

- [ ] Domain tests: a kept Task is listed in its place with no steps. A neighbouring row's step passes over it. The "+N" counts it as shown. With no kept Tasks, the content is as before.
- [ ] Data test: the read lists a Task completed within the duration and leaves out one completed before it.
- [ ] Previews (`RenderPreview`) of the medium and large sizes with a kept row among Incomplete ones, on Today and in Overdue.
- [ ] The settings sheet of a medium and a large widget shows "Keep Complete Tasks For" with its five choices, and the small and Lock Screen sheets don't.
- [ ] On the iOS 27 simulator's Home Screen: a Task made Complete stays struck through for about 3 s, then leaves. Tapping its circle within that time makes it Incomplete again, in place. With Off, it leaves at once.
- [ ] `build_sim`, `test_sim` and `scripts/check.sh` pass.
