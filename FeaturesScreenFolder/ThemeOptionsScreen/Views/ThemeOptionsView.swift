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
            // 1. ZStack top alignment anchors everything to the top safe area
            ZStack(alignment: .top) {
                
                themeBackground
                
                // 2. Scrollable Layer: Respects safe area so the image starts at the exact same Y-axis
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // MARK: - Theme Preview
                        isoWalkThemeImageArea(theme: viewModel.selectedTheme, isAnimated: true)
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
                .frame(width: geo.size.width, height: max(0, geo.size.height - navBarHeight))
                
                // 3. Navigation Layer: Floats independently
                IsoWalkBackButton(theme: theme) {
                    dismiss()
                }
                
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

