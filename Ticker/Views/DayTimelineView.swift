import SwiftUI

struct DayTimelineView: View {
    let events: [CalendarEvent]
    let selectedEventID: String?
    let onSelectEvent: (CalendarEvent) -> Void

    private let hourHeight: CGFloat = 40
    private let startHour = 0
    private let endHour = 24
    private let timeColumnWidth: CGFloat = 50
    private let eventLeading: CGFloat = 56
    private let eventTrailing: CGFloat = 8
    private let workDayStart = 8

    private var totalHeight: CGFloat {
        CGFloat(endHour - startHour) * hourHeight
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                // Single coordinate system: grid is the base, events overlay on top
                hourGrid
                    .overlay(alignment: .topLeading) {
                        eventLayer
                    }
                    .overlay(alignment: .topLeading) {
                        nowLine
                    }
            }
            .frame(maxHeight: .infinity)
            .onAppear {
                scrollToWorkHours(proxy: proxy)
            }
        }
    }

    // MARK: - Hour Grid (base layer)

    private var hourGrid: some View {
        VStack(spacing: 0) {
            ForEach(startHour..<endHour, id: \.self) { hour in
                HStack(alignment: .top, spacing: 0) {
                    // Hour label — bottom-aligned to the grid line
                    Text(hourLabel(hour))
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                        .frame(width: timeColumnWidth - 6, alignment: .trailing)
                        .offset(y: -13) // text sits above the line

                    // Horizontal line from after label to right edge
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.primary.opacity(0.1))
                            .frame(height: 1)
                        Spacer()
                    }
                    .padding(.leading, 6)
                }
                .frame(height: hourHeight)
                .id(hour)
            }
        }
        .frame(width: 340, height: totalHeight)
    }

    // MARK: - Event Layer (overlaid on grid)

    private var eventLayer: some View {
        let layoutEvents = computeColumns(events: events)
        let availableWidth = 340 - eventLeading - eventTrailing

        return ZStack(alignment: .topLeading) {
            // Invisible spacer to fill the full grid area
            Color.clear.frame(width: 340, height: totalHeight)

            ForEach(layoutEvents, id: \.event.id) { le in
                let y = minutesFromMidnight(le.event.startDate) / 60.0 * hourHeight
                let durationMins = max(Double(le.event.durationMinutes), 15)
                let h = durationMins / 60.0 * hourHeight
                let colWidth = availableWidth / CGFloat(le.totalColumns)
                let x = eventLeading + colWidth * CGFloat(le.column)
                let isSelected = selectedEventID == le.event.id

                MeetingBlockView(event: le.event, isSelected: isSelected) {
                    onSelectEvent(le.event)
                }
                .frame(width: colWidth - 2, height: h)
                .position(x: x + (colWidth - 2) / 2, y: y + h / 2)
            }
        }
        .frame(width: 340, height: totalHeight)
    }

    // MARK: - Now Line

    private var nowLine: some View {
        let y = minutesFromMidnight(Date.now) / 60.0 * hourHeight

        return ZStack(alignment: .topLeading) {
            Color.clear.frame(width: 340, height: totalHeight)

            HStack(spacing: 0) {
                Spacer().frame(width: eventLeading - 6)
                Circle()
                    .fill(.red)
                    .frame(width: 8, height: 8)
                Rectangle()
                    .fill(.red)
                    .frame(height: 1.5)
            }
            .position(x: 170, y: y)
        }
        .frame(width: 340, height: totalHeight)
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
        var currentGroupEnd: Date = .distantPast

        for event in sorted {
            if event.startDate < currentGroupEnd {
                currentGroup.append(event)
                currentGroupEnd = max(currentGroupEnd, event.endDate)
            } else {
                if !currentGroup.isEmpty { groups.append(currentGroup) }
                currentGroup = [event]
                currentGroupEnd = event.endDate
            }
        }
        if !currentGroup.isEmpty { groups.append(currentGroup) }

        var result: [LayoutEvent] = []
        for group in groups {
            let total = group.count
            for (i, event) in group.enumerated() {
                result.append(LayoutEvent(event: event, column: i, totalColumns: total))
            }
        }
        return result
    }

    // MARK: - Helpers

    private func minutesFromMidnight(_ date: Date) -> CGFloat {
        let cal = Calendar.current
        let hour = cal.component(.hour, from: date)
        let minute = cal.component(.minute, from: date)
        return CGFloat(hour * 60 + minute)
    }

    private func hourLabel(_ hour: Int) -> String {
        if hour == 0 { return "12 AM" }
        if hour < 12 { return "\(hour) AM" }
        if hour == 12 { return "12 PM" }
        return "\(hour - 12) PM"
    }

    private func scrollToWorkHours(proxy: ScrollViewProxy) {
        let currentHour = Calendar.current.component(.hour, from: Date.now)
        let targetHour = (currentHour >= workDayStart && currentHour <= 18)
            ? max(workDayStart, currentHour - 1)
            : workDayStart
        proxy.scrollTo(targetHour, anchor: .top)
    }
}
