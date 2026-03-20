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
    
    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }

    private let cardCornerRadius: CGFloat = 16
    private let maxCardWidth: CGFloat = 340

    var body: some View {
        HStack(spacing: 12) {

            // Green heart icon (Kept forest green as it's a specific health brand color)
            Image(systemName: "heart.fill")
                .font(.system(size: 16))
                .foregroundColor(isoWalkColors.forestGreen)

            // Title + subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text("HealthKit Integration")
                    .font(.custom(theme.bodyFontName, size: 16))
                    .foregroundColor(theme.primaryTextColor)

                Text("Track walking distance in Apple Health")
                    .font(.custom(theme.bodyFontName, size: 12))
                    .foregroundColor(theme.secondaryTextColor)
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
        .padding(.vertical, 16)
        .frame(maxWidth: maxCardWidth)
        .background(
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(theme.cardColor)
        )

        // MARK: - Denied Alert
        .alert("HealthKit Access Required", isPresented: $viewModel.showDeniedAlert) {
            Button("Open Settings") { viewModel.openSettings() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("To enable HealthKit, go to Settings → Privacy & Security → Health → isoWalk and turn on all permissions.")
        }

        // MARK: - Unavailable Alert
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

