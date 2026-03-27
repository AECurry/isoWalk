//
//  WalkSessionTimerManager.swift
//  isoWalk
//
//  Created by AnnElaine on 3/26/26.
//
//
//  TIMER SUB-MANAGER — handles all timer-related operations.
//

import Foundation
import Combine
import QuartzCore
import SwiftUI

final class WalkSessionTimerManager {
    
    // FIXED: Use a GCD Timer instead of a Combine publisher
    private var backgroundTimer: DispatchSourceTimer?
    
    private var amplitudeLink: CADisplayLink?
    private var backgroundTime: Date?
    private var currentAmplitudes: [Float] = Array(repeating: 0.1, count: 30)
    
    // MARK: - Timer Management
    
    func startTimer(onTick: @escaping () -> Void) {
        stopTimer()
        
        // CRITICAL: Create a dedicated background queue for the timer
        // This ensures iOS does not throttle it when the screen is backgrounded
        let queue = DispatchQueue(label: "com.isowalk.backgroundTimer", qos: .userInteractive)
        backgroundTimer = DispatchSource.makeTimerSource(queue: queue)
        
        // Fire immediately, then repeat every 1.0 seconds exactly
        backgroundTimer?.schedule(deadline: .now(), repeating: 1.0)
        
        backgroundTimer?.setEventHandler {
            // Push the actual tick update back to the Main thread so the UI can update safely
            DispatchQueue.main.async {
                onTick()
            }
        }
        
        backgroundTimer?.resume()
        print("⏱️ GCD Background Timer started (immune to UI throttling)")
    }
    
    func stopTimer() {
        backgroundTimer?.cancel()
        backgroundTimer = nil
        print("⏱️ GCD Background Timer stopped")
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
                print("📱 App resumed after \(Int(elapsed))s")
                
                // With the new GCD timer, drift should be near zero,
                // but this acts as a great safety net just in case of severe system lag.
                if elapsed > 2 {
                    print("⚠️ Detected background time drift of \(Int(elapsed))s")
                    onBackgroundTimeDeducted(elapsed)
                }
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
        // Display link callback
    }
    
    // MARK: - Cleanup
    
    func cleanup() {
        stopTimer()
        stopAmplitudeAnimation()
    }
}
