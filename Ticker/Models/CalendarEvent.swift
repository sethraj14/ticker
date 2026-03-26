import SwiftUI

enum CalendarSource {
    case google
    case apple
}

struct EventAttendee: Identifiable, Hashable {
    var id: String { email }
    let email: String
    let name: String?
}

struct CalendarEvent: Identifiable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let meetingURL: URL?
    let source: CalendarSource
    let calendarColor: Color
    let attendees: [EventAttendee]
    let location: String?
    let notes: String?
    let isAllDay: Bool

    init(
        id: String,
        title: String,
        startDate: Date,
        endDate: Date,
        meetingURL: URL?,
        source: CalendarSource,
        calendarColor: Color,
        attendees: [EventAttendee],
        location: String?,
        notes: String?,
        isAllDay: Bool = false
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.meetingURL = meetingURL
        self.source = source
        self.calendarColor = calendarColor
        self.attendees = attendees
        self.location = location
        self.notes = notes
        self.isAllDay = isAllDay
    }

    var durationMinutes: Int {
        Int(endDate.timeIntervalSince(startDate) / 60)
    }

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()

    var timeRangeLabel: String {
        "\(Self.timeFormatter.string(from: startDate)) – \(Self.timeFormatter.string(from: endDate))"
    }

    var startTimeLabel: String {
        Self.timeFormatter.string(from: startDate)
    }
}
