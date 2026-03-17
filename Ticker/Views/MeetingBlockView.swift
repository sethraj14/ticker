import SwiftUI

struct MeetingBlockView: View {
    let event: CalendarEvent
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Left color bar
            RoundedRectangle(cornerRadius: 2)
                .fill(event.calendarColor)
                .frame(width: 3)
                .padding(.vertical, 3)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.system(size: 11, weight: .semibold))
                    .lineLimit(1)

                Text(event.startTimeLabel)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 6)
            .padding(.vertical, 3)

            Spacer(minLength: 4)

            if let url = event.meetingURL {
                Button {
                    NSWorkspace.shared.open(url)
                } label: {
                    Image(systemName: "video.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(event.calendarColor.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                .buttonStyle(.plain)
                .padding(.trailing, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(event.calendarColor.opacity(isSelected ? 0.18 : 0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .strokeBorder(event.calendarColor.opacity(isSelected ? 0.5 : 0.25), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}
