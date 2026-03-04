//
//  ThemeOptionsViewModel.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  RESPONSIBILITY: All business logic for the Theme Options screen.
//  The View is dumb — it only reads from and calls into this ViewModel.
//
//  ADDING A NEW THEME:
//  → Add ONE AnimatedImageConfig entry to AnimatedImageLibrary.availableImages
//  → Done. The grid picks it up automatically.
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
        let savedId = UserDefaults.standard.string(forKey: IsoWalkThemes.selectedThemeKey)
                      ?? IsoWalkThemes.defaultThemeId
        self.selectedThemeId = savedId
        self.themes = IsoWalkThemes.all
    }

    // MARK: - Computed
    var selectedTheme: IsoWalkTheme {
        IsoWalkThemes.current(selectedId: selectedThemeId)
    }

    // MARK: - Intent
    func select(theme: IsoWalkTheme) {
        guard theme.id != selectedThemeId else { return }
        selectedThemeId = theme.id
        persist()
        AnimatedImageLibrary.setCurrentImage(id: theme.id)
    }

    func isSelected(_ theme: IsoWalkTheme) -> Bool {
        theme.id == selectedThemeId
    }

    // MARK: - Private
    private func persist() {
        UserDefaults.standard.set(selectedThemeId, forKey: IsoWalkThemes.selectedThemeKey)
    }
}

