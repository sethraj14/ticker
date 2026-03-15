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

    private var authenticatedView: some View {
        VStack(spacing: 0) {
            DayNavigationBar(
                dateLabel: viewModel.selectedDateLabel,
                onPrevious: { viewModel.navigateDay(by: -1) },
                onNext: { viewModel.navigateDay(by: 1) },
                onToday: { viewModel.goToToday() }
            )

            Divider()

            if viewModel.events.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 32))
                        .foregroundStyle(.tertiary)
                    Text("No events")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(height: 320)
            } else {
                DayTimelineView(events: viewModel.events)
            }

            Divider()

            JoinSection(event: viewModel.nextUpcomingEvent)

            Divider()

            bottomBar
        }
    }

    private var signInView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 40))
                .foregroundStyle(.blue)

            Text("CalendarBar")
                .font(.system(size: 18, weight: .semibold))

            Text("Connect your Google Calendar to see upcoming meetings.")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button {
                viewModel.authenticate()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "person.crop.circle.badge.plus")
                    Text("Sign in with Google")
                }
                .font(.system(size: 13, weight: .medium))
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
                .font(.caption)
                .padding(12)
            }
        }
        .frame(width: 320, height: 480)
    }

    private var bottomBar: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.showSettings = true
                }
            } label: {
                Label("Settings", systemImage: "gear")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Spacer()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
}
