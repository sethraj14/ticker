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
    let isToday: Bool
    let selectedDate: Date
    let onSelectEvent: (CalendarEvent) -> Void
    var onCreateAtTime: ((Date, Date?) -> Void)? = nil
    var onResizeEvent: ((CalendarEvent, Date) -> Void)? = nil
    var onMoveEvent: ((CalendarEvent, Date, Date) -> Void)? = nil

    private let hourHeight: CGFloat = 40
    private let totalHours = 24
    private let labelWidth: CGFloat = 50
    private let lineStart: CGFloat = 56
    private let viewWidth: CGFloat = 340
    private let workDayStart = 8

    private var eventAreaWidth: CGFloat { viewWidth - lineStart - 8 }
    private var contentHeight: CGFloat { CGFloat(totalHours) * hourHeight }

    // Drag-to-create state
    @State private var dragStartY: CGFloat? = nil
    @State private var dragCurrentY: CGFloat? = nil
    @State private var isDraggingToCreate = false


    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                ZStack(alignment: .topLeading) {
                    AbsoluteLayout(width: viewWidth, height: contentHeight) {
                        scrollAnchors
                        gridContent

                        // Tap targets for empty 15-min slots (BEFORE events so events get priority)
                        tapTargets

                        eventContent
                        if isToday {
                            nowLineContent
                        }
                    }

                    // Drag-to-create preview block
                    if isDraggingToCreate, let startY = dragStartY, let currentY = dragCurrentY {
                        let topY = min(startY, currentY)
                        let height = max(abs(currentY - startY), hourHeight / 4)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.blue.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(Color.blue.opacity(0.5), lineWidth: 1.5)
                            )
                            .overlay(
                                Text(dragPreviewLabel(topY: topY, height: height))
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.7))
                                    .padding(.leading, 6)
                                    .padding(.top, 3),
                                alignment: .topLeading
                            )
                            .frame(width: eventAreaWidth - 8, height: height)
                            .offset(x: lineStart + 4, y: topY)
                            .allowsHitTesting(false)
                    }
                }
                // Drag-to-create gesture on the whole content area
                .gesture(
                    DragGesture(minimumDistance: 8)
                        .onChanged { value in
                            guard LicenseManager.shared.isPro else { return }
                            // Only start if dragging from empty area in event column
                            if !isDraggingToCreate && dragStartY == nil {
                                let startX = value.startLocation.x
                                guard startX > lineStart else { return }
                                guard !isPointOnEvent(y: value.startLocation.y) else { return }
                                dragStartY = snapToGrid(value.startLocation.y)
                                isDraggingToCreate = true
                            }
                            if isDraggingToCreate {
                                dragCurrentY = snapToGrid(value.location.y)
                            }
                        }
                        .onEnded { _ in
                            guard isDraggingToCreate,
                                  let startY = dragStartY,
                                  let endY = dragCurrentY else {
                                resetDragState()
                                return
                            }
                            let topY = min(startY, endY)
                            let bottomY = max(startY, endY)
                            let startDate = yToDate(topY)
                            let endDate = yToDate(bottomY)
                            if endDate.timeIntervalSince(startDate) >= 900 {
                                onCreateAtTime?(startDate, endDate)
                            }
                            resetDragState()
                        }
                )
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

    // MARK: - Tap Targets (click-to-create on empty areas)

    @ViewBuilder
    private var tapTargets: some View {
        // One tap target per 15-min slot across the timeline
        ForEach(0..<(totalHours * 4), id: \.self) { slot in
            let slotY = CGFloat(slot) * (hourHeight / 4)
            let slotHeight = hourHeight / 4

            Color.clear
                .frame(width: eventAreaWidth, height: slotHeight)
                .contentShape(Rectangle())
                .timelinePosition(x: lineStart, y: slotY)
                .onTapGesture {
                    guard LicenseManager.shared.isPro else { return }
                    // Only create if this slot has no event
                    guard !isPointOnEvent(y: slotY + slotHeight / 2) else { return }
                    let date = yToDate(slotY)
                    onCreateAtTime?(date, nil)
                }
                .allowsHitTesting(!isPointOnEvent(y: slotY + slotHeight / 2))
        }
    }

    // MARK: - Events

    @ViewBuilder
    private var eventContent: some View {
        ForEach(computeColumns(events: events), id: \.event.id) { le in
            let topY = timeToY(le.event.startDate)
            let bottomY = timeToY(le.event.endDate)
            let baseHeight = max(bottomY - topY, 20)
            let colWidth = (eventAreaWidth / CGFloat(le.totalColumns)).rounded(.down)
            let leftX = (lineStart + colWidth * CGFloat(le.column)).rounded(.down)
            let isSelected = selectedEventID == le.event.id

            DraggableEventBlock(
                event: le.event,
                isSelected: isSelected,
                baseHeight: baseHeight,
                topY: topY,
                colWidth: colWidth,
                isPro: LicenseManager.shared.isPro,
                onSelect: { onSelectEvent(le.event) },
                onResize: { newEnd in onResizeEvent?(le.event, newEnd) },
                onMove: { newStart, newEnd in onMoveEvent?(le.event, newStart, newEnd) },
                snapToGrid: snapToGrid,
                yToDate: yToDate
            )
            .frame(width: colWidth - 2, height: baseHeight)
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

    private func resetDragState() {
        dragStartY = nil
        dragCurrentY = nil
        isDraggingToCreate = false
    }

    /// Label for drag-to-create preview
    private func dragPreviewLabel(topY: CGFloat, height: CGFloat) -> String {
        let start = yToDate(topY)
        let end = yToDate(topY + height)
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return "\(f.string(from: start)) – \(f.string(from: end))"
    }

    private func timeToY(_ date: Date) -> CGFloat {
        let cal = Calendar.current
        let h = cal.component(.hour, from: date)
        let m = cal.component(.minute, from: date)
        return ((CGFloat(h) + CGFloat(m) / 60.0) * hourHeight).rounded(.down)
    }

    /// Inverse of timeToY — convert Y coordinate back to a Date on the displayed day
    private func yToDate(_ y: CGFloat) -> Date {
        let fractionalHour = y / hourHeight
        let hour = Int(fractionalHour)
        let minute = Int((fractionalHour - CGFloat(hour)) * 60)
        var cal = Calendar.current
        cal.timeZone = .current
        return cal.date(bySettingHour: max(0, min(23, hour)), minute: max(0, min(59, minute)), second: 0, of: selectedDate) ?? selectedDate
    }

    /// Snap Y to nearest 15-minute grid line
    private func snapToGrid(_ y: CGFloat) -> CGFloat {
        let quarterHourHeight = hourHeight / 4
        return (y / quarterHourHeight).rounded() * quarterHourHeight
    }

    /// Check if a Y coordinate overlaps with any event block
    private func isPointOnEvent(y: CGFloat) -> Bool {
        for event in events {
            let topY = timeToY(event.startDate)
            let bottomY = timeToY(event.endDate)
            if y >= topY && y <= max(bottomY, topY + 20) {
                return true
            }
        }
        return false
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

// MARK: - Draggable Event Block (isolated state = only this view re-renders during drag)

private struct DraggableEventBlock: View {
    let event: CalendarEvent
    let isSelected: Bool
    let baseHeight: CGFloat
    let topY: CGFloat
    let colWidth: CGFloat
    let isPro: Bool
    let onSelect: () -> Void
    let onResize: (Date) -> Void
    let onMove: (Date, Date) -> Void
    let snapToGrid: (CGFloat) -> CGFloat
    let yToDate: (CGFloat) -> Date

    // Each block owns its own gesture state — no parent re-render
    @GestureState private var dragOffset: CGFloat = 0
    @GestureState private var resizeDelta: CGFloat = 0
    @State private var isDragging = false
    @State private var isResizing = false

    private var isGoogle: Bool { event.source == .google }
    private var isCompact: Bool { baseHeight < 28 }

    private var displayHeight: CGFloat {
        isResizing ? max(baseHeight + resizeDelta, 20) : baseHeight
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            MeetingBlockView(event: event, isSelected: isSelected, availableHeight: displayHeight) {
                onSelect()
            }

            // Resize handle at bottom
            if isGoogle && isPro && displayHeight >= 16 {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: colWidth - 2, height: 8)
                    .contentShape(Rectangle())
                    .gesture(resizeGesture)
                    .onHover { hovering in
                        if hovering { NSCursor.resizeUpDown.push() }
                        else { NSCursor.pop() }
                    }
            }
        }
        .overlay(alignment: .leading) {
            // Left color bar = drag handle
            if isGoogle && isPro {
                RoundedRectangle(cornerRadius: 2)
                    .fill(event.calendarColor.opacity(isDragging ? 1.0 : 0.8))
                    .frame(width: 6, height: displayHeight - (isCompact ? 4 : 6))
                    .contentShape(Rectangle())
                    .gesture(moveGesture)
                    .onHover { hovering in
                        if hovering { NSCursor.openHand.push() }
                        else { NSCursor.pop() }
                    }
            }
        }
        .frame(width: colWidth - 2, height: displayHeight)
        .offset(y: dragOffset)
        .shadow(color: isDragging ? .black.opacity(0.3) : .clear, radius: 4, y: 2)
        .zIndex(isDragging || isResizing ? 10 : 0)
    }

    // MARK: - Move Gesture (uses @GestureState for 60fps perf)

    private var moveGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .updating($dragOffset) { value, state, _ in
                state = value.translation.height
            }
            .onChanged { _ in
                if !isDragging {
                    isDragging = true
                    NSCursor.closedHand.push()
                }
            }
            .onEnded { value in
                NSCursor.pop()
                isDragging = false
                let finalY = topY + value.translation.height
                let snappedY = snapToGrid(finalY)
                let newStart = yToDate(snappedY)
                let duration = event.endDate.timeIntervalSince(event.startDate)
                let newEnd = newStart.addingTimeInterval(duration)
                onMove(newStart, newEnd)
            }
    }

    // MARK: - Resize Gesture

    private var resizeGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .updating($resizeDelta) { value, state, _ in
                state = value.translation.height
            }
            .onChanged { _ in
                if !isResizing { isResizing = true }
            }
            .onEnded { value in
                isResizing = false
                let newBottomY = snapToGrid(topY + baseHeight + value.translation.height)
                let newEnd = yToDate(newBottomY)
                if newEnd > event.startDate {
                    onResize(newEnd)
                }
            }
    }
}
