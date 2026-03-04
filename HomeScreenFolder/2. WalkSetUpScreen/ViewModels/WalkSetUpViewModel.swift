//
//  WalkSetUpViewModel.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  RESPONSIBILITY: All business logic for the WalkSetUp screen.
//  The View is dumb — it only reads from and calls into this ViewModel.
//

import SwiftUI
import Observation

@Observable
final class WalkSetUpViewModel {

    var selectedPace: PaceOptions = .steady
    var selectedDuration: DurationOptions = .recommended
    var selectedMusic: MusicOptions = .placeholder

    var isReadyToStart: Bool { true }

    init() {
        loadLastPreferences()
    }

    func startWalkingSession() {
        UserDefaults.standard.set(selectedDuration.rawValue, forKey: "lastDuration")
        UserDefaults.standard.set(selectedPace.rawValue, forKey: "lastPace")
        UserDefaults.standard.set(selectedMusic.rawValue, forKey: "lastMusic")
        print("Starting walk: \(selectedDuration.minutes) min, \(selectedPace.displayName)")
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
        if let raw = UserDefaults.standard.string(forKey: "lastMusic"),
           let option = MusicOptions(rawValue: raw) {
            selectedMusic = option
        }
    }
}

