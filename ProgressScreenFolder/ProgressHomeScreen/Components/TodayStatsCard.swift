//
//  TodayStatsCard.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  LOCATION: ProgressScreenFolder/Components/
//
//  COMPONENT — dumb child.
//  Always shows: Active Time, Sessions.
//  Shows Miles only when HealthKit is enabled.
//  Label above. Number + unit in HStack with center alignment —
//  identical pattern to StreakCard's number + "days" layout.
//  Receives all values from parent — owns nothing.
//

import SwiftUI

struct TodayStatsCard: View {

    let formattedActiveTime: String
    let sessionCount: Int
    let isHealthKitEnabled: Bool
    let miles: Double

    // MARK: - Design Constants
    private let cardCornerRadius: CGFloat = 14
    private let cardHeight: CGFloat = 90
    private let maxCardWidth: CGFloat = 340
    private let valueFontSize: CGFloat = 32
    private let labelFontSize: CGFloat = 16

    private var activeTimeNumber: String {
        formattedActiveTime.components(separatedBy: " ").first ?? formattedActiveTime
    }
    private var activeTimeUnit: String {
        formattedActiveTime.components(separatedBy: " ").dropFirst().joined(separator: " ")
    }

    var body: some View {
        HStack(spacing: 0) {

            StatCell(
                label: "Active Time",
                value: activeTimeNumber,
                unit: activeTimeUnit,
                valueFontSize: valueFontSize,
                labelFontSize: labelFontSize
            )

            Divider()
                .frame(height: 44)
                .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.6))

            StatCell(
                label: sessionCount == 1 ? "Session" : "Sessions",
                value: "\(sessionCount)",
                unit: "",
                valueFontSize: valueFontSize,
                labelFontSize: labelFontSize
            )

            if isHealthKitEnabled {
                Divider()
                    .frame(height: 44)
                    .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.6))

                StatCell(
                    label: "Miles",
                    value: String(format: "%.1f", miles),
                    unit: "",
                    valueFontSize: valueFontSize,
                    labelFontSize: labelFontSize
                )
            }
        }
        .frame(maxWidth: maxCardWidth)
        .frame(height: cardHeight)
        .background(
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(isoWalkColors.ivory)
        )
    }
}

// MARK: - Stat Cell
// Exact same pattern as StreakCard:
// label above in Regular/16pt, then HStack with number Bold/32pt
// and unit Regular/16pt, default center alignment, no padding tricks.
private struct StatCell: View {
    let label: String
    let value: String
    let unit: String
    let valueFontSize: CGFloat
    let labelFontSize: CGFloat

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.custom("Inter-Regular", size: labelFontSize))
                .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.8))

            HStack(spacing: 4) {
                Text(value)
                    .font(.custom("Inter-Bold", size: valueFontSize))
                    .foregroundColor(isoWalkColors.deepSpaceBlue)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)

                if !unit.isEmpty {
                    Text(unit)
                        .font(.custom("Inter-Regular", size: labelFontSize))
                        .foregroundColor(isoWalkColors.deepSpaceBlue)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        Image("GoldenTextureBackground")
            .resizable()
            .ignoresSafeArea()
        VStack(spacing: 12) {
            TodayStatsCard(
                formattedActiveTime: "33 min",
                sessionCount: 1,
                isHealthKitEnabled: false,
                miles: 0
            )
            TodayStatsCard(
                formattedActiveTime: "54 min",
                sessionCount: 2,
                isHealthKitEnabled: true,
                miles: 4.2
            )
        }
    }
}

