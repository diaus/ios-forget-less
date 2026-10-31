# 02: The store in the App Group, with a widget reload after every save

**What to build:** The app keeps its Tasks in an App Group container that a widget extension can later share (ADR 0003). After every successful write, the app asks WidgetKit to reload every widget timeline. To the user, the app works exactly as before.

- **App Group:** the app gets the App Group entitlement. The store opens in the group's container.
  - Only the app creates the store.
  - Data also exposes a read-only reader for the widget, which returns nothing while no store exists yet. It's created fresh per request, so a long-lived widget process sees the latest save.
  - In the simulator only, a store that won't open is still deleted and created again, now at the new location. SwiftUI previews keep the in-memory store.
  - The old sandbox store is neither moved nor deleted.
- **After-save hook:** the repository takes an after-save hook as an `init` parameter and runs it after every successful save, never after a failed one.
  - Data's Factory registers a hook that does nothing. The app overrides it to reload all widget timelines, so Data stays free of WidgetKit.
  - The hook is separate from the `ChangeNotifier` that feeds open streams (ADR 0002).
- **UI check doc:** the "Tasks on past Days" step in `docs/agents/ui-check.md` names the store's new location, in the App Group container rather than the app's data container.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] After a fresh install, the store file is in the App Group container, and adding, completing, renaming and deleting Tasks all work, confirmed by the UI check on iOS 27.
- [x] The read-only reader returns nothing when no store exists, and reads the app's Tasks once it does. A Data test covers both.
- [x] Data tests: the hook runs once for each successful create, rename, setComplete and delete, and never when a save fails.
- [x] The app wires the hook to the widget reload; Data doesn't import WidgetKit.
- [ ] `docs/agents/ui-check.md` describes the new store location, and its past-Day setup works against it.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.

## Comments

- The UI check was skipped at the user's request, so the fresh-install box and the past-Day half of the `ui-check.md` box stay unticked. The doc now names the App Group container; its `simctl` lookup hasn't been tried in the simulator yet.
