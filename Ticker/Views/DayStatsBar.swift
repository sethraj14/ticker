import SwiftUI

/// Compact stats bar with donut chart + text showing event count and total meeting time.
struct DayStatsBar: View {
    let events: [CalendarEvent]

    var body: some View {
        HStack(spacing: 10) {
            // Mini donut
            MeetingDonut(events: events, size: 28)

            // Text stats
            VStack(alignment: .leading, spacing: 1) {
                Text("\(events.count) \(events.count == 1 ? "meeting" : "meetings")")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))

                Text("\(formattedTotalTime) of meetings")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.3))
            }

            Spacer()

            // Meeting load indicator
            Text(loadLabel)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(loadColor.opacity(0.8))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(loadColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
    }

    // MARK: - Load label

    private var loadLabel: String {
        let mins = totalMeetingMinutes
        if mins == 0 { return "FREE" }
        if mins <= 120 { return "LIGHT" }
        if mins <= 300 { return "MODERATE" }
        return "HEAVY"
    }

    private var loadColor: Color {
        let mins = totalMeetingMinutes
        if mins == 0 { return .green }
        if mins <= 120 { return .green }
        if mins <= 300 { return .yellow }
        return .orange
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
