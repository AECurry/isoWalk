//
//  FeaturesMenuGroup.swift
//  isoWalk
//
//  Created by AnnElaine on 3/9/26.
//
//  COMPONENT — dumb child.
//  Single ivory card containing all 5 menu rows separated by dividers.
//  Each row receives an onTap callback from parent — owns nothing.
//

import SwiftUI

struct FeaturesMenuGroup: View {

    let onNameEmail:       () -> Void
    let onNotifications:   () -> Void
    let onPrivacy:         () -> Void
    let onScientificProof: () -> Void
    let onSubmitFeedback:  () -> Void

    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }

    private let cardCornerRadius: CGFloat = 16
    private let maxCardWidth: CGFloat = 340

    var body: some View {
        VStack(spacing: 0) {
            menuRow(
                icon: "envelope",
                title: "Name & Email",
                onTap: onNameEmail
            )
            divider
            menuRow(
                icon: "iphone",
                title: "Notifications",
                onTap: onNotifications
            )
            divider
            menuRow(
                icon: "checkmark.shield",
                title: "Privacy",
                onTap: onPrivacy
            )
            divider
            menuRow(
                icon: "doc.text",
                title: "Scientific Proof",
                onTap: onScientificProof
            )
            divider
            menuRow(
                icon: "pencil.and.outline",
                title: "Submit Feedback",
                onTap: onSubmitFeedback
            )
        }
        .frame(maxWidth: maxCardWidth)
        .background(
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(theme.cardColor)
        )
    }

    // MARK: - Row Builder
    private func menuRow(icon: String, title: String, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(theme.primaryIconColor)
                    .frame(width: 24, height: 24)

                Text(title)
                    .font(.custom(theme.bodyFontName, size: 16))
                    .foregroundColor(theme.primaryTextColor)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.primaryIconColor.opacity(0.5))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
    }

    private var divider: some View {
        Divider()
            .background(theme.primaryTextColor.opacity(0.16))
            .padding(.horizontal, 24)
    }
}

