//
//  ThemeMediaView.swift
//  isoWalk
//
//  Created by AnnElaine on 3/18/26.
//
//  SMART MEDIA ROUTER for all app backgrounds.
//  This view automatically reads the current theme and renders the exact right
//  background type (Static, Legacy Koi Fish, Layered Fog, or Kling AI Video).
//
//  USAGE:
//  - Drop this view into the ZStack of any screen that needs the background.
//  - Pass `isAnimated: true` for standard screens (ThemeOptions, Privacy, etc.).
//  - Pass `isAnimated: false` for busy screens (WalkSessionScreen) to force a static image.
//
//  NOTE: You do NOT need to edit this file when adding new themes to the app,
//  unless you are inventing a completely new `ThemeAnimationType`.
//

import SwiftUI
import AVKit

struct ThemeMediaView: View {
    let theme: IsoWalkTheme
    let isAnimated: Bool // Pass 'false' on WalkSessionScreen to disable movement
    
    var body: some View {
        ZStack {
            // 1. Draw the Base Background (White for tree, Parchment for others)
            if let bgName = theme.backgroundImageName {
                Image(bgName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            } else {
                theme.backgroundColor
                    .ignoresSafeArea()
            }
            
            // 2. Draw the Content/Animation
            if !isAnimated {
                // WALK SESSION SCREEN: Static image only, no animations
                Image(theme.mainImageName)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
            } else {
                // ALL OTHER SCREENS: Route to the correct animation type
                switch theme.animationType {
                    
                case .layeredAnimation(let bgImage, let overlayImage, let overlayAnim):
                    LayeredFogView(bgImage: bgImage, overlayImage: overlayImage, animation: overlayAnim)
                    
                case .video(let filename, let fallback):
                    // Future proofed for Kling AI!
                    LoopingVideoView(videoName: filename, fallbackImage: fallback)
                    
                case .none:
                    Image(theme.mainImageName)
                        .resizable()
                        .scaledToFit()
                        .ignoresSafeArea()
                    
                default:
                    // KOI FISH & LEGACY CONFIGS:
                    // We display the image safely to ensure it doesn't break,
                    // relying on the parent view to apply the legacy rotatingPulse animations.
                    Image(theme.mainImageName)
                        .resizable()
                        .scaledToFit()
                        .ignoresSafeArea()
                }
            }
        }
    }
}

// MARK: - Layered Fog Animation
// This struct handles the Japanese Tree + Clouds layered setup.
// It uses a classic side-by-side looping trick to create a seamless,
// continuous scroll from right to left.
struct LayeredFogView: View {
    let bgImage: String
    let overlayImage: String
    let animation: OverlayAnimation
    
    // We use a specific animation speed, independent of the variable duration parameter.
    private let continuousSpeed: Double = 30.0 // LOWER = FASTER (Seconds to cross screen once)
    
    @State private var scrollOffset: CGFloat = 0
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // 1. Fixed Japanese Tree Background
            Image(bgImage)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // 2. Continuous Looping Fog Overlay (Slides Right to Left)
            GeometryReader { geo in
                // Using an HStack with two identical images side-by-side allows us to create
                // a perfectly seamless loop with no gaps.
                HStack(spacing: 0) {
                    // Image A (starts centered)
                    Image(overlayImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width)
                    
                    // Image B (starts off-screen right)
                    Image(overlayImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width)
                }
                .frame(width: geo.size.width * 2, alignment: .leading) // Full width of the two-image strip
                
                // --- THE ANIMATION LOGIC ---
                // Start: centered (offset 0).
                // End: shifted left by exactly one screen width (offset -width).
                // Then repeat without autoreversing to instantly snap back to 0.
                .offset(x: isAnimating ? -geo.size.width : 0)
                .animation(
                    .linear(duration: continuousSpeed).repeatForever(autoreverses: false),
                    value: isAnimating
                )
                .onAppear {
                    // Start the animation as soon as the view is rendered.
                    // The image is already centered by default.
                    isAnimating = true
                }
                .onDisappear {
                    // Turn off animation to save CPU when off-screen.
                    isAnimating = false
                }
            }
            .ignoresSafeArea()
            .opacity(0.8) // Slightly transparent for better blending
        }
    }
}

// MARK: - Kling AI Video Future-Proofing
// Uses UIViewRepresentable so we can hide playback controls (VideoPlayer shows them)
struct LoopingVideoView: UIViewRepresentable {
    let videoName: String
    let fallbackImage: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        // 1. Check if the video file exists in the bundle
        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            // If video isn't added yet, show the fallback image safely without crashing
            let imageView = UIImageView(image: UIImage(named: fallbackImage))
            imageView.contentMode = .scaleAspectFill
            imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(imageView)
            return view
        }
        
        // 2. Set up seamless looping player
        let playerItem = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        context.coordinator.looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        
        let playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer.videoGravity = .resizeAspectFill
        
        // Use a sublayer so it resizes correctly
        let layerView = VideoLayerView()
        layerView.layer.addSublayer(playerLayer)
        context.coordinator.playerLayer = playerLayer
        
        view.addSubview(layerView)
        layerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        queuePlayer.play()
        queuePlayer.isMuted = true // Background videos should always be muted
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Handle resizing if the screen rotates
        context.coordinator.playerLayer?.frame = uiView.bounds
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var looper: AVPlayerLooper?
        var playerLayer: AVPlayerLayer?
    }
    
    // Helper view to force the layer to resize with SwiftUI
    class VideoLayerView: UIView {
        override func layoutSubviews() {
            super.layoutSubviews()
            layer.sublayers?.first?.frame = bounds
        }
    }
}
