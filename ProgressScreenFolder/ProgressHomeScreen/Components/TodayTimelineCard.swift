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

    // MARK: - Design Constants
    private let cardHeight: CGFloat = 90
    private let maxCardWidth: CGFloat = 340
    private let cornerRadius: CGFloat = 14
    private let labelFontSize: CGFloat = 14
    private let bottomPadding: CGFloat = -16
    private let barHeights: [CGFloat] = [28, 38, 28]

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Card background
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(isoWalkColors.ivory)

            // Timeline row — labels + dashed line on same baseline
            GeometryReader { geo in
                let totalWidth = geo.size.width
                let labelWidth: CGFloat = 44

                ZStack(alignment: .bottomLeading) {

                    HStack(alignment: .bottom, spacing: 0) {
                        Text("12 AM")
                            .font(.custom("Inter-Regular", size: labelFontSize))
                            .foregroundColor(isoWalkColors.deepSpaceBlue)
                            .frame(width: labelWidth, alignment: .leading)

                        // Dashed line stretches to fill remaining space
                        TimelineDashLine()

                        Text("12 AM")
                            .font(.custom("Inter-Regular", size: labelFontSize))
                            .foregroundColor(isoWalkColors.deepSpaceBlue)
                            .frame(width: labelWidth, alignment: .trailing)
                    }
                    .frame(width: totalWidth)
                    .offset(y: -bottomPadding)

                    // Session bars — positioned horizontally by time,
                    // sitting directly above the dashed line
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
    var body: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: geo.size.width, y: 0))
            }
            .stroke(
                isoWalkColors.deepSpaceBlue,
                style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
            )
        }
        .frame(height: 1)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Session Marker Group
private struct SessionMarkerGroup: View {
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

#Preview {
    ZStack {
        Image("GoldenTextureBackground")
            .resizable()
            .ignoresSafeArea()
        VStack(spacing: 12) {
            // No sessions
            TodayTimelineCard(sessions: [])

            // One session — morning
            TodayTimelineCard(sessions: [
                CompletedSession(
                    id: UUID(),
                    duration: .twentyOne,
                    music: .placeholder,
                    pace: .steady,
                    startTime: Calendar.current.date(bySettingHour: 8, minute: 30, second: 0, of: Date())!,
                    endTime: Date(),
                    totalDuration: 21 * 60,
                    wasPaused: false
                )
            ])

            // Two sessions
            TodayTimelineCard(sessions: [
                CompletedSession(
                    id: UUID(),
                    duration: .twentyOne,
                    music: .placeholder,
                    pace: .steady,
                    startTime: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!,
                    endTime: Date(),
                    totalDuration: 21 * 60,
                    wasPaused: false
                ),
                CompletedSession(
                    id: UUID(),
                    duration: .twentyOne,
                    music: .placeholder,
                    pace: .steady,
                    startTime: Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date())!,
                    endTime: Date(),
                    totalDuration: 21 * 60,
                    wasPaused: false
                )
            ])
        }
        .padding()
    }
}

