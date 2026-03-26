import SwiftUI

enum CalendarSource {
    case google
    case apple
}

struct EventAttendee: Identifiable, Hashable {
    var id: String { email }
    let email: String
    let name: String?
    let responseStatus: String?

    init(email: String, name: String?, responseStatus: String? = nil) {
        self.email = email
        self.name = name
        self.responseStatus = responseStatus
    }

    /// RSVP display icon
    var rsvpIcon: String {
        switch responseStatus {
        case "accepted": return "checkmark.circle.fill"
        case "declined": return "xmark.circle.fill"
        case "tentative": return "questionmark.circle.fill"
        default: return "circle"
        }
    }

    var rsvpColor: Color {
        switch responseStatus {
        case "accepted": return .green
        case "declined": return .red
        case "tentative": return .yellow
        default: return .gray
        }
    }
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
    let accountEmail: String?

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
        isAllDay: Bool = false,
        accountEmail: String? = nil
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
        self.accountEmail = accountEmail
    }

    /// Current user's RSVP status for this event
    var myRSVPStatus: String? {
        guard let email = accountEmail else { return nil }
        return attendees.first(where: { $0.email.lowercased() == email.lowercased() })?.responseStatus
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
