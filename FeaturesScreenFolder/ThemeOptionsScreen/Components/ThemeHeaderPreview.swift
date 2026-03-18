//
//  ThemeHeaderPreview.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  Updated 3/18/26: Added horizontal drift for cloud animation
//  - FIXED: Exhaustive switch coverage for .video support and .none
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
                
            case .video(_, let fallback):
                // Safe fallback for video themes in this preview component
                Image(fallback)
                    .resizable()
                    .scaledToFit()
                    
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
    
    // MARK: - Layered View
    
    private func layeredView(backgroundImage: String, overlayImage: String, overlayAnimation: OverlayAnimation) -> some View {
        ZStack {
            // Fixed background layer (tree)
            Image(backgroundImage)
                .resizable()
                .scaledToFit()
            
            // Animated overlay layer (clouds)
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

            case .video, .none:
                break // No programmatic @State animation needed for videos or static images
            }
        }
    }
    
    // MARK: - Overlay Animation
    
    private func animateOverlay(_ animation: OverlayAnimation) {
        switch animation {
        case .none:
            // ADDED THIS CASE: Do absolutely nothing so the images just sit still.
            break
            
        case .horizontalDrift(let duration):
            // Start clouds off-screen to the left
            offsetX = -frameSize
            
            // Animate clouds moving from left to right across the screen
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                offsetX = frameSize * 2  // Move fully off-screen to the right
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
