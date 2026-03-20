//
//  BadgeDetailSheet.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONENT — dumb child.
//  Centered popup shown when user taps a badge in the grid.
//  Not a sheet — rendered as an overlay in BadgesScreenView.
//  Locked: shows name and requirement only, no badge artwork revealed.
//  Unlocked: shows badge artwork, name, requirement, and date earned.
//  Receives badge data from parent — owns nothing.
//

import SwiftUI

struct BadgeDetailSheet: View {

    let badge: Badge
    let themeId: String
    let onDismiss: () -> Void

    // MARK: - Design Constants
    private let popupWidth: CGFloat = 320
    private let popupHeight: CGFloat = 440 // Increased slightly to fit the Share button nicely
    private let cornerRadius: CGFloat = 24
    private let circleSize: CGFloat = 120
    private let iconSize: CGFloat = 60
    private let titleFontSize: CGFloat = 22
    private let bodyFontSize: CGFloat = 15
    private let labelFontSize: CGFloat = 13

    var body: some View {
        ZStack {
            // Dim background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            // Popup card
            VStack(spacing: 16) {
                // Close button top right
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.5))
                    }
                    .padding([.top, .trailing], 16)
                }

                // Badge circle
                ZStack {
                    Circle()
                        .fill(badge.isUnlocked
                              ? isoWalkColors.forestGreen
                              : isoWalkColors.forestGreen.opacity(0.3)) // Muted if locked
                        .frame(width: circleSize, height: circleSize)

                    badgeImageContent
                }

                // Badge name
                Text(badge.id.displayName)
                    .font(.custom("Inter-Bold", size: titleFontSize))
                    .foregroundColor(isoWalkColors.deepSpaceBlue)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                // Status pill
                if badge.isUnlocked {
                    VStack(spacing: 4) {
                        Text("Badge Earned")
                            .font(.custom("Inter-SemiBold", size: labelFontSize))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(isoWalkColors.forestGreen))

                        if let dateString = badge.formattedUnlockDate {
                            Text(dateString)
                                .font(.custom("Inter-Regular", size: labelFontSize))
                                .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.7))
                        }
                    }
                } else {
                    Text("Keep Walking to Unlock")
                        .font(.custom("Inter-SemiBold", size: labelFontSize))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(isoWalkColors.deepSpaceBlue.opacity(0.4)))
                }

                // Requirement
                VStack(spacing: 6) {
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
                
                // MARK: - Share Button
                // Only show the share button if they actually earned it!
                if badge.isUnlocked {
                    ShareLink(
                        item: "I just earned the \(badge.id.displayName) badge in isoWalk! 🚶‍♂️✨ Time to keep the streak alive."
                    ) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .bold))
                            Text("Share Badge")
                                .font(.custom("Inter-SemiBold", size: 16))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 12).fill(isoWalkColors.forestGreen))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                    }
                } else {
                    // Just a little bottom padding if locked
                    Spacer().frame(height: 20)
                }
            }
            .frame(width: popupWidth, height: popupHeight)
            .background(
                Group {
                    if let bgName = currentThemeBackground {
                        Image(bgName)
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(1.2)
                    } else {
                        isoWalkColors.ivory
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 8)
        }
    }

    @ViewBuilder
    private var badgeImageContent: some View {
        let assetName = badge.id.imageName(themeId: themeId)
        
        if badge.isUnlocked {
            if UIImage(named: assetName) != nil {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
            } else {
                Image(systemName: "trophy.fill")
                    .font(.system(size: iconSize * 0.7))
                    .foregroundColor(.white)
            }
        } else {
            if UIImage(named: assetName) != nil {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .saturation(0) // Grayscale
                    .opacity(0.2)  // Very faint
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: iconSize * 0.6))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }

    private var currentThemeBackground: String? {
        IsoWalkTheme.current(selectedId: themeId).backgroundImageName
    }
}
