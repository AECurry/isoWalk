//
//  SetUpImageArea.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONENT — dumb child.
//  Displays the animated theme image.
//  Size comes from AnimatedImageSize defined in AnimatedImageConfig.swift.
//

import SwiftUI

struct SetUpImageArea: View {

    let theme: IsoWalkTheme
    var size: AnimatedImageSize = .medium

    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Image(theme.mainImageName)
            .resizable()
            .scaledToFit()
            .frame(width: size.dimension, height: size.dimension)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .id(theme.id)
            .onAppear { applyThemeAnimation() }
    }

    private func applyThemeAnimation() {
        // Reset to starting values first — prevents stacked animations
        // when onAppear fires again after navigation back to this screen.
        rotation = 0
        scale = 1.0

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

#Preview {
    ZStack {
        Image("GoldenTextureBackground")
            .resizable()
            .ignoresSafeArea()
        VStack(spacing: 40) {
            SetUpImageArea(theme: IsoWalkThemes.all[0], size: .extraLarge)
            SetUpImageArea(theme: IsoWalkThemes.all[0], size: .medium)
        }
    }
}

