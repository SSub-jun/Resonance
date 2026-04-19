import Foundation
import UserNotifications

final class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationHandler()

    static let eventIDKey = "eventID"

    private override init() { super.init() }

    func bootstrap() {
        UNUserNotificationCenter.current().delegate = self
    }

    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

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
        let userInfo = response.notification.request.content.userInfo

        if let idString = userInfo[Self.eventIDKey] as? String,
           let id = UUID(uuidString: idString) {
            Task { @MainActor in
                DeepLinkRouter.shared.pendingEventID = id
            }
        }

        completionHandler()
    }

    #if DEBUG
    /// 로컬 테스트용: eventID를 payload에 넣고 지연 후 로컬 알림 발송.
    /// 백그라운드로 내려보낸 뒤 알림센터에서 탭하면 딥링크 플로우 검증 가능.
    func scheduleDebugNotification(eventID: UUID, delay: TimeInterval = 5, title: String = "Resonance", body: String = "Tap to view on map") {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = [Self.eventIDKey: eventID.uuidString]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    #endif
}
