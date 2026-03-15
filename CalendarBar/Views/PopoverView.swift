import SwiftUI

struct PopoverView: View {
    @ObservedObject var viewModel: CalendarViewModel

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.showSettings {
                SettingsView(viewModel: viewModel)
            } else if viewModel.isAuthenticated {
                authenticatedView
            } else {
                signInView
            }
        }
        .background(.ultraThinMaterial)
    }

    private var timedEvents: [CalendarEvent] {
        viewModel.displayedEvents.filter { !$0.isAllDay }
    }

    private var allDayEvents: [CalendarEvent] {
        viewModel.displayedEvents.filter { $0.isAllDay }
    }

    private var authenticatedView: some View {
        VStack(spacing: 0) {
            DayNavigationBar(
                dateLabel: viewModel.selectedDateLabel,
                onPrevious: { viewModel.navigateDay(by: -1) },
                onNext: { viewModel.navigateDay(by: 1) },
                onToday: { viewModel.goToToday() }
            )

            Divider()

            // All-day events banner
            if !allDayEvents.isEmpty {
                AllDayBanner(events: allDayEvents)
                Divider()
            }

            if timedEvents.isEmpty && allDayEvents.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "calendar")
                        .font(.system(size: 36))
                        .foregroundStyle(.tertiary)
                    Text("No events")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(height: 320)
            } else {
                DayTimelineView(
                    events: timedEvents,
                    selectedEventID: viewModel.selectedEvent?.id,
                    onSelectEvent: { event in
                        viewModel.selectEvent(event)
                    }
                )
            }

            Divider()

            JoinSection(event: viewModel.joinSectionEvent)

            Divider()

            bottomBar
        }
    }

    private var signInView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 44))
                .foregroundStyle(.blue)

            Text("CalendarBar")
                .font(.system(size: 20, weight: .semibold))

            Text("Connect your Google Calendar\nto see upcoming meetings.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button {
                viewModel.authenticate()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.plus")
                    Text("Sign in with Google")
                }
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Spacer()

            HStack {
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .font(.system(size: 12))
                .padding(14)
            }
        }
        .frame(width: 340, height: 520)
    }

    private var bottomBar: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.showSettings = true
                }
            } label: {
                Label("Settings", systemImage: "gear")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)

            Spacer()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .font(.system(size: 12))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
    }
}

// MARK: - All-Day Events Banner

struct AllDayBanner: View {
    let events: [CalendarEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(events) { event in
                HStack(spacing: 6) {
                    Circle()
                        .fill(event.calendarColor)
                        .frame(width: 8, height: 8)
                    Text(event.title)
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                    Spacer()
                    Text("All day")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(.quaternary.opacity(0.3))
    }
}
