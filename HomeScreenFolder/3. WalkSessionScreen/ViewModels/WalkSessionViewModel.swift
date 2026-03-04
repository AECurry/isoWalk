//
//  WalkSessionViewModel.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  VIEWMODEL — all business logic for the walk session screen.
//  The View is dumb — it only reads from and calls into this ViewModel.
//


import SwiftUI
import Observation
import Combine
import QuartzCore

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

    // MARK: - Private
    private var totalDuration: TimeInterval = 0
    private var timerCancellable: AnyCancellable?
    private var amplitudeLink: CADisplayLink?
    private var backgroundTime: Date?

    // Tracks whether the timer was running before an alert paused it,
    // so resumeAfterAlert() knows whether to restart or stay paused.
    private var wasRunningBeforeAlert = false

    deinit {
        stopTimer()
        stopAmplitudeLink()
    }

    // MARK: - Session Lifecycle

    func initializeSession(duration: DurationOptions, pace: PaceOptions, music: MusicOptions) {
        WalkSessionOptions.clearActive()
        activeSession = nil

        let session = WalkSessionOptions(
            duration: duration,
            music: music,
            startTime: Date()
        )

        activeSession = session
        WalkSessionOptions.saveActive(session)

        totalDuration = session.durationInSeconds
        remainingTime = session.durationInSeconds
        progress = 0
        timerState = .stopped
        isAudioPlaying = false

        updateFormattedTime()
        startAmplitudeLink()
    }

    func playPause() {
        switch timerState {
        case .stopped:
            timerState = .running
            isAudioPlaying = true
            startTimer()
        case .running:
            timerState = .paused
            isAudioPlaying = false
            stopTimer()
        case .paused:
            timerState = .running
            isAudioPlaying = true
            startTimer()
        }
    }

    func stopSession() {
        stopTimer()
        stopAmplitudeLink()

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

    // Called the moment a confirmation alert appears (stop, back, tab tap).
    // Freezes the timer without changing the visible timerState so the UI
    // doesn't flicker. Records whether it was running so we can restore it.
    func pauseForAlert() {
        wasRunningBeforeAlert = timerState == .running
        if timerState == .running {
            stopTimer()
            isAudioPlaying = false
        }
    }

    // Called when the user taps Cancel on a confirmation alert.
    // Restores the timer exactly as it was before the alert appeared.
    func resumeAfterAlert() {
        if wasRunningBeforeAlert {
            startTimer()
            isAudioPlaying = true
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
        switch phase {
        case .background, .inactive:
            if timerState == .running {
                backgroundTime = Date()
                stopTimer()
                // timerState stays .running so we know to resume on return
            }
        case .active:
            if let bg = backgroundTime {
                backgroundTime = nil
                if timerState == .running {
                    let elapsed = Date().timeIntervalSince(bg)
                    remainingTime = max(0, remainingTime - elapsed)
                    if remainingTime <= 0 {
                        completeSession()
                    } else {
                        startTimer()
                    }
                }
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
        updateFormattedTime()
    }

    private func completeSession() {
        guard let session = activeSession else { return }
        _ = WalkSessionOptions.completeSession(session)
        activeSession = nil
        timerState = .stopped
        remainingTime = 0
        progress = 1.0
        isAudioPlaying = false
        stopTimer()
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
