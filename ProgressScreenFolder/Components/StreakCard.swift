//
//  StreakCard.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  LOCATION: ProgressScreenFolder/Components/
//  COMPONENT — dumb child.
//  Label ABOVE number. Max width 340, centered, responsive.
//  Receives values from parent — owns nothing.
//

import SwiftUI

struct StreakCard: View {

    let walksThisMonth: Int
    let longestStreak: Int

    // MARK: - Design Constants
    private let cardCornerRadius: CGFloat = 14
    private let cardHeight: CGFloat = 90
    private let maxCardWidth: CGFloat = 340
    private let valueFontSize: CGFloat = 32
    private let labelFontSize: CGFloat = 16

    var body: some View {
        HStack(spacing: 0) {

            // Walks This Month
            VStack(spacing: 4) {
                Text("Walks This Month")
                    .font(.custom("Inter-Regular", size: labelFontSize))
                    .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.8))

                HStack(spacing: 4) {
                    Text("\(walksThisMonth)")
                        .font(.custom("Inter-Bold", size: valueFontSize))
                        .foregroundColor(isoWalkColors.deepSpaceBlue)
                        .contentTransition(.numericText())
                    Text("days")
                        .font(.custom("Inter-Regular", size: labelFontSize))
                        .foregroundColor(isoWalkColors.deepSpaceBlue)
                }
            }
            .frame(maxWidth: .infinity)

            Divider()
                .frame(height: 44)
                .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.2))

            // Longest Streak
            VStack(spacing: 4) {
                Text("Longest Streak")
                    .font(.custom("Inter-Regular", size: labelFontSize))
                    .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.8))

                HStack(spacing: 4) {
                    Text("\(longestStreak)")
                        .font(.custom("Inter-Bold", size: valueFontSize))
                        .foregroundColor(isoWalkColors.deepSpaceBlue)
                        .contentTransition(.numericText())
                    Text("days")
                        .font(.custom("Inter-Regular", size: labelFontSize))
                        .foregroundColor(isoWalkColors.deepSpaceBlue)
                }
            }
            .frame(maxWidth: .infinity)
        }
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
            StreakCard(walksThisMonth: 42, longestStreak: 108)
            StreakCard(walksThisMonth: 0, longestStreak: 0)
        }
    }
}

