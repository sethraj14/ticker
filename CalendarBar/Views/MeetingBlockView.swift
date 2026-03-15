import SwiftUI

struct MeetingBlockView: View {
    let event: CalendarEvent
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(event.title)
                .font(.system(size: 11, weight: .semibold))
                .lineLimit(1)

            Text(event.timeRangeLabel)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)

            if isExpanded {
                expandedDetails
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(event.calendarColor.opacity(0.15))
        .overlay(
            Rectangle()
                .frame(width: 3)
                .foregroundStyle(event.calendarColor),
            alignment: .leading
        )
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        }
    }

    @ViewBuilder
    private var expandedDetails: some View {
        VStack(alignment: .leading, spacing: 3) {
            if !event.attendees.isEmpty {
                Label(event.attendees.joined(separator: ", "), systemImage: "person.2")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            if let location = event.location {
                Label(location, systemImage: "mappin")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }

            if let meetingURL = event.meetingURL {
                Button {
                    NSWorkspace.shared.open(meetingURL)
                } label: {
                    Label("Join", systemImage: "video")
                        .font(.system(size: 10, weight: .medium))
                }
                .buttonStyle(.plain)
                .foregroundStyle(event.calendarColor)
                .padding(.top, 2)
            }
        }
    }
}
