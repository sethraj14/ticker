import Foundation
import UserNotifications
import AppKit

final class NotificationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()

    private let meetingCategory = "MEETING"
    private let joinAction = "JOIN"
    private let notificationLeadTimesKey = "notification_lead_times"

    @Published var isAuthorized = false

    private var scheduledEventIDs: Set<String> = []
    private var panelTimers: [String: Timer] = [:]
    private var eventStore: [String: CalendarEvent] = [:]

    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        // Clear any previously scheduled native notifications — custom panel is the only system now
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        registerCategories()
        checkAuthorization()
        migrateDefaultLeadTimes()
    }

    /// One-time migration: ensure 1-minute lead time exists for existing users
    private func migrateDefaultLeadTimes() {
        let migrationKey = "notification_lead_times_v2_migrated"
        guard !UserDefaults.standard.bool(forKey: migrationKey) else { return }
        UserDefaults.standard.set(true, forKey: migrationKey)

        var times = leadTimes
        if !times.contains(1) {
            times.append(1)
            times.sort(by: >)
            leadTimes = times
        }
    }

    // MARK: - Lead Times (user-configurable)

    var leadTimes: [Int] {
        get {
            let saved = UserDefaults.standard.array(forKey: notificationLeadTimesKey) as? [Int]
            return saved ?? [10, 1] // default: 10 minutes and 1 minute before
        }
        set {
            UserDefaults.standard.set(newValue, forKey: notificationLeadTimesKey)
        }
    }

    // MARK: - Authorization

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
            }
        }
    }

    private func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Categories & Actions

    private func registerCategories() {
        let join = UNNotificationAction(
            identifier: joinAction,
            title: "Join Meeting",
            options: .foreground
        )

        let category = UNNotificationCategory(
            identifier: meetingCategory,
            actions: [join],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    // MARK: - Schedule Notifications

    func scheduleNotifications(for events: [CalendarEvent]) {
        let now = Date.now

        // Store events for custom panel lookup
        for event in events {
            eventStore[event.id] = event
        }

        // Build the set of notification IDs we want to exist
        var desiredIDs: Set<String> = []

        for event in events {
            guard event.startDate.timeIntervalSince(now) > -1 else { continue }

            for leadMinutes in leadTimes {
                let fireDate = event.startDate.addingTimeInterval(-Double(leadMinutes * 60))
                let interval = fireDate.timeIntervalSince(now)

                // Need at least 1 second in the future
                guard interval >= 1 else { continue }

                let notificationID = "\(event.id)_\(leadMinutes)m"
                desiredIDs.insert(notificationID)

                // Skip if already scheduled from a previous call
                guard !scheduledEventIDs.contains(notificationID) else { continue }

                // Schedule custom floating panel timer (only notification system)
                let eventID = event.id
                let lead = leadMinutes
                let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
                    guard let self, let storedEvent = self.eventStore[eventID] else { return }
                    NotificationWindowController.shared.show(event: storedEvent, leadMinutes: lead)
                }
                panelTimers[notificationID] = timer
            }
        }

        // Remove stale timers
        let staleIDs = scheduledEventIDs.subtracting(desiredIDs)
        if !staleIDs.isEmpty {
            for id in staleIDs {
                panelTimers[id]?.invalidate()
                panelTimers.removeValue(forKey: id)
            }
        }

        scheduledEventIDs = desiredIDs
    }

    // MARK: - UNUserNotificationCenterDelegate (kept for backward compatibility)

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Suppress all native notifications — custom panel handles everything
        completionHandler([])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}
