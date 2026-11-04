import FactoryKit
import SwiftUI

/// The quick-add panel for Tasks, which also edits one: renames it, or Moves it to another Day.
struct ComposerView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    // Focus state lives only in a view; it follows the view model's, which says where focus goes.
    @FocusState private var isNameFocused: Bool
    @AccessibilityFocusState private var isDayChipAccessibilityFocused: Bool

    // Animated reset, so a drag short of dismissing settles back instead of jumping.
    @GestureState(resetTransaction: Transaction(animation: .spring)) private var dragOffset: CGFloat = 0
    /// Whether the Day was last stepped forward.
    @State private var isDaySteppedForward = true
    /// Counts the Day steps, for a haptic on each.
    @State private var dayStepCount = 0
    /// Counts the steps refused before Today, for a bounce and a haptic on each.
    @State private var refusedDayStepCount = 0
    /// Counts the long presses that opened the Day picker, for a haptic on each.
    @State private var dayPickerPressCount = 0

    /// How far a swipe on the Day chip must go to step its Day.
    private let dayStepDistance: CGFloat = 24
    /// How long a press on the Day chip takes to open the Day picker.
    private let dayPickerPressDuration = 0.35
    /// How far a press on the Day chip can move before it's a swipe instead.
    private let dayPickerPressDistance: CGFloat = 10

    /// Whether the Day picker is up or closing; a drag ending meanwhile is the rest of the press that opened it.
    private var isDayPickerOpen: Bool {
        vm.dayPicker != nil
    }

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // TextField(_:text:) takes a catalog symbol only from iOS 26; on iOS 18 it goes through a Text.
            TextField(text: $vm.composer.taskName, prompt: Text(.composerTaskName)) {
                Text(.composerTaskName)
            }
            .focused($isNameFocused)
            // In step with the view model both ways, so it also learns of focus the field loses on its own.
            .onChange(of: vm.composer.isNameFocused, initial: true) { isNameFocused = vm.composer.isNameFocused }
            .onChange(of: isNameFocused) { vm.composer.isNameFocused = isNameFocused }
            // The Twitter layout has no Return key, so ▶ is the only submit on the software keyboard.
            .keyboardType(.twitter)
            .onSubmit(submit)
            HStack {
                dayChip
                Spacer()
                Button(action: submit) {
                    Image(systemName: "arrowtriangle.right.fill")
                        .font(.title3)
                }
                .disabled(!vm.composer.canSubmit)
                .accessibilityLabel(Text(vm.composer.editedTask == nil ? .taskAdd : .taskSave))
            }
        }
        .padding(16)
        .background(.background.secondary, in: .rect(cornerRadius: 20))
        .transformAnchorPreference(key: DayChipCalendarAnchorsKey.self, value: .bounds) { $0.composer = $1 }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
        .offset(y: max(dragOffset, 0))
        .gesture(dismissDrag)
        // A container, so VoiceOver's escape (two-finger scrub) from any of its elements dismisses, like the drag.
        .accessibilityElement(children: .contain)
        .accessibilityAction(.escape, vm.requestComposerDismissal)
        // Typing goes straight back to the name field.
        .onChange(of: vm.composer.taskName) { vm.closeDayChipCalendar() }
        .onChange(of: vm.composer.dayChipAccessibilityFocusCount) { isDayChipAccessibilityFocused = true }
    }

    // MARK: - UI Components
    private var dayChip: some View {
        let label = vm.composer.day.dayChipLabel(today: vm.today)
        // A container of its own, so a step slides the label within the capsule rather than the whole capsule.
        return ZStack {
            Text(label)
                .foregroundStyle(vm.composer.day.dayChipColor(today: vm.today))
                // A new identity per Day, so a step slides the old label out and the new one in.
                .id(vm.composer.day)
                .transition(.push(from: isDaySteppedForward ? .trailing : .leading))
        }
            .font(.subheadline)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(.fill.tertiary, in: .capsule)
            .clipShape(.capsule)
            .keyframeAnimator(initialValue: 0, trigger: refusedDayStepCount) { chip, offset in
                chip.offset(x: offset)
            } keyframes: { _ in
                // Nudged the way the swipe went, toward the Days it can't reach.
                SpringKeyframe(isDaySteppedForward ? -8 : 8, duration: 0.1)
                SpringKeyframe(0, duration: 0.3)
            }
            .contentShape(.capsule)
            .transformAnchorPreference(key: DayChipCalendarAnchorsKey.self, value: .bounds) { $0.chip = $1 }
            .gesture(dayChipPress)
            .simultaneousGesture(dayStepSwipe)
            .sensoryFeedback(.selection, trigger: dayStepCount)
            .sensoryFeedback(.impact(weight: .medium), trigger: dayPickerPressCount)
            .sensoryFeedback(.refusal, trigger: refusedDayStepCount)
            .accessibilityElement()
            .accessibilityLabel(Text(.composerDay))
            .accessibilityValue(label)
            .accessibilityHint(Text(.composerDayHint))
            .accessibilityAddTraits(.isButton)
            // A double-tap opens the calendar, as a tap does, while swiping up or down still steps.
            .accessibilityAction(.default, vm.toggleDayChipCalendar)
            // VoiceOver's way to the long press, which it can't make.
            .accessibilityAction(named: Text(.taskChooseDay), vm.showComposerDayPicker)
            .accessibilityFocused($isDayChipAccessibilityFocused)
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: stepDay(forward: true)
                case .decrement: stepDay(forward: false)
                @unknown default: break
                }
            }
    }

    // MARK: - Actions
    private func stepDay(forward: Bool) {
        guard forward == isDaySteppedForward else {
            // A label leaves with the transition it was last drawn with, so a turn is drawn first, then stepped.
            isDaySteppedForward = forward
            Task { stepDay(forward: forward) }
            return
        }
        let isStepped = withAnimation(.snappy(duration: 0.25)) {
            vm.stepComposerDay(forward: forward)
        }
        if isStepped {
            dayStepCount += 1
        } else {
            refusedDayStepCount += 1
        }
    }

    private func submit() {
        vm.submitComposer()
        // Within the action, as Return drops focus right after it; the view model's focus hasn't changed to say so.
        isNameFocused = vm.composer.isNameFocused
    }

    // MARK: - Gestures
    private var dismissDrag: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, offset, _ in
                // The rest of the press that opened the Day picker leaves the panel where it was.
                offset = isDayPickerOpen ? 0 : value.translation.height
            }
            .onEnded { value in
                if !isDayPickerOpen, value.dismissesComposer {
                    vm.requestComposerDismissal()
                }
            }
    }

    /// A long press opens the Day picker, and a shorter tap the Day chip calendar.
    private var dayChipPress: some Gesture {
        // The tap waits only for the press to fail, which a lift does at once.
        LongPressGesture(minimumDuration: dayPickerPressDuration, maximumDistance: dayPickerPressDistance)
            .onEnded { _ in
                dayPickerPressCount += 1
                vm.showComposerDayPicker()
            }
            .exclusively(before: TapGesture().onEnded { vm.toggleDayChipCalendar() })
    }

    /// A swipe left steps to the next Day, and a swipe right to the one before, as a calendar pages.
    private var dayStepSwipe: some Gesture {
        DragGesture()
            .onEnded { value in
                let width = value.translation.width
                // Mostly sideways, so a drag down from the chip only dismisses. The rest of the press that opened the
                // Day picker steps nothing.
                guard !isDayPickerOpen, abs(width) > abs(value.translation.height) else { return }
                let isFlung = abs(value.predictedEndTranslation.width) > dayStepDistance * 2
                if abs(width) > dayStepDistance || isFlung {
                    stepDay(forward: width < 0)
                }
            }
    }
}

#Preview("Adding") {
    ComposerView()
        .frame(maxHeight: .infinity, alignment: .bottom)
}

#Preview("Editing") {
    ComposerView()
        .frame(maxHeight: .infinity, alignment: .bottom)
        // The view resolves the same shared view model.
        .onAppear { Container.shared.scheduleViewModel().showComposer(editing: .previewIncomplete) }
}
