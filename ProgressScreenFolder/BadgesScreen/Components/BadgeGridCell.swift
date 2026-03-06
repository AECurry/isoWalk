//
//  BadgeGridCell.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONENT — dumb child.
//  Single badge cell. Shows theme-matched locked placeholder or earned badge.
//  Name always visible. Tappable — calls onTap.
//  Receives all data from parent — owns nothing.
//

import SwiftUI

struct BadgeGridCell: View {

    let badge: Badge
    let themeId: String
    let onTap: () -> Void

    // MARK: - Design Constants
    private let circleSize: CGFloat = 88
    private let iconSize: CGFloat = 44
    private let nameFontSize: CGFloat = 14

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(circleColor)
                        .frame(width: circleSize, height: circleSize)

                    badgeImage
                }

                Text(badge.id.displayName)
                    .font(.custom("Inter-Regular", size: nameFontSize))
                    .foregroundColor(isoWalkColors.deepSpaceBlue)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
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
                // SF Symbol fallback until real assets exist
                Image(systemName: "trophy.fill")
                    .font(.system(size: iconSize * 0.55))
                    .foregroundColor(.white)
            }
        } else {
            // Locked — show theme-matched placeholder
            let lockedAsset = BadgeID.lockedImageName(themeId: themeId)
            if UIImage(named: lockedAsset) != nil {
                Image(lockedAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
            } else {
                // SF Symbol fallback
                Image(systemName: "trophy.fill")
                    .font(.system(size: iconSize * 0.55))
                    .foregroundColor(.white)
                    .opacity(0.7)
            }
        }
    }

    private var circleColor: Color {
        badge.isUnlocked
            ? isoWalkColors.forestGreen
            : isoWalkColors.forestGreen.opacity(0.55)
    }
}

#Preview {
    ZStack {
        Image("GoldenTextureBackground")
            .resizable()
            .ignoresSafeArea()
        HStack(spacing: 24) {
            BadgeGridCell(
                badge: Badge(id: .firstSteps, unlockedDate: Date()),
                themeId: "Golden",
                onTap: {}
            )
            BadgeGridCell(
                badge: Badge(id: .rhythmFinder, unlockedDate: nil),
                themeId: "Golden",
                onTap: {}
            )
        }
        .padding()
    }
}
