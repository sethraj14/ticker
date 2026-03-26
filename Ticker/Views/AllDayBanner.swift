import SwiftUI

// MARK: - All-Day Events Banner

struct AllDayBanner: View {
    let events: [CalendarEvent]

    var body: some View {
        if events.count == 1 {
            // Single event — show full row
            singleEventRow(events[0])
        } else {
            // Multiple events — compact horizontal scroll
            compactBanner
        }
    }

    private func singleEventRow(_ event: CalendarEvent) -> some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 2)
                .fill(event.calendarColor)
                .frame(width: 3, height: 16)
            Text(event.title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
                .lineLimit(1)
            Spacer()
            Text("ALL DAY")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.white.opacity(0.3))
                .tracking(0.8)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(RoundedRectangle(cornerRadius: 4).fill(.white.opacity(0.08)))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.white.opacity(0.04))
    }

    private var compactBanner: some View {
        HStack(spacing: 0) {
            // "ALL DAY" label on the left
            Text("\(events.count)")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.5))
                .frame(width: 20)

            // Horizontal scrollable chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(events) { event in
                        HStack(spacing: 5) {
                            Circle()
                                .fill(event.calendarColor)
                                .frame(width: 6, height: 6)
                            Text(event.title)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.white.opacity(0.7))
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.white.opacity(0.06))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .strokeBorder(event.calendarColor.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.white.opacity(0.04))
    }
}
