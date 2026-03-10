//
//  ThemeOptionsView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  PARENT VIEW — intentionally dumb.
//  Owns the ViewModel. Passes data down. Passes callbacks up.
//  Contains zero business logic — all logic lives in ThemeOptionsViewModel.
//

import SwiftUI

struct ThemeOptionsView: View {

    @State private var viewModel = ThemeOptionsViewModel()
    @Environment(\.dismiss) private var dismiss
    @AppStorage(IsoWalkThemes.selectedThemeKey) private var selectedThemeId: String = IsoWalkThemes.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkThemes.current(selectedId: selectedThemeId) }

    private let navBarHeight: CGFloat = 115

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {

                themeBackground

                // ScrollView ignores safe area so content can start from very top
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {

                        // Top padding clears the back button row
                        ThemeHeaderPreview(
                            theme: viewModel.selectedTheme,
                            frameSize: 200
                        )
                        .padding(.top, 56)
                        .frame(maxWidth: .infinity)

                        ThemeGridSection(
                            themes: viewModel.themes,
                            selectedThemeId: viewModel.selectedThemeId,
                            onSelect: { theme in
                                viewModel.select(theme: theme)
                            }
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)

                        Spacer(minLength: 24)
                    }
                    .frame(maxWidth: .infinity)
                }
                .ignoresSafeArea(edges: .top)
                .frame(width: geo.size.width, height: max(0, geo.size.height - navBarHeight))

                // MARK: - Custom Back Button
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(isoWalkColors.deepSpaceBlue)
                            .padding(12)
                    }
                    .padding(.leading, 56)
                    Spacer()
                }
                .padding(.top, -8)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
        .navigationBarHidden(true)
    }

    @ViewBuilder
    private var themeBackground: some View {
        if let bgName = theme.backgroundImageName {
            Image(bgName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        } else {
            theme.backgroundColor.ignoresSafeArea()
        }
    }
}

#Preview {
    NavigationStack {
        ThemeOptionsView()
    }
}

