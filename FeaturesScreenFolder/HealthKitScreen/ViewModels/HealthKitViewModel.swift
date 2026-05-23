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
        // Restore saved state
        let saved = UserDefaults.standard.bool(forKey: enabledKey)
     
        if saved && manager.isHealthKitAvailable {
            isEnabled = true
        } else {
            isEnabled = false
            UserDefaults.standard.set(false, forKey: enabledKey)
        }
    }

    // MARK: - Intent

    func toggleHealthKit() {
        guard manager.isHealthKitAvailable else {
            isEnabled = false
            showUnavailableAlert = true
            return
        }

        if isEnabled {
            disable()
            return
        }

        manager.requestAuthorization { [weak self] success, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if self.manager.isFullyAuthorized {
                    self.isEnabled = true
                    UserDefaults.standard.set(true, forKey: self.enabledKey)
                } else {
            
                    self.isEnabled = false
                    UserDefaults.standard.set(false, forKey: self.enabledKey)
                    self.showDeniedAlert = true
                }
            }
        }
    }

    func openSettings() {
        manager.openHealthSettings()
    }

    private func disable() {
        isEnabled = false
        UserDefaults.standard.set(false, forKey: enabledKey)
    }
}

