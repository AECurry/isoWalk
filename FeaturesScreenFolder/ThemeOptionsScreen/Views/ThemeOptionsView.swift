//
//  ThemeOptionsView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//

import SwiftUI

struct ThemeOptionsView: View {
    
    @State private var viewModel = ThemeOptionsViewModel()
    @Environment(\.dismiss) private var dismiss
    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }
    
    private let navBarHeight: CGFloat = 115
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                
                // LAYER 1: Floating Navigation
                IsoWalkBackButton(theme: theme, onBack: { dismiss() })
                    .zIndex(10)
                
                // LAYER 2: Main Content
                VStack(spacing: 0) {
                    
                    // MARK: - Shared Theme Image Area (Fixed)
                    // Note: We use viewModel.selectedTheme here so the preview changes instantly when tapping the grid
                    isoWalkThemeImageArea(theme: viewModel.selectedTheme, isAnimated: true)
                        .frame(maxWidth: .infinity)
                    
                    // MARK: - Scrollable Content
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            
                            ThemeGridSection(
                                themes: viewModel.themes,
                                selectedThemeId: viewModel.selectedThemeId,
                                onSelect: { selectedTheme in
                                    viewModel.select(theme: selectedTheme)
                                }
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                            .padding(.top, 16) // Added to compensate for removed image padding
                            
                            Spacer(minLength: 24)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(width: geo.size.width, height: max(0, geo.size.height - navBarHeight))
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
        .background {
            themeBackground
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

