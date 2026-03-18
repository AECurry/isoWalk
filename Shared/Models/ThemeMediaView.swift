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

import SwiftUI
import AVKit

struct ThemeMediaView: View {
    let theme: IsoWalkTheme
    let isAnimated: Bool
    
    var body: some View {
        ZStack {
            // 1. BASE BACKGROUND
            if let bgName = theme.backgroundImageName {
                Image(bgName).resizable().aspectRatio(contentMode: .fill).ignoresSafeArea()
            } else {
                theme.backgroundColor.ignoresSafeArea()
            }
            
            // 2. ISOLATED CONTENT ROUTING
            if isAnimated {
                switch theme.animationType {
                    
                // --- LAYERED THEME (JAPANESE TREE) ---
                case .layeredAnimation(let bgImage, let overlayImage, _):
                    // STRICTLY ISOLATED: The Japanese Tree Test View (NO ANIMATION)
                    LayeredAlignmentTestView(bgImage: bgImage, overlayImage: overlayImage)
                    
                // --- KOI FISH THEMES (FULLY WORKING & ISOLATED) ---
                case .rotation(let speed):
                    Image(theme.mainImageName).resizable().scaledToFit()
                        .modifier(RotateModifier(speed: speed))
                        
                case .pulse(let minSc, let maxSc, let speed):
                    Image(theme.mainImageName).resizable().scaledToFit()
                        .modifier(PulseModifier(minScale: minSc, maxScale: maxSc, speed: speed))
                        
                case .rotatingPulse(let rotSpeed, let minSc, let maxSc, let pulseSpeed):
                    Image(theme.mainImageName).resizable().scaledToFit()
                        .modifier(RotateModifier(speed: rotSpeed))
                        .modifier(PulseModifier(minScale: minSc, maxScale: maxSc, speed: pulseSpeed))
                        
                // --- VIDEO THEMES ---
                case .video(let filename, let fallback):
                    LoopingVideoView(videoName: filename, fallbackImage: fallback)
                    
                // --- STATIC FALLBACK ---
                case .none:
                    Image(theme.mainImageName).resizable().scaledToFit()
                }
                
            } else {
                // WALK SESSION SCREEN (ALWAYS STATIC)
                switch theme.animationType {
                case .layeredAnimation(let bgImage, let overlayImage, _):
                    LayeredAlignmentTestView(bgImage: bgImage, overlayImage: overlayImage)
                default:
                    Image(theme.mainImageName).resizable().scaledToFit()
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - THE TEST VIEW (Zero Animation, Pure Stacking)
struct LayeredAlignmentTestView: View {
    let bgImage: String
    let overlayImage: String
    
    var body: some View {
        ZStack {
            Image(bgImage)
                .resizable()
                .scaledToFit()
            
            Image(overlayImage)
                .resizable()
                .scaledToFit()
                .opacity(0.7) // Keeping opacity at 0.7 so we can clearly see the overlap
        }
    }
}

// MARK: - ISOLATED ANIMATION MODIFIERS FOR KOI FISH
// Because these are ViewModifiers, they only apply to the exact image they are attached to.

struct RotateModifier: ViewModifier {
    let speed: Double
    @State private var rotation: Double = 0
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: speed).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

struct PulseModifier: ViewModifier {
    let minScale: Double
    let maxScale: Double
    let speed: Double
    @State private var scale: Double = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                scale = minScale
                withAnimation(.easeInOut(duration: speed).repeatForever(autoreverses: true)) {
                    scale = maxScale
                }
            }
    }
}

// MARK: - LOOPING VIDEO VIEW (iOS 26 Compliant)
struct LoopingVideoView: UIViewRepresentable {
    let videoName: String
    let fallbackImage: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            let imageView = UIImageView(image: UIImage(named: fallbackImage))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(imageView)
            return view
        }
        let playerItem = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        context.coordinator.looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        let playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer.videoGravity = .resizeAspectFill
        let videoContainer = VideoContainerView(playerLayer: playerLayer)
        view.addSubview(videoContainer)
        videoContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            videoContainer.topAnchor.constraint(equalTo: view.topAnchor),
            videoContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            videoContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        queuePlayer.play()
        queuePlayer.isMuted = true
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator() }
    class Coordinator { var looper: AVPlayerLooper? }
}

class VideoContainerView: UIView {
    var playerLayer: AVPlayerLayer
    init(playerLayer: AVPlayerLayer) {
        self.playerLayer = playerLayer
        super.init(frame: .zero)
        self.layer.addSublayer(playerLayer)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = self.bounds
    }
}
