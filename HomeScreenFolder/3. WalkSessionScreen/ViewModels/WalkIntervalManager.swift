//
//  WalkIntervalManager.swift
//  isoWalk
//
//  Created by AnnElaine on 3/24/26.
//
//
//  Manages the sub-intervals (normal/brisk pacing) during a walk.
//  Triggers custom .mp3 voice cues when it's time to change pace.
//

import Foundation

final class WalkIntervalManager {
    
    // MARK: - State
    private var intervals: [WalkInterval] = []
    private var currentIntervalIndex: Int = 0
    private var timeRemaining: TimeInterval = 0
    private var currentMusicMode: MusicMode = .noMusic
    
    // 👇 NEW: Tells the ViewModel if the current active interval is brisk
    var isBriskInterval: Bool {
        guard currentIntervalIndex < intervals.count else { return false }
        return intervals[currentIntervalIndex].pace == .brisk
    }
    
    // Helper to automatically pick the correct custom voice based on user preference
    private var voicePrefix: String {
        // If the user hasn't made a choice yet, default to Jacqueline
        if UserDefaults.standard.object(forKey: "useFemaleVoice") == nil {
            return "Jacqueline"
        }
        // Otherwise, use their saved preference
        return UserDefaults.standard.bool(forKey: "useFemaleVoice") ? "Jacqueline" : "William"
    }
    
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
        if currentMusicMode != .isoWalkTracks {
            // Add a tiny delay so music settles first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                
                // Plays either Jacqueline-StartingSession.mp3 or William-StartingSession.mp3
                MusicPlayerService.shared.playVoiceCue(filename: "\(self.voicePrefix)-StartingSession")
            }
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
            // Determine which custom audio file to play based on the new pace
            let filename = nextInterval.pace == .brisk
                ? "\(voicePrefix)-BriskPace"
                : "\(voicePrefix)-NormalPace"
                
            MusicPlayerService.shared.playVoiceCue(filename: filename)
        }
    }
}

