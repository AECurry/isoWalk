//
//  TodayTimelineCard.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONENT — dumb child.
//  24-hour dashed timeline. Max 3 session markers at actual time positions.
//  "12 AM _ _ _ 12 AM" all on the same line, 16pt from card bottom.
//  Session bars grow upward above the line.
//  Max width 340, centered, responsive.
//  Receives session data from parent — owns nothing.
//

import SwiftUI

struct TodayTimelineCard: View {

    let sessions: [CompletedSession]

   
    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }

    // MARK: - Design Constants
    private let cardHeight: CGFloat = 96
    private let maxCardWidth: CGFloat = 340
    private let cornerRadius: CGFloat = 16
    private let labelFontSize: CGFloat = 16
    private let bottomPadding: CGFloat = -16
    private let barHeights: [CGFloat] = [28, 38, 28]

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Card background
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(theme.cardColor)

            // Timeline row
            GeometryReader { geo in
                let totalWidth = geo.size.width
                let labelWidth: CGFloat = 48

                ZStack(alignment: .bottomLeading) {

                    HStack(alignment: .bottom, spacing: 0) {
                        Text("12 AM")
                            .font(.custom(theme.bodyFontName, size: labelFontSize))
                            .foregroundColor(theme.primaryTextColor)
                            .frame(width: labelWidth, alignment: .leading)

                        TimelineDashLine()

                        Text("12 AM")
                            .font(.custom(theme.bodyFontName, size: labelFontSize))
                            .foregroundColor(theme.primaryTextColor)
                            .frame(width: labelWidth, alignment: .trailing)
                    }
                    .frame(width: totalWidth)
                    .offset(y: -bottomPadding)

                    ForEach(Array(sessions.prefix(3).enumerated()), id: \.offset) { _, session in
                        let trackWidth = totalWidth - (labelWidth * 2)
                        let xPos = labelWidth + trackWidth * timeFraction(for: session.startTime)

                        SessionMarkerGroup(barHeights: barHeights)
                            .offset(
                                x: xPos - 7,
                                y: -(bottomPadding + 4)
                            )
                    }
                }
                .frame(width: totalWidth, height: cardHeight)
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: maxCardWidth)
        .frame(height: cardHeight)
    }

    private func timeFraction(for date: Date) -> CGFloat {
        let calendar = Calendar.current
        let hour = CGFloat(calendar.component(.hour, from: date))
        let minute = CGFloat(calendar.component(.minute, from: date))
        return (hour * 60 + minute) / (24 * 60)
    }
}

// MARK: - Dashed Line
private struct TimelineDashLine: View {
    @AppStorage(IsoWalkTheme.selectedThemeKey) private var selectedThemeId: String = IsoWalkTheme.defaultThemeId
    private var theme: IsoWalkTheme { IsoWalkTheme.current(selectedId: selectedThemeId) }

    var body: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: geo.size.width, y: 0))
            }
            .stroke(
                theme.primaryTextColor, 
                style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
            )
        }
        .frame(height: 1)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Session Marker Group
struct SessionMarkerGroup: View {
    let barHeights: [CGFloat]

    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(0..<3, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(isoWalkColors.forestGreen)
                    .frame(width: 4, height: barHeights[i])
            }
        }
    }
}
