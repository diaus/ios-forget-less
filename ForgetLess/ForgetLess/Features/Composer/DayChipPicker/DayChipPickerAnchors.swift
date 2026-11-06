import SwiftUI

/// What the Day chip picker is placed from: the Day chip it grows from, and the composer it covers.
struct DayChipPickerAnchors {
    var chip: Anchor<CGRect>?
    var composer: Anchor<CGRect>?
}

/// Carries the composer's `DayChipPickerAnchors` up to the screen that draws the picker.
struct DayChipPickerAnchorsKey: PreferenceKey {
    static var defaultValue: DayChipPickerAnchors { DayChipPickerAnchors() }

    static func reduce(value: inout DayChipPickerAnchors, nextValue: () -> DayChipPickerAnchors) {
        let next = nextValue()
        value.chip = next.chip ?? value.chip
        value.composer = next.composer ?? value.composer
    }
}
