import SwiftUI

struct MeetingBlockView: View {
    let event: CalendarEvent
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Left color bar
            RoundedRectangle(cornerRadius: 1.5)
                .fill(event.calendarColor)
                .frame(width: 3)
                .padding(.vertical, 2)

            VStack(alignment: .leading, spacing: 1) {
                Text(event.title)
                    .font(.system(size: 11, weight: .semibold))
                    .lineLimit(1)

                Text(event.startTimeLabel)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 5)
            .padding(.vertical, 1)

            Spacer(minLength: 2)

            if let url = event.meetingURL {
                Button {
                    NSWorkspace.shared.open(url)
                } label: {
                    Image(systemName: "video.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(event.calendarColor)
                        .frame(width: 22, height: 22)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .buttonStyle(.plain)
                .padding(.trailing, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(event.calendarColor.opacity(isSelected ? 0.2 : 0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(event.calendarColor.opacity(isSelected ? 0.6 : 0.3), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}
