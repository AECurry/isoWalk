//
//  BadgesScreenView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  PARENT VIEW — intentionally dumb.
//  Owns BadgesViewModel. Passes data down to child components.
//  Presented as fullScreenCover from isoWalkMainView.
//  Back button calls onDismiss.
//  Uses GeometryReader height cap so content never goes behind BottomNavBar.
//  BadgeDetailSheet shown as centered overlay — not a sheet.
//

import SwiftUI

struct BadgesScreenView: View {

    let onDismiss: () -> Void

    @State private var viewModel = BadgesViewModel()
    @AppStorage(IsoWalkThemes.selectedThemeKey) private var selectedThemeId: String = IsoWalkThemes.defaultThemeId
    @State private var selectedTab: Int = 1

    private let navBarHeight: CGFloat = 115

    private let columns = [
        GridItem(.flexible(), spacing: 24),
        GridItem(.flexible(), spacing: 24)
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                themeBackground

                // Content hard-capped above BottomNavBar
                VStack(spacing: 0) {

                    // MARK: - Back Button Row
                    HStack {
                        Button(action: onDismiss) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(isoWalkColors.deepSpaceBlue)
                                .padding(12)
                        }
                        .padding(.leading, 32)
                        Spacer()
                    }
                    .padding(.top, -8)

                    // MARK: - Scrollable Content
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 24) {

                            BadgeFeaturedView(
                                mostRecentBadge: viewModel.mostRecentBadge,
                                earnedCount: viewModel.earnedCount,
                                themeId: selectedThemeId,
                                showReveal: viewModel.showRevealAnimation,
                                newlyUnlockedBadge: viewModel.newlyUnlockedBadge,
                                onRevealComplete: { viewModel.didShowReveal() }
                            )

                            LazyVGrid(columns: columns, spacing: 32) {
                                ForEach(viewModel.badges) { badge in
                                    BadgeGridCell(
                                        badge: badge,
                                        themeId: selectedThemeId,
                                        onTap: { viewModel.didTapBadge(badge) }
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 16)
                        }
                    }
                }
                .frame(width: geo.size.width, height: max(0, geo.size.height - navBarHeight))

                // MARK: - Centered Badge Detail Popup
                if viewModel.showDetailSheet, let badge = viewModel.selectedBadge {
                    BadgeDetailSheet(
                        badge: badge,
                        themeId: selectedThemeId,
                        onDismiss: { viewModel.showDetailSheet = false }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.showDetailSheet)
                    .zIndex(10)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
        // MARK: - BottomNavBar overlay
        .overlay(alignment: .bottom) {
            BottomNavBar(
                selectedTab: $selectedTab,
                onTabReTap: { onDismiss() },
                onTabChange: { tab in
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) { selectedTab = tab }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        onDismiss()
                    }
                }
            )
        }
        .onAppear {
            viewModel.loadBadges()
        }
    }

    @ViewBuilder
    private var themeBackground: some View {
        let theme = IsoWalkThemes.current(selectedId: selectedThemeId)
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
    BadgesScreenView(onDismiss: {})
}
