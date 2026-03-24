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
                    BadgeIconView(badgeId: badgeId, size: badgeCircleSize, themeId: selectedThemeId)
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
    let themeId: String
    
    var body: some View {
        // 1. Convert the raw database string back into our typed BadgeID enum
        if let validBadge = BadgeID(rawValue: badgeId),
           // 2. Ask the enum for the exact folder path (e.g., "JapaneseBadges/FirstSteps")
           UIImage(named: validBadge.imageName(themeId: themeId)) != nil {
            
            // 3. Display the custom artwork!
            Image(validBadge.imageName(themeId: themeId))
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .clipShape(Circle())
            
        } else {
            // 4. FALLBACK: Only used if the custom image is missing from Assets
            Image(systemName: fallbackSymbolName)
                .font(.system(size: size * 0.75))
                .foregroundColor(isoWalkColors.balticBlue)
        }
    }
    
    // Renamed so it's clear this is just a backup plan!
    private var fallbackSymbolName: String {
        switch badgeId {
        case "firstSteps":      return "figure.walk"
        case "habitWalker":     return "flame.fill"
        case "eveningUnwinder": return "moon.stars.fill"
        case "morningMover":    return "sun.max.fill"
        case "perfectPace":     return "timer"
        case "rhythmFinder":    return "crown.fill"
        case "momentumMaker":   return "star.fill"
        default:                return "figure.walk.circle"
        }
    }
}

