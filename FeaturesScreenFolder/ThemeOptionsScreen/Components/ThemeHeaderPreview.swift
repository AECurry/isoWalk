//
//  ThemeHeaderPreview.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONENT — dumb child.
//  Receives a theme and displays the large animated preview.
//  Owns its own animation state; re-triggers when theme.id changes.
//  No box, no border — image floats freely.
//

import SwiftUI

struct ThemeHeaderPreview: View {

    let theme: IsoWalkTheme
    let frameSize: CGFloat

    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Image(theme.mainImageName)
            .resizable()
            .scaledToFit()
            .frame(width: frameSize, height: frameSize)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .id(theme.id)
            .onAppear { startAnimation() }
    }

    private func startAnimation() {
        rotation = 0
        scale = 1.0

        switch theme.animationType {
        case .rotation(let speed):
            withAnimation(.linear(duration: speed).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        case .pulse(let minSc, let maxSc, let speed):
            scale = minSc
            withAnimation(.easeInOut(duration: speed).repeatForever(autoreverses: true)) {
                scale = maxSc
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
    ThemeHeaderPreview(theme: IsoWalkThemes.all[0], frameSize: 220)
        .padding()
}
