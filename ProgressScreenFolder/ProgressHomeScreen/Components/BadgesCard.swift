//
//  BadgesCard.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONENT — dumb child.
//  Tappable — calls onShowBadges so isoWalkMainView presents BadgesScreenView.
//  Owns nothing — receives badgesEarned and onShowBadges from parent.
//

import SwiftUI

struct BadgesCard: View {

    let badgesEarned: Int
    let onShowBadges: () -> Void

    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }

    // MARK: - Design Constants
    private let cardCornerRadius: CGFloat = 16
    private let cardHeight: CGFloat = 96
    private let maxCardWidth: CGFloat = 340
    private let trophyCircleSize: CGFloat = 48
    private let trophyIconSize: CGFloat = 32
    private let valueFontSize: CGFloat = 32
    private let labelFontSize: CGFloat = 16

    var body: some View {
        Button(action: onShowBadges) {
            HStack(spacing: 16) {

                VStack(alignment: .leading, spacing: 4) {
                    Text("Badges Earned")
                        .font(.custom(theme.bodyFontName, size: labelFontSize))
                        .foregroundColor(theme.secondaryTextColor)

                    Text("\(badgesEarned)")
                        .font(.custom(theme.titleFontName, size: valueFontSize))
                        .foregroundColor(theme.primaryTextColor)
                        .contentTransition(.numericText())
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(isoWalkColors.balticBlue)
                        .frame(width: trophyCircleSize, height: trophyCircleSize)

                    if UIImage(named: "TrophyIcon") != nil {
                        Image("TrophyIcon")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: trophyIconSize, height: trophyIconSize)
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: trophyIconSize))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: maxCardWidth)
            .frame(height: cardHeight)
            .background(
                RoundedRectangle(cornerRadius: cardCornerRadius)
                    .fill(theme.cardColor)
            )
        }
        .buttonStyle(.plain)
    }
}

