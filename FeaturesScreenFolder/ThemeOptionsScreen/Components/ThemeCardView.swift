//
//  ThemeCardView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONENT — dumb child.
//  Displays a single selectable theme card.
//  Fixed size square — image fills most of card, title below.
//  Background uses theme.backgroundColor so each theme looks different.
//  Receives all data and callbacks from parent — owns nothing.
//

import SwiftUI

struct ThemeCardView: View {

    let theme: IsoWalkTheme
    let isSelected: Bool
    let onSelect: () -> Void

    // MARK: - Design Constants
    private let cardWidth: CGFloat = 150
    private let imageSize: CGFloat = 120   // image fills most of the card
    private let cardCornerRadius: CGFloat = 16
    private let titleFontSize: CGFloat = 14

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 0) {

                // MARK: - Image Area
                ZStack(alignment: .topTrailing) {
                    // Theme image fills the image area
                    Image(theme.mainImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize, height: imageSize)
                        .padding(.top, 12)

                    // Selected checkmark badge
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(isoWalkColors.balticBlue)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .padding(2)
                            )
                            .padding(8)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(width: cardWidth, height: imageSize + 12)

                // MARK: - Title Area
                Text(theme.displayName)
                    .font(.custom("Inter-SemiBold", size: titleFontSize))
                    .foregroundStyle(isoWalkColors.deepSpaceBlue)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
                    .frame(width: cardWidth)
            }
            .frame(width: cardWidth)
            // Dynamic background — each theme uses its own color
            .background(theme.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cardCornerRadius)
                    .strokeBorder(
                        isSelected ? isoWalkColors.balticBlue : Color.gray.opacity(0.15),
                        lineWidth: isSelected ? 2.5 : 1
                    )
            )
            .shadow(
                color: isSelected ? isoWalkColors.balticBlue.opacity(0.25) : .black.opacity(0.06),
                radius: isSelected ? 12 : 6,
                x: 0,
                y: isSelected ? 6 : 3
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let theme = IsoWalkThemes.all[0]
    HStack(spacing: 16) {
        ThemeCardView(theme: theme, isSelected: true, onSelect: {})
        ThemeCardView(theme: theme, isSelected: false, onSelect: {})
    }
    .padding()
    .background(isoWalkColors.parchment)
}
