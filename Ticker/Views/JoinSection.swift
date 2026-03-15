import SwiftUI

struct JoinSection: View {
    let event: CalendarEvent?

    var body: some View {
        if let event {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("UP NEXT")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                        .tracking(1)

                    Text(event.title)
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)

                    Text(event.timeRangeLabel)
                        .font(.system(size: 12))
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
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        } else {
            Text("No upcoming meetings")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
    }
}
