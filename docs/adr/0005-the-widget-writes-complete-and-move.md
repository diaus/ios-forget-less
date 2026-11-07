---
status: accepted
---

# The widget makes Tasks Complete and Moves them itself, through App Intents

The Home Screen widget's large and medium sizes let the user make a listed Task Complete and Move it one step up or down. A widget button runs an App Intent, and by default WidgetKit runs it in the widget extension's process, not the app's. So the widget opens the App Group store read-write for those writes, through the same repository and its `setComplete` and `move`. This supersedes ADR 0003's consequence that the widget never writes. Timelines still read through the read-only repository.

The intent works out Today itself when it runs. The destination of each step is computed with the timeline and travels in the intent. A Task the intent names that's gone by then is left alone, as the repository already does for an unknown ID.

## Considered Options

- **Run the intents in the app's process**, so the app stays the only writer. Only an intent that opens the app, or conforms to a few protocols for audio, Live Activities and the like, runs there. Opening the app on every tap defeats the widget, and none of those protocols fits.
- **Pass only the Task and a direction, and compute the destination at tap time.** That needs the intent to know the widget's settings, such as whether Tomorrow is listed, which only the timeline has. The timeline already reloads after every write, so its destinations are current when the user taps.

## Consequences

- The app's open Schedule stream misses a write the widget makes. ADR 0002 already restarts the observation each time the scene becomes active, and that's the only way to see the app again after tapping the widget.
- Each intent reloads every timeline after its write, so the Lock Screen widget and other Home Screen widgets catch it too. WidgetKit reloads the tapped widget itself after the intent returns. The widget leaves Data's after-save hook as it is, so it doesn't link the injection library for one call.
- The widget never creates the store. It writes only to a store the app has already created, and it never deletes a store that won't open, which is a simulator-only recovery the app keeps for itself.
