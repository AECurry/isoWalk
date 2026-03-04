//
//  ThemeCardView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONENT — dumb child.
//  Displays a single selectable theme card.
//  Receives all data and callbacks from parent — owns nothing.
//

import SwiftUI

struct ThemeCardView: View {

    // MARK: - Input
    let theme: IsoWalkTheme
    let isSelected: Bool
    let onSelect: () -> Void

    // MARK: - Body
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 0) {
                imageArea
                infoArea
            }
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(selectionBorder)
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

    // MARK: - Subviews

    private var imageArea: some View {
        ZStack(alignment: .topTrailing) {
            Image(theme.mainImageName)
                .resizable()
                .scaledToFit()
                .padding(16)
                .frame(maxWidth: .infinity)
                .frame(height: 130)

            if isSelected {
                selectedBadge
                    .padding(10)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private var selectedBadge: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(isoWalkColors.balticBlue)
            .background(
                Circle()
                    .fill(Color.white)
                    .padding(2)
            )
    }

    private var infoArea: some View {
        VStack(spacing: 4) {
            Text(theme.displayName)
                .font(.custom("Inter-SemiBold", size: 13))
                .foregroundStyle(isoWalkColors.adaptiveText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(
            isoWalkColors.adaptiveBackground.opacity(0.6)
        )
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(isSelected ? isoWalkColors.parchment : Color(.systemBackground))
    }

    private var selectionBorder: some View {
        RoundedRectangle(cornerRadius: 20)
            .strokeBorder(
                isSelected ? isoWalkColors.balticBlue : Color.gray.opacity(0.15),
                lineWidth: isSelected ? 2.5 : 1
            )
    }
}

#Preview {
    let theme = IsoWalkThemes.all[0]
    HStack {
        ThemeCardView(theme: theme, isSelected: true, onSelect: {})
        ThemeCardView(theme: theme, isSelected: false, onSelect: {})
    }
    .padding()
}

