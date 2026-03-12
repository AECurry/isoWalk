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

    private let cardCornerRadius: CGFloat = 14
    private let maxCardWidth: CGFloat = 340
    private let iconSize: CGFloat = 28

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {

                // Icon
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: iconSize * 0.7, weight: .regular))
                    .foregroundColor(isoWalkColors.deepSpaceBlue)
                    .frame(width: iconSize, height: iconSize)

                Text("Change Your Apps' Theme")
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(isoWalkColors.deepSpaceBlue)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .frame(maxWidth: maxCardWidth)
            .background(
                RoundedRectangle(cornerRadius: cardCornerRadius)
                    .fill(isoWalkColors.ivory)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        FeaturesThemeRow(onTap: {})
    }
}

