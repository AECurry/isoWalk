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


import SwiftUI
import SwiftData

@main
struct isoWalkApp: App {
    @State private var sessionManager = SessionManager()
    @Environment(\.scenePhase) private var scenePhase
    
    // Explicitly create the ModelContainer so we can safely pass the context to background tasks
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([CompletedSession.self, EarnedBadgeRecord.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            isoWalkMainView()
                .environment(sessionManager)
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // Pass the context so it can check if the user walked today
                DailyReminderScheduler.refreshSchedule(context: sharedModelContainer.mainContext)
            }
        }
    }
}

