import Foundation
import UserNotifications

final class ReminderManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = ReminderManager()

    private let center = UNUserNotificationCenter.current()
    private var requested = false

    override init() {
        super.init()
        center.delegate = self
    }

    func apply(_ reminder: AppState.Reminder) {
        center.removeAllPendingNotificationRequests()
        guard reminder != .off else { return }

        switch reminder {
        case .fourPM: schedule(hour: 16)
        case .sevenPM: schedule(hour: 19)
        case .both:
            schedule(hour: 16)
            schedule(hour: 19)
        case .off:
            break
        }

        if !requested {
            requested = true
            center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
        }
    }

    private func schedule(hour: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Surah Mulk · daily recitation"
        content.body = "30 verses, about five minutes. Open Quick Pass and keep the chain alive."
        content.sound = .default
        content.userInfo = ["tab": AppState.Tab.quickPass.rawValue]

        var components = DateComponents()
        components.hour = hour
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: "com.ikbhal.surahmulk.daily.\(hour)",
            content: content,
            trigger: trigger
        )
        center.add(request, withCompletionHandler: nil)
    }

    // App in foreground — show the banner too.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if let raw = response.notification.request.content.userInfo["tab"] as? String,
           let tab = AppState.Tab(rawValue: raw) {
            NotificationCenter.default.post(name: .openTab, object: tab)
        }
        completionHandler()
    }
}

extension Notification.Name {
    static let openTab = Notification.Name("openTab")
}
