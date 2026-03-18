//
//  MusicPlayerService.swift
//  isoWalk
//
//  Created by AnnElaine on 3/11/26.
//
//
//  Handles music playback during walk sessions.
//  Plays SUNO tracks from Audio folder or user's Apple Music/Spotify.
//

import AVFoundation
import Foundation

@Observable
final class MusicPlayerService {
    
    // MARK: - Singleton
    static let shared = MusicPlayerService()
    
    // MARK: - State
    private var audioPlayer: AVAudioPlayer?
    private var currentTrackId: String?
    var isPlaying: Bool = false
    var volume: Float = 0.8
    
    private init() {
        setupAudioSession()
    }
    
    // MARK: - Audio Session Setup
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            print("✅ Audio session activated successfully")
        } catch {
            print("❌ Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Play SUNO Track
    
    func playSunoTrack(trackId: String, duration: Int) {
        guard let track = SunoTrackLibrary.track(byId: trackId) else {
            print("❌ Track not found: \(trackId)")
            return
        }
        
        // Build filename with duration
        let filename = track.filename(forDuration: duration)
        
        // Debug output
        print("🎵 DEBUG: Looking for file: \(filename).wav")
        print("🎵 DEBUG: Track title: \(track.title)")
        
        // Try to load audio file - search entire bundle
        guard let url = Bundle.main.url(
            forResource: filename,
            withExtension: "wav"
        ) else {
            print("❌ Audio file not found: \(filename).wav")
            print("💡 Searching bundle for any .wav files...")
            
            // Debug: Print all .wav files in bundle
            if let allWavs = Bundle.main.urls(forResourcesWithExtension: "wav", subdirectory: nil) {
                print("📁 Found \(allWavs.count) .wav files in bundle:")
                allWavs.forEach { print("   - \($0.lastPathComponent)") }
            }
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = volume
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            currentTrackId = trackId
            isPlaying = true
            
            print("✅ Playing: \(track.title) (\(duration) min)")
            print("✅ Audio player started! Volume: \(audioPlayer?.volume ?? 0), isPlaying: \(audioPlayer?.isPlaying ?? false)")
        } catch {
            print("❌ Failed to play audio: \(error)")
        }
    }
    
    // MARK: - Play Preview (6-8 second clip)
    
    func playPreview(trackId: String, duration: Double = 7.0) {
        guard let track = SunoTrackLibrary.track(byId: trackId) else {
            print("❌ Track not found for preview: \(trackId)")
            return
        }
        
        // For previews, use 3min for Normal, 1min for Brisk
        let previewDuration = track.pace == .normal ? 3 : 1
        playSunoTrack(trackId: trackId, duration: previewDuration)
        
        // Stop after preview duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            if self?.currentTrackId == trackId {
                self?.stop()
            }
        }
    }
    
    // MARK: - Playback Controls
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    func resume() {
        audioPlayer?.play()
        isPlaying = true
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentTrackId = nil
        isPlaying = false
    }
    
    func setVolume(_ volume: Float) {
        self.volume = max(0.0, min(1.0, volume))
        audioPlayer?.volume = self.volume
    }
    
    // MARK: - Fade Out
    
    func fadeOut(duration: Double = 3.0) {
        guard audioPlayer != nil, isPlaying else { return }
        
        let steps = 30
        let stepDuration = duration / Double(steps)
        let volumeDecrement = volume / Float(steps)
        
        for step in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) { [weak self] in
                guard let self = self else { return }
                self.audioPlayer?.volume = max(0, self.volume - (volumeDecrement * Float(step + 1)))
                
                if step == steps - 1 {
                    self.stop()
                }
            }
        }
    }
    
    // MARK: - Chime & Voice Cue (TODO)
    
    func playChimeAndVoiceCue(message: String) {
        // TODO: Implement chime sound + voice cue
        print("🔔 Chime + Voice: \(message)")
    }
}

