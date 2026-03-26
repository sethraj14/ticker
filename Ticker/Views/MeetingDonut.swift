import SwiftUI

/// Mini donut chart showing meeting load for a day.
/// Ring fills proportional to meeting hours vs working day (8h).
/// Center shows event count.
struct MeetingDonut: View {
    let events: [CalendarEvent]
    let size: CGFloat

    private let workingHours: Double = 8.0
    private let ringWidth: CGFloat = 4

    init(events: [CalendarEvent], size: CGFloat = 32) {
        self.events = events
        self.size = size
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(.white.opacity(0.08), lineWidth: ringWidth)

            // Filled ring — meeting proportion
            Circle()
                .trim(from: 0, to: fillFraction)
                .stroke(
                    fillFraction > 0.75
                        ? Color.orange  // Heavy day
                        : fillFraction > 0.5
                            ? Color.yellow  // Moderate day
                            : Color.green,  // Light day
                    style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: fillFraction)

            // Center: event count
            Text("\(events.count)")
                .font(.system(size: size * 0.35, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(width: size, height: size)
    }

    // MARK: - Meeting load calculation (merged overlapping)

    private var fillFraction: CGFloat {
        let mins = totalMergedMinutes
        guard mins > 0 else { return 0 }
        let fraction = Double(mins) / (workingHours * 60)
        return CGFloat(min(fraction, 1.0))
    }

    private var totalMergedMinutes: Int {
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
}
