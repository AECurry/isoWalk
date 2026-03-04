//
//  SessionManager.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//

import SwiftUI
import Observation

@Observable
class SessionManager {
    // This holds the current walk data. If it is nil, no walk is happening.
    var activeSession: WalkSessionOptions?
    
    init() {
        self.activeSession = WalkSessionOptions.loadActive()
    }
    
    // MARK: - Computed Properties
    
    // FIX: This is the missing piece the View was looking for!
    // It calculates "00:00" based on how long the walk has been running.
    var formattedDuration: String {
        guard let session = activeSession else { return "00:00" }
        
        let elapsed = session.elapsedTime
        let totalSeconds = Int(elapsed)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Actions
    
    func startSession(duration: DurationOptions, music: MusicOptions) {
        print("Starting session: \(duration.minutes) min, Music: \(music.displayName)")
        
        let newSession = WalkSessionOptions(
            duration: duration,
            music: music,
            startTime: Date()
        )
        
        self.activeSession = newSession
        WalkSessionOptions.saveActive(newSession)
    }
    
    func stopSession() {
        print("Stopping session")
        
        if let session = activeSession {
            _ = WalkSessionOptions.completeSession(session)
        }
        
        self.activeSession = nil
        WalkSessionOptions.clearActive()
    }
}

