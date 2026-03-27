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
        setupAudioSession(withDucking: false) // ← Start WITHOUT ducking
        speechSynthesizer.delegate = self
        createSilentAudioFile()
    }
    
    // MARK: - Audio Session Setup
    
    // Takes a parameter to control ducking
    private func setupAudioSession(withDucking: Bool) {
        do {
            let session = AVAudioSession.sharedInstance()
            
            // CRITICAL: Only add .duckOthers when voice cue is playing
            var options: AVAudioSession.CategoryOptions = [.mixWithOthers]
            if withDucking {
                options.insert(.duckOthers)
            }
            
            try session.setCategory(
                .playback,
                mode: .default,
                options: options
            )
            try session.setActive(true)
            
            let duckStatus = withDucking ? "WITH ducking" : "WITHOUT ducking"
            print("✅ Audio session configured \(duckStatus)")
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
    
    // MARK: - Play Preview
    
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
        // FIXED: Enable ducking BEFORE speaking
        setupAudioSession(withDucking: true)
        
        // Manually lower isoWalk track volume (if playing)
        if let player = audioPlayer, isPlaying {
            player.setVolume(self.volume * 0.15, fadeDuration: 0.5)
        }
        
        // Play chime (TODO: Add actual chime sound)
        print("🔔 [Chime]")
        
        // Read user's voice preference
        let useFemaleVoice = UserDefaults.standard.bool(forKey: "useFemaleVoice")
        let utterance = AVSpeechUtterance(string: message)
        let preferredGender: AVSpeechSynthesisVoiceGender = useFemaleVoice ? .female : .male
        
        // Find best quality voice
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
        print("🗣️ Voice cue finished")
        
        // FIXED: Restore isoWalk track volume
        if let player = audioPlayer, isPlaying {
            player.setVolume(self.volume, fadeDuration: 1.0)
        }
        
        // CRITICAL: Disable ducking AFTER speaking
        // This lets Apple Music return to full volume
        setupAudioSession(withDucking: false)
        print("✅ Audio ducking disabled - external music restored")
    }
    
    // MARK: - Silent Heartbeat
        
        private func createSilentAudioFile() {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("isoWalk_silence.wav")
            
            // 1. If we already made the file successfully, just use it!
            if FileManager.default.fileExists(atPath: url.path) {
                silenceFileURL = url
                // Don't print anything here so we don't spam the console
                return
            }
            
            // 2. Use the "Standard" format which iOS heavily prefers (Float32)
            guard let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1) else { return }
            
            do {
                let audioFile = try AVAudioFile(forWriting: url, settings: format.settings)
                guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 44100) else { return }
                
                buffer.frameLength = buffer.frameCapacity
                
                // 3. EXPLICITLY fill the memory with silence (zeros) so CoreAudio doesn't panic
                if let channelData = buffer.floatChannelData {
                    for i in 0..<Int(buffer.frameLength) {
                        channelData[0][i] = 0.0
                    }
                }
                
                try audioFile.write(from: buffer)
                silenceFileURL = url
                print("✅ Properly formatted silent WAV file created")
            } catch {
                print("❌ Failed to create silent audio file: \(error)")
            }
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
            print("🤫 Silent heartbeat started (keeps app alive in background)")
        } catch {
            print("❌ Could not start silence player: \(error)")
        }
    }
    
    func stopSilentHeartbeat() {
        silencePlayer?.stop()
        silencePlayer = nil
        print("🤫 Silent heartbeat stopped")
    }
}

