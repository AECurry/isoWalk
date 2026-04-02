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
    
    // MARK: - Initialization
    
    init() {
        // Set default pace to "steady" (3-3) on first launch
        if UserDefaults.standard.string(forKey: "lastSelectedPace") == nil {
            UserDefaults.standard.set("steady", forKey: "lastSelectedPace")
        }
        
        // Set default duration to "thirty" minutes on first launch
        if UserDefaults.standard.string(forKey: "lastSelectedDuration") == nil {
            UserDefaults.standard.set("thirty", forKey: "lastSelectedDuration")
        }
    }

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

