//
//  isoWalkApp.swift
//  isoWalk
//
//  Created by AnnElaine on 2/12/26.
//
//  APP ROOT — creates shared services and injects them into the environment.
//  No business logic lives here. Both coordinators are created once and live
//  for the entire app lifetime.
//
//  scenePhase observer calls DailyReminderScheduler.refreshSchedule() every
//  time the app comes to foreground — ensures noon/6pm reminders are always
//  current and cancelled if user already walked today.
//

import SwiftUI

@main
struct isoWalkApp: App {
    @State private var sessionManager = SessionManager()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            isoWalkMainView()
                .environment(sessionManager)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                DailyReminderScheduler.refreshSchedule()
            }
        }
    }
}
