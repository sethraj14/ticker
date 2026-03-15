import SwiftUI
import Combine

final class CalendarViewModel: ObservableObject {
    @Published var menuBarLabel: String = "No meetings"
    @Published var selectedDate: Date = .now
    @Published var displayedEvents: [CalendarEvent] = []  // events for selected day
    @Published var showSettings = false
    @Published var selectedEvent: CalendarEvent? = nil     // tapped meeting for join section

    let googleService = GoogleCalendarService.shared
    let notificationService = NotificationService.shared
    let eventKitService = EventKitService.shared

    private var todayEvents: [CalendarEvent] = []  // always today's events for menu bar
    private var timer: AnyCancellable?
    private var refreshTimer: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

    init() {
        startTimer()
        startRefreshTimer()
        notificationService.requestAuthorization()
        setupWakeObserver()

        eventKitService.onEventsChanged = { [weak self] in
            self?.fetchEvents()
        }

        googleService.$isAuthenticated
            .removeDuplicates()
            .sink { [weak self] isAuth in
                if isAuth {
                    self?.fetchEvents()
                } else {
                    self?.displayedEvents = []
                    self?.todayEvents = []
                }
            }
            .store(in: &cancellables)

        // Schedule notifications when today's events change
        $displayedEvents
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.notificationService.scheduleNotifications(for: self.todayEvents)
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
        return selectedDate.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }

    // Next upcoming event — always from TODAY's events (for menu bar)
    var nextUpcomingEvent: CalendarEvent? {
        let now = Date.now
        return todayEvents
            .filter { $0.endDate > now }
            .sorted { $0.startDate < $1.startDate }
            .first
    }

    // The event to show in join section: selected event, or next upcoming if viewing today
    var joinSectionEvent: CalendarEvent? {
        if let selected = selectedEvent {
            return selected
        }
        if Calendar.current.isDateInToday(selectedDate) {
            return nextUpcomingEvent
        }
        return nil
    }

    func selectEvent(_ event: CalendarEvent) {
        if selectedEvent?.id == event.id {
            selectedEvent = nil  // deselect on second tap
        } else {
            selectedEvent = event
        }
    }

    func navigateDay(by offset: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: offset, to: selectedDate) {
            selectedDate = newDate
            selectedEvent = nil
            fetchDisplayedEvents()
        }
    }

    func goToToday() {
        selectedDate = .now
        selectedEvent = nil
        fetchEvents()
    }

    func authenticate() {
        googleService.authenticate()
    }

    func signOut() {
        googleService.signOut()
        displayedEvents = []
        todayEvents = []
    }

    func fetchEvents() {
        // Always fetch today for menu bar
        fetchTodayEvents()
        // Fetch displayed date
        fetchDisplayedEvents()
    }

    func rescheduleNotifications() {
        notificationService.scheduleNotifications(for: todayEvents)
    }

    // MARK: - Private

    private func fetchTodayEvents() {
        Task { @MainActor in
            let today = Date.now
            var allEvents: [CalendarEvent] = []
            let googleEvents = await googleService.fetchEvents(for: today)
            allEvents.append(contentsOf: googleEvents)
            let appleEvents = eventKitService.fetchEvents(for: today)
            allEvents.append(contentsOf: appleEvents)
            self.todayEvents = deduplicateEvents(allEvents)
        }
    }

    private func fetchDisplayedEvents() {
        let dateToFetch = selectedDate
        Task { @MainActor in
            var allEvents: [CalendarEvent] = []
            let googleEvents = await googleService.fetchEvents(for: dateToFetch)
            allEvents.append(contentsOf: googleEvents)
            let appleEvents = eventKitService.fetchEvents(for: dateToFetch)
            allEvents.append(contentsOf: appleEvents)
            self.displayedEvents = deduplicateEvents(allEvents)
        }
    }

    private func deduplicateEvents(_ events: [CalendarEvent]) -> [CalendarEvent] {
        var seen = Set<String>()
        return events.filter { event in
            let calendar = Calendar.current
            let day = calendar.component(.day, from: event.startDate)
            let minute = calendar.component(.minute, from: event.startDate)
            let hour = calendar.component(.hour, from: event.startDate)
            let key = "\(event.title.lowercased())_\(day)_\(hour):\(minute)"
            if seen.contains(key) { return false }
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

    // Menu bar ALWAYS shows today's next event countdown
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
}
