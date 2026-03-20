//
//  ThemeOptionsViewModel.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  RESPONSIBILITY: All business logic for the Theme Options screen.
//  The View is dumb — it only reads from and calls into this ViewModel.
//


import SwiftUI
import Observation

@Observable
final class ThemeOptionsViewModel {

    // MARK: - State
    var selectedThemeId: String
    var themes: [IsoWalkTheme] = []

    // MARK: - Init
    init() {
        let savedId = UserDefaults.standard.string(forKey: IsoWalkTheme.selectedThemeKey)
                      ?? IsoWalkTheme.defaultThemeId
        self.selectedThemeId = savedId
        
        // FIX 1: Replaced .all with our new Library!
        self.themes = IsoWalkThemeLibrary.availableThemes
    }

    // MARK: - Computed
    var selectedTheme: IsoWalkTheme {
        IsoWalkTheme.current(selectedId: selectedThemeId)
    }

    // MARK: - Intent
    func select(theme: IsoWalkTheme) {
        guard theme.id != selectedThemeId else { return }
        selectedThemeId = theme.id
        
        // This handles the save!
        persist()
        
        // FIX 2: We removed the old AnimatedImageLibrary line here because persist() already does the work.
    }

    func isSelected(_ theme: IsoWalkTheme) -> Bool {
        theme.id == selectedThemeId
    }

    // MARK: - Private
    private func persist() {
        UserDefaults.standard.set(selectedThemeId, forKey: IsoWalkTheme.selectedThemeKey)
    }
}

