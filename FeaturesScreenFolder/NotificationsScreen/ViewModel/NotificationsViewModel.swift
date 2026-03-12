//
//  NotificationsViewModel.swift
//  isoWalk
//
//  Created by AnnElaine on 3/9/26.
//
//
//  VIEWMODEL — all business logic for NotificationsScreenView.
//  Manages 6 notification toggles. No time picker — daily reminder
//  fires at 9:00 AM automatically. All others are event-driven.
//  Mirrors HealthKit denied pattern — shows alert with Open Settings button.
//  Persists all state to UserDefaults — consistent with rest of app.
//
//  NOTIFICATION SCHEDULE:
//  - Daily Reminder       → 9:00 AM every day (scheduled)
//  - Streak Alert         → fired by SessionManager when streak at risk
//  - Badge Earned         → fired by BadgesViewModel when badge unlocked
//  - Walk Complete        → fired by WalkSessionViewModel on session end
//  - Weekly Progress      → Sunday 6:00 PM (scheduled)
//  - Inactivity Nudge     → fired by SessionManager after 2 days no walk
//

import SwiftUI
import UserNotifications
import Observation

@Observable
final class NotificationsViewModel {

    // MARK: - UserDefaults Keys
    private let dailyReminderKey   = "notif_dailyReminder"
    private let streakAlertKey     = "notif_streakAlert"
    private let badgeEarnedKey     = "notif_badgeEarned"
    private let walkSummaryKey     = "notif_walkSummary"
    private let weeklyReportKey    = "notif_weeklyReport"
    private let inactivityNudgeKey = "notif_inactivityNudge"

    // MARK: - Notification Identifiers
    static let dailyReminderID   = "isoWalk_dailyReminder"
    static let streakAlertID     = "isoWalk_streakAlert"
    static let badgeEarnedID     = "isoWalk_badgeEarned"
    static let walkSummaryID     = "isoWalk_walkSummary"
    static let weeklyReportID    = "isoWalk_weeklyReport"
    static let inactivityNudgeID = "isoWalk_inactivityNudge"

    // MARK: - Toggle State
    var isDailyReminderOn: Bool = false {
        didSet { handleScheduledToggle(isDailyReminderOn, key: dailyReminderKey, schedule: scheduleDailyReminder, cancel: { self.cancel(self.dailyReminderID) }) }
    }
    var isStreakAlertOn: Bool = false {
        didSet { UserDefaults.standard.set(isStreakAlertOn, forKey: streakAlertKey) }
    }
    var isBadgeEarnedOn: Bool = false {
        didSet { UserDefaults.standard.set(isBadgeEarnedOn, forKey: badgeEarnedKey) }
    }
    var isWalkSummaryOn: Bool = false {
        didSet { UserDefaults.standard.set(isWalkSummaryOn, forKey: walkSummaryKey) }
    }
    var isWeeklyReportOn: Bool = false {
        didSet { handleScheduledToggle(isWeeklyReportOn, key: weeklyReportKey, schedule: scheduleWeeklyReport, cancel: { self.cancel(self.weeklyReportID) }) }
    }
    var isInactivityNudgeOn: Bool = false {
        didSet { UserDefaults.standard.set(isInactivityNudgeOn, forKey: inactivityNudgeKey) }
    }

    var showDeniedAlert: Bool = false

    // MARK: - Static read helpers (used by other ViewModels to check before firing)
    static func isEnabled(_ key: String) -> Bool {
        UserDefaults.standard.bool(forKey: key)
    }
    static var streakAlertsEnabled:   Bool { isEnabled("notif_streakAlert") }
    static var badgeAlertsEnabled:    Bool { isEnabled("notif_badgeEarned") }
    static var walkSummaryEnabled:    Bool { isEnabled("notif_walkSummary") }
    static var inactivityNudgeEnabled:Bool { isEnabled("notif_inactivityNudge") }

    // MARK: - Init
    init() {
        isDailyReminderOn   = UserDefaults.standard.bool(forKey: dailyReminderKey)
        isStreakAlertOn     = UserDefaults.standard.bool(forKey: streakAlertKey)
        isBadgeEarnedOn     = UserDefaults.standard.bool(forKey: badgeEarnedKey)
        isWalkSummaryOn     = UserDefaults.standard.bool(forKey: walkSummaryKey)
        isWeeklyReportOn    = UserDefaults.standard.bool(forKey: weeklyReportKey)
        isInactivityNudgeOn = UserDefaults.standard.bool(forKey: inactivityNudgeKey)
    }

    // MARK: - Toggle Handler for Scheduled Notifications
    private func handleScheduledToggle(
        _ isOn: Bool,
        key: String,
        schedule: @escaping () -> Void,
        cancel: @escaping () -> Void
    ) {
        if isOn {
            requestAuthorizationThen {
                schedule()
                UserDefaults.standard.set(true, forKey: key)
            } onDenied: {
                // Snap back off — will trigger didSet again but isOn will be false
                UserDefaults.standard.set(false, forKey: key)
            }
        } else {
            cancel()
            UserDefaults.standard.set(false, forKey: key)
        }
    }

    // MARK: - Permission Request
    private func requestAuthorizationThen(onGranted: @escaping () -> Void, onDenied: @escaping () -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                guard let self else { return }
                switch settings.authorizationStatus {
                case .denied:
                    self.showDeniedAlert = true
                    onDenied()
                case .authorized, .provisional, .ephemeral:
                    onGranted()
                case .notDetermined:
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                        DispatchQueue.main.async {
                            if granted { onGranted() } else {
                                self.showDeniedAlert = true
                                onDenied()
                            }
                        }
                    }
                @unknown default:
                    break
                }
            }
        }
    }

    // MARK: - Schedule: Daily Reminder (9:00 AM every day)
    private func scheduleDailyReminder() {
        let content = UNMutableNotificationContent()
        let name = UserDefaults.standard.string(forKey: "userName") ?? "Friend"
        content.title = "Time for your walk, \(name)! 🚶"
        content.body  = "A short walk today keeps you strong tomorrow."
        content.sound = .default

        var components = DateComponents()
        components.hour   = 11
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        schedule(id: dailyReminderID, content: content, trigger: trigger)
    }

    // MARK: - Schedule: Weekly Progress Report (Sunday 6:00 PM)
    private func scheduleWeeklyReport() {
        let content = UNMutableNotificationContent()
        let name = UserDefaults.standard.string(forKey: "userName") ?? "Friend"
        content.title = "Your weekly progress, \(name)! 📊"
        content.body  = "Check out how many walks you completed this week."
        content.sound = .default

        var components = DateComponents()
        components.weekday = 1  // Sunday
        components.hour    = 18
        components.minute  = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        schedule(id: weeklyReportID, content: content, trigger: trigger)
    }

    // MARK: - Helpers
    private func schedule(id: String, content: UNMutableNotificationContent, trigger: UNNotificationTrigger) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id])
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }

    private func cancel(_ id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    private var dailyReminderID:   String { NotificationsViewModel.dailyReminderID }
    private var weeklyReportID:    String { NotificationsViewModel.weeklyReportID }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

