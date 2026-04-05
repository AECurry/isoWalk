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
    
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([CompletedSession.self, EarnedBadgeRecord.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        // Set default pace to "steady" (3-3) on first launch
        if UserDefaults.standard.string(forKey: "lastSelectedPace") == nil {
            UserDefaults.standard.set("steady", forKey: "lastSelectedPace")
        }
        
        // Set default duration to "thirty" minutes on first launch
        if UserDefaults.standard.string(forKey: "lastSelectedDuration") == nil {
            UserDefaults.standard.set("thirty", forKey: "lastSelectedDuration")
        }
        
        // ✅ NEW: Retroactive Quick Start unlock for existing users
        migrateQuickStartFeature()
        
        // 🎬 DEMO MODE: Reset tooltips for presentation
        #if DEBUG
        resetTooltipsForDemo()
        #endif
    }
    
    // MARK: - Migration Helper
    
    private func migrateQuickStartFeature() {
        // Only run this check if the flag doesn't exist yet
        if UserDefaults.standard.object(forKey: "hasCompletedFirstWalk") == nil {
            let context = sharedModelContainer.mainContext
            let descriptor = FetchDescriptor<CompletedSession>()
            
            do {
                let sessions = try context.fetch(descriptor)
                if !sessions.isEmpty {
                    // User has existing walks - unlock Quick Start!
                    UserDefaults.standard.set(true, forKey: "hasCompletedFirstWalk")
                    print("🔓 Quick Start unlocked for existing user (\(sessions.count) walks found)")
                } else {
                    print("🆕 New user - Quick Start will unlock after first walk")
                }
            } catch {
                print("❌ Migration check failed: \(error)")
            }
        }
    }
    
    // MARK: - Demo Helper
    
    private func resetTooltipsForDemo() {
        // 🎬 UNCOMMENT THESE 3 LINES FOR MONDAY'S PRESENTATION:
        UserDefaults.standard.removeObject(forKey: "hasSeenTooltip_quickStart")
        UserDefaults.standard.removeObject(forKey: "hasSeenTooltip_hapticPace")
        print("🎬 DEMO MODE: Tooltips reset for presentation")
    }

    var body: some Scene {
        WindowGroup {
            isoWalkMainView()
                .environment(sessionManager)
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                DailyReminderScheduler.refreshSchedule(context: sharedModelContainer.mainContext)
            }
        }
    }
}

