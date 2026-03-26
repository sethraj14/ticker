import SwiftUI

/// Compact stats bar showing event count + total meeting time.
/// Merges overlapping events to avoid double-counting time.
struct DayStatsBar: View {
    let events: [CalendarEvent]

    var body: some View {
        HStack(spacing: 12) {
            // Event count
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.3))
                Text("\(events.count) \(events.count == 1 ? "event" : "events")")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            }

            Circle()
                .fill(.white.opacity(0.15))
                .frame(width: 3, height: 3)

            // Total meeting time (merged)
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.3))
                Text("\(formattedTotalTime) total")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(.white.opacity(0.02))
    }

    // MARK: - Merged total time

    private var totalMeetingMinutes: Int {
        let sorted = events.sorted { $0.startDate < $1.startDate }
        guard !sorted.isEmpty else { return 0 }

        var merged: [(start: Date, end: Date)] = []
        var currentStart = sorted[0].startDate
        var currentEnd = sorted[0].endDate

        for event in sorted.dropFirst() {
            if event.startDate <= currentEnd {
                currentEnd = max(currentEnd, event.endDate)
            } else {
                merged.append((currentStart, currentEnd))
                currentStart = event.startDate
                currentEnd = event.endDate
            }
        }
        merged.append((currentStart, currentEnd))

        let totalSeconds = merged.reduce(0.0) { $0 + $1.end.timeIntervalSince($1.start) }
        return Int(totalSeconds / 60)
    }

    private var formattedTotalTime: String {
        let mins = totalMeetingMinutes
        if mins < 60 {
            return "\(mins)m"
        }
        let hours = mins / 60
        let remaining = mins % 60
        if remaining == 0 {
            return "\(hours)h"
        }
        return "\(hours)h \(remaining)m"
    }
}
