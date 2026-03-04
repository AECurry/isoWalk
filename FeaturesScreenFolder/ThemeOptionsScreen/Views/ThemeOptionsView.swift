//
//  ThemeOptionsView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  PARENT VIEW — intentionally dumb.
//  Owns the ViewModel. Passes data down. Passes callbacks up.
//  Contains zero business logic — all logic lives in ThemeOptionsViewModel.

import SwiftUI

struct ThemeOptionsView: View {

    // MARK: - ViewModel (owned here, passed down as data)
    @State private var viewModel = ThemeOptionsViewModel()

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Add the frameSize: 220 here
                ThemeHeaderPreview(
                    theme: viewModel.selectedTheme,
                    frameSize: 220
                )
                .padding(.top, 24)

                ThemeGridSection(
                    themes: viewModel.themes,
                    selectedThemeId: viewModel.selectedThemeId,
                    onSelect: { theme in
                        viewModel.select(theme: theme)
                    }
                )
                .padding(.horizontal, 20)

                Spacer(minLength: 24)
            }
        }
        .background(isoWalkColors.adaptiveBackground)
        .navigationTitle("")
    }
}

#Preview {
    NavigationStack {
        ThemeOptionsView()
    }
}

