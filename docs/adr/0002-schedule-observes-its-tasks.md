---
status: accepted
---

# The Schedule observes one stream of its Tasks; a Task records the Day it was completed

The repository streams the Tasks the Schedule lists on Today: those from Today on, the Incomplete ones before Today, and those completed on Today. One query fetches them all. The stream sends them at once, and again after every write. The view model rebuilds the Schedule on each element and resubscribes when Today changes. Nothing reloads by hand after a write.

How Data learns of a change stays inside Data. Every write goes through one save that fires a `ChangeNotifier` (Utils), and each open stream fetches again. Domain and the app see only `AsyncStream<[TodoTask]>`, so moving to SwiftData's own change notification later touches only the repository.

The stream never throws. The first fetch happens when subscribing and throws, so a store that can't be read reaches the error alert. A later failed fetch is logged and sends nothing: the list keeps its last Tasks, and the next change fetches again.

A Task completed from Overdue stays there until Today rolls over, so a mis-tap can be undone. A Task stores `completeDay`, the Day it was made Complete, and `isComplete` is computed from it, so the rule needs no in-memory state and survives a relaunch.

## Considered Options

- **Three queries merged by a use case, reloaded by the view model after each write**, our first design. Rejected: every write needed a manual reload and a guard against reloads finishing out of order, and the kept Overdue Tasks lived only in memory.
- **A stream of every Task, with the Schedule filtering in memory.** It needs no resubscribing, but rejected because it fetches every past Complete Task, a set that only grows.
- **Exposing the change signal to the app**, as PillsTracker does. Rejected: it ties the app to how Data detects changes.
- **`ModelContext.didSave`.** It catches saves the repository didn't make, but none exist yet. Bridging a non-`Sendable` `Notification` into the actor, and keeping test containers apart, costs more than it gives today.
- **SwiftData history to spot writes from another process**, such as a future widget. Rejected: checking the history costs as much as the fetch it would save. Instead, the observation restarts each time the scene becomes active, and its first fetch picks those writes up.

## Consequences

- Every new write calls the repository's notifying save, or open streams miss it.
- Story 13 changes from "until the list next refreshes" to "until Today rolls over".
- V1 is edited in place until the first release. In the simulator only, a store that won't open is deleted and created again. A device never wipes, because a Debug build can overwrite a TestFlight install that holds real data.
