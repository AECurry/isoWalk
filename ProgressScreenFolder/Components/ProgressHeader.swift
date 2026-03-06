//
//  ProgressHeader.swift
//  isoWalk
//
//  Created by AnnElaine on 2/26/26.
//
//  LOCATION: ProgressScreenFolder/Components/
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

    // MARK: - Design Constants
    private let badgeCircleSize: CGFloat = 152
    private let sideColumnWidth: CGFloat = 96
    private let iconSize: CGFloat = 32

    var body: some View {
        HStack(alignment: .center, spacing: 24) {

            // LEFT: Greeting
            VStack(spacing: 8) {
                Image("HandWavingIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)

                VStack(spacing: 4) {
                    Text("Hello")
                    Text(userName.isEmpty ? "Friend" : userName)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(isoWalkColors.deepSpaceBlue)
            }
            .frame(width: sideColumnWidth)

            // CENTER: Badge Display
            // Shows most recently earned badge.
            // Placeholder shown until first badge is earned.
            ZStack {
                Circle()
                    .fill(isoWalkColors.balticBlue.opacity(0.12))
                    .frame(width: badgeCircleSize, height: badgeCircleSize)

                if let badgeId = mostRecentBadgeId {
                    BadgeIconView(badgeId: badgeId, size: 80)
                } else {
                    // No badge earned yet — neutral placeholder
                    Image(systemName: "figure.walk.circle")
                        .font(.system(size: 60))
                        .foregroundColor(isoWalkColors.balticBlue.opacity(0.4))
                }
            }

            // RIGHT: Total Walks
            VStack(spacing: 8) {
                Image("CalendarIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)

                VStack(spacing: 4) {
                    Text("\(totalWalkCount)")
                        .font(.custom("Inter-Bold", size: 24))

                    Text("Total Walks")
                        .fixedSize(horizontal: true, vertical: false)
                }
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(isoWalkColors.deepSpaceBlue)
            }
            .frame(width: sideColumnWidth)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }
}

// MARK: - Badge Icon View
// Resolves a badgeId string to the correct SF Symbol or asset.
// Extend this switch as new badges are added.
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

#Preview {
    ZStack {
        Image("GoldenTextureBackground")
            .resizable()
            .ignoresSafeArea()
        VStack(spacing: 32) {
            ProgressHeader(
                userName: "AnnElaine",
                totalWalkCount: 142,
                mostRecentBadgeId: "streak_7"
            )
            ProgressHeader(
                userName: "",
                totalWalkCount: 0,
                mostRecentBadgeId: nil
            )
        }
    }
}

