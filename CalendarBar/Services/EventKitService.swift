import Foundation
import EventKit
import SwiftUI

final class EventKitService: ObservableObject {
    static let shared = EventKitService()

    @Published var isAuthorized = false
    @Published var isEnabled = false {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "apple_calendar_enabled")
        }
    }

    private let store = EKEventStore()

    private init() {
        isEnabled = UserDefaults.standard.bool(forKey: "apple_calendar_enabled")
        checkAuthorization()
        setupChangeNotification()
    }

    var onEventsChanged: (() -> Void)?

    // MARK: - Authorization

    func requestAccess() {
        if #available(macOS 14.0, *) {
            store.requestFullAccessToEvents { [weak self] granted, _ in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted { self?.isEnabled = true }
                }
            }
        } else {
            store.requestAccess(to: .event) { [weak self] granted, _ in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted { self?.isEnabled = true }
                }
            }
        }
    }

    private func checkAuthorization() {
        let status = EKEventStore.authorizationStatus(for: .event)
        if #available(macOS 14.0, *) {
            isAuthorized = status == .fullAccess
        } else {
            isAuthorized = status == .authorized
        }
    }

    private func setupChangeNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(eventStoreChanged),
            name: .EKEventStoreChanged,
            object: store
        )
    }

    @objc private func eventStoreChanged() {
        DispatchQueue.main.async { [weak self] in
            self?.onEventsChanged?()
        }
    }

    // MARK: - Fetch Events

    func fetchEvents(for date: Date) -> [CalendarEvent] {
        guard isAuthorized, isEnabled else { return [] }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }

        let predicate = store.predicateForEvents(
            withStart: startOfDay,
            end: endOfDay,
            calendars: nil
        )

        let ekEvents = store.events(matching: predicate)

        return ekEvents.compactMap { ekEvent in
            // Skip all-day events for now
            guard !ekEvent.isAllDay else { return nil }
            // Skip cancelled/declined
            guard ekEvent.status != .canceled else { return nil }

            let meetingURL = extractMeetingURL(from: ekEvent)
            let attendees = ekEvent.attendees?.compactMap { $0.name } ?? []
            let color = Color(cgColor: ekEvent.calendar.cgColor)

            return CalendarEvent(
                id: ekEvent.eventIdentifier,
                title: ekEvent.title ?? "(No title)",
                startDate: ekEvent.startDate,
                endDate: ekEvent.endDate,
                meetingURL: meetingURL,
                source: .apple,
                calendarColor: color,
                attendees: attendees,
                location: ekEvent.location,
                notes: ekEvent.notes
            )
        }
    }

    private func extractMeetingURL(from event: EKEvent) -> URL? {
        if let urlStr = event.url?.absoluteString,
           urlStr.contains("meet.google") || urlStr.contains("zoom.us") || urlStr.contains("teams.microsoft") {
            return event.url
        }
        if let location = event.location {
            if location.hasPrefix("https://") {
                return URL(string: location)
            }
        }
        if let notes = event.notes {
            let patterns = ["https://meet\\.google\\.com/[a-z-]+", "https://[a-z]+\\.zoom\\.us/j/[0-9]+"]
            for pattern in patterns {
                if let range = notes.range(of: pattern, options: .regularExpression) {
                    return URL(string: String(notes[range]))
                }
            }
        }
        return nil
    }
}
