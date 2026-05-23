//
//  PrivacyViewModel.swift
//  isoWalk
//
//  Created by AnnElaine on 3/10/26.
//
//
//  VIEWMODEL — all logic for PrivacyScreenView.
//  Owns the expanded/collapsed state for the full policy toggle.
//  View is dumb — reads from and calls into this only.
//

import SwiftUI
import Observation

@Observable
final class PrivacyViewModel {

    // MARK: - State
    var isFullPolicyExpanded: Bool = false

    // MARK: - Content
    var shortSections: [PrivacySection] { PrivacyContent.shortSections }
    var longSections: [PrivacySection]  { PrivacyContent.longSections  }

    var toggleButtonLabel: String {
        isFullPolicyExpanded ? "Hide Full Policy ▲" : "Read Full Policy ▼"
    }

    // MARK: - Intent
    func toggleFullPolicy() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isFullPolicyExpanded.toggle()
        }
    }
}

