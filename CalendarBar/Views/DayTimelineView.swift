import SwiftUI

struct DayTimelineView: View {
    let events: [CalendarEvent]
    let selectedEventID: String?
    let onSelectEvent: (CalendarEvent) -> Void

    private let hourHeight: CGFloat = 52
    private let startHour = 0
    private let endHour = 24
    private let timeColumnWidth: CGFloat = 54

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                ZStack(alignment: .topLeading) {
                    hourGrid
                    nowIndicator
                    eventBlocks
                }
                .frame(
                    width: 340,
                    height: CGFloat(endHour - startHour) * hourHeight,
                    alignment: .topLeading
                )
                .clipped()
            }
            .frame(maxHeight: 330)
            .onAppear {
                scrollToCurrentTime(proxy: proxy)
            }
        }
    }

    private var hourGrid: some View {
        VStack(spacing: 0) {
            ForEach(startHour..<endHour, id: \.self) { hour in
                HStack(alignment: .top, spacing: 0) {
                    Text(hourLabel(hour))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .frame(width: timeColumnWidth, alignment: .trailing)
                        .padding(.trailing, 6)
                        .offset(y: -7)

                    VStack {
                        Divider()
                        Spacer()
                    }
                }
                .frame(height: hourHeight)
                .id(hour)
            }
        }
    }

    private var nowIndicator: some View {
        GeometryReader { _ in
            let yOffset = yPosition(for: Date.now)
            if yOffset >= 0 {
                HStack(spacing: 0) {
                    Circle()
                        .fill(.red)
                        .frame(width: 9, height: 9)
                        .offset(x: timeColumnWidth - 4)

                    Rectangle()
                        .fill(.red)
                        .frame(height: 2)
                        .offset(x: timeColumnWidth)
                }
                .offset(y: yOffset - 4)
            }
        }
    }

    private var eventBlocks: some View {
        ForEach(events) { event in
            let yOffset = yPosition(for: event.startDate)
            let height = max(CGFloat(event.durationMinutes) / 60.0 * hourHeight, 28)
            let isSelected = selectedEventID == event.id

            MeetingBlockView(event: event, isSelected: isSelected) {
                onSelectEvent(event)
            }
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .padding(.leading, timeColumnWidth + 8)
            .padding(.trailing, 10)
            .offset(y: yOffset)
        }
    }

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

    private func scrollToCurrentTime(proxy: ScrollViewProxy) {
        let currentHour = Calendar.current.component(.hour, from: Date.now)
        let targetHour = max(startHour, currentHour - 1)
        proxy.scrollTo(targetHour, anchor: .top)
    }
}
