//
//  FeaturesThemeRow.swift
//  isoWalk
//
//  Created by AnnElaine on 3/9/26.
//
//
//  COMPONENT — dumb child.
//  Standalone ivory card for the "Change Your Apps' Theme" row.
//  Sits between HealthKitCard and FeaturesMenuGroup.
//  Receives onTap from parent — owns nothing.
//

import SwiftUI

struct FeaturesThemeRow: View {

    let onTap: () -> Void

    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }

    private let cardCornerRadius: CGFloat = 16
    private let maxCardWidth: CGFloat = 340
    private let iconSize: CGFloat = 28

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {

                // Icon
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: iconSize * 0.7, weight: .regular))
                    .foregroundColor(theme.primaryIconColor)
                    .frame(width: iconSize, height: iconSize)

                Text("Change Your Apps' Theme")
                    .font(.custom(theme.bodyFontName, size: 16))
                    .foregroundColor(theme.primaryTextColor)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.primaryIconColor.opacity(0.5))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .frame(maxWidth: maxCardWidth)
            .background(
                RoundedRectangle(cornerRadius: cardCornerRadius)
                    .fill(theme.cardColor)
            )
        }
        .buttonStyle(.plain)
    }
}

