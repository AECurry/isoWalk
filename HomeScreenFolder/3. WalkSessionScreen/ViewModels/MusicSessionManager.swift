//
//  MusicSessionManager.swift
//  isoWalk
//
//  Created by AnnElaine on 3/17/26.
//
//
//  Handles all music playback logic during walk sessions.
//  Manages track sequencing, interval transitions, and playback state.
//

import Foundation
import Observation

@Observable
final class MusicSessionManager {
    
    // MARK: - State
    private(set) var isPlaying: Bool = false
    
    // MARK: - Private
    private var musicMode: MusicMode = .noMusic
    private var trackSequence: [TrackSequenceItem] = []
    private var currentIntervalIndex: Int = 0
    private var intervalStartTime: TimeInterval = 0
    
    // MARK: - Setup
    
    func configure(musicMode: MusicMode, pace: PaceOptions, duration: DurationOptions) {
        self.musicMode = musicMode
        
        if musicMode == .isoWalkTracks {
            loadTrackSequence(pace: pace, duration: duration)
        }
    }
    
    private func loadTrackSequence(pace: PaceOptions, duration: DurationOptions) {
        let sequence = TrackSequenceStorage.getOrCreate(pace: pace, duration: duration)
        trackSequence = sequence.playbackSequence
        currentIntervalIndex = 0
        print("🎵 Loaded track sequence: \(trackSequence.count) intervals")
        
        // Debug: Print full sequence
        for (index, item) in trackSequence.enumerated() {
            print("   \(index + 1). \(item.track.title) (\(item.paceLabel)) - \(item.durationMinutes) min")
        }
    }
    
    // MARK: - Playback Control
    
    func start(remainingTime: TimeInterval) {
        guard musicMode == .isoWalkTracks, !trackSequence.isEmpty else { return }
        intervalStartTime = remainingTime
        currentIntervalIndex = 0
        playCurrentInterval()
        isPlaying = true
    }
    
    func pause() {
        guard musicMode == .isoWalkTracks else { return }
        MusicPlayerService.shared.pause()
        isPlaying = false
    }
    
    func resume() {
        guard musicMode == .isoWalkTracks else { return }
        MusicPlayerService.shared.resume()
        isPlaying = true
    }
    
    func stop() {
        guard musicMode == .isoWalkTracks else { return }
        MusicPlayerService.shared.stop()
        currentIntervalIndex = 0
        isPlaying = false
    }
    
    // MARK: - Interval Management
    
    func checkIntervalChange(remainingTime: TimeInterval) {
        guard musicMode == .isoWalkTracks, !trackSequence.isEmpty else { return }
        guard currentIntervalIndex < trackSequence.count else { return }
        
        let currentItem = trackSequence[currentIntervalIndex]
        let intervalDuration = TimeInterval(currentItem.durationMinutes * 60)
        let elapsedInInterval = intervalStartTime - remainingTime
        
        // Debug log every 30 seconds
        let elapsedMinutes = Int(elapsedInInterval) / 60
        let elapsedSeconds = Int(elapsedInInterval) % 60
        if Int(elapsedInInterval) % 30 == 0 {
            print("⏱️ Interval \(currentIntervalIndex + 1): \(elapsedMinutes):\(String(format: "%02d", elapsedSeconds)) / \(currentItem.durationMinutes):00")
        }
        
        // Check if current interval is complete
        if elapsedInInterval >= intervalDuration {
            print("✅ Interval \(currentIntervalIndex + 1) complete!")
            currentIntervalIndex += 1
            
            if currentIntervalIndex < trackSequence.count {
                intervalStartTime = remainingTime
                playCurrentInterval()
                
                // FIXED: Add voice cue for interval transitions
                announceIntervalTransition()
            } else {
                print("🏁 All intervals complete!")
            }
        }
    }
    
    // MARK: - Private
    
    private func playCurrentInterval() {
        guard currentIntervalIndex < trackSequence.count else { return }
        
        let item = trackSequence[currentIntervalIndex]
        
        print("🎵 Playing interval \(item.intervalNumber)/\(trackSequence.count): \(item.track.title) (\(item.paceLabel)) - \(item.durationMinutes) min")
        
        MusicPlayerService.shared.playSunoTrack(
            trackId: item.track.id,
            duration: item.durationMinutes
        )
    }
    
    // FIXED: Voice cues for isoWalkTracks mode
    private func announceIntervalTransition() {
        guard currentIntervalIndex < trackSequence.count else { return }
        
        let nextItem = trackSequence[currentIntervalIndex]
        
        let message: String
        if nextItem.track.pace == .brisk {
            message = "Time to speed up. Switch to a brisk pace."
        } else if nextItem.isCooldown {
            message = "Final cooldown. Return to your normal pace."
        } else {
            message = "Time to slow down. Return to your normal pace."
        }
        
        // Play voice cue OVER the music
        MusicPlayerService.shared.playChimeAndVoiceCue(message: message)
    }
}

