import SwiftUI

struct DayTimelineView: View {
    let events: [CalendarEvent]
    let selectedEventID: String?
    let onSelectEvent: (CalendarEvent) -> Void

    private let hourHeight: CGFloat = 40
    private let totalHours = 24
    private let labelWidth: CGFloat = 50
    private let eventPadding: CGFloat = 6
    private let workDayStart = 8

    private var totalHeight: CGFloat { CGFloat(totalHours) * hourHeight }
    private var eventAreaLeft: CGFloat { labelWidth + eventPadding }
    private var eventAreaWidth: CGFloat { 340 - eventAreaLeft - 8 }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                canvas
                    .frame(width: 340, height: totalHeight)
            }
            .frame(maxHeight: .infinity)
            .onAppear {
                scrollToWorkHours(proxy: proxy)
            }
        }
    }

    // Everything in one coordinate system
    private var canvas: some View {
        ZStack(alignment: .topLeading) {
            // 1. Grid lines + labels (background)
            gridLayer

            // 2. Event blocks
            eventBlocks

            // 3. Now indicator
            nowIndicator
        }
    }

    // MARK: - Grid Layer

    private var gridLayer: some View {
        ForEach(0..<totalHours, id: \.self) { hour in
            // Grid line
            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .frame(width: 340 - labelWidth - eventPadding, height: 1)
                .offset(x: labelWidth + eventPadding, y: CGFloat(hour) * hourHeight)

            // Hour label (bottom of text aligns with line)
            Text(hourLabel(hour))
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
                .fixedSize()
                .offset(
                    x: 4,
                    y: CGFloat(hour) * hourHeight - 14
                )
                .id(hour)
        }
    }

    // MARK: - Event Blocks

    private var eventBlocks: some View {
        let layout = computeColumns(events: events)

        return ForEach(layout, id: \.event.id) { le in
            let topY = timeToY(le.event.startDate)
            let bottomY = timeToY(le.event.endDate)
            let height = max(bottomY - topY, 10)
            let colWidth = eventAreaWidth / CGFloat(le.totalColumns)
            let leftX = eventAreaLeft + colWidth * CGFloat(le.column)
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

        return Group {
            Circle()
                .fill(.red)
                .frame(width: 8, height: 8)
                .offset(x: labelWidth + eventPadding - 4, y: y - 4)

            Rectangle()
                .fill(.red)
                .frame(width: 340 - labelWidth - eventPadding, height: 1.5)
                .offset(x: labelWidth + eventPadding, y: y - 0.75)
        }
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

    /// Converts a time to a Y position. This is the ONLY function that maps time → pixels.
    /// Grid lines and events both use this, guaranteeing alignment.
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
