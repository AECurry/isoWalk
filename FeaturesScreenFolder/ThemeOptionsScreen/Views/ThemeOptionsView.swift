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
                
                themeBackground
                
                // ScrollView ignores safe area so content can start from very top
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // MARK: - Theme Preview
                        isoWalkThemeImageArea(theme: viewModel.selectedTheme, isAnimated: true)
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
                
                // MARK: - Universal Shared Back Button
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

#Preview {
    NavigationStack {
        ThemeOptionsView()
    }
}

