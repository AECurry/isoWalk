//
//  WalkSessionTimerManager.swift
//  isoWalk
//
//  Created by AnnElaine on 3/26/26.
//
//  TIMER SUB-MANAGER — handles all timer-related operations.
//  Separated from WalkSessionViewModel to maintain single responsibility.
//  Manages: timer ticking, background time tracking, amplitude animation, time formatting.
//

import Foundation
import Combine
import QuartzCore
import SwiftUI

final class WalkSessionTimerManager {
    
    // MARK: - Private State
    private var timerCancellable: AnyCancellable?
    private var amplitudeLink: CADisplayLink?
    private var backgroundTime: Date?
    private var currentAmplitudes: [Float] = Array(repeating: 0.1, count: 30)
    
    // MARK: - Timer Management
    
    func startTimer(onTick: @escaping () -> Void) {
        stopTimer()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in onTick() }
    }
    
    func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    // MARK: - Background Time Tracking
    
    func handleScenePhase(_ phase: ScenePhase, isRunning: Bool, onBackgroundTimeDeducted: @escaping (TimeInterval) -> Void) {
        switch phase {
        case .background, .inactive:
            if isRunning {
                backgroundTime = Date()
                print("📱 App backgrounded at \(Date())")
            }
            
        case .active:
            if let bgTime = backgroundTime, isRunning {
                let elapsed = Date().timeIntervalSince(bgTime)
                print("📱 App resumed. Deducting \(elapsed)s background time")
                onBackgroundTimeDeducted(elapsed)
                backgroundTime = nil
            }
            
        @unknown default:
            break
        }
    }
    
    // MARK: - Time Formatting
    
    func updateFormattedTime(remainingTime: TimeInterval, completion: @escaping (String) -> Void) {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        let formatted = String(format: "%02d:%02d", minutes, seconds)
        completion(formatted)
    }
    
    // MARK: - Amplitude Animation
    
    func startAmplitudeAnimation(onUpdate: @escaping ([Float]) -> Void) {
        stopAmplitudeAnimation()
        amplitudeLink = CADisplayLink(target: self, selector: #selector(animateAmplitudes))
        amplitudeLink?.add(to: .main, forMode: .common)
    }
    
    func stopAmplitudeAnimation() {
        amplitudeLink?.invalidate()
        amplitudeLink = nil
    }
    
    func updateAmplitudes(isPlaying: Bool, completion: @escaping ([Float]) -> Void) {
        if isPlaying {
            for i in 0..<currentAmplitudes.count {
                let change = Float.random(in: -0.08...0.08)
                currentAmplitudes[i] = max(0.1, min(1.0, currentAmplitudes[i] + change))
            }
        } else {
            for i in 0..<currentAmplitudes.count {
                currentAmplitudes[i] = max(0.1, currentAmplitudes[i] - 0.02)
            }
        }
        completion(currentAmplitudes)
    }
    
    @objc private func animateAmplitudes() {
        // This runs on every display frame but we don't update here
        // The actual update happens in updateAmplitudes() called from timer tick
    }
    
    // MARK: - Cleanup
    
    func cleanup() {
        stopTimer()
        stopAmplitudeAnimation()
    }
}

