//
//  AnimatedThemeView.swift
//  isoWalk
//
//  Created by AnnElaine on 3/19/26.
//
//  THE CORE RENDERING ENGINE FOR SQUARE IMAGE AREAS.
//  This is the single source of truth for animating the square theme images
//  (like in the Header, Setup, and Features screens).
//

import SwiftUI

struct SquareThemeEngineView: View {
    let theme: IsoWalkTheme
    let frameWidth: CGFloat

    // ALL animation state lives exclusively here
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    
    // Conveyor Belt Math adapts to whatever width is passed in
    private var cloudGap: CGFloat { frameWidth * 0.60 }
    private var shiftAmount: CGFloat { frameWidth + cloudGap }

    var body: some View {
        ZStack {
            switch theme.animationType {
            case .layeredAnimation(let bgImage, let overlayImage, let overlayAnim):
                layeredView(backgroundImage: bgImage, overlayImage: overlayImage, overlayAnimation: overlayAnim)
                
            case .video(_, let fallback):
                Image(fallback)
                    .resizable()
                    .scaledToFit()
                
            default:
                singleImageView
            }
        }
        .frame(width: frameWidth, height: frameWidth) // Enforces a perfect square
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
            
            // Animated overlay layer (Conveyor Belt)
            ZStack {
                // IMAGE 2: Waiting off-screen left
                Image(overlayImage)
                    .resizable()
                    .scaledToFit()
                    .offset(x: offsetX - shiftAmount, y: offsetY)
                
                // IMAGE 1: Starting centered
                Image(overlayImage)
                    .resizable()
                    .scaledToFit()
                    .offset(x: offsetX, y: offsetY)
            }
            .opacity(0.7)
        }
    }

    // MARK: - Animation Logic
    
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
                // EXACTLY ONE SECOND PAUSE BEFORE WIND BLOWS
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    animateOverlay(overlayAnim)
                }

            case .video, .none:
                break
            }
        }
    }
    
    private func animateOverlay(_ animation: OverlayAnimation) {
        switch animation {
        case .none:
            break
            
        case .horizontalDrift(let duration):
            // The magic looping conveyor belt
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                offsetX = shiftAmount
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

