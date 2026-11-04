# 04: The "Upcoming" widget on the Home Screen

**What to build:** The "Upcoming" widget gains the small Home Screen size (2×2). It lists the same Tasks as on the Lock Screen, in the same order, with the same settings for Overdue and Tomorrow, the same states and the same tap. It always shows one column, top-aligned, with a larger font and space between rows. Both sizes also get two shared row changes: Tomorrow's Tasks in the secondary colour, and Overdue Tasks in the accent group.

- **Widget and settings:**
  - The existing widget adds `.systemSmall` to its families. It stays one entry in the gallery, with the same name, description, sample and placeholder.
  - On the Home Screen, the settings sheet shows only Show Overdue Tasks and Show Tomorrow's Tasks. "Show two columns" and the cut ending are hidden there with `When(widgetFamily:)` in the parameter summary, since the Home Screen never shows two columns.
  - StandBy, the iPad Lock Screen, the Mac desktop and CarPlay get the small size automatically. They're left on and aren't checked.
- **Appearance (Home Screen):**
  - The system's default widget background, its default content margins, and primary text.
  - A space after "!" and after "→". The Lock Screen keeps no space, since width is scarce there.
  - The "!" is drawn in the `OverdueDay` colour from the app's asset catalog, which the widget target now shares. The name stays primary: only the marker is red.
- **Rows on both sizes:**
  - A Tomorrow row is secondary as a whole, "→" included, in every layout, the Lock Screen's two columns too.
  - An Overdue row is accentable as a whole. In the Home Screen's tinted and clear looks (accented rendering), the row takes the accent tint while the red is lost. The iPhone Lock Screen renders in vibrant mode, where accentable does nothing, so the Lock Screen looks the same as before.
  - Apart from these two changes, the Lock Screen stays exactly as it is.
- **Layout (Home Screen):**
  - Always one column, top-aligned. A name that doesn't fit is cut by the system with "…". The marker is never cut.
  - 1–5 rows: a fixed font of about 17 pt, sized so 5 rows plus gaps of about 5 pt fill the height.
  - 6–8 rows: the gaps shrink first, down to about 1–2 pt. Then the font shrinks, never below the Lock Screen's size.
  - The content holds up to 8 rows. Rows that still don't fit at the Lock Screen's size are left out from the end, so Tomorrow's go first.
  - The font size changes with the number of Tasks. This deliberately departs from spec story 20, which holds only for the Lock Screen.
  - The exact numbers are tuned with `RenderPreview` and agreed with the user.
- **States (Home Screen):** the empty and unreadable symbols are the Lock Screen's, centred, at about ⅓–½ of the widget's height (tuned with `RenderPreview`, agreed with the user).
- **Docs:** `docs/agents/ui-check.md` gains a Home Screen widget step beside the Lock Screen one.

**Blocked by:** none (03 is done)

**Status:** ready-for-agent

- [x] Previews (`RenderPreview`) of the small size show:
  - 1 and 5 Tasks at the full font and gap;
  - 6 Tasks with smaller gaps;
  - 8 Tasks with the font shrunk, and whatever doesn't fit left out from the end;
  - 9 or more Tasks capped at 8 or fewer;
  - long names ending "…", with "!" and "→" never cut;
  - each marker: a red "!" with a space after it, and a secondary "→" row with a space after the marker;
  - the empty and unreadable states.
- [x] The font, gaps, smallest gap and symbol size are agreed with the user.
- [x] Accessory previews still match the Lock Screen as it was, apart from Tomorrow rows being secondary.
- [x] On the Home Screen, the settings sheet shows only Show Overdue Tasks and Show Tomorrow's Tasks. The Lock Screen's sheet is unchanged.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.
- [x] On the simulator's Home Screen (iOS 27), the widget is added from the gallery, shows the empty state with no Tasks, and lists Tasks after an app write, in the default look and in tinted.
- [x] On the simulator's Lock Screen (iOS 27), the widget looks as before, with Tomorrow rows dimmer.
- [x] `docs/agents/ui-check.md` has the Home Screen widget step.

## Comments

- **2026-11-04, the numbers agreed with the user** after `RenderPreview` on iPhone 18 Pro (iOS 27), whose small widget has a 128×128 pt content area. The full font is a fixed 17 pt with 5 pt gaps. Sizing it so 5 rows plus 5 pt gaps fill the height would give 18 pt, and then 6 rows couldn't keep the full font with any gap. At 17 pt, 6 rows fit with gaps of about 1.3 pt. The smallest gap is 1 pt. 7 rows take 14 pt and 8 rows 12 pt, which is the Lock Screen's computed size on that device (its widget is 148×58 pt), so all 8 still fit there and none is left out. The state symbols are 40% of the widget's height.
- The Lock Screen rows view is now `LockScreenRowsView` (it was `UpcomingRowsView`), beside the new `HomeScreenRowsView`. The default widget background is `.background`.
- **2026-11-04, on the iOS 27 simulator (iPhone 18 Pro):** the Home Screen gallery lists ForgetLess > "Upcoming", "Planned tasks", with the sample and a secondary "→ Call mum". Once added, the widget showed the empty state with no Tasks on Today or Tomorrow. Its settings sheet showed only Show Overdue Tasks and Show Tomorrow's Tasks. An Overdue and a Tomorrow Task were written into the store, then "milk" was added on Today in the app. Back on the Home Screen, the widget listed "! Pay the electr…" (red "!"), "milk" and "→ Water the g…" (secondary). In the Tinted look with a blue tint, the Overdue row took the accent tint without its red, "milk" stayed primary and the Tomorrow row secondary. The look was set back to Default. On the Lock Screen, the widget looked as before ("!Pay the electricity bill b…", "milk", no space after "!"). Its sheet still showed Show Two Columns. With Show Tomorrow's Tasks turned on, "→Water the garden" showed dimmer than the other rows. The check's Tasks were then deleted from the store.
- No preview shows a row left out at the smallest font, since all 8 fit on iPhone 18 Pro. A render on iPad mini, whose small widget may be shorter, couldn't launch the widget extension (`timelineReloadTimeout`). The 12 pt floor is iPhone 18 Pro's Lock Screen size. On a device whose Lock Screen widget is taller or shorter, the floor doesn't follow it.
