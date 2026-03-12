//
//  ScientificProofScreenView.swift
//  isoWalk
//
//  Created by AnnElaine on 3/10/26.
//
//  PARENT VIEW — intentionally dumb.
//  Owns ScientificProofViewModel. Renders short article always.
//  Full article expands inline when user taps "Read Full Article".
//  ScrollView starts from top of screen (ignoresSafeArea).
//  Back button floats over content in ZStack — same structure as ThemeOptionsView.
//

import SwiftUI

struct ScientificProofScreenView: View {

    @State private var viewModel = ScientificProofViewModel()
    @Environment(\.dismiss) private var dismiss
    @AppStorage(IsoWalkThemes.selectedThemeKey) private var selectedThemeId: String = IsoWalkThemes.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkThemes.current(selectedId: selectedThemeId) }

    private let navBarHeight: CGFloat    = 115
    private let maxContentWidth: CGFloat = 340

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                themeBackground

                // MARK: - Scrollable Content (starts from very top)
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {

                            ThemeHeaderPreview(theme: theme, frameSize: 200)
                                .padding(.top, 56)
                                .padding(.bottom, 16)
                                .frame(maxWidth: .infinity)

                            HStack {
                                Text("Scientific Proof")
                                    .font(.custom("Inter-Bold", size: 34))
                                    .foregroundColor(isoWalkColors.deepSpaceBlue)
                                Spacer()
                            }
                            .padding(.horizontal, max((geo.size.width - maxContentWidth) / 2, 20))
                            .padding(.bottom, 24)

                            // Short Version (always visible)
                            VStack(alignment: .leading, spacing: 20) {
                                ForEach(viewModel.shortSections) { section in
                                    ProofSectionView(section: section)
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
                                        ProofSectionView(section: section)
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
                    .ignoresSafeArea(edges: .top)
                    .frame(width: geo.size.width, height: max(0, geo.size.height - navBarHeight))
                }

                // MARK: - Back Button (floats over scroll content)
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

// MARK: - Section View
private struct ProofSectionView: View {

    let section: ProofSection

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
        ScientificProofScreenView()
    }
}

