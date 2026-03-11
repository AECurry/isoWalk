//
//  ScientificProofViewModel.swift
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
final class ScientificProofViewModel {

    // MARK: - State
    var isFullArticleExpanded: Bool = false

    // MARK: - Content
    var shortSections: [ProofSection] { ScientificProofContent.shortSections }
    var longSections: [ProofSection]  { ScientificProofContent.longSections  }

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
