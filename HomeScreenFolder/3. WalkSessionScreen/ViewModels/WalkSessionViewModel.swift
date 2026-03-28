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
    var activeSession: WalkSessionOptions?
    var modelContext: ModelContext?
    
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
        activeSession?.durationInSeconds ?? 0
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
        
        musicManager.configure(musicMode: musicMode, pace: pace, duration: duration)
        intervalManager.configure(duration: duration, pace: pace, musicMode: musicMode)
        
        timerManager.updateFormattedTime(remainingTime: remainingTime) { [weak self] formatted in
            self?.formattedTime = formatted
        }
        timerManager.startAmplitudeAnimation { [weak self] newAmplitudes in
            self?.amplitudes = newAmplitudes
        }
        
        print("✅ Session initialized: \(duration.displayName), \(pace.displayName), \(musicMode.displayName)")
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
                
                // CRITICAL: Start silent heartbeat for No Music mode
                if self.currentMusicMode == .noMusic {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        MusicPlayerService.shared.startSilentHeartbeat()
                        print("🤫 Silent heartbeat started for .noMusic mode")
                    }
                }
            },
            onPauseMusic: { [weak self] in
                self?.musicManager.pause()
                // DON'T stop silent heartbeat on pause - keep app alive
            },
            onResumeMusic: { [weak self] in
                guard let self = self else { return }
                self.musicManager.resume()
                
                // CRITICAL: Restart silent heartbeat for No Music mode
                if self.currentMusicMode == .noMusic {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        MusicPlayerService.shared.startSilentHeartbeat()
                        print("🤫 Silent heartbeat restarted for .noMusic mode")
                    }
                }
            },
            onAnnounceStart: { [weak self] in
                self?.intervalManager.announceStart()
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
            remainingTime = session.durationInSeconds
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
                print("🤫 Restarted silent heartbeat after alert")
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
            print("📱 App entered background - timer should continue if running")
            // DEBUG: Check if silent heartbeat is actually playing
            if currentMusicMode == .noMusic {
                print("🤫 DEBUG: Checking silent heartbeat status...")
                MusicPlayerService.shared.startSilentHeartbeat() // Ensure it's running
            }
        case .active:
            print("📱 App entered foreground")
        case .inactive:
            print("📱 App became inactive")
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
        
        intervalManager.tick()
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
        guard let session = activeSession else {
            print("❌ completeSession called but activeSession is nil!")
            return
        }
        
        print("🏁 completeSession() called")
        
        MusicPlayerService.shared.playVoiceCue(filename: "\(voicePrefix)-CompletedSession")
        
        if let context = modelContext {
            saveToDatabase(session: session, context: context)
        } else {
            print("❌ CRITICAL: modelContext is NIL! Session will NOT be saved!")
        }
        
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
        
        print("🏁 completeSession() finished")
    }
}

