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
        .background(
            ZStack {
                VisualEffectBackground()
                Color.black.opacity(0.3)
            }
        )
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
            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 1)

            JoinSection(event: viewModel.joinSectionEvent)

            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 1)

            bottomBar
        }
    }

    // MARK: - Empty States

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.15), .blue.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(.blue.opacity(0.7))
            }

            Text("All clear")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)

            Text("No events scheduled for this day")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var noMeetingsView: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.15), .orange.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                Image(systemName: "sun.max")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(.orange.opacity(0.7))
            }

            Text("No meetings")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)

            Text("Enjoy your free day")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.3))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

// MARK: - All-Day Events Banner

struct AllDayBanner: View {
    let events: [CalendarEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(events) { event in
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(event.calendarColor)
                        .frame(width: 3, height: 16)
                    Text(event.title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(1)
                    Spacer()
                    Text("ALL DAY")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white.opacity(0.3))
                        .tracking(0.8)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(RoundedRectangle(cornerRadius: 4).fill(.white.opacity(0.08)))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.white.opacity(0.04))
    }
}
