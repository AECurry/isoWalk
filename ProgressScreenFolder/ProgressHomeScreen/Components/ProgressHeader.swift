//
//  ProgressHeader.swift
//  isoWalk
//
//  Created by AnnElaine on 2/26/26.
//
//
//  COMPONENT — dumb child.
//  Displays greeting, current badge, and total walk count.
//  Receives all data from ProgressScreenView — owns nothing.
//

import SwiftUI

struct ProgressHeader: View {

    let userName: String
    let totalWalkCount: Int
    let mostRecentBadgeId: String?

    
    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }

    // MARK: - Design Constants
    private let badgeCircleSize: CGFloat = 152
    private let sideColumnWidth: CGFloat = 96
    private let iconSize: CGFloat = 32

    var body: some View {
        HStack(alignment: .center, spacing: 16) {

            // LEFT: Greeting
            VStack(spacing: 8) {
                Image("Icons/HandWavingIcon")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundColor(theme.primaryTextColor)

                VStack(spacing: 4) {
                    Text("Hello")
                    Text(userName.isEmpty ? "Friend" : userName)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .font(.custom(theme.bodyFontName, size: 16))
                .foregroundColor(theme.primaryTextColor)
            }
            .frame(width: sideColumnWidth)

            // CENTER: Badge Display
            ZStack {
                Circle()
                    .fill(isoWalkColors.balticBlue.opacity(0.12))
                    .frame(width: badgeCircleSize, height: badgeCircleSize)

                if let badgeId = mostRecentBadgeId {
                    BadgeIconView(badgeId: badgeId, size: 80)
                } else {
                    Image(systemName: "figure.walk.circle")
                        .font(.system(size: 60))
                        .foregroundColor(isoWalkColors.balticBlue.opacity(0.4))
                }
            }

            // RIGHT: Total Walks
            VStack(spacing: 4) {
                Text("\(totalWalkCount)")
                    .font(.custom(theme.titleFontName, size: 32))
                    .foregroundColor(theme.primaryTextColor)

                Text("Total")
                    .font(.custom(theme.bodyFontName, size: 16))
                    .foregroundColor(theme.primaryTextColor)
                Text("Walks")
                    .font(.custom(theme.bodyFontName, size: 16))
                    .foregroundColor(theme.primaryTextColor)     
            }
            .multilineTextAlignment(.center)
            .frame(width: sideColumnWidth)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }
}

// MARK: - Badge Icon View
struct BadgeIconView: View {
    let badgeId: String
    let size: CGFloat

    var body: some View {
        Image(systemName: symbolName)
            .font(.system(size: size))
            .foregroundColor(isoWalkColors.balticBlue)
    }

    private var symbolName: String {
        switch badgeId {
        case "first_walk":    return "figure.walk"
        case "streak_3":      return "flame.fill"
        case "streak_7":      return "crown.fill"
        case "walks_10":      return "star.fill"
        case "walks_50":      return "trophy.fill"
        case "walks_100":     return "medal.fill"
        default:              return "figure.walk.circle"
        }
    }
}

