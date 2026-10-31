---
status: accepted
---

# The store lives in the App Group so the widget reads Tasks itself

The Lock Screen widget lists Overdue and Today's Incomplete Tasks. It runs in its own process, which can't read the app's sandbox. So the SwiftData store lives in an App Group container that the app and the widget extension share. The widget opens it read-only and works out Today itself, using the same Domain code as the app.

## Considered Options

- **The app writes a snapshot for the widget** into the App Group after every write, and the store stays in the sandbox. Rejected: a snapshot holds the Tasks as of one Today. If midnight passes while the app isn't running, the widget must turn Today's Tasks into Overdue ones and, with Tomorrow shown, bring in the next Day's Tasks. The snapshot would need every future Day's Incomplete Tasks, which makes it a second copy of the store.

## Consequences

- The widget learns of a write only when the app reloads its timelines. The repository runs an injected after-save hook on every successful save, and the app wires `WidgetCenter.shared.reloadAllTimelines()` into it, so Data stays free of WidgetKit. The hook is kept apart from the `ChangeNotifier` (ADR 0002) because it must fire on every save, even when no stream is open.
- The widget never writes, so ADR 0002's single notifying save still sees every write.
- No install held real data when the store moved, so the old sandbox store isn't migrated. Moving the store again needs a file migration.
