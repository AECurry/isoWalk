//
//  FeaturesViewModel.swift
//  isoWalk
//
//  Created by AnnElaine on 3/9/26.
//
//  VIEWMODEL — all business logic for FeaturesHomeScreenView.
//  The View is dumb — it only reads from and calls into this ViewModel.
//  HealthKit toggle logic lives in HealthKitViewModel (owned by HealthKitCard).
//  This ViewModel owns navigation destination flags and user data reads only.
//

import SwiftUI
import Observation

@Observable
final class FeaturesViewModel {

    // MARK: - Navigation Destinations
    var navigateToNameEmail       = false
    var navigateToNotifications   = false
    var navigateToPrivacy         = false
    var navigateToScientificProof = false
    var navigateToSubmitFeedback  = false
    var navigateToTheme           = false

    // MARK: - User Data (read for Submit Feedback pre-fill)
    var userName: String {
        let stored = UserDefaults.standard.string(forKey: "userName") ?? ""
        return stored.isEmpty ? "Friend" : stored
    }

    var userEmail: String {
        UserDefaults.standard.string(forKey: "userEmail") ?? ""
    }
}
