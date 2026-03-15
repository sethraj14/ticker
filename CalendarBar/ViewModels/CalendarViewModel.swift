import SwiftUI
import Combine

final class CalendarViewModel: ObservableObject {
    @Published var menuBarLabel: String = "No meetings"
    @Published var selectedDate: Date = .now
    @Published var events: [CalendarEvent] = []
    @Published var showSettings = false

    let googleService = GoogleCalendarService.shared
    let notificationService = NotificationService.shared
    let eventKitService = EventKitService.shared
    private var timer: AnyCancellable?
    private var refreshTimer: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

    init() {
        startTimer()
        startRefreshTimer()
        notificationService.requestAuthorization()
        setupWakeObserver()

        // Listen for Apple Calendar changes
        eventKitService.onEventsChanged = { [weak self] in
            self?.fetchEvents()
        }

        // Watch for auth state changes
        googleService.$isAuthenticated
            .removeDuplicates()
            .sink { [weak self] isAuth in
                if isAuth {
                    self?.fetchEvents()
                } else {
                    self?.events = []
                }
            }
            .store(in: &cancellables)

        // Re-schedule notifications when events change
        $events
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] events in
                self?.notificationService.scheduleNotifications(for: events)
            }
            .store(in: &cancellables)
    }

    var isAuthenticated: Bool {
        googleService.isAuthenticated
    }

    var selectedDateLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate) {
            return "Today, \(selectedDate.formatted(.dateTime.month(.abbreviated).day()))"
        }
        if calendar.isDateInYesterday(selectedDate) {
            return "Yesterday, \(selectedDate.formatted(.dateTime.month(.abbreviated).day()))"
        }
        if calendar.isDateInTomorrow(selectedDate) {
            return "Tomorrow, \(selectedDate.formatted(.dateTime.month(.abbreviated).day()))"
        }
        return selectedDate.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }

    var nextUpcomingEvent: CalendarEvent? {
        guard Calendar.current.isDateInToday(selectedDate) else { return nil }
        let now = Date.now
        return events
            .filter { $0.endDate > now }
            .sorted { $0.startDate < $1.startDate }
            .first
    }

    func navigateDay(by offset: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: offset, to: selectedDate) {
            selectedDate = newDate
            fetchEvents()
        }
    }

    func goToToday() {
        selectedDate = .now
        fetchEvents()
    }

    func authenticate() {
        googleService.authenticate()
    }

    func signOut() {
        googleService.signOut()
        events = []
    }

    func fetchEvents() {
        Task { @MainActor in
            var allEvents: [CalendarEvent] = []

            // Fetch Google Calendar events
            let googleEvents = await googleService.fetchEvents(for: selectedDate)
            allEvents.append(contentsOf: googleEvents)

            // Fetch Apple Calendar events
            let appleEvents = eventKitService.fetchEvents(for: selectedDate)
            allEvents.append(contentsOf: appleEvents)

            // Deduplicate by title + approximate start time
            self.events = deduplicateEvents(allEvents)
        }
    }

    func rescheduleNotifications() {
        notificationService.scheduleNotifications(for: events)
    }

    // MARK: - Private

    private func deduplicateEvents(_ events: [CalendarEvent]) -> [CalendarEvent] {
        var seen = Set<String>()
        return events.filter { event in
            // Create a key from title + start time (rounded to nearest minute)
            let calendar = Calendar.current
            let minute = calendar.component(.minute, from: event.startDate)
            let hour = calendar.component(.hour, from: event.startDate)
            let key = "\(event.title.lowercased())_\(hour):\(minute)"

            if seen.contains(key) {
                return false
            }
            seen.insert(key)
            return true
        }
    }

    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.updateMenuBarLabel() }
    }

    private func startRefreshTimer() {
        refreshTimer = Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.isAuthenticated else { return }
                self.fetchEvents()
            }
    }

    private func setupWakeObserver() {
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.goToToday()
        }
    }

    private func updateMenuBarLabel() {
        guard Calendar.current.isDateInToday(selectedDate) else {
            menuBarLabel = selectedDate.formatted(.dateTime.month(.abbreviated).day())
            return
        }

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
}
