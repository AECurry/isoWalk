//
//  SetUpImageArea.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
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
        .frame(width: size.dimension, height: size.dimension)
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
        rotation = 0
        scale = 1.0
        offsetX = 0
        offsetY = 0

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

