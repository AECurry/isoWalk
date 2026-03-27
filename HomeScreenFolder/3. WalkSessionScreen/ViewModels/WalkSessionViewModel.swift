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
    private var currentMusicMode: MusicMode = .noMusic
    private var wasRunningBeforeAlert = false
    
    // Sub-Managers
    private var musicManager = MusicSessionManager()
    private var intervalManager = WalkIntervalManager()
    private var timerManager = WalkSessionTimerManager()
    
    // MARK: - Computed
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
        switch timerState {
        case .stopped:
            timerState = .running
            isAudioPlaying = currentMusicMode != .noMusic
            
            timerManager.startTimer { [weak self] in
                self?.onTimerTick()
            }
            
            musicManager.start(remainingTime: remainingTime)
            
            if currentMusicMode == .noMusic {
                MusicPlayerService.shared.startSilentHeartbeat()
            }
            
            if remainingTime == totalDuration {
                intervalManager.announceStart()
            }
            
        case .running:
            timerState = .paused
            isAudioPlaying = false
            timerManager.stopTimer()
            musicManager.pause()
            
            if var session = activeSession {
                session.wasPaused = true
                activeSession = session
                WalkSessionOptions.saveActive(session)
            }
            
        case .paused:
            timerState = .running
            isAudioPlaying = currentMusicMode != .noMusic
            
            timerManager.startTimer { [weak self] in
                self?.onTimerTick()
            }
            
            musicManager.resume()
            
            if currentMusicMode == .noMusic {
                MusicPlayerService.shared.startSilentHeartbeat()
            }
        }
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
    }
    
    // MARK: - Timer Tick Handler
    
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
        print("   Active session exists: YES")
        print("   Duration: \(session.duration.displayName)")
        print("   Pace: \(session.pace.displayName)")
        
        MusicPlayerService.shared.playChimeAndVoiceCue(
            message: "Walk session complete. Great job!"
        )
        
        if let context = modelContext {
            print("💾 Saving session to database...")
            print("   Duration: \(session.duration.displayName)")
            print("   Pace: \(session.pace.displayName)")
            print("   Music: \(session.music.displayName)")
            print("   Start: \(session.startTime)")
            print("   Was Paused: \(session.wasPaused)")
            
            let completed = WalkSessionOptions.completeSession(session, context: context)
            
            print("✅ Session saved with ID: \(completed.id)")
            
            let descriptor = FetchDescriptor<CompletedSession>()
            do {
                let all = try context.fetch(descriptor)
                print("📊 Total sessions in database after save: \(all.count)")
                
                for (index, s) in all.enumerated() {
                    print("   Session \(index + 1): \(s.duration.displayName), \(s.startTime)")
                }
            } catch {
                print("❌ Failed to fetch sessions after save: \(error)")
            }
            
            DailyReminderScheduler.refreshSchedule(context: context)
        } else {
            print("❌ CRITICAL: modelContext is NIL! Session will NOT be saved!")
            print("   This means WalkSessionView didn't set the modelContext property!")
        }
        
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

