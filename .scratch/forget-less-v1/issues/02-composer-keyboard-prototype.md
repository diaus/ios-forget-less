# 02: Composer keyboard prototype

**What to build:** Prove the quick-add composer can come up together with the keyboard, with no delay, before any other UI is built on it.

Tapping a "+" shows a rounded panel pinned above the keyboard, with a focused "Task Name" field, a placeholder Day chip and a ▶ (`arrowtriangle.right.fill`) button. The keyboard starts rising in the same frame the panel appears.

The approach was chosen during design (spec, "Composer"):
- no `.sheet`;
- the panel and its field are always mounted and hidden while unused;
- the tap action sets the composer's visible state and its focus synchronously;
- the panel respects the keyboard safe area;
- visibility is its own state, separate from focus.

It's unverified whether a field hidden with `opacity` can take focus. If it can't, hide it with an off-screen `offset` instead.

Nothing is saved; this ticket is about the presentation only. Keep the view if it works, since ticket 03 builds on it.

**Blocked by:** 01: Project scaffold and tooling

**Status:** resolved

- [x] Tapping "+" shows the panel and starts the keyboard in the same frame: no staggered "panel, then keyboard". No `asyncAfter`, `Task.sleep` or delayed `onAppear` is used anywhere for focus.
- [ ] The panel rides up with the keyboard on the keyboard's own animation, and sits directly above it on iPhone sizes with and without a home indicator.
- [x] Tapping the dimmed background, or dragging the panel down, hides the panel and the keyboard together.
- [x] Opening, dismissing and opening again works repeatedly, with focus landing every time.
- [x] Taking focus away while keeping the panel visible (as the later "Discard changes?" dialog will) leaves the panel on screen, and focus can be given back.
- [x] Which hiding technique worked (opacity or offset), and anything surprising, is recorded under a `## Comments` heading in this file.
- [x] Verified on the iOS 18 simulator. The user has confirmed there is no visible delay.

## Comments

- 2026-10-25: Implemented on branch `docs/forget-less-v1-spec`. The user checked it on the iOS 18 simulator and an iOS 18 iPhone: it works as expected, with no visible delay. The agent checked part of it on the iPhone 16 Pro (iOS 18.5) simulator: "+" shows the panel with the field focused and the keyboard up beneath it, and tapping the dimmed background hides both. After the review fixes, the agent checked open → drag down → open on the iPhone 18 Pro (iOS 27) simulator through UI snapshots. `scripts/check.sh` passes.
- Left unticked: no phone without a home indicator (iPhone SE size) is recorded as checked.
- **Hiding technique: `opacity`.** A field hidden with `.opacity(0)` takes focus, so the off-screen `offset` fallback wasn't needed. While hidden, the panel also has `.allowsHitTesting(false)` and `.accessibilityHidden(true)`.
- The panel is `Features/Composer/ComposerView.swift`. `ScheduleView` owns the visibility `@State` and the `@FocusState` and passes them in, so "+" (and the later row taps) set both in one action. `ComposerView` asks for dismissal through `onDismiss` rather than writing that state itself, so ticket 09 has one place to intercept. A drag short of the dismiss distance springs back. The list behind the panel has `.ignoresSafeArea(.keyboard)`, so only the panel rides up and the "+" stays put.
- Prototype stand-ins that ticket 03 replaces: Return takes focus away and leaves the panel up (standing in for the "Discard changes?" dialog); ▶ gives focus back (standing in for "Keep Editing"). Ticket 03 makes both add the Task.
- Surprises:
  - `TextField(_:text:)` takes a `LocalizedStringResource` (a catalog symbol) only from iOS 26. On iOS 18 the field uses `TextField(text:prompt:label:)` with `Text(.composerTaskName)`.
  - MobileBuildMCP's `snapshot_ui` still lists the hidden panel's field and ▶ despite `.accessibilityHidden`. The tool may be reading the raw accessibility tree; VoiceOver itself wasn't checked.
  - The typed name lives in `ComposerView`'s own `@State`, so it survives dismissal. Tickets 03 and 09 move it out to clear, prefill and compare it.
  - The drag gesture covers the whole panel, field included. It didn't get in the way here; if it fights text selection, move it to the panel's background.
  - Simulator automation: typing through AXe/`type_text` sends hardware-keyboard events, and the simulator then hides the software keyboard until it's toggled back (⌥⌘K in Xcode 27's Device Hub). MobileBuildMCP's `screenshot` can lag a few seconds behind on a freshly booted simulator.
