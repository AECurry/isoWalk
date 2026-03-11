//
//  CompletedSession.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  LOCATION: Shared/Models/
//
//  MODEL — pure data, no UI, no business logic.
//  Represents a finished walk session.
//  Used by: BadgeEarnedChecker, ProgressViewModel, TodayTimelineCard,
//           DailyReminderScheduler, BadgesViewModel, WalkSessionOptions
//
//  Persistence key: "completedSessions"
//

import Foundation

struct CompletedSession: Identifiable, Codable {
    let id: UUID
    let duration: DurationOptions
    let music: MusicMode          // was MusicOptions
    let pace: PaceOptions
    let startTime: Date
    let endTime: Date
    let totalDuration: TimeInterval
    let wasPaused: Bool

    // MARK: - Persistence
    static func loadAll() -> [CompletedSession] {
        guard let data = UserDefaults.standard.data(forKey: "completedSessions")
        else { return [] }
        return (try? JSONDecoder().decode([CompletedSession].self, from: data)) ?? []
    }

    static func saveAll(_ sessions: [CompletedSession]) {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: "completedSessions")
        }
    }
}

