import SwiftUI
import Combine

final class CalendarViewModel: ObservableObject {
    @Published var menuBarLabel: String = "No meetings"
    @Published var selectedDate: Date = .now
    @Published var displayedEvents: [CalendarEvent] = []
    @Published var showSettings = false
    @Published var selectedEvent: CalendarEvent? = nil

    let googleService = GoogleCalendarService.shared
    let notificationService = NotificationService.shared
    let eventKitService = EventKitService.shared

    private var todayEvents: [CalendarEvent] = []
    private var eventCache: [String: [CalendarEvent]] = [:]
    private var timer: AnyCancellable?
    private var refreshTimer: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private var navigationDebounce: AnyCancellable?
    @Published var isSyncing = false

    private static let cacheDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    init() {
        startTimer()
        startRefreshTimer()
        notificationService.requestAuthorization()
        setupWakeObserver()
        setupCrashProtection()

        eventKitService.onEventsChanged = { [weak self] in
            self?.refreshAll()
        }

        googleService.$accounts
            .removeDuplicates()
            .sink { [weak self] accounts in
                if !accounts.isEmpty {
                    self?.refreshAll()
                } else {
                    self?.displayedEvents = []
                    self?.todayEvents = []
                    self?.eventCache.removeAll()
                }
            }
            .store(in: &cancellables)
    }

    deinit {
        timer?.cancel()
        refreshTimer?.cancel()
        navigationDebounce?.cancel()
        cancellables.removeAll()
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

    /// Priority logic: if an upcoming meeting starts within 10 minutes,
    /// show it instead of an ongoing meeting (it's more actionable).
    var nextUpcomingEvent: CalendarEvent? {
        let now = Date.now
        // Use todayEvents if available, fallback to displayedEvents when viewing today
        let source = todayEvents.isEmpty && Calendar.current.isDateInToday(selectedDate)
            ? displayedEvents
            : todayEvents
        let activeEvents = source
            .filter { $0.endDate > now && !$0.isAllDay }
            .sorted { $0.startDate < $1.startDate }

        // Find the next event that hasn't started yet
        let upcoming = activeEvents.first { $0.startDate > now }

        // If an upcoming event starts within 10 minutes, prioritize it
        if let upcoming, upcoming.startDate.timeIntervalSince(now) <= 600 {
            return upcoming
        }

        // Otherwise show the earliest active event (ongoing or upcoming)
        return activeEvents.first
    }

    var joinSectionEvent: CalendarEvent? {
        if let selected = selectedEvent {
            return selected
        }
        if Calendar.current.isDateInToday(selectedDate) {
            return nextUpcomingEvent
        }
        // For non-today dates, show the first timed event of that day
        let timedEvents = displayedEvents
            .filter { !$0.isAllDay }
            .sorted { $0.startDate < $1.startDate }
        return timedEvents.first
    }

    func selectEvent(_ event: CalendarEvent) {
        if selectedEvent?.id == event.id {
            selectedEvent = nil
        } else {
            selectedEvent = event
        }
    }

    func navigateDay(by offset: Int) {
        guard let newDate = Calendar.current.date(byAdding: .day, value: offset, to: selectedDate) else { return }
        selectedDate = newDate
        selectedEvent = nil

        // Show cached data immediately
        let key = cacheKey(for: newDate)
        if let cached = eventCache[key] {
            displayedEvents = cached
        }

        // Debounce rapid clicks
        navigationDebounce?.cancel()
        navigationDebounce = Just(newDate)
            .delay(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] date in
                self?.fetchForDate(date)
                self?.prefetchAround(date)
            }
    }

    func goToToday() {
        selectedDate = .now
        selectedEvent = nil
        let key = cacheKey(for: .now)
        if let cached = eventCache[key] {
            displayedEvents = cached
        }
        fetchForDate(.now)
    }

    func addAccount() {
        googleService.addAccount()
    }

    func removeAccount(_ account: GoogleAccount) {
        googleService.removeAccount(account)
        eventCache.removeAll()
        refreshAll()
    }

    func signOutAll() {
        googleService.signOutAll()
        displayedEvents = []
        todayEvents = []
        eventCache.removeAll()
    }

    func fetchEvents() {
        refreshAll()
    }

    func rescheduleNotifications() {
        notificationService.scheduleNotifications(for: todayEvents)
    }

    // MARK: - Private: Single fetch path

    private func cacheKey(for date: Date) -> String {
        Self.cacheDateFormatter.string(from: date)
    }

    /// Main refresh — fetches today + selected date, updates everything
    private func refreshAll() {
        guard !isSyncing else { return }
        isSyncing = true
        eventCache.removeAll()

        Task { @MainActor in
            // Always fetch today first
            let todayKey = cacheKey(for: .now)
            let todayResult = await fetchMergedEvents(for: .now)
            todayEvents = todayResult
            eventCache[todayKey] = todayResult
            notificationService.scheduleNotifications(for: todayResult)

            // If viewing today, update display
            if cacheKey(for: selectedDate) == todayKey {
                displayedEvents = todayResult
            } else {
                // Fetch selected date separately
                let selectedKey = cacheKey(for: selectedDate)
                let selectedResult = await fetchMergedEvents(for: selectedDate)
                eventCache[selectedKey] = selectedResult
                if cacheKey(for: self.selectedDate) == selectedKey {
                    displayedEvents = selectedResult
                }
            }

            isSyncing = false
            prefetchAround(selectedDate)
        }
    }

    /// Fetch a single date and update display if still selected
    private func fetchForDate(_ date: Date) {
        let key = cacheKey(for: date)
        Task { @MainActor in
            let events = await fetchMergedEvents(for: date)
            eventCache[key] = events

            // Update display only if this date is still selected
            if cacheKey(for: self.selectedDate) == key {
                displayedEvents = events
            }

            // If this is today, also update todayEvents
            if cacheKey(for: .now) == key {
                todayEvents = events
                notificationService.scheduleNotifications(for: events)
            }
        }
    }

    private func prefetchAround(_ date: Date) {
        let calendar = Calendar.current
        for offset in [-1, 1, 2] {
            if let d = calendar.date(byAdding: .day, value: offset, to: date) {
                let key = cacheKey(for: d)
                if eventCache[key] == nil {
                    Task { @MainActor in
                        let events = await fetchMergedEvents(for: d)
                        eventCache[key] = events
                    }
                }
            }
        }
    }

    private func fetchMergedEvents(for date: Date) async -> [CalendarEvent] {
        async let googleEvents = googleService.fetchEvents(for: date)
        let appleEvents = eventKitService.fetchEvents(for: date)

        var allEvents: [CalendarEvent] = []
        allEvents.append(contentsOf: await googleEvents)
        allEvents.append(contentsOf: appleEvents)
        return deduplicateEvents(allEvents)
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

    // MARK: - Timers

    private func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.updateMenuBarLabel() }
    }

    private func startRefreshTimer() {
        refreshTimer?.cancel()
        refreshTimer = Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.isAuthenticated else { return }
                self.refreshAll()
            }
    }

    private func setupWakeObserver() {
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            // Reset syncing flag in case a refresh was in-flight when sleep happened
            self.isSyncing = false
            // Restart timers (they may have been cancelled on sleep)
            self.startTimer()
            self.startRefreshTimer()
            self.goToToday()
        }
    }

    /// Monitors for app termination to cleanly stop timers
    private func setupCrashProtection() {
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.willSleepNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.timer?.cancel()
            self?.refreshTimer?.cancel()
        }

        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.timer?.cancel()
            self?.refreshTimer?.cancel()
            self?.cancellables.removeAll()
        }
    }

    private func updateMenuBarLabel() {
        guard let next = nextUpcomingEvent else {
            menuBarLabel = "No meetings"
            return
        }

        let now = Date.now
        let diff = next.startDate.timeIntervalSince(now)
        let isOngoing = diff <= 0

        // Count concurrent events:
        // - For ongoing: count ALL currently active meetings (started & not ended)
        // - For upcoming: count events starting at the same time (within 60s)
        let concurrentCount: Int
        if isOngoing {
            concurrentCount = todayEvents.filter {
                !$0.isAllDay && $0.startDate <= now && $0.endDate > now
            }.count
        } else {
            concurrentCount = todayEvents.filter {
                !$0.isAllDay && $0.endDate > now &&
                abs($0.startDate.timeIntervalSince(next.startDate)) < 60
            }.count
        }

        let label: String
        if concurrentCount > 1 {
            label = "\(concurrentCount) events"
        } else {
            label = next.title
        }

        if diff <= 0 {
            // ONGOING — meeting already started, show time until it ends
            let remaining = next.endDate.timeIntervalSince(now)
            if remaining <= 60 {
                menuBarLabel = "\(label) - \(max(Int(ceil(remaining)), 0))s left"
            } else if remaining < 3600 {
                let mins = Int(ceil(remaining / 60))
                menuBarLabel = "\(label) - \(mins)m left"
            } else {
                let hours = Int(remaining / 3600)
                let mins = Int(ceil((remaining.truncatingRemainder(dividingBy: 3600)) / 60))
                menuBarLabel = "\(label) - \(hours)h \(mins)m left"
            }
        } else if diff < 60 {
            // UPCOMING — under 1 minute, show seconds
            menuBarLabel = "\(label) in \(Int(ceil(diff)))s"
        } else if diff < 3600 {
            // UPCOMING — show minutes (ceil so 9m59s shows "10m" not "9m")
            let mins = Int(ceil(diff / 60))
            menuBarLabel = "\(label) in \(mins)m"
        } else {
            // UPCOMING — hours + minutes
            let hours = Int(diff / 3600)
            let mins = Int(ceil((diff.truncatingRemainder(dividingBy: 3600)) / 60))
            if mins == 0 {
                menuBarLabel = "\(label) in \(hours)h"
            } else {
                menuBarLabel = "\(label) in \(hours)h \(mins)m"
            }
        }
    }
}
