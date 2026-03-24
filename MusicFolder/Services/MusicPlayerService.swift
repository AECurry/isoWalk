//
//  MusicPlayerService.swift
//  isoWalk
//
//  Created by AnnElaine on 3/11/26.
//
//
//  Handles music playback during walk sessions.
//  Plays SUNO tracks from Audio folder or user's Apple Music/Spotify.
//  Also handles text-to-speech interval cues (ducking music volume when speaking).
//

import AVFoundation
import Foundation
import Observation // Needed for @Observable

@Observable
final class MusicPlayerService: NSObject, AVSpeechSynthesizerDelegate {
    
    // MARK: - Singleton
    static let shared = MusicPlayerService()
    
    // MARK: - State
    private var audioPlayer: AVAudioPlayer?
    private var currentTrackId: String?
    var isPlaying: Bool = false
    var volume: Float = 0.8
    
    // NEW: The engine that handles reading text out loud
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    private override init() {
        super.init() // Required because we now inherit from NSObject
        setupAudioSession()
        speechSynthesizer.delegate = self // Lets us know when the voice stops speaking
    }
    
    // MARK: - Audio Session Setup
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            // NEW: Added .duckOthers so Apple Music / Spotify volume lowers automatically when voice speaks!
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            try session.setActive(true)
            print("Audio session activated successfully")
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Play SUNO Track
    
    func playSunoTrack(trackId: String, duration: Int) {
        guard let track = SunoTrackLibrary.track(byId: trackId) else {
            print("Track not found: \(trackId)")
            return
        }
        
        // Build filename with duration
        let filename = track.filename(forDuration: duration)
        
        // Debug output
        print("DEBUG: Looking for file: \(filename).wav")
        print("DEBUG: Track title: \(track.title)")
        
        // Try to load audio file - search entire bundle
        guard let url = Bundle.main.url(
            forResource: filename,
            withExtension: "wav"
        ) else {
            print("Audio file not found: \(filename).wav")
            print("Searching bundle for any .wav files...")
            
            // Debug: Print all .wav files in bundle
            if let allWavs = Bundle.main.urls(forResourcesWithExtension: "wav", subdirectory: nil) {
                print("Found \(allWavs.count) .wav files in bundle:")
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
            
            print("Playing: \(track.title) (\(duration) min)")
            print("Audio player started! Volume: \(audioPlayer?.volume ?? 0), isPlaying: \(audioPlayer?.isPlaying ?? false)")
        } catch {
            print("Failed to play audio: \(error)")
        }
    }
    
    // MARK: - Play Preview (6-8 second clip)
    
    func playPreview(trackId: String, duration: Double = 7.0) {
        guard let track = SunoTrackLibrary.track(byId: trackId) else {
            print("Track not found for preview: \(trackId)")
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
        silencePlayer?.stop()
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
    
    // MARK: - Chime & Voice Cue (INTEGRATED)
    
    func playChimeAndVoiceCue(message: String) {
        // 1. Manually "duck" (lower) the Suno track volume while speaking
        if let player = audioPlayer, isPlaying {
            player.setVolume(self.volume * 0.15, fadeDuration: 0.5) // Lower to 15% volume
        }
        
        // 2. Play Chime (Optional TODO: hook up your actual ding.mp3 here)
        print("🎵 [Chime Sound Plays]")
        
        // 3. Read the user's Male/Female preference
        let useFemaleVoice = UserDefaults.standard.bool(forKey: "useFemaleVoice")
        let utterance = AVSpeechUtterance(string: message)
        let preferredGender: AVSpeechSynthesisVoiceGender = useFemaleVoice ? .female : .male
        
        // 4. Gather all English voices matching the gender
        let availableVoices = AVSpeechSynthesisVoice.speechVoices().filter {
            $0.language.hasPrefix("en") && $0.gender == preferredGender
        }
        
        // 5. Hunt for the highest quality voice available (Premium > Enhanced > Default)
        if let bestVoice = availableVoices.first(where: { $0.quality == .premium }) ??
                           availableVoices.first(where: { $0.quality == .enhanced }) ??
                           availableVoices.first {
            utterance.voice = bestVoice
            print("Selected Premium/Enhanced Voice: \(bestVoice.name)")
        } else {
            // Ultimate fallback
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        
        // 6. Speak!
        print("Voice Cue: \(message)")
        speechSynthesizer.speak(utterance)
    }
    
    // NEW: This triggers automatically when the robot voice finishes speaking
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // Fade the Suno track volume back up to normal over 1 second!
        if let player = audioPlayer, isPlaying {
            player.setVolume(self.volume, fadeDuration: 1.0)
        }
    }
    
    // The "Ghost" player that stays silent but keeps the app awake
    private var silencePlayer: AVAudioPlayer?

    func startSilentHeartbeat() {
        // Only start this if we aren't already playing music
        guard audioPlayer == nil || !isPlaying else { return }
        
        // We create a tiny 1-second silent file programmatically
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("silence.wav")
        
        // Create the "empty" audio file
        let audioData = Data(count: 44100 * 2) // 1 second of 16-bit silence
        try? audioData.write(to: url)
        
        do {
            silencePlayer = try AVAudioPlayer(contentsOf: url)
            silencePlayer?.numberOfLoops = -1 // Loop forever
            silencePlayer?.volume = 0.01 // Inaudible to the human ear
            silencePlayer?.prepareToPlay()
            silencePlayer?.play()
            print("Silent heartbeat started to maintain background session.")
        } catch {
            print("Could not start silence player: \(error)")
        }
    }
}

