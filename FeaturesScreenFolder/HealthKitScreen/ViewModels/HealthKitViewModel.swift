//
//  HealthKitViewModel.swift
//  isoWalk
//
//  Created by AnnElaine on 3/9/26.
//
//
//  VIEWMODEL — all business logic for the HealthKit toggle.
//  The View is dumb — it only reads from and calls into this ViewModel.
//  Bridges HealthKitManager (service) to HealthKitCard (UI).
//

import SwiftUI
import Observation

@Observable
final class HealthKitViewModel {

    // MARK: - State
    var isEnabled: Bool = false
    var showDeniedAlert: Bool = false
    var showUnavailableAlert: Bool = false

    // MARK: - Private
    private let manager = HealthKitManager.shared
    private let enabledKey = "isHealthKitEnabled"

    // MARK: - Init
    init() {
        // Restore saved state, but verify it's still actually authorized.
        // If the user revoked permission in Settings since last launch,
        // we snap the toggle back to off.
        let saved = UserDefaults.standard.bool(forKey: enabledKey)
        if saved && manager.isFullyAuthorized {
            isEnabled = true
        } else {
            isEnabled = false
            UserDefaults.standard.set(false, forKey: enabledKey)
        }
    }

    // MARK: - Intent

    // Called when the user taps the toggle.
    func toggleHealthKit() {
        guard manager.isHealthKitAvailable else {
            // Device does not support HealthKit (e.g. iPad without Health app)
            isEnabled = false
            showUnavailableAlert = true
            return
        }

        if isEnabled {
            // Turning OFF — just disable, no HealthKit call needed
            disable()
            return
        }

        // Turning ON — check if previously denied
        if manager.isDenied {
            // Apple won't show dialog again — send to Settings
            isEnabled = false
            showDeniedAlert = true
            return
        }

        // First time or undetermined — request permission
        manager.requestAuthorization { [weak self] success, error in
            DispatchQueue.main.async {
                guard let self else { return }
                if success && self.manager.isFullyAuthorized {
                    self.isEnabled = true
                    UserDefaults.standard.set(true, forKey: self.enabledKey)
                } else {
                    // User denied in the dialog
                    self.isEnabled = false
                    UserDefaults.standard.set(false, forKey: self.enabledKey)
                    self.showDeniedAlert = true
                }
            }
        }
    }

    // Called when user taps "Open Settings" in the denied alert
    func openSettings() {
        manager.openHealthSettings()
    }

    // MARK: - Private
    private func disable() {
        isEnabled = false
        UserDefaults.standard.set(false, forKey: enabledKey)
    }
}

