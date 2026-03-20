//
//  TodayStatsCard.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
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

    
    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }

    // MARK: - Design Constants
    private let cardCornerRadius: CGFloat = 16
    private let cardHeight: CGFloat = 96
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
                .frame(height: 48)
                .foregroundColor(theme.primaryTextColor.opacity(0.6))

            StatCell(
                label: sessionCount == 1 ? "Session" : "Sessions",
                value: "\(sessionCount)",
                unit: "",
                valueFontSize: valueFontSize,
                labelFontSize: labelFontSize
            )

            if isHealthKitEnabled {
                Divider()
                    .frame(height: 48)
                    .foregroundColor(theme.primaryTextColor.opacity(0.6))

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
                .fill(theme.cardColor)
        )
    }
}

private struct StatCell: View {
    let label: String
    let value: String
    let unit: String
    let valueFontSize: CGFloat
    let labelFontSize: CGFloat

 
    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.custom(theme.bodyFontName, size: labelFontSize))
                .foregroundColor(theme.secondaryTextColor) // 👈 Theme

            HStack(spacing: 4) {
                Text(value)
                    .font(.custom(theme.titleFontName, size: valueFontSize))
                    .foregroundColor(theme.primaryTextColor)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)

                if !unit.isEmpty {
                    Text(unit)
                        .font(.custom(theme.bodyFontName, size: labelFontSize))
                        .foregroundColor(theme.primaryTextColor) 
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
