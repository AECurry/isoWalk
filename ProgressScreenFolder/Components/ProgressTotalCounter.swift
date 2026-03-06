//
//  ProgressTotalCounter.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  LOCATION: ProgressScreenFolder/Components/
//
//  COMPONENT — dumb child.
//  Big all-time number. Total Time (HealthKit OFF) or Miles (HealthKit ON).
//  Fixed — does not scroll with the cards below it.
//  Receives formatted values from parent — owns nothing.
//

import SwiftUI

struct ProgressTotalCounter: View {

    let formattedTotalTime: String
    let isHealthKitEnabled: Bool
    var formattedTotalMiles: String = "0"

    // MARK: - Design Constants
    private let numberFontSize: CGFloat = 60
    private let subtitleFontSize: CGFloat = 18

    var body: some View {
        VStack(spacing: 4) {
            Text(isHealthKitEnabled ? formattedTotalMiles : formattedTotalTime)
                .font(.custom("Inter-Bold", size: numberFontSize))
                .foregroundColor(isoWalkColors.deepSpaceBlue)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: formattedTotalTime)

            Text(isHealthKitEnabled ? "Miles, and counting!" : "Total Walk Time")
                .font(.custom("Inter-Regular", size: subtitleFontSize))
                .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .padding(.horizontal, 16)
    }
}

#Preview {
    ZStack {
        Image("GoldenTextureBackground")
            .resizable()
            .ignoresSafeArea()
        VStack(spacing: 20) {
            ProgressTotalCounter(
                formattedTotalTime: "14h 22m",
                isHealthKitEnabled: false
            )
            ProgressTotalCounter(
                formattedTotalTime: "14h 22m",
                isHealthKitEnabled: true,
                formattedTotalMiles: "25,982"
            )
        }
    }
}

