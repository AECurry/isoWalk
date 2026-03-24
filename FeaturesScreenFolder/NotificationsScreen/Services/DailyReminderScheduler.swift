//
//  DailyReminderScheduler.swift
//  isoWalk
//
//  SERVICE — no SwiftUI, no ViewModel, no state.
//  Pure scheduling logic. Called from two places only:
//    1. isoWalkApp on scenePhase .active
//    2. WalkSessionViewModel.completeSession()
//
//  SCHEDULE:
//    - 12:00 PM reminder fires if user has NOT walked today
//    - 6:00 PM reminder fires if user has STILL not walked today
//  Both are cancelled immediately when a walk completes.
//

import Foundation
import UserNotifications
import SwiftData

enum DailyReminderScheduler {

    static let noonReminderID    = "isoWalk_noonReminder"
    static let eveningReminderID = "isoWalk_eveningReminder"

    // Now requires context to read from the database
    static func refreshSchedule(context: ModelContext) {
        guard UserDefaults.standard.bool(forKey: "notif_dailyReminder") else {
            cancelBothReminders()
            return
        }

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized ||
                  settings.authorizationStatus == .provisional else { return }

            if hasWalkedToday(context: context) {
                cancelBothReminders()
            } else {
                scheduleIfNeeded()
            }
        }
    }

    static func hasWalkedToday(context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<CompletedSession>()
        let sessions = (try? context.fetch(descriptor)) ?? []
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return sessions.contains {
            calendar.startOfDay(for: $0.startTime) == today
        }
    }

    private static func scheduleIfNeeded() {
        let now = Date()
        let calendar = Calendar.current

        var noonComponents    = calendar.dateComponents([.year, .month, .day], from: now)
        var eveningComponents = calendar.dateComponents([.year, .month, .day], from: now)
        noonComponents.hour    = 12; noonComponents.minute    = 0; noonComponents.second = 0
        eveningComponents.hour = 18; eveningComponents.minute = 0; eveningComponents.second = 0

        let noonToday    = calendar.date(from: noonComponents)!
        let eveningToday = calendar.date(from: eveningComponents)!

        let name = UserDefaults.standard.string(forKey: "userName") ?? "Friend"

        if now < noonToday {
            scheduleOnce(id: noonReminderID, at: noonComponents, title: "Time for your walk, \(name)! 🚶", body: "A short walk now will keep you strong and energized.")
        }

        if now < eveningToday {
            scheduleOnce(id: eveningReminderID, at: eveningComponents, title: "Still time for a walk today, \(name)! 🌅", body: "Even a short stroll this evening counts. You've got this.")
        }
    }

    private static func scheduleOnce(id: String, at components: DateComponents, title: String, body: String) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { pending in
            let alreadyScheduled = pending.contains { $0.identifier == id }
            guard !alreadyScheduled else { return }

            let content = UNMutableNotificationContent()
            content.title = title
            content.body  = body
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            center.add(request)
        }
    }

    static func cancelBothReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [noonReminderID, eveningReminderID])
    }
}

