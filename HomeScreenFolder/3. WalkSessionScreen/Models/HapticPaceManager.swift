//
//  HapticPaceManager.swift
//  isoWalk
//
//  Created by AnnElaine on 4/2/26.
//
//  Generates highly precise haptic vibration patterns (metronome) using CoreHaptics.
//

import Foundation
import CoreHaptics

final class HapticPaceManager {
    private var engine: CHHapticEngine?
    
    init() {
        prepareHaptics()
    }
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("⚠️ Device does not support CoreHaptics.")
            return
        }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("❌ There was an error creating the haptic engine: \(error.localizedDescription)")
        }
    }
    
    func playPace(bpm: Int, durationInSeconds: Double = 4.0) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        // We put everything inside one single do-catch block
        do {
            // 1. Try to wake up the engine
            try engine?.start()
            
            // 2. Calculate timing
            let beatDuration = 60.0 / Double(bpm)
            let totalBeats = Int(durationInSeconds / beatDuration)
            var events = [CHHapticEvent]()
            
            // 3. Create the taps
            for i in 0..<totalBeats {
                let time = beatDuration * Double(i)
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                
                let event = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: time
                )
                events.append(event)
            }
            
            // 4. Play the pattern
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
            
            print("📳 Playing haptic pace at \(bpm) BPM for \(durationInSeconds) seconds.")
            
        } catch {
            // If ANY of the steps above fail, this catch block handles it
            print("❌ Haptic Error: \(error.localizedDescription)")
        }
    }
}

