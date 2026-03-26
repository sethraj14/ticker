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

            // Free time remaining (8h working day)
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.system(size: 8))
                    .foregroundStyle(freeTimeColor)
                Text("\(formattedFreeTime) free")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(freeTimeColor)
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(freeTimeColor.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
    }

    // MARK: - Free time

    private var freeMinutes: Int {
        max(480 - totalMeetingMinutes, 0) // 8h = 480m
    }

    private var freeTimeColor: Color {
        let free = freeMinutes
        if free >= 300 { return .green }   // 5h+ free
        if free >= 120 { return .blue }    // 2-5h free
        return .orange                      // under 2h free
    }

    private var formattedFreeTime: String {
        let mins = freeMinutes
        if mins < 60 { return "\(mins)m" }
        let hours = mins / 60
        let remaining = mins % 60
        if remaining == 0 { return "\(hours)h" }
        return "\(hours)h \(remaining)m"
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
