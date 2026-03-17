import SwiftUI

// MARK: - Custom Layout (places children at exact pixel coordinates)

/// Layout value keys — each child specifies its top-left position
private struct TimelineX: LayoutValueKey {
    static let defaultValue: CGFloat = 0
}

private struct TimelineY: LayoutValueKey {
    static let defaultValue: CGFloat = 0
}

/// Places every child at an absolute (x, y) from the layout's top-left.
private struct AbsoluteLayout: Layout {
    let width: CGFloat
    let height: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for subview in subviews {
            let x = subview[TimelineX.self]
            let y = subview[TimelineY.self]
            let size = subview.sizeThatFits(.unspecified)
            subview.place(
                at: CGPoint(x: bounds.minX + x, y: bounds.minY + y),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )
        }
    }
}

private extension View {
    func timelinePosition(x: CGFloat, y: CGFloat) -> some View {
        self.layoutValue(key: TimelineX.self, value: x)
            .layoutValue(key: TimelineY.self, value: y)
    }
}

// MARK: - DayTimelineView

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
    private var contentHeight: CGFloat { CGFloat(totalHours) * hourHeight }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                // SINGLE layout — scroll anchors, grid, events, now-line all in one coordinate space
                AbsoluteLayout(width: viewWidth, height: contentHeight) {
                    scrollAnchors
                    gridContent
                    eventContent
                    nowLineContent
                }
            }
            .frame(maxHeight: .infinity)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    scrollToWorkHours(proxy: proxy)
                }
            }
        }
    }

    // MARK: - Scroll Anchors (invisible, inside the same layout)

    @ViewBuilder
    private var scrollAnchors: some View {
        ForEach(0..<totalHours, id: \.self) { hour in
            Color.clear
                .frame(width: 1, height: hourHeight)
                .timelinePosition(x: 0, y: CGFloat(hour) * hourHeight)
                .id(hour)
        }
    }

    // MARK: - Grid (lines + labels)

    @ViewBuilder
    private var gridContent: some View {
        ForEach(0..<totalHours, id: \.self) { hour in
            let y = CGFloat(hour) * hourHeight

            // Horizontal grid line
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(width: viewWidth - lineStart, height: 1)
                .timelinePosition(x: lineStart, y: y)
                .allowsHitTesting(false)

            // Hour label
            Text(hourLabel(hour))
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.25))
                .frame(width: labelWidth, alignment: .trailing)
                .timelinePosition(x: 0, y: y - 8)
                .allowsHitTesting(false)
        }
    }

    // MARK: - Events

    @ViewBuilder
    private var eventContent: some View {
        ForEach(computeColumns(events: events), id: \.event.id) { le in
            let topY = timeToY(le.event.startDate)
            let bottomY = timeToY(le.event.endDate)
            let height = max(bottomY - topY, 10)
            let colWidth = eventAreaWidth / CGFloat(le.totalColumns)
            let leftX = lineStart + colWidth * CGFloat(le.column)
            let isSelected = selectedEventID == le.event.id

            MeetingBlockView(event: le.event, isSelected: isSelected) {
                onSelectEvent(le.event)
            }
            .frame(width: colWidth - 2, height: height)
            .timelinePosition(x: leftX, y: topY)
        }
    }

    // MARK: - Now Line

    @ViewBuilder
    private var nowLineContent: some View {
        let y = timeToY(Date.now)

        // Red dot
        Circle()
            .fill(.red)
            .frame(width: 8, height: 8)
            .timelinePosition(x: lineStart - 8, y: y - 4)
            .allowsHitTesting(false)

        // Red line
        Rectangle()
            .fill(.red)
            .frame(width: viewWidth - lineStart, height: 1.5)
            .timelinePosition(x: lineStart, y: y - 0.75)
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
