import SwiftUI
import AppKit

// MARK: - macOS Frosted Glass Background

struct VisualEffectBackground: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    init(
        material: NSVisualEffectView.Material = .hudWindow,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    ) {
        self.material = material
        self.blendingMode = blendingMode
    }

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.isEmphasized = true
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// MARK: - Main Popover

struct PopoverView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView(viewModel: viewModel, hasCompletedOnboarding: $hasCompletedOnboarding)
            } else if let editEvent = viewModel.showEditEvent {
                CreateEventView(viewModel: viewModel, editingEvent: editEvent)
            } else if viewModel.showCreateEvent {
                CreateEventView(viewModel: viewModel)
            } else if viewModel.showSettings {
                SettingsView(viewModel: viewModel)
            } else if viewModel.isAuthenticated {
                authenticatedView
            } else {
                signInView
            }
        }
        .frame(width: 340, height: 520)
        .background(
            ZStack {
                VisualEffectBackground()
                Color.black.opacity(0.3)
            }
        )
        .onAppear {
            // Reset state every time the popover opens
            viewModel.goToToday()
            viewModel.showCreateEvent = false
            viewModel.showEditEvent = nil
            viewModel.showSettings = false
        }
    }

    private var timedEvents: [CalendarEvent] {
        viewModel.displayedEvents.filter { !$0.isAllDay }
    }

    private var allDayEvents: [CalendarEvent] {
        viewModel.displayedEvents.filter { $0.isAllDay }
    }

    // MARK: - Authenticated View

    private var authenticatedView: some View {
        VStack(spacing: 0) {
            // HEADER
            DayNavigationBar(
                dateLabel: viewModel.selectedDateLabel,
                onPrevious: { viewModel.navigateDay(by: -1) },
                onNext: { viewModel.navigateDay(by: 1) },
                onToday: { viewModel.goToToday() },
                isPro: LicenseManager.shared.isPro
            )

            // Day stats bar
            if !timedEvents.isEmpty {
                DayStatsBar(events: timedEvents)
            }

            // Subtle divider
            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 1)

            // MIDDLE
            VStack(spacing: 0) {
                if !allDayEvents.isEmpty {
                    AllDayBanner(events: allDayEvents)
                    Rectangle()
                        .fill(.white.opacity(0.08))
                        .frame(height: 1)
                }

                if timedEvents.isEmpty && allDayEvents.isEmpty {
                    EmptyDayView()
                } else if timedEvents.isEmpty {
                    NoMeetingsView()
                } else {
                    DayTimelineView(
                        events: timedEvents,
                        selectedEventID: viewModel.selectedEvent?.id,
                        isToday: Calendar.current.isDateInToday(viewModel.selectedDate),
                        selectedDate: viewModel.selectedDate,
                        onSelectEvent: { event in
                            viewModel.selectEvent(event)
                        },
                        onCreateAtTime: { date, endDate in
                            guard LicenseManager.shared.isPro else { return }
                            viewModel.createEventStartDate = date
                            viewModel.createEventEndDate = endDate
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.showCreateEvent = true
                            }
                        },
                        onResizeEvent: { event, newEndDate in
                            Task {
                                let result = await viewModel.googleService.editEvent(
                                    eventId: event.id,
                                    title: event.title,
                                    startDate: event.startDate,
                                    endDate: newEndDate,
                                    attendees: event.attendees
                                )
                                await MainActor.run {
                                    if case .success = result {
                                        viewModel.refreshAll()
                                    }
                                }
                            }
                        },
                        onMoveEvent: { event, newStart, newEnd in
                            Task {
                                let result = await viewModel.googleService.editEvent(
                                    eventId: event.id,
                                    title: event.title,
                                    startDate: newStart,
                                    endDate: newEnd,
                                    attendees: event.attendees
                                )
                                await MainActor.run {
                                    if case .success = result {
                                        viewModel.refreshAll()
                                    }
                                }
                            }
                        }
                    )
                }
            }
            .frame(maxHeight: .infinity)

            // FOOTER
            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 1)

            JoinSection(
                event: viewModel.joinSectionEvent,
                isToday: Calendar.current.isDateInToday(viewModel.selectedDate),
                allTimedEvents: timedEvents,
                onEdit: { event in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.showEditEvent = event
                    }
                },
                onDelete: { event in
                    Task {
                        let result = await viewModel.googleService.deleteEvent(eventId: event.id)
                        await MainActor.run {
                            switch result {
                            case .success:
                                viewModel.selectedEvent = nil
                                viewModel.refreshAll()
                            case .error:
                                break
                            }
                        }
                    }
                },
                onRSVP: { event, status in
                    Task {
                        let result = await viewModel.googleService.rsvpEvent(
                            eventId: event.id,
                            status: status
                        )
                        await MainActor.run {
                            if case .success = result {
                                viewModel.refreshAll()
                                // Re-select event from fresh data so JoinSection updates
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    if let fresh = viewModel.displayedEvents.first(where: { $0.id == event.id }) {
                                        viewModel.selectedEvent = fresh
                                    }
                                }
                            }
                        }
                    }
                }
            )

            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 1)

            // Upgrade footer (free users only)
            if !LicenseManager.shared.isPro {
                Button {
                    if let url = URL(string: LicenseManager.checkoutURL) {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10))
                        Text("Upgrade to Pro")
                            .font(.system(size: 11, weight: .medium))
                        Spacer()
                        Text(LicenseManager.priceDisplay)
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Upgrade to Ticker Pro for seven ninety-nine")

                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 1)
            }

            bottomBar
        }
    }

    // MARK: - Sign In

    private var signInView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.2), .purple.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 88, height: 88)
                    Image(systemName: "timer")
                        .font(.system(size: 36, weight: .light))
                        .foregroundStyle(.white.opacity(0.8))
                }

                VStack(spacing: 8) {
                    Text("Ticker")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Your meetings, always in sight")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.5))
                }

                Text("Connect your Google Calendar to see\nupcoming meetings and join with one click.")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.3))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)

                Button {
                    viewModel.addAccount()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.badge.plus")
                        Text("Sign in with Google")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: 220)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }

            Spacer()

            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 1)

            HStack {
                Spacer()
                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Image(systemName: "power")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.3))
                        .frame(width: 28, height: 28)
                        .background(.white.opacity(0.06))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .accessibilityLabel("Quit Ticker")
            }
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.showSettings = true
                }
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.4))
                    .frame(width: 32, height: 32)
                    .background(.white.opacity(0.06))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .accessibilityLabel("Settings")

            Button {
                if LicenseManager.shared.isPro {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.showCreateEvent = true
                    }
                } else {
                    if let url = URL(string: LicenseManager.checkoutURL) {
                        NSWorkspace.shared.open(url)
                    }
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.4))
                    .frame(width: 32, height: 32)
                    .background(.white.opacity(0.06))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(LicenseManager.shared.isPro ? "Create event" : "Upgrade to Pro to create events")

            Spacer()

            Button {
                viewModel.fetchEvents()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.4))
                    .frame(width: 32, height: 32)
                    .background(.white.opacity(0.06))
                    .clipShape(Circle())
                    .rotationEffect(.degrees(viewModel.isSyncing ? 360 : 0))
                    .animation(
                        viewModel.isSyncing
                            ? .linear(duration: 1).repeatForever(autoreverses: false)
                            : .default,
                        value: viewModel.isSyncing
                    )
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isSyncing)
            .accessibilityLabel("Refresh events")

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "power")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.4))
                    .frame(width: 32, height: 32)
                    .background(.white.opacity(0.06))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .accessibilityLabel("Quit Ticker")
        }
    }
}
