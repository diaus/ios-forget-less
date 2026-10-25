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

**Status:** ready-for-human (an agent can build it; whether there is any visible delay is the user's call)

- [ ] Tapping "+" shows the panel and starts the keyboard in the same frame: no staggered "panel, then keyboard". No `asyncAfter`, `Task.sleep` or delayed `onAppear` is used anywhere for focus.
- [ ] The panel rides up with the keyboard on the keyboard's own animation, and sits directly above it on iPhone sizes with and without a home indicator.
- [ ] Tapping the dimmed background, or dragging the panel down, hides the panel and the keyboard together.
- [ ] Opening, dismissing and opening again works repeatedly, with focus landing every time.
- [ ] Taking focus away while keeping the panel visible (as the later "Discard changes?" dialog will) leaves the panel on screen, and focus can be given back.
- [ ] Which hiding technique worked (opacity or offset), and anything surprising, is recorded under a `## Comments` heading in this file.
- [ ] Verified on the iOS 18 simulator. The user has confirmed there is no visible delay.
