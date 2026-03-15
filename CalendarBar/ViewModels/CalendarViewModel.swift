import SwiftUI
import Combine

final class CalendarViewModel: ObservableObject {
    @Published var menuBarLabel: String = "No meetings"
    @Published var selectedDate: Date = .now
    @Published var events: [CalendarEvent] = []

    private var timer: AnyCancellable?

    init() {
        loadSampleEvents()
        startTimer()
    }

    var selectedDateLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate) {
            return "Today, \(selectedDate.formatted(.dateTime.month(.abbreviated).day()))"
        }
        return selectedDate.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }

    var nextUpcomingEvent: CalendarEvent? {
        let now = Date.now
        return events
            .filter { $0.endDate > now }
            .sorted { $0.startDate < $1.startDate }
            .first
    }

    func navigateDay(by offset: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: offset, to: selectedDate) {
            selectedDate = newDate
        }
    }

    func goToToday() {
        selectedDate = .now
    }

    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.updateMenuBarLabel() }
    }

    private func updateMenuBarLabel() {
        guard let next = nextUpcomingEvent else {
            menuBarLabel = "No meetings"
            return
        }

        let diff = next.startDate.timeIntervalSinceNow

        if diff <= 0 {
            menuBarLabel = "\(next.title) NOW"
        } else if diff < 60 {
            menuBarLabel = "\(next.title) in \(Int(diff))s"
        } else if diff < 3600 {
            menuBarLabel = "\(next.title) in \(Int(diff / 60))m"
        } else {
            let hours = Int(diff / 3600)
            let mins = Int((diff.truncatingRemainder(dividingBy: 3600)) / 60)
            menuBarLabel = "\(next.title) in \(hours)h \(mins)m"
        }
    }

    private func loadSampleEvents() {
        let calendar = Calendar.current
        let now = Date.now

        guard let nineAM = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now),
              let nineThirty = calendar.date(bySettingHour: 9, minute: 30, second: 0, of: now),
              let elevenAM = calendar.date(bySettingHour: 11, minute: 0, second: 0, of: now),
              let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: now),
              let twoPM = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now),
              let threeThirty = calendar.date(bySettingHour: 15, minute: 30, second: 0, of: now)
        else { return }

        events = [
            CalendarEvent(
                id: "1",
                title: "Team Standup",
                startDate: nineAM,
                endDate: nineThirty,
                meetingURL: URL(string: "https://meet.google.com/abc-defg-hij"),
                source: .google,
                calendarColor: .blue,
                attendees: ["Alice", "Bob", "Charlie"],
                location: nil,
                notes: "Daily sync"
            ),
            CalendarEvent(
                id: "2",
                title: "Design Review",
                startDate: elevenAM,
                endDate: noon,
                meetingURL: URL(string: "https://meet.google.com/xyz-uvwx-rst"),
                source: .google,
                calendarColor: .green,
                attendees: ["Alice", "Diana"],
                location: nil,
                notes: "Review new dashboard designs"
            ),
            CalendarEvent(
                id: "3",
                title: "Sprint Planning",
                startDate: twoPM,
                endDate: threeThirty,
                meetingURL: URL(string: "https://zoom.us/j/123456789"),
                source: .google,
                calendarColor: .purple,
                attendees: ["Full team"],
                location: "Conference Room B",
                notes: nil
            ),
        ]
    }
}
