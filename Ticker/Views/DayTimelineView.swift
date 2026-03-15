import SwiftUI

struct DayTimelineView: View {
    let events: [CalendarEvent]
    let selectedEventID: String?
    let onSelectEvent: (CalendarEvent) -> Void

    private let hourHeight: CGFloat = 40
    private let totalHours = 24
    private let labelWidth: CGFloat = 50
    private let lineStart: CGFloat = 56
    private let viewWidth: CGFloat = 340
    private let workDayStart = 8

    private var eventAreaWidth: CGFloat { viewWidth - lineStart - 8 }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                // SINGLE ZStack — grid and events as siblings, same coordinate space
                ZStack(alignment: .topLeading) {
                    // Layer 0: VStack grid — sets content height + scroll anchors
                    gridVStack

                    // Layer 1: Events
                    ForEach(computeColumns(events: events), id: \.event.id) { le in
                        eventView(for: le)
                    }

                    // Layer 2: Now indicator
                    nowLine
                }
            }
            .frame(maxHeight: .infinity)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    scrollToWorkHours(proxy: proxy)
                }
            }
        }
    }

    // MARK: - Grid VStack

    // This VStack is the LARGEST child of the ZStack, so it determines
    // the ZStack's size (24 * 40 = 960px). All other children are offset
    // within this 960px space from (0, 0).
    private var gridVStack: some View {
        VStack(spacing: 0) {
            ForEach(0..<totalHours, id: \.self) { hour in
                // Each cell: line at TOP, spacer fills the rest
                ZStack(alignment: .topLeading) {
                    // Horizontal grid line — at y=0 of this cell
                    Rectangle()
                        .fill(Color.primary.opacity(0.1))
                        .frame(height: 1)
                        .padding(.leading, lineStart)

                    // Hour label — sits above the line
                    Text(hourLabel(hour))
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                        .frame(width: labelWidth, alignment: .trailing)
                        .offset(y: -8)
                }
                .frame(height: hourHeight)
                .id(hour)
            }
        }
    }

    // MARK: - Single Event View

    private func eventView(for le: LayoutEvent) -> some View {
        let topY = timeToY(le.event.startDate)
        let bottomY = timeToY(le.event.endDate)
        let height = max(bottomY - topY, 10)
        let colWidth = eventAreaWidth / CGFloat(le.totalColumns)
        let leftX = lineStart + colWidth * CGFloat(le.column)
        let isSelected = selectedEventID == le.event.id

        return MeetingBlockView(event: le.event, isSelected: isSelected) {
            onSelectEvent(le.event)
        }
        .frame(width: colWidth - 2, height: height)
        .offset(x: leftX, y: topY)
    }

    // MARK: - Now Line

    private var nowLine: some View {
        let y = timeToY(Date.now)
        return HStack(spacing: 0) {
            Color.clear.frame(width: lineStart - 4)
            Circle()
                .fill(.red)
                .frame(width: 8, height: 8)
            Rectangle()
                .fill(.red)
                .frame(height: 1.5)
        }
        .frame(height: 8)
        .offset(y: y - 4)
        .allowsHitTesting(false)
    }

    // MARK: - Column Layout

    struct LayoutEvent {
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

    // THE source of truth for time → y position.
    // Grid cell for hour N starts at y = N * hourHeight (VStack cells).
    // timeToY(2:00 PM) = 14 * 40 = 560 = same as cell 14's top. ✓
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
