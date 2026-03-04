//
//  WalkSessionOptions.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//

import Foundation

struct WalkSessionOptions: Identifiable, Codable {
    let id: UUID
    let duration: DurationOptions
    let music: MusicOptions
    let startTime: Date
    var endTime: Date?
    var isCompleted: Bool = false
    var pausedAt: TimeInterval?
    
    init(
        id: UUID = UUID(),
        duration: DurationOptions,
        music: MusicOptions,
        startTime: Date = Date(),
        endTime: Date? = nil,
        isCompleted: Bool = false,
        pausedAt: TimeInterval? = nil
    ) {
        self.id = id
        self.duration = duration
        self.music = music
        self.startTime = startTime
        self.endTime = endTime
        self.isCompleted = isCompleted
        self.pausedAt = pausedAt
    }
    
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
    
    // MARK: - Persistence
    
    static func saveActive(_ session: WalkSessionOptions) {
        if let encoded = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(encoded, forKey: "activeWalkSession")
        }
    }
    
    static func loadActive() -> WalkSessionOptions? {
        guard let data = UserDefaults.standard.data(forKey: "activeWalkSession") else { return nil }
        return try? JSONDecoder().decode(WalkSessionOptions.self, from: data)
    }
    
    static func clearActive() {
        UserDefaults.standard.removeObject(forKey: "activeWalkSession")
    }
    
    static func completeSession(_ session: WalkSessionOptions) -> CompletedSession {
        var completed = session
        completed.endTime = Date()
        completed.isCompleted = true
        
        let completedSession = CompletedSession(
            id: completed.id,
            duration: completed.duration,
            music: completed.music,
            startTime: completed.startTime,
            endTime: completed.endTime ?? Date(),
            totalDuration: completed.durationInSeconds
        )
        
        var allSessions = CompletedSession.loadAll()
        allSessions.append(completedSession)
        CompletedSession.saveAll(allSessions)
        
        clearActive()
        return completedSession
    }
}

// This model handles saving finished walks to history
struct CompletedSession: Identifiable, Codable {
    let id: UUID
    let duration: DurationOptions
    let music: MusicOptions
    let startTime: Date
    let endTime: Date
    let totalDuration: TimeInterval
    
    static func loadAll() -> [CompletedSession] {
        guard let data = UserDefaults.standard.data(forKey: "completedSessions") else { return [] }
        return (try? JSONDecoder().decode([CompletedSession].self, from: data)) ?? []
    }
    
    static func saveAll(_ sessions: [CompletedSession]) {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: "completedSessions")
        }
    }
}

