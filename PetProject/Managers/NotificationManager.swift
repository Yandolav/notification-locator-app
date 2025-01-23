import UIKit
import MapKit
import UserNotifications

// MARK: - NotificationManager

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    // MARK: - Singleton
    
    static let shared = NotificationManager()
    
    // MARK: - Properties
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    // MARK: - Public Methods
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if let error = error {
                print("Ошибка при запросе разрешений на уведомления: \(error.localizedDescription)")
                return
            }
            if granted {
                print("Разрешение на уведомления предоставлено.")
            } else {
                print("Разрешение на уведомления не предоставлено.")
            }
        }
    }
    
    func sendNotificationEnter(for note: Note) {
        let content = UNMutableNotificationContent()
        content.title = note.title
        content.body = note.body
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(identifier: note.id.uuidString,
                                            content: content,
                                            trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("Ошибка при добавлении уведомления: \(error.localizedDescription)")
            }
        }
    }
    
    func sendNotificationExit() {
        let content = UNMutableNotificationContent()
        content.title = "Пока!"
        content.body = "Не забудьте обновить заметки в данной точке. Хорошего дня!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "exit_trigger",
                                            content: content,
                                            trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Ошибка при добавлении уведомления: \(error.localizedDescription)")
            }
        }
    }
    
        
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}

