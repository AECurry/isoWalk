//
//  ScientificResearchViewModel.swift
//  isoWalk
//
//  Created by AnnElaine on 3/10/26.
//
//
//  VIEWMODEL — all logic for ScientificResearchScreenView.
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
    var shortSections: [ResearchSection] { ScientificResearchContent.shortSections }
    var longSections: [ResearchSection]  { ScientificResearchContent.longSections  }

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

