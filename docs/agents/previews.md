# Widget previews

Render the widget's `#Preview`s with the Xcode tools' `RenderPreview`.

## Warm-up

The first widget render after Xcode opens the project is a **warm-up**: it often fails to launch the widget extension with `CHSErrorDomain 1051 timelineReloadTimeout`, whatever the code. A render on a device that hasn't rendered previews yet (`preferredRenderDestination`) is a warm-up too, since its preview simulator boots first.

Send the same call again with `timeout: 240`. A preview counts as broken only once the warm-up and two more tries have failed; report it then, with the full error.

## Lock Screen previews

Static mode renders `.accessoryRectangular` previews blank, whatever the content and appearance. Render them with `displayMode: "interactive"` and `snapshotDelay: 3`: the widget then sits on a full Lock Screen (689×1500, wallpaper and clock), its rows from y ≈ 360.

- The first interactive render can come up on a black background before the wallpaper loads. Render it again before comparing.
- For before/after checks, compare only below the clock, whose time changes between runs. Crop and stitch with Python PIL in the scratchpad.

Home Screen sizes render in static mode.
