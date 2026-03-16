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

    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
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
        let center = UNUserNotificationCenter.current()
        let now = Date.now

        // Build the set of notification IDs we want to exist
        var desiredIDs: Set<String> = []
        var requests: [UNNotificationRequest] = []

        for event in events {
            guard event.startDate.timeIntervalSince(now) > -1 else { continue }

            for leadMinutes in leadTimes {
                let fireDate = event.startDate.addingTimeInterval(-Double(leadMinutes * 60))
                let interval = fireDate.timeIntervalSince(now)

                // Need at least 1 second in the future for UNTimeIntervalNotificationTrigger
                guard interval >= 1 else { continue }

                let notificationID = "\(event.id)_\(leadMinutes)m"
                desiredIDs.insert(notificationID)

                // Skip if already scheduled from a previous call
                guard !scheduledEventIDs.contains(notificationID) else { continue }

                let content = UNMutableNotificationContent()
                content.title = event.title
                content.sound = .default
                content.categoryIdentifier = meetingCategory

                if leadMinutes == 1 {
                    content.body = "Starting in 60 seconds — get ready to join"
                    content.interruptionLevel = .timeSensitive
                } else if leadMinutes > 0 {
                    content.body = "Starts in \(leadMinutes) minutes"
                } else {
                    content.body = "Starting now"
                    content.interruptionLevel = .timeSensitive
                }

                if let url = event.meetingURL {
                    content.userInfo["meetingURL"] = url.absoluteString
                }
                content.userInfo["eventID"] = event.id

                let trigger = UNTimeIntervalNotificationTrigger(
                    timeInterval: interval,
                    repeats: false
                )

                requests.append(UNNotificationRequest(
                    identifier: notificationID,
                    content: content,
                    trigger: trigger
                ))
            }
        }

        // Remove only notifications that are no longer needed (e.g. cancelled events)
        let staleIDs = scheduledEventIDs.subtracting(desiredIDs)
        if !staleIDs.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: Array(staleIDs))
        }

        // Add new notifications
        for request in requests {
            center.add(request)
        }

        scheduledEventIDs = desiredIDs
    }

    // MARK: - UNUserNotificationCenterDelegate

    // Show notifications even when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    // Handle notification actions
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        if response.actionIdentifier == joinAction || response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            if let urlString = userInfo["meetingURL"] as? String,
               let url = URL(string: urlString) {
                NSWorkspace.shared.open(url)
            }
        }

        completionHandler()
    }
}
