//
//  MusicSessionManager.swift
//  isoWalk
//
//  Created by AnnElaine on 3/17/26.
//
//  LOCATION: WalkSessionScreen/ViewModels/
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
    }
    
    // MARK: - Playback Control
    
    func start(remainingTime: TimeInterval) {
        guard musicMode == .isoWalkTracks, !trackSequence.isEmpty else { return }
        intervalStartTime = remainingTime
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
        
        // Check if current interval is complete
        if elapsedInInterval >= intervalDuration {
            currentIntervalIndex += 1
            if currentIntervalIndex < trackSequence.count {
                intervalStartTime = remainingTime
                playCurrentInterval()
            }
        }
    }
    
    // MARK: - Private
    
    private func playCurrentInterval() {
        guard currentIntervalIndex < trackSequence.count else { return }
        
        let item = trackSequence[currentIntervalIndex]
        
        print("🎵 Playing interval \(item.intervalNumber): \(item.track.title) (\(item.durationMinutes) min)")
        
        MusicPlayerService.shared.playSunoTrack(
            trackId: item.track.id,
            duration: item.durationMinutes
        )
    }
}
