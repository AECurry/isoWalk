//
//  FeaturesHomeScreenView.swift
//  isoWalk
//
//  Created by AnnElaine on 3/9/26.
//
//
//  PARENT VIEW — intentionally dumb.
//  Owns FeaturesViewModel and the NavigationStack for all sub-screens.
//  Hero image + title are FIXED at top.
//  Cards scroll underneath the title.
//  HealthKitCard owns its own HealthKitViewModel internally.
//

import SwiftUI

struct FeaturesHomeScreenView: View {

    @State private var viewModel = FeaturesViewModel()
    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }

    private let navBarHeight: CGFloat = 115
    private let maxCardWidth: CGFloat = 340
    private let cardShadowRadius: CGFloat = 8
    private let cardShadowY: CGFloat = 4

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack(alignment: .top) {

                    themeBackground

                    VStack(spacing: 0) {

                        // MARK: - FIXED: Hero image
                        ThemeHeaderPreview(
                            theme: theme,
                            frameSize: 200
                        )
                        .padding(.top, 8)
                        .padding(.bottom, 8)

                        // MARK: - FIXED: Title
                        HStack {
                            Text("More Options")
                                .font(.custom("Inter-Bold", size: 34))
                                .foregroundColor(isoWalkColors.deepSpaceBlue)
                            Spacer()
                        }
                        .padding(.horizontal, max((geo.size.width - maxCardWidth) / 2, 20))
                        .padding(.bottom, 16)

                        // MARK: - SCROLLABLE: Cards scroll behind title
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 0) {

                                HealthKitCard()
                                    .shadow(color: .black.opacity(0.10), radius: cardShadowRadius, x: 0, y: cardShadowY)
                                    .padding(.bottom, 24)

                                FeaturesThemeRow(
                                    onTap: { viewModel.navigateToTheme = true }
                                )
                                .shadow(color: .black.opacity(0.10), radius: cardShadowRadius, x: 0, y: cardShadowY)
                                .padding(.bottom, 24)

                                FeaturesMenuGroup(
                                    onNameEmail:       { viewModel.navigateToNameEmail = true },
                                    onNotifications:   { viewModel.navigateToNotifications = true },
                                    onPrivacy:         { viewModel.navigateToPrivacy = true },
                                    onScientificProof: { viewModel.navigateToScientificProof = true },
                                    onSubmitFeedback:  { viewModel.navigateToSubmitFeedback = true }
                                )
                                .shadow(color: .black.opacity(0.10), radius: cardShadowRadius, x: 0, y: cardShadowY)
                                .padding(.bottom, 40)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 4)
                        }
                    }
                    .frame(width: geo.size.width, height: max(0, geo.size.height - navBarHeight))
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            }
            .navigationDestination(isPresented: $viewModel.navigateToTheme) {
                ThemeOptionsView()
            }
            .navigationDestination(isPresented: $viewModel.navigateToNameEmail) {
                NameEmailScreenView()
            }
            .navigationDestination(isPresented: $viewModel.navigateToNotifications) {
                NotificationsScreenView()
            }
            .navigationDestination(isPresented: $viewModel.navigateToPrivacy) {
                PrivacyScreenView()
            }
            .navigationDestination(isPresented: $viewModel.navigateToScientificProof) {
                ScientificProofScreenView()
            }
            .navigationDestination(isPresented: $viewModel.navigateToSubmitFeedback) {
                SubmitFeedbackScreenView()
            }
            .navigationBarHidden(true)
        }
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
    FeaturesHomeScreenView()
        .environment(SessionManager())
}

