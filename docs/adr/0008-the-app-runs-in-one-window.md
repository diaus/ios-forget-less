---
status: accepted
---

# The app runs in one window on iPad

On iPad, a second ForgetLess window would mirror the first one's screen state. The Schedule's and Settings' view models are `.shared` Factory instances that every part of a screen resolves for itself (CODING_STANDARDS.md, SwiftUI), so two windows would hold the same `ScheduleViewModel` and `SettingsViewModel`. A composer or Day picker opened in one window would open in the other, laid out with positions measured in the first. For 1.0 the app turns multiple windows off: `UIApplicationSupportsMultipleScenes` is `false` in `ForgetLess/ForgetLess/Info.plist`. One window can still be resized, moved and used in Split View.

This may be revisited after release.

## Considered Options

- **A view model per window**: each window's root view creates its own, passes it down through the SwiftUI environment, and the list controller passes it into each cell's hosting configuration, which doesn't inherit the environment. The data already stays in step across windows, since every save notifies every open stream (ADR 0002). Rejected for now: it touches every part that resolves a view model and rewrites the standard that says how they resolve it, for a feature few users of a personal todo list would miss.

## Consequences

- The build setting `INFOPLIST_KEY_UIApplicationSceneManifest_Generation` is gone: a generated manifest always allows multiple windows, and Xcode ignores `INFOPLIST_KEY_UIApplicationSupportsMultipleScenes`. The app target's `Info.plist` holds the manifest instead. Xcode still generates the rest from build settings, and the file is kept out of Copy Bundle Resources by the folder's exception set.
- Turning multiple windows back on needs a view model per window first, as above. Each window would then have its own Grace Period: a Task completed in one window would stay listed there but leave the other's list at once.
