import SwiftUI

struct CreateEventView: View {
    @ObservedObject var viewModel: CalendarViewModel
    var editingEvent: CalendarEvent? = nil

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

    // Guest management
    @State private var guestInput: String = ""
    @State private var guests: [EventAttendee] = []

    // Delete confirmation (edit mode)
    @State private var showDeleteConfirm = false
    @State private var isDeleting = false

    private let durations = [15, 30, 45, 60, 90, 120]

    private var isEditMode: Bool { editingEvent != nil }

    var body: some View {
        VStack(spacing: 0) {
            header

            Rectangle().fill(.white.opacity(0.08)).frame(height: 1)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if LicenseManager.shared.isPro {
                        if isEditMode {
                            manualForm
                            guestSection
                            if let error = errorMessage {
                                errorBanner(error)
                            }
                            saveButton
                            if showSuccess {
                                successBanner
                            }
                            deleteSection
                        } else {
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

                            guestSection

                            // Error message
                            if let error = errorMessage {
                                errorBanner(error)
                            }

                            createButton

                            if showSuccess {
                                successBanner
                            }
                        }
                    } else {
                        proGate
                    }
                }
                .padding(16)
            }
        }
        .frame(width: 340, height: 520)
        .onAppear {
            if let event = editingEvent {
                title = event.title
                startDate = event.startDate
                selectedDuration = event.durationMinutes
                guests = event.attendees
                showManualForm = true
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if isEditMode {
                        viewModel.showEditEvent = nil
                    } else {
                        viewModel.showCreateEvent = false
                    }
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
            .accessibilityLabel("Go back")

            Spacer()

            Text(isEditMode ? "Edit Event" : "New Event")
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
            Text(isEditMode ? "EVENT DETAILS" : "MANUAL ENTRY")
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

            // Date
            VStack(alignment: .leading, spacing: 6) {
                Text("Date")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))

                // Quick date chips
                HStack(spacing: 6) {
                    dateChip("Today", date: Date.now)
                    dateChip("Tomorrow", date: Calendar.current.date(byAdding: .day, value: 1, to: Date.now) ?? Date.now)
                    dateChip("Day After", date: Calendar.current.date(byAdding: .day, value: 2, to: Date.now) ?? Date.now)
                }

                // Fallback full picker (hidden behind "Pick date" button)
                DatePicker("", selection: $startDate, in: Date.now..., displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .scaleEffect(0.85, anchor: .leading)
            }

            // Time
            VStack(alignment: .leading, spacing: 6) {
                Text("Time")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))

                // Quick time chips (common meeting times)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach([9, 10, 11, 12, 13, 14, 15, 16, 17], id: \.self) { hour in
                            timeChip(hour: hour, minute: 0)
                            timeChip(hour: hour, minute: 30)
                        }
                    }
                }

                // Fallback time picker
                DatePicker("", selection: $startDate, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .scaleEffect(0.85, anchor: .leading)
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
                        .accessibilityLabel("Duration \(durationLabel(mins))")
                    }
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 10).fill(.white.opacity(0.04)))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(.white.opacity(0.08), lineWidth: 1))
    }

    // MARK: - Guest Section

    private var guestSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("GUESTS")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.3))
                .tracking(1)

            // Guest chips
            if !guests.isEmpty {
                guestChips
            }

            // Input with autocomplete
            VStack(spacing: 0) {
                TextField("Add guest email", text: $guestInput)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))
                    .disableAutocorrection(true)
                    .textContentType(.none)
                    .onSubmit {
                        addGuestFromInput()
                    }

                if !filteredSuggestions.isEmpty {
                    autocompleteDropdown
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 10).fill(.white.opacity(0.04)))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(.white.opacity(0.08), lineWidth: 1))
    }

    private var guestChips: some View {
        FlowLayout(spacing: 6) {
            ForEach(guests) { guest in
                guestChip(guest)
            }
        }
    }

    private func guestChip(_ guest: EventAttendee) -> some View {
        HStack(spacing: 5) {
            // Colored circle with first letter
            ZStack {
                Circle()
                    .fill(colorForEmail(guest.email))
                    .frame(width: 18, height: 18)
                Text(String((guest.name ?? guest.email).prefix(1)).uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
            }

            Text(guest.name ?? guest.email)
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.8))
                .lineLimit(1)

            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    guests.removeAll { $0.email == guest.email }
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
                    .frame(width: 14, height: 14)
                    .background(.white.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove \(guest.name ?? guest.email)")
        }
        .padding(.leading, 3)
        .padding(.trailing, 5)
        .padding(.vertical, 4)
        .background(RoundedRectangle(cornerRadius: 14).fill(.white.opacity(0.08)))
        .transition(.scale.combined(with: .opacity))
    }

    private var autocompleteDropdown: some View {
        VStack(spacing: 0) {
            ForEach(filteredSuggestions) { suggestion in
                Button {
                    addGuest(suggestion)
                } label: {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(colorForEmail(suggestion.email))
                                .frame(width: 22, height: 22)
                            Text(String((suggestion.name ?? suggestion.email).prefix(1)).uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            if let name = suggestion.name {
                                Text(name)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.8))
                                    .lineLimit(1)
                            }
                            Text(suggestion.email)
                                .font(.system(size: 10))
                                .foregroundStyle(.white.opacity(0.4))
                                .lineLimit(1)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if suggestion.id != filteredSuggestions.last?.id {
                    Rectangle().fill(.white.opacity(0.06)).frame(height: 1)
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.black.opacity(0.6)))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(.white.opacity(0.1), lineWidth: 1))
        .padding(.top, 4)
    }

    var filteredSuggestions: [EventAttendee] {
        guard !guestInput.isEmpty else { return [] }
        let query = guestInput.lowercased()
        return Array(
            viewModel.knownAttendees
                .filter { attendee in
                    !guests.contains(where: { $0.email == attendee.email }) &&
                    (attendee.email.lowercased().contains(query) ||
                     (attendee.name?.lowercased().contains(query) ?? false))
                }
                .prefix(5)
        )
    }

    private func addGuestFromInput() {
        let email = guestInput.trimmingCharacters(in: .whitespaces).lowercased()
        guard !email.isEmpty, email.contains("@"), email.contains(".") else { return }
        guard !guests.contains(where: { $0.email == email }) else {
            guestInput = ""
            return
        }
        let existingName = viewModel.knownAttendees.first(where: { $0.email == email })?.name
        let attendee = EventAttendee(email: email, name: existingName)
        withAnimation(.easeInOut(duration: 0.15)) {
            guests.append(attendee)
        }
        guestInput = ""
    }

    private func addGuest(_ attendee: EventAttendee) {
        guard !guests.contains(where: { $0.email == attendee.email }) else { return }
        withAnimation(.easeInOut(duration: 0.15)) {
            guests.append(attendee)
        }
        guestInput = ""
    }

    private func colorForEmail(_ email: String) -> Color {
        let colors: [Color] = [.blue, .purple, .orange, .green, .pink, .teal, .indigo]
        let hash = abs(email.hashValue)
        return colors[hash % colors.count]
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
        .accessibilityLabel("Create event")
    }

    // MARK: - Save Button (Edit Mode)

    private var saveButton: some View {
        Button {
            Task { await saveEvent() }
        } label: {
            HStack(spacing: 8) {
                if isCreating {
                    ProgressView()
                        .controlSize(.small)
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                }
                Text(isCreating ? "Saving..." : "Save Changes")
                    .font(.system(size: 14, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    colors: canSave ? [.blue, .blue.opacity(0.8)] : [.gray.opacity(0.3), .gray.opacity(0.2)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundStyle(canSave ? .white : .white.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .disabled(!canSave || isCreating)
        .accessibilityLabel("Save changes")
    }

    // MARK: - Delete Section (Edit Mode)

    private var deleteSection: some View {
        VStack(spacing: 8) {
            if showDeleteConfirm {
                HStack(spacing: 8) {
                    Text("Delete this event?")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))

                    Spacer()

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showDeleteConfirm = false
                        }
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Cancel delete")

                    Button {
                        Task { await deleteEvent() }
                    } label: {
                        HStack(spacing: 4) {
                            if isDeleting {
                                ProgressView()
                                    .controlSize(.small)
                                    .scaleEffect(0.7)
                            }
                            Text("Delete")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.red.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                    .disabled(isDeleting)
                    .accessibilityLabel("Confirm delete event")
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 10).fill(.red.opacity(0.06)))
                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(.red.opacity(0.15), lineWidth: 1))
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showDeleteConfirm = true
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                        Text("Delete Event")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .foregroundStyle(.red.opacity(0.7))
                    .background(RoundedRectangle(cornerRadius: 10).fill(.red.opacity(0.06)))
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(.red.opacity(0.12), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Delete event")
            }
        }
    }

    // MARK: - Success Banner

    private var successBanner: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 13))
            Text(isEditMode ? "Event updated!" : "Event created!")
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

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func createEvent() async {
        isCreating = true
        errorMessage = nil
        let result: GoogleCalendarService.CreateResult

        if let parsed = parsedEvent {
            result = await viewModel.googleService.createEvent(
                title: parsed.title,
                startDate: parsed.startDate,
                endDate: parsed.endDate,
                attendees: guests
            )
        } else {
            let endDate = startDate.addingTimeInterval(TimeInterval(selectedDuration * 60))
            result = await viewModel.googleService.createEvent(
                title: title,
                startDate: startDate,
                endDate: endDate,
                attendees: guests
            )
        }

        isCreating = false

        switch result {
        case .success:
            showSuccess = true
            naturalInput = ""
            parsedEvent = nil
            title = ""
            guests = []

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

    private func saveEvent() async {
        guard let event = editingEvent else { return }
        isCreating = true
        errorMessage = nil

        let endDate = startDate.addingTimeInterval(TimeInterval(selectedDuration * 60))
        let result = await viewModel.googleService.editEvent(
            eventId: event.id,
            title: title,
            startDate: startDate,
            endDate: endDate,
            attendees: guests
        )

        isCreating = false

        switch result {
        case .success:
            showSuccess = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                viewModel.refreshAll()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    viewModel.showEditEvent = nil
                }
            }

        case .error(let message):
            errorMessage = message
        }
    }

    private func deleteEvent() async {
        guard let event = editingEvent else { return }
        isDeleting = true
        errorMessage = nil

        let result = await viewModel.googleService.deleteEvent(eventId: event.id)

        isDeleting = false

        switch result {
        case .success:
            viewModel.selectedEvent = nil
            viewModel.refreshAll()
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.showEditEvent = nil
            }

        case .error(let message):
            errorMessage = message
            showDeleteConfirm = false
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

    // MARK: - Date/Time Chips

    private func dateChip(_ label: String, date: Date) -> some View {
        let cal = Calendar.current
        let isSelected = cal.isDate(startDate, inSameDayAs: date)
        return Button {
            // Preserve the current time, just change the date
            var components = cal.dateComponents([.hour, .minute], from: startDate)
            let dayComponents = cal.dateComponents([.year, .month, .day], from: date)
            components.year = dayComponents.year
            components.month = dayComponents.month
            components.day = dayComponents.day
            if let newDate = cal.date(from: components) {
                startDate = newDate
            }
        } label: {
            Text(label)
                .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.5))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? .blue.opacity(0.3) : .white.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(isSelected ? .blue.opacity(0.5) : .clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func timeChip(hour: Int, minute: Int) -> some View {
        let cal = Calendar.current
        let currentHour = cal.component(.hour, from: startDate)
        let currentMinute = cal.component(.minute, from: startDate)
        let isSelected = currentHour == hour && currentMinute == minute

        let label: String = {
            let h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
            let period = hour >= 12 ? "PM" : "AM"
            return minute == 0 ? "\(h) \(period)" : "\(h):\(String(format: "%02d", minute)) \(period)"
        }()

        return Button {
            var components = cal.dateComponents([.year, .month, .day], from: startDate)
            components.hour = hour
            components.minute = minute
            if let newDate = cal.date(from: components) {
                startDate = newDate
            }
        } label: {
            Text(label)
                .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.5))
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(isSelected ? .blue.opacity(0.3) : .white.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .strokeBorder(isSelected ? .blue.opacity(0.5) : .clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow Layout (wrapping horizontal layout for guest chips)

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private struct ArrangeResult {
        var positions: [CGPoint]
        var size: CGSize
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> ArrangeResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            totalHeight = currentY + lineHeight
            currentX += size.width + spacing
        }

        return ArrangeResult(
            positions: positions,
            size: CGSize(width: maxWidth, height: totalHeight)
        )
    }
}
