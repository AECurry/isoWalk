//
//  CompletedSession.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//
//  MODEL — pure data, no UI, no business logic.
//  Represents a finished walk session.
//  Used by: BadgeEarnedChecker, ProgressViewModel, TodayTimelineCard,
//           DailyReminderScheduler, BadgesViewModel, WalkSessionOptions
//
//  Persistence key: "completedSessions"
//

import Foundation
import SwiftData

@Model
final class CompletedSession {
    var id: UUID
    var duration: DurationOptions
    var music: MusicMode
    var pace: PaceOptions
    var startTime: Date
    var endTime: Date
    var totalDuration: TimeInterval
    var wasPaused: Bool

    init(
        id: UUID = UUID(),
        duration: DurationOptions,
        music: MusicMode,
        pace: PaceOptions,
        startTime: Date,
        endTime: Date,
        totalDuration: TimeInterval,
        wasPaused: Bool
    ) {
        self.id = id
        self.duration = duration
        self.music = music
        self.pace = pace
        self.startTime = startTime
        self.endTime = endTime
        self.totalDuration = totalDuration
        self.wasPaused = wasPaused
    }
}

