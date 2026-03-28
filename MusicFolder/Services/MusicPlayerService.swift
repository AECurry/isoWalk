//
//  MusicPlayerService.swift
//  isoWalk
//
//  Created by AnnElaine on 3/11/26.
//
//
//  Handles music playback during walk sessions.
//  Plays SUNO tracks from Audio folder or user's Apple Music/Spotify.
//  Also handles custom .mp3 voice cues (ducking music volume when speaking).
//

import AVFoundation
import Foundation
import Observation

@Observable
final class MusicPlayerService: NSObject, AVAudioPlayerDelegate {
    
    static let shared = MusicPlayerService()
    
    private var audioPlayer: AVAudioPlayer?
    private var currentTrackId: String?
    var isPlaying: Bool = false
    var volume: Float = 0.8
    
    private var voiceCuePlayer: AVAudioPlayer?
    private var silencePlayer: AVAudioPlayer?
    private var silenceFileURL: URL?
    
    private override init() {
        super.init()
        createSilentAudioFile()
        AudioSessionManager.shared.configureForBackgroundPlayback()
    }
    
    // MARK: - Play SUNO Track
    
    func playSunoTrack(trackId: String, duration: Int) {
        guard let track = SunoTrackLibrary.track(byId: trackId) else {
            print("❌ Track not found: \(trackId)")
            return
        }
        
        let filename = track.filename(forDuration: duration)
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: "wav") else {
            print("❌ Audio file not found: \(filename).wav")
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
        voiceCuePlayer?.stop()
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
    
    // MARK: - Voice Cues
    
    func playVoiceCue(filename: String) {
        AudioSessionManager.shared.enableDucking()
        
        if let player = audioPlayer, isPlaying {
            player.setVolume(self.volume * 0.15, fadeDuration: 0.5)
        }
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: "mp3") else {
            print("❌ Could not find \(filename).mp3 in the project!")
            restoreAfterVoiceCue()
            return
        }
        
        do {
            voiceCuePlayer = try AVAudioPlayer(contentsOf: url)
            voiceCuePlayer?.delegate = self
            voiceCuePlayer?.volume = 1.0
            voiceCuePlayer?.prepareToPlay()
            voiceCuePlayer?.play()
            print("🗣️ Playing custom voice cue: \(filename)")
        } catch {
            print("❌ Error playing voice cue: \(error)")
            restoreAfterVoiceCue()
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player == voiceCuePlayer {
            print("🗣️ Custom voice cue finished")
            restoreAfterVoiceCue()
        }
    }
    
    private func restoreAfterVoiceCue() {
        if let mainPlayer = audioPlayer, isPlaying {
            mainPlayer.setVolume(self.volume, fadeDuration: 1.0)
        }
        AudioSessionManager.shared.disableDucking()
        print("✅ Audio ducking disabled - external music restored")
    }
    
    // MARK: - Silent Heartbeat
    
    private func createSilentAudioFile() {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("isoWalk_silence.wav")
        
        if FileManager.default.fileExists(atPath: url.path) {
            silenceFileURL = url
            print("✅ Silent audio file already exists")
            return
        }
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1) else {
            print("❌ Failed to create audio format")
            return
        }
        
        do {
            let audioFile = try AVAudioFile(forWriting: url, settings: format.settings)
            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 44100) else {
                print("❌ Failed to create audio buffer")
                return
            }
            
            buffer.frameLength = buffer.frameCapacity
            
            if let channelData = buffer.floatChannelData {
                for i in 0..<Int(buffer.frameLength) {
                    channelData[0][i] = 0.0
                }
            }
            
            try audioFile.write(from: buffer)
            silenceFileURL = url
            print("✅ Silent WAV file created at: \(url.path)")
        } catch {
            print("❌ Failed to create silent audio file: \(error)")
        }
    }
    
    func startSilentHeartbeat() {
        guard let url = silenceFileURL else {
            print("❌ Silent audio file not ready - cannot start heartbeat")
            return
        }
        
        if let player = silencePlayer, player.isPlaying {
            print("🤫 Silent heartbeat already running")
            return
        }
        
        do {
            silencePlayer = try AVAudioPlayer(contentsOf: url)
            silencePlayer?.numberOfLoops = -1
            silencePlayer?.volume = 0.01
            silencePlayer?.prepareToPlay() // ← FIXED: Capital 'P'
            silencePlayer?.play()
            
            print("🤫 Silent heartbeat started - app will stay alive in background")
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
