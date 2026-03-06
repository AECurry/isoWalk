//
//  BadgeDetailSheet.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONENT — dumb child.
//  Sheet shown when user taps a badge in the grid.
//  Locked: shows name and requirement, hides badge artwork.
//  Unlocked: shows badge artwork, name, requirement, and date earned.
//  Receives badge data from parent — owns nothing.
//

import SwiftUI

struct BadgeDetailSheet: View {

    let badge: Badge
    let themeId: String
    let onDismiss: () -> Void

    // MARK: - Design Constants
    private let circleSize: CGFloat = 120
    private let iconSize: CGFloat = 60
    private let titleFontSize: CGFloat = 24
    private let bodyFontSize: CGFloat = 16
    private let labelFontSize: CGFloat = 14

    var body: some View {
        ZStack {
            // Background
            if let bgName = currentThemeBackground {
                Image(bgName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            } else {
                isoWalkColors.ivory.ignoresSafeArea()
            }

            VStack(spacing: 24) {

                // Drag indicator
                Capsule()
                    .fill(isoWalkColors.deepSpaceBlue.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)

                // Badge circle
                ZStack {
                    Circle()
                        .fill(badge.isUnlocked
                              ? isoWalkColors.forestGreen
                              : isoWalkColors.forestGreen.opacity(0.55))
                        .frame(width: circleSize, height: circleSize)

                    badgeImage
                }

                // Badge name
                Text(badge.id.displayName)
                    .font(.custom("Inter-Bold", size: titleFontSize))
                    .foregroundColor(isoWalkColors.deepSpaceBlue)
                    .multilineTextAlignment(.center)

                // Status label
                if badge.isUnlocked {
                    Text("Badge Earned")
                        .font(.custom("Inter-SemiBold", size: labelFontSize))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            Capsule().fill(isoWalkColors.forestGreen)
                        )

                    if let dateString = badge.formattedUnlockDate {
                        Text(dateString)
                            .font(.custom("Inter-Regular", size: labelFontSize))
                            .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.7))
                    }
                } else {
                    Text("Keep Walking to Unlock")
                        .font(.custom("Inter-SemiBold", size: labelFontSize))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(isoWalkColors.deepSpaceBlue.opacity(0.5))
                        )
                }

                // Requirement
                VStack(spacing: 8) {
                    Text("How to Earn")
                        .font(.custom("Inter-SemiBold", size: labelFontSize))
                        .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.7))

                    Text(badge.id.requirement)
                        .font(.custom("Inter-Regular", size: bodyFontSize))
                        .foregroundColor(isoWalkColors.deepSpaceBlue)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }

    @ViewBuilder
    private var badgeImage: some View {
        if badge.isUnlocked {
            let assetName = badge.id.imageName(themeId: themeId)
            if UIImage(named: assetName) != nil {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
            } else {
                Image(systemName: "trophy.fill")
                    .font(.system(size: iconSize * 0.6))
                    .foregroundColor(.white)
            }
        } else {
            Image(systemName: "trophy.fill")
                .font(.system(size: iconSize * 0.6))
                .foregroundColor(.white)
                .opacity(0.7)
        }
    }

    private var currentThemeBackground: String? {
        IsoWalkThemes.current(selectedId: themeId).backgroundImageName
    }
}

#Preview {
    BadgeDetailSheet(
        badge: Badge(id: .firstSteps, unlockedDate: Date()),
        themeId: "Golden",
        onDismiss: {}
    )
}
