import SwiftUI

struct PopoverView: View {
    @ObservedObject var viewModel: CalendarViewModel

    var body: some View {
        VStack(spacing: 0) {
            DayNavigationBar(
                dateLabel: viewModel.selectedDateLabel,
                onPrevious: { viewModel.navigateDay(by: -1) },
                onNext: { viewModel.navigateDay(by: 1) },
                onToday: { viewModel.goToToday() }
            )

            Divider()

            DayTimelineView(events: viewModel.events)

            Divider()

            JoinSection(event: viewModel.nextUpcomingEvent)

            Divider()

            HStack {
                Button {
                    // Settings will be added in Phase 5
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
        .background(.ultraThinMaterial)
    }
}
