//
//  WalkSessionViewModel.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//
//  VIEWMODEL — all business logic for the walk session screen.
//  The View is dumb — it only reads from and calls into this ViewModel.
//  Delegates timer operations to WalkSessionTimerManager.
//

import SwiftUI
import Observation
import Combine
import SwiftData

@Observable
final class WalkSessionViewModel {
    
    var timerState: TimerState = .stopped
    var remainingTime: TimeInterval = 0
    var formattedTime: String = "00:00"
    var progress: Double = 0
    var amplitudes: [Float] = Array(repeating: 0.1, count: 30)
    var isAudioPlaying = false
    var isBriskInterval: Bool = false
    var activeSession: WalkSessionOptions?
    var modelContext: ModelContext?
    
    var showCompletionPopup: Bool = false
    
    // ⚠️ Developer Test Mode Properties
    var isTestModeActive: Bool = false
    private let testDuration: TimeInterval = 90
    
    private var currentMusicMode: MusicMode = .noMusic
    private var wasRunningBeforeAlert = false
    
    private var musicManager = MusicSessionManager()
    private var intervalManager = WalkIntervalManager()
    private var timerManager = WalkSessionTimerManager()
    private var stateManager = TimerStateManager()
    
    private var voicePrefix: String {
        if UserDefaults.standard.object(forKey: "useFemaleVoice") == nil {
            return "Jacqueline"
        }
        return UserDefaults.standard.bool(forKey: "useFemaleVoice") ? "Jacqueline" : "William"
    }
    
    private var totalDuration: TimeInterval {
        return isTestModeActive ? testDuration : (activeSession?.durationInSeconds ?? 0)
    }
    
    deinit {
        timerManager.cleanup()
        musicManager.stop()
        MusicPlayerService.shared.stopSilentHeartbeat()
    }
    
    // MARK: - Session Lifecycle
    
    func initializeSession(
        duration: DurationOptions,
        pace: PaceOptions,
        musicMode: MusicMode,
        musicSelection: MusicSelection,
        isTesting: Bool // Injected from the View's toggle
    ) {
        WalkSessionOptions.clearActive()
        activeSession = nil
        showCompletionPopup = false
        
        self.isTestModeActive = isTesting
        
        let session = WalkSessionOptions(
            duration: duration,
            music: musicMode,
            pace: pace,
            startTime: Date(),
            wasPaused: false
        )
        
        activeSession = session
        WalkSessionOptions.saveActive(session)
        
        // Dynamically set time based on Test Mode
        remainingTime = isTestModeActive ? testDuration : session.durationInSeconds
        progress = 0
        timerState = .stopped
        isAudioPlaying = false
        currentMusicMode = musicMode
        
        musicManager.configure(musicMode: musicMode, pace: pace, duration: duration)
        intervalManager.configure(duration: duration, pace: pace, musicMode: musicMode)
        
        timerManager.updateFormattedTime(remainingTime: remainingTime) { [weak self] formatted in
            self?.formattedTime = formatted
        }
        timerManager.startAmplitudeAnimation { [weak self] newAmplitudes in
            self?.amplitudes = newAmplitudes
        }
        
        print("✅ Session initialized. Test Mode: \(isTesting)")
    }
    
    func playPause() {
        let result = stateManager.handlePlayPause(
            currentState: timerState,
            currentMusicMode: currentMusicMode,
            remainingTime: remainingTime,
            totalDuration: totalDuration,
            onStartTimer: { [weak self] in
                self?.timerManager.startTimer { self?.onTimerTick() }
            },
            onStopTimer: { [weak self] in
                self?.timerManager.stopTimer()
            },
            onStartMusic: { [weak self] in
                guard let self = self else { return }
                self.musicManager.start(remainingTime: self.remainingTime)
                
                if self.currentMusicMode == .noMusic {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        MusicPlayerService.shared.startSilentHeartbeat()
                    }
                }
            },
            onPauseMusic: { [weak self] in
                self?.musicManager.pause()
            },
            onResumeMusic: { [weak self] in
                guard let self = self else { return }
                self.musicManager.resume()
                
                if self.currentMusicMode == .noMusic {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        MusicPlayerService.shared.startSilentHeartbeat()
                    }
                }
            },
            onAnnounceStart: { [weak self] in
                guard let self = self else { return }
                if self.isTestModeActive {
                    // Force the explicit test starting cue
                    print("🗣️ Triggering test voice cue: StartingSession")
                    MusicPlayerService.shared.playVoiceCue(filename: "\(self.voicePrefix)-StartingSession")
                } else {
                    self.intervalManager.announceStart()
                }
            },
            onSessionPaused: { [weak self] in
                guard var session = self?.activeSession else { return }
                session.wasPaused = true
                self?.activeSession = session
                WalkSessionOptions.saveActive(session)
            }
        )
        
        timerState = result.newState
        isAudioPlaying = result.isAudioPlaying
    }
    
    func stopSession() {
        timerManager.cleanup()
        musicManager.stop()
        MusicPlayerService.shared.stopSilentHeartbeat()
        
        if let session = activeSession {
            remainingTime = isTestModeActive ? testDuration : session.durationInSeconds
            progress = 0
            timerManager.updateFormattedTime(remainingTime: remainingTime) { [weak self] formatted in
                self?.formattedTime = formatted
            }
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
            timerManager.stopTimer()
            musicManager.pause()
            isAudioPlaying = false
        }
    }
    
    func resumeAfterAlert() {
        if wasRunningBeforeAlert {
            timerManager.startTimer { [weak self] in
                self?.onTimerTick()
            }
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
    
    func handleScenePhase(_ phase: ScenePhase) {
        timerManager.handleScenePhase(phase, isRunning: timerState == .running) { [weak self] elapsed in
            self?.intervalManager.deductBackgroundTime(elapsed)
        }
        
        switch phase {
        case .background:
            if currentMusicMode == .noMusic {
                MusicPlayerService.shared.startSilentHeartbeat()
            }
        case .active, .inactive:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - Timer Tick
    
    private func onTimerTick() {
        guard remainingTime > 0 else {
            completeSession()
            return
        }
        
        remainingTime -= 1
        progress = 1 - (remainingTime / totalDuration)
        
        if isTestModeActive {
            // ⚠️ EXCLUSIVE TEST MODE LOGIC (Bypasses regular interval manager)
            let shouldBeBrisk = (remainingTime <= 60 && remainingTime > 30)
            
            if shouldBeBrisk != isBriskInterval {
                if shouldBeBrisk {
                    print("🗣️ Triggering test voice cue: BriskPace")
                    MusicPlayerService.shared.playVoiceCue(filename: "\(voicePrefix)-BriskPace")
                } else {
                    print("🗣️ Triggering test voice cue: NormalPace")
                    MusicPlayerService.shared.playVoiceCue(filename: "\(voicePrefix)-NormalPace")
                }
            }
            isBriskInterval = shouldBeBrisk
            
        } else {
            // 🟢 REAL SESSION LOGIC
            intervalManager.tick()
            isBriskInterval = intervalManager.isBriskInterval
        }
        
        musicManager.checkIntervalChange(remainingTime: remainingTime)
        
        timerManager.updateFormattedTime(remainingTime: remainingTime) { [weak self] formatted in
            self?.formattedTime = formatted
        }
        
        timerManager.updateAmplitudes(isPlaying: isAudioPlaying) { [weak self] newAmplitudes in
            self?.amplitudes = newAmplitudes
        }
    }
    
    // MARK: - Complete Session
    
    private func completeSession() {
        guard let session = activeSession else { return }
        
        print("🏁 completeSession() called")
        MusicPlayerService.shared.playVoiceCue(filename: "\(voicePrefix)-CompletedSession")
        
        if let context = modelContext {
            saveToDatabase(session: session, context: context)
        }
        
        // Unlocks the Quick Start feature after first use
        UserDefaults.standard.set(true, forKey: "hasCompletedFirstWalk")
        
        showCompletionPopup = true
        cleanupAfterCompletion()
    }
    
    private func saveToDatabase(session: WalkSessionOptions, context: ModelContext) {
        print("💾 Saving session to database...")
        
        let completed = WalkSessionOptions.completeSession(session, context: context)
        print("✅ Session saved with ID: \(completed.id)")
        
        DailyReminderScheduler.refreshSchedule(context: context)
    }
    
    private func cleanupAfterCompletion() {
        activeSession = nil
        timerState = .stopped
        remainingTime = 0
        progress = 1.0
        isAudioPlaying = false
        timerManager.cleanup()
        musicManager.stop()
        MusicPlayerService.shared.stopSilentHeartbeat()
        
        timerManager.updateFormattedTime(remainingTime: 0) { [weak self] formatted in
            self?.formattedTime = formatted
        }
    }
}

