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
    }

    // MARK: - Lead Times (user-configurable)

    var leadTimes: [Int] {
        get {
            let saved = UserDefaults.standard.array(forKey: notificationLeadTimesKey) as? [Int]
            return saved ?? [10] // default: 10 minutes before
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
        // Cancel all existing meeting notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        scheduledEventIDs.removeAll()

        let now = Date.now

        for event in events {
            guard event.startDate > now else { continue }

            for leadMinutes in leadTimes {
                let fireDate = event.startDate.addingTimeInterval(-Double(leadMinutes * 60))
                guard fireDate > now else { continue }

                let notificationID = "\(event.id)_\(leadMinutes)m"
                guard !scheduledEventIDs.contains(notificationID) else { continue }

                let content = UNMutableNotificationContent()
                content.title = event.title
                content.sound = .default
                content.categoryIdentifier = meetingCategory

                if leadMinutes > 0 {
                    content.body = "Starts in \(leadMinutes) minutes"
                    if leadMinutes == 1 {
                        content.body = "Starts in 1 minute"
                    }
                } else {
                    content.body = "Starting now"
                }

                if let url = event.meetingURL {
                    content.userInfo["meetingURL"] = url.absoluteString
                }
                content.userInfo["eventID"] = event.id

                let interval = fireDate.timeIntervalSinceNow
                guard interval > 0 else { continue }

                let trigger = UNTimeIntervalNotificationTrigger(
                    timeInterval: interval,
                    repeats: false
                )

                let request = UNNotificationRequest(
                    identifier: notificationID,
                    content: content,
                    trigger: trigger
                )

                UNUserNotificationCenter.current().add(request)
                scheduledEventIDs.insert(notificationID)
            }
        }
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
