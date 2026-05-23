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
    // ✅ Initial "Factory" defaults for a brand new install
    var selectedPace:     PaceOptions     = .brisk
    var selectedDuration: DurationOptions = .thirty
    var musicViewModel:   MusicViewModel  = MusicViewModel()
    
    var selectedMusicMode: MusicMode { musicViewModel.selectedMode }
    var musicSummary:      String    { musicViewModel.summaryLabel  }
    
    var isReadyToStart: Bool {
        musicViewModel.canStartWalk
    }
    
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
        loadLastPreferences()
    }
    
    func startWalkingSession() {
        // ✅ Consistent keys: "lastDuration" and "lastPace"
        UserDefaults.standard.set(selectedDuration.rawValue, forKey: "lastDuration")
        UserDefaults.standard.set(selectedPace.rawValue,     forKey: "lastPace")
        musicViewModel.selection.save()
    }
    
    func loadLastPreferences() {
        // 1. Load Duration
        if let rawDuration = UserDefaults.standard.string(forKey: "lastDuration"),
           let option = DurationOptions(rawValue: rawDuration) {
            selectedDuration = option
        } else {
            selectedDuration = .thirty // Fallback for new users
        }
        
        // 2. Load Pace
        if let rawPace = UserDefaults.standard.string(forKey: "lastPace"),
           let option = PaceOptions(rawValue: rawPace) {
            selectedPace = option
        } else {
            selectedPace = .brisk // Fallback for new users (3-3 Protocol)
        }
    }
}

