import SwiftUI

struct MeetingBlockView: View {
    let event: CalendarEvent
    let isSelected: Bool
    let availableHeight: CGFloat
    let onTap: () -> Void

    /// Compact: single line (title only) — for events < 28px tall (under ~40 min)
    /// Full: two lines (title + time) + video button — for events >= 28px
    private var isCompact: Bool { availableHeight < 28 }

    var body: some View {
        HStack(spacing: 0) {
            // Left color bar
            RoundedRectangle(cornerRadius: 2)
                .fill(event.calendarColor)
                .frame(width: 3)
                .padding(.vertical, isCompact ? 2 : 3)

            if isCompact {
                compactContent
            } else {
                fullContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: isCompact ? 4 : 6)
                .fill(event.calendarColor.opacity(isSelected ? 0.2 : 0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: isCompact ? 4 : 6)
                .strokeBorder(event.calendarColor.opacity(isSelected ? 0.5 : 0.2), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }

    // MARK: - Compact (short events: 15-40 min)

    private var compactContent: some View {
        HStack(spacing: 4) {
            Text(event.title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(1)

            Text(event.startTimeLabel)
                .font(.system(size: 8))
                .foregroundStyle(.white.opacity(0.35))
                .lineLimit(1)
                .layoutPriority(-1)

            Spacer(minLength: 2)

            if let url = event.meetingURL {
                Button {
                    NSWorkspace.shared.open(url)
                } label: {
                    Image(systemName: "video.fill")
                        .font(.system(size: 7))
                        .foregroundStyle(.white)
                        .frame(width: 18, height: 18)
                        .background(event.calendarColor.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .buttonStyle(.plain)
                .padding(.trailing, 3)
            }
        }
        .padding(.leading, 5)
        .padding(.trailing, 2)
    }

    // MARK: - Full (normal/long events: 40+ min)

    private var fullContent: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(1)

                Text(event.startTimeLabel)
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.4))
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
                        .background(event.calendarColor.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                .buttonStyle(.plain)
                .padding(.trailing, 4)
            }
        }
    }
}
