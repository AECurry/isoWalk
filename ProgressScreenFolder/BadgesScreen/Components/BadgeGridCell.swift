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
import SwiftData

struct BadgeGridCell: View {
    let badge: Badge
    let themeId: String
    let onTap: () -> Void
    
    // MARK: - Design Constants
    // We only need one size now! The image will perfectly fill this circle.
    private let circleSize: CGFloat = 88
    private let nameFontSize: CGFloat = 14
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                
                
                badgeImage
                
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
                // MARK: - THE FIX (with shadow)
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: circleSize, height: circleSize)
                    .clipShape(Circle())
                // MARK: - Added shadow here
                    .shadow(color: .black.opacity(0.5), radius: 6, x: 1, y: 3)
            } else {
                // Fallback Trophy
                ZStack {
                    Circle()
                        .fill(isoWalkColors.forestGreen)
                        .frame(width: circleSize, height: circleSize)
                    
                    Image(systemName: "trophy.fill")
                        .font(.system(size: circleSize * 0.55))
                        .foregroundColor(.white)
                }
            }
        } else {
            // Locked State
            ZStack {
                Circle()
                    .fill(isoWalkColors.forestGreen.opacity(0.55))
                    .frame(width: circleSize, height: circleSize)
                
                Image(systemName: "lock.fill")
                    .font(.system(size: circleSize * 0.45))
                    .foregroundColor(.white)
                    .opacity(0.6)
            }
        }
    }
}

