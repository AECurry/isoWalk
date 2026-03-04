//
//  ThemeGridSection.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONENT — dumb child.
//  Lays out ThemeCardViews in a 2-column grid.
//  Receives all data and callbacks — owns nothing.
//

import SwiftUI

struct ThemeGridSection: View {

    // MARK: - Input
    let themes: [IsoWalkTheme]
    let selectedThemeId: String
    let onSelect: (IsoWalkTheme) -> Void

    // MARK: - Layout
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader
            grid
        }
    }

    // MARK: - Subviews

    private var sectionHeader: some View {
        Text("Theme Options")
            .font(.custom("Inter-Bold", size: 28))
            .foregroundStyle(isoWalkColors.adaptiveText)
            .padding(.horizontal, 4)
    }

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(themes) { theme in
                ThemeCardView(
                    theme: theme,
                    isSelected: theme.id == selectedThemeId,
                    onSelect: { onSelect(theme) }
                )
            }
        }
    }
}

#Preview {
    ThemeGridSection(
        themes: IsoWalkThemes.all,
        selectedThemeId: "koi",
        onSelect: { _ in }
    )
    .padding()
}

