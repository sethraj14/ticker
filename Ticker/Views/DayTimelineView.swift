import SwiftUI

struct DayTimelineView: View {
    let events: [CalendarEvent]
    let selectedEventID: String?
    let onSelectEvent: (CalendarEvent) -> Void

    private let hourHeight: CGFloat = 40
    private let totalHours = 24
    private let labelWidth: CGFloat = 50
    private let lineStart: CGFloat = 56
    private let eventStart: CGFloat = 56
    private let viewWidth: CGFloat = 340
    private let workDayStart = 8

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                // VStack grid is the source of truth for layout and scrolling
                grid
                    .overlay(alignment: .topLeading) {
                        // Events overlaid — shares exact coordinate system with grid
                        GeometryReader { _ in
                            eventLayer
                            nowIndicator
                        }
                    }
            }
            .frame(maxHeight: .infinity)
            .onAppear {
                scrollToWorkHours(proxy: proxy)
            }
        }
    }

    // MARK: - Grid (VStack — controls scroll height and hour positions)

    private var grid: some View {
        VStack(spacing: 0) {
            ForEach(0..<totalHours, id: \.self) { hour in
                VStack(spacing: 0) {
                    // Grid line at exact top of each cell
                    HStack(spacing: 0) {
                        // Hour label — positioned so baseline sits on the line
                        Text(hourLabel(hour))
                            .font(.system(size: 10))
                            .foregroundStyle(.tertiary)
                            .frame(width: labelWidth, alignment: .trailing)

                        // Horizontal line
                        Rectangle()
                            .fill(Color.primary.opacity(0.1))
                            .frame(height: 1)
                            .padding(.leading, 6)
                    }

                    Spacer(minLength: 0)
                }
                .frame(height: hourHeight)
                .id(hour)
            }
        }
    }

    // MARK: - Event Layer

    private var eventLayer: some View {
        let layout = computeColumns(events: events)
        let eventWidth = viewWidth - eventStart - 8

        return ForEach(layout, id: \.event.id) { le in
            let topY = timeToY(le.event.startDate)
            let bottomY = timeToY(le.event.endDate)
            let height = max(bottomY - topY, 10)
            let colWidth = eventWidth / CGFloat(le.totalColumns)
            let leftX = eventStart + colWidth * CGFloat(le.column)
            let isSelected = selectedEventID == le.event.id

            MeetingBlockView(event: le.event, isSelected: isSelected) {
                onSelectEvent(le.event)
            }
            .frame(width: colWidth - 2, height: height)
            .offset(x: leftX, y: topY)
        }
    }

    // MARK: - Now Indicator

    private var nowIndicator: some View {
        let y = timeToY(Date.now)

        return HStack(spacing: 0) {
            Spacer()
                .frame(width: lineStart - 4)
            Circle()
                .fill(.red)
                .frame(width: 8, height: 8)
            Rectangle()
                .fill(.red)
                .frame(height: 1.5)
        }
        .offset(y: y - 4)
        .allowsHitTesting(false)
    }

    // MARK: - Column Layout

    private struct LayoutEvent {
        let event: CalendarEvent
        let column: Int
        let totalColumns: Int
    }

    private func computeColumns(events: [CalendarEvent]) -> [LayoutEvent] {
        let sorted = events.sorted { $0.startDate < $1.startDate }
        guard !sorted.isEmpty else { return [] }

        var groups: [[CalendarEvent]] = []
        var currentGroup: [CalendarEvent] = []
        var groupEnd: Date = .distantPast

        for event in sorted {
            if event.startDate < groupEnd {
                currentGroup.append(event)
                groupEnd = max(groupEnd, event.endDate)
            } else {
                if !currentGroup.isEmpty { groups.append(currentGroup) }
                currentGroup = [event]
                groupEnd = event.endDate
            }
        }
        if !currentGroup.isEmpty { groups.append(currentGroup) }

        var result: [LayoutEvent] = []
        for group in groups {
            for (i, event) in group.enumerated() {
                result.append(LayoutEvent(event: event, column: i, totalColumns: group.count))
            }
        }
        return result
    }

    // MARK: - Helpers

    /// Single source of truth: time → y pixel position.
    /// Grid line for hour N is at y = N * hourHeight (top of each VStack cell).
    /// This function produces the same values for on-the-hour times.
    private func timeToY(_ date: Date) -> CGFloat {
        let cal = Calendar.current
        let h = cal.component(.hour, from: date)
        let m = cal.component(.minute, from: date)
        return (CGFloat(h) + CGFloat(m) / 60.0) * hourHeight
    }

    private func hourLabel(_ hour: Int) -> String {
        if hour == 0 { return "12 AM" }
        if hour < 12 { return "\(hour) AM" }
        if hour == 12 { return "12 PM" }
        return "\(hour - 12) PM"
    }

    private func scrollToWorkHours(proxy: ScrollViewProxy) {
        let currentHour = Calendar.current.component(.hour, from: Date.now)
        let target = (currentHour >= workDayStart && currentHour <= 18)
            ? max(workDayStart, currentHour - 1) : workDayStart
        proxy.scrollTo(target, anchor: .top)
    }
}
