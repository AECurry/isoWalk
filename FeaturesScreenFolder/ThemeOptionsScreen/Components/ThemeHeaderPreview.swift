//
//  ThemeHeaderPreview.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//
//  COMPONENT — dumb child.
//  Receives a theme and displays the large animated preview.
//  No box, no border — image floats freely.
//

import SwiftUI

struct ThemeHeaderPreview: View {

    let theme: IsoWalkTheme
    let frameSize: CGFloat

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
        .frame(width: frameSize, height: frameSize)
        .id(theme.id)
        .onAppear { startAnimation() }
        .onChange(of: theme.id) { startAnimation() }
    }
    
    // MARK: - Single Image View (Original)
    
    private var singleImageView: some View {
        Image(theme.mainImageName)
            .resizable()
            .scaledToFit()
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
    }
    
    // MARK: - Layered View (NEW)
    
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

    private func startAnimation() {
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
    VStack(spacing: 40) {
        // Original koi theme
        ThemeHeaderPreview(theme: IsoWalkThemes.all[0], frameSize: 220)
        
        // New cloudy tree theme
        ThemeHeaderPreview(theme: IsoWalkThemes.cloudyTreeTheme, frameSize: 220)
    }
    .padding()
}
