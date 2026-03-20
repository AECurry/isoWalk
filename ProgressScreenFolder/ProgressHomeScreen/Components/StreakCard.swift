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

    
    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }

    // MARK: - Design Constants
    private let cardCornerRadius: CGFloat = 16
    private let cardHeight: CGFloat = 96
    private let maxCardWidth: CGFloat = 340
    private let valueFontSize: CGFloat = 32
    private let labelFontSize: CGFloat = 16

    var body: some View {
        HStack(spacing: 0) {

            // Walks This Month
            VStack(spacing: 4) {
                Text("Walks This Month")
                    .font(.custom(theme.bodyFontName, size: labelFontSize))
                    .foregroundColor(theme.secondaryTextColor)

                HStack(spacing: 4) {
                    Text("\(walksThisMonth)")
                        .font(.custom(theme.titleFontName, size: valueFontSize))
                        .foregroundColor(theme.primaryTextColor)
                        .contentTransition(.numericText())
                    Text("days")
                        .font(.custom(theme.bodyFontName, size: labelFontSize))
                        .foregroundColor(theme.primaryTextColor)
                }
            }
            .frame(maxWidth: .infinity)

            Divider()
                .frame(height: 48)
                .foregroundColor(theme.primaryTextColor.opacity(0.2))

            // Longest Streak
            VStack(spacing: 4) {
                Text("Longest Streak")
                    .font(.custom(theme.bodyFontName, size: labelFontSize))
                    .foregroundColor(theme.secondaryTextColor)

                HStack(spacing: 4) {
                    Text("\(longestStreak)")
                        .font(.custom(theme.titleFontName, size: valueFontSize))
                        .foregroundColor(theme.primaryTextColor)
                        .contentTransition(.numericText())
                    Text("days")
                        .font(.custom(theme.bodyFontName, size: labelFontSize))
                        .foregroundColor(theme.primaryTextColor)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: maxCardWidth)
        .frame(height: cardHeight)
        .background(
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(theme.cardColor) 
        )
    }
}

