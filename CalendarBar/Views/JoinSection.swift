import SwiftUI

struct JoinSection: View {
    let event: CalendarEvent?

    var body: some View {
        if let event {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("UP NEXT")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.secondary)
                        .tracking(1)

                    Text("\(event.title) · \(event.startTimeLabel)")
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                }

                Spacer()

                if let url = event.meetingURL {
                    Button {
                        NSWorkspace.shared.open(url)
                    } label: {
                        Label("Join", systemImage: "video.fill")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        } else {
            Text("No upcoming meetings")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .padding(.vertical, 10)
        }
    }
}
