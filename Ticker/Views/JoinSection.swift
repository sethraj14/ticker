import SwiftUI

struct JoinSection: View {
    let event: CalendarEvent?
    var isToday: Bool = true
    var allTimedEvents: [CalendarEvent] = []

    var body: some View {
        if isToday {
            todayView
        } else {
            daySummaryView
        }
    }

    // MARK: - Today: show next event with Join button

    private var todayView: some View {
        Group {
            if let event {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(event.calendarColor)
                        .frame(width: 3, height: 40)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("UP NEXT")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white.opacity(0.3))
                            .tracking(1.2)

                        Text(event.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        Text(event.timeRangeLabel)
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.4))
                    }

                    Spacer(minLength: 8)

                    if let url = event.meetingURL {
                        Button {
                            NSWorkspace.shared.open(url)
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "video.fill")
                                    .font(.system(size: 10))
                                Text("Join")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: [event.calendarColor, event.calendarColor.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 14))
                        .foregroundStyle(.green.opacity(0.5))
                    Text("No upcoming meetings today")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.3))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
        }
    }

    // MARK: - Non-today: show day summary (event count + total meeting time)

    private var daySummaryView: some View {
        Group {
            if allTimedEvents.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.3))
                    Text("No events this day")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.3))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            } else {
                HStack(spacing: 14) {
                    // Event count
                    VStack(spacing: 2) {
                        Text("\(allTimedEvents.count)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(allTimedEvents.count == 1 ? "event" : "events")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    .frame(width: 50)

                    // Divider
                    Rectangle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 1, height: 30)

                    // Total meeting time (merged, no double-counting)
                    VStack(spacing: 2) {
                        Text(formattedTotalTime)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("in meetings")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.white.opacity(0.3))
                    }

                    Spacer()

                    // DAY SUMMARY label
                    Text("DAY SUMMARY")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white.opacity(0.2))
                        .tracking(1)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
        }
    }

    // MARK: - Total time calculation (merges overlapping events)

    /// Merges overlapping time intervals to avoid double-counting,
    /// then sums the total duration.
    private var totalMeetingMinutes: Int {
        let sorted = allTimedEvents.sorted { $0.startDate < $1.startDate }
        guard !sorted.isEmpty else { return 0 }

        // Merge overlapping intervals
        var merged: [(start: Date, end: Date)] = []
        var currentStart = sorted[0].startDate
        var currentEnd = sorted[0].endDate

        for event in sorted.dropFirst() {
            if event.startDate <= currentEnd {
                // Overlapping — extend the current interval
                currentEnd = max(currentEnd, event.endDate)
            } else {
                // No overlap — save current and start new
                merged.append((currentStart, currentEnd))
                currentStart = event.startDate
                currentEnd = event.endDate
            }
        }
        merged.append((currentStart, currentEnd))

        // Sum total minutes
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
