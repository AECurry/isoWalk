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
    // FIXED SIZING: Icon size is much closer to circle size so it fills the space.
    // The asset must have transparent alpha background.
    private let iconSize: CGFloat = 82
    private let nameFontSize: CGFloat = 14

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    // This green circle serves as a border/locked state
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
        // Find the correct asset path in the JapaneseBadges folder
        let assetName = badge.id.imageName(themeId: themeId)
        
        if badge.isUnlocked {
            if UIImage(named: assetName) != nil {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
            } else {
                Image(systemName: "trophy.fill")
                    .font(.system(size: iconSize * 0.55))
                    .foregroundColor(.white)
            }
        } else {
            // Locked — generic placeholder (muted look)
            Image(systemName: "trophy.fill")
                .font(.system(size: iconSize * 0.55))
                .foregroundColor(.white)
                .opacity(0.4)
        }
    }

    private var circleColor: Color {
        badge.isUnlocked
            ? isoWalkColors.forestGreen
            : isoWalkColors.forestGreen.opacity(0.55)
    }
}
