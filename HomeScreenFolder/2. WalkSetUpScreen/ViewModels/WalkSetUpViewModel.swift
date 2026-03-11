//
//  WalkSetUpViewModel.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  LOCATION: WalkSetUpScreen/ViewModels/
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

    var selectedPace:     PaceOptions     = .steady
    var selectedDuration: DurationOptions = .recommended

    // Music owned by MusicFolder — this VM just holds the reference
    var musicViewModel: MusicViewModel = MusicViewModel()

    // Convenience passthroughs for WalkSetUpView
    var selectedMusicMode: MusicMode { musicViewModel.selectedMode }
    var musicSummary:      String    { musicViewModel.summaryLabel  }

    var isReadyToStart: Bool {
        musicViewModel.canStartWalk
    }

    init() {
        loadLastPreferences()
    }

    func startWalkingSession() {
        UserDefaults.standard.set(selectedDuration.rawValue, forKey: "lastDuration")
        UserDefaults.standard.set(selectedPace.rawValue,     forKey: "lastPace")
        musicViewModel.selection.save()
        print("Starting walk: \(selectedDuration.minutes) min · \(selectedPace.displayName) · \(musicViewModel.summaryLabel)")
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
