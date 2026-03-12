//
//  HealthKitCard.swift
//  isoWalk
//
//  Created by AnnElaine on 3/9/26.
//
//
//  COMPONENT — dumb child.
//  Ivory card with green heart, title, subtitle, and toggle.
//  Owns HealthKitViewModel — all logic lives there.
//  Shows alerts for denied permission and unavailable device.
//

import SwiftUI

struct HealthKitCard: View {

    @State private var viewModel = HealthKitViewModel()

    private let cardCornerRadius: CGFloat = 14
    private let maxCardWidth: CGFloat = 340

    var body: some View {
        HStack(spacing: 12) {

            // Green heart icon
            Image(systemName: "heart.fill")
                .font(.system(size: 18))
                .foregroundColor(isoWalkColors.forestGreen)

            // Title + subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text("HealthKit Integration")
                    .font(.custom("Inter-SemiBold", size: 15))
                    .foregroundColor(isoWalkColors.deepSpaceBlue)

                Text("Track walking distance in Apple Health")
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.6))
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { viewModel.isEnabled },
                set: { _ in viewModel.toggleHealthKit() }
            ))
            .labelsHidden()
            .tint(isoWalkColors.balticBlue)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: maxCardWidth)
        .background(
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(isoWalkColors.ivory)
        )

        // MARK: - Denied Alert
        // Shown when user previously denied HealthKit or denies in dialog.
        // "Open Settings" deep links to iOS Settings → Health → isoWalk.
        .alert("HealthKit Access Required", isPresented: $viewModel.showDeniedAlert) {
            Button("Open Settings") { viewModel.openSettings() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("To enable HealthKit, go to Settings → Privacy & Security → Health → isoWalk and turn on all permissions.")
        }

        // MARK: - Unavailable Alert
        // Shown on devices that don't support HealthKit (e.g. iPad).
        .alert("HealthKit Not Available", isPresented: $viewModel.showUnavailableAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("HealthKit is not supported on this device.")
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        HealthKitCard()
    }
}

