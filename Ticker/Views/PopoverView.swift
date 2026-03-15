import SwiftUI

struct PopoverView: View {
    @ObservedObject var viewModel: CalendarViewModel

    var body: some View {
        Group {
            if viewModel.showSettings {
                SettingsView(viewModel: viewModel)
            } else if viewModel.isAuthenticated {
                authenticatedView
            } else {
                signInView
            }
        }
        .frame(width: 340, height: 520)
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
            // HEADER
            DayNavigationBar(
                dateLabel: viewModel.selectedDateLabel,
                onPrevious: { viewModel.navigateDay(by: -1) },
                onNext: { viewModel.navigateDay(by: 1) },
                onToday: { viewModel.goToToday() }
            )

            Divider()

            // MIDDLE
            VStack(spacing: 0) {
                if !allDayEvents.isEmpty {
                    AllDayBanner(events: allDayEvents)
                    Divider()
                }

                if timedEvents.isEmpty && allDayEvents.isEmpty {
                    emptyStateView
                } else if timedEvents.isEmpty {
                    noMeetingsView
                } else {
                    DayTimelineView(
                        events: timedEvents,
                        selectedEventID: viewModel.selectedEvent?.id,
                        onSelectEvent: { event in
                            viewModel.selectEvent(event)
                        }
                    )
                }
            }
            .frame(maxHeight: .infinity)

            // FOOTER
            Divider()

            JoinSection(event: viewModel.joinSectionEvent)

            Divider()

            bottomBar
        }
    }

    // Completely empty day
    private var emptyStateView: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.blue.opacity(0.08))
                    .frame(width: 72, height: 72)
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 32))
                    .foregroundStyle(.blue.opacity(0.5))
            }

            Text("All clear")
                .font(.system(size: 16, weight: .semibold))

            Text("No events scheduled for this day")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // Has holidays/all-day but no timed meetings
    private var noMeetingsView: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.orange.opacity(0.08))
                    .frame(width: 64, height: 64)
                Image(systemName: "sun.max")
                    .font(.system(size: 28))
                    .foregroundStyle(.orange.opacity(0.5))
            }

            Text("No meetings")
                .font(.system(size: 15, weight: .semibold))

            Text("Enjoy your free day")
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var signInView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(.blue.opacity(0.1))
                        .frame(width: 88, height: 88)
                    Image(systemName: "timer")
                        .font(.system(size: 36))
                        .foregroundStyle(.blue)
                }

                VStack(spacing: 6) {
                    Text("Ticker")
                        .font(.system(size: 22, weight: .bold))
                    Text("Your meetings, always in sight")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                Text("Connect your Google Calendar to see\nupcoming meetings and join with one click.")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)

                Button {
                    viewModel.addAccount()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.badge.plus")
                        Text("Sign in with Google")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .frame(maxWidth: 220)
                    .padding(.vertical, 3)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }

            Spacer()

            Divider()

            HStack {
                Spacer()
                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Image(systemName: "power")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
            }
        }
    }

    private var bottomBar: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.showSettings = true
                }
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 13))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            Spacer()

            Button {
                viewModel.fetchEvents()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 12))
                    .rotationEffect(.degrees(viewModel.isSyncing ? 360 : 0))
                    .animation(
                        viewModel.isSyncing
                            ? .linear(duration: 1).repeatForever(autoreverses: false)
                            : .default,
                        value: viewModel.isSyncing
                    )
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .disabled(viewModel.isSyncing)
            .padding(.vertical, 10)

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "power")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
    }
}

// MARK: - All-Day Events Banner

struct AllDayBanner: View {
    let events: [CalendarEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(events) { event in
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(event.calendarColor)
                        .frame(width: 4, height: 16)
                    Text(event.title)
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                    Spacer()
                    Text("All day")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(RoundedRectangle(cornerRadius: 4).fill(.quaternary.opacity(0.5)))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.quaternary.opacity(0.15))
    }
}
