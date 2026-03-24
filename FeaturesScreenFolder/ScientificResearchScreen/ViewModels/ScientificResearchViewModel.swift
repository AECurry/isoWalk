//
//  ScientificResearchViewModel.swift
//  isoWalk
//
//  Created by AnnElaine on 3/10/26.
//
//
//  VIEWMODEL — all logic for ScientificProofScreenView.
//  Owns the expanded/collapsed state for the full article toggle.
//  View is dumb — reads from and calls into this only.
//

import SwiftUI
import Observation

@Observable
final class ScientificResearchViewModel {

    // MARK: - State
    var isFullArticleExpanded: Bool = false

    // MARK: - Content
    var shortSections: [ProofSection] { ScientificResearchContent.shortSections }
    var longSections: [ProofSection]  { ScientificResearchContent.longSections  }

    var toggleButtonLabel: String {
        isFullArticleExpanded ? "Hide Full Article ▲" : "Read Full Article ▼"
    }

    // MARK: - Intent
    func toggleFullArticle() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isFullArticleExpanded.toggle()
        }
    }
}

