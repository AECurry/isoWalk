//
//  BadgesScreenView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  PARENT VIEW — intentionally dumb.
//  Owns BadgesViewModel. Passes data down to child components.
//  Presented as a sheet from BadgesCard in ProgressScreenView.
//  Back button (top left) dismisses the sheet.
//

import SwiftUI

struct BadgesScreenView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = BadgesViewModel()
    @AppStorage(IsoWalkThemes.selectedThemeKey) private var selectedThemeId: String = IsoWalkThemes.defaultThemeId

    private let columns = [
        GridItem(.flexible(), spacing: 24),
        GridItem(.flexible(), spacing: 24)
    ]

    var body: some View {
        ZStack(alignment: .top) {
            themeBackground

            VStack(spacing: 0) {

                // MARK: - Back Button Row
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(isoWalkColors.deepSpaceBlue)
                            .padding(12)
                    }
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)

                // MARK: - Scrollable Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {

                        // MARK: - Featured Badge
                        BadgeFeaturedView(
                            mostRecentBadge: viewModel.mostRecentBadge,
                            earnedCount: viewModel.earnedCount,
                            themeId: selectedThemeId,
                            showReveal: viewModel.showRevealAnimation,
                            newlyUnlockedBadge: viewModel.newlyUnlockedBadge,
                            onRevealComplete: { viewModel.didShowReveal() }
                        )

                        // MARK: - Badge Grid
                        // Fixed order 1-38. Locked badges show placeholder.
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
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadBadges()
        }
        .sheet(isPresented: $viewModel.showDetailSheet) {
            if let badge = viewModel.selectedBadge {
                BadgeDetailSheet(
                    badge: badge,
                    themeId: selectedThemeId,
                    onDismiss: { viewModel.showDetailSheet = false }
                )
            }
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
    BadgesScreenView()
}
