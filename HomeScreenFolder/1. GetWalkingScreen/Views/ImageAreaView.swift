//
//  ImageAreaView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  FIX: Animation jump and erratic speed resolved.
//  - DispatchQueue.main.async defers animation start by one run loop tick
//    so SwiftUI finishes its render pass before animation begins.
//    This eliminates the visible snap without needing an isAnimating guard.
//  - rotation = 0 and scale = minSc are set synchronously BEFORE the
//    async block so the image renders at rest while SwiftUI settles.
//

import SwiftUI

struct ImageAreaView: View {
    let theme: IsoWalkTheme

    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0

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
            .onChange(of: theme.id) { applyThemeAnimation() }
    }

    private func applyThemeAnimation() {
        // Set rest position synchronously — no visible snap
        rotation = 0
        scale = 1.0

        // Defer animation start by one run loop so SwiftUI
        // finishes rendering before animation begins
        DispatchQueue.main.async {
            switch theme.animationType {
            case .rotation(let speed):
                withAnimation(.linear(duration: speed).repeatForever(autoreverses: false)) {
                    rotation = 360
                }

            case .pulse(let min, let max, let speed):
                scale = min
                withAnimation(.easeInOut(duration: speed).repeatForever(autoreverses: true)) {
                    scale = max
                }

            case .rotatingPulse(let rotSpeed, let minSc, let maxSc, let pulseSpeed):
                withAnimation(.linear(duration: rotSpeed).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
                scale = minSc
                withAnimation(.easeInOut(duration: pulseSpeed).repeatForever(autoreverses: true)) {
                    scale = maxSc
                }

            case .none:
                break
            }
        }
    }
}

#Preview {
    ImageAreaView(theme: IsoWalkThemes.all[0])
}

