//
//  ThemeHeaderPreview.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONENT — dumb child.
//  Receives a theme and displays the large animated preview at the top of the screen.
//  Owns its own animation state; re-triggers when theme.id changes.
//

import SwiftUI

struct ThemeHeaderPreview: View {

    // MARK: - Input
    let theme: IsoWalkTheme
    let frameSize: CGFloat // You already have this!

    // MARK: - Private Animation State
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0

    // MARK: - Body
    var body: some View {
        // Wrap in a ZStack to ensure the 'box' stays the same size
        // even when the image inside pulses or rotates.
        ZStack {
            Image(theme.mainImageName)
                .resizable()
                .scaledToFit()
                // Use the variable here instead of 220
                .frame(width: frameSize, height: frameSize)
                .rotationEffect(.degrees(rotation))
                .scaleEffect(scale)
        }
        // These styles now wrap the dynamic size perfectly
        .clipShape(RoundedRectangle(cornerRadius: frameSize / 7)) // Responsive corner radius
        .overlay(
            RoundedRectangle(cornerRadius: frameSize / 7)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.black.opacity(0.8), Color.black.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
        )
        .shadow(color: .black.opacity(0.18), radius: 20, x: 0, y: 8)
        .id(theme.id)
        .onAppear { startAnimation() }
    }

    // MARK: - Animation Logic (No changes needed here)
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

// FIXED PREVIEW
#Preview {
    // You MUST pass frameSize here or it won't compile
    ThemeHeaderPreview(theme: IsoWalkThemes.all[0], frameSize: 220)
        .padding()
}

