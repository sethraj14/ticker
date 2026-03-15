import SwiftUI
import Combine

final class CalendarViewModel: ObservableObject {
    @Published var menuBarLabel: String = "No meetings"
    @Published var selectedDate: Date = .now
    @Published var events: [CalendarEvent] = []

    let googleService = GoogleCalendarService.shared
    private var timer: AnyCancellable?
    private var refreshTimer: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

    init() {
        startTimer()
        startRefreshTimer()

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
    }

    var isAuthenticated: Bool {
        googleService.isAuthenticated
    }

    var selectedDateLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate) {
            return "Today, \(selectedDate.formatted(.dateTime.month(.abbreviated).day()))"
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
            let fetched = await googleService.fetchEvents(for: selectedDate)
            self.events = fetched
        }
    }

    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.updateMenuBarLabel() }
    }

    // Refresh events every 5 minutes
    private func startRefreshTimer() {
        refreshTimer = Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.isAuthenticated else { return }
                self.fetchEvents()
            }
    }

    private func updateMenuBarLabel() {
        // Only countdown for today's events
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
