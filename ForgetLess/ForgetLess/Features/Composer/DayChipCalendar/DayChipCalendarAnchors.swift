import SwiftUI

/// What the Day chip calendar is placed from: the Day chip it opens above, and the composer it lines up with.
struct DayChipCalendarAnchors {
    var chip: Anchor<CGRect>?
    var composer: Anchor<CGRect>?
}

/// Carries the composer's `DayChipCalendarAnchors` up to the screen that draws the calendar.
struct DayChipCalendarAnchorsKey: PreferenceKey {
    static var defaultValue: DayChipCalendarAnchors { DayChipCalendarAnchors() }

    static func reduce(value: inout DayChipCalendarAnchors, nextValue: () -> DayChipCalendarAnchors) {
        let next = nextValue()
        value.chip = next.chip ?? value.chip
        value.composer = next.composer ?? value.composer
    }
}
