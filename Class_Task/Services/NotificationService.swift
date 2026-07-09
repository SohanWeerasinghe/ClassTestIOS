import Foundation
import UserNotifications

enum NotificationService {
    static let dailyChallengeIdentifier = "dailyChallengeReminder"
    
    static func scheduleDailyChallenge(hour: Int, minute: Int, category: QuizCategory, difficulty: QuizDifficulty) async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let allowed = try await center.requestAuthorization(options: [.alert, .sound])
        guard allowed else { return false }
        
        center.removePendingNotificationRequests(withIdentifiers: [dailyChallengeIdentifier])
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge"
        content.body = "Play \(category.title) on \(difficulty.title)."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: dailyChallengeIdentifier, content: content, trigger: trigger)
        try await center.add(request)
        return true
    }
    
    static func cancelDailyChallenge() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dailyChallengeIdentifier])
    }
}
