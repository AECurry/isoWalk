//
//  ImageAreaView.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
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
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0

    var body: some View {
        ZStack {
            switch theme.animationType {
            case .layeredAnimation(let bgImage, let overlayImage, let overlayAnim):
                layeredView(backgroundImage: bgImage, overlayImage: overlayImage, overlayAnimation: overlayAnim)
            default:
                singleImageView
            }
        }
        .frame(width: AnimatedImageSize.extraLarge.dimension,
               height: AnimatedImageSize.extraLarge.dimension)
        .id(theme.id)
        .onAppear { applyThemeAnimation() }
        .onChange(of: theme.id) { applyThemeAnimation() }
    }
    
    // MARK: - Single Image View
    
    private var singleImageView: some View {
        Image(theme.mainImageName)
            .resizable()
            .scaledToFit()
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
    }
    
    // MARK: - Layered View
    
    private func layeredView(backgroundImage: String, overlayImage: String, overlayAnimation: OverlayAnimation) -> some View {
        ZStack {
            // Fixed background layer
            Image(backgroundImage)
                .resizable()
                .scaledToFit()
            
            // Animated overlay layer
            Image(overlayImage)
                .resizable()
                .scaledToFit()
                .offset(x: offsetX, y: offsetY)
                .opacity(0.7)  // Slightly transparent for depth
        }
    }

    private func applyThemeAnimation() {
        // Set rest position synchronously — no visible snap
        rotation = 0
        scale = 1.0
        offsetX = 0
        offsetY = 0

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
                
            case .layeredAnimation(_, _, let overlayAnim):
                animateOverlay(overlayAnim)

            case .none:
                break
            }
        }
    }
    
    // MARK: - Overlay Animation
    
    private func animateOverlay(_ animation: OverlayAnimation) {
        switch animation {
        case .drift(let xOff, let yOff, let duration):
            // Slow drift animation - clouds moving gently
            withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                offsetX = xOff
                offsetY = yOff
            }
            
        case .pulse(let minSc, let maxSc, let speed):
            scale = minSc
            withAnimation(.easeInOut(duration: speed).repeatForever(autoreverses: true)) {
                scale = maxSc
            }
            
        case .rotate(let speed):
            withAnimation(.linear(duration: speed).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

#Preview {
    ImageAreaView(theme: IsoWalkThemes.all[0])
}

