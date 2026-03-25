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
import Observation

@Observable
final class MusicPlayerService: NSObject, AVSpeechSynthesizerDelegate {
    
    // MARK: - Singleton
    static let shared = MusicPlayerService()
    
    // MARK: - State
    private var audioPlayer: AVAudioPlayer?
    private var currentTrackId: String?
    var isPlaying: Bool = false
    var volume: Float = 0.8
    
    // Speech synthesis
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    // Silent heartbeat
    private var silencePlayer: AVAudioPlayer?
    private var silenceFileURL: URL?
    
    private override init() {
        super.init()
        setupAudioSession()
        speechSynthesizer.delegate = self
        createSilentAudioFile()
    }
    
    // MARK: - Audio Session Setup
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            // FIXED: Added background audio capability
            try session.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .duckOthers]
            )
            try session.setActive(true)
            print("✅ Audio session activated with background capability")
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
        
        let filename = track.filename(forDuration: duration)
        
        print("🎵 Looking for: \(filename).wav")
        
        guard let url = Bundle.main.url(
            forResource: filename,
            withExtension: "wav"
        ) else {
            print("❌ Audio file not found: \(filename).wav")
            
            // Debug: List all .wav files
            if let allWavs = Bundle.main.urls(forResourcesWithExtension: "wav", subdirectory: nil) {
                print("📁 Found \(allWavs.count) .wav files:")
                allWavs.prefix(5).forEach { print("   - \($0.lastPathComponent)") }
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
        
        let previewDuration = track.pace == .normal ? 3 : 1
        playSunoTrack(trackId: trackId, duration: previewDuration)
        
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
    
    // MARK: - Chime & Voice Cue
    
    func playChimeAndVoiceCue(message: String) {
        // Duck the music volume while speaking
        if let player = audioPlayer, isPlaying {
            player.setVolume(self.volume * 0.15, fadeDuration: 0.5)
        }
        
        // TODO: Play chime sound here
        print("🔔 [Chime]")
        
        // FIXED: Read user's voice preference
        let useFemaleVoice = UserDefaults.standard.bool(forKey: "useFemaleVoice")
        let utterance = AVSpeechUtterance(string: message)
        let preferredGender: AVSpeechSynthesisVoiceGender = useFemaleVoice ? .female : .male
        
        // Find best quality voice matching gender
        let availableVoices = AVSpeechSynthesisVoice.speechVoices().filter {
            $0.language.hasPrefix("en") && $0.gender == preferredGender
        }
        
        if let bestVoice = availableVoices.first(where: { $0.quality == .premium }) ??
                           availableVoices.first(where: { $0.quality == .enhanced }) ??
                           availableVoices.first {
            utterance.voice = bestVoice
            print("🗣️ Using \(bestVoice.name)")
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        
        print("🗣️ Voice Cue: \(message)")
        speechSynthesizer.speak(utterance)
    }
    
    // MARK: - Speech Synthesizer Delegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // Fade music volume back up
        if let player = audioPlayer, isPlaying {
            player.setVolume(self.volume, fadeDuration: 1.0)
        }
    }
    
    // MARK: - Silent Heartbeat (for No Music mode background running)
    
    // FIXED: Create silence file once and reuse
    private func createSilentAudioFile() {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("isoWalk_silence.wav")
        
        // Only create if doesn't exist
        if !FileManager.default.fileExists(atPath: url.path) {
            let audioData = Data(count: 44100 * 2) // 1 second of silence
            try? audioData.write(to: url)
        }
        
        silenceFileURL = url
    }
    
    func startSilentHeartbeat() {
        guard let url = silenceFileURL else { return }
        guard silencePlayer == nil || silencePlayer?.isPlaying == false else { return }
        
        do {
            silencePlayer = try AVAudioPlayer(contentsOf: url)
            silencePlayer?.numberOfLoops = -1
            silencePlayer?.volume = 0.01
            silencePlayer?.prepareToPlay()
            silencePlayer?.play()
            print("🤫 Silent heartbeat started")
        } catch {
            print("❌ Could not start silence player: \(error)")
        }
    }
    
    func stopSilentHeartbeat() {
        silencePlayer?.stop()
        silencePlayer = nil
    }
}

