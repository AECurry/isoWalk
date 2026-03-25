//
//  WalkIntervalManager.swift
//  isoWalk
//
//  Created by AnnElaine on 3/24/26.
//
//
//  Manages the sub-intervals (normal/brisk pacing) during a walk.
//  Triggers voice and chime cues when it's time to change pace.
//

import Foundation

final class WalkIntervalManager {
    
    // MARK: - State
    private var intervals: [WalkInterval] = []
    private var currentIntervalIndex: Int = 0
    private var timeRemaining: TimeInterval = 0
    private var currentMusicMode: MusicMode = .noMusic
    
    // MARK: - Setup
    func configure(duration: DurationOptions, pace: PaceOptions, musicMode: MusicMode) {
        let cycleInfo = duration.cycleInfo(for: pace)
        self.intervals = cycleInfo.intervalSequence
        self.currentIntervalIndex = 0
        self.currentMusicMode = musicMode
        
        if let first = intervals.first {
            self.timeRemaining = TimeInterval(first.duration * 60)
        }
        
        print("🏃 Interval manager configured: \(intervals.count) intervals, mode: \(musicMode.displayName)")
    }
    
    // MARK: - Actions
    func announceStart() {
        // Only announce for No Music and My Music modes
        // isoWalkTracks has its own announcement timing
        if currentMusicMode != .isoWalkTracks {
            MusicPlayerService.shared.playChimeAndVoiceCue(
                message: "Starting your isoWalk session. Begin at a normal pace."
            )
        }
    }
    
    func tick() {
        guard timeRemaining > 0 else { return }
        timeRemaining -= 1
        
        if timeRemaining <= 0 {
            transitionToNextInterval()
        }
    }
    
    func deductBackgroundTime(_ elapsed: TimeInterval) {
        timeRemaining = max(0, timeRemaining - elapsed)
        if timeRemaining <= 0 {
            transitionToNextInterval()
        }
    }
    
    // MARK: - Private
    private func transitionToNextInterval() {
        currentIntervalIndex += 1
        
        guard currentIntervalIndex < intervals.count else { return }
        
        let nextInterval = intervals[currentIntervalIndex]
        timeRemaining = TimeInterval(nextInterval.duration * 60)
        
        // Only announce for No Music and My Music modes
        if currentMusicMode != .isoWalkTracks {
            let message = nextInterval.pace == .brisk
                ? "Time to speed up. Switch to a brisk pace."
                : "Time to slow down. Return to your normal pace."
                
            MusicPlayerService.shared.playChimeAndVoiceCue(message: message)
        }
    }
}

