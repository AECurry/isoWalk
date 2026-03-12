//
//  BadgeFeaturedView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONENT — dumb child.
//  Shows the most recently earned badge large at top.
//  Shows locked placeholder if no badges earned yet.
//  Receives data from parent — owns nothing.
//

import SwiftUI

struct BadgeFeaturedView: View {

    let mostRecentBadge: Badge?
    let earnedCount: Int
    let themeId: String
    let showReveal: Bool
    let newlyUnlockedBadge: Badge?
    let onRevealComplete: () -> Void

    // MARK: - Design Constants
    private let circleSize: CGFloat = 160
    private let iconSize: CGFloat = 80
    private let countFontSize: CGFloat = 48
    private let labelFontSize: CGFloat = 18

    @State private var isSpinning = false
    @State private var showSparkles = false
    @State private var revealScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 12) {

            ZStack {
                // Badge circle
                Circle()
                    .fill(isoWalkColors.forestGreen)
                    .frame(width: circleSize, height: circleSize)

                badgeImage
                    .scaleEffect(revealScale)

                // Sparkle overlay during reveal
                if showSparkles {
                    SparkleView()
                }
            }
            .rotationEffect(.degrees(isSpinning ? 360 : 0))
            .onChange(of: showReveal) { _, newValue in
                if newValue { startRevealAnimation() }
            }

            Text("\(earnedCount)")
                .font(.custom("Inter-Bold", size: countFontSize))
                .foregroundColor(isoWalkColors.deepSpaceBlue)

            Text("Badges Earned")
                .font(.custom("Inter-Regular", size: labelFontSize))
                .foregroundColor(isoWalkColors.deepSpaceBlue.opacity(0.8))
        }
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var badgeImage: some View {
        if let badge = mostRecentBadge, badge.isUnlocked {
            let assetName = badge.id.imageName(themeId: themeId)
            if UIImage(named: assetName) != nil {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
            } else {
                // SF Symbol fallback until real assets exist
                Image(systemName: "trophy.fill")
                    .font(.system(size: iconSize * 0.6))
                    .foregroundColor(.white)
            }
        } else {
            // No badge earned yet
            Image(systemName: "trophy.fill")
                .font(.system(size: iconSize * 0.6))
                .foregroundColor(.white)
        }
    }

    private func startRevealAnimation() {
        // Step 1: Spin
        withAnimation(.linear(duration: 1.2)) {
            isSpinning = true
        }
        // Step 2: Sparkles appear mid-spin
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showSparkles = true
        }
        // Step 3: Scale pop
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                revealScale = 1.3
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                revealScale = 1.0
            }
        }
        // Step 4: Clean up
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isSpinning = false
            showSparkles = false
            onRevealComplete()
        }
    }
}

// MARK: - Sparkle View
// Simple sparkle burst using circles radiating outward
private struct SparkleView: View {
    @State private var animate = false

    private let sparkleCount = 8
    private let radius: CGFloat = 90

    var body: some View {
        ZStack {
            ForEach(0..<sparkleCount, id: \.self) { i in
                Circle()
                    .fill(Color.yellow.opacity(animate ? 0 : 0.9))
                    .frame(width: 8, height: 8)
                    .offset(
                        x: animate ? radius * cos(angle(for: i)) : 0,
                        y: animate ? radius * sin(angle(for: i)) : 0
                    )
                    .animation(
                        .easeOut(duration: 0.8).delay(Double(i) * 0.05),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }

    private func angle(for index: Int) -> CGFloat {
        CGFloat(index) * (2 * .pi / CGFloat(sparkleCount))
    }

    private func cos(_ angle: CGFloat) -> CGFloat { Foundation.cos(angle) }
    private func sin(_ angle: CGFloat) -> CGFloat { Foundation.sin(angle) }
}

