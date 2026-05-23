//
//  isoWalkApp.swift
//  isoWalk
//
//  Created by AnnElaine on 2/12/26.
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
        // 1. Increment launch count
        let currentCount = UserDefaults.standard.integer(forKey: "appLaunchCount")
        UserDefaults.standard.set(currentCount + 1, forKey: "appLaunchCount")
        print("🚀 App Launch Count: \(currentCount + 1)")
        
        // ✅ Safe: Only touches lightweight UserDefaults memory
        migratePaceAndDurationDefaults()
    }
    
    // MARK: - Migration Helper for Pace/Duration
    
    private func migratePaceAndDurationDefaults() {
        let needsMigration = !UserDefaults.standard.bool(forKey: "hasValidatedDefaults_v2")
        
        if needsMigration {
            print("🔧 Running defaults migration for the very first time...")
            
            UserDefaults.standard.set(PaceOptions.brisk.rawValue, forKey: "lastPace")
            UserDefaults.standard.set(DurationOptions.thirty.rawValue, forKey: "lastDuration")
            UserDefaults.standard.set(true, forKey: "hasValidatedDefaults_v2")
            
            print("✅ Initial factory defaults configured successfully:")
        } else {
            print("ℹ️ First-time setup already complete. Respecting saved user preferences.")
        }
    }
    
    // MARK: - Migration Helper for Quick Start
    
    // ✅ MainActor tag guarantees SwiftData operations execute safely on the main queue
    @MainActor
    private func migrateQuickStartFeature() {
        // Only run this check if the flag doesn't exist yet
        if UserDefaults.standard.object(forKey: "hasCompletedFirstWalk") == nil {
            let context = sharedModelContainer.mainContext
            let descriptor = FetchDescriptor<CompletedSession>()
            
            do {
                let sessions = try context.fetch(descriptor)
                if !sessions.isEmpty {
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
    
    var body: some Scene {
        WindowGroup {
            isoWalkMainView()
                .environment(sessionManager)
                // ✅ Moved out of initialization and into an asynchronous view lifecycle block
                .onAppear {
                    migrateQuickStartFeature()
                }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                DailyReminderScheduler.refreshSchedule(context: sharedModelContainer.mainContext)
            }
        }
    }
}

