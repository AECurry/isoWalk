//
//  AudioSessionManager.swift
//  isoWalk
//
//  Created by AnnElaine on 3/27/26.
//
//
//  Manages AVAudioSession configuration for background audio playback.
//  Handles ducking for voice cues and maintains background execution capability.
//

import AVFoundation
import Foundation

final class AudioSessionManager {
    
    static let shared = AudioSessionManager()
    
    private init() {
        configureForBackgroundPlayback()
    }
    
    // MARK: - Background Configuration
    
    func configureForBackgroundPlayback() {
        do {
            let session = AVAudioSession.sharedInstance()
            
            try session.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            
            try session.setActive(true)
            
            print("✅ Background audio session configured - app will stay alive in background")
        } catch {
            print("❌ Failed to configure background audio session: \(error)")
        }
    }
    
    // MARK: - Ducking Control
    
    func enableDucking() {
        updateSession(withDucking: true)
    }
    
    func disableDucking() {
        updateSession(withDucking: false)
    }
    
    private func updateSession(withDucking: Bool) {
        do {
            let session = AVAudioSession.sharedInstance()
            
            var options: AVAudioSession.CategoryOptions = [.mixWithOthers]
            if withDucking {
                options.insert(.duckOthers)
            }
            
            try session.setCategory(
                .playback,
                mode: .default,
                options: options
            )
            
            let status = withDucking ? "WITH ducking" : "WITHOUT ducking"
            print("✅ Audio session updated \(status)")
        } catch {
            print("❌ Failed to update audio session: \(error)")
        }
    }
}

