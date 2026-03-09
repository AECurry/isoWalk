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

    private let cardCornerRadius: CGFloat = 14
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
                .fill(isoWalkColors.ivory)
        )
    }

    // MARK: - Row Builder
    private func menuRow(icon: String, title: String, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(isoWalkColors.deepSpaceBlue)
                    .frame(width: 24, height: 24)

                Text(title)
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(isoWalkColors.deepSpaceBlue)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .buttonStyle(.plain)
    }

    private var divider: some View {
        Divider()
            .background(isoWalkColors.deepSpaceBlue.opacity(0.15))
            .padding(.horizontal, 20)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        FeaturesMenuGroup(
            onNameEmail: {},
            onNotifications: {},
            onPrivacy: {},
            onScientificProof: {},
            onSubmitFeedback: {}
        )
        .padding()
    }
}
