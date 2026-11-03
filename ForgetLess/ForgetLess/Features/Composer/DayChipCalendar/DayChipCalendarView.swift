import Domain
import FactoryKit
import SwiftUI
import Utils

/// Chooses the composer's Day from a month at a time, from Today's month on.
struct DayChipCalendarView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    let calendar: DayChipCalendarState
    let availableHeight: CGFloat
    let onClose: () -> Void

    /// How many months have a page, from Today's on; grows as the user nears the last.
    @State private var pageCount: Int
    @State private var position: ScrollPosition
    /// Counts the swipes refused before Today's month, for a haptic on each.
    @State private var refusedPageCount = 0
    /// Measured at the current text size, for the rows to fit around.
    @State private var headerHeight: CGFloat = 0
    @State private var buttonsHeight: CGFloat = 0

    /// How many months the pages grow by at a time, and how close to their end they grow.
    private static let growthStep = 12
    private static let edgeThreshold = 3
    /// How far past Today's month a swipe must pull before it counts as refused.
    private static let refusedPullDistance: CGFloat = 8
    private static let pagePadding: CGFloat = 16
    /// About the ✕'s width, which a month's name stays clear of.
    static let closeButtonSize: CGFloat = 30

    init(
        calendar: DayChipCalendarState,
        availableHeight: CGFloat,
        onClose: @escaping () -> Void
    ) {
        self.calendar = calendar
        self.availableHeight = availableHeight
        self.onClose = onClose
        // Opens on its month at once, with no scroll to it.
        _pageCount = State(initialValue: calendar.monthOffset + Self.growthStep)
        _position = State(initialValue: ScrollPosition(id: calendar.monthOffset))
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            months
            // Under the months rather than on one, so they stay put while the months page.
            buttons
        }
        // Closes a moment after a Day is chosen, so the choice is seen.
        .task(id: calendar.isClosing) {
            guard calendar.isClosing, (try? await Task.sleep(for: .seconds(0.15))) != nil else { return }
            // Any keyboard it hid comes back with the close, not at the tap, so the calendar doesn't refit as it goes.
            onClose()
        }
        // Once down, the keyboard stays down until the calendar closes, so the calendar never bounces as it refits.
        .onChange(of: layout.hidesKeyboard, initial: true) { _, hidesKeyboard in
            guard hidesKeyboard else { return }
            vm.dayChipCalendar?.recordHiddenKeyboard()
            UIApplication.shared.resignFocus()
        }
        .sensoryFeedback(.selection, trigger: calendar.isClosing) { _, isClosing in isClosing }
        // Over the pages rather than on one, so it stays put while they page.
        .overlay(alignment: .topTrailing) {
            closeButton
                // Raised a little, as it's taller than the month's name, so it sits on that name's line.
                .padding(.top, Self.pagePadding - 4)
                .padding(.trailing, Self.pagePadding)
        }
        .background(.background.secondary)
        .clipShape(.rect(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 16, y: 4)
    }

    // MARK: - UI Components
    private var months: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(0..<pageCount, id: \.self) { offset in
                    DayChipCalendarMonthView(
                        month: DayPickerCalendar.Month(today: calendar.today, offset: offset),
                        calendar: calendar,
                        rowHeight: layout.rowHeight
                    ) { headerHeight = $0 }
                    .padding(Self.pagePadding)
                    .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.hidden)
        .scrollPosition($position)
        // The name field keeps focus, so typing can go on as soon as the calendar closes.
        .scrollDismissesKeyboard(.never)
        .fixedSize(horizontal: false, vertical: true)
        .onScrollGeometryChange(for: Bool.self) { geometry in
            geometry.contentOffset.x + geometry.contentInsets.leading < -Self.refusedPullDistance
        } action: { _, isPulledPastStart in
            if isPulledPastStart {
                refusedPageCount += 1
            }
        }
        .onChange(of: position.viewID(type: Int.self)) { _, offset in
            guard let offset else { return }
            vm.dayChipCalendar?.page(to: offset)
            if pageCount - offset <= Self.edgeThreshold {
                pageCount += Self.growthStep
            }
        }
        // A new Today renumbers the months; the month shown keeps its place, or moves on to Today's.
        .onChange(of: calendar.monthOffset) { _, offset in
            guard position.viewID(type: Int.self) != offset else { return }
            var instant = Transaction()
            instant.disablesAnimations = true
            withTransaction(instant) { position.scrollTo(id: offset) }
        }
        .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.5), trigger: refusedPageCount)
    }

    private var buttons: some View {
        DayChipCalendarButtonsView(calendar: calendar)
            .padding([.horizontal, .bottom], Self.pagePadding)
            // Measured even while hidden, so a new text size can bring them back.
            .fixedSize(horizontal: false, vertical: true)
            .onGeometryChange(for: CGFloat.self, of: \.size.height) { buttonsHeight = $0 }
            .frame(height: layout.showsButtons ? nil : 0, alignment: .top)
            .opacity(layout.showsButtons ? 1 : 0)
            .allowsHitTesting(layout.showsButtons)
            .accessibilityHidden(!layout.showsButtons)
    }

    @ViewBuilder private var closeButton: some View {
        if #available(iOS 26, *) {
            // Outside a toolbar the close role draws its title, so only its xmark is kept.
            Button(role: .close, action: onClose)
                .labelStyle(.iconOnly)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
        } else {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: Self.closeButtonSize, height: Self.closeButtonSize)
                    .background(.fill.tertiary, in: .circle)
            }
            .accessibilityLabel(Text(.dayChipCalendarClose))
        }
    }

    // MARK: - Helpers
    private var layout: DayChipCalendarLayout {
        DayChipCalendarLayout(
            availableHeight: availableHeight,
            headerHeight: headerHeight,
            buttonsHeight: buttonsHeight,
            padding: 2 * Self.pagePadding,
            isKeyboardUp: !calendar.hasHiddenKeyboard
        )
    }
}
