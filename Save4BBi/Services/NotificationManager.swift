//
//  NotificationManager.swift
//  MediFamily
//
//  Created by Cường Trần on 05/12/25.
//

import Foundation
import UserNotifications

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization
    
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            await checkAuthorizationStatus()
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }
    
    // MARK: - Schedule Notification
    
    func scheduleReminder(_ reminder: Reminder) async -> Bool {
        // Check authorization first
        if !isAuthorized {
            let granted = await requestAuthorization()
            if !granted { return false }
        }
        
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.message
        content.sound = .default
        content.badge = 1
        
        // Add user info for deep linking
        var userInfo: [String: Any] = [:]
        if let visitId = reminder.visitId {
            userInfo["visitId"] = visitId.uuidString
        }
        if let memberId = reminder.memberId {
            userInfo["memberId"] = memberId.uuidString
        }
        content.userInfo = userInfo
        
        // Create trigger
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminder.scheduledDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: reminder.notificationId,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Reminder scheduled: \(reminder.title) at \(reminder.formattedDate)")
            return true
        } catch {
            print("❌ Failed to schedule reminder: \(error)")
            return false
        }
    }
    
    // MARK: - Cancel Notification
    
    func cancelReminder(_ reminder: Reminder) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [reminder.notificationId])
        print("🗑️ Reminder cancelled: \(reminder.notificationId)")
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ All reminders cancelled")
    }
    
    // MARK: - Get Pending Notifications
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
    
    // MARK: - Clear Badge
    
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                print("Failed to clear badge: \(error)")
            }
        }
    }
}

