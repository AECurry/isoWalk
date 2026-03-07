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

    // MARK: - Design Constants
    private let cardCornerRadius: CGFloat = 14
    private let cardHeight: CGFloat = 90
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
                        .font(.custom("Inter-Regular", size: labelFontSize))
                        .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.8))

                    Text("\(badgesEarned)")
                        .font(.custom("Inter-Bold", size: valueFontSize))
                        .foregroundColor(isoWalkColors.deepSpaceBlue)
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
                    .fill(isoWalkColors.ivory)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Image("GoldenTextureBackground")
            .resizable()
            .ignoresSafeArea()
        VStack(spacing: 12) {
            BadgesCard(badgesEarned: 8, onShowBadges: {})
            BadgesCard(badgesEarned: 0, onShowBadges: {})
        }
    }
}
