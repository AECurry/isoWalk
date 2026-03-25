//
//  WalkSessionViewModel.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//
//  VIEWMODEL — all business logic for the walk session screen.
//  The View is dumb — it only reads from and calls into this ViewModel.
//

import SwiftUI
import Observation
import Combine
import QuartzCore
import SwiftData

@Observable
final class WalkSessionViewModel {
    
    // MARK: - State
    var timerState: TimerState = .stopped
    var remainingTime: TimeInterval = 0
    var formattedTime: String = "00:00"
    var progress: Double = 0
    var amplitudes: [Float] = Array(repeating: 0.1, count: 30)
    var isAudioPlaying = false
    var activeSession: WalkSessionOptions?
    
    // MARK: - Database Context
    var modelContext: ModelContext?
    
    // MARK: - Private
    private var timerCancellable: AnyCancellable?
    private var amplitudeLink: CADisplayLink?
    private var backgroundTime: Date?
    private var wasRunningBeforeAlert = false
    private var currentMusicMode: MusicMode = .noMusic
    
    // Sub-Managers
    private var musicManager = MusicSessionManager()
    private var intervalManager = WalkIntervalManager()
    
    // MARK: - Computed (derived from activeSession)
    private var totalDuration: TimeInterval {
        activeSession?.durationInSeconds ?? 0
    }
    
    deinit {
        stopTimer()
        stopAmplitudeLink()
        musicManager.stop()
        MusicPlayerService.shared.stopSilentHeartbeat()
    }
    
    // MARK: - Session Lifecycle
    
    func initializeSession(
        duration: DurationOptions,
        pace: PaceOptions,
        musicMode: MusicMode,
        musicSelection: MusicSelection
    ) {
        WalkSessionOptions.clearActive()
        activeSession = nil
        
        let session = WalkSessionOptions(
            duration: duration,
            music: musicMode,
            pace: pace,
            startTime: Date(),
            wasPaused: false
        )
        
        activeSession = session
        WalkSessionOptions.saveActive(session)
        
        remainingTime = session.durationInSeconds
        progress = 0
        timerState = .stopped
        isAudioPlaying = false
        currentMusicMode = musicMode
        
        // Configure Sub-Managers
        musicManager.configure(musicMode: musicMode, pace: pace, duration: duration)
        intervalManager.configure(duration: duration, pace: pace, musicMode: musicMode)
        
        updateFormattedTime()
        startAmplitudeLink()
        
        print("✅ Session initialized: \(duration.displayName), \(pace.displayName), \(musicMode.displayName)")
    }
    
    func playPause() {
        switch timerState {
        case .stopped:
            timerState = .running
            isAudioPlaying = currentMusicMode != .noMusic
            startTimer()
            musicManager.start(remainingTime: remainingTime)
            
            // Start silent heartbeat for No Music mode
            if currentMusicMode == .noMusic {
                MusicPlayerService.shared.startSilentHeartbeat()
            }
            
            // Announce start if at the very beginning
            if remainingTime == totalDuration {
                intervalManager.announceStart()
            }
            
        case .running:
            timerState = .paused
            isAudioPlaying = false
            stopTimer()
            musicManager.pause()
            if var session = activeSession {
                session.wasPaused = true
                activeSession = session
                WalkSessionOptions.saveActive(session)
            }
            
        case .paused:
            timerState = .running
            isAudioPlaying = currentMusicMode != .noMusic
            startTimer()
            musicManager.resume()
            
            // Restart silent heartbeat if resuming No Music mode
            if currentMusicMode == .noMusic {
                MusicPlayerService.shared.startSilentHeartbeat()
            }
        }
    }
    
    func stopSession() {
        stopTimer()
        stopAmplitudeLink()
        musicManager.stop()
        MusicPlayerService.shared.stopSilentHeartbeat()
        
        if let session = activeSession {
            remainingTime = session.durationInSeconds
            progress = 0
            updateFormattedTime()
        }
        
        timerState = .stopped
        isAudioPlaying = false
        wasRunningBeforeAlert = false
        WalkSessionOptions.clearActive()
        activeSession = nil
    }
    
    func pauseForAlert() {
        wasRunningBeforeAlert = timerState == .running
        if timerState == .running {
            stopTimer()
            musicManager.pause()
            isAudioPlaying = false
        }
    }
    
    func resumeAfterAlert() {
        if wasRunningBeforeAlert {
            startTimer()
            musicManager.resume()
            isAudioPlaying = currentMusicMode != .noMusic
            
            if currentMusicMode == .noMusic {
                MusicPlayerService.shared.startSilentHeartbeat()
            }
        }
        wasRunningBeforeAlert = false
    }
    
    func saveSessionState() {
        guard timerState != .stopped, var session = activeSession else { return }
        session.pausedAt = timerState == .paused ? remainingTime : nil
        WalkSessionOptions.saveActive(session)
        activeSession = session
    }
    
    // FIXED: Added background time tracking
    func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .background, .inactive:
            if timerState == .running {
                backgroundTime = Date()
                print("📱 App backgrounded at \(Date())")
            }
            
        case .active:
            if let bgTime = backgroundTime, timerState == .running {
                let elapsed = Date().timeIntervalSince(bgTime)
                print("📱 App resumed. Deducting \(elapsed)s background time")
                intervalManager.deductBackgroundTime(elapsed)
                backgroundTime = nil
            }
            
        @unknown default:
            break
        }
    }
    
    // MARK: - Private Timer
    
    private func startTimer() {
        stopTimer()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.timerTick() }
    }
    
    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    private func timerTick() {
        guard remainingTime > 0 else { completeSession(); return }
        remainingTime -= 1
        progress = 1 - (remainingTime / totalDuration)
        
        // Delegate to sub-managers
        intervalManager.tick()
        musicManager.checkIntervalChange(remainingTime: remainingTime)
        
        updateFormattedTime()
    }
    
    private func completeSession() {
        guard let session = activeSession else { return }
        
        // FIXED: Only announce completion for No Music and My Music modes
        // (isoWalkTracks has completion built into the final track)
        if currentMusicMode != .isoWalkTracks {
            MusicPlayerService.shared.playChimeAndVoiceCue(
                message: "Walk session complete. Great job!"
            )
        }
        
        if let context = modelContext {
            _ = WalkSessionOptions.completeSession(session, context: context)
            DailyReminderScheduler.refreshSchedule(context: context)
        } else {
            print("⚠️ Warning: modelContext was not set! Cannot save session.")
        }
        
        activeSession = nil
        timerState = .stopped
        remainingTime = 0
        progress = 1.0
        isAudioPlaying = false
        stopTimer()
        musicManager.stop()
        MusicPlayerService.shared.stopSilentHeartbeat()
        updateFormattedTime()
    }
    
    private func updateFormattedTime() {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        formattedTime = String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Amplitude Animation
    
    private func startAmplitudeLink() {
        stopAmplitudeLink()
        amplitudeLink = CADisplayLink(target: self, selector: #selector(updateAmplitudes))
        amplitudeLink?.add(to: .main, forMode: .common)
    }
    
    private func stopAmplitudeLink() {
        amplitudeLink?.invalidate()
        amplitudeLink = nil
    }
    
    @objc private func updateAmplitudes() {
        guard isAudioPlaying else {
            for i in 0..<amplitudes.count {
                amplitudes[i] = max(0.1, amplitudes[i] - 0.02)
            }
            return
        }
        for i in 0..<amplitudes.count {
            let change = Float.random(in: -0.08...0.08)
            amplitudes[i] = max(0.1, min(1.0, amplitudes[i] + change))
        }
    }
}

