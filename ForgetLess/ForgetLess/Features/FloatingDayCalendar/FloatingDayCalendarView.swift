import Domain
import SwiftUI

/// Chooses a Day from a month at a time, from Today's month on, in a card floating over the screen.
struct FloatingDayCalendarView: View {
    @Binding var calendar: FloatingDayCalendarState
    let availableHeight: CGFloat
    /// Whether a keyboard is up that the calendar can take down to make room.
    let isKeyboardUp: Bool
    /// Asks the owner to take the keyboard down, once the calendar can't fit beside it.
    let onHideKeyboard: () -> Void
    /// Reports the height the calendar takes when nothing has to make room.
    let onFullHeightChange: (CGFloat) -> Void
    let onChoose: (Date) -> Void
    let onClose: () -> Void

    /// How many months have a page, from Today's on; grows as the user nears the last.
    @State private var pageCount: Int
    @State private var position: ScrollPosition
    /// Counts the swipes refused before Today's month, for a haptic on each.
    @State private var refusedPageCount = 0
    /// Measured at the current text size, for the rows to fit around.
    @State private var headerHeight: CGFloat = 0
    @State private var buttonsHeight: CGFloat = 0
    /// The month whose header has VoiceOver focus, by its offset.
    @AccessibilityFocusState private var focusedMonthOffset: Int?

    /// How many months the pages grow by at a time, and how close to their end they grow.
    private static let growthStep = 12
    private static let edgeThreshold = 3
    /// How far past Today's month a swipe must pull before it counts as refused.
    private static let refusedPullDistance: CGFloat = 8
    private static let pagePadding: CGFloat = 16
    /// About the ✕'s width, which a month's name stays clear of.
    static let closeButtonSize: CGFloat = 30

    init(
        calendar: Binding<FloatingDayCalendarState>,
        availableHeight: CGFloat,
        isKeyboardUp: Bool = false,
        onHideKeyboard: @escaping () -> Void = {},
        onFullHeightChange: @escaping (CGFloat) -> Void = { _ in },
        onChoose: @escaping (Date) -> Void,
        onClose: @escaping () -> Void
    ) {
        _calendar = calendar
        self.availableHeight = availableHeight
        self.isKeyboardUp = isKeyboardUp
        self.onHideKeyboard = onHideKeyboard
        self.onFullHeightChange = onFullHeightChange
        self.onChoose = onChoose
        self.onClose = onClose
        // Opens on its month at once, with no scroll to it.
        let monthOffset = calendar.wrappedValue.monthOffset
        _pageCount = State(initialValue: monthOffset + Self.growthStep)
        _position = State(initialValue: ScrollPosition(id: monthOffset))
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
        .onChange(of: layout.hidesKeyboard, initial: true) { _, hidesKeyboard in
            if hidesKeyboard {
                onHideKeyboard()
            }
        }
        .onChange(of: fullHeight, initial: true) { _, fullHeight in
            // Not before the header and the buttons have been measured, so the owner never acts on a partial height.
            if headerHeight > 0, buttonsHeight > 0 {
                onFullHeightChange(fullHeight)
            }
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
        // Modal, so VoiceOver stays in the calendar, and its escape closes only the calendar.
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
        .accessibilityAction(.escape, onClose)
        // The modal hides what VoiceOver was on, so focus moves to the month shown rather than anywhere.
        .onAppear { focusedMonthOffset = calendar.monthOffset }
    }

    // MARK: - UI Components
    private var months: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(0..<pageCount, id: \.self) { offset in
                    FloatingDayCalendarMonthView(
                        month: DayPickerCalendar.Month(today: calendar.today, offset: offset),
                        offset: offset,
                        calendar: calendar,
                        rowHeight: layout.rowHeight,
                        focusedMonthOffset: $focusedMonthOffset,
                        onPage: page(by:),
                        onChoose: onChoose
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
        // A name field keeps focus, so typing can go on as soon as the calendar closes.
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
            calendar.page(to: offset)
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
        FloatingDayCalendarButtonsView(calendar: calendar, onChoose: onChoose)
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
            .accessibilityLabel(Text(.floatingDayCalendarClose))
        }
    }

    // MARK: - Actions
    private func page(by monthCount: Int) {
        guard calendar.page(by: monthCount) else {
            // The same haptic as a swipe before Today's month, so a refusal feels the same either way.
            refusedPageCount += 1
            return
        }
        // Once the month has scrolled in, VoiceOver moves to its header and reads its name.
        let offset = calendar.monthOffset
        Task { focusedMonthOffset = offset }
    }

    // MARK: - Helpers
    private var layout: FloatingDayCalendarLayout {
        FloatingDayCalendarLayout(
            availableHeight: availableHeight,
            headerHeight: headerHeight,
            buttonsHeight: buttonsHeight,
            padding: 2 * Self.pagePadding,
            isKeyboardUp: isKeyboardUp
        )
    }

    private var fullHeight: CGFloat {
        FloatingDayCalendarLayout.fullHeight(
            headerHeight: headerHeight,
            buttonsHeight: buttonsHeight,
            padding: 2 * Self.pagePadding
        )
    }
}
