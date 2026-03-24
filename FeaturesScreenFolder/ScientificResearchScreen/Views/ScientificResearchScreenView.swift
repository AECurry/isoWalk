//
//  ScientificResearchScreenView.swift
//  isoWalk
//
//  Created by AnnElaine on 3/10/26.
//
//  PARENT VIEW — intentionally dumb.
//  Owns ScientificResearchViewModel. Renders short article always.
//  - FIXED: Image Area extracted to stay fixed while content below scrolls naturally.
//

import SwiftUI

struct ScientificResearchScreenView: View {

    @State private var viewModel = ScientificResearchViewModel()
    @Environment(\.dismiss) private var dismiss
    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }

    private let navBarHeight: CGFloat    = 115
    private let maxContentWidth: CGFloat = 340

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                
                // LAYER 1: Background
                themeBackground

                // LAYER 2: Floating Navigation
                IsoWalkBackButton(theme: theme, onBack: { dismiss() })
                    .zIndex(10)

                // LAYER 3: Main Content
                VStack(spacing: 0) {
                    
                    // MARK: - Shared Theme Image Area (Fixed)
                    isoWalkThemeImageArea(theme: theme, isAnimated: true)
                        .frame(maxWidth: .infinity)

                    // MARK: - Scrollable Content
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 0) {
                                HStack {
                                    Text("Scientific Research")
                                        .font(.custom("Inter-Bold", size: 34))
                                        .foregroundColor(isoWalkColors.deepSpaceBlue)
                                    Spacer()
                                }
                                .padding(.horizontal, max((geo.size.width - maxContentWidth) / 2, 20))
                                .padding(.top, 16) // Compensates for removed image padding
                                .padding(.bottom, 24)

                                // Short Version (always visible)
                                VStack(alignment: .leading, spacing: 20) {
                                    ForEach(viewModel.shortSections) { section in
                                        ResearchSectionView(section: section)
                                    }
                                }
                                .padding(.horizontal, max((geo.size.width - maxContentWidth) / 2, 20))

                                // Read Full Article Button
                                Button(action: {
                                    viewModel.toggleFullArticle()
                                    if viewModel.isFullArticleExpanded {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                            withAnimation {
                                                proxy.scrollTo("fullArticle", anchor: .top)
                                            }
                                        }
                                    }
                                }) {
                                    Text(viewModel.toggleButtonLabel)
                                        .font(.custom("Inter-SemiBold", size: 15))
                                        .foregroundColor(isoWalkColors.balticBlue)
                                        .padding(.vertical, 16)
                                }
                                .padding(.horizontal, max((geo.size.width - maxContentWidth) / 2, 20))
                                .padding(.top, 8)

                                // Full Article (expands inline)
                                if viewModel.isFullArticleExpanded {
                                    VStack(alignment: .leading, spacing: 20) {
                                        Divider().padding(.bottom, 4)
                                        ForEach(viewModel.longSections) { section in
                                            ResearchSectionView(section: section)
                                        }
                                    }
                                    .padding(.horizontal, max((geo.size.width - maxContentWidth) / 2, 20))
                                    .id("fullArticle")
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }

                                Spacer(minLength: 40)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .frame(width: geo.size.width, height: max(0, geo.size.height - navBarHeight))
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

// MARK: - Section View
private struct ResearchSectionView: View {

    let section: ResearchSection

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(section.heading)
                .font(.custom("Inter-Bold", size: 17))
                .foregroundColor(isoWalkColors.deepSpaceBlue)

            if let body = section.body {
                Text(body)
                    .font(.custom("Inter-Regular", size: 15))
                    .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
            }

            if !section.bullets.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(section.bullets, id: \.self) { bullet in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .font(.custom("Inter-Regular", size: 15))
                                .foregroundColor(isoWalkColors.balticBlue)
                            Text(bullet)
                                .font(.custom("Inter-Regular", size: 15))
                                .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.85))
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(4)
                        }
                    }
                }
            }

            if let footer = section.footer {
                Text(footer)
                    .font(.custom("Inter-SemiBold", size: 15))
                    .foregroundColor(isoWalkColors.deepSpaceBlue)
                    .padding(.top, 4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScientificResearchScreenView()
    }
}

