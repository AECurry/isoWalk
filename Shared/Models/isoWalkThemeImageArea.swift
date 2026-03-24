//
//  isoWalkThemeImageArea.swift
//  isoWalk
//
//  Created by AnnElaine on 3/23/26.
//
//  SHARED COMPONENT
//  Universal theme image display. Can render as fully animated (default)
//  or static (for screens like WalkSession that have too many animations).
//

import SwiftUI

struct isoWalkThemeImageArea: View {
    let theme: IsoWalkTheme
    var isAnimated: Bool = true
    var size: CGFloat = 200 // Default size, but overridable
    
    // Configurable padding with safe default values
    var topPadding: CGFloat = 24
    var bottomPadding: CGFloat = 16
    
    var body: some View {
        Group {
            if isAnimated {
                // MARK: - Animated Version
                SquareThemeEngineView(
                    theme: theme,
                    frameWidth: size
                )
            } else {
                // MARK: - Static Version (for WalkSession)
                staticImageView
                    .frame(width: size, height: size)
            }
        }
        // Apply the padding directly to the component wrapper
        .padding(.top, topPadding)
        .padding(.bottom, bottomPadding)
    }
    
    // MARK: - Static Rendering Logic
    @ViewBuilder
    private var staticImageView: some View {
        ZStack {
            switch theme.animationType {
            case .layeredAnimation(let bgImage, let overlayImage, _):
                ZStack {
                    Image(bgImage)
                        .resizable()
                        .scaledToFit()
                    
                    Image(overlayImage)
                        .resizable()
                        .scaledToFit()
                        .opacity(0.7)
                }
                
            case .video(_, let fallback):
                Image(fallback)
                    .resizable()
                        .scaledToFit()
                
            default:
                Image(theme.mainImageName)
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}
