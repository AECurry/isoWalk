//
//  WalkSessionOptions.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  LOCATION: Shared/Models/
//
//  MODEL — represents an active or in-progress walk session.
//  CompletedSession has been moved to its own file: CompletedSession.swift
//

import Foundation

struct WalkSessionOptions: Identifiable, Codable {
    let id: UUID
    let duration: DurationOptions
    let music: MusicMode          // was MusicOptions
    let pace: PaceOptions
    let startTime: Date
    var endTime: Date?
    var isCompleted: Bool = false
    var pausedAt: TimeInterval?
    var wasPaused: Bool = false

    init(
        id: UUID = UUID(),
        duration: DurationOptions,
        music: MusicMode = .noMusic,  // was MusicOptions / .placeholder
        pace: PaceOptions,
        startTime: Date = Date(),
        endTime: Date? = nil,
        isCompleted: Bool = false,
        pausedAt: TimeInterval? = nil,
        wasPaused: Bool = false
    ) {
        self.id = id
        self.duration = duration
        self.music = music
        self.pace = pace
        self.startTime = startTime
        self.endTime = endTime
        self.isCompleted = isCompleted
        self.pausedAt = pausedAt
        self.wasPaused = wasPaused
    }

    // MARK: - Computed
    var durationInSeconds: TimeInterval {
        TimeInterval(duration.minutes * 60)
    }

    var elapsedTime: TimeInterval {
        if let pausedAt = pausedAt {
            return pausedAt
        } else if isCompleted {
            return durationInSeconds
        } else {
            return Date().timeIntervalSince(startTime)
        }
    }

    var remainingTime: TimeInterval {
        max(0, durationInSeconds - elapsedTime)
    }

    var progress: Double {
        min(1.0, elapsedTime / durationInSeconds)
    }

    // MARK: - Active Session Persistence
    static func saveActive(_ session: WalkSessionOptions) {
        if let encoded = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(encoded, forKey: "activeWalkSession")
        }
    }

    static func loadActive() -> WalkSessionOptions? {
        guard let data = UserDefaults.standard.data(forKey: "activeWalkSession")
        else { return nil }
        return try? JSONDecoder().decode(WalkSessionOptions.self, from: data)
    }

    static func clearActive() {
        UserDefaults.standard.removeObject(forKey: "activeWalkSession")
    }

    // MARK: - Complete Session
    @discardableResult
    static func completeSession(_ session: WalkSessionOptions) -> CompletedSession {
        let completedSession = CompletedSession(
            id: session.id,
            duration: session.duration,
            music: session.music,
            pace: session.pace,
            startTime: session.startTime,
            endTime: session.endTime ?? Date(),
            totalDuration: session.durationInSeconds,
            wasPaused: session.wasPaused
        )

        var allSessions = CompletedSession.loadAll()
        allSessions.append(completedSession)
        CompletedSession.saveAll(allSessions)

        if !session.wasPaused {
            UserDefaults.standard.set(true, forKey: "hasCompletedPauseFreeSession")
        }

        clearActive()
        return completedSession
    }
}

