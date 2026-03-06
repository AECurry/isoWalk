//
//  BadgesCard.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  LOCATION: ProgressScreenFolder/Components/
//  COMPONENT — dumb child.
//  Label ABOVE number. Max width 340, centered, responsive.
//  Receives badgesEarned from parent — owns nothing.
//

import SwiftUI

struct BadgesCard: View {

    let badgesEarned: Int

    // MARK: - Design Constants
    private let cardCornerRadius: CGFloat = 14
    private let cardHeight: CGFloat = 90
    private let maxCardWidth: CGFloat = 340
    private let trophyCircleSize: CGFloat = 48
    private let trophyIconSize: CGFloat = 32
    private let valueFontSize: CGFloat = 32
    private let labelFontSize: CGFloat = 16

    var body: some View {
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
                .fill(Color(UIColor.systemGray6).opacity(0.92))
        )
    }
}

#Preview {
    ZStack {
        Image("GoldenTextureBackground")
            .resizable()
            .ignoresSafeArea()
        VStack(spacing: 12) {
            BadgesCard(badgesEarned: 8)
            BadgesCard(badgesEarned: 0)
        }
    }
}

