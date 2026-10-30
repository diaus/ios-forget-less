# UI check

Drive the running app with MobileBuildMCP's UI tools (`snapshot_ui`, `tap`, `drag`) on an iOS 27 simulator (the session default, iPhone 18 Pro).

## Steps

1. Run the app with `build_run_sim`, and call `snapshot_ui` once it has returned.
2. Act with `tap` (passing `postDelay: 1`) or `drag`. On iOS 27, input sent before the simulator's HID services open is dropped, though the tool reports success.
3. Confirm each action from the snapshot in its own result (`capture.targets`). A tool's success status can't tell a dropped tap from a landed one, and a `screenshot` can lag seconds behind the screen.

The check passes once every behaviour the change touches is confirmed this way.

## Simulator workarounds

- **Small controls.** An elementRef tap hits the element's centre. When that misses, tap the control's point with `scripts/sim-tap.sh X Y`, then `snapshot_ui`.
- **Keys.** Press a key with `scripts/sim-tap.sh --key CODE` (Return is 40): `key_press` is dropped the same way as an early tap.
- **Typing.** While the software keyboard shows, type by tapping its keys. `type_text` sends hardware-keyboard events, which hide the software keyboard until the user toggles it back with ⌥⌘K in Xcode's Device Hub while a field has focus. Once it's hidden (the snapshot lists no keys), type with `type_text`.
- **Autocorrect.** Type dictionary words: a pending autocorrect suggestion takes the next Return or button tap.
- **`replaceExisting`** appends rather than replaces.
- **Relaunch** with `xcrun simctl terminate`/`launch <udid> com.andrew.ForgetLess`: `stop_app_sim` and `launch_app_sim` need a bundle ID the session defaults lack.
- **Background and return.** The `home` button is dropped like an early tap. Launch Settings (`xcrun simctl launch <udid> com.apple.Preferences`), then the app again; the same process id shows it came back rather than relaunched.

## Time-based states

A check is never skipped because a state needs a past Day or another time. Set it up directly:

- **Tasks on past Days.** The app can't add them, so write them into its store. Terminate the app first. The store is `Library/Application Support/default.store` under `xcrun simctl get_app_container <udid> com.andrew.ForgetLess data`, a path that changes when the app is reinstalled. Insert rows into `ZTODOTASKMODEL` with `Z_ENT = 1`, `Z_OPT = 1`, `ZID = randomblob(16)` and `ZDAY = strftime('%s','YYYY-MM-DD') - 978307200` (a Day, 00:00 GMT, in Core Data's reference time). Raise `Z_MAX` in `Z_PRIMARYKEY` to the highest `Z_PK`. Delete the rows when the check is done.
- **Another time zone.** Relaunch with `SIMCTL_CHILD_TZ=<zone> xcrun simctl launch <udid> com.andrew.ForgetLess`. Pick zones on both sides of GMT where the local date differs, such as `Pacific/Kiritimati` (UTC+14) and `Pacific/Pago_Pago` (UTC−11).
- **Midnight or a time-zone change while the app runs.** Post the notification iOS sends for both: `xcrun simctl spawn <udid> notifyutil -p SignificantTimeChangeNotification`.
