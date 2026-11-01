# UI check

Drive the running app with MobileBuildMCP's UI tools (`snapshot_ui`, `tap`, `drag`) on an iOS 27 simulator (the session default, iPhone 18 Pro).

## Steps

1. Run the app with `build_run_sim`, and call `snapshot_ui` once it has returned.
2. Act with `tap` (passing `postDelay: 1`) or `drag`. On iOS 27, input sent before the simulator's HID services open is dropped, though the tool reports success.
3. Confirm each action from the snapshot in its own result (`capture.targets`). A tool's success status can't tell a dropped tap from a landed one, and a `screenshot` can lag seconds behind the screen.

The check passes once every behaviour the change touches is confirmed this way.

## Simulator workarounds

- **Small controls.** An elementRef tap hits the element's centre. When that misses, tap the control's point with `scripts/sim-tap.sh X Y`, then `snapshot_ui`.
- **Moving a row.** Drag its handle with `"$axe" drag --start-x X --start-y Y --end-x X --end-y Y2 --duration 2 --steps 100 --udid <udid>`, with `axe` found as `scripts/sim-tap.sh` finds it, then read the rows back with `axe describe-ui`. `axe drag` sends a touch-move event per step, which the list needs to place the gap. `axe swipe`'s steps are too coarse: a drop onto an empty Day's header can miss. A drop near the bottom of the list auto-scrolls.
- **Keys.** Press a key with `scripts/sim-tap.sh --key CODE` (Return is 40): `key_press` is dropped the same way as an early tap.
- **Typing.** While the software keyboard shows, type by tapping its keys. `type_text` sends hardware-keyboard events, which hide the software keyboard until the user toggles it back with ⌥⌘K in Xcode's Device Hub while a field has focus. Once it's hidden (the snapshot lists no keys), type with `type_text`.
- **Autocorrect.** Type dictionary words: a pending autocorrect suggestion takes the next Return or button tap.
- **`replaceExisting`** appends rather than replaces.
- **Relaunch** with `xcrun simctl terminate`/`launch <udid> com.andrew.ForgetLess`: `stop_app_sim` and `launch_app_sim` need a bundle ID the session defaults lack.
- **Background and return.** The `home` button is dropped like an early tap. Launch Settings (`xcrun simctl launch <udid> com.apple.Preferences`), then the app again; the same process id shows it came back rather than relaunched.

## VoiceOver actions

`snapshot_ui` lists neither an element's named actions nor its announcements, and the simulator has no VoiceOver. Without a Simulator.app to drive through the Mac's accessibility API, check them this way:

- **Read the actions.** `"$axe" describe-ui --udid <udid>` prints each element's `custom_actions`, including those it inherits from its cell (Delete).
- **Invoke one.** Run the app under Xcode's debugger (the Xcode tools' `RunProject` with `attachDebugger: true`). `lldb -p` from the shell hangs while Developer Mode (`DevToolsSecurity`) is off. Run `describe-ui` once, so the app builds its accessibility elements. Then `process interrupt`, `expr -l objc -- @import UIKit`, and an Objective-C expression that walks the windows' `accessibilityElements` and `subviews` to the element with that `accessibilityLabel`, and calls the matching action's `actionHandler`. Then `continue`.
- **Read the announcement.** Before invoking, set `breakpoint set -n UIAccessibilityPostNotification -c "(int)$arg1 == 1008"` (1008 is the announcement). After `continue`, check `process status` until it has stopped there, then `po $arg2`.
- Stop the app with `StopProject` when done, and relaunch with `build_run_sim` before using `snapshot_ui` again.

## Lock Screen widget

The simulator's Lock Screen can be driven, so a widget check is not skipped for lack of a device.

- **Lock and wake.** MobileBuildMCP's `button lock` is dropped like `home`. Press it through one axe session that waits for the HID services, as `scripts/sim-tap.sh` does: `"$axe" batch --udid <udid> --step "touch -x 1 -y 1 --up" --step "sleep 0.5" --step "button lock" --step "sleep 1"`, with `axe` found the way that script finds it. Once to lock, once more to wake to the Lock Screen. Swipes and long presses go through the same kind of batch (`swipe --start-x … --end-y …`, or `touch --down`, `sleep`, `touch --up`).
- **Add the widget.** Long-press the middle of the Lock Screen (about 1.8 s), tap Customise (`sim-tap.sh`), then the editor's "Add Widget", "ForgetLess", the widget's tile, and its card's close button. These have elementRefs in `snapshot_ui`. Dismiss the gallery by dragging its handle down. A tap above the gallery lands on the clock. Tap Done at the top right. iOS 27's editor shows the tall clock with widgets at the bottom once a widget is placed. The widget's settings sheet opens when you tap the placed widget in the editor.
- **See it.** Confirm the widget from a screenshot (`xcrun simctl io <udid> screenshot`), since `snapshot_ui` doesn't describe widget content. `snapshot_ui` keeps reading the app launched by `build_run_sim`, even while SpringBoard or another app is in front, so outside the editor, tap by coordinates.
- **Update after a save.** Save in the app, then lock. iOS lets one reload through per foreground session and runs the rest when the app goes to the background, so lock before judging.
- **Midnight.** Settings has no Date & Time page, so move the simulator's time zone instead. Boot it with a `TZ` whose midnight is a few minutes away: `xcrun simctl shutdown <udid>`, then `SIMCTL_CHILD_TZ=GMT+HHMM xcrun simctl boot <udid>`, then `xcrun simctl bootstatus <udid> -b`. Work out HHMM from `date -u` (a whole number of minutes is fine). Every process then runs in that zone, the Lock Screen clock and the widget extension included, and chronod rebuilds the timeline at boot. `launchctl setenv TZ` doesn't work: it never reaches the widget extension. Lock, take a screenshot after midnight, then boot again without `SIMCTL_CHILD_TZ` to put the Mac's zone back.

## Time-based states

A check is never skipped because a state needs a past Day or another time. Set it up directly:

- **Tasks on past Days.** The app can't add them, so write them into its store. Terminate the app first. The store is in the App Group container the widget shares (ADR 0003), at `Library/Application Support/default.store` under `xcrun simctl get_app_container <udid> com.andrew.ForgetLess group.com.andrew.ForgetLess`. Look the path up each time rather than reusing it. Insert rows into `ZTODOTASKMODEL` with `Z_ENT = 1`, `Z_OPT = 1`, `ZID = randomblob(16)` and `ZDAY = strftime('%s','YYYY-MM-DD') - 978307200` (a Day, 00:00 GMT, in Core Data's reference time). Raise `Z_MAX` in `Z_PRIMARYKEY` to the highest `Z_PK`. Delete the rows when the check is done.
- **Another time zone.** Relaunch with `SIMCTL_CHILD_TZ=<zone> xcrun simctl launch <udid> com.andrew.ForgetLess`. Pick zones on both sides of GMT where the local date differs, such as `Pacific/Kiritimati` (UTC+14) and `Pacific/Pago_Pago` (UTC−11).
- **Midnight or a time-zone change while the app runs.** Post the notification iOS sends for both: `xcrun simctl spawn <udid> notifyutil -p SignificantTimeChangeNotification`.
