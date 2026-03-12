//
//  NotificationToggleRow.swift
//  isoWalk
//
//  Created by AnnElaine on 3/9/26.
//
//
//  COMPONENT — dumb child.
//  Single ivory card row: icon + title + subtitle + toggle.
//  Receives all state and callbacks from parent — owns nothing.
//

import SwiftUI

struct NotificationToggleRow: View {

    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 16) {

            // Icon
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(isoWalkColors.balticBlue)
                .frame(width: 32)

            // Text
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundStyle(isoWalkColors.deepSpaceBlue)
                Text(subtitle)
                    .font(.custom("Inter-Regular", size: 13))
                    .foregroundStyle(isoWalkColors.deepSpaceBlue.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            // Toggle
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(isoWalkColors.balticBlue)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isoWalkColors.ivory)
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        NotificationToggleRow(
            icon: "bell.fill",
            title: "Daily Walking Reminder",
            subtitle: "Get a nudge each day to take your walk",
            isOn: .constant(true)
        )
        NotificationToggleRow(
            icon: "flame.fill",
            title: "Streak & Badge Alerts",
            subtitle: "Know when you earn a badge or risk losing your streak",
            isOn: .constant(false)
        )
    }
    .padding()
    .background(isoWalkColors.parchment)
}

