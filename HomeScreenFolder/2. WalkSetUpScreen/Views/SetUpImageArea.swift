//
//  SetUpImageArea.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//
//  COMPONENT — dumb child.
//  Displays the theme image in the setup screen.
//  Receives theme from parent. Owns nothing.
//  - FIXED: Replaced deprecated UIScreen.main.bounds with GeometryReader
//  - FIXED: Added exhaustive switch coverage for .video and .none support
//

import SwiftUI

struct SetUpImageArea: View {
    
    let theme: IsoWalkTheme
    @State private var offsetX: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        // We use GeometryReader here to get the width without using the deprecated UIScreen.main
        GeometryReader { geo in
            ZStack {
                switch theme.animationType {
                case .layeredAnimation(let bgImage, let overlayImage, let overlayAnim):
                    layeredView(backgroundImage: bgImage, overlayImage: overlayImage, overlayAnimation: overlayAnim)
                    
                case .video(_, let fallback):
                    // Fallback to static image for setup preview
                    Image(fallback)
                        .resizable()
                        .scaledToFit()
                    
                default:
                    singleImageView
                }
            }
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .id(theme.id)
            .onAppear { startAnimation(viewWidth: geo.size.width) }
        }
        .frame(height: 200) // Ensure the GeometryReader takes the proper height
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
        GeometryReader { geo in
            ZStack {
                // Fixed background
                Image(backgroundImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width)
                
                // Animated overlay
                Image(overlayImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width)
                    .offset(x: offsetX)
                    .opacity(0.7)
            }
        }
    }
    
    // MARK: - Animation
    
    private func startAnimation(viewWidth: CGFloat) {
        offsetX = 0
        rotation = 0
        scale = 1.0
        
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
                animateOverlay(overlayAnim, viewWidth: viewWidth)
                
            case .video, .none:
                break
            }
        }
    }
    
    private func animateOverlay(_ animation: OverlayAnimation, viewWidth: CGFloat) {
        switch animation {
        case .none:
            // ADDED: Explicitly tell it to do nothing
            break
            
        case .horizontalDrift(let duration):
            // Start off-screen left (using the GeometryReader width instead of UIScreen)
            offsetX = -viewWidth
            
            // Drift to off-screen right
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                offsetX = viewWidth * 2
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
    SetUpImageArea(theme: IsoWalkThemes.cloudyTreeTheme)
        .background(Color.white)
}
