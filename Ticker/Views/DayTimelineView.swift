import SwiftUI

struct DayTimelineView: View {
    let events: [CalendarEvent]
    let selectedEventID: String?
    let onSelectEvent: (CalendarEvent) -> Void

    private let hourHeight: CGFloat = 40
    private let startHour = 0
    private let endHour = 24
    private let timeColumnWidth: CGFloat = 44
    private let workDayStart = 8
    private let workDayEnd = 18

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                ZStack(alignment: .topLeading) {
                    hourGrid
                    nowIndicator
                    eventColumns
                }
                .frame(
                    width: 340,
                    height: CGFloat(endHour - startHour) * hourHeight,
                    alignment: .topLeading
                )
                .clipped()
            }
            .frame(maxHeight: .infinity)
            .onAppear {
                scrollToWorkHours(proxy: proxy)
            }
        }
    }

    // MARK: - Hour Grid

    private var hourGrid: some View {
        VStack(spacing: 0) {
            ForEach(startHour..<endHour, id: \.self) { hour in
                HStack(alignment: .top, spacing: 0) {
                    Text(hourLabel(hour))
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.tertiary)
                        .frame(width: timeColumnWidth, alignment: .trailing)
                        .padding(.trailing, 4)
                        .offset(y: -6)

                    VStack(spacing: 0) {
                        Divider()
                        Spacer()
                    }
                }
                .frame(height: hourHeight)
                .id(hour)
            }
        }
    }

    // MARK: - Now Indicator

    private var nowIndicator: some View {
        GeometryReader { _ in
            let yOffset = yPosition(for: Date.now)
            if yOffset >= 0 {
                HStack(spacing: 0) {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                        .offset(x: timeColumnWidth - 2)

                    Rectangle()
                        .fill(.red)
                        .frame(height: 1.5)
                        .offset(x: timeColumnWidth)
                }
                .offset(y: yOffset - 4)
            }
        }
    }

    // MARK: - Event Columns (overlap handling)

    private var eventColumns: some View {
        let layoutEvents = computeColumns(events: events)
        let availableWidth = 340 - timeColumnWidth - 16

        return ForEach(layoutEvents, id: \.event.id) { layoutEvent in
            let yOffset = yPosition(for: layoutEvent.event.startDate)
            let durationMins = max(layoutEvent.event.durationMinutes, 15)
            let height = CGFloat(durationMins) / 60.0 * hourHeight
            let columnWidth = availableWidth / CGFloat(layoutEvent.totalColumns)
            let xOffset = timeColumnWidth + 8 + columnWidth * CGFloat(layoutEvent.column)
            let isSelected = selectedEventID == layoutEvent.event.id

            MeetingBlockView(event: layoutEvent.event, isSelected: isSelected) {
                onSelectEvent(layoutEvent.event)
            }
            .frame(width: columnWidth - 2, height: height)
            .offset(x: xOffset, y: yOffset)
        }
    }

    // MARK: - Column Layout Algorithm

    private struct LayoutEvent {
        let event: CalendarEvent
        let column: Int
        let totalColumns: Int
    }

    private func computeColumns(events: [CalendarEvent]) -> [LayoutEvent] {
        let sorted = events.sorted { $0.startDate < $1.startDate }
        guard !sorted.isEmpty else { return [] }

        // Group overlapping events
        var groups: [[CalendarEvent]] = []
        var currentGroup: [CalendarEvent] = []
        var currentGroupEnd: Date = .distantPast

        for event in sorted {
            if event.startDate < currentGroupEnd {
                currentGroup.append(event)
                currentGroupEnd = max(currentGroupEnd, event.endDate)
            } else {
                if !currentGroup.isEmpty {
                    groups.append(currentGroup)
                }
                currentGroup = [event]
                currentGroupEnd = event.endDate
            }
        }
        if !currentGroup.isEmpty {
            groups.append(currentGroup)
        }

        // Assign columns within each group
        var result: [LayoutEvent] = []

        for group in groups {
            let totalColumns = group.count
            for (index, event) in group.enumerated() {
                result.append(LayoutEvent(
                    event: event,
                    column: index,
                    totalColumns: totalColumns
                ))
            }
        }

        return result
    }

    // MARK: - Helpers

    private func yPosition(for date: Date) -> CGFloat {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let hourOffset = CGFloat(hour - startHour)
        let minuteOffset = CGFloat(minute) / 60.0
        return (hourOffset + minuteOffset) * hourHeight
    }

    private func hourLabel(_ hour: Int) -> String {
        if hour == 0 { return "12 AM" }
        if hour < 12 { return "\(hour) AM" }
        if hour == 12 { return "12 PM" }
        return "\(hour - 12) PM"
    }

    private func scrollToWorkHours(proxy: ScrollViewProxy) {
        let currentHour = Calendar.current.component(.hour, from: Date.now)
        let targetHour: Int
        if currentHour >= workDayStart && currentHour <= workDayEnd {
            targetHour = max(workDayStart, currentHour - 1)
        } else {
            targetHour = workDayStart
        }
        proxy.scrollTo(targetHour, anchor: .top)
    }
}
