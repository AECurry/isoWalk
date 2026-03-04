//
//  ImageAreaView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//

import SwiftUI

struct ImageAreaView: View {
    let theme: IsoWalkTheme

    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var isAnimating: Bool = false

    var body: some View {
        Image(theme.mainImageName)
            .resizable()
            .scaledToFit()
            .frame(width: AnimatedImageSize.extraLarge.dimension,
                   height: AnimatedImageSize.extraLarge.dimension)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .id(theme.id)
            .onAppear { applyThemeAnimation() }
            .onDisappear { isAnimating = false }
    }

    private func applyThemeAnimation() {
        // Reset first — prevents stacked animations when onAppear
        // fires again after navigation returns to this screen.
        rotation = 0
        scale = 1.0
        isAnimating = true

        switch theme.animationType {
        case .rotation(let speed):
            withAnimation(
                .linear(duration: speed)
                .repeatForever(autoreverses: false)
                // Speed-based autoReverse false keeps rotation smooth
            ) {
                rotation = 360
            }
        case .pulse(let min, let max, let speed):
            scale = min
            withAnimation(
                .easeInOut(duration: speed)
                .repeatForever(autoreverses: true)
            ) {
                scale = max
            }
        case .rotatingPulse(let rotSpeed, let minSc, let maxSc, let pulseSpeed):
            withAnimation(
                .linear(duration: rotSpeed)
                .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
            scale = minSc
            withAnimation(
                .easeInOut(duration: pulseSpeed)
                .repeatForever(autoreverses: true)
            ) {
                scale = maxSc
            }
        case .none:
            break
        }
    }
}

#Preview {
    ImageAreaView(theme: IsoWalkThemes.all[0])
}
