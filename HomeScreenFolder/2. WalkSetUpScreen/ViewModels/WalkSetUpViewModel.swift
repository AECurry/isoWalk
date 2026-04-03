//
//  WalkSetUpViewModel.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  Updated 3/11/26: Now calculates duration cycle info dynamically based on selected pace.
//
//
//  RESPONSIBILITY: Pace and duration selection only.
//  Music is owned entirely by MusicViewModel (MusicFolder).
//  This VM holds a reference to MusicViewModel and reads
//  canStartWalk and summaryLabel from it.
//

import SwiftUI
import Observation

@Observable
final class WalkSetUpViewModel {

    var selectedPace:       PaceOptions     = .steady
    var selectedDuration:   DurationOptions = .recommended

    // 🌟 PERFECT FOR QUICK START: When this is initialized, it automatically
    // calls MusicSelection.load(), meaning the last used music mode is instantly ready!
    var musicViewModel: MusicViewModel = MusicViewModel()

    // Convenience passthroughs for WalkSetUpView
    var selectedMusicMode: MusicMode { musicViewModel.selectedMode }
    var musicSummary:      String    { musicViewModel.summaryLabel  }

    var isReadyToStart: Bool {
        musicViewModel.canStartWalk
    }
    
    // MARK: - Computed Properties for UI Display
    
    var currentCycleInfo: CycleInfo {
        selectedDuration.cycleInfo(for: selectedPace)
    }
    
    var durationDescription: String {
        selectedDuration.description(for: selectedPace)
    }
    
    var paceRatioDisplay: String {
        selectedPace.ratioDisplay
    }

    init() {
        // Automatically loads last duration and pace for the Quick Start
        loadLastPreferences()
    }

    func startWalkingSession() {
        // Save duration and pace for next time
        UserDefaults.standard.set(selectedDuration.rawValue, forKey: "lastDuration")
        UserDefaults.standard.set(selectedPace.rawValue,     forKey: "lastPace")
        
        // Save the music selection (Mode, Playlists, Tracks) for next time
        musicViewModel.selection.save()
        
        let info = currentCycleInfo
        print("Starting walk: \(selectedDuration.minutes) min · \(selectedPace.displayName)")
        print("Cycle breakdown: \(info.normalCount)N + \(info.briskCount)B = \(info.totalCycles) total cycles")
        print("Final Normal cooldown: \(info.finalNormalDuration) min (extension: +\(info.cooldownExtension) min)")
        print("Music: \(musicViewModel.summaryLabel)")
    }

    private func loadLastPreferences() {
        if let raw = UserDefaults.standard.string(forKey: "lastDuration"),
           let option = DurationOptions(rawValue: raw) {
            selectedDuration = option
        }
        if let raw = UserDefaults.standard.string(forKey: "lastPace"),
           let option = PaceOptions(rawValue: raw) {
            selectedPace = option
        }
        // MusicViewModel loads its own state from UserDefaults in its own init
    }
}

