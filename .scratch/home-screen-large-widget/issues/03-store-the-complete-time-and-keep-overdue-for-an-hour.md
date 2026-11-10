# 03: Store the moment a Task is made Complete, and keep it in Overdue for an hour

Status: ready-for-agent

**What to build:** A Task stores `completeTime`, the moment it was made Complete, in place of the Day it was (`completeDay`). The app's Overdue section keeps a Task completed from it for an hour after that moment, even past midnight, instead of until Today rolls over. User story 23 in `../spec.md`, and ADR 0007. The widget doesn't change yet: it still drops a Task as soon as it's Complete (issue 04).

- **Domain:** `TodoTask.completeDay` becomes `completeTime`, a plain moment, not a Day (ADR 0001 doesn't apply to it). `isComplete` is unchanged. `TodoTaskRepository.setComplete(id:isComplete:today:)` takes `now` in place of `today`.
- **Domain:** `Schedule` takes `now` besides `today`. Overdue lists a Task whose Day is before Today while it's Incomplete, or while `now` is less than an hour after its `completeTime`. The hour is a constant. Hiding Complete Tasks still hides it, apart from the app's Grace Period.
- **Data:** in `ForgetLessSchemaV1`, edited in place, `completeDay` becomes `@Attribute(originalName: "completeDay") var completeTime: Date?`. The mapping and `setComplete` follow. The Schedule stream's predicate outside History lists a Task whose Day is Today or later, or whose `completeTime` is no more than an hour before the moment it fetches (an Incomplete Task counts as never completed, as now).
- **App:** `ScheduleViewModel` and the types it hands `today` to pass now where the Schedule needs it, and rebuild the Schedule when the hour of the next Task kept in Overdue ends. `setComplete` gets `.now`.
- **Widget:** `CompleteTaskIntent` passes `.now`.
- **Previews and fakes:** `SampleTasks`, `TodoTask+Preview` and `FakeTodoTaskRepository` follow the rename.
- **Follow-up, not in this issue:** once the device holding real data has run this build, a commit drops `originalName` (ADR 0007).

**Blocked by:** none

- [ ] Domain tests: a Task completed from Overdue 59 minutes before now is listed in Overdue, and one completed 61 minutes before isn't. One completed at 23:30 is still listed at 00:15 on the next Today. With Complete Tasks hidden, a Task completed from Overdue is listed only while it's kept.
- [ ] Data tests: `setComplete` stores the moment it's given and clears it on Incomplete. Outside History, the stream lists a Task completed from Overdue within the last hour and leaves out one completed earlier.
- [ ] On the iOS 27 simulator, a store made by the build before this change keeps its Tasks, Complete ones included, after the new build is installed over it. Since the simulator wipes a store that won't open, the Tasks must still be there afterwards.
- [ ] In the app, with Complete Tasks shown, an Overdue Task made Complete stays in Overdue, struck through, and leaves an hour later without a relaunch.
- [ ] `build_sim`, `test_sim` and `scripts/check.sh` pass.
