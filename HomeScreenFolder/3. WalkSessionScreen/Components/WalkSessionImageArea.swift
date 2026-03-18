//
//  WalkSessionImageArea.swift
//  isoWalk
//
//  Created by AnnElaine on 2/17/26.
//
//  COMPONET — dumb child.
//  Displays the selected theme image statically during a walk session.
//  Static (no animation) — two animations already exist on this screen.
//  - FIXED: Added support for static layered themes and video fallbacks.
//

import SwiftUI

struct WalkSessionImageArea: View {
    let theme: IsoWalkTheme

    var body: some View {
        ZStack {
            switch theme.animationType {
            case .layeredAnimation(let bgImage, let overlayImage, _):
                // Layered view, strictly static (no animation logic here)
                ZStack {
                    Image(bgImage)
                        .resizable()
                        .scaledToFit()
                    
                    Image(overlayImage)
                        .resizable()
                        .scaledToFit()
                        .opacity(0.7) // Keeping the same opacity for consistency
                }
                
            case .video(_, let fallback):
                // Safe static fallback for video themes
                Image(fallback)
                    .resizable()
                    .scaledToFit()
                
            default:
                // Original single image logic
                Image(theme.mainImageName)
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(width: AnimatedImageSize.medium.dimension,
               height: AnimatedImageSize.medium.dimension)
        .padding(.vertical, 8)
    }
}

#Preview {
    ZStack {
        Color.white // Using white to match your screenshot
            .ignoresSafeArea()
        WalkSessionImageArea(theme: IsoWalkThemes.cloudyTreeTheme)
    }
}
