import SwiftUI

struct JoinSection: View {
    let event: CalendarEvent?

    var body: some View {
        if let event {
            HStack(spacing: 10) {
                // Color indicator
                RoundedRectangle(cornerRadius: 2)
                    .fill(event.calendarColor)
                    .frame(width: 4, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text("UP NEXT")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.secondary)
                        .tracking(1.2)

                    Text(event.title)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(1)

                    Text(event.timeRangeLabel)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let url = event.meetingURL {
                    Button {
                        NSWorkspace.shared.open(url)
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "video.fill")
                            Text("Join")
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        } else {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 14))
                    .foregroundStyle(.green.opacity(0.6))
                Text("No upcoming meetings")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }
}
