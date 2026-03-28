//
//  TimerStateManager.swift
//  isoWalk
//
//  Created by AnnElaine on 3/27/26.
//
//
//  Handles timer state transitions for walk sessions.
//  Extracted from WalkSessionViewModel to keep it under 300 lines.
//

import Foundation

final class TimerStateManager {
    
    func handlePlayPause(
        currentState: TimerState,
        currentMusicMode: MusicMode,
        remainingTime: TimeInterval,
        totalDuration: TimeInterval,
        onStartTimer: @escaping () -> Void,
        onStopTimer: @escaping () -> Void,
        onStartMusic: @escaping () -> Void,
        onPauseMusic: @escaping () -> Void,
        onResumeMusic: @escaping () -> Void,
        onAnnounceStart: @escaping () -> Void,
        onSessionPaused: @escaping () -> Void
    ) -> (newState: TimerState, isAudioPlaying: Bool) {
        
        switch currentState {
        case .stopped:
            onStartTimer()
            onStartMusic() // This will handle silent heartbeat in the callback
            
            if remainingTime == totalDuration {
                onAnnounceStart()
            }
            
            return (.running, currentMusicMode != .noMusic)
            
        case .running:
            onStopTimer()
            onPauseMusic()
            onSessionPaused()
            
            return (.paused, false)
            
        case .paused:
            onStartTimer()
            onResumeMusic() // This will handle silent heartbeat in the callback
            
            return (.running, currentMusicMode != .noMusic)
        }
    }
}

