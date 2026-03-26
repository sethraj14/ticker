import SwiftUI

struct CreateEventView: View {
    @ObservedObject var viewModel: CalendarViewModel

    @State private var naturalInput: String = ""
    @State private var parsedEvent: ParsedEvent?

    // Manual form fallback
    @State private var title: String = ""
    @State private var startDate: Date = {
        let calendar = Calendar.current
        let now = Date.now
        let minute = calendar.component(.minute, from: now)
        // Round up to next 15-minute mark
        let roundedMinute = ((minute / 15) + 1) * 15
        return calendar.date(bySetting: .minute, value: roundedMinute, of: now) ?? now
    }()
    @State private var selectedDuration: Int = 30 // minutes
    @State private var isCreating = false
    @State private var showSuccess = false
    @State private var errorMessage: String?
    @State private var showManualForm = false

    private let durations = [15, 30, 45, 60, 90, 120]

    var body: some View {
        VStack(spacing: 0) {
            header

            Rectangle().fill(.white.opacity(0.08)).frame(height: 1)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if LicenseManager.shared.isPro {
                        // Mode toggle: Quick Add vs Manual
                        modePicker

                        if !showManualForm {
                            naturalLanguageSection

                            if let parsed = parsedEvent {
                                parsedPreview(parsed)
                            }
                        } else {
                            manualForm
                        }

                        // Error message
                        if let error = errorMessage {
                            errorBanner(error)
                        }

                        createButton

                        if showSuccess {
                            successBanner
                        }
                    } else {
                        proGate
                    }
                }
                .padding(16)
            }
        }
        .frame(width: 340, height: 520)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.showCreateEvent = false
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 13))
                }
                .foregroundStyle(.white.opacity(0.5))
                .frame(height: 30)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()

            Text("New Event")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))

            Spacer()

            // Invisible spacer to center title
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12, weight: .semibold))
                Text("Back")
                    .font(.system(size: 13))
            }
            .hidden()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Natural Language Section

    private var naturalLanguageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("QUICK ADD")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.3))
                .tracking(1)

            TextField("Team sync tomorrow 3pm 45min", text: $naturalInput)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 13))
                .disableAutocorrection(true)
                .textContentType(.none)
                .onChange(of: naturalInput) { newValue in
                    parsedEvent = NaturalLanguageParser.parse(newValue)
                }

            Text("Type a title with date, time, and duration")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.25))
        }
    }

    // MARK: - Parsed Preview

    private func parsedPreview(_ parsed: ParsedEvent) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.green.opacity(0.8))
                Text("Ready to create")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.green.opacity(0.8))
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "text.quote")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.4))
                        .frame(width: 16)
                    Text(parsed.title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                }

                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.4))
                        .frame(width: 16)
                    Text(parsed.startDate.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()))
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.6))
                }

                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.4))
                        .frame(width: 16)
                    Text("\(parsed.startDate.formatted(date: .omitted, time: .shortened)) - \(parsed.endDate.formatted(date: .omitted, time: .shortened))")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.6))
                }

                HStack(spacing: 8) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.4))
                        .frame(width: 16)
                    Text(formatDuration(parsed.duration))
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(.green.opacity(0.06)))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(.green.opacity(0.15), lineWidth: 1))
    }

    // MARK: - Mode Picker

    private var modePicker: some View {
        HStack(spacing: 0) {
            modeButton(label: "Quick Add", icon: "bolt.fill", isActive: !showManualForm) {
                withAnimation(.easeInOut(duration: 0.2)) { showManualForm = false }
            }
            modeButton(label: "Manual", icon: "square.and.pencil", isActive: showManualForm) {
                withAnimation(.easeInOut(duration: 0.2)) { showManualForm = true }
            }
        }
        .background(RoundedRectangle(cornerRadius: 8).fill(.white.opacity(0.06)))
    }

    private func modeButton(label: String, icon: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(label)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(isActive ? .white : .white.opacity(0.35))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isActive ? RoundedRectangle(cornerRadius: 7).fill(.white.opacity(0.1)) : nil)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Error Banner

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 11))
            Text(message)
                .font(.system(size: 11))
                .lineLimit(3)
        }
        .foregroundStyle(.orange)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(.orange.opacity(0.1)))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(.orange.opacity(0.2), lineWidth: 1))
    }

    // MARK: - Manual Form

    private var manualForm: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("MANUAL ENTRY")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.3))
                .tracking(1)

            // Title
            VStack(alignment: .leading, spacing: 4) {
                Text("Title")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))
                TextField("Event title", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 13))
                    .disableAutocorrection(true)
                    .textContentType(.none)
            }

            // Date & Time
            VStack(alignment: .leading, spacing: 4) {
                Text("Date & Time")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))
                DatePicker("", selection: $startDate, in: Date.now...)
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }

            // Duration
            VStack(alignment: .leading, spacing: 6) {
                Text("Duration")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))

                HStack(spacing: 6) {
                    ForEach(durations, id: \.self) { mins in
                        Button {
                            selectedDuration = mins
                        } label: {
                            Text(durationLabel(mins))
                                .font(.system(size: 11, weight: selectedDuration == mins ? .semibold : .regular))
                                .foregroundStyle(selectedDuration == mins ? .white : .white.opacity(0.5))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(selectedDuration == mins ? .blue.opacity(0.3) : .white.opacity(0.06))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .strokeBorder(selectedDuration == mins ? .blue.opacity(0.5) : .clear, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 10).fill(.white.opacity(0.04)))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(.white.opacity(0.08), lineWidth: 1))
    }

    // MARK: - Create Button

    private var createButton: some View {
        Button {
            Task { await createEvent() }
        } label: {
            HStack(spacing: 8) {
                if isCreating {
                    ProgressView()
                        .controlSize(.small)
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14))
                }
                Text(isCreating ? "Creating..." : "Create Event")
                    .font(.system(size: 14, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    colors: canCreate ? [.blue, .blue.opacity(0.8)] : [.gray.opacity(0.3), .gray.opacity(0.2)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundStyle(canCreate ? .white : .white.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .disabled(!canCreate || isCreating)
    }

    // MARK: - Success Banner

    private var successBanner: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 13))
            Text("Event created!")
                .font(.system(size: 13, weight: .medium))
        }
        .foregroundStyle(.green)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 10).fill(.green.opacity(0.1)))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(.green.opacity(0.2), lineWidth: 1))
    }

    // MARK: - Pro Gate

    private var proGate: some View {
        VStack(spacing: 16) {
            Spacer()
            VStack(spacing: 10) {
                HStack(spacing: 6) {
                    Text("EVENT CREATION")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.3))
                        .tracking(1)
                    ProBadge()
                }
                UpgradePrompt(feature: "Create events with natural language from your menu bar")
            }
            Spacer()
        }
    }

    // MARK: - Helpers

    private var canCreate: Bool {
        if parsedEvent != nil { return true }
        if showManualForm && !title.trimmingCharacters(in: .whitespaces).isEmpty { return true }
        return false
    }

    private func createEvent() async {
        isCreating = true
        errorMessage = nil
        let result: GoogleCalendarService.CreateResult

        if let parsed = parsedEvent {
            result = await viewModel.googleService.createEvent(
                title: parsed.title,
                startDate: parsed.startDate,
                endDate: parsed.endDate
            )
        } else {
            let endDate = startDate.addingTimeInterval(TimeInterval(selectedDuration * 60))
            result = await viewModel.googleService.createEvent(
                title: title,
                startDate: startDate,
                endDate: endDate
            )
        }

        isCreating = false

        switch result {
        case .success:
            showSuccess = true
            naturalInput = ""
            parsedEvent = nil
            title = ""

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                viewModel.refreshAll()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { showSuccess = false }
            }

        case .error(let message):
            errorMessage = message
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds / 60)
        if mins < 60 { return "\(mins) min" }
        let hours = mins / 60
        let remainder = mins % 60
        if remainder == 0 { return "\(hours)h" }
        return "\(hours)h \(remainder)m"
    }

    private func durationLabel(_ mins: Int) -> String {
        if mins < 60 { return "\(mins)m" }
        let h = mins / 60
        let m = mins % 60
        if m == 0 { return "\(h)h" }
        return "\(h).\(m * 10 / 60)h"
    }
}
